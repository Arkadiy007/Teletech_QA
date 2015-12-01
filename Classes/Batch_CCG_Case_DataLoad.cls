/**********************************************************************
Name: Batch_CCG_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CCG specific Stage_Case table data into Case table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 01/13/2011 Created
***********************************************************************/
//Batch_CCG_Case_DataLoad batchJob = new Batch_CCG_Case_DataLoad();
//Database.executeBatch(batchJob);
//delete [select ID from Case Where RecordType.Name = 'Roadside Assistance']; 
//delete [select ID from Stage_Case__c Where Origination_Source__c = 'CCG' and Origination_Type__c = 'CCG']; 
//List<Stage_Case__c> lst = [select ID, Successful__c from Stage_Case__c Where Origination_Type__c = 'CCG' and Origination_Source__c = 'CCG'];
//for (Stage_Case__c c : lst) {
//	c.Successful__c = null;
//}
//update lst;
global class Batch_CCG_Case_DataLoad implements Database.Batchable<sObject> {
    
    private static final String WClause = 'Successful__c != \'Y\' AND Origination_Type__c = \'' + System.label.Origination_Type_CCG + '\' AND Origination_Source__c = \'' + System.label.Origination_Type_CCG + '\' ';
    global String query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_Case__c', WClause);
 	
    global Database.QueryLocator start(Database.BatchableContext BC){	      
        return Database.getQueryLocator(query);
    } 
	
    global void execute(Database.BatchableContext BC, List<Stage_Case__c> lstCaseStagingTable) {   	
     	Case newCase;
    	List<Case> lstCaseInsert = new List<Case>(); 
    	List<Stage_Case__c> lstCaseStageProc = new List<Stage_Case__c>();
    	Map<Integer, Stage_Case__c> CaseStagingInsMap = new Map<Integer, Stage_Case__c>();
 		integer ins=0;
		RecordType caseCCGRT = [select id, name from recordtype where name = 'Roadside Assistance' and sobjecttype = 'Case' limit 1];
 		Map<String, Stage_Case__c> CaseNoToCaseStagingMap = new Map<String, Stage_Case__c>();
 		Map<String,CaseCategory_Dependency__c> categoryMap = getCategoryMap();
 		List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
 		
    	for (Stage_Case__c stage : lstCaseStagingTable) {		 
    		newCase = new Case();   		
    		if (stage.SFDC_Action_Code__c == System.label.Stage_Action_Add) {
    			newCase.Stage_Status__c = System.label.Stage_Status_Done;
    			newCase.Origin = 'Data Load';
				newCase.RecordTypeId = caseCCGRT.ID;
				newCase.Mailing_City__c = stage.City__c; 			
				newCase.Legacy_Case_Number__c = stage.DocumentID__c;
				newCase.First_Name__c = stage.First_Name__c;
				newCase.Last_Name__c = stage.Last_Name__c;
				newCase.Current_Mileage__c = stage.Mileage__c == null ? null : Integer.valueOf(stage.Mileage__c);
				newCase.Mailing_State__c = stage.State__c;
				newCase.Mailing_Street__c = stage.Street__c;
				newCase.VIN__c = stage.VIN__c;
				newCase.Mailing_Zip_Code__c = stage.Zip__c;
				newCase.Client_Dealer_ID__c = stage.Client_Dealer_ID__c;
				//newCase.Bill_Group__c = stage.Bill_Group__c;
				newCase.Task_ID__c = stage.Task_ID__c;
				newCase.Caller_Reference_No__c = stage.Caller_Reference_No__c;
				newCase.Task_Created_Date__c = stage.Task_Created_Date__c;
				newCase.Status = 'Closed'; //stage.Case_Status__c;
				newCase.Service_Provided__c = stage.Service_Provided__c;
				newCase.Disablement_Reason__c = stage.Disablement_Reason__c;
				newCase.Service_Provider_ID__c = stage.Service_Provider_ID__c;
				newCase.Service_Provider_Name__c = stage.Service_Provider_Name__c;
				newCase.Service_Provider_ETA__c = stage.Service_Provider_ETA__c == null ? null : Integer.valueOf(stage.Service_Provider_ETA__c);
				newCase.Tow_Mileage__c = stage.Tow_Mileage__c == null ? null : Integer.valueOf(stage.Tow_Mileage__c);
				newCase.Destination_Type__c = stage.Destination_Type__c;
				newCase.Tow_To_Address_Name__c = stage.Tow_To_Address_Name__c;
				newCase.Tow_To_Address__c = stage.Tow_To_Address__c;
				newCase.Tow_To_City__c = stage.Tow_To_City__c;
				newCase.Tow_To_State__c = stage.Tow_To_State__c;
				newCase.Tow_To_Zip__c = stage.Tow_To_Zip__c;
				newCase.Dealer_Name__c = stage.Dealer_Name__c;
				newCase.OwnerId = System.Label.Batch_Record_Owner;
				
				lstCaseInsert.add(newCase); 
				CaseStagingInsMap.put(ins,stage); 	
				ins++;
    		}  
    	}
    	
		//Insert Cases
    	if (lstCaseInsert.size() > 0) {
    		Stage_Case__c CStageIns; 
    		
    		Database.SaveResult[] lstCSIns = Database.insert(lstCaseInsert, false);
			
    		if (lstCSIns.size() > 0) {
    			for (integer x = 0; x < lstCaseInsert.size(); x++) {
    				CStageIns = CaseStagingInsMap.get(x);
    				if (lstCSIns[x].isSuccess()) {
    					CStageIns.Successful__c = 'Y';
    					if (CStageIns.Disablement_Reason__c != null)
    						caseCats.add(createCaseCat(lstCSIns[x].Id, categoryMap.get(CStageIns.Disablement_Reason__c)));
    				} else {
    					CStageIns.Successful__c = 'N';
    					Database.Error err = lstCSIns[x].getErrors()[0];
                    	CStageIns.Error_Message__c = err.getMessage();													
    				}
    				lstCaseStageProc.add(CStageIns);
    			}
    		}
    	}
    	
		//Insert Case Categorizations
    	if (caseCats.size() > 0) {    		
    		Database.SaveResult[] lstCCIns = Database.insert(caseCats, false);
    	}    	
    	
		Database.SaveResult[] dbResult = Database.update(lstCaseStageProc, false); 
  	}
  	
  	private Map<String,CaseCategory_Dependency__c> getCategoryMap() {
  		Map<String,CaseCategory_Dependency__c> categoryMap = new Map<String,CaseCategory_Dependency__c>();
  		
  		// Get codes to convert CCG Disablement reasons to CaseCategory_Dependency Ids
  		List<Code__c> categorizationCodes = [select code__c, description__c from Code__c where type__c = 'CCG_Disablement'];
  		List<String> dependencyIds = new List<String>();
  		
  		// Get List of CaseCategory_Dependency Ids
  		for (Code__c code: categorizationCodes) {
  			dependencyIds.add(code.Code__c);
  		}
  		
  		// Get Map of CaseCategory_Dependency Ids to CaseCategory_Dependency objects
  		Map<Id, CaseCategory_Dependency__c> dependencies =
  			new Map<Id,CaseCategory_Dependency__c>(
	  			[select Concern_Code__c, Concern__c, 
	  			        Category_Code__c, Category__c, 
	  			        Subcategory_Code__c, Subcategory__c, 
	  			        Symptom_Code__c, Symptom__c 
	  			 from CaseCategory_Dependency__c
	  			 where Id in :dependencyIds]);
  		
  		// Link Ids from Codes to Ids in CaseCategory_Dependency Map to construct Map from
  		// CCG Disablement reasons to CaseCategory_Dependency data.
  		for (Code__c code: categorizationCodes) {
  			categoryMap.put(code.Description__c, dependencies.get(code.Code__c));
  		}

  		return categoryMap;
  	}
  	
  	private Case_Categorization__c createCaseCat(Id caseId, CaseCategory_Dependency__c dependency) {
  		Case_Categorization__c caseCat = new Case_Categorization__c();
  		caseCat.Case__c = caseId;
  		caseCat.Concern__c = dependency.Concern__c;
  		caseCat.Concern_Code__c = dependency.Concern_Code__c;
  		caseCat.Category__c = dependency.Category__c;
  		caseCat.Category_Code__c = dependency.Category_Code__c;
  		caseCat.Subcategory__c = dependency.Subcategory__c;
  		caseCat.Subcategory_Code__c = dependency.Subcategory_Code__c;
  		caseCat.Symptom__c = dependency.Symptom__c;
  		caseCat.Symptom_Code__c = dependency.Symptom_Code__c;
  		caseCat.Stage_Status__c = System.Label.Stage_Status_Add;
  		
  		return caseCat;
  	}

    global void finish(Database.BatchableContext BC){
    }
}