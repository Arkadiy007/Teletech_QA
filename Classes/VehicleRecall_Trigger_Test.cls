/**********************************************************************
Name: VehicleRecall_Trigger_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of the Vehicle_Recall Before
and After Apex Triggers.

Related to: Vehicle Recall Trigger
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 03/15/2013 Created
***********************************************************************/

@isTest
private class VehicleRecall_Trigger_Test {
    static testMethod void TestVehicleRecall() {
        System.Debug('***** TestVehicleRecall *****');
        
      	List<Vehicle__c> testVehicles = new List<Vehicle__c> {
      	    new Vehicle__c(Vehicle_Identification_Number__c = '**VehicleVIN**')
    	};
        insert testVehicles;
        
        List<Account> testAccounts = new List<Account> {
        	new Account(RecordTypeId = '012A0000000OfI0IAK', Dealer_Code__c = 'RECALLTEST_DEALER', Name = 'Recall Test Dealer')
        };
        
        insert testAccounts;
        
        List<Vehicle_Recall__c> testVRs = new List<Vehicle_Recall__c> {
            new Vehicle_Recall__c(Recall_Identifier__c = 'TESTRECALL_ZYX',Effective_Date__c = System.today()),
            new Vehicle_Recall__c(Recall_Identifier__c = 'TESTRECALL_XYZ', Vehicle_Identification_Number__c = testVehicles[0].Vehicle_Identification_Number__c,
                                  Recall_Primary_Description__c = 'Desc ITB-123', Effective_Date__c = System.today(),
                                  Dealer_Submitted_Claim_Code__c = 'RECALLTEST_DEALER')
        };
    
    	test.startTest();
        insert testVRs;
    	test.stopTest();
    }
}