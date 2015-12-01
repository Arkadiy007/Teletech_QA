/**********************************************************************
Name: Batch_OneTime_Set_DNC_Fields_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_OneTime_Set_DNC_Fields.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 04/17/2014 Created 
***********************************************************************/
@isTest
private class Batch_OneTime_Set_DNC_Fields_Test  {

    static testMethod void Batch_OneTime_Set_DNC_Fields_Test() {
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
        account.do_not_email_in__c = 'YES';
        account.alternate_email_do_not_email__c = 'YES';
        account.home_phone_do_not_call__c = 'true';
        account.mobile_phone_do_not_call_indicator__c = 'true';
        account.other_phone_do_not_call_in__c = 'true';

        
        insert account;

        Account account2 = new Account();
        account2.lastName = 'Account2';
        account2.FirstName = 'firstname2';
        account2.PersonMailingPostalCode = '21204';
        account2.RecordTypeId = '012A0000000wu5hIAA';
        account2.Preferred_Dealer_Code__c = 'Test';
        account2.PersonMailingState = 'CO';
        account2.PersonMailingStreet = 'New';
        account2.do_not_email_in__c = 'NO';
        account2.alternate_email_do_not_email__c = 'NO';
        account2.home_phone_do_not_call__c = 'false';
        account2.mobile_phone_do_not_call_indicator__c = 'false';
        account2.other_phone_do_not_call_in__c = 'false';
        
        
        insert account2;



        System.assert(account.Do_Not_Email_CB__c == false);
        
        Test.startTest();
            Batch_OneTime_Set_DNC_Fields batch = new Batch_OneTime_Set_DNC_Fields();
            Database.executeBatch(batch);
        Test.stopTest();
        
        Account insertedAccount = [select id, Do_Not_Email_CB__c, Alternate_Email_Do_Not_Email_CB__c, Home_Phone_Do_Not_Call_CB__c,
                            Mobile_Do_Not_Call_CB__c, Work_Phone_Do_Not_Call_CB__c
                           from Account
                           where Id =: account.Id];
                           
        System.assert(insertedAccount.Do_Not_Email_CB__c == true);
        System.assert(insertedAccount.Alternate_Email_Do_Not_Email_CB__c == true);
        System.assert(insertedAccount.Home_Phone_Do_Not_Call_CB__c == true);
        System.assert(insertedAccount.Mobile_Do_Not_Call_CB__c == true);
        System.assert(insertedAccount.Work_Phone_Do_Not_Call_CB__c == true);
       
        Account insertedAccount2 = [select id, Do_Not_Email_CB__c, Alternate_Email_Do_Not_Email_CB__c, Home_Phone_Do_Not_Call_CB__c,
                            Mobile_Do_Not_Call_CB__c, Work_Phone_Do_Not_Call_CB__c
                           from Account
                           where Id =: account2.Id];
                           
        System.assert(insertedAccount2.Do_Not_Email_CB__c == false);
        System.assert(insertedAccount2.Alternate_Email_Do_Not_Email_CB__c == false);
        System.assert(insertedAccount2.Home_Phone_Do_Not_Call_CB__c == false);
        System.assert(insertedAccount2.Mobile_Do_Not_Call_CB__c == false);
        System.assert(insertedAccount2.Work_Phone_Do_Not_Call_CB__c == false);
        


        
     } 
     
 }