/**********************************************************************
Name: Account_DNC_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Account_DNC_Before Trigger
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 04/17/2014 Created 
***********************************************************************/
@isTest
private class Account_DNC_Before_Test  {

    static testMethod void Account_DNC_Before_Test() {
        State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
        insert state;
        

        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'firstname';
        account.PersonMailingPostalCode = '21204';
        account.RecordTypeId = '012A0000000wu5hIAA';
        account.Preferred_Dealer_Code__c = 'Test';
        account.PersonMailingState = 'CO';
        account.PersonMailingStreet = 'New';
        account.do_not_email_in__c = 'NO';
        account.home_phone_do_not_call__c = 'NO';
        account.mobile_phone_do_not_call_indicator__c = 'NO';
        account.other_phone_do_not_call_in__c = 'NO';
        account.alternate_email_do_not_email__c = 'NO';
        account.Do_Not_Email_CB__c = false;
        account.Alternate_Email_Do_Not_Email_CB__c = false;
        account.Home_Phone_Do_Not_Call_CB__c = false;
        account.Mobile_Do_Not_Call_CB__c = false;
        account.Work_Phone_Do_Not_Call_CB__c = false;
        
        insert account;
        account.do_not_email_in__c = 'YES';
        account.home_phone_do_not_call__c  = 'YES';
        account.mobile_phone_do_not_call_indicator__c = 'YES';
        account.other_phone_do_not_call_in__c = 'YES';
        account.alternate_email_do_not_email__c = 'YES';
        
        update account;

        
        
         Account account2 = new Account();
        account2.lastName = 'Account';
        account2.FirstName = 'firstname';
        account2.PersonMailingPostalCode = '21204';
        account2.RecordTypeId = '012A0000000wu5hIAA';
        account2.Preferred_Dealer_Code__c = 'Test';
        account2.PersonMailingState = 'CO';
        account2.PersonMailingStreet = 'New';
        account2.do_not_email_in__c = 'YES';
        account2.home_phone_do_not_call__c = 'NO';
        account2.mobile_phone_do_not_call_indicator__c = 'NO';
        account2.other_phone_do_not_call_in__c = 'NO';
        account2.alternate_email_do_not_email__c = 'NO';
        account2.Do_Not_Email_CB__c = false;
        account2.Alternate_Email_Do_Not_Email_CB__c = false;
        account2.Home_Phone_Do_Not_Call_CB__c = false;
        account2.Mobile_Do_Not_Call_CB__c = false;
        account2.Work_Phone_Do_Not_Call_CB__c = false;
        
        insert account2;
        account2.Work_Phone_Do_Not_Call_CB__c = true;
        account2.Mobile_Do_Not_Call_CB__c  = true;
        account2.Home_Phone_Do_Not_Call_CB__c = true;
        account2.Alternate_Email_Do_Not_Email_CB__c = true;
        account2.Do_Not_Email_CB__c = true;
        
        update account2;
        
        

        
        Account insertedAccount2 = [select id, do_not_email_in__c, home_phone_do_not_call__c, mobile_phone_do_not_call_indicator__c,
                                other_phone_do_not_call_in__c , alternate_email_do_not_email__c from Account where Id =: account2.Id];  
             
        System.assert(insertedAccount2.do_not_email_in__c == 'YES');
        System.assert(insertedAccount2.home_phone_do_not_call__c == 'true');
        System.assert(insertedAccount2.mobile_phone_do_not_call_indicator__c == 'true');
        System.assert(insertedAccount2.other_phone_do_not_call_in__c == 'true');
        System.assert(insertedAccount2.alternate_email_do_not_email__c == 'YES');
        
        account2.Work_Phone_Do_Not_Call_CB__c = false;
        account2.Mobile_Do_Not_Call_CB__c  = false;
        account2.Home_Phone_Do_Not_Call_CB__c = false;
        account2.Alternate_Email_Do_Not_Email_CB__c = false;
        account2.Do_Not_Email_CB__c = false;
                           
        update account2;
        insertedAccount2 = [select id, do_not_email_in__c, home_phone_do_not_call__c, mobile_phone_do_not_call_indicator__c,
                                other_phone_do_not_call_in__c , alternate_email_do_not_email__c from Account where Id =: account2.Id];  
             
        System.assert(insertedAccount2.do_not_email_in__c == 'NO');
        System.assert(insertedAccount2.home_phone_do_not_call__c == 'false');
        System.assert(insertedAccount2.mobile_phone_do_not_call_indicator__c == 'false');
        System.assert(insertedAccount2.other_phone_do_not_call_in__c == 'false');
        System.assert(insertedAccount2.alternate_email_do_not_email__c == 'NO');
                          
 
        
        
        
        
        

        
        
     } 
     
 }