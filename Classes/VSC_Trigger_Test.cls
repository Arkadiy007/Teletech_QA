/**********************************************************************
Name: VSC_Trigger_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "VSC" Apex Trigger.

Related to: VSC Trigger
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 01/30/2012 Created
***********************************************************************/

@isTest
private class VSC_Trigger_Test {
    static testMethod void VSC_SyncVehicleVINTest() {
        System.Debug('***** VSC_SyncVehicleVINTest *****');
        
    	List<Vehicle__c> testVehicles = new List<Vehicle__c> {
    		new Vehicle__c(Name = '**VehicleName**'),
			new Vehicle__c(Vehicle_Identification_Number__c = '**VehicleVIN**'),
			new Vehicle__c(Name = '**VehicleDiffName', Vehicle_Identification_Number__c = '**VehicleDiffName'),
			new Vehicle__c(Name = '**VehicleDiffVIN', Vehicle_Identification_Number__c = '**VehicleDiffVIN')
		};
        insert testVehicles;
        
		List<Vehicle_Service_Contract__c> testVSCs = new List<Vehicle_Service_Contract__c> {
			new Vehicle_Service_Contract__c(Policy_Number__c = 'VSC12341', Vehicle_Id__c = testVehicles[0].Id),
			new Vehicle_Service_Contract__c(Policy_Number__c = 'VSC12342', VIN__c = testVehicles[1].Vehicle_Identification_Number__c),
			new Vehicle_Service_Contract__c(Policy_Number__c = 'VSC12343', VIN__c = '**NEWIN1**')
		};
		
		test.startTest();
		//sync when insert
		insert testVSCs;
        for (Vehicle_Service_Contract__c b : [Select Vehicle_Id__c, Vehicle_Id__r.Name, VIN__c From Vehicle_Service_Contract__c Where ID in: testVSCs])
        	System.assert(b.VIN__c == b.Vehicle_Id__r.Name);
        
        //sync when update
        testVSCs[0].Vehicle_Id__c = testVehicles[2].Id; //change vehicle to VehicleDiffName
        testVSCs[1].VIN__c = '**VehicleDiffVIN';		//change vehicle to VehicleDiffVIN
        testVSCs[2].VIN__c = '**VehicleDiffNEW';		//change vehicle to VehicleDiffNEW
        update testVSCs;
        for (Vehicle_Service_Contract__c b : [Select Vehicle_Id__c, Vehicle_Id__r.Name, VIN__c From Vehicle_Service_Contract__c Where ID in: testVSCs]) {
        	System.assert(b.VIN__c.contains('**VehicleDiff'));
        	System.assert(b.VIN__c == b.Vehicle_Id__r.Name);
        }
		
		//behavior when update null values
        testVSCs[0].Vehicle_Id__c = null; 
        testVSCs[1].VIN__c = null;
        testVSCs[2].Application_Number__c = '9876';
        update testVSCs;
        List<Vehicle_Service_Contract__c> bbs = [Select Vehicle_Id__c, Vehicle_Id__r.Name, VIN__c From Vehicle_Service_Contract__c Where ID in: testVSCs];
        System.assert(bbs[0].VIN__c == null && bbs[0].Vehicle_Id__r.Name == null && bbs[1].VIN__c == null && bbs[1].Vehicle_Id__r.Name == null);
        System.assert(bbs[2].VIN__c == '**VehicleDiffNEW');
        
		test.stopTest();
    }
}