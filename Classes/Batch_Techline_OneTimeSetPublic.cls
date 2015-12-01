/**********************************************************************
Name: Batch_Techline_OneTimeSetPublic (set onetime public)
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 2/14/2013 Created
***********************************************************************/
global class Batch_Techline_OneTimeSetPublic implements Database.Batchable<sObject> {
    private final Integer thisDaysBackLbound;
    private final Integer thisDaysBackUbound;
    private final DateTime endDate;
    private final DateTime startDate;
    
    global Batch_Techline_OneTimeSetPublic() {

    }
 
 
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = '';
        if (Test.isRunningTest()) {
        } else {
           WClause = WClause + '  WHERE Parent.RecordTypeId=\'012F0000000yFmQ\' and IsPublished=false ';
        }        
        return Database.getQueryLocator('select id from CaseComment ' + WClause);
    } 

    global void execute(Database.BatchableContext BC, List<CaseComment> lstCaseCommentTable) {
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (lstCaseCommentTable.size() > 0) {
            for (CaseComment cc : lstCaseCommentTable) {
                cc.isPublished = true;
            }
        
            Database.SaveResult[] lstCSIns = Database.update(lstCaseCommentTable, false);

            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < lstCSIns.size(); x++) {
                    if (lstCSIns[x].isSuccess()) {
                     
                    } else {           
                        Database.Error err = lstCSIns[x].getErrors()[0];    
                        errors.add(new Error_Log__c(
                                    Record_Type__c = 'Case Comment', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_New_OneTimeSetPublic', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                        System.debug('FAILED DML operation' + err.getMessage());                        
                    }
                     
    
                }
            }
        
        } else {
              
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