/**********************************************************************
Name: WebToCaseNissan_Test 
Copyright © notice: Nissan Motor Company.
=====================================================================
Purpose: Test class for WebToCaseNissan.
=====================================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        07/10/2014    Created

***********************************************************************/
@isTest
private class WebToCaseNissan_Test {
     
     
     public static testmethod void testWebtoCase(){
        
        Account acc = TestData_Utils.createPersonAccount(); 
        insert acc;
        
        Account dealerAcc = TestData_Utils.createTestDealer();
        insert dealerAcc;  
        

        ApexPages.currentPage().getParameters().put('firstName', 'test');
        ApexPages.currentPage().getParameters().put('lastName', 'Rohdenburg');
        ApexPages.currentPage().getParameters().put('emailAddress', 'test@abc.org');
        ApexPages.currentPage().getParameters().put('address1', 'test Street Address');
        ApexPages.currentPage().getParameters().put('city', 'Louisville');
        ApexPages.currentPage().getParameters().put('address1', 'test Street Address');
        ApexPages.currentPage().getParameters().put('state', 'KY');
        ApexPages.currentPage().getParameters().put('zip', '40202');
        ApexPages.currentPage().getParameters().put('hdnQuestionText', 'Nissan Products');
        ApexPages.currentPage().getParameters().put('comments', 'Test Comments');
        
        Test.starttest();          
        WebToCaseNissan wtc = new WebToCaseNissan();        
        wtc.submitNissanForm();  
        
        Test.stopTest();
        
        System.assert(([Select Id from Case where First_name__c = 'test' and Last_name__c = 'Rohdenburg']).size() > 0);
        
     }
      
      
 }