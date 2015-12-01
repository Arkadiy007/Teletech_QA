/**********************************************************************
Name: Account_LeadMigration_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "Account_Before_LeadMigration"
and "Account_After_LeadMigration" Triggers.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     05/03/2011 Created
***********************************************************************/

@isTest
private class Account_LeadMigration_Test {
    
    private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    static Account account;
    static Account account2;
    static Account account3;
    static Lead lead;
    static Account dealer;
    static Account dealer2;
    static Brochure_Request__c br;
    static Dealer_Quotes_Request__c dqr;
    static Maritz_Update_Error__c mue;
    static Task t;
    static Username__c username;
    static User user1;
    static User user2;
    
    static final String CUSTOMER_ID = '987654321';
    static final String CUSTOMER_ID_2 = '9876543212';
    static final String CUSTOMER_ID_3 = '9876543213';
    static final String DEALER_ID = '12345678901';
    static final String ID_STRING = '7UE9O2P1';
    static final String BROCHURE_REQ = '2010 Nissan Leaf';
    static final String HANDRAISER = 'Handraiser';
    static final String RESERVATIONISTS = 'Reservationists';
    static final String GENERAL = 'General';
    static final String CCC = 'CCC';
    static final String YES = 'Yes';
    static final String NO = 'No';
   
    static final Decimal ACCT_ANNREV = 100;
    static final String ACCT_BUS = 'YES';
    static final Boolean ACCT_BUS_BOOL = true;
    static final Boolean ACCT_DNC = true;
    static final Boolean ACCT_DNM = true;
    static final String ACCT_FNAME = 'accountfirst';
    static final String ACCT_HOUSE = 'accounthouse';
    static final String ACCT_LANG = 'accountlang';
    static final String ACCT_LNAME = 'accountlast';
    static final String ACCT_MID = 'accountmid';
    static final String ACCT_SAL = 'accountsal';
    static final Boolean ACCT_UNDEL = false;    
    static final String ACCT_CITY = 'accountuncity';
    static final String ACCT_COUNTRY = 'accountcountry';
    static final String ACCT_DNE = 'true';
    static final String ACCT_EMAIL = 'account@email.com';
    static final String ACCT_FEDHDNC = 'true';
    static final String ACCT_FEDMDNC = 'true';
    static final String ACCT_FEDODNC = 'true';
    static final String ACCT_MDNC = 'true';
    static final String ACCT_ODNC = 'true';
    static final String ACCT_OTHERPHONE = 'accountotherphone';
    static final String ACCT_HOMEPHONE = 'accounthomephone';
    static final Boolean ACCT_PERDNC = true;
    static final String ACCT_ZIP = 'accountfedzip';
    static final String ACCT_STATE = 'CO';
    static final String ACCT_STREET = 'accountstreet';
    static final Boolean ACCT_UNDELADD = false;
    static final String ACCT_WEBSITE = 'accountwebsite';
    
    static final Decimal LEAD_ANNREV = 100;
    static final String LEAD_BUS = 'NO';
    static final Boolean LEAD_DNC = false;
    static final Boolean LEAD_DNM = false;
    static final String LEAD_FNAME = 'leadfirst';
    static final String LEAD_HOUSE = 'leadhouse';
    static final String LEAD_LANG = 'leadlang';
    static final String LEAD_LNAME = 'leadlast';
    static final String LEAD_MID = 'leadmid';
    static final String LEAD_SAL = 'leadsal';
    static final Boolean LEAD_UNDEL = true;
    static final String LEAD_CITY = 'leaduncity';
    static final String LEAD_COUNTRY = 'leadcountry';
    static final String LEAD_DNE = 'false';
    static final String LEAD_EMAIL = 'lead@email.com';
    static final String LEAD_FEDHDNC = 'false';
    static final String LEAD_FEDMDNC = 'false';
    static final String LEAD_FEDODNC = 'false';
    static final String LEAD_MDNC = 'false';
    static final String LEAD_ODNC = 'false';
    static final String LEAD_OTHERPHONE = 'leadotherphone';
    static final String LEAD_HOMEPHONE = 'leadhomephone';
    static final Boolean LEAD_PERDNC = false;
    static final String LEAD_ZIP = 'leadfedzip';
    static final String LEAD_STATE = 'CA';
    static final String LEAD_STREET = 'leadstreet';
    static final Boolean LEAD_UNDELADD = true;
    static final String LEAD_WEBSITE = 'leadwebsite';

    static void testInsertData() {
        String dealerType = System.Label.AccRTDealer;
        String personType = System.Label.AccRTMaritz;

        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        dealer = new Account();
        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        insert dealer;
        
        lead = new Lead();
        lead.lastName = LEAD_LNAME;
        lead.firstName = LEAD_FNAME;
        lead.Customer_ID__c = CUSTOMER_ID;
        lead.Assigned_Dealer_Name__c = dealer.id;
        insert lead;
        
        /*
        br = new Brochure_Request__c();
        br.Lead_Name__c = lead.id;
        br.Nissan_Model_1__c = BROCHURE_REQ;
        br.Vehicle_Identification_Number__c = ID_STRING;
        insert br;
        */
        
        dqr = new Dealer_Quotes_Request__c();
        dqr.Lead__c = lead.id;
        dqr.Division__c = ID_STRING;
        insert dqr;
        
        t = new Task();
        t.WhoId = lead.id;
        t.Subject = ID_STRING;
        insert t;
        
        username = new Username__c();
        username.Lead_Name__c = lead.id;
        username.Portal_User_Name__c = ID_STRING;
        insert username;
        
        account = new Account();
        account.RecordTypeId = personTypeRT.id;
        account.LastName = LEAD_LNAME;
        account.FirstName = LEAD_FNAME;
        account.Lead_Type__c = HANDRAISER;
        account.Customer_ID__c = CUSTOMER_ID;

        account2 = new Account();
        account2.RecordTypeId = personTypeRT.id;
        account2.LastName = LEAD_LNAME;
        account2.FirstName = LEAD_FNAME;
        account2.Lead_Record_Type__c = RESERVATIONISTS;
        account2.Customer_ID__c = CUSTOMER_ID_2;

        account3 = new Account();
        account3.RecordTypeId = personTypeRT.id;
        account3.LastName = LEAD_LNAME;
        account3.FirstName = LEAD_FNAME;
        account3.Lead_Record_Type__c = GENERAL;
        account3.Lead_Type__c = CCC;
        account3.Customer_ID__c = CUSTOMER_ID_3;
    }

    static testmethod void testAccountLeadMigrationInsert() {
        oUtil.isUnitTesting = true;
        testInsertData();
        
        // Start the test, this changes governor limit context to that of trigger rather than test.     
        Test.startTest();
        
        // Insert the Dealer Quotes Request records that cause the trigger to execute.
        insert account;
        insert account2;
        insert account3;
        
        // Stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
/*
        // Get the Account object with fields filled in after triggers execute and make sure it was filled correctly.
        account = [select id, LastName, PersonContactId, Customer_ID__c, Customer__c, Lead__c, Reservationist__c, Handraiser__c
                   from Account
                   where customer_id__c = :CUSTOMER_ID];
        System.assert(account.LastName == LEAD_LNAME);
        System.assert(account.Customer__c == false);
        System.assert(account.Lead__c == false);
        System.assert(account.Reservationist__c == false);
        System.assert(account.Handraiser__c == true);

        // Get Brochure Request associated to account and verify it was moved correctly.
        br = [select id, Vehicle_Identification_Number__c
              from Brochure_Request__c
              where Account_Name__c = :account.id];
        System.assert(br.Vehicle_Identification_Number__c == ID_STRING);

        // Get Dealer Quotes Request associated to account and verify it was moved correctly.
        dqr = [select id, Division__c
               from Dealer_Quotes_Request__c
               where Account__c = :account.id];
        System.assert(dqr.Division__c == ID_STRING);        

        // Get Task associated to account and verify it was moved correctly.
        t = [select id, Subject
             from Task
             where WhoId = :account.PersonContactId];
        System.assert(t.Subject == ID_STRING);

        // Get Username associated to account and verify it was moved correctly.
        username = [select id, Portal_User_Name__c
                    from Username__c
                    where Customer_Name__c = :account.id];
        System.assert(username.Portal_User_Name__c == ID_STRING);

        // Get the second Account object with fields filled in after triggers execute and make sure
        // the type flags are filled in correctly
        account2 = [select id, Customer__c, Lead__c, Reservationist__c, Handraiser__c
                    from Account
                    where customer_id__c = :CUSTOMER_ID_2];
        System.assert(account2.Customer__c == false);
        System.assert(account2.Lead__c == false);
        System.assert(account2.Reservationist__c == true);
        System.assert(account2.Handraiser__c == false);

        // Get the second Account object with fields filled in after triggers execute and make sure
        // the type flags are filled in correctly
        account3 = [select id, Customer__c, Lead__c, Reservationist__c, Handraiser__c
                    from Account
                    where customer_id__c = :CUSTOMER_ID_3];
        System.assert(account3.Customer__c == false);
        System.assert(account3.Lead__c == true);
        System.assert(account3.Reservationist__c == false);
        System.assert(account3.Handraiser__c == false);
*/
    }

    static void testUpdateData() {
        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;

        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;
    	State__c state2 = new State__c(Name = 'CA', Name__c = 'California', Order__c = 1);
    	insert state2;

        dealer = new Account();
        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        insert dealer;

        dealer2 = new Account();
        dealer2.name = 'dealerAccTest2';
        dealer2.RecordTypeId = dealerTypeRT.id;
        dealer2.Dealer_Code__c = DEALER_ID + '2';
        insert dealer2;
        
        lead = new Lead();
        lead.LastName = LEAD_LNAME;
        lead.FirstName = LEAD_FNAME;
        lead.Customer_ID__c = CUSTOMER_ID;
        lead.Assigned_Dealer_Name__c = dealer.id;
        insert lead;
        
        /*
        br = new Brochure_Request__c();
        br.Lead_Name__c = lead.id;
        br.Nissan_Model_1__c = BROCHURE_REQ;
        br.Vehicle_Identification_Number__c = ID_STRING;
        insert br;
        */
        
        dqr = new Dealer_Quotes_Request__c();
        dqr.Lead__c = lead.id;
        dqr.Division__c = ID_STRING;
        insert dqr;
        
        t = new Task();
        t.WhoId = lead.id;
        t.Subject = ID_STRING;
        insert t;
        
        username = new Username__c();
        username.Lead_Name__c = lead.id;
        username.Portal_User_Name__c = ID_STRING;
        insert username;
        
        List<User> users = [select id from User where isActive = true limit 2];
        
        user1 = users[0];
        user2 = users[1];
        
        account = new Account();
        account.RecordTypeId = personTypeRT.id;
        account.AnnualRevenue = ACCT_ANNREV;
        account.Business_Indicator_Temp__c = ACCT_BUS;
        account.Do_Not_Contact_Indicator__c = ACCT_DNC;
        account.Do_Not_Mail_Indicator__c = ACCT_DNM;
        account.FirstName = ACCT_FNAME;
        account.Household_ID__c = ACCT_HOUSE;
        account.Language_Preference__c = ACCT_LANG;
        account.LastName = ACCT_LNAME;
        account.MiddleName__c = ACCT_MID;
        account.OwnerId = user1.id;
        account.Salutation = ACCT_SAL;
        account.Undeliverable_Email_Address_In__c = ACCT_UNDEL;
        account.PersonMailingCity = ACCT_CITY;
        account.PersonMailingCountry = ACCT_COUNTRY;
        account.Do_Not_Email_In__c = ACCT_DNE;
        account.PersonEmail = ACCT_EMAIL;
        account.Federal_Home_Phone_Do_Not_Call_In__c = ACCT_FEDHDNC;
        account.Federal_Mobile_Phone_Do_Not_Call_In__c = ACCT_FEDMDNC;
        account.Federal_Other_Phone_Do_Not_Call_In__c = ACCT_FEDODNC;
        account.Mobile_Phone_Do_Not_Call_Indicator__c = ACCT_MDNC;
        account.Other_Phone_Do_Not_Call_In__c = ACCT_ODNC;
        account.PersonOtherPhone = ACCT_OTHERPHONE;
        account.PersonHomePhone = ACCT_HOMEPHONE;
        account.PersonDoNotCall = ACCT_PERDNC;
        account.PersonMailingPostalCode = ACCT_ZIP;
        account.PersonMailingState = ACCT_STATE;
        account.PersonMailingStreet = ACCT_STREET;
        account.Undeliverable_Address_Indicator__c = ACCT_UNDELADD;
        account.Preferred_Dealer_Id__c = dealer.id;
        account.Website = ACCT_WEBSITE;
        account.Lead_Type__c = HANDRAISER;
        account.Customer_ID__c = CUSTOMER_ID;
        insert account;
        
        account2 = new Account();
        account2.RecordTypeId = personTypeRT.id;
        account2.LastName = LEAD_LNAME;
        account2.FirstName = LEAD_FNAME;
        account2.Customer_ID__c = CUSTOMER_ID_2;
        insert account2;
        

        account3 = new Account();
        account3.RecordTypeId = personTypeRT.id;
        account3.LastName = LEAD_LNAME;
        account3.FirstName = LEAD_FNAME;
        account3.Customer_ID__c = CUSTOMER_ID_3;
        insert account3;
    }
   
    static testmethod void testAccountLeadMigrationUpdate() {
        oUtil.isUnitTesting = true;
        testUpdateData();
        
        account = [select id, LastName
                   from Account
                   where customer_id__c = :CUSTOMER_ID];
        account.AnnualRevenue = LEAD_ANNREV;
        account.Business_Indicator_Temp__c = LEAD_BUS;
        account.Do_Not_Contact_Indicator__c = LEAD_DNC;
        account.Do_Not_Mail_Indicator__c = LEAD_DNM;
        account.FirstName = LEAD_FNAME;
        account.Household_ID__c = LEAD_HOUSE;
        account.Language_Preference__c = LEAD_LANG;
        account.LastName = LEAD_LNAME;
        account.MiddleName__c = LEAD_MID;
        account.OwnerId = user2.id;
        account.Salutation = LEAD_SAL;
        account.Undeliverable_Email_Address_In__c = LEAD_UNDEL;
        account.PersonMailingCity = LEAD_CITY;
        account.PersonMailingCountry = LEAD_COUNTRY;
        account.Do_Not_Email_In__c = LEAD_DNE;
        account.PersonEmail = LEAD_EMAIL;
        account.Federal_Home_Phone_Do_Not_Call_In__c = LEAD_FEDHDNC;
        account.Federal_Mobile_Phone_Do_Not_Call_In__c = LEAD_FEDMDNC;
        account.Federal_Other_Phone_Do_Not_Call_In__c = LEAD_FEDODNC;
        account.Mobile_Phone_Do_Not_Call_Indicator__c = LEAD_MDNC;
        account.Other_Phone_Do_Not_Call_In__c = LEAD_ODNC;
        account.PersonOtherPhone = LEAD_OTHERPHONE;
        account.PersonHomePhone = LEAD_HOMEPHONE;
        account.PersonDoNotCall = LEAD_PERDNC;
        account.PersonMailingPostalCode = LEAD_ZIP;
        account.PersonMailingState = LEAD_STATE;
        account.PersonMailingStreet = LEAD_STREET;
        account.Undeliverable_Address_Indicator__c = LEAD_UNDELADD;
        account.Preferred_Dealer_Id__c = dealer2.id;
        account.Website = LEAD_WEBSITE;
        account.Lead_Type__c = HANDRAISER;
        
        account2.Lead_Record_Type__c = RESERVATIONISTS;
        
        account3.Lead_Record_Type__c = GENERAL;
        account3.Lead_Type__c = CCC;
                
        // Start the test, this changes governor limit context to that of trigger rather than test.
        Test.startTest();
        
        // Update the Account records that cause the trigger to execute.
        update account;
        update account2;
        update account3;
        
        // Stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
/*
        // Get the Account object with fields filled in after triggers execute and make sure it was filled correctly.
        account = [select id, Customer_ID__c, AnnualRevenue, Business_Indicator__c, Do_Not_Contact_Indicator__c,
                          Do_Not_Mail_Indicator__c, FirstName, Household_ID__c, Language_Preference__c,
                          LastName, MiddleName__c, Name, OwnerId, Salutation, Undeliverable_Email_Address_In__c,
                          PersonMailingCity, PersonMailingCountry, Do_Not_Email_In__c, PersonEmail,
                          Federal_Home_Phone_Do_Not_Call_In__c, Federal_Mobile_Phone_Do_Not_Call_In__c,
                          Federal_Other_Phone_Do_Not_Call_In__c, Mobile_Phone_Do_Not_Call_Indicator__c,
                          Other_Phone_Do_Not_Call_In__c, PersonOtherPhone, PersonHomePhone, PersonDoNotCall,
                          PersonMailingPostalCode, PersonMailingState, PersonMailingStreet, Undeliverable_Address_Indicator__c,
                          Preferred_Dealer_Id__c, Website, Customer__c, Lead__c, Reservationist__c, Handraiser__c,
                          PersonContactId
                   from Account
                   where customer_id__c = :CUSTOMER_ID];
        System.Assert(account.AnnualRevenue == ACCT_ANNREV);
        //System.Assert(account.Business_Indicator__c == ACCT_BUS_BOOL);
        System.Assert(account.Do_Not_Contact_Indicator__c == ACCT_DNC);
        System.Assert(account.Do_Not_Mail_Indicator__c == ACCT_DNM);
        System.Assert(account.FirstName == ACCT_FNAME);
        System.Assert(account.Household_ID__c == ACCT_HOUSE);
        System.Assert(account.Language_Preference__c == ACCT_LANG);
        System.Assert(account.LastName == ACCT_LNAME);
        System.Assert(account.MiddleName__c == ACCT_MID);
        System.Assert(account.OwnerId == user1.id);
        System.Assert(account.Salutation == ACCT_SAL);
        System.Assert(account.Undeliverable_Email_Address_In__c == ACCT_UNDEL);
        System.Assert(account.PersonMailingCity == ACCT_CITY);
        System.Assert(account.PersonMailingCountry == ACCT_COUNTRY);
        System.Assert(account.Do_Not_Email_In__c == YES.toUpperCase());
        System.Assert(account.PersonEmail == ACCT_EMAIL);
        System.Assert(account.Federal_Home_Phone_Do_Not_Call_In__c == YES);
        System.Assert(account.Federal_Mobile_Phone_Do_Not_Call_In__c == YES);
        System.Assert(account.Federal_Other_Phone_Do_Not_Call_In__c == YES);
        System.Assert(account.Mobile_Phone_Do_Not_Call_Indicator__c == YES.toUpperCase());
        System.Assert(account.Other_Phone_Do_Not_Call_In__c == YES.toUpperCase());
        System.Assert(account.PersonOtherPhone == ACCT_OTHERPHONE);
        System.Assert(account.PersonHomePhone == ACCT_HOMEPHONE);
        System.Assert(account.PersonDoNotCall == ACCT_PERDNC);
        System.Assert(account.PersonMailingPostalCode == ACCT_ZIP);
        System.Assert(account.PersonMailingState == ACCT_STATE);
        System.Assert(account.PersonMailingStreet == ACCT_STREET);
        System.Assert(account.Undeliverable_Address_Indicator__c == ACCT_UNDELADD);
        System.Assert(account.Preferred_Dealer_Id__c == dealer.id);
        System.Assert(account.Website == LEAD_WEBSITE);
        System.assert(account.Customer__c == true);
        System.assert(account.Lead__c == false);
        System.assert(account.Reservationist__c == false);
        System.assert(account.Handraiser__c == true);
        
        // Get Brochure Request associated to account and verify it was moved correctly.
        br = [select id, Vehicle_Identification_Number__c
              from Brochure_Request__c
              where Account_Name__c = :account.id];
        System.assert(br.Vehicle_Identification_Number__c == ID_STRING);

        // Get Dealer Quotes Request associated to account and verify it was moved correctly.
        dqr = [select id, Division__c
               from Dealer_Quotes_Request__c
               where Account__c = :account.id];
        System.assert(dqr.Division__c == ID_STRING);        

        // Get Task associated to account and verify it was moved correctly.
        t = [select id, Subject
             from Task
             where WhoId = :account.PersonContactId];
        System.assert(t.Subject == ID_STRING);

        // Get Username associated to account and verify it was moved correctly.
        username = [select id, Portal_User_Name__c
                    from Username__c
                    where Customer_Name__c = :account.id];
        System.assert(username.Portal_User_Name__c == ID_STRING);      

        // Get the second Account object with fields filled in after triggers execute and make sure
        // the type flags are filled in correctly
        account2 = [select id, LastName, Customer_ID__c, Preferred_Dealer_Id__c, PersonContactId,
                           Customer__c, Lead__c, Reservationist__c, Handraiser__c, Lead_Type__c, Lead_Record_Type__c
                    from Account
                    where customer_id__c = :CUSTOMER_ID_2];
        System.assert(account2.Customer__c == true);
        System.assert(account2.Lead__c == false);
        System.assert(account2.Reservationist__c == true);
        System.assert(account2.Handraiser__c == false);

        // Get the second Account object with fields filled in after triggers execute and make sure
        // the type flags are filled in correctly
        account3 = [select id, LastName, Customer_ID__c, Preferred_Dealer_Id__c, PersonContactId,
                           Customer__c, Lead__c, Reservationist__c, Handraiser__c
                    from Account
                    where customer_id__c = :CUSTOMER_ID_3];
        System.assert(account3.Customer__c == true);
        System.assert(account3.Lead__c == true);
        System.assert(account3.Reservationist__c == false);
        System.assert(account3.Handraiser__c == false);
*/
    } 
}