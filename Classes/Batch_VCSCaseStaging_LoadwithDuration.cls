/**********************************************************************
Name: Batch_VCSCaseStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads VCS and LEAF Case table data into Stage_Case__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry         09/26/2013 Created
1.0 - Matt Starr        02/24/2014 Added new field mapping for
                        Call Type, Model Line, Customer Name, &
                        Current Vehicle Make.
***********************************************************************/
global class Batch_VCSCaseStaging_LoadwithDuration implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;
   
    public static String getQuery() {
        return 'SELECT Id, Account.Customer_Id__c, CDIID__c, Servicing_Dealer__r.Dealer_Code__c, Description, Primary_Reason__c, ' +
                      'Secondary_Reason__c, Vehicle_Name__r.Vehicle_Identification_Number__c, ' +
                      'Model_Line__c, Model_Code__c, Model_Year__c, Stage_Status__c, RecordType.Name, ' +
                      'Error_Code__c, CreatedDate, LastModifiedDate, Country_of_Origin__c, Who_Contacted_Us__c, ' +
                      'Make__c, CaseNumber, Account.Name, Owner.Name, Origin FROM Case ';
    }
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        DateTime startdate = DateTime.parse(Label.VCSBatchStartDate);       
        DateTime endDate = DateTime.parse(Label.VCSBatchEndDate);
        query = query + 'Where CreatedDate >: startdate AND CreatedDate <: endDate '+
                        'And RecordType.Name in (\'VCS Support\',\'LEAF\') ' +
                        'And Spam_Remove_From_Backfeed__c != true';

        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned and insert corresponding records into Stage_Case
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {
        // Initialize variables and lists
        Stage_Case__c CaseStgRec;
        List<Stage_Case__c> lstCaseStg = new List<Stage_Case__c>(); 
        Map<Integer, Case> CaseInsMap = new Map<Integer, Case>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Case doneCase;        
        List<String> caseIds = new List<String>();

        // Get all Model lines from Code__c records
        List<Code__c> modelLineList = new List<Code__c>([select Id, Type__c, Code__c, Description__c 
                                                         from Code__c
                                                         where Type__c = 'Model_Line']);
        Map<String,String> modelLines = new Map<String,String>();
        for(Code__c modelLine: modelLineList) {
            modelLines.put(modelLine.Description__c, modelLine.Code__c);
        }

        for (Case c: lstCaseTable) {
            caseIds.add(c.Id);
        }
        List<Case> caseCalls = [select id, (select id from calls__r) from case where Id in :caseIds];
        Map<String,Integer> caseCallCount = new Map<String,Integer>();
        for (Case c: caseCalls) {
            if (c.Calls__r != null) {
                caseCallCount.put(c.Id, c.Calls__r.size());
            }
        }
    
        // Loop through all Cases returned
        for (Case CaseAll : lstCaseTable)
        {
            CaseStgRec = new Stage_Case__c();
            
            try {
                // Set Stage_Case fields from the input Case
                fillCaseStage(CaseStgRec, CaseAll, modelLines);
                   
                // Add Stage_Case record to the list to insert 
                lstCaseStg.add(CaseStgRec); 
                
                // Save the input Case to a numbered Map where the key of the Map is the
                // index of the Case in the original input.
                CaseInsMap.put(ins,CaseAll);    
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseAll.Id,
                                    Record_Type__c = 'Case', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_VCSCaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Stage_Case rows are in the list, insert them and handle any errors.
        if (!lstCaseStg.isEmpty())      //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCStage = Database.insert(lstCaseStg, false);

            // If there are any results, handle the errors
            if (!dbCStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (CaseInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Case__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_VCSCaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
                        // If the current row was successful, set its status to Done Processing.
                        doneCase = CaseInsMap.get(row);
                        doneCase.Stage_Status__c = System.Label.Stage_Status_Done;
                       // updateCaseList.add(doneCase);
                    }
                }
            }
        }

      
    }

    public static void fillCaseStage(Stage_Case__c stage, Case c, Map<String,String> modelLines) {
        stage.Batch_Status__c = 'New';
        stage.Call_Type__c = c.Origin; // Added by Matt Starr
        stage.Case_Number__c = c.CaseNumber;
        stage.Case_Owner__c = c.Owner.Name;
        stage.CDIID__c = c.CDIID__c;
        stage.Channel_Designation_Code__c = c.Make__c;
        stage.Contact_Id__c = c.Account.Customer_Id__c;
        stage.Country_of_Origin__c = c.Country_of_Origin__c;
        stage.Customer_Name__c = c.Account.Name; // Added by Matt Starr
        stage.Description__c = c.Description;
        stage.Error_Code__c = c.Error_Code__c;
        stage.Current_Vehicle_Make__c = c.Make__c; // Added by Matt Starr
        stage.Model__c = c.Model_Line__c != null ? modelLines.get(c.Model_Line__c.toUpperCase()) : null;
        stage.ModelCode__c = c.Model_Code__c != null ? c.Model_Code__c.toUpperCase() : null;
        stage.Model_Line__c = c.Model_Line__c; // Added by Matt Starr
        stage.ModelYear__c = c.Model_Year__c;
        stage.Modified_Date__c = Text_Util.getFormattedDateTime(c.LastModifiedDate);
        stage.Open_Date__c = Text_Util.getFormattedDateTime(c.CreatedDate);
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_VCS;
        stage.Primary_Reason__c = c.Primary_Reason__c;
        stage.Secondary_Reason__c = c.Secondary_Reason__c;
        stage.Service_Dealer_Number__c = c.Servicing_Dealer__r.Dealer_Code__c;
        stage.SFDC_Case_Id__c = c.Id;
        stage.Who_Contacted_Us__c = c.Who_Contacted_Us__c;
        if (c.Stage_Status__c == System.Label.Stage_Status_Add) {
            stage.SFDC_Action_Code__c = System.Label.Stage_Action_Add;
        } else {
            stage.SFDC_Action_Code__c = System.Label.Stage_Action_Update;
        }
        if (c.Vehicle_Name__c != null && c.Vehicle_Name__r.Vehicle_Identification_Number__c != null) {
            stage.VIN__c = c.Vehicle_Name__r.Vehicle_Identification_Number__c;
        }
    }
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}