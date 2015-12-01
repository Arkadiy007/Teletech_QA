/**********************************************************************
Name: ErrorLogDelete
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class deletes all Error_Log__c entries older than
a set number of days, defaulting to 7. 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry		05/09/2011 Created
***********************************************************************/
global class ErrorLogDelete implements Database.Batchable<sObject>
{
	global String query = 'SELECT Id FROM error_log__c WHERE createddate < LAST_N_DAYS:';

	global ErrorLogDelete() {
		String days = System.Label.Error_Log_Keep_Days;
		if (days == null || days.length() == 0) {
			days = '7';
		}
		query = query + days;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> errorLogs){
		delete errorLogs;
	}

	global void finish(Database.BatchableContext BC){
	}
}