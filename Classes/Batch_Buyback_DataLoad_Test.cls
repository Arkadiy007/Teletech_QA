/**********************************************************************
Name: Batch_Buyback_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_Buyback_DataLoad.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 02/06/2012 Created 
***********************************************************************/
@isTest
private class Batch_Buyback_DataLoad_Test {

    static testMethod void myUnitTest() {
	    RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        RecordType Dealer = [Select id from RecordType where Name=: system.label.Dealer and SobjectType = 'Account' limit 1];
	    ID bbRTid = '012F0000000yCk4';
	    
        Account testDealer = new Account();
        testDealer.Name = 'testDealer';
        testDealer.Dealer_Code__c = 'DLR!!';
        testDealer.RecordTypeId = Dealer.id;
        insert testDealer;
        
    	List<Vehicle__c> testVehicles = new List<Vehicle__c> {
    		new Vehicle__c(Name = 'VIN01000010000101'),
			new Vehicle__c(Name = 'VIN01000010000102')
		};
        insert testVehicles;
        
		List<Case> testCases = new List<Case> {
			new Case(AccountID = testDealer.ID, RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[0].Id),
			new Case(AccountID = testDealer.ID, RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[0].Id),
			new Case(AccountID = testDealer.ID, RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[1].Id)
		};
		insert testCases;
		
		List<Buyback__c> testBuybacks = new List<Buyback__c> {
			new Buyback__c(RecordTypeId = bbRTid, Case__c = testCases[0].ID, Vehicle__c = testVehicles[0].Id),
			new Buyback__c(RecordTypeId = bbRTid, Case__c = testCases[1].ID, Vehicle__c = testVehicles[0].Id),
			new Buyback__c(RecordTypeId = bbRTid, Case__c = testCases[2].ID, Vehicle__c = testVehicles[1].Id)
		};
		insert testBuybacks;
		
		List<Stage_SMM__c> testSMMs = new List<Stage_SMM__c> {
			new Stage_SMM__c(Successful__c = 'T', Vehicle_Identification_Number__c = 'VIN01000010000101', Sold_Amount__c = 100, Dealer_Code__c = 'DLR!!'),
			new Stage_SMM__c(Successful__c = 'T', Vehicle_Identification_Number__c = 'VIN01000010000102', Sold_Amount__c = 200, Dealer_Code__c = 'DLR@@', Dealer_Name__c = 'DLR@@'),
			new Stage_SMM__c(Successful__c = 'T', Vehicle_Identification_Number__c = 'VIN01000010000102', Sold_Amount__c = 300, Dealer_Code__c = 'DLR##', Dealer_Name__c = 'DLR##'),
			new Stage_SMM__c(Successful__c = 'T', Vehicle_Identification_Number__c = 'VIN01000010000103', Sold_Amount__c = 400, Dealer_Code__c = 'DLR$$', Dealer_Name__c = 'DLR$$')
		};
		insert testSMMs;
		
		Test.startTest();
        Batch_Buyback_DataLoad batch = new Batch_Buyback_DataLoad();
        batch.query = 'Select Vehicle_Identification_Number__c, ' + 
							'Sold_Date__c, ' + 
							'Sold_Amount__c, ' + 
							'Id, Name, ' + 
							'LastModifiedDate, ' + 
							'Dealer_Code__c, ' + 
							'Dealer_Name__c, ' + 
							'CreatedDate, ' + 
							'Contract_Type__c, ' + 
							'Contract_Number__c, ' + 
							'Centre_Type__c, ' + 
							'Centre_Arrival_Date__c, ' + 
							'Buyback_Status__c, ' + 
							'Buyback_Indicator__c, ' + 
							'Business_Source_Code__c ' + 
						'From Stage_SMM__c ' + 
						'WHERE Successful__c = \'T\' Order by Vehicle_Identification_Number__c, Name';
        Database.executeBatch(batch);
        Test.stopTest();
        
        Boolean bFound = false;
        List<Buyback__c> buybacks = [Select Sold_Amount__c, Dealer_Code__c, Dealer__c, Vehicle_Identification_Number__c From Buyback__c Where ID in: testBuybacks];
        for (Buyback__c b : buybacks) {
        	System.Debug('***' + b.Vehicle_Identification_Number__c + ' ' + b.Sold_Amount__c);
        	if (b.Vehicle_Identification_Number__c == 'VIN01000010000101') {
        		bFound = true;
        		System.assert(b.Sold_Amount__c == 100);
        		System.assert(b.Dealer__c == testDealer.ID);
        	} else if (b.Vehicle_Identification_Number__c == 'VIN01000010000102')
        		System.assert(b.Sold_Amount__c == 300);
        }
        System.assert(bFound == true);
        
        Stage_SMM__c smm = [Select Successful__c From Stage_SMM__c Where ID =: testSMMs[3].ID];
        System.assert(smm.Successful__c == 'N');
    }
}