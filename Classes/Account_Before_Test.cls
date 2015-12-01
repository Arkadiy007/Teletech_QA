/**********************************************************************
Name: Account_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Account_Before Trigger.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Biswa Ray 02/01/2011 Created 
***********************************************************************/
@isTest
private class Account_Before_Test  {
    final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
    final static RecordType personType = [select id, name from recordtype where name =: System.Label.AccRTTMS and sobjecttype = 'Account' limit 1];
    
    static testmethod void testTriggerAccountBefore() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;
    	
        Account insertedAccount;
        Account preferredAccount = new Account();
        preferredAccount.name = 'Account';
        preferredAccount.RecordTypeId = dealerType.id;
        preferredAccount.Dealer_Code__c = 'Test';
        preferredAccount.Dealer_External_Id__c = 'Test_USA';
        insert preferredAccount; 
        
        Account preferredAccount2 = new Account();
        preferredAccount2.name = 'Account';
        preferredAccount2.RecordTypeId = dealerType.id;
        preferredAccount2.Dealer_Code__c = '*Test*';
        preferredAccount2.Dealer_External_Id__c = '*Test*_USA';
        insert preferredAccount2; 
        
        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'firstname';
        account.PersonMailingPostalCode = '21204';
        account.RecordTypeId = personType.id;
        account.Preferred_Dealer_Code__c = 'Test';
        account.PersonMailingState = 'CO';
        account.PersonMailingStreet = 'New';
        insert account;
        
        Test.startTest();
        account.Preferred_Dealer_Id__c = preferredAccount2.Id;
        update account;
        Test.stopTest();
        
        insertedAccount = [select id, Preferred_Dealer_Code__c
                           from Account
                           where Id =: account.Id];
        System.assert(insertedAccount.Preferred_Dealer_Code__c == preferredAccount2.Dealer_Code__c);
    }

    static testmethod void testTriggerAccountBeforeUpdate() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;
    	State__c state2 = new State__c(Name = 'NY', Name__c = 'New York', Order__c = 1);
    	insert state2;

        Test.startTest();
        
        Account insertedAccount = new Account();
        insertedAccount.lastName = 'Account';
        insertedAccount.FirstName = 'firstname';
        insertedAccount.RecordTypeId = personType.id;
        insertedAccount.PersonMailingCity = 'City City';
        insertedAccount.PersonMailingPostalCode = '21204';
        insertedAccount.PersonMailingState = 'CO';
        insertedAccount.PersonMailingStreet = 'Street St.';
        insertedAccount.Do_Not_Mail_Indicator__c = true;
        
        insertedAccount.Home_Phone_Do_Not_Call__c = 'Y';
        insertedAccount.Other_Phone_Do_Not_Call_In__c = 'Y';
        insertedAccount.Mobile_Phone_Do_Not_Call_Indicator__c = 'Y';
        insert insertedAccount;
        
        Account account = [select Do_Not_Mail_Indicator__c, Previous_Mailing_Street__c, Home_Phone_Do_Not_Call__c, Other_Phone_Do_Not_Call_In__c, Mobile_Phone_Do_Not_Call_Indicator__c from Account where ID =: insertedAccount.ID];
        System.assert(account.Previous_Mailing_Street__c == NULL);
        System.assert(account.Home_Phone_Do_Not_Call__c == 'YES');
        
        insertedAccount.PersonMailingCity = 'Another City';
        insertedAccount.PersonMailingPostalCode = '12345';
        insertedAccount.PersonMailingState = 'NY';
        insertedAccount.PersonMailingStreet = 'Main St.';
        
        insertedAccount.Home_Phone_Do_Not_Call__c = 'N';
        insertedAccount.Other_Phone_Do_Not_Call_In__c = 'N';
        insertedAccount.Mobile_Phone_Do_Not_Call_Indicator__c = 'N';
        update insertedAccount;
        
        account = [select Do_Not_Mail_Indicator__c, Previous_Mailing_Street__c, Home_Phone_Do_Not_Call__c, Other_Phone_Do_Not_Call_In__c, Mobile_Phone_Do_Not_Call_Indicator__c from Account where ID =: account.ID];
        System.assert(account.Do_Not_Mail_Indicator__c == false);
        System.assert(account.Previous_Mailing_Street__c == 'Street St.');
        System.assert(account.Home_Phone_Do_Not_Call__c == 'NO');
        
        Test.stopTest();
    }

    static testmethod void testTriggerAccountBeforeInvalidState() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        List<Account> insertedAccount;
        DmlException dmle;
        
        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'firstname';
        account.PersonMailingPostalCode = '21204';
        account.RecordTypeId = personType.id;
        account.Preferred_Dealer_Code__c = 'Test';
        account.PersonMailingState = 'Co';
        account.PersonMailingCountry = '';
        
        try {
            Test.startTest();
            insert account;
            Test.stopTest();
        } catch (DmlException e) {
            dmle = e;
        }
        
        /* Get the Dealer Quotes Request object with fields filled in after trigger executes. */
        insertedAccount = [select id 
                           from Account
                           where LastName = 'Account' 
                           and FirstName = 'firstname'
                           and Preferred_Dealer_Code__c = 'Test'];
        
        /* Assert that the row was not inserted and an exception was caught. */
        System.assert(insertedAccount.isEmpty());
        System.assert(dmle != null);
    }
}