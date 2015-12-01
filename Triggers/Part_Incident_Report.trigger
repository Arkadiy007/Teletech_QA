trigger Part_Incident_Report on Part_Incident_Report__c (after insert, after update, after delete, before insert, before update, before delete)  {
	if(Trigger.isBefore && Trigger.isInsert){
		for(Part_Incident_Report__c part : Trigger.New){
			part.Name = part.PIR_Number__c;
			part.Last_Modified_By_Customer__c = System.now();
		}
	}

	if(Trigger.isUpdate && Trigger.isAfter){
		NotificationsHelper.createNotifications(Trigger.newMap, Trigger.oldMap);	
	}

	
	if(Trigger.isUpdate && Trigger.isBefore){
		Map<Id, Part_Incident_Report__c> oldMap = new Map<Id, Part_Incident_Report__c>();
		Map<Id, Part_Incident_Report__c> newMap = new Map<Id, Part_Incident_Report__c>();
		for(Part_Incident_Report__c part : Trigger.New){
			Part_Incident_Report__c oldPart = Trigger.oldMap.get(part.Id);
			if(part.PIR_Status__c == 'Closed'){
				part.Closed_Date__c = Date.today();
			}

			if (part.OwnerId != oldPart.OwnerId || true == part.Save_And_Send_Flag__c) {
				oldMap.put(part.Id, oldPart);
				newMap.put(part.Id, part);
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