global class Batch_LinkSurveysToCases implements Database.Batchable < SObject >, Schedulable {
    private Id epsilonRT = RecordTypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Epsilon Survey');
    private string query { get {
            Epsilon_Link_Job_Settings__c settings = Epsilon_Link_Job_Settings__c.getOrgDefaults();
            if (settings.Number_of_days__c != null) {
                return 'SELECT Id, Lead_Id__c, DQR_Dealer_Contacted__c, DQR_Dealer_Rating__c, RecordTypeId FROM Surveys__c WHERE EpErrors__c != null AND CreatedDate = LAST_N_DAYS:' + settings.Number_of_days__c + ' AND RecordTypeId = :epsilonRT';
            }

            return 'SELECT Id, Lead_Id__c, DQR_Dealer_Contacted__c, DQR_Dealer_Rating__c, RecordTypeId FROM Surveys__c WHERE EpErrors__c != null AND CreatedDate = LAST_N_DAYS:5 AND RecordTypeId = :epsilonRT';
        } set; }
    global Batch_LinkSurveysToCases() {

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
    global void execute(Database.BatchableContext context, List<Surveys__c> scope) {
        EpsilonSurveyAfterHelper surveysHelper = new EpsilonSurveyAfterHelper();
        surveysHelper.upsertCasesForEpsilonRT(scope, false);
    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }
    global void execute(SchedulableContext sc) {
        //Batch_LinkSurveysToCases batchJob = new Batch_LinkSurveysToCases();
        Database.executeBatch(this);
    }
}