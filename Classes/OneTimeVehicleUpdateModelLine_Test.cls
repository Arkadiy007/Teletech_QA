/**********************************************************************
Name: OneTimeVehicleUpdateModelLine_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Updating model line /series based on values from code table

 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 1-31-2014
***********************************************************************/   
   
@isTest
private class OneTimeVehicleUpdateModelLine_Test {
   
    static testMethod void OneTimeVehicleUpdateModelLine_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
    
        Code__c code = new Code__c();
        code.Type__c = 'MOD LINE/SERIES';
        code.Description__c = 'S1';
        code.Value__c = 'ABC';
        insert code;
    
        Test.startTest();
    
            OneTimeVehicleUpdateModelLine batch = new OneTimeVehicleUpdateModelLine();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
}