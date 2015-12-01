global class BellomyStageObject_CACBatchJob implements Database.Batchable<SObject> {

    private String query {get; set;}
    private Bellomy_Reports_Settings__c reportSettings {get; Set;}
    
    global BellomyStageObject_CACBatchJob() {
        retriveCustomSettings();
        query = 'SELECT Id, CreatedDate, ClosedDate, CaseNumber, (SELECT Id, Category_Code__c, Category_Description__c, Concern_Code__c, Concern_Description__c, Subcategory_Code__c, Subcategory_Description__c, Symptom_Code__c, Symptom_Description__c FROM Case_Categorizations__r), Origin, CreatedById, OwnerId, Type FROM Case ';
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
            newBellomyCasesList.addAll(newCACategorizationsStageObject(cs));
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
            if (settings.Name == 'CA Categorizations'){
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

     private List<StageBellomyCases__c> newCACategorizationsStageObject(Case cs){
        List<StageBellomyCases__c> stageObjects = new List<StageBellomyCases__c>();

        if (cs.Case_Categorizations__r.isEmpty()){
            StageBellomyCases__c stageObject = new StageBellomyCases__c();
            stageObject.Case_Number__c = cs.CaseNumber;
            stageObject.Type__c = cs.Type;
            stageObject.Query_Filters__c = reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
            stageObject.Report_Name__c = 'CA Categorizations';
            stageObject.Batch_Status__c = 'New';
            stageObjects.add(stageObject);
        }

        for(Case_Categorization__c cc : cs.Case_Categorizations__r){
            StageBellomyCases__c stageObject = new StageBellomyCases__c();
            stageObject.Case_Number__c = cs.CaseNumber;
            stageObject.Type__c = cs.Type;
            stageObject.Concern_Code__c =  cc.Concern_Code__c;
            stageObject.Concern_Description__c = cc.Concern_Description__c;
            stageObject.Category_Code__c = cc.Category_Code__c;
            stageObject.Category_Description__c = cc.Category_Description__c;
            stageObject.Subcategory_Code__c = cc.Subcategory_Code__c;
            stageObject.Subcategory_Description__c = cc.Subcategory_Description__c;
            stageObject.Symptom_Code__c = cc.Symptom_Code__c;
            stageObject.Symptom_Description__c = cc.Symptom_Description__c;
            stageObject.Report_Name__c = 'CA Categorizations';
            stageObject.Query_Filters__c = reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
            stageObject.Batch_Status__c = 'New';
            stageObjects.add(stageObject);
        }
    
        return stageObjects;
    }

}