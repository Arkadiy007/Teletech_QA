/**********************************************************************
Name: Controller_ByVinsInVehicle_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Controller_ByVinsInVehicle.cls.
 
======================================================
History: 

VERSION  AUTHOR       DATE     DETAIL
1.0 -   Vivek Batham 10/06/2015 Created 
***********************************************************************/
@isTest
private class Controller_ByVinsInVehicle_Test {
    
     static testMethod void testByVinsInVehicle() {
        ByVinsInAccount_TestUtil.TestData();
        System.Debug('*** testVehicles ' + ByVinsInAccount_TestUtil.testVehicles);
        Test.startTest();
                
        Controller_ByVinsInVehicle controller = new Controller_ByVinsInVehicle(new ApexPages.StandardController(ByVinsInAccount_TestUtil.testVehicles[1]));
        controller.doSearch();

        Test.stopTest();
    }
}