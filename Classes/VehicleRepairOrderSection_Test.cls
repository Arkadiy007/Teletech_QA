@isTest
private class VehicleRepairOrderSection_Test {

     static Account testAccount;
     static Account testDealer;
     static List<Vehicle__c> testVehicles;
     static List<String> testVINs;
     final static String DEALER_CODE = 'DLRCD!@';
     
     
    public class RepairOrderMock implements WebServiceMock {
        public void doInvoke(
          Object stub,
          Object request,
          Map<String, Object> response,
          String endpoint,
          String soapAction,
          String requestName,
          String responseNS,
          String responseName,
          String responseType) {
          Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element respElement = new Nna360RepairOrderServiceSoap.GetRepairOrdersByVINResponse_element();
          Nna360RepairOrderServiceSoap.RepairOrderResponse repOrderResponse = new Nna360RepairOrderServiceSoap.RepairOrderResponse();
          repOrderResponse.Message = 'Success';
          repOrderResponse.Status = 'Success';
          
          Nna360RepairOrderServiceSoap.ArrayOfRepairOrder arrRepOrders = new Nna360RepairOrderServiceSoap.ArrayOfRepairOrder();
          Nna360RepairOrderServiceSoap.ArrayOfVehicle arrVehs = new Nna360RepairOrderServiceSoap.ArrayOfVehicle();
          
          Nna360RepairOrderServiceSoap.Vehicle[] vehicles = new Nna360RepairOrderServiceSoap.Vehicle[] {
                    new Nna360RepairOrderServiceSoap.Vehicle(),
                    new Nna360RepairOrderServiceSoap.Vehicle(),
                    new Nna360RepairOrderServiceSoap.Vehicle(),
                    new Nna360RepairOrderServiceSoap.Vehicle()
                };
         
         Nna360RepairOrderServiceSoap.ArrayOfOpCode arrOpCode = new Nna360RepairOrderServiceSoap.ArrayOfOpCode();  
         
         Nna360RepairOrderServiceSoap.OpCode[] opCodes = new Nna360RepairOrderServiceSoap.OpCode[]{
             new Nna360RepairOrderServiceSoap.OpCode()
         }; 
         
         Nna360RepairOrderServiceSoap.ArrayOfPart arrPart = new Nna360RepairOrderServiceSoap.ArrayOfPart();
         String[] parts = new String[]{'part1','part2'};
         arrPart.Part = parts ;
         
         opCodes[0].OpCodeDesc = 'Test Desc';   
         opCodes[0].Parts = arrPart; 
         
         arrOpCode.OpCode = opCodes;
                 
         
         Nna360RepairOrderServiceSoap.RepairOrder[] repOrders = new Nna360RepairOrderServiceSoap.RepairOrder[]{
                     new Nna360RepairOrderServiceSoap.RepairOrder()
                     
                };
                
          repOrders[0].DealerCode = DEALER_CODE ;
          repOrders[0].ContactId = '98787';
          repOrders[0].FirstName = 'fName';
          repOrders[0].LastName  = 'lName';
          repOrders[0].Line1     = 'Line1';
          repOrders[0].Line2     = 'Line2';
          repOrders[0].City      = 'City';
          repOrders[0].State     = 'TN';
          repOrders[0].Zip       = '37064';
          repOrders[0].HomePhone = '98765789';
          repOrders[0].WorkPhone = '897657809';
          repOrders[0].EmailAddress= 'a@b.com';
          repOrders[0].CloseDate = String.valueOf(Date.today().addDays(-10));
          repOrders[0].Mileage   = '9898';
          repOrders[0].PartsAmount = 100;
          repOrders[0].TotalAmount = 100;
          repOrders[0].CustNameType = 'CType';
          repOrders[0].CustLaborAmount = 100;
          repOrders[0].CustPartsAmount = 100;
          repOrders[0].CustMiscAmount= 100;
          repOrders[0].WarrantyLaborAmount = 100;
          repOrders[0].WarrantyPartsAmount = 100;
          repOrders[0].WarrantyMiscAmount= 100;
          repOrders[0].InternalLaborAmount = 100;
          repOrders[0].InternalPartsAmount = 100;
          repOrders[0].InternalMiscAmount = 100;
          repOrders[0].Details = arrOpCode;
          arrRepOrders.RepairOrder = repOrders;
          
          vehicles[0].RepairOrders = arrRepOrders;
          vehicles[0].VIN = 'VIN01000010000100';
          vehicles[1].RepairOrders = arrRepOrders;
          vehicles[1].VIN = 'VIN01000010000101';
          vehicles[2].RepairOrders = arrRepOrders;
          vehicles[2].VIN = 'VIN01000010000102';
          
          arrVehs.Vehicle = vehicles;
          
          repOrderResponse.Vehicles = arrVehs;
          respElement.RepairOrderResponse = repOrderResponse;
          
          response.put('response_x', respElement);      
        }
    }
          
     static void createTestData(){
        testAccount = new Account();
        testAccount.name = 'Test Account';
        testAccount.Last_Retrieve_Date__c = Date.newInstance(2010, 12, 21);
        insert testAccount; 
        
        testDealer = new Account();
        testDealer.name = 'Test Dealer';
        testDealer.Dealer_Code__C = DEALER_CODE;
        insert testDealer; 
        
        testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000102'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000103'));
        insert testVehicles;
        testVINs = new List<String> {'VIN01000010000101', 'VIN01000010000102', 'VIN01000010000103'};
        
        List<Vehicle_Ownership_History__c> testOwners = new List<Vehicle_Ownership_History__c>();
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[0].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[1].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[2].ID));
        insert testOwners;
        
        Integration_Settings__c settings = new Integration_Settings__c(Name=Label.Claims_Webservice, Endpoint_URL__c = 'https://b2bws.dev.na.nissan.biz', IsActive__c = true, Username__c = 'abc@xyz.com', Password__c = 'pwd123', Timeout__c = 30000 );
        insert settings;
    
    }
    
    static testmethod void testSectionTest1(){
        createTestData();
        
        Test.startTest();
        
        ApexPages.StandardController cont = new ApexPages.StandardController(testVehicles[0]);
        VehicleRepairOrderSectionController controller = new VehicleRepairOrderSectionController(cont);
        Test.setMock(WebServiceMock.class, new VehicleRepairOrderSection_Test.RepairOrderMock());  
        controller.onload();
        List<ServiceHistoryWrapHelper> SRHs= controller.lstServiceHistories;
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.getTotalPages();
        controller.getPageNumber();
        System.assert(SRHs.size() > 0);
               
        Test.stopTest();
    }
    
    static testmethod void testSectionWithNoResponse(){
        createTestData();
        
        Test.startTest();
        ApexPages.StandardController cont = new ApexPages.StandardController(testVehicles[0]);
        VehicleRepairOrderSectionController controller = new VehicleRepairOrderSectionController(cont);
        controller.onload();
        List<ServiceHistoryWrapHelper> SRHs = controller.lstServiceHistories;
        
        System.assert(SRHs.size() == 0);
                       
        Test.stopTest();
    }

}