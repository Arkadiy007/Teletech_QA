public class ContactHelper{
	public static void removeDuplicatePrimaryContactsForAccount(List<Contact> triggerNew){
		Set<Id> accountIds = getAccountIds(triggerNew);
		Map<Id, Boolean> contactsByAccountId = getContactsByAccount(accountIds, triggerNew);

		for(Contact c : triggerNew){
			if(contactsByAccountId.containsKey(c.AccountId) && c.EQA_Records_Owner__c){
				System.debug(contactsByAccountId.get(c.AccountId));
				if (contactsByAccountId.get(c.AccountId)){
					c.addError('EQA Owner already exists');
				}
			}
		}
	}

	public static Set<Id> getAccountIds(List<Contact> triggerNew){
		Set<Id> accountIds = new Set<Id>();

		for(Contact c : triggerNew){
			accountIds.add(c.AccountId);
		}

		return accountIds;
	}

	public static Map<Id, Boolean> getContactsByAccount(Set<Id> accountIds, List<Contact> triggerNew){
		Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
		
		for(Contact c : [SELECT Id, AccountId, EQA_Records_Owner__c FROM Contact WHERE AccountId IN :accountIds AND Id NOT IN :triggerNew]){
			if(contactsByAccountId.containsKey(c.AccountId)){
				contactsByAccountId.get(c.AccountId).add(c);
			}
			else{
				contactsByAccountId.put(c.AccountId, new List<Contact>());
				contactsByAccountId.get(c.AccountId).add(c);
			}
		}
		Map<Id, Boolean> primaryContactAvailableForAccId = new Map<Id, Boolean>();

		for (Id AccountId : contactsByAccountId.keySet()){
			Boolean primaryContactAvailable = false;

			for(Contact c : contactsByAccountId.get(AccountId)){
				if(c.EQA_Records_Owner__c){
					primaryContactAvailable = true;
				}
			}

			primaryContactAvailableForAccId.put(AccountId, primaryContactAvailable);
		}
	System.debug(primaryContactAvailableForAccId);
		return primaryContactAvailableForAccId;
	}
}