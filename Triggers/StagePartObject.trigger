trigger StagePartObject on Stage_Part_Object__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(Trigger.isBefore && Trigger.isInsert){
		StagePartObjectHelper.buildParts(Trigger.new);
	}
}