/**********************************************************************
Name: Batch_VCS_Alert_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Stage VCS Alert table data into Case table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 06/26/2013 Created
1.1 - Bryan Fry 09/19/2013 Changed record type handling to use custom label.
1.2 - Bryan Fry 10/15/2013 Only require IC and IPA subscription status.
1.3 - Bryan Fry 10/23/2013 Don't create case where customer name includes Nissan or Infiniti
1.4 - Bryan Fry 11/04/2013 Add TCU Activation Status handling
1.5 - Bryan Fry 11/15/2013 Change key from VIN+ContactId to VIN+TransactionMasterId
***********************************************************************/
global class Batch_VCS_Alert_Case_DataLoad implements Database.Batchable<sObject> {
    public static final String VCS_ALERT = 'VCSALERT';
    public static final String INFINITI_CONNECTION = 'Infiniti Connection';
    public static final String INFINITI_PERSONAL_ASSISTANT = 'Infiniti Personal Assistant';
    public static final String TELEMATICS_COMMUNICATION_UNIT = 'Telematics Communication Unit (TCU)';
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = 'Stage_Status__c = \'Process\'';

        String query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_VCS_Alert__c', WClause); 
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Stage_VCS_Alert__c> alerts) {
        Case newCase;
        List<Case> upsertCases = new List<Case>();
        List<Stage_VCS_Alert__c> lstCaseStageProc = new List<Stage_VCS_Alert__c>();
        Map<Integer, Stage_VCS_Alert__c> CaseStagingInsMap = new Map<Integer, Stage_VCS_Alert__c>();
        integer ins=0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Vehicle__c vehicle;
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<String> customerIds = new List<String>();
        Map<String, Account> customerIdMap = new Map<String, Account>();
        List<String> dealerExternalIds = new List<String>();
        Map<String, Account> dealerExternalIdMap = new Map<String, Account>();
        Map<String,Stage_VCS_Alert__c> contactIdStageMap = new Map<String,Stage_VCS_Alert__c>();
        Map<String,Case> contactIdCaseMap = new Map<String,Case>();
        Map<String,Case> rdrContactIdCaseMap = new Map<String,Case>();
        List<Account> accountsInsert = new List<Account>();
        List<Id> accountIdsInserted = new List<Id>();
        List<Account> accountsInserted = new List<Account>();
        List<Id> dealerIds = new List<Id>();
        List<String> caseExternalIds = new List<String>();
        List<Stage_VCS_Alert__c> validAlerts = new List<Stage_VCS_Alert__c>();
        Case openCase = null;
        Case closedCase = null;

        // Add to list of case external Ids to get existing Cases
        for (Stage_VCS_Alert__c stage: alerts) {
            if (stage.Contact_Id__c != null && stage.VIN__c != null && stage.Transaction_Master_Id__c != null) {
                caseExternalIds.add(createExternalId(stage));
            }
        }
        
        // Each Transaction Master Id/VIN combination can have only one VCS Alert case, identified by an external Id
        // including 'VCSALERT', the transaction master Id, and the VIN.  If a VCS Alert case exists for the Transaction
        // Master Id and VIN for a record and that record is closed, no action should be taken for the row.  Closed
        // cases cannot be updated through the batch load unless their TCU Activation Status changes to 0.
        List<Case> closedCases = [select id, case_external_id__c, status 
                                  from case 
                                  where case_external_id__c in :caseExternalIds 
                                  and status = 'Closed'];
        Map<String,Case> closedCaseMap = new Map<String,Case>();
        for (Case c: closedCases) {
            closedCaseMap.put(c.Case_External_Id__c, c);
        }

        List<Case> openCases = [select id, case_external_id__c, status 
                                  from case 
                                  where case_external_id__c in :caseExternalIds 
                                  and status != 'Closed'];
        Map<String,Case> openCaseMap = new Map<String,Case>();
        for (Case c: openCases) {
            openCaseMap.put(c.Case_External_Id__c, c);
        }

        // Add to list of customer Ids to get Account Salesforce Ids
        // and Add to list of dealer external Ids to get Dealer Account Salesforce Ids
        // RDR Date must be greater than or equal to Oct 1, 2013.  Rows with RDR date before this
        // will be rejected.
        Date rdrDate;
        Date oct1 = Date.newInstance(2013,10,1);
        for (Stage_VCS_Alert__c stage: alerts) {
            rdrDate = Text_Util.MMDDYYToDate(stage.RDR_Date__c);
            if (stage.Contact_Id__c == null || stage.VIN__c == null || stage.Transaction_Master_Id__c == null) {
                stage.Error_Message__c = 'Contact Id, VIN, and Transaction Master Id are required.';
                stage.Stage_Status__c = 'Processed';
                lstCaseStageProc.add(stage);
            } else if (closedCaseMap.keySet().contains(createExternalId(stage)) && stage.TCU_Activation_Status__c == '1') {
                stage.Error_Message__c = 'Case Id ' + closedCaseMap.get(createExternalId(stage)).Id +
                                         ' exists for Transaction Master Id ' + stage.Transaction_Master_Id__c + ' and VIN ' + stage.VIN__c + 'and is closed.';
                stage.Stage_Status__c = 'Processed';
                lstCaseStageProc.add(stage);
            } else if (rdrDate.daysBetween(oct1) > 0) {
                stage.Error_Message__c = 'RDR Date must be after Sept 30, 2013. RDR Date Value passed in is "' + 
                                         stage.RDR_Date__c + '". Parsed date is "' + rdrDate + '".';
                stage.Stage_Status__c = 'Processed';
                lstCaseStageProc.add(stage);
            } else if ((stage.First_Name__c != null && (stage.First_Name__c.contains('Nissan') || stage.First_Name__c.contains('Infiniti'))) ||
                       (stage.Last_Name__c != null && (stage.Last_Name__c.contains('Infiniti') || stage.Last_Name__c.contains('Infiniti')))) {
                stage.Error_Message__c = 'Case will not be created for alert because customer name contains Nissan or Infiniti.';
                stage.Stage_Status__c = 'Processed';
                lstCaseStageProc.add(stage);
            } else if (stage.IC_Subscription_Status__c == '1' && stage.IPA_Subscription_Status__c == '1' &&
                       stage.TCU_Activation_Status__c == '1' && !openCaseMap.keySet().contains(createExternalId(stage))) {
                stage.Error_Message__c = 'Case will not be created for alert because all Subscriptions are activated.';
                stage.Stage_Status__c = 'Processed';
                lstCaseStageProc.add(stage);
            } else {
                customerIds.add(stage.Contact_Id__c);
                if (stage.RDR_Contact_Id__c != null) {
                    customerIds.add(stage.RDR_Contact_Id__c);
                }
                if (stage.Dealer_Code__c != null) {
                    dealerExternalIds.add(stage.Dealer_Code__c + System.Label.Dealer_USA);
                }
                validAlerts.add(stage);
            }
        }

        // Get a List of Account records for the customer ids received.
        List<Account> accts = [select Id, PersonContactId, Customer_Id__c from Account where customer_id__c in :customerIds];
        
        // Construct a Map of Customer_Id__c to Account records
        for (Account acct: accts) {
            customerIdMap.put(acct.Customer_Id__c, acct);
        }

        // Get a List of Dealer Account records for the dealer codes received.
        List<Account> dealers = [select Id, Dealer_Code__c, Dealer_External_Id__c, Sales_Manager__r.Email, Sales_Manager__c
                                 from Account 
                                 where Dealer_External_Id__c in :dealerExternalIds];
        
        // Construct a Map of Dealer_External_Id__c to Dealer Account records
        for (Account dealer: dealers) {
            dealerExternalIdMap.put(dealer.Dealer_External_Id__c, dealer);
            dealerIds.add(dealer.Id);
        }

        // Construct Case object from Stage row
        for (Stage_VCS_Alert__c stage : validAlerts)
        {
            closedCase = closedCaseMap.get(createExternalId(stage));
            try {
                newCase = new Case();
                newCase.Case_External_Id__c = createExternalId(stage);
                newCase.Contact_Id__c = stage.Contact_ID__c;
                newCase.First_Name__c = stage.First_Name__c;
                newCase.Middle_Initial__c = stage.Middle_Initial__c;
                newCase.Last_Name__c = stage.Last_Name__c;
                newCase.Mailing_Street__c = stage.Address1__c;
                newCase.Mailing_Street_2__c = stage.Address2__c;
                newCase.Mailing_City__c = stage.City__c;
                newCase.Mailing_State__c = stage.State__c;
                newCase.Mailing_Zip_Code__c = stage.ZIP_Code__c;
                newCase.Mailing_Zip_Plus4__c = stage.ZIP_4__c;
                newCase.Email2__c = Text_Util.toValidEmail(stage.Email_Address__c);
                newCase.Home_Phone__c = stage.Home_Phone__c;
                newCase.Work_Phone__c = stage.Work_Phone__c;
                newCase.Mobile_Phone__c = stage.Cell_Phone__c;
                newCase.VIN__c = stage.VIN__c;
                newCase.Channel_Designation_Code__c = stage.Make__c;
                newCase.Vehicle_Model__c = stage.Model__c;
                newcase.Vehicle_Year__c = stage.Model_Year__c;
                newCase.Description = 'First Name: ' + stage.First_Name__c + ', Middle Initial: ' + stage.Middle_Initial__c +
                                      ', Last Name: ' + stage.Last_Name__c + ', Address1: ' + stage.Address1__c +
                                      ', Address2: ' + stage.Address2__c + ', City: ' + stage.City__c +
                                      ', State: ' + stage.State__c + ', Zip Code: ' + stage.Zip_Code__c +
                                      ', Zip 4: ' + stage.Zip_4__c + ', Email Address: ' + stage.Email_Address__c +
                                      ', Home Phone: ' + stage.Home_Phone__c + ', Work Phone: ' + stage.Work_Phone__c +
                                      ', Cell Phone: ' + stage.Cell_Phone__c + ', RDR Date: ' + stage.RDR_Date__c;
                newCase.Purchase_Date__c = stage.Purchase_Date__c == null ? null : Text_Util.MMDDYYToDate(stage.Purchase_Date__c);
                newCase.Dealer_Number__c = stage.Dealer_Code__c;
                newCase.Subscription_Status__c = stage.Subscription_Status__c;
                newCase.Op_Subscription_Status__c = Text_Util.BooleanLookup(stage.Op_Subscription_Status__c, false);
                newCase.IC_Subscription_Status__c = Text_Util.BooleanLookup(stage.IC_Subscription_Status__c, false);
                newCase.TCU_Activation_Status__c = Text_Util.BooleanLookup(stage.TCU_Activation_Status__c, false);
                newCase.ITA_Subscription_Status__c = Text_Util.BooleanLookup(stage.ITA_Subscription_Status__c, false);
                newCase.IPA_Subscription_Status__c = Text_Util.BooleanLookup(stage.IPA_Subscription_Status__c, false);
                newCase.Transaction_Master_Id__c = stage.Transaction_Master_Id__c;
                newCase.Subject = createSubject(newCase);

                // VCS Alert Queue
                newCase.OwnerId = System.Label.VCS_Alert_Queue;
                newCase.RecordTypeId = System.Label.VCS_Alert_RecordType;

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
                    acct.PersonMailingStreet = stage.Address1__c + ' ' + stage.Address2__c;
                    acct.PersonMailingCity = stage.City__c;
                    acct.PersonMailingState = stage.State__c;
                    acct.PersonMailingPostalCode = stage.ZIP_Code__c;
                    acct.PersonEmail = Text_Util.toValidEmail(stage.Email_Address__c);
                    acct.PersonHomePhone = stage.Home_Phone__c;
                    acct.PersonOtherPhone = stage.Work_Phone__c;
                    acct.PersonMobilePhone = stage.Cell_Phone__c;
                    accountsInsert.add(acct);
                    contactIdStageMap.put(acct.Customer_Id__c, stage);
                    contactIdCaseMap.put(acct.Customer_Id__c, newCase);
                }

                if (stage.RDR_Contact_Id__c != null && stage.Contact_Id__c != stage.RDR_Contact_Id__c) {
                    acct = customerIdMap.get(stage.RDR_Contact_Id__c);
                    if (acct != null) {
                        newCase.RDR_Account__c = acct.Id;
                    } else {
                        // If no account was found, create one from the Case data and add it to a list to insert.
                        acct = new Account();
                        acct.Customer_Id__c = stage.RDR_Contact_Id__c;
                        acct.FirstName = stage.First_Name__c;
                        acct.MiddleName__c = stage.Middle_Initial__c;
                        acct.LastName = stage.Last_Name__c;
                        acct.PersonMailingStreet = stage.Address1__c + ' ' + stage.Address2__c;
                        acct.PersonMailingCity = stage.City__c;
                        acct.PersonMailingState = stage.State__c;
                        acct.PersonMailingPostalCode = stage.ZIP_Code__c;
                        acct.PersonEmail = Text_Util.toValidEmail(stage.Email_Address__c);
                        acct.PersonHomePhone = stage.Home_Phone__c;
                        acct.PersonOtherPhone = stage.Work_Phone__c;
                        acct.PersonMobilePhone = stage.Cell_Phone__c;
                        accountsInsert.add(acct);
                        contactIdStageMap.put(acct.Customer_Id__c, stage);
                        rdrContactIdCaseMap.put(acct.Customer_Id__c, newCase);
                    }
                }

                // Set dealer on new case if found
                Account dealer = dealerExternalIdMap.get(stage.Dealer_Code__c + System.Label.Dealer_USA);
                if (dealer != null) {
                    newCase.Servicing_Dealer__c = dealer.Id;
                }
                
                // If case is closed and TCU Activation Status is 0, reopen it.
                if (closedCase != null && stage.TCU_Activation_Status__c == '0') {
                  newCase.Status = 'Open';
                }

                upsertCases.add(newCase);
                CaseStagingInsMap.put(ins,stage);
                ins++;
                    
                vehicle = getVehicle(stage);
                vehicles.add(vehicle);
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = stage.Id,
                                    Record_Type__c = 'Stage_VCS_Alert__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_VCS_Alert_Case_DataLoad', 
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
                                    Record_Type__c = 'Stage_VCS_Alert__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_VCS_Alert_Case_DataLoad.Accounts', 
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

            c = rdrContactIdCaseMap.get(acct.Customer_Id__c);
            if (c != null) {
                c.RDR_Account__c = acct.Id;
            }
        }
        
        // Create new Vehicle__c objects for any Vehicles in the list that do not already exist.  These will
        // then be linked automatically to the Cases when they are upserted.
        Text_Util.linkVehiclesByVIN(vehicles, errors);

        // Upsert Cases
        if (upsertCases.size() > 0) {
            Stage_VCS_Alert__c CStageIns; 
        
            Database.UpsertResult[] lstCSIns = Database.upsert(upsertCases, Case.Fields.Case_External_Id__c, false);

            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < upsertCases.size(); x++) {
                    CStageIns = CaseStagingInsMap.get(x);
                    if (!lstCSIns[x].isSuccess()) {
                        Database.Error err = lstCSIns[x].getErrors()[0];
                        CStageIns.Error_Message__c = err.getMessage();
                    } else {
                        CStageIns.Stage_Status__c = 'Processed'; 
                        CStageIns.Error_Message__c = '';
                    }
                    lstCaseStageProc.add(CStageIns);      
                }
            }
        }

        // Get a List of Case Ids for the upserted cases
        List<Id> caseIds = new List<Id>();
        for (Case c: upsertCases) {
            caseIds.add(c.Id);
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
                                    Record_Type__c = 'Stage_VCS_Alert__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_VCS_Alert_Case_DataLoad.Update_StageCases', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
 
        // Get users to share Cases with
        List<User> shareUsers = [select Id, contact.AccountId, contact.Account.Dealer_External_Id__c, Profile.Name
                                 from user 
                                 where Profile.Name in ('Dealer Sales or Service Manager','Dealer Parts Manager',
                                                        'Infiniti Sales or Service Manager','Infiniti Parts Manager') 
                                 and profile.userlicense.name = 'Gold Partner' 
                                 and contact.accountid in :dealerIds
                                 and isactive = true];

        // Create Map of each dealer's portal users to share Case with
        Map<String,List<User>> dealerPortalUserMap = new Map<String,List<User>>();
        List<User> dealerPortalUsers;
        for (User u: shareUsers) {
            if (dealerPortalUserMap.containsKey(u.Contact.Account.Dealer_External_Id__c)) {
                dealerPortalUsers = dealerPortalUserMap.get(u.Contact.Account.Dealer_External_Id__c);
                dealerPortalUsers.add(u);
            } else {
                dealerPortalUsers = new List<User>();
                dealerPortalUsers.add(u);
                dealerPortalUserMap.put(u.Contact.Account.Dealer_External_Id__c, dealerPortalUsers);
            }
        }

        // Get list of existing Manual Case Shares for the Cases upserted
        List<CaseShare> caseShares = [Select Id, CaseId, UserOrGroupId
                                      From CaseShare
                                      Where RowCause = 'Manual' 
                                      And UserOrGroupId in (select Id from User where profile.userlicense.name = 'Gold Partner')
                                      And CaseId in :caseIds];
        Map<Id,List<CaseShare>> caseShareMap = new Map<Id,List<CaseShare>>();
        List<CaseShare> caseShareList = new List<CaseShare>();
        for (CaseShare cs: caseShares) {
            if (caseShareMap.containsKey(cs.CaseId)) {
                caseShareList = caseShareMap.get(cs.CaseId);
                caseShareList.add(cs);
            } else {
                caseShareList = new List<CaseShare>();
                caseShareList.add(cs);
                caseShareMap.put(cs.CaseId, caseShareList);
            }
        }

        // Go through list of existing Case Shares and compare with List of Users to share each case with to generate a List
        // of CaseShares that should be deleted.
        List<CaseShare> deleteCaseShares = new List<CaseShare>();
        Boolean found = false;
        for (Case c: upsertCases) {
            caseShareList = caseShareMap.get(c.Id);
            dealerPortalUsers = dealerPortalUserMap.get(c.Dealer_Number__c + System.Label.Dealer_USA);
            if (caseShareList != null) {
                for (CaseShare cs: caseShareList) {
                    found = false;
                    for (User u: dealerPortalUsers) {
                        if (cs.UserOrGroupId == u.Id) {
                            found = true;
                        }
                    }
                    if (found == false) {
                        deleteCaseShares.add(cs);
                    }
                }
            }
        }

        if (deleteCaseShares != null && !deleteCaseShares.isEmpty()) {
            delete deleteCaseShares;
        }

        // Share the Cases with the appropriate lists of Users
        List<CaseShare> insertShares = new List<CaseShare>();
        for (Case c: upsertCases) {
            dealerPortalUsers = dealerPortalUserMap.get(c.Dealer_Number__c + System.Label.Dealer_USA);
            if (dealerPortalUsers != null && !dealerPortalUsers.isEmpty()) {
                for (User u: dealerPortalUsers) {
                    CaseShare cs = new CaseShare();
                    cs.CaseId = c.Id;
                    cs.UserOrGroupId = u.Id;
                    cs.CaseAccessLevel = 'Edit';
                    insertShares.add(cs);
                }
            }
        }

        insert insertShares;

        // Get a List of upserted cases including the Case Number to update the case subject
        List<Case> upsertedCases = [select Id, CaseNumber, Subject, Dealer_Number__c, Make__c, VIN__c, First_Name__c,
                                           Last_Name__c, Transaction_Master_Id__c, TCU_Activation_Status__c,
                                           IPA_Subscription_Status__c, IC_Subscription_Status__c, Case_External_Id__c
                                    from Case 
                                    where Id in :caseIds];
        
        // Reset case subject to include the case number and update
        for (Case c: upsertedCases) {
            c.Subject = createSubject(c);
        }
        
        Database.update(upsertedCases);        

        // Send emails to Sales Managers where found
        String url = null;
        String emailAddress = null;
        Id salesManagerId = null;
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailMessage = null;
        String nissanInfiniti = null;
        Account dealer = null;
        String logMessage;

        for (Case c: upsertedCases) {
            dealer = dealerExternalIdMap.get(c.Dealer_Number__c + System.Label.Dealer_USA);
            if (dealer != null) {
                emailAddress = dealer.Sales_Manager__r.Email;
                salesManagerId = dealer.Sales_Manager__c;
            }
            if (dealer != null && emailAddress != null && salesManagerId != null && c.Id != null &&
                    ((!openCaseMap.keySet().contains(createExternalId(c)) && !closedCaseMap.keySet().contains(createExternalId(c)))
                      || (c.TCU_Activation_Status__c = false)
                    ))
            {
                emailMessage = new Messaging.SingleEmailMessage();
                nissanInfiniti = 'Nissan';
                if (c.Make__c != null && c.Make__c == 'Infiniti') {
                    nissanInfiniti = 'Infiniti';
                }
            
                emailMessage.setSenderDisplayName('Enrollment Alert');

                if (System.URL.getSalesforceBaseUrl().getHost().left(2).equalsIgnoreCase('cs')) {
                    if (nissanInfiniti == 'Infiniti') {
                        url = System.label.InfinitiRetailerPortalQA;
                    } else {
                        url = System.label.NissanDealerPortalQA;
                    }
                } else {
                    if (nissanInfiniti == 'Infiniti') {
                        url = System.label.InfinitiRetailerPortalProd;
                    } else {
                        url = System.label.NissanDealerPortalProd;
                    }
                }
                emailMessage.setTargetObjectId(salesManagerId);
                emailMessage.setSaveAsActivity(false);
                emailMessage.setReplyTo(System.Label.Support_Reply_To_Email);

                closedCase = closedCaseMap.get(createExternalId(c));
                openCase = openCaseMap.get(createExternalId(c));

                if (closedCase != null && c.TCU_Activation_Status__c == false) {
                    // Case reopened because of TCU email
                    emailMessage.setSubject('Enrollment Alert ' + c.Subject);
                    emailMessage.setPlainTextBody(getReopenEmailBody(c, url));
                } else if (openCase != null && c.TCU_Activation_Status__c == false && openCase.TCU_Activation_Status__c == true) {
                    // TCU set not active for open case email
                    emailMessage.setSubject('Enrollment Alert ' + c.Subject);
                    emailMessage.setPlainTextBody(getOpenEmailBody(c, url));
                } else {
                    // Case creation email
                    emailMessage.setSubject('Enrollment Alert ' + c.Subject);
                    emailMessage.setPlainTextBody(getCreationEmailBody(c, url));
                }
                emailMessages.add(emailMessage);

                logMessage = 'Sending email, ext id = ' + createExternalId(c) + ', dealer not null = ' + (dealer != null) +
                             ', emailAddress = ' + emailAddress +
                             ', salesManagerId = ' + salesManagerId + ', c.Id = ' + c.Id +
                             ', !openCase = ' + !openCaseMap.keySet().contains(createExternalId(c)) +
                             ', !closedCase = ' + !closedCaseMap.keySet().contains(createExternalId(c)) +
                             ', TCU = ' + c.TCU_Activation_Status__c;
                
                errors.add(new Error_Log__c(Record_ID__c = c.Id,
                            Record_Type__c = 'Case',
                            Error_Message__c = logMessage, 
                            TimeStamp__c = System.now(), 
                            Operation_Name__c = 'Batch_VCS_Alert_Case_DataLoad.Email_Sent', 
                            Source__c='Salesforce', 
                            Log_Type__c = 'Error', 
                            Log_Level__c = 1));
            }
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emailMessages);
        }

        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }

    private Vehicle__c getVehicle(Stage_VCS_Alert__c stage) {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = stage.VIN__c;
        vehicle.Make_Name__c = stage.Make__c;
        vehicle.Model_Name__c = stage.Model__c;
        vehicle.Model_Year__c = stage.Model_Year__c;
        
        return vehicle;
    }

    private String createSubject(Case c) {
        String subject = 'Case: ' + c.CaseNumber + '; Customer: ';
        if (c.First_Name__c != null) {
            subject = subject + c.First_Name__c + ' ';
        }
        if (c.Last_Name__c != null) {
            subject = subject + c.Last_Name__c;
        }
        subject = subject + '; VIN: ' + c.VIN__c;
        
        return subject;
    }
    
    private String createExternalId(Stage_VCS_Alert__c stage) {
        String externalId = VCS_ALERT + '_' + stage.Transaction_Master_Id__c + '_' + stage.VIN__c;
        return externalId;
    }

    private String createExternalId(Case c) {
        String externalId = VCS_ALERT + '_' + c.Transaction_Master_Id__c + '_' + c.VIN__c;
        return externalId;
    }

    private String getCreationEmailBody(Case c, String url) {
        String emailBody = 'There is a new Enrollment Alert that requires your attention.  Our records show this VIN is eligible but has not been enrolled in ';
        Boolean fieldAdded = false;        
        if (c.IC_Subscription_Status__c == false) {
            emailBody += INFINITI_CONNECTION;
            fieldAdded = true;
        }
        if (c.IPA_Subscription_Status__c == false) {
            if (fieldAdded == true) {
                emailBody += ', ';
            }
            emailBody += INFINITI_PERSONAL_ASSISTANT;
            fieldAdded = true;
        }
        if (c.TCU_Activation_Status__c == false) {
            if (fieldAdded == true) {
                emailBody += ', ';
            }
            emailBody += TELEMATICS_COMMUNICATION_UNIT;
            fieldAdded = true;
        }
        emailBody += '. Please click the link below to review the Case and take appropriate action: ' + url + '?caseId=' + c.Id;
        
        return emailBody;
    }

    private String getOpenEmailBody(Case c, String url) {

        String emailBody = 'Our records show that there is an existing open Enrollment Alert for this Vehicle and that the Telematics Communication Unit (TCU) ' +
                           'has not been activated.  Please click the link below to review the case and take appropriate action: ' + url + '?caseId=' + c.Id;
        
        return emailBody;
    }

    private String getReopenEmailBody(Case c, String url) {
        String emailBody = 'Our records show that there is an Enrollment Alert for this Vehicle and that the Telematics Communication Unit (TCU) ' +
                           'has not been activated.  Please click the link below to review the case and take appropriate action: ' + url + '?caseId=' + c.Id;
        
        return emailBody;
    }

    global void finish(Database.BatchableContext BC){
    }
}