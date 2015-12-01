/**********************************************************************
Name: Batch_VCS_Alert_Update_Sharing
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class deletes and re-inserts sharing for open VCS Alert cases.
This keeps the sharing up to date as dealer portal users are added or
removed during the lifetime of a case.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     12/18/2013 Created
***********************************************************************/
//Batch_VCS_Alert_Update_Sharing batchJob = new Batch_VCS_Alert_Update_Sharing();
//Database.executeBatch(batchJob);
global class Batch_VCS_Alert_Update_Sharing implements Database.Batchable<sObject> {
    global String queryBase = 'Select Id, Servicing_Dealer__c, Servicing_Dealer__r.Dealer_External_Id__c, ' +
                                     '(Select Id ' +
                                      'From Shares ' +
                                      'Where RowCause = \'Manual\' ' +
                                      'And UserOrGroupId in (select id ' +
                                                            'from user ' +
                                                            'where isactive = true ' +
                                                            'and profile.userlicense.name = \'Gold Partner\')) ' +
                              'From Case ' +
                              'Where IsClosed = false ' +
                              'and RecordTypeId = \'012F0000000yH3M\'';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = queryBase;

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases) {
        List<CaseShare> sharesToDelete = new List<CaseShare>();
        Set<Id> dealerIds = new Set<Id>();

        // Collect shares to delete and dealer Ids
        for (Case c : cases) {
            if (c.Shares != null && !c.Shares.isEmpty()) {
                sharesToDelete.addAll(c.Shares);
            }
            
            dealerIds.add(c.Servicing_Dealer__c);
        }
        
        // Delete Shares
        if (!sharesToDelete.isEmpty()) {
            Database.DeleteResult[] dbResults = Database.delete(sharesToDelete, false);
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

        // Share the Cases with the appropriate lists of Users
        List<CaseShare> sharesToInsert = new List<CaseShare>();
        for (Case c: cases) {
            dealerPortalUsers = dealerPortalUserMap.get(c.Servicing_Dealer__r.Dealer_External_Id__c);
            if (dealerPortalUsers != null && !dealerPortalUsers.isEmpty()) {
                for (User u: dealerPortalUsers) {
                    CaseShare cs = new CaseShare();
                    cs.CaseId = c.Id;
                    cs.UserOrGroupId = u.Id;
                    cs.CaseAccessLevel = 'Edit';
                    sharesToInsert.add(cs);
                }
            }
        }

        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (!sharesToInsert.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(sharesToInsert, false);
            for (integer row = 0; row < sharesToInsert.size(); row++) {
                if (!dbResults[row].isSuccess()) {
                    Database.Error err = dbResults[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = sharesToInsert[row].CaseId,
                                Record_Type__c = 'Case',
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_VCS_Alert_Update_Sharing',
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                }
            }
        }
        
        if (!errors.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}