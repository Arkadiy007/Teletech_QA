/**********************************************************************
  Name: NNAScheduledCheckDealerIntCert
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Scheduled Job, that start NNABatchCheckDealerIntCert that makes dealer Internet Certified if <isDealerContactable>true</isDealerContactable> - from callout

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 06/12/2015 Created
 ***********************************************************************/
global class NNAScheduledCheckDealerIntCert implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new NNABatchCheckDealerIntCert(), 90);
	}
}