/**********************************************************************
Name: Batch_Welcome_HotAlert_Tests 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for Batch_Welcome_HotAlert Apex Class 

Related to:Batch_Welcome_HotAlert
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Koseikina Anna 05/06/2015 created to cover creation of a Case by condition
***********************************************************************/
@isTest
private class Batch_Welcome_HotAlert_Tests {
static testMethod void testCaseCreation(){
        
        Account acc = new Account();
        acc.Name = 'Test Account1234';
        Insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2345';
        Insert acc2;         
           
       	Account acc3 = new Account();
        acc3.Name = 'Test Account3456';
        Insert acc3;
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name='Test Vehicle1234';
		vehicle.Make_Name__c = 'Nissan';
		vehicle.Model_Year__c = '2015';
		vehicle.Model_Line_Name__c = 'Altima';
        Insert vehicle;
                      	 	              
        /*
           Switch to the runtime context
        */
       Test.startTest();
        
        /* 
           Create a vehicleRetailSale to test the functionality
        */
        List<Vehicle_Retail_Sale__c> vrsIns= new List<Vehicle_Retail_Sale__c>();
		String vrsRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Vehicle_Retail_Sale__c.SObjectType, 'RDR');
        
		
        Vehicle_Retail_Sale__c vehicleRetailSale = new Vehicle_Retail_Sale__c();
          
            vehicleRetailSale.Owner_Id__c = acc.id;
            vehicleRetailSale.Vehicle_Identification_Number__c = vehicle.id;
            vehicleRetailSale.Rewind_Indicator__c = true;
			vehicleRetailSale.recordTypeId = vrsRecordTypeId;
			vehicleRetailSale.Purchase_Date__c = Date.newInstance(2015, 4, 27);
            vrsIns.add(vehicleRetailSale);
            
            insert vrsIns;
			Welcome_Calls__c welcomeCallsSetting = Welcome_Calls__c.getOrgDefaults();
			welcomeCallsSetting.Purchase_Date__c = null;
			upsert welcomeCallsSetting;
			Batch_Welcome_HotAlert batchJob = new Batch_Welcome_HotAlert();
			Database.executeBatch(batchJob);
			Test.stopTest();
            List<case> caseItem = [select ID, Survey_Type__c from Case];
			System.assertEquals(caseItem[0].Survey_Type__c, 'Sales Priority E');
			System.assertEquals(caseItem.size(), 2);
			
       /*
           Switch back to the original context
        */
       
              
        
   	}
}