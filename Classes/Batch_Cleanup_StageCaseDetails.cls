/**********************************************************************
Name: Batch_Cleanup_StageCaseDetails (deletes old stagecasedetails)
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 2/14/2013 Created
***********************************************************************/
global class Batch_Cleanup_StageCaseDetails implements Database.Batchable<sObject> {
    private final Integer thisDaysBackLbound;
    private final Integer thisDaysBackUbound;
    private final DateTime endDate;
    private final DateTime startDate;
    
    global Batch_Cleanup_StageCaseDetails() {
        // Get the last run time
        List<Code__c> daysBackList = [select Id, Description__c from Code__c where Type__c = 'Cleanup_Days_Back' and Code__c = 'Cleanup_Stage_Case_Details'];
        String lastRunTimeString = null;
        thisDaysBackLbound = Integer.valueOf(daysBackList[0].Description__c);
        thisDaysBackUbound = thisDaysBackLbound + 5;   // every 5 days
        
        startDate = Date.today().addDays(-thisDaysBackUbound);
        endDate = Date.today().addDays(-thisDaysBackLbound);

        System.debug('Will Taylor: start date: ' + startDate);
        System.debug('Will Taylor: end date: ' + endDate);
        

    }
 
 
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = '';
        
        if (Test.isRunningTest()) {
       
        } else {
           
           WClause = WClause + ' WHERE CreatedDate >= :startDate AND CreatedDate < :endDate ' +
                               ' AND Error_Message__c=\'\' and Batch_Status__c=\'Acknowledged\'';

           
           
           
            //WClause = WClause + ' AND   CreatedBy.Name IN (\'Digesh Shah\',\'Sebastian Rohdenburg\',\'William Taylor\',\'Sarah McCarter\') ';   
            //WClause = WClause + ' AND   Id=\'500Z0000007GtpXIAS\' ';
        }        

        return Database.getQueryLocator('SELECT Id, CreatedDate FROM Stage_Case_Detail__c' + WClause);
    } 

    global void execute(Database.BatchableContext BC, List<Stage_Case_Detail__c> lstDeleteTable) {
      
      
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (lstDeleteTable.size() > 0) {
            Database.DeleteResult[] lstCSIns = Database.delete(lstDeleteTable, false);
            //System.debug('Will Taylor delete: ' + lstDeleteTable);
            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < lstCSIns.size(); x++) {
                    if (lstCSIns[x].isSuccess()) {
                       // System.debug('Will Taylor - Successful DML operation');
                    } else {           
                        Database.Error err = lstCSIns[x].getErrors()[0];    
                         errors.add(new Error_Log__c(
                                    Record_Type__c = 'Case (Techline Cases)', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Cleanup_Stage_Case_Details', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                        System.debug('Will Taylor - FAILED DML operation' + err.getMessage());                        
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

      
      
       
       /*System.debug('Will Taylor - STARTING ------ ');
       
       for (Stage_Case_Detail__c eachDel : lstDeleteTable) {
           
           System.debug('Will Taylor : this delete: ' + eachDel.Id + ' - ' + eachDel.CreatedDate );
       
       }
      */
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
        String[] toAddresses = new String[] {'wrmtyr@gmail.com'};  //a.CreatedBy.Email
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('Cleanup Delete StageCase Details done, ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    
      Code__c DaysBack = [select Id, Description__c from Code__c where Type__c = 'Cleanup_Days_Back' and Code__c = 'Cleanup_Stage_Case_Details'];
        DaysBack.Description__c = String.valueOf(thisDaysBackUbound);
        update DaysBack;


        if (thisDaysBackUbound >= 800) {
            // done 
        } else {
            // continue processing
            Batch_Cleanup_StageCaseDetails batchd = new Batch_Cleanup_StageCaseDetails();
            Database.executeBatch(batchd);
        }
    
    
    
    }

    
}