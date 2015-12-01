/**********************************************************************
Name: Batch_Techline_New_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Techline onetimedata into the  Case table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 12/18/2013 Created
***********************************************************************/
global class Batch_Techline_New_Case_DataLoad implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = '';
        if (Test.isRunningTest()) {

        } else {
            // Production Id's
            WClause = WClause + ' Successful__c=\'N\'  ';  
        }
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('OneTimeTechlineLoad__c', WClause); 
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<OneTimeTechlineLoad__c> lstCaseStagingTable) {
        Case newCase;
        List<Case> lstCaseInsert = new List<Case>();       
        List<OneTimeTechlineLoad__c> lstCaseStageProc = new List<OneTimeTechlineLoad__c>();
        Map<Integer, OneTimeTechlineLoad__c> CaseStagingInsMap = new Map<Integer, OneTimeTechlineLoad__c>();
        integer ins=0;
        Id techLineRecordTypeId = [select id from recordtype where name = 'TECH LINE Cases' and sobjecttype = 'Case' Limit 1].Id;
        
       List<User> userTSSList = [select Id, TSS_Code__c FROM User];
       Map<String,String> userTSSMap = new Map<String,String>();
        for(User thisuserTSS:  userTSSList) {
            userTSSMap.put(thisuserTSS.TSS_Code__c, thisuserTSS.Id);
        }

        CaseComment comment;
        List<CaseComment> commentList = new List<CaseComment>();
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Vehicle__c vehicle;
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<String> customerIds = new List<String>();
        Map<String, Account> customerIdMap = new Map<String, Account>();
        List<String> dealerCodes = new List<String>();
        Map<String, Account> dealerCodeMap = new Map<String, Account>();
        Map<String,OneTimeTechlineLoad__c> contactIdStageMap = new Map<String,OneTimeTechlineLoad__c>();
        Map<String,Case> contactIdCaseMap = new Map<String,Case>();
        List<Account> accountsInsert = new List<Account>();
        List<Id> accountIdsInserted = new List<Id>();
        List<Account> accountsInserted = new List<Account>();
        
        
        // Add to list of customer Ids to get Contact and Account Salesforce Ids
        // and Add to list of dealer codes to get Dealer Account Salesforce Ids
        for (OneTimeTechlineLoad__c stage: lstCaseStagingTable) { 
            customerIds.add(stage.STC_CODE_1__c);
            dealerCodes.add(stage.DEALER_NUMBER__c);
        }


        // Get a List of Dealer Account records for the dealer numbers received.***
        List<Account> dealers = [select Id, Region_Code__c, Dealer_Code__c, RCAS__c, DTS_A_Stage_User__r.Cell_Phone__c, DTS_A_Stage_User__r.Full_Name__c,DTS_A_Stage_User__r.Email__c,DTS_A_Stage_User__r.Office_Phone__c from Account where Dealer_Code__c in :dealerCodes];
        
        // Construct a Map of Dealer_Code__c to Dealer Account records
        for (Account dealer: dealers) {
          dealerCodeMap.put(dealer.Dealer_Code__c, dealer);
        }
        
        for (OneTimeTechlineLoad__c stage : lstCaseStagingTable)
        {
            try {
            
            vehicle = getVehicle(stage);
                   
                
                newCase = new Case(); 
                newCase.Bonus_Cash_Code__c='99';      
                newCase.CreatedDate = dateTimeParse(stage.OPEN_DATECYMD__c);
                newCase.LastModifiedDate = dateTimeParse(stage.UPDATE_DATECYMD__c);
                newCase.RecordTypeId =techLineRecordTypeId;
                newCase.Case_External_ID__c = stage.INCIDENT_RECORD_NUMBER__c;
                newCase.Customer_Name__c = stage.CONSUMER_NAME__c;
                newCase.Caller_Name__c = stage.CALLER_NAME__c;
                if (stage.PHONE_NUMBER__c.length() >= 10) {
                    newCase.Phone_Number__c = stage.PHONE_NUMBER__c.left(10);
                } else {
                    newCase.Phone_Number__c = stage.PHONE_NUMBER__c;
                }
                newCase.Dealer_Number__c = stage.DEALER_NUMBER__c;
                newCase.Component_Code_Issue__c = stage.COMPONENT__c;
                newCase.Symptom_Code_Issue__c = stage.SYMPTOM_CODES__c;
                // this should be the id of the vehicle 
                newCase.Legacy_Owner_Id__c = stage.STC_CODE_1__c;
                newCase.VIN__c = stage.VIN__c;

                newCase.Vehicle_Mileage_Prior_Value__c = stage.VEHICLE_MILEAGE__c != null ? Decimal.valueOf(stage.VEHICLE_MILEAGE__c) : null;
                newCase.Current_Mileage__c = stage.VEHICLE_MILEAGE_ORIG__c != null ? Decimal.valueOf(stage.VEHICLE_MILEAGE_ORIG__c) : null;
                
                newCase.Distributor_Code__c = stage.DISTRIBUTOR__c;
                if (stage.IN_SERVICE_DATEYMD__c != null) {
                    newCase.In_Service_Date__c = dateParse(stage.IN_SERVICE_DATEYMD__c.trim());
                }
                
                newCase.ClosedDate = datetimeParse(stage.CLOSE_DATEYMD__c.trim());
               
                newCase.Solution_Rating__c = stage.SOLUTION_RATING__c;
                newCase.AssignmentLevel__c = stage.ASSIGNMENT_LEVEL__c;
                newCase.Critical_Status_Flag__c = stage.CRITICAL_STATUS_FLAG__c != null ? Text_Util.BooleanLookup(stage.CRITICAL_STATUS_FLAG__c,false) : false;
                newCase.Solution_Description__c = stage.SOLUTION_DESCRIPTION__c;
                newCase.Report_Type__c = stage.LOCATION_CODE__c;
                newCase.Issue_Type__c = stage.LOCATION_CODE__c;
                if (stage.RESPONSE_DATEYMD__c != null) {
                    newCase.Response_Date__c = dateParse(stage.RESPONSE_DATEYMD__c.trim());
                }
                newCase.Project_Number__c = stage.PROJECT_NUMBER__c;
                if (stage.INCIDENT_DATEYMD__c != null) {
                    newCase.Incident_Date__c = dateParse(stage.INCIDENT_DATEYMD__c.trim());
                }
                newCase.Engine_Number__c = stage.ENGINE_NUMBER__c;
                if (stage.REGION_CODE__c != null) {
                    newCase.Region_Code__c = Decimal.valueOf(stage.REGION_CODE__c);
                }
               /* //newCase.Parts_Avail__c = stage.PARTS_AVAILABLE__c != null ? Text_Util.BooleanLookup(stage.PARTS_AVAILABLE__c,false) : false;
                if (stage.PARTS_REQUEST_DATEYMD__c != null) 
                    //newCase.Parts_Request_Date__c = dateParse(stage.PARTS_REQUEST_DATEYMD__c.trim());
                
                //newCase.Parts_Requestor__c = stage.PARTS_FOR_WHOM__c;
                if (stage.PARTS_RECEIVED_DATEYMD__c != null) 
                    //newCase.Parts_Received_Date__c = dateParse(stage.PARTS_RECEIVED_DATEYMD__c.trim());
                if (stage.PARTS_SHIPPED_DATEYMD__c != null)
                //newCase.Parts_Shipped_Date__c = dateParse(stage.PARTS_SHIPPED_DATEYMD__c.trim());*/
                newCase.Revision_Number__c = stage.REVISION_NUMBER__c != null ? Decimal.valueOf(stage.REVISION_NUMBER__c) : null;
                newCase.Dealer_Could_Benefit_By__c = stage.DEALER_BENEFIT_BY__c;
                newCase.Incident_Category__c = stage.INCIDENT_CATEGORY__c;
                newCase.Operating_Mode__c = stage.OPERATING_MODE__c;
                newCase.Operating_Temperature__c = stage.OPERATING_TEMPERATURE__c;
                newCase.Ambient_Temperature__c = stage.AMBIENT_TEMPERATURE__c;
                newCase.Ambient_Humidity__c = stage.AMBIENT_HUMIDITY__c;
                newCase.Frequency_of_Problem__c = stage.FREQUENCY_OF_PROBLEM__c;
                newCase.Product_Alert_Number__c = stage.PRODUCT_ALERT_NUMBER__c;
                newCase.Description = stage.DESCRIPTION__c;
                newCase.Subject = stage.DESCRIPTION__c;
                
                newCase.TREAD_Component__c = stage.TREAD_Component__c;
                newCase.TREAD_Component_Prior_Value__c = stage.TREAD_COMPONENT_OLD__c;
                newCase.TREAD_Effective_Date__c = stage.TREAD_EFF_DATE__c != null ? dateParse(stage.TREAD_EFF_DATE__c) : null;
                newCase.Reason_For_Call__c = stage.REASON_FOR_CALL__c;
                newCase.FFFS__c = Text_Util.BooleanLookup(stage.SMOKE_FLAG__c,false);
                newCase.FFFS_Date__c = dateParse(stage.SMOKE_FLAG_EFF_DATE__c);
                newCase.Field_Inspection_Indicator__c = stage.NNA_FIELD_INSPECTION__c != null ? Text_Util.BooleanLookup(stage.NNA_FIELD_INSPECTION__c.trim(),false) : false;
                newCase.Recommendation_Rating__c = stage.Recommedation_Rating__c;
                newCase.NNA_Field_Inspection_Date__c = stage.NNA_INSPECTION_FLG_DT__c != null ? dateParse(stage.NNA_INSPECTION_FLG_DT__c) : null;

              Account dealer = dealerCodeMap.get(stage.DEALER_NUMBER__c);
              
              if (dealer != null) {
                  
                  newCase.Dealer__c = dealer.Id;
                  newCase.DTS_Name__c = dealer.DTS_A_Stage_User__r.Full_Name__c;
                  newCase.DTS_User_Cell_Phone__c = dealer.DTS_A_Stage_User__r.Cell_Phone__c;
                  newCase.DTS_User_Email__c = dealer.DTS_A_Stage_User__r.Email__c;
                  newCase.DTS_User_Office_Phone__c = dealer.DTS_A_Stage_User__r.Office_Phone__c;
                  newCase.DealerRegion_Code__c = dealer.Region_Code__c;
              }
              
             if (stage.STC_CODE_1__c != null && stage.STC_CODE_1__c.length() >= 3) {

                 if (userTSSMap.get(stage.STC_CODE_1__c.substring(0,3)) != null) {
                     newCase.OwnerId = userTSSMap.get(stage.STC_CODE_1__c.substring(0,3));
                 } else {
                     newCase.OwnerId ='005F00000020rv3';           // '00GZ0000001F0pY';
                 }   
             }

            vehicles.add(vehicle);
            lstCaseInsert.add(newCase);
            CaseStagingInsMap.put(ins,stage);
    
            ins++;
    
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = stage.Id,
                                    Record_Type__c = 'OneTimeTechlineLoad__c', 
                                    Error_Message__c = err.getMessage() + 'Line: ' + err.getLineNumber(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineNew_Dataload', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }

        // Create new Vehicle__c objects for any Vehicles in the list that do not already exist.  These will
        // then be linked automatically to the Cases when they are inserted.
        Text_Util.linkVehiclesByVIN(vehicles, errors);
      
        // Insert Cases
        if (lstCaseInsert.size() > 0) {
            
            
            OneTimeTechlineLoad__c CStageIns; 

            //Schema.SObjectField caseExternalIdField = Case.Fields.Case_External_Id__c;
            //Database.UpsertResult[] lstCSIns = Database.upsert(lstCaseInsert, caseExternalIdField , false);
            Database.SaveResult[] lstCSIns = Database.insert(lstCaseInsert, false);
            
            if (lstCSIns.size() > 0) {
                
                for (integer x = 0; x < lstCaseInsert.size(); x++) {
                    System.debug('Will Taylor - Case Id of insert:' + lstCSIns[x].getId());
                    CStageIns = CaseStagingInsMap.get(x);
                    if (lstCSIns[x].isSuccess()) {
                        CStageIns.Successful__c = 'Y';
                        
                       // String thiscmt = commentsMap.get(CStageIns.INCIDENT_RECORD_NUMBER__c);
                       // if (thiscmt != null) {
                            
                           // comment = new CaseComment();
                           // comment.ParentId = lstCSIns[x].getId();
                           // comment.CommentBody = thiscmt;
                           // commentList.add(comment);
                        
                       // }
                    } else {           
                        CStageIns.Successful__c = 'N';
                        Database.Error err = lstCSIns[x].getErrors()[0];
                        CStageIns.Error_Message__c = err.getMessage();                               
                    } 
                    lstCaseStageProc.add(CStageIns);      
                }
            }
        } else {
            
        }
        if (!commentList.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(commentList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < commentList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = commentList[row].ParentId,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineNew_Case_DataLoad.Comments', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        
        if (!lstCaseStageProc.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(lstCaseStageProc, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseStageProc.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = lstCaseStageProc[row].Id,
                                    Record_Type__c = 'OneTimeTechlineLoad__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineNew_Case_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }

    private Vehicle__c getVehicle(OneTimeTechlineLoad__c stage) {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = stage.VIN__c;
        return vehicle;
    }

    global void finish(Database.BatchableContext BC){
    
    
     // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information. 
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email, CompletedDate
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
          
        // Send an email to the Apex job's submitter notifying of job completion. 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'wrmtyr@gmail.com'};  //a.CreatedBy.Email
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Case DataLoad ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    
    
    }
    
   
    private Date dateParse(String inDate) {
        if (inDate == null || inDate.length() < 8) {
            return null;
        } else {
            String thisYear = inDate.substring(0,4);
            String thisMonth = inDate.substring(4,6);
            String thisDay = inDate.substring(6,8);
            return Date.parse(thisMonth  + '/' + thisDay  + '/' + thisYear  );
        }
    }
    
    private DateTime datetimeParse(String inDate) {
        if (inDate == null || inDate.length() < 8) {
            return null;
        } else {
            String thisYear = inDate.substring(0,4);
            String thisMonth = inDate.substring(4,6);
            String thisDay = inDate.substring(6,8);
            return DateTime.parse(thisMonth  + '/' + thisDay  + '/' + thisYear + ' 12:00 AM');
        }
    }
    
    
}