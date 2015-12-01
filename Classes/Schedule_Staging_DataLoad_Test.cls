/**********************************************************************
Name: Schedule_Staging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class tests the Schedule_Staging_DataLoad class.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     02/22/2011 Created
***********************************************************************/

@isTest(SeeAllData=true)
private class Schedule_Staging_DataLoad_Test {
    
   

    static testmethod void Schedule_CategoryStaging_DataLoad_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 1 1 1 ? 2020';
        
        Test.startTest();

        // Schedule a test job
        String testJobId = System.schedule('testScheduleCategoryStagingDataLoad', cronExpression, new Schedule_CategoryStaging_DataLoad());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 01:00:00', String.valueOf(ct.NextFireTime));
    }
           
    static testmethod void Schedule_Staging_DataLoad2_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 4 1 1 ? 2020';
        
        Test.startTest();

        // Schedule a test job
        String testJobId = System.schedule('testScheduleStagingDataLoad2', cronExpression, new Schedule_Staging_DataLoad2());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 04:00:00', String.valueOf(ct.NextFireTime));
   }

    static testmethod void Schedule_Staging_DataLoad3_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 5 1 1 ? 2020';
        
        Test.startTest();

        // Schedule a test job
        String testJobId = System.schedule('testScheduleStagingDataLoad3', cronExpression, new Schedule_Staging_DataLoad3());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 05:00:00', String.valueOf(ct.NextFireTime));
   }
}