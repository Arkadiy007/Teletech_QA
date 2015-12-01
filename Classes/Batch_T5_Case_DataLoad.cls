/**********************************************************************
Name: Batch_T5_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads T5 specific Stage_Case table data into Case table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 12/13/2011 Created
1.1 - Matt Starr 03/07/2014 All T5 Cases will now route to T5 queue
***********************************************************************/
global class Batch_T5_Case_DataLoad implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = 'Successful__c != \'Y\' AND Origination_Type__c = \'T5\' AND Origination_Source__c = \'SFDC Stage\' ';
        if (Test.isRunningTest()) {
            WClause = WClause + 'AND First_Name__c = \'ZYXABC\'';
        }
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_Case__c', WClause); 
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Stage_Case__c> lstCaseStagingTable) {
        Case newCase;
        List<Case> lstCaseInsert = new List<Case>();       
        List<Stage_Case__c> lstCaseStageProc = new List<Stage_Case__c>();
        Map<Integer, Stage_Case__c> CaseStagingInsMap = new Map<Integer, Stage_Case__c>();
        integer ins=0;
        RecordType t5RecordType = [select id from recordtype where name = 'T5' and sobjecttype = 'Case'];
        CaseComment comment;
        List<CaseComment> commentList = new List<CaseComment>();
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Vehicle__c vehicle;
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<String> customerIds = new List<String>();
        Map<String, Account> customerIdMap = new Map<String, Account>();
        List<String> dealerCodes = new List<String>();
        Map<String, Account> dealerCodeMap = new Map<String, Account>();
        Map<String,Stage_Case__c> contactIdStageMap = new Map<String,Stage_Case__c>();
        Map<String,Case> contactIdCaseMap = new Map<String,Case>();
        List<Account> accountsInsert = new List<Account>();
        List<Id> accountIdsInserted = new List<Id>();
        List<Account> accountsInserted = new List<Account>();

        // Add to list of customer Ids to get Contact and Account Salesforce Ids
        // and Add to list of dealer codes to get Dealer Account Salesforce Ids
        for (Stage_Case__c stage: lstCaseStagingTable) { 
            customerIds.add(stage.Contact_ID__c);
            dealerCodes.add(stage.Dealer_Number__c);
        }

        // Get a List of Account records for the customer ids received.
        List<Account> accts = [select Id, PersonContactId, Customer_Id__c from Account where customer_id__c in :customerIds];
        
        // Construct a Map of Customer_Id__c to Account records
        for (Account acct: accts) {
        	customerIdMap.put(acct.Customer_Id__c, acct);
        }

        // Get a List of Dealer Account records for the dealer numbers received.
        List<Account> dealers = [select Id, Dealer_Code__c, RCAS__c from Account where Dealer_Code__c in :dealerCodes];
        
        // Construct a Map of Dealer_Code__c to Dealer Account records
        for (Account dealer: dealers) {
        	dealerCodeMap.put(dealer.Dealer_Code__c, dealer);
        }
        
        for (Stage_Case__c stage : lstCaseStagingTable)
        {
            try {
                newCase = new Case();       
                if (stage.SFDC_Action_Code__c == 'A')
                {
                    newcase.OwnerId = '00GF0000003fuPd'; //1.1 routing to T5 queue
                    newCase.Contact_Id__c = stage.Contact_ID__c;
                    newCase.CDIID__c = stage.CDIID__c;
                    newCase.Sequence_Number__c = stage.Sequence_Number__c;
                    newCase.Record_Suffix__c = stage.Record_Suffix__c;
                    newCase.Date_Sent__c = stage.Date_Sent_Text__c == null ? null : Text_Util.CCYYMMDDNoDashesToDate(stage.Date_Sent_Text__c);
                    newCase.Dealer_Number__c = stage.Dealer_Number__c;
                    newCase.VIN__c = stage.VIN__c;
                    newCase.Trans_Type__c = stage.Trans_Type__c;
                    newCase.Survey_Type__c = stage.Survey_Type__c;
                    newCase.First_Name__c = stage.First_Name__c;
                    newCase.Middle_Initial__c = stage.Middle_Initial__c;
                    newCase.Last_Name__c = stage.Last_Name__c;
                    newCase.Mailing_Street__c = stage.Street__c;
                    newCase.Mailing_Street_2__c = stage.Street2__c;
                    newCase.Mailing_City__c = stage.City__c;
                    newCase.Mailing_State__c = stage.State__c;
                    newCase.Mailing_Zip_Code__c = stage.ZIP__c;
                    newCase.Home_Phone__c = stage.EveningPhone__c;
                    newCase.Work_Phone__c = stage.DayPhone__c;
                    newCase.RecordTypeId = t5RecordType.Id;
                    if (stage.Dealer_Forward_Indicator__c != null) {
                        newCase.Dealer_Forward_Indicator__c = Boolean.valueOf(stage.Dealer_Forward_Indicator__c);
                    }
                    
                    // Get Account from the map and set Accountid and ContactId on the new case if found
        			Account acct = customerIdMap.get(stage.Contact_Id__c);
        			if (acct != null) {
        				newCase.AccountId = acct.Id;
        				newCase.ContactId = acct.PersonContactId;
        			} else {
        				// If no account was found, create one from the Case data and add it to a list to insert.
        				acct = new Account();
        				acct.Customer_Id__c = stage.Contact_Id__c;
        				acct.FirstName = stage.First_Name__c;
        				acct.MiddleName__c = stage.Middle_Initial__c;
        				acct.LastName = stage.Last_Name__c;
        				acct.PersonMailingStreet = stage.Street__c + ' ' + stage.Street2__c;
        				acct.PersonMailingCity = stage.City__c;
        				acct.PersonMailingState = stage.State__c;
        				acct.PersonMailingPostalCode = stage.ZIP__c;
        				acct.PersonHomePhone = stage.EveningPhone__c;
        				acct.PersonOtherPhone = stage.DayPhone__c;
        				accountsInsert.add(acct);
        				contactIdStageMap.put(acct.Customer_Id__c, stage);
        				contactIdCaseMap.put(acct.Customer_Id__c, newCase);
        			}
        			
        			// Get Dealer from the map and set Servicing Dealer and Owner if present.
        			Account dealer = dealerCodeMap.get(stage.Dealer_Number__c);
        			
                    if (dealer != null)
        			{
        				newCase.Servicing_Dealer__c = dealer.Id;
                    }
                    /****Commenting out old code for routing to CA RCAS Queue****/
        				/*if (dealer.RCAS__c != null) {
        					newCase.OwnerId = dealer.RCAS__c;
        				} else {
        					// CA RCAS Queue
        					newCase.OwnerId = '00GF0000002IUHTMA4';
        				}
        			} else {
        				// CA RCAS Queue
        				newCase.OwnerId = '00GF0000002IUHTMA4';
        			}*/
                      
                    lstCaseInsert.add(newCase);
                    CaseStagingInsMap.put(ins,stage);
                    ins++;
                    
                    vehicle = getVehicle(stage);
                    vehicles.add(vehicle);
                 }
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = stage.Id,
                                    Record_Type__c = 'Stage_Case__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_T5_Case_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // Insert new accounts
        if (accountsInsert.size() > 0) {
            Database.SaveResult[] lstAcctIns = Database.insert(accountsInsert, false);

            if (lstAcctIns.size() > 0) {
                for (integer x = 0; x < lstAcctIns.size(); x++) {
                    if (!lstAcctIns[x].isSuccess()) {
                        Database.Error err = lstAcctIns[x].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = contactIdStageMap.get(accountsInsert[x].Customer_Id__c).Id,
                                    Record_Type__c = 'Stage_Case__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_T5_Case_DataLoad.Accounts', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
						// Add the Account to a List to query to get Contact Id as well
						accountIdsInserted.add(lstAcctIns[x].getId());
                    } 
                }
            }
        }
        
        // Query to get Contact Id for Accounts Inserted
        accountsInserted = [select Id, PersonContactId, Customer_Id__c from Account where Id in :accountIdsInserted];

    	// Add the newly created Account Id to the associated Case
    	for (Account acct: accountsInserted) {
        	Case c = contactIdCaseMap.get(acct.Customer_Id__c);
        	if (c != null) {
        		c.AccountId = acct.Id;
        		c.ContactId = acct.PersonContactId;
        	}
    	}
        
        // Create new Vehicle__c objects for any Vehicles in the list that do not already exist.  These will
        // then be linked automatically to the Cases when they are inserted.
        Text_Util.linkVehiclesByVIN(vehicles, errors);
      
        // Insert Cases
        if (lstCaseInsert.size() > 0) {
            Stage_Case__c CStageIns; 
        
            Database.SaveResult[] lstCSIns = Database.insert(lstCaseInsert, false);

            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < lstCaseInsert.size(); x++) {
                    CStageIns = CaseStagingInsMap.get(x);
                    if (lstCSIns[x].isSuccess()) {
                        CStageIns.Successful__c = 'Y';
                        comment = new CaseComment();
                        comment.ParentId = lstCSIns[x].getId();
                        comment.CommentBody = CStageIns.Comment_Text__c;
                        commentList.add(comment);
                    } else {           
                        CStageIns.Successful__c = 'N';
                        Database.Error err = lstCSIns[x].getErrors()[0];
                        CStageIns.Error_Message__c = err.getMessage();                               
                    } 
                    lstCaseStageProc.add(CStageIns);      
                }
            }
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
                                    Operation_Name__c = 'Batch_T5_Case_DataLoad.Comments', 
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
                                    Record_Type__c = 'Stage_Case__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_T5_Case_DataLoad.Update_StageCases', 
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

    private Vehicle__c getVehicle(Stage_Case__c stage) {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = stage.VIN__c;
        
        return vehicle;
    }

    global void finish(Database.BatchableContext BC){
    }
}