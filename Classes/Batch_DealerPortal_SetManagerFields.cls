/**********************************************************************
Name: Batch_DealerPortal_SetManagerFields
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class sets dealer Account fields for Service Manager, Sales Manager,
and Parts Manager based on User fields
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     06/07/2011 Created
***********************************************************************/
global class Batch_DealerPortal_SetManagerFields implements Database.Batchable<sObject> {
    global String query;
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, IsActive, AccountId, LastName, Title ' +
                'FROM User ' +
                'WHERE AccountId != null';
        if (Test.isRunningTest()) {
        	 query = 'SELECT Id, IsActive, AccountId, LastName, Title ' +
                'FROM User Limit 100';
        }
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of User rows returned and update corresponding records in Account
    global void execute(Database.BatchableContext BC, List<User> batchUsers) {       
        Set<Id> dealerIds = new Set<Id>();
        List<Id> dealerIdList = new List<Id>();
        List<User> users = new List<User>();
        Account dealer = null;
        Boolean dealerModified = false;
        Map<Id,Account> updateDealers = new Map<Id,Account>();
        List<Error_Log__c> errors = new List<Error_Log__c>();

        for (User u: batchUsers) {
            if (u.AccountId != null) {
                dealerIds.add(u.AccountId);
                users.add(u);
            }
        }

        dealerIdList.addAll(dealerIds);
        Map<Id,Account> dealers = new Map<Id,Account>([select Id, Service_Manager__c, Sales_Manager__c, Parts_Manager__c from Account where Id in :dealerIdList]);
    
        for (User u: users) {
            dealer = dealers.get(u.AccountId);
            dealerModified = false;

            // For inactive users, make sure they are not set as Service Manager, Sales Manager, or Parts Manager for the dealer
            if (u.IsActive == false) {
                if (dealer.Service_Manager__c == u.Id) {
                    dealer.Service_Manager__c = null;
                    dealerModified = true;
                }
                if (dealer.Sales_Manager__c == u.Id) {
                    dealer.Sales_Manager__c = null;
                    dealerModified = true;
                }
                if (dealer.Parts_Manager__c == u.Id) {
                    dealer.Parts_Manager__c = null;
                    dealerModified = true;
                }
            } else {
            // For active users, set them as Service Manager, Sales Manager, or Parts Manager on the dealer if that is their position.
            // Remove them from roles if their position does not match it.
                if (u.lastname == 'Service Manager' && dealer.Service_Manager__c != u.Id) {
                    dealer.Service_Manager__c = u.Id;
                    dealerModified = true;
                }
                if (u.lastname == 'Sales Manager' && dealer.Sales_Manager__c != u.Id) {
                    dealer.Sales_Manager__c = u.Id;
                    dealerModified = true;
                }
                if (u.lastname == 'Parts Manager' && dealer.Parts_Manager__c != u.Id) {
                    dealer.Parts_Manager__c = u.Id;
                    dealerModified = true;
                }
                if (dealer.Service_Manager__c == u.Id && u.lastname != 'Service Manager') {
                    dealer.Service_Manager__c = null;
                    dealerModified = true;
                }
                if (dealer.Sales_Manager__c == u.Id && u.lastname != 'Sales Manager') {
                    dealer.Sales_Manager__c = null;
                    dealerModified = true;
                }
                if (dealer.Parts_Manager__c == u.Id && u.lastname != 'Parts Manager') {
                    dealer.Parts_Manager__c = null;
                    dealerModified = true;
                }
            }

            // If any of the fields for Service Manager, Sales Manager, or Parts Manager were modified, add the record to be updated.
            if (dealerModified == true) {
                updateDealers.put(dealer.Id, dealer);
            }
        }

        // Update dealers
        if (!updateDealers.values().isEmpty())
        {   
            Database.SaveResult[] results = Database.update(updateDealers.values(), false);
            if (!results.isEmpty()) {
                for (integer row = 0; row < updateDealers.size(); row++) {
                    if (!results[row].isSuccess()) {
                        Database.Error err = results[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateDealers.values()[row].Id, Record_Type__c = 'Account', 
                                    Error_Message__c = err.getMessage(), TimeStamp__c = System.now(), Operation_Name__c = 'Stage_User_Update_Dealer', 
                                    Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
                    }
                }
            }
        }

        // Insert any error rows from updating dealers.
        if (!errors.isEmpty()) {
            insert errors;
        }
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}