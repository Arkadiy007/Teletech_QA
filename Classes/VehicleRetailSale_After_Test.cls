/**********************************************************************
Name: VehicleRetailSale_After_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for VehicleRetailSaleClass Apex Class 

Related to:VehicleRetailSale_After and VehicleRetailSaleClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Biswa Ray 01/17/2011 Created
1.1 - Munawar Esmail 08/23/2011 updated to include more test cases
1.2 - Koseikina Anna 04/28/2015 updated to cover creation of a Case by condition
***********************************************************************/

@isTest
private Class VehicleRetailSale_After_Test{
    static testMethod void testTrigger(){
        
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
        Insert vehicle;
                      	 	              
        /*
           Switch to the runtime context
        */
       Test.startTest();
        
        /* 
           Create a vehicleRetailSale to test the functionality
        */
        List<Vehicle_Retail_Sale__c> vrsIns= new List<Vehicle_Retail_Sale__c>();
        
        Vehicle_Retail_Sale__c vehicleRetailSale = new Vehicle_Retail_Sale__c();
        Vehicle_Retail_Sale__c vehicleRetailSale2 = new Vehicle_Retail_Sale__c();
        Vehicle_Retail_Sale__c vehicleRetailSale3 = new Vehicle_Retail_Sale__c();
          
            vehicleRetailSale.Owner_Id__c = acc.id;
            vehicleRetailSale.Vehicle_Identification_Number__c = vehicle.id;
            vehicleRetailSale.Rewind_Indicator__c = true;
            vrsIns.add(vehicleRetailSale);
            
            vehicleRetailSale2.Owner_Id__c = acc2.id;
            vehicleRetailSale2.Vehicle_Identification_Number__c = vehicle.id;
            vrsIns.add(vehicleRetailSale2);
            
            insert vrsIns;
            
            vehicleRetailSale3.Owner_Id__c = acc3.id;
            vehicleRetailSale3.Vehicle_Identification_Number__c = vehicle.id;
            vehicleRetailSale3.Purchase_Date__c = date.Today()+2;
			
			insert vehicleRetailSale3;
			
       /*
           Switch back to the original context
        */
       Test.stopTest();
              
        /*
           query for all vehicle ownership s created and assert comments were added correctly
        */
    	List<Vehicle_Ownership_History__c> vehicleOwnerHistoryList = [select Owner__c,Vehicle_Retail_Sale_Id__c,Vehicle__c, End_Date__c 
       																from Vehicle_Ownership_History__c
       																where Vehicle_Retail_Sale_Id__c in : vrsIns];
       
        List<Vehicle_Ownership_History__c> vehicleOwnerHistoryListEndDate = [select Id, End_Date__c, Vehicle_Retail_Sale_Id__c
                                                        from Vehicle_Ownership_History__c
                                                        where End_Date__c = null 
                                                        and Vehicle__c in (select Vehicle_Identification_Number__c
                                                                            from Vehicle_Retail_Sale__c
                                                                            where Id = :vehicleRetailSale3.Id)];
       //This will test if vehicle ownership history record gets added
       system.assert(vehicleOwnerHistoryList.size() == 2);
       
       //This will test rewind indicator case	
       for (Vehicle_Ownership_History__c voh : vehicleOwnerHistoryList) {
       	if(voh.Vehicle_Retail_Sale_Id__c == vehicleRetailSale.Id)
       	{
			system.assert(voh.End_Date__c == date.Today());
       	}     	
       }
       //This will test if the related vehicle ownership history record gets end date updated
       for (Vehicle_Ownership_History__c vohEnd : vehicleOwnerHistoryListEndDate) {
       	if(vohEnd.Vehicle_Retail_Sale_Id__c == vehicleRetailSale2.Id) {      	
   	   		system.assert(vohEnd.End_Date__c == date.Today()+2);
        }
       }
   	}

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
            case caseItem = [select ID, Survey_Type__c from Case limit 1];
			System.assertEquals(caseItem.Survey_Type__c, 'Sales Priority E');
			
       /*
           Switch back to the original context
        */
       Test.stopTest();
              
        
   	}
       
}