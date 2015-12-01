/**********************************************************************
Name: Batch_LEAFCase_CreateCall
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class creates an open Task for LEAF Cases.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     05/21/2012 Created
1.1 - Bryan Fry     09/19/2013 Changed to deal with Tasks not Calls
***********************************************************************/
//Batch_LEAFCase_CreateCall batchJob = new Batch_LEAFCase_CreateCall();
//Database.executeBatch(batchJob);
global class Batch_LEAFCase_CreateCall implements Database.Batchable<sObject> {
    global String queryBase = 'Select Id, OwnerId, ContactId, ' +
                                     '(select Id ' +
                                      'from Tasks ' +
                                      'where Status != \'Complete\')' +
                              'From Case c ' +
                              'Where IsClosed = false ' +
                              'and RecordTypeId = \'012A0000000xeks\'';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = queryBase;
        if(System.Label.Create_Calls_Escalated_Only == 'Yes') {
            query = query + ' and IsEscalated = true';
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> lstCases) {
        List<Task> tasksToCreate = new List<Task>();
        String ownerId;

        RecordType leafRecordType = [select Id, Name from RecordType where SobjectType = 'Task' and Name = 'LEAF'];
        
        for (Case c : lstCases) {
            if (c.Tasks.size() == 0) {
                ownerId = c.ownerId;

                Task t = new Task();
                t.RecordTypeId = leafRecordType.Id;
                t.WhatId = c.Id;
                t.WhoId = c.ContactId;
                t.Subject = 'Outbound Call';
                t.Status = 'Not Started';
                t.ActivityDate = System.today();
                if (ownerId.startsWith('005')) {
                    t.OwnerId = c.OwnerId;
                }
                t.Description = 'Follow Up';
                tasksToCreate.add(t);
            }
        }
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (tasksToCreate.size() > 0) {
            Database.SaveResult[] dbResults = Database.insert(tasksToCreate, false);
            for (integer row = 0; row < tasksToCreate.size(); row++) {
                if (!dbResults[row].isSuccess()) {
                    Database.Error err = dbResults[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = tasksToCreate[row].Id,
                                Record_Type__c = 'Task',
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_LEAFCase_CreateCall',
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