/**********************************************************************
Name: CCG_Case_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_CCG_Case_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Munawar Esmail 11/03/2011 Created 
***********************************************************************/
@isTest
private class CCG_Case_DataLoad_Test {

    static testMethod void CCGCase_DataLoad_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        insert testVehicles;

	  	List<Stage_Case__c> SCList = new List<Stage_Case__c>();
		
	    Stage_Case__c sc1 = new Stage_Case__c(Successful__c = 'T', SFDC_Action_Code__c = System.label.Stage_Action_Add,
	 											Origination_Source__c = System.label.Origination_Type_CCG,
	 											Origination_Type__c = System.label.Origination_Type_CCG,
	        									VIN__c = 'VIN01000010000100',
	        									Tow_Mileage__c = '1',
	        									Service_Provider_ETA__c ='1',
	        									Reopen_Count__c = 999); 
	    SCList.add(sc1);
	    
	    Stage_Case__c sc2 = new Stage_Case__c(Successful__c = 'T', SFDC_Action_Code__c = System.label.Stage_Action_Add,
	 											Origination_Source__c = System.label.Origination_Type_CCG,
	 											Origination_Type__c = System.label.Origination_Type_CCG,
	        									Mileage__c = '1',
	        									VIN__c = 'VIN01000010000101',
	        									Service_Provider_ETA__c ='1',
	        									Reopen_Count__c = 999); 
	    SCList.add(sc2);
	    
	    Stage_Case__c sc3 = new Stage_Case__c(Successful__c = 'T', SFDC_Action_Code__c = System.label.Stage_Action_Add,
	 											Origination_Source__c = System.label.Origination_Type_CCG,
	 											Origination_Type__c = System.label.Origination_Type_CCG,
	        									VIN__c = 'VIN01000010000101',
	        									Reopen_Count__c = 999); 
	    SCList.add(sc3);
	    
	    insert SCList; 
	    
	    Test.startTest();
	
	        Batch_CCG_Case_DataLoad BCDL = new Batch_CCG_Case_DataLoad();
		    String WClause = 'Successful__c = \'T\' AND Origination_Type__c = \'' + System.label.Origination_Type_CCG + '\' AND Origination_Source__c = \'' + System.label.Origination_Type_CCG + '\' ';
		    BCDL.query = BuildSoqlUtil.getCreatableFieldsSOQL('Stage_Case__c', WClause);
	        Database.executeBatch(BCDL);
	
	    Test.stopTest(); 
	    
	  	System.AssertEquals(database.countquery('select count() from Stage_Case__c where Reopen_Count__c = 999 and Successful__c = \'Y\''),3);
	        
    }   
    
}