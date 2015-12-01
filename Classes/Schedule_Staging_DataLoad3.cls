/**********************************************************************
Name: Schedule_Staging_DataLoad3
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 5am MT:
System.schedule('Staging DataLoad - Late', '0 0 5 * * ?', new Schedule_Staging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 03/15/2012 Created
***********************************************************************/
global class Schedule_Staging_DataLoad3 implements Schedulable {
	global void execute(SchedulableContext SC) {
		/* INBOUND */
		// Techline Comments
	/*	Batch_Techline_CaseComment_DataLoad techlineCaseCommentDataLoad = new Batch_Techline_CaseComment_DataLoad();
		Database.executeBatch(techlineCaseCommentDataLoad);
		// SAP CheckRequests
		Batch_CheckRequest_DataLoad checkRequestDataLoad = new Batch_CheckRequest_DataLoad();
		Database.executeBatch(checkRequestDataLoad);*/
		// SMM
		Batch_Buyback_DataLoad buybackDataLoad = new Batch_Buyback_DataLoad();
		Database.executeBatch(buybackDataLoad);
	}
}