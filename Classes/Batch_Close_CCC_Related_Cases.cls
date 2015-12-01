/**********************************************************************
Name: Batch_Close_CCC_Related_Cases
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class closes CCC-related record types 90 days after
creation.  The record types included are 'CCC', 'Lease Loyalty', 
'Retail Loyalty', 'Customer Connection Follow Up',
'Sales & Service Record Type', 'Pre-Sell'.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry         10/03/2013 Initial Creation
***********************************************************************/
global class Batch_Close_CCC_Related_Cases implements Database.Batchable<sObject> {
    
    // String of query for all creatable fields on Case
    global String query;
   
    public static String getQuery() {
        return 'SELECT Id, Status,Lease_Maturity_Date__c ,RecordType.Name FROM Case where RecordTypeId in (\'012F0000000yAbxIAE\',\'012A0000000xekoIAA\', \'012F0000000yAwvIAE\', \'012F0000000yBMoIAM\', \'012F0000000yCgMIAU\', \'012F0000000yD8QIAU\') and status != \'Closed\' and createddate < LAST_90_DAYS';
    }
// 012F0000000yAbxIAE   removed this recordtype 
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();

        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned: Set the status of all
    // Cases to Closed.
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {
    
        List<Error_Log__c> errors = new List<Error_Log__c>();

        // Loop through all Cases returned.
        for (Case c : lstCaseTable)  {
            if (c.RecordType.Name == 'Lease Loyalty') {
               if (c.Lease_Maturity_Date__c < System.now()) {
                   c.Status = 'Closed';
               }
            } else {
                c.Status = 'Closed';
            }
        }

        // Update rows
        Database.SaveResult[] results = Database.update(lstCaseTable, false);

        // If there are any results, handle the errors
        if (!results.isEmpty()) 
        {
            // Loop through results returned
            for (integer row = 0; row < lstCaseTable.size(); row++)
            {
                // If the current row was not sucessful, handle the error.
                if (!results[row].isSuccess())
                {
                    // Get the error for this row and add it to a list of Error_Log rows.
                    Database.Error err = results[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = lstCaseTable[row].Id,
                                Record_Type__c = 'Case', 
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_Close_CCC_Related_Cases', 
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                }
            }
        }

        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    
    }
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}