/**********************************************************************
Name: Batch_Techline_CaseComment_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Techline specific Stage_Case_Detail table data into CaseComment table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 12/17/2011 Created
***********************************************************************/
global class Batch_Techline_CaseComment_DataLoad implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = 'Successful__c != \'Y\' AND Origination_Type__c = \'Techline\' AND Origination_Source__c = \'Informatica\' ';
        if (Test.isRunningTest()) {
            WClause = WClause + ' AND Root_Cause__c = \'ZYXABC\'';
        }
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_Case_Detail__c', WClause);
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Stage_Case_Detail__c> lstCaseStagingTable) {     
        CaseComment newCaseComment;
        List<CaseComment> lstCaseCommentInsert = new List<CaseComment>();       
        List<Stage_Case_Detail__c> stages = new List<Stage_Case_Detail__c>();
        Map<Integer, Stage_Case_Detail__c> CaseDtlStagingInsMap = new Map<Integer, Stage_Case_Detail__c>();
        integer ins=0;
        List<String> incidentNumbers = new List<String>();
        List<Case> cases;
        Map<String, Case> incidentMap = new Map<String,Case>();
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        for (Stage_Case_Detail__c stage : lstCaseStagingTable) {
            incidentNumbers.add(stage.Incident_Number__c);
        }
        
        cases = [Select Id, Incident_Number__c From Case Where Incident_Number__c in :incidentNumbers];
        
        for (Case oneCase: cases) {
            incidentMap.put(oneCase.Incident_Number__c, oneCase);
        }
          
        for (Stage_Case_Detail__c stage : lstCaseStagingTable)
        {
            try {
                newCaseComment = new CaseComment();       
                if (stage.SFDC_Action_Code__c == 'A')
                {
                    newCaseComment.CommentBody = stage.Incident_Comment_Date__c + ': ' + stage.Case_Comments__c;
                    newCaseComment.ParentId = (incidentMap.get(stage.Incident_Number__c)).Id;
                      
                    lstCaseCommentInsert.add(newCaseComment); 
                    CaseDtlStagingInsMap.put(ins,stage);   
                    ins++;
                 }
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = stage.Id,
                                    Record_Type__c = 'Stage_Case_Detail__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Techline_CaseComment_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }  
        }
      
        //INSERT PROCESSED
        if (lstCaseCommentInsert.size() > 0) {
            Stage_Case_Detail__c CStageIns; 
        
            Database.SaveResult[] lstCSIns = Database.insert(lstCaseCommentInsert, false);

            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < lstCaseCommentInsert.size(); x++) {
                    CStageIns = CaseDtlStagingInsMap.get(x);
                    if (lstCSIns[x].isSuccess()) {        
                        CStageIns.Successful__c = 'Y';
                    } else {           
                        CStageIns.Successful__c = 'N';
                        Database.Error err = lstCSIns[x].getErrors()[0];
                        CStageIns.Error_Message__c = err.getMessage();                               
                    } 
                    stages.add(CStageIns);      
                }
            }
        }

        if (!stages.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(stages, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < stages.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = stages[row].Id,
                                    Record_Type__c = 'Stage_Case_Detail__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Techline_CaseComment_DataLoad.Update_StageCaseDetails', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}