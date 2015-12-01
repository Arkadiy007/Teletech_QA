/**********************************************************************
Name: Batch_CheckRequest_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Stage_Check_Request__c table data from SAP into the Check_Request__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     11/28/2011 Created
***********************************************************************/
global class Batch_CheckRequest_DataLoad implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Check_Number__c, Error_Message__c, Issue_Date__c, SFDC_Case_Id__c, Successful__c ' +
                'FROM Stage_Check_Request__c ' +
                'WHERE Origination_source__c = \'' + System.Label.Origination_Source_Informatica + '\' ' +
                'AND Origination_Type__c = \'' + System.Label.Origination_Type_Check_Processing_File + '\' ' +
                'AND Successful__c != \'Y\'';
        if (Test.isRunningTest()) {
            query = query + ' AND Payable_To_Last_Name__c = \'ZYXABC\'';
        }
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Stage_Check_Request rows returned and update corresponding records in Check_Request
    global void execute(Database.BatchableContext BC, List<Stage_Check_Request__c> lstChkTable) {       

        // Initialize variables and lists
        Check_Request__c ChkRec;
        List<Check_Request__c> lstChk = new List<Check_Request__c>();   
        Map<Integer, Stage_Check_Request__c> ChkInsMap = new Map<Integer, Stage_Check_Request__c>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Stage_Check_Request__c doneChk;
        List<Stage_Check_Request__c> updateStageList = new List<Stage_Check_Request__c>();
        List<String> chkDocIds = new List<String>();
        List<Check_Request__c> chkList = new List<Check_Request__c>();
        Map<String, Check_Request__c> chkMap = new Map<String, Check_Request__c>();

        // Loop through all Stage_Check_Request records returned to get a List of Ids to look up
        for (Stage_Check_Request__c stage : lstChkTable)
        {
            chkDocIds.add(stage.SFDC_Case_Id__c);
        }
        
        // Get Check_Request objects from Document_ID list
        chkList = [select Id, Issue_Date__c, Check_Number__c, Document_ID__c from Check_Request__c where Document_ID__c in :chkDocIds];
        
        for (Check_Request__c chk: chkList) {
            chkMap.put(chk.Document_id__c, chk);
        }

        // Loop through all Stage_Check_Request records returned
        for (Stage_Check_Request__c ChkAll : lstChkTable)
        {
            try {
                ChkRec = chkMap.get(ChkAll.SFDC_Case_Id__c);
                if (ChkRec == null) {
                    errors.add(new Error_Log__c(Record_ID__c = ChkAll.Id,
                                Record_Type__c = 'Check_Request__c', 
                                Error_Message__c = 'Could not match Document_ID__c = ' + ChkAll.SFDC_Case_Id__c + ' in Check_Request__c', 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_CheckRequest_DataLoad', 
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                    
                    ChkAll.Successful__c = 'N';
                    ChkAll.Error_Message__c = 'Could not match Document_ID__c = ' + ChkAll.SFDC_Case_Id__c + ' in Check_Request__c';
                    updateStageList.add(ChkAll);
                } else {
                    
                    // Set Check_Request fields from the input Stage_Check_Request
                    fillCheckRequest(ChkRec, ChkAll);
                       
                    // Add Check_Request record to the list to update 
                    lstChk.add(ChkRec);
                }   
                
                // Save the input Stage_Check_Request to a numbered Map where the key of the Map is the
                // index of the Stage_Check_Request in the original input.
                ChkInsMap.put(ins,ChkAll);  
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = ChkAll.Id,
                                    Record_Type__c = 'Stage_Check_Request__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Check_Request_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Check Request rows are in the list, update them and handle any errors.
        if (!lstChk.isEmpty())      //UPDATE PROCESSED
        {   
            // Update rows
            Database.SaveResult[] dbResult = Database.update(lstChk, false);

            // If there are any results, handle the errors
            if (!dbResult.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstChk.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResult[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResult[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (ChkInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Check_Request__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequest_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                        
                        doneChk = ChkInsMap.get(row);
                        doneChk.Successful__c = 'N';
                        doneChk.Error_Message__c = 'Failed to update row in Check_Request__c: ' + err.getMessage();
                        updateStageList.add(doneChk);
                    } else {
                        // If the current row was successful, set Successful__c to 'Y'.
                        doneChk = ChkInsMap.get(row);
                        doneChk.Successful__c = 'Y';
                        updateStageList.add(doneChk);
                    }
                }
            }
        }
        
        // If any Check Requests were successful, update the Stage_Check so their Successful__c is set.
        if (!updateStageList.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.update(updateStageList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < updateStageList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateStageList[row].Id,
                                    Record_Type__c = 'Stage_Check_Request__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequest_DataLoad.Update_StageCheckRequest', 
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
    
    private void fillCheckRequest(Check_Request__c cr, Stage_Check_Request__c stage) {
        cr.Issue_Date__c = Text_Util.MMDDCCYYtoDate(stage.Issue_Date__c);
        cr.Check_Number__c = stage.Check_Number__c;
        cr.Stage_Status__c = System.Label.Stage_Status_Done;
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}