/**********************************************************************
Name: CAT_Loader_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for CAT_Loader_Before.trigger.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/22/2011 Created 
***********************************************************************/
@isTest
private class CAT_Loader_Before_Test {

    static testMethod void CAT_Loader_Before_Test() {
		RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];
		
	    Case c = new Case(Legacy_Case_Number__c = 'CA4000001',
	                      Case_External_Id__c = 'CA4000001',
	                      RecordTypeId = rt.Id);
	    	    
	    insert c; 
    		
	    CAT_Loader__c cat = new CAT_Loader__c(Document_Id_Text__c = 'CA4000001',
	                                          Comment_Text__c = 'A comment.'); 
	    
	    Test.startTest();
	
	    	insert cat;
	
	    Test.stopTest();
    }
}