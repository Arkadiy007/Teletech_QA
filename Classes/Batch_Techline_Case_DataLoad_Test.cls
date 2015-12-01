/**********************************************************************
Name: Batch_Techline_Case_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_Techline_Case_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/22/2011 Created 
***********************************************************************/
@isTest
private class Batch_Techline_Case_DataLoad_Test {

    static testMethod void Batch_Techline_Case_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        insert testVehicles;

        List<Stage_Case__c> SCList = new List<Stage_Case__c>();
        
        Stage_Case__c sc1 = new Stage_Case__c(SFDC_Action_Code__c = 'P',
                                                Origination_Source__c = 'Informatica',
                                                Origination_Type__c = 'Techline',
                                                VIN__c = 'VIN01000010000100',
                                                Tow_Mileage__c = '1',
                                                Service_Provider_ETA__c ='1',
                                                Reopen_Count__c = 999,
                                                First_Name__c = 'ZYXABC'); 
        SCList.add(sc1);

        insert SCList; 
        
        Test.startTest();
    
            Batch_Techline_Case_DataLoad batch = new Batch_Techline_Case_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}