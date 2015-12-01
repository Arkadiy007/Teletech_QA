@isTest
                                
private class TestSchedule_VCSCaseStaging_DataLoad {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
   
      Id RTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'VCS Support'); 
      Case testCase = new Case(RecordTypeId = RTypeId, TCU_Activation_Status__c = true, Status = 'Open', CreatedDate = Date.newInstance(2014,10,10));
      insert testCase;
        
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new Schedule_VCSCaseStaging_WithDuration());
         
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
      // Verify the scheduled job hasn't run yet.
      Stage_Case__c[] stl = [Select Id from Stage_Case__c Where CreatedDate = TODAY];
      System.assertEquals(stl.size(),0);
      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new Stage Case that got added.
      stl = [Select Id from Stage_Case__c Where CreatedDate = TODAY];
     // System.assertEquals(stl.size() > 0, true); 

   }
}