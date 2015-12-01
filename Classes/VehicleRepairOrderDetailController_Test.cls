@isTest
private class VehicleRepairOrderDetailController_Test {

    static Account testAccount;
    static Account testDealer;
    static List<Vehicle__c> testVehicles;
    static List<String> testVINs;
    
    static testmethod void testWarrantydetail(){
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('desc', 'Test Description');
        ApexPages.currentPage().getParameters().put('covPayType', 'Test Coverage Pay Type');
        ApexPages.currentPage().getParameters().put('transdt',  Datetime.now().format());
        ApexPages.currentPage().getParameters().put('vrOpenDt', Datetime.now().format());
        ApexPages.currentPage().getParameters().put('vehMileage', '765467');
        ApexPages.currentPage().getParameters().put('dealerNo', '0806');
        ApexPages.currentPage().getParameters().put('claimLine', '8989');
        ApexPages.currentPage().getParameters().put('woNumber', '765467');
        ApexPages.currentPage().getParameters().put('olStatusCode', 'Open');
        ApexPages.currentPage().getParameters().put('cFirstName', 'FName');
        ApexPages.currentPage().getParameters().put('cLastName', 'LName');
        ApexPages.currentPage().getParameters().put('cStreetAdd1', 'Str Add 1');
        ApexPages.currentPage().getParameters().put('cStreetAdd2', 'Add2');
        ApexPages.currentPage().getParameters().put('cCity', 'FR');
        ApexPages.currentPage().getParameters().put('cState', 'TN');
        ApexPages.currentPage().getParameters().put('cZip', '37064');
                
        VehicleRepairOrderDetailController controller = new VehicleRepairOrderDetailController();
        System.assert(controller.servInfo.PNC_Code_Description__c!= null);  
        
    
    }
    
    static testmethod void testWarrantydetailNegativeTest(){
        Test.startTest();
        
        VehicleRepairOrderDetailController controller = new VehicleRepairOrderDetailController();
        System.assert(controller.servInfo.PNC_Code_Description__c == null);  
        
    
    }
    
}