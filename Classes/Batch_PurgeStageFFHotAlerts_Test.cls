/**********************************************************************
Name: Batch_PurgeStageFFHotAlerts_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_PurgeStageFFHotAlerts.cls.
 
======================================================
History: 

VERSION AUTHOR       DATE       DETAIL
1.0 - Vivek Batham   07/29/2015 Created 
***********************************************************************/
@isTest(seeAllData = false)
private class Batch_PurgeStageFFHotAlerts_Test {
    
    private static Stage_FF_Hot_Alerts__c alert;
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testmethod void testDeletionofHotAlerts() {
        alert =TestData_Utils.CreateAlertInstance('Service', 'Nissan Service');        
        alert.CreatedDate = Date.today().addDays(-31);        
        insert alert;
        
        Test.startTest();
        Batch_PurgeStageFFHotAlerts batch = new Batch_PurgeStageFFHotAlerts();
        Database.executeBatch(batch);
        Test.stopTest();
        
        System.assert([Select Id from Stage_FF_Hot_Alerts__c where Id =: alert.Id].size() <= 0);
        
    }
    
    static testMethod void testScheduleJob(){
        
        Test.startTest();
        String jobId = System.schedule('Schedule_Batch_PurgeStageFFHotAlerts',
                        CRON_EXP,
                        new Batch_PurgeStageFFHotAlerts());
                        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
    
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
    
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    
    }
    
    
}