trigger Stage_User_Before on Stage_User__c (before insert, before update) {
    Id dealerAccountRTId = '012A0000000OfI0IAK';
    RecordType rtSSOContactsrt = [select id from recordtype where name='SSO Contact' limit 1];
    String rtSSOContacts = rtSSOContactsrt.Id;
    List<Stage_User__c> dealerUsers = new List<Stage_User__c>();
    List<Stage_User__c> insertDealerUsers = new List<Stage_User__c>();
    List<String> usernames = new List<String>();
    List<String> dealerExternalIds = new List<String>();
    List<Id> existingContactIds = new List<Id>();
    List<Contact> insertContacts = new List<Contact>();
    List<Contact> updateContacts = new List<Contact>();
    Contact cont = null;
    Account dealer = null;
    Map<String,Contact> userContactsMap = new Map<String,Contact>();
    Map<String,Account> dealerMap = new Map<String,Account>();
        Map<String,Stage_User__c> stageUserMap = new Map<String,Stage_User__c>();
        List<Error_Log__c> errors = new List<Error_Log__c>();

    List<String> insertFirstNames = new List<String>();
    List<String> insertLastNames = new List<String>();
    List<String> insertPhones = new List<String>();
    List<String> insertMobilePhones = new List<String>();
    List<String> insertUsernames = new List<String>();
    List<String> insertEmails = new List<String>();
    List<String> insertTitles = new List<String>();
    List<String> insertContactIds = new List<String>();
    List<String> insertProfileIds = new List<String>();
    List<Boolean> insertIsActives = new List<Boolean>();

    List<String> updateUserIds = new List<String>();
    List<String> updateFirstNames = new List<String>();
    List<String> updateLastNames = new List<String>();
    List<String> updatePhones = new List<String>();
    List<String> updateMobilePhones = new List<String>();
    List<String> updateUsernames = new List<String>();
    List<String> updateEmails = new List<String>();
    List<String> updateTitles = new List<String>();
    List<String> updateContactIds = new List<String>();
    List<String> updateProfileIds = new List<String>();
    List<Boolean> updateIsActives = new List<Boolean>();

        // If External_Identifier__c is empty, fill it by concatenating dealer number and username
    // User Type 'D' is for Dealers.  Only these rows should be processed further.
    for (Stage_User__c su: Trigger.new) {
                if (su.External_Identifier__c == null) {
                    su.External_Identifier__c = su.Dealer_Number__c + su.Username__c;
                }
        if (su.User_Type__c == 'D') {
            dealerUsers.add(su);
            dealerExternalIds.add(su.Dealer_Number__c + '_USA');
            
            usernames.add(Text_Util.createPortalUsernameLowercase(su.Username__c, su.Dealer_Number__c));
        }
    }

    // Use Dealer Codes to find Dealer Accounts.
    List<Account> dealers = [select Id, Name, Dealer_Code__c, Dealer_External_Id__c, Make_Name__c, Service_Manager__c, Sales_Manager__c, Parts_Manager__c
                             from Account 
                             where RecordTypeId = :dealerAccountRTId
                             and Dealer_External_Id__c in :dealerExternalIds];
    for (Account acct: dealers) {
        dealerMap.put(acct.Dealer_Code__c, acct);
    }

    // Use usernames to find existing Users.
    List<User> existingUsers = [select Id, Username, ContactId
                                from user
                                where Username in :usernames];
    Map<String,User> userMap = new Map<String,User>();
    for (User u: existingUsers) {
                u.Username = u.Username.toLowerCase();
        userMap.put(u.Username, u);
        existingContactIds.add(u.ContactId);
    }

    // Use Portal Usernames to find existing Contacts and create Map from Portal Username to
    // Contact objects.
    List<Contact> existingContacts = [select Id, Portal_Username__c, LastName
                                      from Contact
                                      where Portal_Username__c in :usernames and RecordTypeId=:rtSSOContacts];
    Map<String,Contact> existingContactMap = new Map<String,Contact>();
    for(Contact c: existingContacts) {
                c.Portal_Username__c = c.Portal_Username__c.toLowerCase();
        existingContactMap.put(c.Portal_Username__c, c);
    }

    // Use Map of users to separate trigger rows into Users that should be inserted vs updated.
    for (Stage_User__c su: dealerUsers) {
        String username = Text_Util.createPortalUsernameLowercase(su.Username__c, su.Dealer_Number__c);
        User u = userMap.get(username);
        cont = existingContactMap.get(username);
                dealer = dealerMap.get(su.Dealer_Number__c);

                 if (dealer != null) {
                    stageUserMap.put(username,su);

            if (cont != null) {
            // Construct Contact records to update.
            cont.accountId = dealer.Id;
            cont.Email = UserClass.checkEmailAddress(su.Email__c);   
            cont.Phone = su.Primary_Phone_Number__c;

            
            if (UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c) == 'Inactive User') {
                cont.LastName = su.Last_Name__c;
                cont.Title = su.Title__c;
                cont.SSO_Active__c = false;
            } else {
                cont.Title = UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c);
                cont.LastName = UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c);
                cont.SSO_Active__c = true;
            }

            //cont.FirstName = su.First_Name__c;

            cont.Portal_Username__c = username;
            updateContacts.add(cont);
            
            userContactsMap.put(su.Unique_Id__c , cont);
            }  else if (su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Service' || su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Sales' ||
                                    su.SFDC_Partner_Portal_User__c == 'NNA Case support - Parts' || su.SFDC_Partner_Portal_User__c =='Consumer Affairs - Other') {
            // Construct Contact records to insert
            cont = new Contact();
            cont.accountId = dealer.Id;
            cont.RecordTypeId = rtSSOContacts;
            cont.Email = UserClass.checkEmailAddress(su.Email__c);
            //cont.LastName = UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c);
            cont.LastName = su.Last_Name__c;
            cont.Phone = su.Primary_Phone_Number__c;
            cont.Title = UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c);
            cont.Portal_Username__c = Text_Util.createPortalUsernameLowercase(su.Username__c, su.Dealer_Number__c);
            insertContacts.add(cont);
            userContactsMap.put(su.Unique_Id__c , cont);
            }
        
            if (u != null) {
            // Update relevant User fields
            updateUserIds.add(u.Id);
            updateFirstNames.add('');
            updateLastNames.add(UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c));
            updatePhones.add(su.Primary_Phone_Number__c);
            updateMobilePhones.add(su.Alternate_Phone_Number__c);
            updateUsernames.add(Text_Util.createPortalUsernameLowercase(su.Username__c, su.Dealer_Number__c));
            updateEmails.add(UserClass.checkEmailAddress(su.Email__c));
            updateTitles.add(UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c));
            updateContactIds.add(cont.Id);
                        updateProfileIds.add(UserClass.getSalesforcePartnerProfile(su.SFDC_Partner_Portal_User__c, dealer.Make_Name__c));
            
            // User Status can be Active, Deleted, Disabled, Inactive, Locked.  For any status
            // other than Active or Locked, deactivate the user.
            if ((su.User_Status__c == 'Active' || su.User_Status__c == 'Locked') &&
                    (su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Service' || su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Sales' ||
                                 su.SFDC_Partner_Portal_User__c == 'NNA Case support - Parts' || su.SFDC_Partner_Portal_User__c =='Consumer Affairs - Other')) {
                updateIsActives.add(true);
            } else {
                updateIsActives.add(false);
            }
            } else if (su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Service' ||
                                    su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Sales' ||
                                    su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Other' ||
                                    su.SFDC_Partner_Portal_User__c == 'NNA Case support - Parts') {
            // Add Stage_User__c to a List of rows to create User records for.
            insertDealerUsers.add(su);
            }
                }
        } 

        if (!insertContacts.isEmpty())
        {   
            Database.SaveResult[] results = Database.insert(insertContacts, false);

            if (!results.isEmpty()) {
                for (integer row = 0; row < insertContacts.size(); row++) {
                    if (!results[row].isSuccess()) {
                        Database.Error err = results[row].getErrors()[0];
                        Stage_User__c su = stageUserMap.get(insertContacts[row].Portal_Username__c);
                        su.addError(err.getMessage());
                        errors.add(new Error_Log__c(Record_ID__c = su.Id, Record_Type__c = 'Stage_User__c',
                                    Error_Message__c = err.getMessage(), TimeStamp__c = System.now(), Operation_Name__c = 'Stage_User_Insert_Contact', 
                                    Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
                    }
                }
            }
        }
        if (!updateContacts.isEmpty())
        {   
            Database.SaveResult[] results = Database.update(updateContacts, false);

            if (!results.isEmpty()) {
                for (integer row = 0; row < updateContacts.size(); row++) {
                    if (!results[row].isSuccess()) {
                        Database.Error err = results[row].getErrors()[0];
                        Stage_User__c su = stageUserMap.get(updateContacts[row].Portal_Username__c);
                        su.addError(err.getMessage());
                        errors.add(new Error_Log__c(Record_ID__c = su.Id, Record_Type__c = 'Stage_User__c',
                                    Error_Message__c = err.getMessage(), TimeStamp__c = System.now(), Operation_Name__c = 'Stage_User_Update_Contact', 
                                    Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
                    }
                }
            }
        }

    // Construct User field lists for User inserts  
    for (Stage_User__c su: insertDealerUsers) {
        cont = userContactsMap.get(su.Unique_Id__c);
        dealer = dealerMap.get(su.Dealer_Number__c);
        
        insertFirstNames.add('');
        insertLastNames.add(UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c));
        insertPhones.add(su.Primary_Phone_Number__c);
        insertMobilePhones.add(su.Alternate_Phone_Number__c);
        insertUsernames.add(Text_Util.createPortalUsernameLowercase(su.Username__c, su.Dealer_Number__c));
        insertEmails.add(UserClass.checkEmailAddress(su.Email__c));
        insertTitles.add(UserClass.getSalesforcePartnerTitle(su.SFDC_Partner_Portal_User__c));
        insertContactIds.add(cont.Id);
        insertProfileIds.add(UserClass.getSalesforcePartnerProfile(su.SFDC_Partner_Portal_User__c, dealer.Make_Name__c));
        
        // User Status can be Active, Deleted, Disabled, Inactive, Locked.  For any status
        // other than Active or Locked, deactivate the user.
        if ((su.User_Status__c == 'Active' || su.User_Status__c == 'Locked')  &&
                    (su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Service' || su.SFDC_Partner_Portal_User__c == 'Consumer Affairs - Sales' ||
                                 su.SFDC_Partner_Portal_User__c == 'NNA Case support - Parts' || su.SFDC_Partner_Portal_User__c =='Consumer Affairs - Other')) {
            insertIsActives.add(true);
        } else {
            insertIsActives.add(false);
        }
    }
    
    // Future calls to create and update portal users.  These must be done with future calls since
    // operations on normal objects (contacts) and setup objects (users) cannot be in the same transaction.
    UserClass.createPortalUsers(insertFirstNames, insertLastNames, insertPhones, insertMobilePhones, insertUsernames,
                                insertEmails, insertTitles, insertContactIds, insertProfileIds, insertIsActives);

    UserClass.updatePortalUsers(updateUserIds, updateFirstNames, updateLastNames, updatePhones, updateMobilePhones,
                                updateUsernames, updateEmails, updateTitles, updateContactIds, updateProfileIds, 
                                updateIsActives);
}