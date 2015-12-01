/**********************************************************************
Name: BuyBack_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Upon creating a new Buyback record, need to update the related Case to populate the "Buyback" field with the Buyback ID.

======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli FIntescu 09/20/2011 Created
1.1 - Yuli FIntescu 02/24/2012 Task Creation when VPP Claim # is populated
***********************************************************************/
trigger BuyBack_After on Buyback__c (after insert, after update, after delete, after undelete) {
	
	BuybackHelper helper = new BuybackHelper();
	
	if(Trigger.isAfter && Trigger.isInsert){
		helper.handleAfterInsert(Trigger.new);
	}
	if(Trigger.isAfter && Trigger.isUpdate){
		helper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
	}
	if(Trigger.isAfter && Trigger.isDelete){
		helper.handleAfterDelete(Trigger.old);
	}
	if(Trigger.isAfter && Trigger.isUndelete){
		helper.handleAfterUnDelete(Trigger.new);
	}	

}