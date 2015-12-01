/**********************************************************************
Name: TestSchedule_DeleteOldCases_Dataload 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Schedule_DeleteOldCases_Dataload.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestSchedule_DeleteOldCases_Dataload {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void Schedule_DeleteOldCases_Dataload_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 0 1 1 ? 2020';
        
        Test.startTest();

        // Schedule a test job
        String testJobId = System.schedule('testSchedule_DeleteOldCases_Dataload', cronExpression, new Schedule_DeleteOldCases_Dataload());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 00:00:00', String.valueOf(ct.NextFireTime));
    }
   
 }