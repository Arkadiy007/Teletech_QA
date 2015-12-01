/**********************************************************************
Name: Account_LeadMigration_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "Account_Before_LeadMigration"
and "Account_After_LeadMigration" Triggers.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry		05/03/2011 Created
***********************************************************************/

@isTest
private class ErrorLogDelete_Test {
	static final String TEST_MESSAGE = 'Error 12345678987654321';
	
	static void testErrorLogDeleteData() {
		List<Error_Log__c> errorLogs = new List<Error_Log__c>();
		Error_Log__c errorLog;
		for (Integer i = 0; i < 200; i++) {
			errorLog = new Error_Log__c();
			errorLog.Log_Type__c = 'Error';
			errorLog.Log_Level__c = 1;
			errorLog.Operation_Name__c = TEST_MESSAGE + i;
			errorLogs.add(errorLog);
		}
		
		insert errorLogs;
	}
	
	static testmethod void testErrorLogDelete() {
		testErrorLogDeleteData();
		
		String errorMessageSearch = '\'' + TEST_MESSAGE + '%\'';
		
        // Start the test, this changes governor limit context to that of trigger rather than test.     
        Test.startTest();
        
        // Insert the Dealer Quotes Request records that cause the trigger to execute.
        ErrorLogDelete eld = new ErrorLogDelete();
        eld.query = 'SELECT Id FROM error_log__c WHERE Operation_Name__c like ' + errorMessageSearch;
        ID batchprocessid = Database.executeBatch(eld);
        
        // Stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        //System.Assert that we got rid of all the TEST_ERROR_MESSAGE ones
        System.AssertEquals(database.countquery('SELECT count() FROM error_log__c WHERE Operation_Name__c like ' + errorMessageSearch), 0);  
	}
	
	static testmethod void testScheduledErrorLogDelete() {
		// Schedule a test job at midnight on Jan 1, 2020.
		String cronExpression = '0 0 0 1 1 ? 2020';
		
   		Test.startTest();

   		// Schedule a test job
      	String testJobId = System.schedule('testScheduledErrorLogDelete', cronExpression, new ScheduledErrorLogDelete());

   		Test.stopTest();

   		// Get the information from the CronTrigger API object  
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
		
   		// Verify the job is as expected
    	System.assertEquals(cronExpression,ct.CronExpression);
		System.assertEquals(ct.TimesTriggered, 0);
      	System.assertEquals('2020-01-01 00:00:00', String.valueOf(ct.NextFireTime));
   }
}