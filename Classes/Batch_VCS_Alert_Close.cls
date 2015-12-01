/**********************************************************************
Name: Batch_VCS_Alert_Close
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class closes VCS Alert cases that meet the criteria to close.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     11/13/2013 Created
***********************************************************************/
//Batch_VCSCase_CreateCall batchJob = new Batch_VCSCase_CreateCall();
//Database.executeBatch(batchJob);
global class Batch_VCS_Alert_Close implements Database.Batchable<sObject> {
    global String queryBase = 'Select Id, Customer_Declined__c, CreatedDate ' +
                              'From Case c ' +
                              'Where IsClosed = false ' +
                              'and RecordTypeId = \'012F0000000yH3M\' ' +
                              'and TCU_Activation_Status__c = true';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = queryBase;

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases) {
        String ownerId;
        List<Case> casesToClose = new List<Case>();
        Date createdDate;
        Date today = System.today();
        Integer days;

        for (Case c : cases) {
            createdDate = Date.valueOf(c.createdDate);
            days = createdDate.daysBetween(today);
            
            if (days >= 14 && c.Customer_Declined__c == 'Customer not reached') {
                c.Status = 'Closed';
                c.Remove_Dealer_Sharing__c = true;
                casesToClose.add(c);
            } else if (days >= 120) {
                c.Status = 'Closed';
                if (c.Customer_Declined__c == null) {
                    c.Customer_Declined__c = 'System Closed';
                }
                c.Remove_Dealer_Sharing__c = true;
                casesToClose.add(c);
            }
        }
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (!casesToClose.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(casesToClose, false);
            for (integer row = 0; row < casesToClose.size(); row++) {
                if (!dbResults[row].isSuccess()) {
                    Database.Error err = dbResults[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = casesToClose[row].Id,
                                Record_Type__c = 'Case',
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_VCS_Alert_Close',
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                }
            }
        }
        
        if (!errors.isEmpty())
            Database.SaveResult[] dbResults = Database.insert(errors, false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}