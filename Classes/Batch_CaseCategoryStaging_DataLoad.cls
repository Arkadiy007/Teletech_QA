/**********************************************************************
Name: Batch_CaseCategoryStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Case_Categorization__c table data into Stage_Case_Detail__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry         11/14/2011 Initial Creation
***********************************************************************/
global class Batch_CaseCategoryStaging_DataLoad implements Database.Batchable<sObject> {

    // String of query for all creatable fields on Case_Categorization__c
    global String query;
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause;
        
        if(Test.isRunningTest()) {
            WClause = 'Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                 System.Label.Stage_Status_Update + '\') And Root_Cause__c = \'ZYXABC\' ' +
                      'And Case__r.Spam_Remove_From_Backfeed__c != true';
        } else {
            WClause = 'Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                 System.Label.Stage_Status_Update + '\') ' +
                      'And Case__r.Spam_Remove_From_Backfeed__c != true';
        }
        query = BuildSoqlUtil.getCreatableFieldsSOQL('Case_Categorization__c', WClause);
        query = query.replace('FROM Case_Categorization__c', ', Case__r.DocumentId__c, Case__r.CaseNumber, Case__r.RecordType.Name FROM Case_Categorization__c');
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case_Categorization__c rows returned and insert corresponding records
    // into Stage_Case_Detail
    global void execute(Database.BatchableContext BC, List<Case_Categorization__c> lstCaseCatTable) {       

        // Initialize variables and lists
        Stage_Case_Detail__c CaseDtlStgRec;
        List<Stage_Case_Detail__c> lstCaseDtlStg = new List<Stage_Case_Detail__c>();    
        Map<Integer, Case_Categorization__c> CaseCatInsMap = new Map<Integer, Case_Categorization__c>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Case_Categorization__c doneCaseCat;
        List<Case_Categorization__c> updateCaseCatList = new List<Case_Categorization__c>();

        // Loop through all Case_Categorizations returned and classify them as adds or updates.
        for (Case_Categorization__c CaseCatAll : lstCaseCatTable)
        {
            try {
                CaseDtlStgRec = new Stage_Case_Detail__c();
                
                if (CaseCatAll.Stage_Status__c == System.Label.Stage_Status_Add)        //ADD
                {   
                    System.debug('********** ADD: ');   
                    CaseDtlStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Add;          
                }  
                else if (CaseCatAll.Stage_Status__c == System.Label.Stage_Status_Update)//UPDATE 
                { 
                    System.debug('********** UPDATE: ');
                    CaseDtlStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Update;
                }
                
                // Set Stage_Case_Detail fields from the input Case_Categorization
                fillStageCaseDetail(CaseDtlStgRec, CaseCatAll);
                   
                // Add Stage_Case_Detail record to the list to insert 
                lstCaseDtlStg.add(CaseDtlStgRec);   
                
                // Save the input Case_Categorization__c to a numbered Map where the key of the Map is the
                // index of the Case_Categorization__c in the original input.
                CaseCatInsMap.put(ins,CaseCatAll);  
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseCatAll.Id,
                                    Record_Type__c = 'Case_Categorization__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CaseCategoryStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Stage_Case_Detail rows are in the list, insert them and handle any errors.
        if (!lstCaseDtlStg.isEmpty())       //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCDStage = Database.insert(lstCaseDtlStg, false);

            // If there are any results, handle the errors
            if (!dbCDStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseDtlStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCDStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCDStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (CaseCatInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Case_Detail__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CaseCategoryStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
                        // If the current row was successful, set its status to Done Processing.
                        doneCaseCat = CaseCatInsMap.get(row);
                        doneCaseCat.Stage_Status__c = System.Label.Stage_Status_Done;
                        updateCaseCatList.add(doneCaseCat);
                    }
                }
            }
        }
        
        // If any Case Categorizations were successful, update them so their Stage_Status__c is set to Done Processing.
        if (!updateCaseCatList.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(updateCaseCatList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < updateCaseCatList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateCaseCatList[row].Id,
                                    Record_Type__c = 'Case_Categorization__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CaseCategoryStaging_DataLoad.Update_CaseCat', 
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
    
    public static void fillStageCaseDetail(Stage_Case_Detail__c stage, Case_Categorization__c cc) {
        stage.Batch_Status__c = 'New';
        stage.Case_DocumentID__c = Text_Util.getDocumentId(cc.Case__r.DocumentId__c, cc.Case__r.CaseNumber, cc.Case__r.RecordType.Name);
        stage.Category_Code__c =  cc.Category_Code__c;
        stage.Category_Description__c = cc.Category_Description__c;
        stage.Detail_Type__c = System.Label.Detail_Type_Categorization;
        stage.Concern_Code__c = cc.Concern_Code__c;
        stage.Concern_Description__c = cc.Concern_Description__c;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.Root_Cause__c =  cc.Root_Cause__c;
        if (stage.SFDC_Action_Code__c == null) {
            stage.SFDC_Action_Code__c = System.Label.Stage_Action_Add;
        }
        stage.SFDC_Case_Id__c = cc.Case__c;
        stage.SubCategory_Code__c = cc.Subcategory_Code__c;
        stage.SubCategory_Description__c = cc.Subcategory_Description__c;
        stage.Successful__c = null;
        stage.Symptom_Code__c = cc.Symptom_Code__c;
        stage.Symptom_Description__c = cc.Symptom_Description__c;
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}