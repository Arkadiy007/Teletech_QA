public with sharing class CallClass {
    //Async method, using @future, to create User records and associate it to the previously created Contact
    //This uses @future because you can not have mixed DML operations for standard objects (Account, Contact) 
    // and Setup objects(User).
    @future public static void createPortalUsers(List<String> firstNames, List<String> lastNames, List<String> phones,
                                                 List<String> mobilePhones, List<String> usernames, List<String> emails,
                                                 List<String> titles, List<String> contactIds, List<String> profileIds,
                                                 List<Boolean> isActives) {
    	List<User> users = new List<User>();
    	User u = null;
    	for (Integer count = 0; count < firstNames.size(); count++) {
            u = new User();
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
	        u.ContactId = contactIds[count];
	        u.ProfileId = profileIds[count];
	        u.IsActive = isActives[count];
	        
	        users.add(u);
    	}
    	
    	insert users;
    }
}