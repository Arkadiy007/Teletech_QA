trigger Code_BeforeDelete on Code__c (before delete)  { 
	List<Code__c> undeletableCodes = new List<Code__c>();
	for (Code__c code: Trigger.old) {
		if(code.Type__c.equals('Major Component Code') || code.Type__c.equals('TREAD Code')){
			List<CaseCategory_Dependency__c> dependencies = [SELECT Id FROM CaseCategory_Dependency__c WHERE Major_Component_Code__c=:code.Code__c];
			if(dependencies.size() > 0){
				undeletableCodes.add(code);
			}
		}
	}

	if(undeletableCodes.size() > 0){
		for(Code__c code : undeletableCodes){
			code.addError('The Code cannot be deleted because it has Case Category Dependency.');
		}
	}
}