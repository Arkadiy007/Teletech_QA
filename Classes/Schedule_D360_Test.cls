@isTest
public class Schedule_D360_Test{
    static testmethod void Test1() {
    
        Test.startTest();
   
        String CRON_EXP = '0 0 * * * ?';
        
        // Schedule the test job

      String jobId = System.schedule('testD360BatchSchedule',
      CRON_EXP, 
         new Schedule_D360_Summary());
   
   // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

   // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

   // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

  Test.stopTest();
        
        
    
    
    }
}