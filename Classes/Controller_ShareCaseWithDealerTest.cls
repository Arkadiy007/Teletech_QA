/**********************************************************************
Name: Controller_ShareCaseWithDealerTest 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Controller_ShareCaseWithDealer.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class Controller_ShareCaseWithDealerTest {

   
    static testmethod void test1() {
    
        RecordType maritzTypeRT = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
        RecordType caTypeRT = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        PageReference objPageRef = Page.ShareCaseWithDealer;
        Controller_ShareCaseWithDealer objController;
        String strURL;
        RecordType dealerRt = [SELECT Id FROM RecordType WHERE Name=: system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
        state__c state = new State__c(Name='AL', Name__c = 'Alabama');
        insert state;
        
        Account acct = new Account(FirstName = 'First', LastName = 'Last', PersonMailingCity = 'City', PersonMailingState = 'AL',
                                   PersonMailingPostalCode = '12345', RecordTypeId = maritzTypeRT.Id);
        insert acct;
        
        Account dealer = new Account();
            dealer.name = 'testDealerAccount';
            dealer.RecordTypeId = dealerRt.id;
            dealer.Dealer_Attributes_Text__c = 'EIX';
            dealer.Dealer_Code__c = '88888';
            
        insert dealer;

        Vehicle__c v = new Vehicle__c(Vehicle_Identification_Number__c = '1N345678901234567',
                                      Name = '1N345678901234567',
                                      Model_Year__c = '2009',
                                      Make_Name__c = 'MakeName',
                                      Model_Line_Name__c = 'ModelLineName');
        insert v;

        Case c = new Case(AccountId = acct.Id,
                          Vehicle_Name__c = v.Id,
                          RecordTypeId = caTypeRT.Id,
                          Servicing_Dealer__c = dealer.Id,
                          Subject = 'Test Subject');
        insert c;
        
        c = [select Id, DocumentId__c
             from case
             where id = :c.Id];

        objPageRef.getParameters().put('caseId', c.Id);
        Test.setCurrentPage(objPageRef);

        Test.startTest();       
        //test share case
        objController = new Controller_ShareCaseWithDealer();
        objController.emailServiceManager = true;
        objController.emailSalesManager = true;
        objController.emailPartsManager = true;
        objController.emailDOM = true;
        objController.emailFOM = true;
        objController.emailCSM = true;
        PageReference p = objController.shareAction();
            

        Test.stopTest();
    }
    
 }