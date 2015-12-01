/**********************************************************************
Name: TMSCallCenterMonitor 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Monitoring TMS Call Center Performance
Alert System Administrator about Outbound Message Queue Builup and potensial system failure
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 5/10/2011 Created
***********************************************************************/
public class TMSCallCenterMonitor {
/* to Run anonymously in QA:
	DateTime dtEnd = DateTime.newInstance(2011, 3, 14, 16, 0, 0);
	DateTime dtStart = dtEnd.addHours(-3);
	TMSCallCenterMonitor m = new TMSCallCenterMonitor(dtEnd, dtStart);
	m.ALertResults();
*/
	private DateTime dtEnd, dtStart;
	
	//decimal places for displaying in message
	private final static Integer PERCENTAGE_DECIMALS = 2;

	//giving some time to resolve an ended call.
	private static Integer RESOLVE_TIME_OFFSET;

	//constructor takes 3 parameters, so the time span can be defined in the test method.
	public TMSCallCenterMonitor(DateTime scheduleStartTime, DateTime backTime, Integer timeOffset) {
		RESOLVE_TIME_OFFSET = timeOffset;

		dtEnd = scheduleStartTime;
		dtStart = backTime;
	}

	//email set up
    private void sendErrorEmail(String errMessage) {
		// Setup email options for email to send
		Messaging.reserveSingleEmailCapacity(1);    
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {System.label.TMS_CallCenter_Altert_Email}; 
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(System.label.TMS_CallCenter_Altert_Email);
		mail.setSenderDisplayName('TMS CallCenter Monitor');
		mail.setSubject('TMS CallCenter Performance Alert');
		mail.setPlainTextBody(errMessage);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	private void createErrorEntry(String errMessage) {
		Error_Log__c l = new Error_Log__c(TimeStamp__c = System.Now(), 
				Source__c = 'Salesforce', 
				Operation_Name__c = 'TMSCallCenterMonitor', 
				Log_Type__c = 'Error', 
				Log_Level__c = 4, 
				Error_Message__c = errMessage);
		insert l;
	}

	//analyzing the performance for the last hour
	public void ALertResults() {
		//time span text used for error message
		String hourRange = ' for the hour of ' + dtStart.format('h:mm a') + ' to ' + dtEnd.format('h:mm a') + '.';
		
		//Note the following 2 SOQLs for Task and Call_Resolution__c tables: assumign RESOLVE_TIME_OFFSET = 5
		//we retrieve 1:05 hour Call resolution records from trigger time
		//but retrieve exact 1 hour tasks record but 5 minutes off from trigget time. 
		//we gave call resolution table 5 minutes to ensure resolving all the tasks
		DateTime offsetStartTime = dtStart.addMinutes(RESOLVE_TIME_OFFSET);
		DateTime offsetEndTime = dtEnd.addMinutes(RESOLVE_TIME_OFFSET);

		//calls to Call_Resolution__c to get for the last hour ResolutionId__c set, created counts and failed counts
		Integer crCount = 0, failedCRCount = 0;
		Set<String> allCRs = new Set<String>();
		for (List<Call_Resolution__c> lstCalls : [Select Status__c, ResolutionId__c 
									From Call_Resolution__c
									where CreatedDate >: offsetStartTime and CreatedDate <=: dtEnd
									order by ResolutionId__c Asc, CreatedDate Desc]) {
			for (Call_Resolution__c c : lstCalls) {
				crCount++;

				if (c.Status__c != 'Success')
					failedCRCount++;

				if (!allCRs.contains(c.ResolutionId__c))
					allCRs.add(c.ResolutionId__c);
			}
		}

		//calls to Task to get for the last hour created count, started count, ended count, missing task from call_resolution__c count 
		Integer taskCount = 0, statredTaskCount = 0, endedTaskCount = 0, missingTaskCount = 0;
		for (List<Task> allTasks : [Select Call_End_Time__c, Call_Start_Time__c, Service_Marketing_Call_ID__c 
									From Task 
									where Service_Marketing_Call_ID__c <> NULL and 
										Subject like 'Reservation%' and 
										CreatedDate >: offsetStartTime and 
										CreatedDate <=: offsetEndTime
									Order by Service_Marketing_Call_ID__c Asc, CreatedDate Desc ]) {
			for (Task t : allTasks) {
				taskCount ++;

				if (t.Call_Start_Time__c != null)
					statredTaskCount++;

				if (t.Call_End_Time__c != null) {
					endedTaskCount++;

					if (!allCRs.contains(t.Service_Marketing_Call_ID__c))
						missingTaskCount++;
				}
			}
		}

		/*
		Description:  If the number of tasks created during dialing hours is less than 500 per hour alert managed services.  
			Service Marketing generally makes 2,000 calls an hour. If there are less than 500 tasks being written to the DB 
			in 1hr this would signify a possible problem with the SFDC DB or the CTI Adapter 
		Solution: Query the task table if there are greater than 50 tasks created in the last hour but less than 500 alert
			 managed services.  We could do this via hours of operation, but this would be much more difficult and not scalable.  
		*/
		if (taskCount >= 50 && taskCount < Integer.valueOf(System.Label.TMS_CC_Threshold_Low_Number_Calls)) {
			String errMessage = 'Possible problem with the SFDC DB or the CTI Adapter: only ' + 
				taskCount + ' Salesforce Tasks were created' + 
				hourRange + ' Average number of calls per hour is ' + System.Label.TMS_CC_Average_Calls_per_Hour + '.';
			createErrorEntry(errMessage);
			sendErrorEmail(errMessage);
		}

		/*
		Description: If greater than 20% of the tasks that have a call start time are missing call end time alert managed services.  
			This could signify a universal failure with the CTI adapter  
		Solution:  Query task table for all tasks with a call start time and compare number with call end time to those without and send alert 
		*/
		if (statredTaskCount > 0) {
			Decimal incompleteTasksPercentage = ((1-(Decimal)endedTaskCount/statredTaskCount)*100.00).setScale (PERCENTAGE_DECIMALS, System.RoundingMode.HALF_UP);//round % to 2 decimals
			if (incompleteTasksPercentage >= Decimal.valueOf(System.Label.TMS_CC_Threshold_High_Number_Incomplete_Calls)) {
				String errMessage = 'Possible universal failure with the CTI adapter: ' + 
					incompleteTasksPercentage + '% Salesforce started Tasks did not end (' + statredTaskCount + ' started, ' + endedTaskCount + ' ended)' + hourRange + 
					' Alert Threshold is ' + System.Label.TMS_CC_Threshold_High_Number_Incomplete_Calls + '%.';
				createErrorEntry(errMessage);
				sendErrorEmail(errMessage);
			}
		}

		/*
		Description: If the number of outbound messages sent is 10% higher than the number of results received.  
			This will ensure that if Cast Iron is running slowly and not writing results back to SFDC that managed services is alerted quickly
		Solution:  Query the Task table with record type TMS and the Call resolution table and 
			compare the size of the two tables if they reach a point where there is a 10% variance alert Managed Services 
		*/
		if (endedTaskCount > 0) {
			Decimal missPercentage = ((Decimal)missingTaskCount/endedTaskCount*100.00).setScale (PERCENTAGE_DECIMALS, System.RoundingMode.HALF_UP);//round % to 2 decimals
			if (missPercentage > Decimal.valueOf(System.Label.TMS_CC_Threshold_OBM_BuildUp)) {
				String errMessage = 'Possible SF outbound message buildup: ' + 
					missPercentage + '% Salesforce Tasks are missing from Call Resolution table (' + endedTaskCount + ' outbound messages sent, ' + missingTaskCount + ' NOT resolved)' + hourRange + 
					' Alert Threshold is ' + System.Label.TMS_CC_Threshold_OBM_BuildUp + '%.';
				createErrorEntry(errMessage);
				sendErrorEmail(errMessage);
			}
		}
		
		/*
		Description:  If the percentage of failed results received from Cast Iron reaches greater than 5% alert managed services.  
			This will let managed services know if there is a consistent problem rather than 1 off errors: 
		Solution:  Query that Call resolution table and compare total count vs. error percentage 
		*/
		if (crCount > 0) {
			Decimal failedCRPercentage = ((Decimal)failedCRCount/crCount*100.00).setScale (PERCENTAGE_DECIMALS, System.RoundingMode.HALF_UP);//round % to 2 decimals
			if (failedCRPercentage >= Decimal.valueOf(System.Label.TMS_CC_Threshold_High_Number_Failed_Calls)) { 
				String errMessage = 'Possible problem with Cast Iron: ' + 
					failedCRPercentage + '% failed results were received from Cast Iron(' + crCount + ' called, ' + failedCRCount + ' failed)' + hourRange + 
					' Alert Threshold is ' + System.Label.TMS_CC_Threshold_High_Number_Failed_Calls + '%.';
				createErrorEntry(errMessage);
				sendErrorEmail(errMessage);
			}
		}
	}

	static testmethod void TestTMSCallCenterMonitor() {
		DateTime dtNow = System.Now(), dtHourBack = dtNow.addHours(-1);
		
		List<Task> toCreate = new List<Task>();
		//20 tasks: callresid 0 - 19, start time, no end time
		for (Integer i = 0; i < 20; i++) {
			dtHourBack = dtHourBack.addSeconds(1);
			Task a = new Task(Subject = 'ReservationCall ' + i, Call_Start_Time__c = dtHourBack, Service_Marketing_Call_ID__c = String.valueOf(i));
			toCreate.add(a);
		}
		
		//40 tasks: callresid 20 - 59, start time and end time. 
		//expecting 33% incomplete calls;
		for (Integer i = 20; i < 60; i++) {
			dtHourBack = dtHourBack.addSeconds(1);
			Task a = new Task(Subject = 'ReservationCall ' + i, Call_Start_Time__c = dtHourBack, Call_End_Time__c = dtHourBack.addSeconds(3), Service_Marketing_Call_ID__c = String.valueOf(i));
			toCreate.add(a);
		}
		insert toCreate;
		
		//20 callres: callresid 0 - 19, status success
		List<Call_Resolution__c> croCreate = new List<Call_Resolution__c>();
		for (Integer i = 0; i < 20; i++) {
			dtHourBack = dtHourBack.addSeconds(1);
			Call_Resolution__c a = new Call_Resolution__c(ResolutionId__c = String.valueOf(i), Status__c = 'Success');
			croCreate.add(a);
		}
		
		//20 callres: callresid 20 - 39, status failed
		//expecting 50% failed calls;
		//50% OBM buildup (20 of 40 ended calls have not reached call res table)
		for (Integer i = 20; i < 40; i++) {
			dtHourBack = dtHourBack.addSeconds(1);
			Call_Resolution__c a = new Call_Resolution__c(ResolutionId__c = String.valueOf(i), Status__c = 'Failed');
			croCreate.add(a);
		}
		insert croCreate;
		
		DateTime createdDate = [Select CreatedDate From Call_Resolution__c Where ID in :croCreate][19].CreatedDate;
		System.Debug('Last one created at ' + createdDate);

		Test.startTest();
	
		System.Debug('Call TMSCallCenterMonitor (' + createdDate.addSeconds(2) + ', ' + createdDate.addSeconds(-3) + ')');

		TMSCallCenterMonitor m = new TMSCallCenterMonitor(createdDate.addSeconds(2), createdDate.addSeconds(-3), 0);
		DateTime ALertTime = System.Now();
		m.ALertResults();

		for (Error_Log__c l : [Select Error_Message__c 
								From Error_Log__c 
								WHERE Source__c = 'Salesforce' and 
									Operation_Name__c = 'TMSCallCenterMonitor' and 
									Log_Type__c = 'Error' and 
									Log_Level__c = 4 and 
									TimeStamp__c >=: ALertTime]) {
			if (l.Error_Message__c.startsWith('Possible problem with the SFDC DB or the CTI Adapter')) {
				System.debug(l.Error_Message__c);
			}
			if (l.Error_Message__c.startsWith('Possible universal failure')) {
				System.debug(l.Error_Message__c);
			}
			if (l.Error_Message__c.startsWith('Possible SF outbound message buildup')) {
				System.debug(l.Error_Message__c);
			}
			if (l.Error_Message__c.startsWith('Possible problem with Cast Iron')) {
				System.debug(l.Error_Message__c);
			}
		}

		Test.stopTest();
	}
}