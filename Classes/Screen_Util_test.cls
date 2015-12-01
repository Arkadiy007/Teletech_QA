/**********************************************************************
Name: Screen_Util_test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for Screen_Util Apex Class 

Related to:Screen_Util
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Koseikina Anna 06/19/2015 created 
***********************************************************************/
@istest
public class Screen_Util_test { 

   static testMethod void testgetPersonMailingStreet() {   
	   RecordType myRecordType = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1];
        
        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'firstname';
        account.Customer_ID__c = '143770668';
        account.Recordtypeid = myRecordType.Id;  
          account.PersonMailingStreet='testAccount1';
       insert account ;

      
       Screen_Util.getPersonMailingStreet(account.id);  

   }
   static testMethod void testgetVCSEscalationEmails() {   
        
        Case caseItem = new Case();
        caseItem.Primary_Reason__c = 'test';
		 caseItem.Secondary_Reason__c = 'test';
        caseItem.Severity__c = 'Level 1';
       insert caseItem ;
	   Code__c testCode = new Code__c(Description__c = 'test: test', Type__c = 'VCS_Validation');
	   insert testCode;
      
       Screen_Util.getVCSEscalationEmails(caseItem.id); 
	   Screen_Util.getVCSTemplateId(caseItem.id);  

   }
}