public class UserClass {
    public static final String nissanSalesServiceProfileId = '00eF0000000eGA7IAM';
    public static final String nissanPartsProfileId = '00eF0000000eGA6IAM';
    public static final String infinitiSalesServiceProfileId = '00eF0000000eHPUIA2';
    public static final String infinitiPartsProfileId = '00eF0000000eHPZIA2';

    //Async method, using @future, to create User records and associate it to the previously created Contact
    //This uses @future because you can not have mixed DML operations for standard objects (Account, Contact) 
    // and Setup objects(User).
    @future public static void createPortalUsers(List<String> firstNames, List<String> lastNames, List<String> phones,
                                                 List<String> mobilePhones, List<String> usernames, List<String> emails,
                                                 List<String> titles, List<String> contactIds, List<String> profileIds,
                                                 List<Boolean> isActives) {
    	List<User> users = new List<User>();
    	User u = null;
    	Integer atIndex = 0;

    	for (Integer count = 0; count < firstNames.size(); count++) {
            u = new User();
	        u.emailencodingkey = 'UTF-8';
	        u.languagelocalekey = 'en_US';
	        u.localesidkey = 'en_US';
	        u.timezonesidkey = 'America/Los_Angeles';
	        u.Cost_Center__c = 'Partner Portal';
	        u.Location__c = 'Other / Remote';
	        atIndex = usernames[count].indexOf('@');
	        u.Alias = usernames[count].substring(0,5) + usernames[count].substring(atIndex-3, atIndex);
	        u.FirstName = firstNames[count];
	        u.LastName = lastNames[count];
	        u.Phone = phones[count];
	        u.MobilePhone = mobilePhones[count];
	        u.Username = usernames[count];
	        u.Email = emails[count];
	        u.Title = titles[count];
	        u.ContactId = contactIds[count];
	        u.ProfileId = profileIds[count];
	        u.IsActive = isActives[count];

	        users.add(u);
    	}

        if (!users.isEmpty())
        {   
            Database.SaveResult[] results = Database.insert(users, false);

            if (!results.isEmpty()) {
                for (integer row = 0; row < users.size(); row++) {
                    if (!results[row].isSuccess()) {
                        Database.Error err = results[row].getErrors()[0];
                        System.debug('Error inserting user for Contact ' +  users[row].contactId + ', message = ' + err.getMessage());
                    }
                }
            }
        }
    }

    //Async method, using @future, to update User records.
    //This uses @future because you can not have mixed DML operations for standard objects (Account, Contact) 
    // and Setup objects(User).
    @future public static void updatePortalUsers(List<String> userIds, List<String> firstNames, List<String> lastNames,
                                                 List<String> phones, List<String> mobilePhones, List<String> usernames,
                                                 List<String> emails, List<String> titles, List<String> contactIds,
                                                 List<String> profileIds, List<Boolean> isActives) {

    	Map<Id,Integer> userIndexMap = new Map<Id,Integer>();
    	for (Integer count = 0; count < userIds.size(); count++) {
    		userIndexMap.put(userIds[count], count);
    	}
    	
		List<User> users = [select Id
		                    from User
		                    where Id in :userIds];    	
    	
    	for (User u: users) {
            Integer count = userIndexMap.get(u.Id);
	        u.emailencodingkey = 'UTF-8';
	        u.languagelocalekey = 'en_US';
	        u.localesidkey = 'en_US';
	        u.timezonesidkey = 'America/Los_Angeles';
	        u.Cost_Center__c = 'Partner Portal';
	        u.Location__c = 'Other / Remote';
	        u.FirstName = firstNames[count];
	        u.LastName = lastNames[count];
	        u.Phone = phones[count];
	        u.MobilePhone = mobilePhones[count];
	        u.Username = usernames[count];
	        u.Email = emails[count];
	        u.Title = titles[count];
	        u.ProfileId = profileIds[count];
	        u.IsActive = isActives[count];
    	}
    	
        if (!users.isEmpty())
        {   
            Database.SaveResult[] results = Database.update(users, false);

            if (!results.isEmpty()) {
                for (integer row = 0; row < users.size(); row++) {
                    if (!results[row].isSuccess()) {
                        Database.Error err = results[row].getErrors()[0];
                        System.debug('Error updating user with Id ' +  users[row].Id + ', message = ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    /**
     * Check that email address is valid.  If valid, return the email address.  If not
     * valid, return a default email address since the User object requires one.
     */
    public static String checkEmailAddress(String inputEmail) {
    	String validEmail = inputEmail;

    	// Check for not blank, must contain '@' and '.'.
		if (inputEmail == null || inputEmail == '' || !inputEmail.contains('@') || !inputEmail.contains('.')) {
			validEmail = 'default@default.com';
		}

		return validEmail;		
    }
    
    /**
     * Convert SFDC_Partner_Portal_User__c value from NNA dealer portal into a title
     * for Salesforce.
     */
    public static String getSalesforcePartnerTitle(String sfdcPartnerPortalUser) {
    	String title = 'Inactive User';
    	if (sfdcPartnerPortalUser != null) {
    	    if (sfdcPartnerPortalUser == 'Consumer Affairs - Service') {
    	        title = 'Service Manager';
    	    } else if (sfdcPartnerPortalUser == 'Consumer Affairs - Sales') {
    	        title = 'Sales Manager';
    	    } else if (sfdcPartnerPortalUser == 'NNA Case support - Parts') {
    	        title = 'Parts Manager';
    	    } else if (sfdcPartnerPortalUser == 'Consumer Affairs - Other') {
    	        title = 'Dealer User';
    	    }
    	}
    	
    	return title;
    }
    
    /**
     * Determine Partner Portal profile to assign user based on SFDC_Partner_Portal_User
     * and Make_Name__c fields.
     */
    public static String getSalesforcePartnerProfile(String sfdcPartnerPortalUser, String make) {
    	String profileId = nissanSalesServiceProfileId;
    	if (sfdcPartnerPortalUser != null && make != null) {
    	    if (sfdcPartnerPortalUser == 'Consumer Affairs - Service' ||
    	        sfdcPartnerPortalUser == 'Consumer Affairs - Sales' ||
    	        sfdcPartnerPortalUser == 'Consumer Affairs - Other') {
    	        if (make == 'Nissan') {
    	            profileId = nissanSalesServiceProfileId;
    	        } else if (make == 'Infiniti') {
    	            profileId = infinitiSalesServiceProfileId;
    	        }
    	    } else if (sfdcPartnerPortalUser == 'NNA Case support - Parts') {
    	        if (make == 'Nissan') {
    	            profileId = nissanPartsProfileId;
    	        } else if (make == 'Infiniti') {
    	            profileId = infinitiPartsProfileId;
    	        }
    	    }
    	}
    	
    	return profileId;
    }
}