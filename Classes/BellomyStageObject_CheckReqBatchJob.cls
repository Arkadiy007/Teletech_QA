/**********************************************************************
  Name: BellomyStageObject_CheckReqBatchJob
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose:
  Batch job for backfeed process for Bellomy. (works only with Check_Request__c object, due to data limits in related report (Check/GL Codes Bellomy))
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/21/2015 Created
 ***********************************************************************/
 global class BellomyStageObject_CheckReqBatchJob implements Database.Batchable<SObject> {
    
    private String query {get; set;}
    private Bellomy_Reports_Settings__c reportSettings {get; Set;}

    global BellomyStageObject_CheckReqBatchJob() {
        retriveCustomSettings();
        query = 'SELECT Id, GL_Value_Code__c, Case__r.CaseNumber, Status__c, Case__r.Owner.UserRole.Name, Check_Amount__c FROM Check_Request__c ';
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
    global void execute(Database.BatchableContext context, List<Check_Request__c> scope) {
        List<StageBellomyCases__c> newBellomyCasesList = new List<StageBellomyCases__c>();
        for(Check_Request__c request : scope){
            List<StageBellomyCases__c> newStageBellomyCases = buildStageObjects(request);
            if(!newStageBellomyCases.isEmpty()){
                newBellomyCasesList.addAll(newStageBellomyCases);
            }
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
            if (settings.Name == 'Check/GL Codes-Bellomy'){
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
        String endTimeStr = reportSettings.End_Date__c.addHours(endOffset).addDays(1).format('yyyy-MM-dd');
        String startTimeStr = reportSettings.Start_Date__c.addHours(startOffset).addDays(1).format('yyyy-MM-dd');

        String timeLimits = ' AND ' + reportSettings.Data_Range_Field__c + ' >= ' + startTimeStr;
        timeLimits += ' AND ' + reportSettings.Data_Range_Field__c + ' <= ' + endTimeStr;
        return timeLimits;
    }

    
    private List<StageBellomyCases__c> buildStageObjects(Check_Request__c cs){
        List<StageBellomyCases__c> stageObjects = new List<StageBellomyCases__c>();
        
        stageObjects.add(newGLCodesStageObject(cs));
        
        return stageObjects;
    }


    private StageBellomyCases__c newGLCodesStageObject(Check_Request__c cs){
        StageBellomyCases__c stageObject = new StageBellomyCases__c();
        stageObject.Case_Number__c = cs.Case__r.CaseNumber;
        stageObject.GL_Value_Code__c = cs.GL_Value_Code__c;
        stageObject.Check_Amount__c = String.valueOf(cs.Check_Amount__c);
        stageObject.Query_Filters__c =  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
        stageObject.Report_Name__c = 'Check/GL Codes-Bellomy';
        stageObject.Batch_Status__c = 'New';
        return stageObject;
    }
 
}