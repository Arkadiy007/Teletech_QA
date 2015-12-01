trigger Monetary_Claim on Monetary_Claim__c (after insert, after update, after delete, before insert, before update, before delete) {
    
	if(Trigger.isBefore && Trigger.isInsert){
		for(Monetary_Claim__c monClaim : Trigger.New){
			monClaim.Name = monClaim.Monetary_Claim_Number__c;
			monClaim.Last_Modified_By_Customer__c = System.now();
		}
	}

	if(Trigger.isUpdate && Trigger.isAfter){
			NotificationsHelper.createNotifications(Trigger.newMap, Trigger.oldMap);
    }

	if(Trigger.isUpdate && Trigger.isBefore){
		Map<Id, Monetary_Claim__c> oldMap = new Map<Id, Monetary_Claim__c>();
		Map<Id, Monetary_Claim__c> newMap = new Map<Id, Monetary_Claim__c>();
		for(Monetary_Claim__c mc : Trigger.New){
			Monetary_Claim__c oldMc = Trigger.oldMap.get(mc.Id);
			if(mc.Claim_Status__c == 'Closed'){
				mc.Closed_Date__c = Date.today();
			}
			//Re-open Count
			else if(oldMc.Claim_Status__c == 'Closed'){
				if(mc.Reopen_Count__c == null){
					mc.Reopen_Count__c = 0;
				}
				mc.Reopen_Count__c++;
			}

			if (mc.OwnerId != oldMc.OwnerId || true == mc.Save_And_Send_Flag__c) {
				oldMap.put(mc.Id, oldMc);
				newMap.put(mc.Id, mc);
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