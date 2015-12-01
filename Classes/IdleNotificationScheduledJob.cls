global class IdleNotificationScheduledJob implements Schedulable {
	

	
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new IdlePIRNotificationBatchJob());
		Database.executeBatch(new IdleSRNotificationBatchJob());
		Database.executeBatch(new IdleMCNotificationBatchJob());
	}

}