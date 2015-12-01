/**********************************************************************
Name: Testnotorcomments_controller 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for notorcomments_controller .
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class Testnotorcomments_controller {
    
    
    public static testmethod void test1(){
    
         RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
                system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
         Account dealerAccount = new Account();
            dealerAccount.name = 'testDealerAccount';
            dealerAccount.RecordTypeId = dealer.id;
            dealerAccount.Dealer_Attributes_Text__c = 'EIX';
            dealerAccount.Dealer_Code__c = '88888';
            insert dealerAccount;
    
          Notor__c notor = new Notor__c(First_Name__c = 'Test', Email_Address__c = 'ab@cd.com', Dealership_Administrator_Email__c= 'testdealer@abc.com', Dealer_Name__c ='Test Dealer', Dealer_Code__c ='08064',
                                     City__c = 'Franklin', Case_Reason__c = 'TestReason', Case_Origin__c = 'Web', Call_Reason__c='Defect', 
                                     Address__c ='522 S 3rd', Address_2__c = 'Nashville', Account_Number__c= '765489');
          insert notor;
          
          
          ApexPages.currentPage().getParameters().put('Id', notor.Id);
          
          ApexPages.StandardController controller = new ApexPages.StandardController(notor);
          
          notorcomments_controller ntrCntrller = new notorcomments_controller(controller);
          
          ntrCntrller.Go();
          ntrCntrller.commentType = 'Internal';
          
          ntrCntrller.Go();
          ntrCntrller.oncancel();
      
      }
        
      
     public static testmethod void test2(){
    
         RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
                system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
         Account dealerAccount = new Account();
            dealerAccount.name = 'testDealerAccount';
            dealerAccount.RecordTypeId = dealer.id;
            dealerAccount.Dealer_Attributes_Text__c = 'EIX';
            dealerAccount.Dealer_Code__c = '88888';
            insert dealerAccount;
    
          Notor__c notor = new Notor__c(First_Name__c = 'Test', Email_Address__c = 'ab@cd.com', Dealership_Administrator_Email__c= 'testdealer@abc.com', Dealer_Name__c ='Test Dealer', Dealer_Code__c ='08064',
                                     City__c = 'Franklin', Case_Reason__c = 'TestReason', Case_Origin__c = 'Web', Call_Reason__c='Defect', 
                                     Address__c ='522 S 3rd', Address_2__c = 'Nashville', Account_Number__c= '765489');
          insert notor;
          
          
          ApexPages.currentPage().getParameters().put('Id', notor.Id);
          
          ApexPages.StandardController controller = new ApexPages.StandardController(notor);
          
          notorcomments_controller ntrCntrller = new notorcomments_controller(controller);
          
          ntrCntrller.Go();
          ntrCntrller.commentType = 'External';
          
          ntrCntrller.Go();
          ntrCntrller.oncancel();
          
      }
 
       
}