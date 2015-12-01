@isTest
private class WarrantyInformationSection_Test {
     
     static Account testAccount;
     static Account testDealer;
     static List<Vehicle__c> testVehicles;
     static List<String> testVINs;
     final static String DEALER_CODE = 'DLRCD!@';
    
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
    
    }
       
    static testmethod void testSectionTest1(){
        createTestData();
        Test.startTest();
        ApexPages.StandardController cont = new ApexPages.StandardController(testVehicles[0]);
        WarrantyInformationSectionController controller = new WarrantyInformationSectionController(cont);
        controller.onload();
        List<WarrantyInformationWrapper> wrtys = controller.lstWarranties;
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.getTotalPages();
        controller.getPageNumber();
               
        Test.stopTest();
    }
    
    static testmethod void testAllRecordsTest1(){
        createTestData();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('searchAll', 'Yes');
        ApexPages.StandardController cont = new ApexPages.StandardController(testVehicles[0]);
        WarrantyInformationSectionController controller = new WarrantyInformationSectionController(cont);
        controller.onload();
        List<WarrantyInformationWrapper> wrtys = controller.lstWarranties;
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.getTotalPages();
        controller.getPageNumber();       	
               
        Test.stopTest();
    }
    
   
    
}