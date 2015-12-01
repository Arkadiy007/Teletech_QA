/**********************************************************************
Name: Batch_Buyback_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Stage_SMM__c table data from SAP into the Buyback__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 	12/23/2011 Created
***********************************************************************/
//Batch_Buyback_DataLoad batchJob = new Batch_Buyback_DataLoad();
//Database.executeBatch(batchJob);
//List<Stage_SMM__c> lst = [select ID, Successful__c from Stage_SMM__c];
//for (Stage_SMM__c c : lst) {
//	c.Successful__c = null;
//	c.Error_Message__c = null;
//}
//update lst;
//delete [select id from error_log__c];
global class Batch_Buyback_DataLoad implements Database.Batchable<sObject> {
	ID bbRTid = '012F0000000yCk4';
	global String query = 'Select Vehicle_Identification_Number__c, ' + 
							'Sold_Date__c, ' + 
							'Sold_Amount__c, ' + 
							'Id, Name, ' + 
							'LastModifiedDate, ' + 
							'Dealer_Code__c, ' + 
							'Dealer_Name__c, ' + 
							'CreatedDate, ' + 
							'Contract_Type__c, ' + 
							'Contract_Number__c, ' + 
							'Centre_Type__c, ' + 
							'Centre_Arrival_Date__c, ' + 
							'Buyback_Status__c, ' + 
							'Buyback_Indicator__c, ' + 
							'Business_Source_Code__c ' + 
						'From Stage_SMM__c ' + 
						'WHERE Successful__c != \'Y\' Order by Vehicle_Identification_Number__c, Name';
	
    global Database.QueryLocator start(Database.BatchableContext BC){	      
        return Database.getQueryLocator(query);
    } 
	
    global void execute(Database.BatchableContext BC, List<Stage_SMM__c> lstBuybackTable) {
		Map<String, Stage_SMM__c> deduppedSMM = new Map<String, Stage_SMM__c>();
		// Loop through all Stage_SMM records returned to get a List of SMM unique by the VIN
		for (Stage_SMM__c stage : lstBuybackTable)
			deduppedSMM.put(stage.Vehicle_Identification_Number__c, stage);
		
 		Map<String, List<Buyback__c>> buybackMap = new Map<String, List<Buyback__c>>();
    	// Get existing Buyback objects from the VIN list
    	for (Buyback__c b : [select Vehicle__c, 
						    	Vehicle_Identification_Number__c, 
						    	Sold_Date__c, 
						    	Sold_Amount__c, 
						    	LastModifiedDate, 
						    	Dealer_Code__c,
						    	Dealer_Name__c,
						    	Id, Name,
						    	CreatedDate, 
								Contract_Type__c, 
								Contract_Number__c, 
								Centre_Type__c, 
						    	Centre_Arrival_Date__c, 
						    	Case__c, 
						    	Buyback_Status__c, 
								Business_Source_Code__c
					    	From Buyback__c
					    	where RecordTypeID =: bbRTid and 
					    		Vehicle_Identification_Number__c in :deduppedSMM.keySet()
					    	Order by Vehicle_Identification_Number__c]) {
			List<Buyback__c> buybacks;
			String key = b.Vehicle_Identification_Number__c;
			if (buybackMap.containsKey(key))
				buybacks = buybackMap.get(key);
			else {
				buybacks = new List<Buyback__c>();
				buybackMap.put(key, buybacks);
			}
			buybacks.add(b);
		}
		
    	List<Buyback__c> buybacksToUpdate = new List<Buyback__c>();	
    	List<Case> casesInsert = new List<Case>();
    	Map<Integer, Buyback__c> buybacksToInsert = new Map<Integer, Buyback__c>();
 		List<Error_Log__c> errors = new List<Error_Log__c>();
 		Map<ID, Stage_SMM__c> updateStageList = new Map<ID, Stage_SMM__c>();
    	List<String> dealerCodes = new List<String>();
    	
    	//map update results
    	Map<Integer, Stage_SMM__c> resultUpsMap = new Map<Integer, Stage_SMM__c>();
 		integer ups = 0;
 		
		// Loop through all Stage_SMM records returned
    	for (Stage_SMM__c smm : deduppedSMM.values()) {
    		if (buybackMap.containsKey(smm.Vehicle_Identification_Number__c)) {
    			List<Buyback__c> buybacks = buybackMap.get(smm.Vehicle_Identification_Number__c);
    			for (Buyback__c b : buybacks) {
		    		// Set Buyback fields from the input Stage_SMM
		    		fillBuyback(b, smm);
		    		if (smm.Dealer_Code__c != null)
		    			dealerCodes.add(smm.Dealer_Code__c);
		    		
		    		// Add Buyback record to the list to update 
		    		buybacksToUpdate.add(b);
		    		
		    		// Save the input Stage_SMM to a numbered Map where the key of the Map is the
		    		// index of the Stage_SMM in the original input.
		    		// note that smm in resultUpsMap can be duplicated.
		    		resultUpsMap.put(ups, smm); 	
		    		ups++;
    			}
    		} else {
                smm.Error_Message__c = 'Could not match VIN = ' + smm.Vehicle_Identification_Number__c + ' in Buyback__c';
            	errors.add(new Error_Log__c(Record_ID__c = smm.Id,
                   			Record_Type__c = 'Buyback__c', 
                            Error_Message__c = smm.Error_Message__c, 
                            TimeStamp__c = System.now(), 
                            Operation_Name__c = 'Batch_Buyback_DataLoad', 
                            Source__c='Salesforce', 
                            Log_Type__c = 'Error', 
                           	Log_Level__c = 1));
                
                smm.Successful__c = 'N';
                updateStageList.put(smm.ID, smm);
    		}
    	}
    	
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (Buyback__c bb : buybacksToUpdate)
                bb.Dealer__c = dealerMap.get(bb.Dealer_Code__c);
        }
        
    	/*
    		If any Buyback rows are in the SF, update them and handle any errors.
    	*/
		if (!buybacksToUpdate.isEmpty()) {	//UPDATE PROCESSED
    		Database.SaveResult[] dbResult = Database.update(buybacksToUpdate, false);
			for (integer row = 0; row < buybacksToUpdate.size(); row++)
                collectErrors(dbResult, row, resultUpsMap.get(row), errors, updateStageList);
    	}
    	
    	/*
    		If any Buyback rows are not in the SF, insert them and handle any errors.
    	*/
    	// If any Buyback were successful, update the Stage_SMM so their Successful__c is set.
    	if (!updateStageList.isEmpty()) {
    		Database.SaveResult[] dbResult = Database.update(updateStageList.values(), false);
    	}
    	
    	// If any errors were returned, add them to the Error_Log table.
    	if (!errors.isEmpty())
            Database.SaveResult[] dbResult = Database.insert(errors, false);
  	}
	
  	private void fillBuyback(Buyback__c bb, Stage_SMM__c stage) {
    	bb.Vehicle_Identification_Number__c = stage.Vehicle_Identification_Number__c;
    	bb.RecordTypeId = bbRTid;
    	bb.Type__c = 'DRT Resolution';
    	bb.Sold_Date__c = stage.Sold_Date__c == null ? null : stage.Sold_Date__c;
    	bb.Sold_Amount__c = stage.Sold_Amount__c; 
		bb.Contract_Type__c = stage.Contract_Type__c;
		bb.Contract_Number__c = stage.Contract_Number__c;
		bb.Centre_Type__c = stage.Centre_Type__c;
    	bb.Arrived_at_Auction_Date__c = stage.Centre_Arrival_Date__c == null ? null : stage.Centre_Arrival_Date__c;
    	bb.CBB_Status__c = stage.Buyback_Status__c;//bb.Buyback_Status__c 
		bb.Business_Source_Code__c = stage.Business_Source_Code__c;
		bb.Mailing_Address_Verified__c = true;
		if (stage.Dealer_Code__c != null)
			bb.Dealer_Code__c = stage.Dealer_Code__c;
		if (stage.Dealer_Name__c != null)
			bb.Dealer_Name__c = stage.Dealer_Name__c;
  	}
  	
	// Loop through results returned
  	private void collectErrors(Database.SaveResult[] dbResult, Integer row, Stage_SMM__c doneBuyback, List<Error_Log__c> errors, Map<ID, Stage_SMM__c> updateStageList) {  		
		// If the current row was not sucessful, handle the error.
		if (!dbResult[row].isSuccess()) {
			// Get the error for this row and add it to a list of Error_Log rows.
			Database.Error err = dbResult[row].getErrors()[0];
        	errors.add(new Error_Log__c(Record_ID__c = doneBuyback.Id,
               			Record_Type__c = 'Buyback__c', 
                        Error_Message__c = err.getMessage(), 
                        TimeStamp__c = System.now(), 
                        Operation_Name__c = 'Batch_Buyback_DataLoad', 
                        Source__c='Salesforce', 
                        Log_Type__c = 'Error', 
                       	Log_Level__c = 1));
            
            doneBuyback.Successful__c = 'N';
            doneBuyback.Error_Message__c = 'Failed to update row in Buyback__c: ' + err.getMessage();
            updateStageList.put(doneBuyback.Id, doneBuyback);
		} else {
			// If the current row was successful, set Successful__c to 'Y'.
			doneBuyback.Successful__c = 'Y';
			doneBuyback.Error_Message__c = '';
			updateStageList.put(doneBuyback.Id, doneBuyback);
		}
  	}
  	
    global void finish(Database.BatchableContext BC){
    }
}