/**********************************************************************
  Name: Maritz_DeleteExtractedObjects_BatchJob
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Batch Job, that are deleting all of the extracted standard activities on execution
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/24/2015 Created
 ***********************************************************************/
 global class Maritz_DeleteExtractedObjects_BatchJob implements Database.Batchable<SObject> {
	
	private String query {get; Set;}

	global Maritz_DeleteExtractedObjects_BatchJob() {
		query = 'SELECT Id FROM Stage_Maritz_Backfeed_Object__c WHERE Backfeed_Type__c = \'Standard Activity\' AND Batch_Status__c = \'Extracted\'';
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(query);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Stage_Maritz_Backfeed_Object__c> scope) {
		if (!scope.isEmpty()){
			delete scope;
		}
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}