/**********************************************************************
Name: Schedule_Vehicle_Head_Unit
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Schedule_Vehicle_Head_Unit.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestSchedule_Vehicle_Head_Unit {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
          
       
        Code__c testCode = new Code__c(Type__c = 'Head_Unit', Code__c = '2014_84114', Secondary_Code__c = 'P02', Description__c = '08IT');
        insert testCode;
        
        Vehicle__c testVehicle = new Vehicle__c(Model_Year__c = '2014', Model_Code__c = '84114', Factory_Installed_Options__c = 'P02');
        insert testVehicle;
        
        
          // Schedule the test job
          String jobId = System.schedule('Schedule_Vehicle_Head_UnitTest',
                            CRON_EXP, 
                            new Schedule_Vehicle_Head_Unit());
             
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
    
          // Verify the expressions are the same
          System.assertEquals(CRON_EXP, 
             ct.CronExpression);
    
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
    
          // Verify the next time the job will run
          System.assertEquals('2022-03-15 00:00:00', 
          String.valueOf(ct.NextFireTime));
          
          System.assert([Select Id, Head_Unit__c from Vehicle__c where Id=:testVehicle.Id].Head_Unit__c != null);
   }
   
 }