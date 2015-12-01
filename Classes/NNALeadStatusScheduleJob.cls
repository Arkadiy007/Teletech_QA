global class NNALeadStatusScheduleJob implements  Database.Batchable<SObject>, Database.Stateful,
  Database.AllowsCallouts, Schedulable {

  //--------------------------------------------------------------------------
  // Constants
	private final static String SCHEDULE_JOB_NAME = 'Dealer to lead Case status update.';
	private final static Integer BATCH_SIZE = 50;
	private final static Integer DELAY_MINUTES = 60*12;

  //--------------------------------------------------------------------------
  // Methods

	/** Schedulable method */
	global void execute(SchedulableContext sc) {
		final String jobId = String.valueOf(sc.getTriggerId());
		System.abortJob(jobId);

		// start batch
		if (!IsBatchRunning()) {
			Database.executeBatch(new NNALeadStatusScheduleJob(), BATCH_SIZE);
		}

		// run new job
		final DateTime d = DateTime.now().addMinutes(DELAY_MINUTES);

		System.schedule(
			SCHEDULE_JOB_NAME,
			d.format('ss mm HH dd MM ? yyyy'),
			new NNALeadStatusScheduleJob()
		);
	}


  /** Database.Batchable method */
  public Database.QueryLocator start(Database.BatchableContext context) {


		return Database.getQueryLocator(
			[SELECT Id, Case_GUID__c, Case_Dealer_Disposition__c 
		     FROM Case 
		  	WHERE Case_Dealer_Disposition__c = 'RECEIVED'
							AND Case_GUID__c != null]
							//AND Last_Call_to_USWS__c < :System.now().addMinutes(-30)]
		); 
  }
  
  /** Database.Batchable method */
  public void execute(Database.BatchableContext context, SObject[] scope) {
		Case[] casesToUpdate = new Case[] {};

		for (Case cs : (Case[]) scope) {
			try {
				// make callout and change Case_Dealer_Disposition__c
				NNALeadServicesHandler.LeadApprovalResponse resp = NNALeadServicesHandler.callLeadSoapService(cs.Case_GUID__c);

				// update case staus
				cs.Case_Dealer_Disposition__c = resp.ResponseCode;
				cs.Case_Dealer_Disposition_Information__c = resp.ResponceDetail;

				casesToUpdate.add(cs);
			} catch (Exception ex) {
			}
		}

		if (!casesToUpdate.isEmpty()) {
			update casesToUpdate;
		}
  }
      
  /** Database.Batchable method */
  public void finish(Database.BatchableContext context) {
  }

  //--------------------------------------------------------------------------
  // Helpers
	global static void RunScheduleJob() {
		// Is the job already running?
		CronTrigger[] jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
													FROM CronTrigger WHERE CronJobDetail.Name = :SCHEDULE_JOB_NAME];

		if (jobs.size() > 0 && jobs[0].state != 'COMPLETED'
					&& jobs[0].state != 'ERROR' && jobs[0].state != 'DELETED') {
			if (IsBatchRunning()) return; // The batch is running

			// If we-re going to run soon, exit
			if (DateTime.now().addMinutes(DELAY_MINUTES) > jobs[0].NextFireTime) return;
		}

		// If the job exists, it needs to be deleted
		if (jobs.size() > 0) {
			System.abortJob(jobs[0].Id);
		}

		try {
			final DateTime d = DateTime.now().addMinutes(Integer.valueOf(1));

			System.schedule(
				SCHEDULE_JOB_NAME,
				d.format('ss mm HH dd MM ? yyyy'),
				new NNALeadStatusScheduleJob()
			);
		} catch(Exception e) {
		}
	}

	// It's already running - Is the batch running?
	private static Boolean IsBatchRunning() {
		Set<String> activeJobStates = 
			new Set<String> {'Queued', 'Processing', 'Preparing'};

		List<AsyncApexJob> apexJobs = [SELECT Id, ApexClass.Name
																	   FROM AsyncApexJob
																   	WHERE ApexClass.Name = 'NNALeadStatusScheduleJob'
																					AND Status IN :activeJobStates
																					AND JobType = 'BatchApex'];

		if (apexJobs.size() > 0) return true; // The batch is running

		return false;
	}
}