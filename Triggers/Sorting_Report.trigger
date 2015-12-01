trigger Sorting_Report on Sorting_Report__c(before insert, before update, before delete, after insert, after update, after delete) {
	if (Trigger.isBefore && Trigger.isInsert) {
		for (Sorting_Report__c sortReport : Trigger.New) {
			sortReport.Name = sortReport.Sorting_Report_Number__c;
			sortReport.Last_Modified_By_Customer__c = System.now();
		}
	}

	if (Trigger.isUpdate && Trigger.isAfter) {
		NotificationsHelper.createNotifications(Trigger.newMap, Trigger.oldMap);
	}

	if (Trigger.isUpdate && Trigger.isBefore) {
		Map<Id, Sorting_Report__c> oldMap = new Map<Id, Sorting_Report__c>();
		Map<Id, Sorting_Report__c> newMap = new Map<Id, Sorting_Report__c>();
		for (Sorting_Report__c sr : Trigger.New) {
			Sorting_Report__c oldSr = Trigger.oldMap.get(sr.Id);
			if (sr.Status__c == 'Closed') {
				sr.Closed_Date__c = Date.today();
			}
			else if (oldSr.Status__c == 'Closed') {
				if (sr.Reopen_Count__c == null) {
					sr.Reopen_Count__c = 0;
				}
				sr.Reopen_Count__c++;
			}

			if (sr.OwnerId != oldSr.OwnerId || true == sr.Save_And_Send_Flag__c) {
				oldMap.put(sr.Id, oldSr);
				newMap.put(sr.Id, sr);
			}
		}
		EmailNotificationHelper.populateLastModifiedFields(Trigger.newMap, Trigger.oldMap);
		EmailNotificationHelper.sendNotifications(newMap, oldMap);
		EmailNotificationHelper.sendEmails();
	}
	
	if(Trigger.isUpdate && Trigger.isAfter) {
	  ShareHelper.share(Trigger.new);
	}
}