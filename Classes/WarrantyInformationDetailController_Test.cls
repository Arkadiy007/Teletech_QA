@isTest
private class WarrantyInformationDetailController_Test {

    static Account testAccount;
    static Account testDealer;
    static List<Vehicle__c> testVehicles;
    static List<String> testVINs;
    
    static testmethod void testWarrantydetail(){
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('desc', 'Test Description');
        ApexPages.currentPage().getParameters().put('title', 'Test Title');
        ApexPages.currentPage().getParameters().put('expDate', '07/07/2015');
        ApexPages.currentPage().getParameters().put('bCode', '65789');
        ApexPages.currentPage().getParameters().put('expMiles', '765467');
        ApexPages.currentPage().getParameters().put('modelYr', '2014');
        
        WarrantyInformationDetailController controller = new WarrantyInformationDetailController();
        System.assert(controller.wrtyInfo.Warranty_Description__c != null);  
        
    
    }
    
    static testmethod void testWarrantydetailNegativeTest(){
        Test.startTest();
        
        WarrantyInformationDetailController controller = new WarrantyInformationDetailController();
        System.assert(controller.wrtyInfo.Warranty_Description__c == null);  
        
    
    }
    
}