/*
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Merge data in Vehicle_Retail_Sale_Stage__c with Vehicle_Retail_Sale__c. This batch must be run after Batch_VRS_DataLoadCleanUp
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 06/02/2011 Created
***********************************************************************/
global class Batch_VRS_DataLoadDedup implements Database.Batchable<sObject> {
    static final Integer VEHICLE_NOT_FOUND = 1;
    static final Integer OWNER_NOT_FOUND = 2;
    static final Integer MATCHED = 0;
    
    global String query = 'Select Survey_Verbatim__c, ' +
                            'Survey_System_ID__c, ' +
                            'Survey_Return_Type__c, ' +
                            'Survey_Last_Name__c, ' +
                            'Survey_ID__c, ' +
                            'Survey_First_Name__c, ' +
                            'Survey_Date__c, ' +
                            'Spare3__c, ' +
                            'Spare2__c, ' +
                            'Spare1__c, ' +
                            'Sentiment_Band_Row__c, ' +
                            'Satisfied_with_Sales_Experience__c, ' +
                            'Satisfaction__c, ' +
                            'Name, ' +
                            'Internal_Ferret_Id__c, ' +
                            'Id, ' +
                            'Follow_Up_Status__c, ' +
                            'Follow_Up_Reason__c, ' +
                            'Follow_Up_Call__c, ' +
                            'FF_Score__c, ' +
                            'External_Vehicle_Identification_Number__c, ' +
                            'Excellent_Overall_Experience__c, ' +
                            'Dealer_Follow_Up_Status__c, ' +
                            'Customer_Phone__c, ' +
                            'Customer_Email__c, ' +
                            'Customer_Disposition__c, ' +
                            'Action_Plan__c ' +
                        'From Vehicle_Retail_Sale_Stage__c ' + 
                        'WHERE External_Vehicle_Identification_Number__c <> NULL and ' + 
                            'Survey_Last_Name__c <> NULL ' + 
                        'Order by LastModifiedDate desc';

    //collect the Vehicle_Retail_Sale_Stage__c records to be passed to the interface method execute
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    //retrive corresponding Vehicle_Retail_Sale__c records by input Vehicle_Retail_Sale_Stage__c records, then merge.
    global void execute(Database.BatchableContext BC, List<Vehicle_Retail_Sale_Stage__c> lstVRSS) {
        //pairs of stage entry and its merging status. Integer: 0 Vehicle not found, 1: Vehicle found, but Owner not found, 0 matched
        Map<ID, Integer> mapVRSS_Status = new Map<ID, Integer>();

        //group the input list of Vehicle_Retail_Sale_Stage__c by External_Vehicle_Identification_Number__c;
        Map<String, List<Vehicle_Retail_Sale_Stage__c>> mapExternalVINs = new Map<String, List<Vehicle_Retail_Sale_Stage__c>>();
        for (Vehicle_Retail_Sale_Stage__c stage : lstVRSS) {
            mapVRSS_Status.put(stage.ID, VEHICLE_NOT_FOUND);

            List<Vehicle_Retail_Sale_Stage__c> lstStage;
            if (mapExternalVINs.containsKey(stage.External_Vehicle_Identification_Number__c))
                lstStage = mapExternalVINs.get(stage.External_Vehicle_Identification_Number__c);
            else {
                lstStage = new List<Vehicle_Retail_Sale_Stage__c>();
                mapExternalVINs.put(stage.External_Vehicle_Identification_Number__c, lstStage);
            }
            lstStage.add(stage);
        }
        
        //after successful merge, records in Vehicle_Retail_Sale_Stage__c should be deleted. 
        //mapVRSSToPurge: pairs VRS records with VRS Stage records
        Map<ID, Vehicle_Retail_Sale_Stage__c> mapVRSSToPurge = new Map<ID, Vehicle_Retail_Sale_Stage__c>();

        //retrieve VRS by the input External VINs from above into lstVRStoUpdate.
        List<Vehicle_Retail_Sale__c> lstVRStoUpdate = new List<Vehicle_Retail_Sale__c>();
        for (Vehicle_Retail_Sale__c v : [Select v.Owner_Id__r.LastName, v.Id, v.External_Vehicle_Identification_Number__c
                                        From Vehicle_Retail_Sale__c v
                                        Where External_Vehicle_Identification_Number__c IN :mapExternalVINs.keySet() and 
                                            CreatedDate >= Last_n_Days:90]) {
            List<Vehicle_Retail_Sale_Stage__c> stages = mapExternalVINs.get(v.External_Vehicle_Identification_Number__c);
            Account owner = v.Owner_Id__r;

            for (Vehicle_Retail_Sale_Stage__c stage : stages) {
                mapVRSS_Status.put(stage.ID, OWNER_NOT_FOUND);

                //match VRS records with VRS Stage records by Owner Last Name
                if (owner != null && owner.LastName.equalsIgnoreCase(stage.Survey_Last_Name__c)) {
                    //the following checking is targeted at the situation when there are 2 rows in stage table with same vin and owner last name
                    if (!mapVRSSToPurge.containsKey(v.ID)) {
                        mapVRSSToPurge.put(v.ID, stage);

                        mapVRSS_Status.put(stage.ID, MATCHED);

                        if (stage.Survey_Verbatim__c <> NULL)
                            v.Survey_Verbatim__c = stage.Survey_Verbatim__c;
                        if (stage.Survey_System_ID__c <> NULL)
                            v.Survey_System_ID__c = stage.Survey_System_ID__c;
                        if (stage.Survey_Return_Type__c <> NULL)
                            v.Survey_Return_Type__c = stage.Survey_Return_Type__c;
                        if (stage.Survey_ID__c <> NULL)
                            v.Survey_ID__c = stage.Survey_ID__c;
                        if (stage.Survey_First_Name__c <> NULL)
                            v.Survey_First_Name__c = stage.Survey_First_Name__c;
                        if (stage.Survey_Last_Name__c <> NULL)
                            v.Survey_Last_Name__c = stage.Survey_Last_Name__c;
                        if (stage.Survey_Date__c <> NULL)
                            v.Survey_Date__c = stage.Survey_Date__c;
                        if (stage.Spare3__c <> NULL)
                            v.Spare3__c = stage.Spare3__c;
                        if (stage.Spare2__c <> NULL)
                            v.Spare2__c = stage.Spare2__c;
                        if (stage.Spare1__c <> NULL)
                            v.Spare1__c = stage.Spare1__c;
                        if (stage.Sentiment_Band_Row__c <> NULL)
                            v.Sentiment_Band_Row__c = stage.Sentiment_Band_Row__c;
                        if (stage.Satisfied_with_Sales_Experience__c <> NULL)
                            v.Satisfied_with_Sales_Experience__c = stage.Satisfied_with_Sales_Experience__c;
                        if (stage.Satisfaction__c <> NULL)
                            v.Satisfaction__c = stage.Satisfaction__c;
                        if (stage.Internal_Ferret_Id__c <> NULL)
                            v.Internal_Ferret_Id__c = stage.Internal_Ferret_Id__c;
                        if (stage.Follow_Up_Status__c <> NULL)
                            v.Follow_Up_Status__c = stage.Follow_Up_Status__c;
                        if (stage.Follow_Up_Reason__c <> NULL)
                            v.Follow_Up_Reason__c = stage.Follow_Up_Reason__c;
                        if (stage.Follow_Up_Call__c <> NULL)
                            v.Follow_Up_Call__c = stage.Follow_Up_Call__c;
                        if (stage.FF_Score__c <> NULL)
                            v.FF_Score__c = stage.FF_Score__c;
                        if (stage.Excellent_Overall_Experience__c <> NULL)
                            v.Excellent_Overall_Experience__c = stage.Excellent_Overall_Experience__c;
                        if (stage.Dealer_Follow_Up_Status__c <> NULL)
                            v.Dealer_Follow_Up_Status__c = stage.Dealer_Follow_Up_Status__c;
                        if (stage.Customer_Phone__c <> NULL)
                            v.Customer_Phone__c = stage.Customer_Phone__c;
                        if (stage.Customer_Email__c <> NULL)
                            v.Customer_Email__c = stage.Customer_Email__c;
                        if (stage.Customer_Disposition__c <> NULL)
                            v.Customer_Disposition__c = stage.Customer_Disposition__c;
                        if (stage.Action_Plan__c <> NULL)
                            v.Action_Plan__c = stage.Action_Plan__c;

                        lstVRStoUpdate.add(v);
                    }
                }
            }
        }

        List<Error_Log__c> errors = new List<Error_Log__c>();
        for (ID t :mapVRSS_Status.keySet()) {
            if (mapVRSS_Status.get(t) == VEHICLE_NOT_FOUND) {   
                errors.add(new Error_Log__c(Record_ID__c = t, 
                                            Record_Type__c = 'Vehicle_Retail_Sale_Stage__c', 
                                            Error_Message__c = 'Matching Vehicle is not found', 
                                            TimeStamp__c = System.now(), 
                                            Operation_Name__c = 'Batch_VRS_DataLoadDedup', 
                                            Source__c='Salesforce', 
                                            Log_Type__c = 'Error', 
                                            Log_Level__c = 1)); 
            } else if (mapVRSS_Status.get(t) == OWNER_NOT_FOUND) {
                errors.add(new Error_Log__c(Record_ID__c = t, 
                                            Record_Type__c = 'Vehicle_Retail_Sale_Stage__c', 
                                            Error_Message__c = 'Matching Owner is not found', 
                                            TimeStamp__c = System.now(), 
                                            Operation_Name__c = 'Batch_VRS_DataLoadDedup', 
                                            Source__c='Salesforce', 
                                            Log_Type__c = 'Error', 
                                            Log_Level__c = 1)); 
            }
        }

        if (lstVRStoUpdate.size() > 0) {
            // The false parameter allows for partial processing if multiple records passed into the operation.
            Database.SaveResult[] lsr = Database.update(lstVRStoUpdate, false);
            Map<ID, Vehicle_Retail_Sale_Stage__c> stagesToPurge = new Map<ID, Vehicle_Retail_Sale_Stage__c>();
			
            // Process the save results
            for (Integer i = 0; i < lsr.size(); i++) {
                Database.SaveResult sr = lsr[i];
                Vehicle_Retail_Sale_Stage__c stage = mapVRSSToPurge.get(lstVRStoUpdate[i].ID);
				
                //for successfuly merged record, collect stage records to be purged. 
                if(sr.isSuccess()) {
                	if (!stagesToPurge.containsKey(stage.ID))
                    	stagesToPurge.put(stage.ID, stage);
                }
                
                //process error, add into error log
                else {
                    Database.Error err = sr.getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = stage.ID, 
                                                Record_Type__c = 'Vehicle_Retail_Sale_Stage__c', 
                                                Error_Message__c = err.getMessage(), 
                                                TimeStamp__c = System.now(), 
                                                Operation_Name__c = 'Batch_VRS_DataLoadDedup', 
                                                Source__c='Salesforce', 
                                                Log_Type__c = 'Error', 
                                                Log_Level__c = 1));
                }
            }
			
			try {
	            if (stagesToPurge.size() > 0) {
	            	delete stagesToPurge.values();
	            }
			} catch (Exception e){
                errors.add(new Error_Log__c(Record_Type__c = 'Vehicle_Retail_Sale_Stage__c', Error_Message__c = e.getMessage(), TimeStamp__c = System.now(), Operation_Name__c = 'Batch_VRS_DataLoadDedup', Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
			}
        }
		
        if (errors.size() > 0)
            insert errors;
    }

    global void finish(Database.BatchableContext BC){
    }
}