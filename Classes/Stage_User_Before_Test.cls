/**********************************************************************
Name: Stage_User_Before_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Stage_User_Before" Apex Trigger.

Related to: Stage_User_Before, UserClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 06/12/2013 Created
***********************************************************************/
@isTest
private Class Stage_User_Before_Test {
    final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
    final static RecordType ssoType = [select id, name from recordtype where name ='SSO Contact' and sobjecttype = 'Contact' limit 1];

    private static List<Account> dealers;
    private static List<Contact> contacts;
    private static List<Stage_User__c> sus;

    private static void createTestDealers() {
        dealers = new List<Account> {new Account(RecordTypeId = dealerType.Id, Name = 'Stage User Test Nissan Dealer', Dealer_Code__c = 'StgUserNissanDlr',
                                                                                        Dealer_External_Id__c = 'StgUserNissanDlr_USA', Make_Name__c = 'Nissan'),
                                                               new Account(RecordTypeId = dealerType.Id, Name = 'Stage User Test Infiniti Dealer', Dealer_Code__c = 'StgUserNissanDlr2',
                                                                                        Dealer_External_Id__c = 'StgUserInfinitiDlr_USA', Make_Name__c = 'Nissan'),
                                                               new Account(RecordTypeId = dealerType.Id, Name = 'Stage User Test Nissan Dealer 2', Dealer_Code__c = 'StgUserInfinitiDlr',
                                                                                        Dealer_External_Id__c = 'StgUserNissanDlr2_USA', Make_Name__c = 'Infiniti'),
                                                               new Account(RecordTypeId = dealerType.Id, Name = 'Stage User Test Infiniti Dealer 2', Dealer_Code__c = 'StgUserInfinitiDlr2',
                                                                                        Dealer_External_Id__c = 'StgUserInfinitiDlr2_USA', Make_Name__c = 'Infiniti')};

        insert dealers;
        dealers[0].IsPartner = true;
        dealers[1].IsPartner = true;
        dealers[2].IsPartner = true;
        dealers[3].IsPartner = true;
        update dealers;
    }

    private static void createTestContacts() {
        contacts = new List<Contact> {new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('ServiceManager','StgUserNissanDlr'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Service'), AccountId = dealers[0].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('PartsManager','StgUserNissanDlr'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('NNA Case support - Parts'), AccountId = dealers[0].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('SalesManager','StgUserNissanDlr2'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Sales'), AccountId = dealers[1].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('DealerUser','StgUserNissanDlr2'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Other'), AccountId = dealers[1].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('ServiceManager','StgUserInfinitiDlr'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Service'), AccountId = dealers[2].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('PartsManager','StgUserInfinitiDlr'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('NNA Case support - Parts'), AccountId = dealers[2].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('SalesManager','StgUserInfinitiDlr2'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Sales'), AccountId = dealers[3].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('DealerUser','StgUserInfinitiDlr2'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Other'), AccountId = dealers[3].Id),
                                                                new Contact( RecordTypeId = ssoType.Id,Portal_Username__c =Text_Util.createPortalUsernameLowercase('ServiceManager','StgUserInfinitiDlr2'),
                                                                                        LastName = UserClass.getSalesforcePartnerTitle('Consumer Affairs - Service'), AccountId = dealers[3].Id)};
        insert contacts;
    }

    private static void setupTestStageUsers() {
        sus = new List<Stage_User__c> {new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[0].Dealer_Code__c, Username__c = 'ServiceManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[0].Dealer_Code__c, Username__c = 'PartsManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'NNA Case support - Parts'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[1].Dealer_Code__c, Username__c = 'SalesManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Sales'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[1].Dealer_Code__c, Username__c = 'DealerUser', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Other'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[2].Dealer_Code__c, Username__c = 'ServiceManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[2].Dealer_Code__c, Username__c = 'PartsManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'NNA Case support - Parts'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[3].Dealer_Code__c, Username__c = 'SalesManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Sales'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[3].Dealer_Code__c, Username__c = 'DealerUser', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Other'),
                                                                       new Stage_User__c(User_Type__c = 'D', Dealer_Number__c = dealers[3].Dealer_Code__c, Username__c = 'ServiceManager', Email__c = '', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Disabled', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service')};
    }

    static testMethod void Stage_User_Create_Test() {
        System.Debug('***** Stage_User_Create_Test *****');

        createTestDealers();
        setupTestStageUsers();

        Test.startTest();
            insert sus;
        Test.stopTest();
    }

    static testMethod void Stage_User_Update_Contact_Test() {
        System.Debug('***** Stage_User_Update_Contact_Test *****');

        createTestDealers();
        createTestContacts();
        setupTestStageUsers();

        Test.startTest();
            insert sus;
        Test.stopTest();
    }
    static testMethod void Stage_User_Update_Contact_And_User_Test() {
        System.Debug('***** Stage_User_Update_Contact_And_User_Test *****');

        createTestDealers();
        createTestContacts();
        setupTestStageUsers();

        User currentUser = [select id from User where id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            User u = new User();
            u.emailencodingkey = 'UTF-8';
            u.languagelocalekey = 'en_US';
            u.localesidkey = 'en_US';
            u.timezonesidkey = 'America/Los_Angeles';
            u.Cost_Center__c = 'Partner Portal';
            u.Location__c = 'Other / Remote';
            u.Alias = 'talias';
            u.FirstName = '';
            u.LastName = 'Service Manager';
            u.Username = Text_Util.createPortalUsernameLowercase('ServiceManager','StgUserNissanDlr');
            u.Email = 'stgusertest@noemail.tst';
            u.ContactId = contacts[0].Id;
            u.ProfileId = UserClass.NissanSalesServiceProfileId;

            insert u;

            u = new User();
            u.emailencodingkey = 'UTF-8';
            u.languagelocalekey = 'en_US';
            u.localesidkey = 'en_US';
            u.timezonesidkey = 'America/Los_Angeles';
            u.Cost_Center__c = 'Partner Portal';
            u.Location__c = 'Other / Remote';
            u.Alias = 'talias';
            u.FirstName = '';
            u.LastName = 'Service Manager';
            u.Username = Text_Util.createPortalUsernameLowercase('ServiceManager','StgUserInfinitiDlr2');
            u.Email = 'stgusertest@noemail.tst';
            u.ContactId = contacts[8].Id;
            u.ProfileId = UserClass.NissanSalesServiceProfileId;

            insert u;
        }

        Test.startTest();
            insert sus;
        Test.stopTest();
    }
}