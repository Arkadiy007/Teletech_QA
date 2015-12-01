global class BellomyStageObjects_VCSTBatchJob implements Database.Batchable<SObject> {
        
    private String query {get; set;}
    private Bellomy_Reports_Settings__c reportSettings {get; Set;}

    global BellomyStageObjects_VCSTBatchJob() {
        retriveCustomSettings();
        query = 'SELECT Id, CaseNumber, Origin, CreatedById, OwnerId,  (Select Id, ParentId, CommentBody FROM CaseComments)  FROM Case ';
        query += addWhereClauses();
        query += limitRecordsDate();
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
        List<StageBellomyCases__c> newBellomyCasesList = new List<StageBellomyCases__c>();
        for(Case cs : scope){
            newBellomyCasesList.addAll(newVCS_TextStageObject(cs));
        }

        insert newBellomyCasesList;
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {

    }

    private void retriveCustomSettings(){
        for (Bellomy_Reports_Settings__c settings : Bellomy_Reports_Settings__c.getAll().values()){
            if (settings.Name == 'Bellomy Test Extract-VCS Text'){
                reportSettings = settings;
            }
        }
    }

    private String addWhereClauses(){
        String whereClause = 'WHERE ' +  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
        return whereClause;
    }

    private String limitRecordsDate(){
        TimeZone tz = UserInfo.getTimeZone();
        Integer startOffset = tz.getOffset(reportSettings.Start_Date__c) / (60 * 60 * 1000);
        Integer endOffset = tz.getOffset(reportSettings.End_Date__c) / (60 * 60 * 1000);

        String endTimeStr = reportSettings.End_Date__c.addHours(endOffset).addDays(1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String startTimeStr = reportSettings.Start_Date__c.addHours(startOffset).addDays(1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

        String timeLimits = ' AND ' + reportSettings.Data_Range_Field__c + ' >= ' + startTimeStr;
        timeLimits += ' AND ' + reportSettings.Data_Range_Field__c + ' <= ' + endTimeStr;
        return timeLimits;
    }

    private List<StageBellomyCases__c> newVCS_TextStageObject(Case cs){
        List<StageBellomyCases__c> stageObjects = new List<StageBellomyCases__c>();
        
        if (cs.CaseComments.isEmpty()){
            StageBellomyCases__c stageObject = new StageBellomyCases__c();
            stageObject.Case_Number__c = cs.CaseNumber;
            stageObject.Query_Filters__c =  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
            stageObject.Report_Name__c = 'Bellomy Test Extract-VCS Text';
            stageObject.Batch_Status__c = 'New';
            stageObjects.add(stageObject);
        }

        for(CaseComment cc : cs.CaseComments){
            StageBellomyCases__c stageObject = new StageBellomyCases__c();
            stageObject.Case_Number__c = cs.CaseNumber;
            stageObject.Case_comments__c = cc.CommentBody;
            stageObject.Query_Filters__c =  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
            stageObject.Report_Name__c = 'Bellomy Test Extract-VCS Text';
            stageObject.Batch_Status__c = 'New';
            stageObjects.add(stageObject);
        }
    
        return stageObjects;
    }
}