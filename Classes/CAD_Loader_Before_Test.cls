/**********************************************************************
Name: CAD_Loader_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for CAD_Loader_Before.trigger.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/22/2011 Created 
***********************************************************************/
@isTest
private class CAD_Loader_Before_Test {

    static testMethod void CAD_Loader_Before_Test() {  	
	  	List<CAD_Loader__c> cads = new List<CAD_Loader__c>();
		
	    CAD_Loader__c cad = new CAD_Loader__c(Consumer_First_Name__c = 'First',
	                                          Consumer_Last_Name__c = 'Last',
	                                          Originator_Code__c = 'AE',
	                                          Full_Model_Year__c = '095',
	                                          VIN_Number__c = '12345678901234567'); 
	    cads.add(cad);
	    
	    Test.startTest();
	
	    	insert cads; 
	
	    Test.stopTest();
    }   
    
}