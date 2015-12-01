trigger recordMergeTrigger on MergeRelationships__c (after insert) {
	Set<ID> ids = new Set<ID>();
	for(MergeRelationships__c a: Trigger.new){
		ids.add(a.id);
		
	}
	Merger.MergeRecords(ids);
	
	
	
	
	
	

}