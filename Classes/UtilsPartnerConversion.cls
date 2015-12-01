/**********************************************************************
Name: UtilsPartnerConversion
Copyright © notice: Nissan Motor Company
======================================================
Purpose:

Parner conversion script. Fronted by UtilsPartnerConversion visualforce page.
Look for "NOTE:" to check out SOQL that can be adjusted to decide:

- which Accounts to process
- which Contacts from each Account above to enable for Partner Portal
- which profile to use for the Contacts
   
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Grant Liu 12/1/2011 Created
***********************************************************************/
public with sharing class UtilsPartnerConversion {
	private static final String ACCOUNTIDS_PARAM = 'partnerIDs';
	private static final Boolean partnerEnabled = Schema.SobjectType.Account.fields.getMap().get('isPartner') != null;
    
    public Boolean getPartnerEnabled() {
    	return partnerEnabled;
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
            	/***************************
            	 *NOTE: Accounts to process is decided here. One can change this to only active dealers, etc.
                 ***************************/
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      'SELECT Id, Name FROM Account '+ 
					  'WHERE isDeleted = false AND isPersonAccount = false '+
					  'LIMIT 10000'));
            }
            return setCon;
        }
        set;
    }

    public List<Account> getAccounts() {
    	 if(getPartnerEnabled()) {
	         return (List<Account>) setCon.getRecords();
    	 }
    	 return new List<Account>();
    }

	private Map<Id, Account> buildAccountMap() {
		return new Map<Id, Account>(getAccounts());
	}
    
    public void partnerfy() {
		String accountIDs = ApexPages.currentPage().getParameters().get(ACCOUNTIDS_PARAM);
		if(accountIDs != null && accountIDs.trim() != '') {
			Set<String> accountIDSet = splitTrimAdd(accountIDs);
			Map<Id, Account> processMe = new Map<Id, Account>();
			Map<Id, Account> accountMap = buildAccountMap();
			for(String accountid : accountIDSet) {
				Account currAcct = accountMap.get(accountid);
				if(currAcct == null) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad Account Selected, could not process ID:' + accountid));
				} else {
					processMe.put(currAcct.Id, currAcct);
				}
			}
			createPartners(processMe);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No work to do'));			
		}	
    }
	
	private static final Map<String, Schema.SobjectField> fieldMap = Schema.SobjectType.User.fields.getMap();
	/* Create some partner accounts/users */
	public static void createPartners(Map<Id, Account> accounts) {
		Savepoint sp = Database.setSavepoint();

		String partnerfiedAccountStr = '';
		String partnerfiedContactStr = '';

    	/***************************
		 *NOTE: The partner profile to assign to each user is decided here.
         ***************************/
		/* Fetch correct profile id. System comes with a default Partner User, we can clone the default one to control access to correct KAVs */
		List<Profile> profile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%Partner User' LIMIT 1];

		for(Account partnerAccount : accounts.values()) {
			partnerAccount.put('isPartner', true);
			partnerfiedAccountStr += partnerfiedAccountStr == '' ? partnerAccount.Id + ':' + partnerAccount.Name : ', ' + partnerAccount.Id + ':' + partnerAccount.Name;
			System.debug('**********Account to partnerfy Added to List:' + partnerAccount);
		}
		upsert accounts.values();
		
		/* Map Account ID to list of Contacts */
		Map<Id, List<Contact>> accountIdToContactMap = new Map<Id, List<Contact>>();
    	/***************************
		 *NOTE: The contacts to enable for partner access from an account are selected here. One can change this to only select service managers, for ex.
         ***************************/
		List<Contact> contacts = [SELECT Id, AccountId, FirstName, LastName, Email, Name FROM Contact WHERE AccountId IN: accounts.keySet()];
		for(Contact contact : contacts) {
			List<Contact> currContacts = accountIdToContactMap.get(contact.AccountId);
			if(currContacts == null) {
				currContacts = new List<Contact>();
				accountIdToContactMap.put(contact.AccountId, currContacts);
			}
			currContacts.add(contact);
		}
					
		List<User> newPartners = new List<User>();

		/* For each account, go through contacts and create users. */ 
		for(Account partnerAccount : accounts.values()) {
			List<Contact> currContacts = accountIdToContactMap.get(partnerAccount.Id);
			if(currContacts != null && !currContacts.isEmpty()) {
				for(Contact currContact : currContacts) {
					Integer usernameLen = fieldMap.get('Username').getDescribe().getLength();
					String username = currContact.Email == null || currContact.Email.trim() == '' ? 
						trimToLength(trimmedNonNullStr(currContact.FirstName) + trimmedNonNullStr(currContact.LastName), (usernameLen/2) - 1) + '@' + trimToLength(trimmedNonNullStr(partnerAccount.Name), (usernameLen/2) - 4) + '.com' : 
						trimToLength(trimmedNonNullStr(currContact.Email), usernameLen);
					//There is a bug here: currContact must have an email. if currContact does not have any email, error: user email is required. 
					System.debug('**********username:' + username);
					List<User> puser = (List<User>) [SELECT Id, isActive FROM User 
													 WHERE (isActive = true AND Username =: username) 
													 OR (isActive = false AND Username =: '_' + username) LIMIT 1];
					if(puser == null || puser.isEmpty()) {
						/* For each account, only the first partner portal user enabled in the UI will trigger creation of
						   three roles: Executive, Manager, and Worker. Fetch correct role id based on PortalAccountId. Won't exist if we don't use UI? */
						//List<UserRole> role = [SELECT Id From UserRole WHERE PortalRole = 'Worker' AND PortalType = 'Partner' AND PortalAccountId =: partnerAccount.Id LIMIT 1];
						//agent.UserRoleId = role[0].Id - if we don't set this, we actually get these automatically created and the 'worker' one assigned. Coolio.

						
						User partUser = new User(FirstName = trimToLength(trimmedNonNullStr(currContact.FirstName), fieldMap.get('FirstName').getDescribe().getLength()), 
												 LastName = trimToLength(trimmedNonNullStr(currContact.LastName), fieldMap.get('LastName').getDescribe().getLength()), 
												 Username = username, 
												 Email = trimToLength(trimmedNonNullStr(currContact.Email), fieldMap.get('Email').getDescribe().getLength()),
												 Alias = trimToLength(trimmedNonNullStr(currContact.FirstName) + trimmedNonNullStr(currContact.LastName), fieldMap.get('Alias').getDescribe().getLength()), 
												 CommunityNickname = trimToLength(trimmedNonNullStr(currContact.FirstName) + trimmedNonNullStr(currContact.LastName), fieldMap.get('CommunityNickname').getDescribe().getLength()),
												 ProfileId = profile[0].Id, 
												 ContactId = currContact.Id,
												 TimeZoneSidKey = 'America/Los_Angeles', 
												 EmailEncodingKey = 'ISO-8859-1', 
												 LanguageLocaleKey = 'en_US', 
												 LocaleSidKey = 'en_US');
						newPartners.add(partUser);
						partnerfiedContactStr += partnerfiedContactStr == '' ? currContact.Id + ':' + currContact.Name : ', ' + currContact.Id + ':' + currContact.Name;
						System.debug('**********Partner User to create added to List:' + partUser);
						//agent.IsPortalEnabled = true; is actually not writeable. Triggered by other fields.
						//agent.AccountId = partnerAccount.Id is set by contactID
						//agent.UserType = 'PowerPartner'; is actually not writeable. Triggered by other fields.	
						//agent.PortalRole = 'Worker'; Doesn't seem required
					} else {
						System.debug('**********Partner User exists - no DML for updates on Users:' + puser[0]);							
					}
				}
			}
		}
		
		try{
			insert newPartners;
		} catch(System.DMLException e) {
			outputDMLExceptionUserMessages(e);
 			Database.rollback(sp);
 			return;
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '--------------Number of Partnerfied Accounts: ' + accounts.size()));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '--------------Number of Partner Users Created: ' + newPartners.size()));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '--------------Partnerfied Accounts: ' + partnerfiedAccountStr));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '--------------Contacts converted to Partner Users: ' + partnerfiedContactStr));
	}

	    
	/* Use this in execute Anonymous to disable all partner accounts
	private static void resetAccounts() {
		Map<Id, Account> accounts = new Map<Id, Account>((List<Account>)Database.query('SELECT Id, Name FROM Account WHERE isPartner = true'));
		for(Account partnerAccount : accounts.values()) {
			partnerAccount.put('isPartner', false);
		}
		upsert accounts.values();	
	} */
	
	/* UTILITIES */
	private static void outputDMLExceptionUserMessages(System.DMLException e) {
		outputDMLExceptionUserMessages(null,e);
	}
	
	private static void outputDMLExceptionUserMessages(String messageBeforeExc, System.DMLException e) {
		if(messageBeforeExc != null && messageBeforeExc != ''){
			messageBeforeExc += ': ';
		}else{
			messageBeforeExc = '';
		}
		
		for (Integer i = 0; i < e.getNumDml(); i++) {
			//There was some code doing this, remove it once if we decide the OOB error message
			//is sufficient	
			if(e.getDmlType(0) == StatusCode.ENTITY_IS_DELETED) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
					messageBeforeExc + ' Object Deleted'));
			} else {
				//If we want to dig deeper: String[] fieldNames = e.getDmlFieldNames(i);				
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
	            	messageBeforeExc + e.getDmlMessage(i)));				
			}
		}
	}
    
    /* Split a comma delimited string, trim each element, add (if non empty) to a return set. */
	private static Set<String> splitTrimAdd(String delimStr) {
		return splitAdd(delimStr, false);
	}
	private static Set<String> splitAdd(String delimStr, Boolean upper) {
		System.debug(LoggingLevel.DEBUG, '@splitAdd delimStr: ' + delimStr);		
		Set<String> elemSet = new Set<String>();
		if (delimStr != null && delimStr.length() > 0) {
			List<String> elemList = delimStr.split(',');
			for (String elem : elemList) {
				String elemTrim = elem.trim();
				if (elemTrim.length() > 0) {
					elemSet.add(upper? elemTrim.toUpperCase() : elemTrim);
				}
			}
		}
		System.debug(LoggingLevel.DEBUG, '@splitAdd elemSet: ' + elemSet);		
		return elemSet;		
	}
	
	private static String trimmedNonNullStr(String makeMeWhole){
		return makeMeWhole == null ? '' : makeMeWhole.trim();
    }
    	
    private static String trimToLength(String trimMe, Integer length){
    	if (trimMe != null && trimMe.length() >= length) {
    		return trimMe.substring(0, length);
    	}
    	return (trimMe == null ? '' : trimMe.replaceAll('\\s','').trim());  
    }
        
	/* UNIT TESTS */
    private static testMethod void testUtilsPartnerConversion() {
        RecordType dealerTypeRT = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];

		UtilsPartnerConversion ctrl = new UtilsPartnerConversion();
		ctrl.partnerfy();
		
		Account acct;
		List<Account> accts = ctrl.getAccounts(); 	//[SELECT Id FROM Account WHERE name = 'SCTESTACCOUNT' and RecordTypeID =: dealerTypeRT.Id
													//					   LIMIT 1];
		if (!accts.isEmpty()) { 
			acct = accts[0]; 
		} else { 
			acct = new Account(Name = 'SCTESTACCOUNT', RecordTypeID = dealerTypeRT.Id); 
			insert acct; 
		} 
		Contact cont;
		List<Contact> cList = [SELECT Id FROM Contact WHERE Name = 'SCTEST CONTACT'
							   AND Email = 'SCTESTCONTACT@test.com' LIMIT 1];
		if (!cList.isEmpty()) {
			cont = cList[0]; 
			cont.AccountId = acct.Id;
		} else { 
			cont = new Contact(FirstName = 'SCTEST', LastName = 'CONTACT', 
							   Email = 'SCTESTCONTACT@test.com', AccountId = acct.Id); 
		} 
		upsert cont;
		
		ApexPages.currentPage().getParameters().put(ACCOUNTIDS_PARAM, acct.Id);
		ctrl.partnerfy();
    }
	
    private static testMethod void testSCUtilsDML() {
		try {
			update new Case();
		} catch(System.DMLException e) {
	    	outputDMLExceptionUserMessages(e);
    	}
    }

    private static testMethod void testSplitTrimAdd() {
    	String testString = ' test1,test2  ,test3 ';
    	Set<String> testStrings = splitTrimAdd(testString);
    	System.assertEquals(3, testStrings.size());
    	System.assert(testStrings.contains('test1'));
    	System.assert(testStrings.contains('test2'));
    	System.assert(testStrings.contains('test3'));
    }    
}