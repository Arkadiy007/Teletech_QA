/**********************************************************************
Name: TMSCallCenterAlertServices
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Schedule TMSCallCenterMonitor job
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 5/10/2011 Created
***********************************************************************/
global class TMSCallCenterAlertServices implements Schedulable {
	/*
	to start the schedule, run this in Execute Anonymous
		System.schedule(TMSCallCenterAlertServices.M_F_CRON_NAME, TMSCallCenterAlertServices.M_F_CRON_EXP, new TMSCallCenterAlertServices());
		System.schedule(TMSCallCenterAlertServices.S_CRON_NAME, TMSCallCenterAlertServices.S_CRON_EXP, new TMSCallCenterAlertServices());
	*/

	// This test runs a scheduled job at midnight Sept. 3rd. 2022
	public static String M_F_CRON_EXP = '0 0 14-20/1 ? * 2-6 *';
	public static String M_F_CRON_NAME = 'TMS-CC M-F 2pm-8pm Performance';
	
	public static String S_CRON_EXP = '0 30 10-18/1 ? * 7 *';
	public static String S_CRON_NAME = 'TMS-CC S 10:30am-6:30pm Performance';
	
	global void execute(SchedulableContext SC) {
		DateTime startTime = System.now();
		DateTime lastHour = startTime.addHours(-1);
		TMSCallCenterMonitor m = new TMSCallCenterMonitor(startTime, lastHour, Integer.valueOf(System.Label.TMS_CC_Resolve_Time_Offset_m) * -1);
		m.ALertResults();
	}

	static testmethod void test() {
		Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('testTMSCallCenterAlertServices', TMSCallCenterAlertServices.M_F_CRON_EXP, new TMSCallCenterAlertServices());
		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same
		System.assertEquals(TMSCallCenterAlertServices.M_F_CRON_EXP, ct.CronExpression);
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		// Verify the next time the job will run
		System.debug(ct.NextFireTime);
		Test.stopTest();
	}
}