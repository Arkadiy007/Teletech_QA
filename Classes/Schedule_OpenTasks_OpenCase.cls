/**********************************************************************
Name: Schedule_OpenTasks_OpenCase
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules batch Open Tasks for Open Case to run:
Batch_OpenTasks_OpenCase
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 02/20/2011 Created
1.1 - Bryan Fry     05/03/2013 Added VCSCase_CreateCall batch job to combine similar nightly tasks
1.2 - Bryan Fry     05/21/2013 Added LEAFCase_CreateCall batch job to combine similar nightly tasks
1.3 - Bryan Fry     05/29/2013 Removed CreateCall jobs.
***********************************************************************/
global class Schedule_OpenTasks_OpenCase implements Schedulable {
	global void execute(SchedulableContext SC) {
		Batch_OpenTasks_OpenCase batchJob = new Batch_OpenTasks_OpenCase();
		Database.executeBatch(batchJob);
	}
	
    static testmethod void Schedule_OpenTasks_OpenCase_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 0 1 1 ? 2020';
        
        Test.startTest();
		
        // Schedule a test job
        String testJobId = System.schedule('testScheduleOpenTasksOpenCase', cronExpression, new Schedule_OpenTasks_OpenCase());
		
        Test.stopTest();
		
        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 00:00:00', String.valueOf(ct.NextFireTime));
   	}
}