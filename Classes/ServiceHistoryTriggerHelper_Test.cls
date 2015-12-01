/**********************************************************************
Name: ServiceHistoryTriggerHelper_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test ServiceHistoryTriggerHelper
 
======================================================
History: 

VERSION AUTHOR     DATE       DETAIL
1.0 - Vivek Batham 2/21/2012 Created 
***********************************************************************/
@isTest
private class ServiceHistoryTriggerHelper_Test{
    
    static Vehicle__c vehRec;
    
    
    static testMethod void insertTest() {
       vehRec = new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101');
       insert vehRec;
       
        Test.startTest();
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingClaim = new Service_Repair_History__c();
        existingClaim.Vehicle_ID__c = vehRec.ID;
        existingClaim.Dealer_Number__c = '09087';
        existingClaim.Work_Order_Number__c = 'WO0@@';
        existingClaim.Claim_Line_Number__c = '01';
        existingClaim.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingClaim.Transaction_Date__c = DateTime.newInstance(1999, 1, 1);
        existingClaim.PNC_Code_Description__c = 'Test PNC Description';
        existingClaim.Warranty_Claim_Line_Business_ID__c = existingClaim.Dealer_Number__c + '_' + existingClaim.Work_Order_Number__c + '_' + existingClaim.Vehicle_Identification_Number__c + '_' + existingClaim.Claim_Line_Number__c;
        insert existingClaim;
        
        System.assert([Select Complaint_Description_2__c from Service_Repair_History__c where Id =: existingClaim.Id].Complaint_Description_2__c == 'Test PNC Description');
        Test.stopTest();
    
    }
    
    static testMethod void updateTest() {
       vehRec = new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101');
       insert vehRec;
       
        
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingClaim = new Service_Repair_History__c();
        existingClaim.Vehicle_ID__c = vehRec.ID;
        existingClaim.Dealer_Number__c = '09087';
        existingClaim.Work_Order_Number__c = 'WO0@@';
        existingClaim.Claim_Line_Number__c = '01';
        existingClaim.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingClaim.Transaction_Date__c = DateTime.newInstance(1999, 1, 1);
        existingClaim.PNC_Code_Description__c = 'Test PNC Description';
        existingClaim.Warranty_Claim_Line_Business_ID__c = existingClaim.Dealer_Number__c + '_' + existingClaim.Work_Order_Number__c + '_' + existingClaim.Vehicle_Identification_Number__c + '_' + existingClaim.Claim_Line_Number__c;
        insert existingClaim;
        
        Test.startTest();
        
        existingClaim.Complaint_Description__c = 'Complaint Test';
        update existingClaim;
        
        System.assert([Select Complaint_Description_2__c from Service_Repair_History__c where Id =: existingClaim.Id].Complaint_Description_2__c == 'Complaint Test');
        
        Test.stopTest();
    
    }
 }