/**********************************************************************
Name: Vehicle_Trigger_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Vehicle" Apex Trigger.

Related to: BuyBack Trigger
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 02/04/2012 Created
***********************************************************************/
@isTest
private class Vehicle_Trigger_Test {

    static testMethod void Vehicle_SyncNameVINTest() {
    	System.Debug('***** Vehicle_SyncNameVINTest *****');
    	
    	Code__c code1 = new Code__c(Code__c = '2013_84113', Secondary_Code__c='P01', Description__c = '08IT', Type__c = 'Head_Unit');
    	insert code1;
    	Code__c code2 = new Code__c(Code__c = '2014.5_20364', Secondary_Code__c='U02', Description__c = 'LCN2.kai', Type__c = 'Head_Unit');
    	insert code2;
    	
    	List<Vehicle__c> testVehicles = new List<Vehicle__c> {new Vehicle__c(Name = '**VehicleName**', Make_Name__c = 'NISSAN', Model_Code__c = '84113', Model_Year__c = '2013', Factory_Installed_Options__c ='B9P01H92'),
        													new Vehicle__c(Vehicle_Identification_Number__c = '**VehicleVIN**', Make_Name__c = 'NISSAN', Model_Code__c = '20364', Model_Year__c = '2014.5', Factory_Installed_Options__c ='B93U022L92')};
        //sync when insert
        test.startTest();
        insert testVehicles;
        
        for (Vehicle__c v : [Select Name, Vehicle_Identification_Number__c, Head_Unit__c From Vehicle__c Where ID in: testVehicles]){
        	System.assert(v.Vehicle_Identification_Number__c == v.Name);
        	System.assert(v.Head_Unit__c != null);
        }
        
        testVehicles[0].Head_Unit__c = '';
        testVehicles[1].Head_Unit__c = '';
        
        update testVehicles;	
		
		for (Vehicle__c v : [Select Name, Vehicle_Identification_Number__c, Head_Unit__c From Vehicle__c Where ID in: testVehicles]){
        	System.assert(v.Head_Unit__c != null);
        }       
    }
    /*
        //sync when update
        testVehicles[0].Name = '**VehicleDiffName';
        testVehicles[1].Vehicle_Identification_Number__c = '**VehicleDiffVIN';
        update testVehicles;
        for (Vehicle__c v : [Select Name, Vehicle_Identification_Number__c From Vehicle__c Where ID in: testVehicles]) {
        	System.assert(v.Vehicle_Identification_Number__c.contains('**VehicleDiff'));
        	System.assert(v.Vehicle_Identification_Number__c == v.Name);
        }
        
        //behavior when update null values
        testVehicles[0].Name = null;
        testVehicles[1].Vehicle_Identification_Number__c = null;
        update testVehicles;
        List<Vehicle__c> vehicles = [Select Name, Vehicle_Identification_Number__c From Vehicle__c Where ID in: testVehicles];
        System.assert(vehicles[0].Vehicle_Identification_Number__c == null);
        System.assert(vehicles[1].Vehicle_Identification_Number__c == '**VehicleDiffVIN');
        
        test.stopTest();
    }

    static testMethod void Vehicle_UpdateNameTest() {
    	System.Debug('***** Vehicle_UpdateNameTest *****');
    	Vehicle__c testVehicle = new Vehicle__c(Name = '**VehicleName**');
        insert testVehicle;
        
		Case c = new Case(Vehicle_Name__c = testVehicle.Id);
		insert c;
		Buyback__c b = new Buyback__c(Vehicle__c = testVehicle.Id, Case__c = c.Id);
		insert b;
        
        test.startTest();
        testVehicle.Name = '**VehicleDiffName';
        update testVehicle;
        test.stopTest();
        
		//test buyback_after trigger
		c = [Select Buyback__c From Case WHERE ID =: c.ID];
		System.assert(c.Buyback__c == b.ID);
    }
*/
}