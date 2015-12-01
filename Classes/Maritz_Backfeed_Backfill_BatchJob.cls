global class Maritz_Backfeed_Backfill_BatchJob implements Database.Batchable<SObject> {
    
    private String query {get; set;}

    global static void runBackfillProcess(){
        Maritz_Backfeed_BackfillSettings__c mc = Maritz_Backfeed_BackfillSettings__c.getInstance();
        Database.executeBatch(new Maritz_Backfeed_Backfill_BatchJob(mc.Start_Date__c, mc.End_Date__c, mc.RecordTypeNames__c), 50);
    }

    global Maritz_Backfeed_Backfill_BatchJob(Datetime startTime, Datetime endTime, String recordTypeNames) {
        String startTimeStr = startTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String endTimeStr = endTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        List<String> lines = new List<String>();
        lines = recordTypeNames.split(',');
        Set<String> casesRecordTypeIds = new Set<String>();

        for(String line : lines){
            casesRecordTypeIds.add((String) RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, line));
        }

        query = 'SELECT Id, (SELECT Id, Name, CreatedById, Created_Time__c, CreatedDate, LastModifiedById, Case__c, Outcome__c, Result__c, Reason_Not_Interested__c, Model_of_Interest_1st__c, Model_of_Interest_2nd__c, RecordTypeId FROM Calls__r), (SELECT Id, CreatedById, CreatedDate, LastModifiedById, ParentId, Status, ActivityId, Subject FROM EmailMessages) FROM Case WHERE';
        
        query += ' CreatedDate > ' + startTimeStr;
        query += ' AND CreatedDate < ' + endTimeStr;
        query += ' AND (';
        for(String recTypeId : casesRecordTypeIds){
            query += 'RecordTypeId = ' + '\'' + recTypeId +  '\'' + ' OR ';
        }
        query = query.substring(0, query.length()-3);
        query += ' ) ';
    }
    
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }


    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */ 
    global void execute(Database.BatchableContext context, List<Case> scope) {
        List<Call__c> allCalls = new List<Call__c>();
        List<EmailMessage> allEmails = new List<EmailMessage>();
        for(Case c : scope){
            if(!c.Calls__r.isEmpty()){
                allCalls.addAll(c.Calls__r);
            }
            if(!c.EmailMessages.isEmpty()){
                allEmails.addAll(c.EmailMessages);
            }
        }

        Maritz_Backfeed_TaskTriggerHelper helperCall = new Maritz_Backfeed_TaskTriggerHelper(allCalls);
        Maritz_Backfeed_TaskTriggerHelper helperEmail = new Maritz_Backfeed_TaskTriggerHelper(allEmails);
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {
        
    }
}