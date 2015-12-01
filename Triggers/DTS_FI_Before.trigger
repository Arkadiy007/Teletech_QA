trigger DTS_FI_Before on DTS_Field_Inspection__c(before insert, after update, before update) {
	
	if(Trigger.isInsert && Trigger.isBefore){
		DTS_FI_Helper.handleBeforeInsert(Trigger.new);
	}
	
	if(Trigger.isBefore && Trigger.isUpdate){
		DTS_FI_Helper.handleBeforeUpdate(Trigger.new);
	}
	
    if(Trigger.isAfter && Trigger.isUpdate){
        DTS_FI_Helper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
     
}