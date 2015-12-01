/**********************************************************************
Name: Brochure_Request_After_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Brochure_Request_After Trigger.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 03/16/2011 Created 
***********************************************************************/
@isTest
private class Brochure_Request_After_Test  {
    static  testmethod void testTriggerBrochureRequestBefore() {
        RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
	RecordType brRT = [select id from recordtype where sobjecttype = 'Brochure_Request__c' and name = 'Brochure Request'];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;
		
        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'First';
        account.Undeliverable_Address_Indicator__c = false;
        account.PersonMailingPostalCode = '21204';
        account.PersonMailingStreet = 'PersonMailingStreet';
        account.PersonMailingCity  = 'PersonMailingCity';
        account.PersonMailingState = 'CO';
        account.RecordTypeId = personType.id;
        insert account;

        Brochure_Request__c brochure = new Brochure_Request__c();
        brochure.RecordTypeId = brRT.Id;
        brochure.nissan_model_1__c = 'Security Plus';
        brochure.account_name__c = account.id;
        
        Test.startTest();
        insert brochure;
        Test.stopTest();
    }
}