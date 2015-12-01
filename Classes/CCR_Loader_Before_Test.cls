/**********************************************************************
Name: CCR_Loader_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test CCR Loader Before Trigger
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 2/21/2012 Created 
***********************************************************************/
@isTest
private class CCR_Loader_Before_Test {

    static testMethod void myUnitTest() {
	    Code__c code = new Code__c(Type__c = 'GL_Code', Code__c = 'ThisIsAGLCode', Description__c = 'C');
	    insert code;

	    Case c = new Case(Legacy_Case_Number__c = 'CA4000001',
	                      Case_External_Id__c = 'CA4000001',
	                      RecordTypeId = '012F0000000y9y7');
	    insert c; 
	    
	    CAD_Loader__c cad = new CAD_Loader__c(CHECK_ISSUE_DATE_CYMD__c = '20121221', 
										    CHECK_NUMBER__c = '*131*', 
										    DOCUMENT_ID__c = 'CA4000001');
		insert cad;
	   	
	    Test.startTest();
		
	    	List<CCR_Loader__c> ccr = new List<CCR_Loader__c> { new CCR_Loader__c(DOCUMENT_ID__c = 'CA4000001', CHECK_AMT__c = '100', GL_ACCT_PGM__c = 'ThisIsAGLCode', CUST_LSTNAME__c = 'CUSTLASTNAMECUSTLASTNAMECUSTLASTNAME'),
	    														new CCR_Loader__c(DOCUMENT_ID__c = 'CA4000002', CHECK_AMT__c = '100', GL_ACCT_PGM__c = 'somethingelse', CUST_LSTNAME__c = 'CUSTLASTNAME')};
	    	insert ccr;
		
	    Test.stopTest();
    }
}