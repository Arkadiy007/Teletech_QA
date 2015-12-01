/**********************************************************************
Name: CATEG_Loader_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for CATEG_Loader_Before.trigger.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/22/2011 Created 
***********************************************************************/
@isTest
private class CATEG_Loader_Before_Test {

    static testMethod void CATEG_Loader_Before_Test() {
		RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];
		
	    Case c = new Case(Legacy_Case_Number__c = 'CA4000001',
	                      Case_External_Id__c = 'CA4000001',
	                      RecordTypeId = rt.Id);
	    	    
	    insert c; 
    		
	    CATEG_Loader__c cat = new CATEG_Loader__c(Document_Id__c = 'CA4000001',
	                                              Concern_Code__c = 'OA',
	                                              Category_Code__c = 'AD',
	                                              Subcategory_Code__c = '121000',
	                                              Symptom_Code__c = 'YI',
	                                              Root_Cause__c = 'Root'); 
	    
	    Test.startTest();
	
	    	insert cat;
	
	    Test.stopTest();
    }   
    
}