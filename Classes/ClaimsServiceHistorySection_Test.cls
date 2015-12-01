@isTest
private class ClaimsServiceHistorySection_Test {

     static Account testAccount;
     static Account testDealer;
     static List<Vehicle__c> testVehicles;
     static List<String> testVINs;
     final static String DEALER_CODE = 'DLRCD!@';
     
     
    public class ClaimsServHistoryMockImpl implements WebServiceMock {
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
          Nna360ClaimMasterServiceSoap.VehicleClaim_Output claimOutput = new Nna360ClaimMasterServiceSoap.VehicleClaim_Output();
          Nna360ClaimMasterServiceSoap.VehicleClaim[] claimResponse = new Nna360ClaimMasterServiceSoap.VehicleClaim[] {
                    new Nna360ClaimMasterServiceSoap.VehicleClaim(),
                    new Nna360ClaimMasterServiceSoap.VehicleClaim(),
                    new Nna360ClaimMasterServiceSoap.VehicleClaim(),
                    new Nna360ClaimMasterServiceSoap.VehicleClaim()
                };
                
                //ClaimData is null
                claimResponse[0].Vin = 'VIN01000010000100';
                //extisting claim
                claimResponse[1].Vin = 'VIN01000010000101';
                claimResponse[1].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
                    new Nna360ClaimMasterServiceSoap.Claim()
                };
                claimResponse[1].ClaimData[0].Vin = claimResponse[1].Vin;
                claimResponse[1].ClaimData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
                claimResponse[1].ClaimData[0].WorkOrderNumber = 'WO0@@';
                claimResponse[1].ClaimData[0].TransactionDate = '2012-12-21 00:00:00.0';
                claimResponse[1].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
                    new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
                };
                claimResponse[1].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
                
                //new claim data
                claimResponse[2].Vin = 'VIN01000010000102';
                claimResponse[2].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
                    new Nna360ClaimMasterServiceSoap.Claim()
                };
                claimResponse[2].ClaimData[0].Vin = claimResponse[2].Vin;
                claimResponse[2].ClaimData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
                claimResponse[2].ClaimData[0].WorkOrderNumber = 'WO0@#';
                claimResponse[2].ClaimData[0].VehicleRepairCloseDate = '0001-01-01 00:00:00.0';
                claimResponse[2].ClaimData[0].VehicleMileageNumber = '10000';
                claimResponse[2].ClaimData[0].OwnerIndicator = 'Y';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
                    new Nna360ClaimMasterServiceSoap.WarrantyClaimLine(),
                    new Nna360ClaimMasterServiceSoap.WarrantyClaimLine(),
                    new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
                };
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].SubmittedAmount = '100.00';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].PaidAmount = '100.00';
                //AAB 09/29/2014 - adding test claim line data
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].OriginalPurchaseDate = '2013-08-23 00:00:00.0';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].OriginalPurchaseMiles = '61854';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[0].PrimaryFailedPartDescription = 'SEAL-OILDRIVE PINION';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[1].ClaimLineNumber = '02';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[1].ClaimServiceTechNumber = 'C';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[1].PrimaryFailedPart = 'P';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[2].ClaimLineNumber = '02';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[2].ClaimServiceTechNumber = 'D';
                claimResponse[2].ClaimData[0].WarrantyClaimLineData[2].PrimaryFailedPart = 'P';
                
                //ClaimLine is null
                claimResponse[3].Vin = 'VIN01000010000103';
                claimResponse[3].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
                    new Nna360ClaimMasterServiceSoap.Claim()
                };
          claimOutput.VehicleClaimData = claimResponse;
          response.put('response_x', claimOutput);      
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
        ClaimsServiceHistorySectionController controller = new ClaimsServiceHistorySectionController(cont);
        Test.setMock(WebServiceMock.class, new ClaimsServiceHistorySection_Test.ClaimsServHistoryMockImpl());  
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
        ClaimsServiceHistorySectionController controller = new ClaimsServiceHistorySectionController(cont);
        controller.onload();
        List<ServiceHistoryWrapHelper> SRHs = controller.lstServiceHistories;
        
        System.assert(SRHs.size() == 0);
                       
        Test.stopTest();
    }

}