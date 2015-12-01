global class IdlePIRNotificationBatchJob implements Database.Batchable<SObject> {
	
	String query = 'SELECT Id, Customer_Name__c, Name, Plant__c, Supplier_Code__c, Supplier_Name__c, Part_Name__c, Part_Number__c, Current_Owner__c, Reason_For_Defect__c, Reason_For_Status__c, Part__c, Part__r.Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c, Customer__c FROM Part_Incident_Report__c';
    global Datetime timeLimit {get; set;}

	global IdlePIRNotificationBatchJob() {
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
   	global void execute(Database.BatchableContext context, List<Part_Incident_Report__c> scope) {
		List<Part_Incident_Report__c> scopeToUpdate = new List<Part_Incident_Report__c>();
		for (Part_Incident_Report__c pir : scope){
			if (pir.Last_Modified_By_Supplier__c == null || (pir.Last_Modified_By_Supplier__c != null && pir.Current_Owner__c == 'Customer')){
				EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Idle Supplier', 'Supplier');
			}
			else{
				EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Idle Customer', 'Customer');
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
		query += ' WHERE PIR_Status__c != \'Closed\' AND (Last_Modified_By_Supplier__c = null OR ';

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