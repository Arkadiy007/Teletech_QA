/**********************************************************************
Name: Schedule_Staging_DataLoad2
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 1am MT:
System.schedule('Staging DataLoad - Mid', '0 0 1 * * ?', new Schedule_Staging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 03/15/2012 Created
***********************************************************************/
global class Schedule_Staging_DataLoad2 implements Schedulable {
	global void execute(SchedulableContext SC) {
		/* INBOUND */
		// T5 Cases
		Batch_T5_Case_DataLoad t5CaseDataLoad = new Batch_T5_Case_DataLoad();
		Database.executeBatch(t5CaseDataLoad);
		// Techline Cases
		Batch_Techline_Case_DataLoad techlineCaseDataLoad = new Batch_Techline_Case_DataLoad();
		Database.executeBatch(techlineCaseDataLoad);
		// CCG Cases
		Batch_CCG_Case_DataLoad ccgCaseDataLoad = new Batch_CCG_Case_DataLoad();
		Database.executeBatch(ccgCaseDataLoad);
		
	}
}