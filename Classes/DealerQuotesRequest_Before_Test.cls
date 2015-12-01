/**********************************************************************
Name: DealerQuotesRequest_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "DealerQuotesRequest_Before" Trigger.

Related Class : DealerQuotesRequestClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     04/14/2011 Created
***********************************************************************/

@isTest
private class DealerQuotesRequest_Before_Test  {
    
    static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    
    static void testdata() {
        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Customer_ID__c = CUSTOMER_ID;
        insert account;

        lead.lastname = 'leadTest';
        lead.Customer_ID__c = CUSTOMER_ID;
        insert lead;

        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        insert dealer;
   }
    
   static testmethod void testTriggerDealerQuotesRequest_Before() {
        testdata();
        
        dqr = new Dealer_Quotes_Request__c();
        dqr.Customer_ID__c = CUSTOMER_ID;
        dqr.Dealer_Id__c = DEALER_ID;
        
        /* Start the test, this changes governor limit context to that of trigger rather than test. */        
        Test.startTest();
        
        /* Insert the Dealer Quotes Request records that cause the trigger to execute.*/ 
        insert dqr;
        
        /* Stop the test, this changes limit context back to test from trigger.  */
        Test.stopTest();
        
        /* Get the Dealer Quotes Request object with fields filled in after trigger executes. */
        dqr = [select id, Account__c, Lead__c, DQR_Dealer__c 
               from Dealer_Quotes_Request__c 
               where customer_id__c = :CUSTOMER_ID 
               and dealer_id__c = :DEALER_ID];
        
        /* Assert that the Account, Lead, and DQR Dealer fields contains the proper value now. */
        System.assert(dqr.Account__c != null);
        System.assert(dqr.Lead__c != null);
        System.assert(dqr.DQR_Dealer__c != null);  
      }      
      
      static testmethod void testTriggerDealerQuotesRequest_Before_Negative() {
        dqr = new Dealer_Quotes_Request__c();
        dqr.Customer_ID__c = DEALER_ID;
        dqr.Dealer_Id__c = CUSTOMER_ID;
        
        /* Start the test, this changes governor limit context to that of trigger rather than test. */        
        Test.startTest();
        
        /* Insert the Campaign Member records that cause the trigger to execute. */ 
        insert dqr;
        
        /* Stop the test, this changes limit context back to test from trigger. */
        Test.stopTest();
        
        /* Assert that the Account, Lead, and DQR Dealer fields contains the proper value now. */
        System.assert(dqr.Account__c == null);
        System.assert(dqr.Lead__c == null);
        System.assert(dqr.DQR_Dealer__c == null);  
        
      } 
}