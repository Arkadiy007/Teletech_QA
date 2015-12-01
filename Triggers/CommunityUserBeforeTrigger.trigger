trigger CommunityUserBeforeTrigger on Li_Community_User__c (before insert, before update) {
    Map<String, Li_Community_User__c> emailToCommunityUserMap = new Map<String, Li_Community_User__c>();
    Map<String, Contact> emailToContactMap = new Map<String, Contact>();
    Map<String, Account> emailTopersonAccountMap = new Map<String, Account>();
    List<Li_Community_User__c> listOfCommunityUsers = new List<Li_Community_User__c>();
    List<Contact> contactsToInsert = new List<Contact>();
    List<Account> personAccountsToInsert = new List<Account>();
    LithiumSettings__c liSetting = LithiumSettings__c.getValues('DefaultSetting');
    Id personAccountRecordTypeId;
    
    if(liSetting == NULL) {
        liSetting = new LithiumSettings__c();
        liSetting.Name = 'DefaultSetting';
        liSetting.Sync_With_Contact__c = true;
        liSetting.Create_New_Contact_record__c = true;
        
        Database.insert(liSetting);
    }
    // build a map of email>community user   
    for(Li_Community_User__c aCommunityUser : trigger.new) {
        if(aCommunityUser.Email_Address__c != NULL)
            emailToCommunityUserMap.put(aCommunityUser.Email_Address__c, aCommunityUser); 
    }
    // commented out as PersonAccount is not enabled    
    { 
        // build a map of email>person account (Person Accounts which have same email as community users)
        for(Account pAccount : [SELECT PersonEmail, Name, LastName, FirstName
                            FROM Account
                            WHERE PersonEmail IN :emailToCommunityUserMap.keySet() AND IsPersonAccount = true]) {
            emailTopersonAccountMap.put(pAccount.PersonEmail, pAccount);  
        }
        
        for(RecordType rt : [SELECT Id FROM RecordType  WHERE DeveloperName = :liSetting.Person_Account_Record_Type_Name__c LIMIT 1]) {
            personAccountRecordTypeId = rt.Id;
            }
        
        for(String email : emailToCommunityUserMap.keySet()) { // loop through all community users with email address
            Account pAccount = emailTopersonAccountMap.get(email);
            Li_Community_User__c aCommunityUser = emailToCommunityUserMap.get(email);
            
            if(pAccount != NULL && liSetting.Sync_With_Contact__c){ // attach Person Account record or not
                aCommunityUser.Person_Account__c = pAccount.Id; // use existing Person Account 
            }
            if(pAccount == NULL && liSetting.Create_New_Contact_record__c) { // Person Account doesn't exist and lithium setting asks to create one
                // No Person Account exists; create new record
                pAccount = new Account(); 
                pAccount.RecordTypeId = personAccountRecordTypeId;
                pAccount.FirstName = aCommunityUser.First_Name__c;
                pAccount.LastName = (aCommunityUser.Last_Name__c == NULL)?aCommunityUser.Name:aCommunityUser.Last_Name__c; // LastName is required for Contact; making sure it is not empty
                pAccount.PersonEmail = aCommunityUser.Email_Address__c;
                personAccountsToInsert.add(pAccount); // list of Person Accounts to update/insert
                listOfCommunityUsers.add(aCommunityUser); // maintain a list of community users also; same order as personAccountsToInsert
            }           
        }
    
        if(!personAccountsToInsert.isEmpty()) {
            // insert/update contacts; continue DML operations if a failure occurs
            Database.SaveResult[] iResults = Database.insert(personAccountsToInsert, false); 
            
            Integer i = 0;
            for(Database.SaveResult result : iResults) {
                // Database.SaveResult[] in same order as contactsToInsert
                // Safe to assume same index for community users list
                if(!result.isSuccess()) { // error occured in contact update/insert
                    system.debug('error updating ' + result.getErrors()[0].getMessage());
                    listOfCommunityUsers[i].addError('Error creating/updating Person Account'); // add error to community user object;
                }
                else if(liSetting.Sync_With_Contact__c){  // attach new Contact record or not
                    listOfCommunityUsers[i].Person_Account__c = result.getId(); // assign Person Account id; this is not available before Person Account is inserted, hence done here
                } 
                ++i;
            }
        } 
    }
    
}