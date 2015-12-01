trigger ContactAfter on Contact (after insert, after update, after delete)  {
	if(Trigger.isInsert || Trigger.isUpdate){
		ContactHelper.removeDuplicatePrimaryContactsForAccount(Trigger.new);
	}
}