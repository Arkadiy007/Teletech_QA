/**********************************************************************
Name: Controller_BrochureRequest_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests the Apex class Controller_BrochureRequest.

Related Page : Controller_BrochureRequest 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 09/28/2011 Created                        
***********************************************************************/

@isTest
private class Controller_BrochureRequest_Test {
    private static String personType;
    private static RecordType personTypeRT;
    private static RecordType brochureRequestRecordType;

    private static Brochure_Request__c testBR;
    private static Code__c testNissanBrochure;
    private static Code__c testInfinitiBrochure;
    private static Account acct;
    
    public static void InitializeData() {
        personType = System.Label.AccRTMaritz;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        brochureRequestRecordType = [select id, name 
                                     from recordtype 
                                     where name = 'Brochure Request' 
                                     and sobjecttype = 'Brochure_Request__c' limit 1];

        testNissanBrochure = new Code__c(Type__c = 'Nissan_Brochure', Description__c = '2012 Nissan Test Vehicle', Code__c = '1234567890');
        testInfinitiBrochure = new Code__c(Type__c = 'Infiniti_Brochure', Description__c = '2012 Infiniti Test Vehicle', Code__c = '0987654321');

        insert testNissanBrochure;
        insert testInfinitiBrochure;
        
        acct = new Account();
        acct.customer_Id__c = 'testId1';
        acct.FirstName = 'Test';
        acct.LastName = 'User1';
        acct.RecordTypeId = personTypeRT.id;
        insert acct;

        testBR = new Brochure_Request__c();
    }
    
    static testMethod void TestBrochureRequest_ModifyBrochure() {
        System.debug('***** TestBrochureRequest_ModifyBrochure *****');
        
        InitializeData();
        Test.startTest();
            
            PageReference objPageRef = Page.BrochureRequest;
            Controller_BrochureRequest objController;
    
            // Select options in drop-down lists
            Test.setCurrentPage(objPageRef);
            objController = new Controller_BrochureRequest(new ApexPages.StandardController(testBR));
            List<SelectOption> options;
                        
            options = objController.NissanBrochures;
            options = objController.InfinitiBrochures;
            
            objController.brochureRequest.Account_Name__c = acct.Id;
            objController.brochureRequest.RecordTypeId = brochureRequestRecordType.Id;
            objController.brochureRequest.Nissan_Model_1__c = testNissanBrochure.Description__c;
            objController.brochureRequest.Infiniti_Model_1__c = testInfinitiBrochure.Description__c;

            // Save Brochure Request
            objController.doSaveBrochureRequest();
            
            testBR = [Select Id, Nissan_Model_1__c, Infiniti_Model_1__c
                      From Brochure_Request__c 
                      Where Nissan_Model_1__c = :testNissanBrochure.Description__c];
            System.assert(testBR.Nissan_Model_1__c == testNissanBrochure.Description__c);
            System.assert(testBR.Infiniti_Model_1__c == testInfinitiBrochure.Description__c);
            
            // Test Exception
            objController.brochureRequest.Nissan_Model_1__c = testNissanBrochure.Description__c;
            objController.brochureRequest.Nissan_Model_2__c = testNissanBrochure.Description__c;
            objController.doSaveBrochureRequest();
            System.assert(ApexPages.hasMessages());
            
            objController = null;

            Test.stopTest();
    }
}