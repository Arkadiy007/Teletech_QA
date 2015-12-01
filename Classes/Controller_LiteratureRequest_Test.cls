/**********************************************************************
Name: Controller_LiteratureRequest_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests ths Apex class Controller_LiteratureRequest.

Related Page : Controller_LiteratureRequest 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 09/21/2011 Created                        
***********************************************************************/

@isTest
private class Controller_LiteratureRequest_Test {
    private static String personType;
    private static RecordType personTypeRT;
    private static RecordType literatureRequestRecordType;

    private static Brochure_Request__c testLR;
    private static Literature__c testLit1;
    private static Literature__c testLit2;
    private static Literature__c testLit3;
    private static Account acct;
    private static Account acct2;
    
    public static void InitializeData() {
        personType = System.Label.AccRTMaritz;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        literatureRequestRecordType = [select id, name 
                                       from recordtype 
                                       where name = 'Literature Request' 
                                       and sobjecttype = 'Brochure_Request__c' limit 1];

        testLit1 = new Literature__c(Make__c = 'Nissan', Model_Year__c = '2011', Model__c = 'Altima', Item_Number__c = '111',
                                       Item_Description__c = '2011 Altima Manual 1');
        testLit2 = new Literature__c(Make__c = 'Nissan', Model_Year__c = '2011', Model__c = 'Altima', Item_Number__c = '1112',
                                       Item_Description__c = '2011 Altima Manual 2');
        testLit3 = new Literature__c(Make__c = 'Infiniti', Model_Year__c = '2011', Model__c = 'Q45', Item_Number__c = '1113',
                                       Item_Description__c = '2011 Q45 Manual 1');
        insert testLit1;
        insert testLit2;
        insert testLit3;
        
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
        
        acct2 = new Account();
        acct2.customer_Id__c = 'testId2';
        acct2.FirstName = 'Test';
        acct2.LastName = 'User2';
        acct2.PersonMailingStreet = '112 A St.';
        acct2.PersonMailingCity = 'TestCity';
        acct2.PersonMailingState = 'CO';
        acct2.PersonMailingPostalCode = '80231';
        acct2.PersonEmail = 'a2@a.com'; 
        acct2.RecordTypeId = personTypeRT.id;
        insert acct2;
                
        testLR = new Brochure_Request__c();
        testLR.Literature_Requested__c = testLit1.Id;
        testLR.Account_Name__c = acct.Id;
        testLR.RecordTypeId = literatureRequestRecordType.Id;
        
        insert testLR;
    }
/*
    static testMethod void TestLiteratureRequest_PageOpen() {
        System.debug('***** TestLiteratureRequest_PageOpen *****');
        
        InitializeData();
        Test.startTest();
        
            PageReference objPageRef = Page.LiteratureRequest;
            Controller_LiteratureRequest objController;
            
            Test.setCurrentPage(objPageRef);
            Brochure_Request__c testEmptyBR = new Brochure_Request__c();
            
            //open page
            objController = new Controller_LiteratureRequest(new ApexPages.StandardController(testEmptyBR));
        
        Test.stopTest();
    }
*/
    static testMethod void TestLiteratureRequest_ModifyLiterature() {
        System.debug('***** TestLiteratureRequest_ModifyLiterature *****');
        
        InitializeData();
        Test.startTest();
            
            PageReference objPageRef = Page.LiteratureRequest;
            Controller_LiteratureRequest objController;
    
            // Select options in drop-down lists        
            Test.setCurrentPage(objPageRef);
            objController = new Controller_LiteratureRequest(new ApexPages.StandardController(testLR));
            List<SelectOption> options;
            objController.Years = null;
            objController.Models = null;
            objController.Literatures = null;
            
            options = objController.Makes;
            //System.assert(options.size() == 3);
            objController.selectedMake = 'Nissan';
            
            // Test null
            options = objController.Years;
            // Test not null
            options = objController.Years;
            objController.selectedYear = '2011';
            
            // Test null
            options = objController.Models;
            // Test not null
            options = objController.Models;
            objController.selectedModel = 'Altima';
            
            //Test null
            options = objController.Literatures;
            // Test not null
            options = objController.Literatures;
            objController.selectedLiterature = testLit1.Id;
            objController.populateEntries();
            System.assert(objController.literatureRequest.Literature_Requested__c == testLit1.Id);

            // Test changing null Account
            objController.literatureRequest.Account_Name__c = null;
            objController.changeAccount();
            System.assert(objController.literatureRequest.Mailing_Street__c == null);
            
            // Test changing real Account
            objController.literatureRequest.Account_Name__c = acct2.Id;
            objController.changeAccount();
            System.assert(objController.literatureRequest.Mailing_Street__c == '112 A St.');

            // Save Literature Request
            objController.literatureRequest.Use_this_to_Update_Customer_s_Info__c = true;
            objController.literatureRequest.Mailing_Street__c = '113 A St.';
            objController.doSaveLiteratureRequest();

            testLR = [Select Literature_Requested__c, Mailing_Street__c
                      From Brochure_Request__c 
                      Where Account_Name__c = :acct2.Id];
            System.assert(testLR.Literature_Requested__c == testLit1.Id);
            System.assert(testLR.Mailing_Street__c == '113 A St.');
            
            acct2 = [Select PersonMailingStreet
                     From Account
                     Where Id = :acct2.Id];
            System.assert(acct2.PersonMailingStreet == '113 A St.');
            
            // Test Exception
            objController.acct = new Account(Customer_Id__c = 'testId2');
            objController.doSaveLiteratureRequest();
            System.assert(ApexPages.hasMessages());
            
            objController = null;

            Test.stopTest();
    }
}