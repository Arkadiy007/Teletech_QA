//https://170.65.129.72/TSOCasesManualRunToken
//Delete [Select ID From Case Where Record_Number__C <> NULL limit 10000];
trigger Case_Before_Batch on Case (before update) {
	if (System.label.TurnOnDataFix == 'Yes' || Test.isRunningTest()) {
		Id caseCARTId = '012F0000000y9y7IAA';
		Id caseCAClosedRTId = '012F0000000yCuEIAU';

		Set<ID> accountIDs = new Set<ID>();
    	List<String> dealerCodes = new List<String>();
    	Map<ID, Account> accounts;
		List<Case> cases = new List<Case>();
		
		for(Case c : Trigger.new) {
			if (c.RecordTypeId == caseCARTId || c.RecordTypeId == caseCAClosedRTId) {
				cases.add(c);
				
				if (c.Service_Dealer_Number__c != null && c.Service_Dealer_Number__c != '' && c.Servicing_Dealer__c == null)
					dealerCodes.add(c.Service_Dealer_Number__c);
				
				if (c.ContactId == null && c.AccountId != null)
					accountIDs.add(c.AccountId);
			}
		}
		
		if (accountIDs.size() > 0)
			accounts = new Map<ID, Account>([Select ID, PersonContactId From Account Where RecordType.Name =: System.label.AccRTMaritz and ID in: accountIDs]);
		
		Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
		
		for(Case c : cases) {
			if (c.Service_Dealer_Number__c != null && c.Service_Dealer_Number__c != '' && c.Servicing_Dealer__c == null) {
				if (dealerMap.containsKey(c.Service_Dealer_Number__c)) {
					c.Servicing_Dealer__c = dealerMap.get(c.Service_Dealer_Number__c);
					c.Stage_Status__c = System.label.Stage_Status_None;
				}
			}
			
			if (c.ContactId == null && c.AccountId != null) {
				if (accounts.containsKey(c.AccountId)) {
					c.ContactId = accounts.get(c.AccountId).PersonContactId;
					c.Stage_Status__c = System.label.Stage_Status_None;
				}
			}
			
			if (c.Channel_Designation_Code__c == 'I') {
				c.Channel_Designation_Code__c = 'Infiniti';
				c.Stage_Status__c = System.label.Stage_Status_None;
			} else if (c.Channel_Designation_Code__c == 'N') {
				c.Channel_Designation_Code__c = 'Nissan';
				c.Stage_Status__c = System.label.Stage_Status_None;
			}
		}
	}
}