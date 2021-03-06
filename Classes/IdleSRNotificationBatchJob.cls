global class IdleSRNotificationBatchJob implements Database.Batchable<SObject> {
    
	
   String query = 'SELECT Id, Current_Owner__c, Customer_Name__c, Plant__c, Supplier_Code__c, Supplier_Name__c, Part_Number__c, Part_Name__c, Reason_for_Status__c, Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c, Customer__c, Part__c FROM Sorting_Report__c';
	global Datetime timeLimit {get; set;}

	global IdleSRNotificationBatchJob() {
		prepareQuery();
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
	global void execute(Database.BatchableContext context, List<Sorting_Report__c> scope) {
		List<Sorting_Report__c> scopeToUpdate = new List<Sorting_Report__c>();
		for (Sorting_Report__c sr : scope){
			System.debug(sr);
			if (sr.Last_Modified_By_Supplier__c == null || (sr.Last_Modified_By_Supplier__c != null && sr.Current_Owner__c == 'Customer')){
				EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For Idle Supplier', 'Supplier');
			}
			else{
				EmailNotificationHelper.sendNotification(sr, 'SR Notification For Idle Customer', 'Customer');
			}
		}

		        EmailNotificationHelper.sendEmails();
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}


	private void prepareQuery(){	
		query += ' WHERE Status__c != \'Closed\' AND (Last_Modified_By_Supplier__c = null OR ';

		Integer hoursOffset = getHoursOffset();
		timeLimit = System.now().addHours(-hoursOffset);

		query += '(Last_Modified_By_Supplier__c <= :timeLimit OR Last_Modified_By_Customer__c <= :timeLimit))';
	}

	private Integer getNotificationSettingsValue(){
		if (EQA_Notification_Settings__c.getOrgDefaults() == null || EQA_Notification_Settings__c.getOrgDefaults().Hours_To_Send_Idle_Notification__c == null){
			return 48;
		}
		else{
			return (Integer) EQA_Notification_Settings__c.getOrgDefaults().Hours_To_Send_Idle_Notification__c;
		}
	}

	private Integer getHoursOffset(){
		Integer returnValue = getNotificationSettingsValue();

		if (HolidayCalculator.DayOfWeek(Date.today()) == 0){
			returnValue += 48;
		}
		else if(HolidayCalculator.DayOfWeek(Date.today()) == 6){
			returnValue += 24;
		}

		return returnValue;
	}
}