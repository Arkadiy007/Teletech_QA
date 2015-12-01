/**********************************************************************
Name: Schedule_CreateCalls
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules jobs to create calls for VCS and LEAF cases:
Batch_VCSCase_CreateCall
Batch_LEAFCase_CreateCall
======================================================
History:

VERSION AUTHOR DATE DETAIL

1.0 - Bryan Fry     05/29/2013 Initial creation
***********************************************************************/
global class Schedule_CreateCalls implements Schedulable {
	global void execute(SchedulableContext SC) {
		Batch_VCSCase_CreateCall vcsCaseJob = new Batch_VCSCase_CreateCall();
		Database.executeBatch(vcsCaseJob);

		Batch_LEAFCase_CreateCall leafCaseJob = new Batch_LEAFCase_CreateCall();
		Database.executeBatch(leafCaseJob);
	}

    @isTest
    static void Schedule_CreateCalls_Test() {
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 0 1 1 ? 2020';
        
        Test.startTest();
		
        // Schedule a test job
        String testJobId = System.schedule('testScheduleCreateCalls', cronExpression, new Schedule_CreateCalls());
		
        Test.stopTest();
		
        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 00:00:00', String.valueOf(ct.NextFireTime));
   	}
}