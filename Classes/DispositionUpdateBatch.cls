/**********************************************************************
  Name: DispositionUpdateBatch
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose
  Batch job, which will update dispositons.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 02/05/2015 Created
  2.0 - Vlad Martynenko 03/13/2015 Dev done
 ***********************************************************************/
global class DispositionUpdateBatch implements Database.Batchable <sObject > {

	global DispositionUpdateBatch() {
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		//1.	Selects all event and task records which fall into defined criteria
		Id ServiceMarketingRecordTypeId = [SELECT Id FROM RecordType WHERE Name = :'Service marketing' AND sObjectType = :'Task'].Id;
		Date d = Date.today().addDays(- 1);
		String query = 'SELECT ID, OwnerId, Call_End_Time__c, TMS_Disposition__c, Dialer_Disposition__c, CallDisposition__c, Call_Centre_Id__c, Customer_Experience__c, CallDurationInSeconds, Call_Recording_ID__c';
		query = query + ' FROM Task WHERE RecordTypeID = :ServiceMarketingRecordTypeId AND (CallDisposition__c = NULL OR CallDisposition__c = \'\') AND Dialer_Disposition__c = NULL';
		query = query + ' AND (TMS_Disposition__c = null OR TMS_Disposition__c = \'\') AND (NOT Subject LIKE \'%Inbound%\') AND (CallType != \'Internal\' OR CallType != \'Inbound\')';
		query = query + ' AND (CallDurationInSeconds = 0 OR CallDurationInSeconds = null) AND CreatedDate >= :d';

		return Database.getQueryLocator(query);
	}

	// Empty finish method
	global void finish(Database.BatchableContext BC) {
	}

	global void execute(Database.BatchableContext BC, List <Task > tasks) {
		try {
			//2.	Selects all Users (Id,Call_Centre_Id__c) that are linked to activities via Assigned field. 
			//5.	Creates Map<Id,DateTime>. For each activity record, adds its Id and Call_End_Time_c.
			Map <Id, DateTime > callEndTimes = new Map <Id, DateTime > ();
			Map <Id, User > tasksMap = new Map <Id, User > ();
			Set<ID> ownerIds = new Set<ID> ();

			for (Task taskItem : tasks) {
				callEndTimes.put(taskItem.Id, taskItem.Call_End_Time__c);

				//6.	Clears Call_End_Time_c for all activity records and performs update on them.
				taskItem.Call_End_Time__c = null;
				ownerIds.add(taskItem.OwnerId);
			}

			//update tasks;
			Map <ID, User > users = new Map <Id, User > ([SELECT Id, Call_Centre_Id__c FROM User WHERE Id IN :ownerIds]);
			System.debug(users);

			//3.	Selects custom label User_Role_Check_Enabled.
			//4.	Updates User_Role_Check_Enabled value to NO
			//System.Label.USER_ROLE_CHECK_ENABLED = 'NO';
			User_Role_Check_Enabled__c userRoleCusomSetting = User_Role_Check_Enabled__c.getOrgDefaults();
			userRoleCusomSetting.Is_User_Validation_Enabled__c = true;
			update userRoleCusomSetting;

			for (Task task : tasks) {
				if (users.containsKey(task.OwnerId)) {
					tasksMap.put(task.Id, users.get(task.OwnerId));
				}
			}


			//7.	Sets defined fields for each activity record and performs update on them
			for (Task taskItem : tasks) {
				if (tasksMap.get(taskItem.id) != null) {
					taskItem.TMS_Disposition__c = '10';
					taskItem.Dialer_Disposition__c = 9;
					taskItem.CallDisposition__c = 'No Answer (7 Rings)';
					taskItem.Call_Centre_Id__c = tasksMap.get(taskItem.id).Call_Centre_Id__c;
					taskItem.Customer_Experience__c = '8 None of the above';
					taskItem.CallDurationInSeconds = 0;
					taskItem.Call_Recording_ID__c = '0';
				}
			}
			//update tasks;
			//8.	Using previously created map sets Call_End_Time_c values for each activity record. In case when datetime value is null, sets it as datetime.now().
			for (Task taskItem : tasks) {
				if (callEndTimes.get(taskItem.Id) != null) {
					taskItem.Call_End_Time__c = callEndTimes.get(taskItem.Id);
				} else {
					taskItem.Call_End_Time__c = DateTime.now();
				}
			}
			//9.	Performs update on activity records.
			update tasks;
			//10.	Updates User_Role_Check_Enable value to YES. 
			userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
			update userRoleCusomSetting;
		}
		catch(Exception ex) {
			User_Role_Check_Enabled__c userRoleCusomSetting = User_Role_Check_Enabled__c.getOrgDefaults();
			userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
			update userRoleCusomSetting;
		}
	}
}