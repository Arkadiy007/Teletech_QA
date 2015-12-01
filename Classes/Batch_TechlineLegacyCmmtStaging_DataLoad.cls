/**********************************************************************
Name: Batch_TechlineLegacyCommentStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Legacy Techline CaseComment table data into Techline_Stage_Case_Detail__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor        1/31/2014 Created
***********************************************************************/
global class Batch_TechlineLegacyCmmtStaging_DataLoad implements Database.Batchable<sObject> {
    private final DateTime lastRunDateTime;
    // String of query for all creatable fields on CaseComment
    global String query;
    

    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){

        // check Last Modified Date of parent case to gather all casecomment objects.
        
        String WClause;
        if (Test.isRunningTest()) {
            WClause = '';
        } else {
            WClause = ' Parent.RecordType.Name in (\'Tech Line Cases\') ';
           // WClause = Wclause + ' AND Parent.ID IN (\'500Z0000007L7obIAC\', \'500Z0000007L7ocIAC\', \'500Z0000007L7odIAC\') ';
        }
        
        // Construct query with the where clause and add a child field into the Select list
        query = BuildSoqlUtil.getCreatableFieldsSOQL('CaseComment', WClause);
        query = query.replace('FROM CaseComment', ', Parent.DocumentID__c, Parent.CaseNumber, Parent.RecordType.Name, CreatedBy.UserRole.Name, CreatedBy.Profile.Name, Parent.Case_External_Id__c FROM CaseComment');
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of CaseComment rows returned and insert corresponding records
    // into Techline_Stage_Case_Detail__c
    global void execute(Database.BatchableContext BC, List<CaseComment> lstCaseComTable) {      

        // Initialize variables and lists
        String SFDC_Action_Code;
        Integer lineNumber = 1;
        List<Techline_Stage_Case_Detail__c> addList;
        List<Techline_Stage_Case_Detail__c> lstCaseDtlStg = new List<Techline_Stage_Case_Detail__c>();    
        Map<Integer, CaseComment> CaseComInsMap = new Map<Integer, CaseComment>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        // Get all ZCA ids looked up from User records
        Map<String,User> users = new Map<String,User>([select Id, ZCA_Id__c, TSS_Code__c, Name from User]);

        // Loop through all Case_Categorizations returned and classify them as adds or updates.
        for (CaseComment CaseComAll : lstCaseComTable)
        {
            try {
                SFDC_Action_Code = System.Label.Stage_Action_Add;           
                
                // Set Stage_Case_Detail fields from the input CaseComment
                addList = createStageCaseDetailList(SFDC_Action_Code, 1, CaseComAll, users);
                   
                // Add Stage_Case_Detail record to the list to insert 
                lstCaseDtlStg.addAll(addList);  
                
                // Save the input CaseComment to a numbered Map where the key of the Map is the
                // index of the CaseComment in the original input.
                CaseComInsMap.put(ins,CaseComAll);  
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseComAll.Id,
                                    Record_Type__c = 'CaseComment', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineCaseCommentStaging_DataLoad', 
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
                        errors.add(new Error_Log__c(Record_ID__c = (CaseComInsMap.get(row)).Id,
                                    Record_Type__c = 'Techline_Stage_Case_Detail__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineCaseCommentStaging_DataLoad', 
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
    
    private List<Techline_Stage_Case_Detail__c> createStageCaseDetailList(String SFDC_Action_Code, Integer lineNumber, CaseComment cc, Map<String,User> users) {
        Techline_Stage_Case_Detail__c stage;
        List<Techline_Stage_Case_Detail__c> stageList = new List<Techline_Stage_Case_Detail__c>();
        List<String> lines = splitStringFixed(cc.CommentBody , 150);
        
        stage = new Techline_Stage_Case_Detail__c();
        User user = users.get(cc.CreatedById);
        String tssId = user != null ? user.TSS_Code__c : null;
        stage.Comment_Id__c = cc.Id;
        stage.SFDC_Action_code__c = SFDC_Action_Code;
        stage.Batch_Status__c = 'LEGACY';
        //stage.Case_DocumentID__c = Text_Util.getDocumentId(cc.Parent.DocumentID__c, cc.Parent.CaseNumber, cc.Parent.RecordType.Name);
        stage.Case_Comments__c = 'Created by ' + user.Name + ' at ' + String.valueOf(cc.CreatedDate);
        // stage.Case_Comments__c = 'Created by ' + tssId + ' at ' + String.valueOf(cc.CreatedDate);
        //stage.Detail_Type__c = System.Label.Detail_Type_BasicLine;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Line_Number__c = String.valueOf(lineNumber++);
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = 'TechlineNew';
        if ( cc.Parent.Case_External_Id__c != null ) {
            
            stage.Incident_Number__c = cc.Parent.Case_External_Id__c;
        } else {
           stage.Incident_Number__c = cc.Parent.CaseNumber;
        }
        stage.Successful__c = null;
        stage.User_Defined_Text_1__c = Text_Util.getFormattedDateTime(cc.CreatedDate) + 
                                       Text_Util.getFormattedTime(cc.CreatedDate);
        stageList.add(stage);
        
        for (String line : lines) {
            stage = new Techline_Stage_Case_Detail__c();
            stage.SFDC_Action_code__c = SFDC_Action_Code;
            stage.Batch_Status__c = 'LEGACY';
            //stage.Case_DocumentID__c = Text_Util.getDocumentId(cc.Parent.DocumentID__c, cc.Parent.CaseNumber, cc.Parent.RecordType.Name);
            stage.Case_Comments__c = line;
            //stage.Detail_Type__c = System.Label.Detail_Type_BasicLine;
            stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
            stage.Line_Number__c = String.valueOf(lineNumber++);
            stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
            stage.Origination_Type__c = 'TechlineNew';
            
            if ( cc.Parent.Case_External_Id__c != null ) {
            
               stage.Incident_Number__c = cc.Parent.Case_External_Id__c;
             } else {
               stage.Incident_Number__c = cc.Parent.CaseNumber;
             }
           
           // stage.Incident_Number__c  = cc.Parent.CaseNumber;
            stage.Successful__c = null;
            stage.User_Defined_Text_1__c = Text_Util.getFormattedDateTime(cc.CreatedDate) + 
                                           Text_Util.getFormattedTime(cc.CreatedDate);
            stage.Comment_Id__c = cc.Id;
            stageList.add(stage);
        }
        
        return stageList;
    }


   public static List<String> splitStringFixed(String toSplit, Integer lineLength) {
            // Initialize variables
            List<String> newLines = new List<String>();
            String singleLine;
    
            if (toSplit != null) {
                // Split the input String on the newline character
                List<String> lines = toSplit.split('\n');
        
                // For each portion of the full String after being split by newlines, create
                // a String for each group of LINE_LENGTH characters.  If the
                // String is very long, it will be split into many comment lines.  If it is
                // less than LINE_LENGTH in size, it will be put into a single comment line.  
                for(String line: lines) {
                    // Handle splitting while the line is still longer than LINE_LENGTH,
                    // removing the split characters from the line each time through the loop
                    // to shorten it.
                    while (line.length() > lineLength) {
                        singleLine = line.substring(0, lineLength);
                        newLines.add(singleLine);
                        line = line.substring(lineLength);
                    }
                    
                    // Handle the last portion of the line which is now under LINE_LENGTH in size.
                    singleLine = line;
                    newLines.add(singleLine);
                }
            }        
            return newLines;
        }



    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){

    }
}