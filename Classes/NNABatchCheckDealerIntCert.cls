/**********************************************************************
  Name: NNABatchCheckDealerIntCert
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Batch Job, that makes dealer Internet Certified if <isDealerContactable>true</isDealerContactable> - from callout

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 06/12/2015 Created
 ***********************************************************************/
global class NNABatchCheckDealerIntCert implements Database.Batchable<SObject>, Database.AllowsCallouts {
	
	private String query {get; set;}

	global NNABatchCheckDealerIntCert() {
		String recordTypeId = '\'' +  RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer') + '\'';
		query = 'SELECT Id, Name, Internet_Certified__c, Dealer_Code__c FROM Account WHERE Dealer_Inactive_Indicator__c = false AND RecordTypeId = ' + recordTypeId;
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
   	global void execute(Database.BatchableContext context, List<Account> scope) {
		List<Account> accsToUpdate = new List<Account>();
		for(Account a : scope){
			if(NNAGetDealerByIdService.isDealerContactable(a.Dealer_Code__c)){
				a.Internet_Certified__c = true;
			}
			else{
				a.Internet_Certified__c = false;
			}

			accsToUpdate.add(a);
		}

		if(!accsToUpdate.isEmpty()){
			update accsToUpdate;
		}
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}