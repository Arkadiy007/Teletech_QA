/**********************************************************************
Name: BuyBack_Trigger_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "BuyBack" Apex Trigger.

Related to: BuyBack Trigger
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 01/30/2012 Added test method for updating Case Upon creating a new Buyback record
***********************************************************************/

@isTest
private class BuyBack_Trigger_Test {
    static testMethod void BuyBack_CaseUpdateTest() {
        System.Debug('***** BuyBack_CaseUpdateTest *****');
        
	    RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
		ID bbRTid = '012F0000000yCk4';
	    
        Vehicle__c vehicle = new Vehicle__c(Name = '10293847565647382');
        insert vehicle;
        
		Case testCase = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = vehicle.Id);
		insert testCase;
		
		Buyback__c testBuyback = new Buyback__c(RecordTypeId = bbRTid, Case__c = testCase.ID, Vehicle__c = vehicle.Id);
		
		test.startTest();
		insert testBuyback;
		test.stopTest();
		
		Case c = [Select Buyback__c, Stage_Status__c From Case WHERE ID =: testCase.ID];
		System.assert(c.Buyback__c == testBuyback.ID);
		System.assert(c.Stage_Status__c == 'Update Processing');
    }
    
    static testMethod void BuyBack_TaskCreateTest() {
        System.Debug('***** BuyBack_TaskCreateTest *****');
        
	    RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
		RecordType vppRT = [select id, name from recordtype where name = 'Goodwill VPP' and sobjecttype = 'Buyback__c' limit 1];
	    
        Vehicle__c vehicle = new Vehicle__c(Name = '10293847565647382');
        insert vehicle;
        
		Case testCase = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = vehicle.Id);
		insert testCase;
		
		Buyback__c[] testBuybacks = new Buyback__c[]{new Buyback__c(RecordTypeId = vppRT.Id, Case__c = testCase.ID, Vehicle__c = vehicle.Id),
													new Buyback__c(RecordTypeId = vppRT.Id, Case__c = testCase.ID, Vehicle__c = vehicle.Id)};
		insert testBuybacks;
		
		test.startTest();
		testBuybacks[0].CAVPP_Claim_No__c = '1234';
		testBuybacks[1].CAVPP_Claim_No__c = '4321';
		update testBuybacks;
		test.stopTest();
		
		System.assert([Select Subject From Task WHERE WhatID =: testCase.ID and Subject like 'Complete VPP Goodwill Process%'].size() >= 2);
		
		Case c = [Select Stage_Status__c From Case WHERE ID =: testCase.ID];
		System.assert(c.Stage_Status__c == 'Update Processing');
		
    }
    
    static testMethod void BuyBack_SyncVehicleVINTest() {
        System.Debug('***** BuyBack_SyncVehicleVINTest *****');
        
	    RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
	    
    	List<Vehicle__c> testVehicles = new List<Vehicle__c> {
    		new Vehicle__c(Name = 'VIN01000010000101'),
			new Vehicle__c(Vehicle_Identification_Number__c = 'VIN01000010000102'),
			new Vehicle__c(Name = 'VIN02000010000103', Vehicle_Identification_Number__c = 'VIN02000010000103'),
			new Vehicle__c(Name = 'VIN02000010000104', Vehicle_Identification_Number__c = 'VIN02000010000104')
		};
        insert testVehicles;
        
		List<Case> testCases = new List<Case> {
			new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[0].Id),
			new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[1].Id),
			new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[2].Id)
		};
		insert testCases;
		
		List<Buyback__c> testBuybacks = new List<Buyback__c> {
			new Buyback__c(Case__c = testCases[0].ID, Vehicle__c = testVehicles[0].Id),
			new Buyback__c(Case__c = testCases[1].ID, Vehicle_Identification_Number__c = testVehicles[1].Vehicle_Identification_Number__c),
			new Buyback__c(Case__c = testCases[2].ID, Vehicle_Identification_Number__c = 'VIN01000010000106')
		};
		
		test.startTest();
		//sync when insert
		insert testBuybacks;
        for (Buyback__c b : [Select Vehicle__c, Vehicle__r.Name, Vehicle_Identification_Number__c From Buyback__c Where ID in: testBuybacks])
        	System.assert(b.Vehicle_Identification_Number__c == b.Vehicle__r.Name);
        
        //sync when update
        testBuybacks[0].Vehicle__c = testVehicles[2].Id; 						//change vehicle to VIN02000010000103
        testBuybacks[1].Vehicle_Identification_Number__c = 'VIN02000010000104';	//change vehicle to VIN02000010000104
        testBuybacks[2].Vehicle_Identification_Number__c = 'VIN02000010000105';	//change vehicle to VIN02000010000105
        update testBuybacks;
        for (Buyback__c b : [Select Vehicle__c, Vehicle__r.Name, Vehicle_Identification_Number__c From Buyback__c Where ID in: testBuybacks]) {
        	System.assert(b.Vehicle_Identification_Number__c.contains('VIN020000'));
        	System.assert(b.Vehicle_Identification_Number__c == b.Vehicle__r.Name);
        }
		
		//behavior when update null values
        testBuybacks[0].Vehicle__c = null; 
        testBuybacks[1].Vehicle_Identification_Number__c = null;
        testBuybacks[2].Sold_Amount__c = 100;
        update testBuybacks;
        List<Buyback__c> bbs = [Select Vehicle__c, Vehicle__r.Name, Vehicle_Identification_Number__c From Buyback__c Where ID in: testBuybacks];
        System.assert(bbs[0].Vehicle_Identification_Number__c == null && bbs[0].Vehicle__r.Name == null && bbs[1].Vehicle_Identification_Number__c == null && bbs[1].Vehicle__r.Name == null);
        System.assert(bbs[2].Vehicle_Identification_Number__c == 'VIN02000010000105');
        
		test.stopTest();
    }
    
    static testMethod void BuyBack_DeleteTest() {
        System.Debug('***** BuyBack_CaseUpdateTest *****');
        
        Id caseCART = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
   		ID bbRTid= Schema.SObjectType.Buyback__c.getRecordTypeInfosByName().get('DRT Resolution').getRecordTypeId();
        
        Vehicle__c vehicle = new Vehicle__c(Name = '10293847565647382');
        insert vehicle;
        
		Case testCase = new Case(RecordTypeId = caseCART, Status = 'New', Origin = 'Phone', Vehicle_Name__c = vehicle.Id);
		insert testCase;
		
		Buyback__c testBuyback = new Buyback__c(RecordTypeId = bbRTid, Case__c = testCase.ID, Vehicle__c = vehicle.Id);
		insert testBuyback;
		
		testCase.Stage_Status__c = 'Add Processing';
		update testCase;
		
		test.startTest();
		delete testBuyback;
		test.stopTest();
		
		Case c = [Select Buyback__c, Stage_Status__c From Case WHERE ID =: testCase.ID];
		System.assert(c.Stage_Status__c == 'Update Processing');
    }
    
     static testMethod void BuyBack_UnDeleteTest() {
        System.Debug('***** BuyBack_CaseUpdateTest *****');
        
        Id caseCART = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
   		ID bbRTid= Schema.SObjectType.Buyback__c.getRecordTypeInfosByName().get('DRT Resolution').getRecordTypeId();        
	       
        Vehicle__c vehicle = new Vehicle__c(Name = '10293847565647382');
        insert vehicle;
        
		Case testCase = new Case(RecordTypeId = caseCART, Status = 'New', Origin = 'Phone', Vehicle_Name__c = vehicle.Id);
		insert testCase;
		
		Buyback__c testBuyback = new Buyback__c(RecordTypeId = bbRTid, Case__c = testCase.ID, Vehicle__c = vehicle.Id);
		insert testBuyback;
		
		delete testBuyback;
		
		testCase.Stage_Status__c = 'Add Processing';
		update testCase;
		
		test.startTest();
		undelete testBuyback;
		test.stopTest();
		
		Case c = [Select Buyback__c, Stage_Status__c From Case WHERE ID =: testCase.ID];
		System.assert(c.Stage_Status__c == 'Update Processing');
    }
}