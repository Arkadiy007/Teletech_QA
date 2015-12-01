/**********************************************************************
Name: Controller_ByVinsInAccount_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Controller_ByVinsInAccount.cls.
 
======================================================
History: 

VERSION  AUTHOR       DATE     DETAIL
1.0 -   Vivek Batham 10/06/2015 Created 
***********************************************************************/
@isTest
private class Controller_ByVinsInAccount_Test {

     static testMethod void testByVinsInAccount() {
        ByVinsInAccount_TestUtil.TestData();
        Test.startTest();
        Controller_ByVinsInAccountComponent component = new Controller_ByVinsInAccountComponent();
        
        Controller_ByVinsInAccount controller = new Controller_ByVinsInAccount(new ApexPages.StandardController(ByVinsInAccount_TestUtil.testAccount));
        
        component.ByVinsInAccountController = controller.getThis();
        System.Debug(component.ByVinsInAccountController);
        
        component.BatchNumber = 1;
        
        component.ResponseOutput = 'There is error';
        System.Debug(component.ResponseOutput);
        
        component.doSearch();

        Test.stopTest();
        
      }
}