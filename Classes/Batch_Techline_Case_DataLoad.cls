/**********************************************************************
Name: Batch_CCG_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Techline specific Stage_Case table data into Case table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Munawar Esmail 12/02/2011 Created
***********************************************************************/
global class Batch_Techline_Case_DataLoad implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = 'Successful__c != \'Y\' AND Origination_Type__c = \'Techline\' AND Origination_Source__c = \'Informatica\' ';
        if (Test.isRunningTest()) {
            WClause = WClause + ' AND First_Name__c = \'ZYXABC\'';
        }
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_Case__c', WClause);
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Stage_Case__c> lstCaseStagingTable) {
        Case CaseRecIns;
        List<Case> lstCaseUpsert = new List<Case>(); 
         
        List<String> lstIncidentNo = new List<String>();
        
        List<Stage_Case__c> lstCaseStageProc = new List<Stage_Case__c>();
        
        RecordType techlineRecordType = [select id from recordtype where name = 'Tech Line' and sobjecttype = 'Case'];
        
        Map<Integer, Stage_Case__c> CaseStagingInsMap = new Map<Integer, Stage_Case__c>();
        integer ins=0;

        Map<Integer, Stage_Case__c> CaseStagingUpdMap = new Map<Integer, Stage_Case__c>();
        integer upd=0;
        
        Map<Integer, Stage_Case__c> CaseStagingDelMap = new Map<Integer, Stage_Case__c>();
        integer del=0;
                
        Map<String, Stage_Case__c> IncidentNoToCaseStagingMap = new Map<String, Stage_Case__c>();
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        System.debug('********** START************');
        for (Stage_Case__c CaseStageAll : lstCaseStagingTable)
        {
            try {
                CaseRecIns = new Case();        
                if (CaseStageAll.SFDC_Action_Code__c == 'P')    //UPSERT
                {           
                    System.debug('********** UPSERT');
                    //CaseRecIns.ClosedDate = Text_Util.MMDDCCYYtoDate(CaseStageAll.Close_Date__c);                                   
                    CaseRecIns.First_Name__c = CaseStageAll.First_Name__c;
                    CaseRecIns.Incident_Date__c = Text_Util.MMDDCCYYtoDate(CaseStageAll.Incident_Date__c);
                    CaseRecIns.Current_Mileage__c = CaseStageAll.Mileage__c != null ? Integer.valueOf(CaseStageAll.Mileage__c) : null;
                    //CaseRecIns.Model_Line__c = CaseStageAll.Model__c;
                    //CaseRecIns.Model_Year__c = CaseStageAll.ModelYear__c;
                    //CaseRecIns.CreatedDate = Text_Util.MMDDCCYYtoDate(CaseStageAll.Open_Date__c);
                    CaseRecIns.Part_Number_1__c = CaseStageAll.Part_Number__c;
                    CaseRecIns.Service_Dealer_Number__c = CaseStageAll.Service_Dealer_Number__c;
                    CaseRecIns.VIN__c = CaseStageAll.VIN__c;
                    CaseRecIns.PNC_Description__c = CaseStageAll.PNC_Description__c;
                    CaseRecIns.Report_Type__c = CaseStageAll.Report_Type__c;
                    CaseRecIns.Incident_Number__c = CaseStageAll.Incident_Number__c;
                    CaseRecIns.Case_External_ID__c = 'Techline_' + CaseStageAll.Incident_Number__c;
                    CaseRecIns.In_Service_Date__c = Text_Util.MMDDCCYYtoDate(CaseStageAll.In_Service_Date__c);
                    CaseRecIns.Mileage_Initial__c = Text_Util.DecimalValueOf(CaseStageAll.Mileage_Initial__c);
                    CaseRecIns.Distributor_Code__c = CaseStageAll.Distributor_Code__c;
                    CaseRecIns.Production_Date__c = CaseStageAll.Production_Date__c != null ? date.valueOf(CaseStageAll.Production_Date__c) : null;
                    CaseRecIns.Expected_Response_Date__c = CaseStageAll.Expected_Response_Date__c != null ? date.valueOf(CaseStageAll.Expected_Response_Date__c) : null;
                    //CaseRecIns.Assignment_Level_Code__c = CaseStageAll.Assignment_Level_Code__c;
                    //CaseRecIns.Assignment_Level_Name__c = CaseStageAll.Assignment_Level_Name__c;
                    CaseRecIns.Parts_Available_Indicator__c = Text_Util.BooleanLookup(CaseStageAll.Parts_Available_Indicator__c, false);
                    //CaseRecIns.Parts_Request_Date__c= CaseStageAll.Parts_Request_Date__c != null ? date.valueOf(CaseStageAll.Parts_Request_Date__c) : null;
                    //CaseRecIns.Parts_Requestor__c = CaseStageAll.Parts_Requestor__c;
                    CaseRecIns.Requested_Part_Number__c = CaseStageAll.Requested_Part_Number__c;
                    CaseRecIns.Requested_RO_Number__c = CaseStageAll.Requested_RO_Number__c;
                    //CaseRecIns.Parts_Received_Date__c = CaseStageAll.Parts_Received_Date__c != null ? date.valueOf(CaseStageAll.Parts_Received_Date__c) : null;             
                    CaseRecIns.Shipped_Date__c = CaseStageAll.Shipped_Date__c != null ? date.valueOf(CaseStageAll.Shipped_Date__c) : null;
                    CaseRecIns.Project_Number__c = CaseStageAll.Project_Number__c;
                    CaseRecIns.Reason_for_Call_Code__c = CaseStageAll.Reason_for_Call_Code__c;
                    CaseRecIns.Reason_for_Call_Description__c = CaseStageAll.Reason_for_Call_Description__c;
                    CaseRecIns.Field_Inspection_Indicator__c = Text_Util.BooleanLookup(CaseStageAll.Field_Inspection_Indicator__c,false);
                    CaseRecIns.Attachment_Indicator__c = Text_Util.BooleanLookup(CaseStageAll.Attachment_Indicator__c,false);
                    CaseRecIns.TSS_Code_Primary__c = CaseStageAll.TSS_Code_Primary__c;
                    CaseRecIns.Customer_Name__c = CaseStageAll.Customer_Name__c;
                    CaseRecIns.Client_Dealer_ID__c = CaseStageAll.Client_Dealer_ID__c;
                    CaseRecIns.TSS_Name__c = CaseStageAll.TSS_Name__c;
                    CaseRecIns.Incident_Category_Code__c = CaseStageAll.Incident_Category_Code__c;
                    CaseRecIns.Solution_Description__c= CaseStageAll.Solution_Description__c;
                    CaseRecIns.Incident_Category_Name__c = CaseStageAll.Incident_Category_Name__c;
                    CaseRecIns.RecordTypeId = techlineRecordType.Id;
                                
                    lstCaseUpsert.add(CaseRecIns); 
                    CaseStagingInsMap.put(ins,CaseStageAll);    
                    ins++;
                }
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseStageAll.Id,
                                    Record_Type__c = 'Stage_Case__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Techline_Case_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }  
        }
                
        if (lstCaseUpsert.size() > 0)       //UPSERT PROCESSED
        {
            Stage_Case__c CStageIns; 
            Schema.SObjectField caseExternalIdField = Case.Fields.Case_External_Id__c;
            Database.UpsertResult[] lstCSIns = Database.upsert(lstCaseUpsert, caseExternalIdField, false);

            if (lstCSIns.size() > 0) 
            {
                for (integer x = 0; x < lstCaseUpsert.size(); x++)
                {
                    CStageIns = CaseStagingInsMap.get(x);
                    if (lstCSIns[x].isSuccess())
                    {               
                        CStageIns.Successful__c = 'Y';
                    } 
                    else
                    {                   
                        CStageIns.Successful__c = 'N';
                        Database.Error err = lstCSIns[x].getErrors()[0];
                        CStageIns.Error_Message__c = err.getMessage();
                        //System.debug('********** CStageIns.Error_Message__c: '+ CStageIns.Error_Message__c);                                                          
                    } 
                    lstCaseStageProc.add(CStageIns);            
                }
            }
        }
    
        if (!lstCaseStageProc.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(lstCaseStageProc, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseStageProc.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = lstCaseStageProc[row].Id,
                                    Record_Type__c = 'Stage_Case__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Techline_Case_DataLoad.Update_StageCases', 
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
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information. 
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email, CompletedDate
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
          
        // Send an email to the Apex job's submitter notifying of job completion. 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Case DataLoad ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     //closed for testing
    }

}