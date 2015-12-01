/**********************************************************************
  Name: Maritz_DeleteExtractedObjects_Job
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Scheduled Job, that executes Maritz_DeleteExtractedObjects_BatchJob, that are deleting all of the extracted standard activities
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/24/2015 Created
 ***********************************************************************/
global class Maritz_DeleteExtractedObjects_Job implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		  Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 500);
	}
}