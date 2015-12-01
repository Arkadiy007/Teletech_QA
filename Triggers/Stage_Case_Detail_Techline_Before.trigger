/**********************************************************************
Name:Stage_Case_Detail_Techline_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This trigger loads Techline specific Stage_Case_Detail table data into CaseComment table.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 12/17/2011 Created
1.1 - Bryan Fry 03/08/2011 Converted from Batch job to Trigger
***********************************************************************/
trigger Stage_Case_Detail_Techline_Before on Stage_Case_Detail__c (before update) {
    CaseComment newCaseComment;
    List<CaseComment> lstCaseCommentInsert = new List<CaseComment>();       
    List<Stage_Case_Detail__c> stages = new List<Stage_Case_Detail__c>();
    Map<Integer, Stage_Case_Detail__c> CaseDtlStagingInsMap = new Map<Integer, Stage_Case_Detail__c>();
    integer ins=0;
    List<String> incidentNumbers = new List<String>();
    List<Case> cases;
    Map<String, Case> incidentMap = new Map<String,Case>();
    List<Error_Log__c> errors = new List<Error_Log__c>();
    
    for (Stage_Case_Detail__c stage : Trigger.new) {
    	if (stage.Origination_Source__c == 'Informatica' && stage.Origination_Type__c == 'Techline')
        	incidentNumbers.add('Techline_' + stage.Incident_Number__c);
    }
    
    cases = [Select Id, Incident_Number__c From Case Where Case_External_Id__c in :incidentNumbers and RecordType.Name = 'Tech Line'];
    
    for (Case oneCase: cases) {
        incidentMap.put(oneCase.Incident_Number__c, oneCase);
    }
      
    for (Stage_Case_Detail__c stage : Trigger.new)
    {
        try {
        	if (stage.Origination_Source__c == 'Informatica' && stage.Origination_Type__c == 'Techline') {
	            newCaseComment = new CaseComment();       
	            if (stage.SFDC_Action_Code__c == 'A')
	            {
	                newCaseComment.CommentBody = stage.Incident_Comment_Date__c + ': ' + stage.Case_Comments__c;
	                newCaseComment.ParentId = (incidentMap.get(stage.Incident_Number__c)).Id;
	                  
	                lstCaseCommentInsert.add(newCaseComment); 
	                CaseDtlStagingInsMap.put(ins,stage);   
	                ins++;
	             }
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

    // If any errors were returned, add them to the Error_Log table.
    if (!errors.isEmpty()) {
        // Insert rows
        Database.SaveResult[] dbResults = Database.insert(errors, false);
    }
}