/**********************************************************************
Name: Batch_Cleanup_ServiceRepairHistory_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Cleanup for service repairhistory
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 2/17/2014
***********************************************************************/   
   
@isTest
private class Batch_Cleanup_ServiceRepairHistory_Test {
        static Account testDealer;
        static List<Vehicle__c> testVehicles;
        static List<String> testVINs;
        final static String DEALER_CODE = 'DLRCD!@';
        
    static testMethod void Batch_Cleanup_ServiceRepairHistory_Test () {

       
       
        Code__c code = new Code__c();
        code.Type__c = 'Cleanup_Days_Back';
        code.Code__c = 'Cleanup_Service_Repair_History';
        code.Description__c = '900';
        insert code;

        testDealer = new Account();
        testDealer.name = 'Test Dealer';
        testDealer.Dealer_Code__C = DEALER_CODE;
        insert testDealer; 
        
        testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000102'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000103'));
        insert testVehicles;
        
        List<Service_Repair_History__c> repairh = new List<Service_Repair_History__c>();
        Service_Repair_History__c d1 = new Service_Repair_History__c();
        d1.Vehicle_ID__c = testVehicles[0].ID;
        d1.Dealer_Number__c = DEALER_CODE;
        d1.Work_Order_Number__c = 'WO0@@';
        d1.Claim_Line_Number__c = '01';
        d1.Vehicle_Identification_Number__c = 'VIN01000010000101';
        d1.Transaction_Date__c = DateTime.newInstance(1999, 1, 1);
//        d1.Warranty_Claim_Line_Business_ID__c = existingClaim.Dealer_Number__c + '_' + existingClaim.Work_Order_Number__c + '_' + existingClaim.Vehicle_Identification_Number__c + '_' + existingClaim.Claim_Line_Number__c;
 
        repairh.add(d1); 
                
        insert repairh; 

        Test.startTest();
    
            Batch_Cleanup_ServiceRepairHistory batch = new Batch_Cleanup_ServiceRepairHistory();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
}