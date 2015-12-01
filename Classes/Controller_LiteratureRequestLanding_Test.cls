/**********************************************************************
Name: Controller_LiteratureRequestLanding_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_LiteratureRequestLandingPage.

Related Class : Controller_LiteratureRequestLandingPage
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 09/29/2011 Created                          
***********************************************************************/
@isTest
private class Controller_LiteratureRequestLanding_Test {
    private static Brochure_Request__c br;
    private static Account acct;
    private static Code__c testNissanBrochure;
    private static Literature__c testLit;
    private static String personType;
    private static RecordType personTypeRT;
    private static RecordType brochureRequestRecordType = [select Id 
                                                           from RecordType 
                                                           where SObjectType = 'Brochure_Request__c'
                                                           and Name = 'Brochure Request'];
    private static RecordType literatureRequestRecordType = [select Id 
                                                             from RecordType 
                                                             where SObjectType = 'Brochure_Request__c'
                                                             and Name = 'Literature Request'];

    static void  InitializeData() {
        personType = System.Label.AccRTMaritz;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        acct = new Account();
        acct.customer_Id__c = 'testId1';
        acct.FirstName = 'Test';
        acct.LastName = 'User1';
        acct.PersonMailingStreet = '111 A St.';
        acct.PersonMailingCity = 'TestCity';
        acct.PersonMailingState = 'CO';
        acct.PersonMailingPostalCode = '80231';
        acct.PersonEmail = 'a1@a.com'; 
        acct.RecordTypeId = personTypeRT.id;
        insert acct;
        
        testNissanBrochure = new Code__c(Type__c = 'Nissan_Brochure', Description__c = '2012 Nissan Test Vehicle', Code__c = '1234567890');
        insert testNissanBrochure;
        
        testLit = new Literature__c(Make__c = 'Nissan', Model_Year__c = '2011', Model__c = 'Altima', Item_Number__c = '111',
                                    Item_Description__c = '2011 Altima Manual 1');
        insert testLit;       
    }    
       
    static testMethod void testCreateBrochureRequest() {
        InitializeData();
        
        br = new Brochure_Request__c();
        br.RecordTypeId = brochureRequestRecordType.Id;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('AccountId',acct.id);
            ApexPages.currentPage().getParameters().put('RecordType',brochureRequestRecordType.Id);
            Controller_LiteratureRequestLandingPage scon = new Controller_LiteratureRequestLandingPage(new ApexPages.StandardController(br));

            system.assert(scon.getRedir().getUrl() == ('/apex/BrochureRequest?AccountId=' + acct.Id));
        Test.stopTest();
    }
    
    static testMethod void testCreateLiteratureRequest() {
        InitializeData();
        
        br = new Brochure_Request__c();
        br.RecordTypeId = literatureRequestRecordType.Id;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('AccountId',acct.id);
            ApexPages.currentPage().getParameters().put('RecordType',literatureRequestRecordType.Id);
            Controller_LiteratureRequestLandingPage scon = new Controller_LiteratureRequestLandingPage(new ApexPages.StandardController(br));

            system.assert(scon.getRedir().getUrl() == ('/apex/LiteratureRequest?AccountId=' + acct.Id));
        Test.stopTest();
    }
    
    static testMethod void testEditBrochureRequest() {
        InitializeData();
        
        br = new Brochure_Request__c();
        br.RecordTypeId = brochureRequestRecordType.Id;
        br.Nissan_Model_1__c = testNissanBrochure.Description__c;
        br.Account_Name__c = acct.Id;
        insert br;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('RecordType',brochureRequestRecordType.Id);
            Controller_LiteratureRequestLandingPage scon = new Controller_LiteratureRequestLandingPage(new ApexPages.StandardController(br));

            system.assert(scon.getRedir().getUrl() == ('/apex/BrochureRequest?Id=' + br.Id));
        Test.stopTest();
        System.debug(scon.getRedir().getUrl());
    }

    static testMethod void testEditLiteratureRequest() {
        InitializeData();
        
        br = new Brochure_Request__c();
        br.RecordTypeId = literatureRequestRecordType.Id;
        br.Literature_Requested__c = testLit.Id;
        br.Mailing_State_Province__c = 'CO';
        br.Account_Name__c = acct.Id;
        insert br;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('RecordType',literatureRequestRecordType.Id);
            Controller_LiteratureRequestLandingPage scon = new Controller_LiteratureRequestLandingPage(new ApexPages.StandardController(br));

            system.assert(scon.getRedir().getUrl() == ('/apex/LiteratureRequest?Id=' + br.Id));
        Test.stopTest();
        System.debug(scon.getRedir().getUrl());
    }
}