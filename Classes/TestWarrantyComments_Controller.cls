/**********************************************************************
Name: TestWarrantyComments_Controller 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for WarrantyComments_Controller.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestWarrantyComments_Controller {
    
    private static Account dealerAccount;
    private static Vehicle__c veh;
    private static Warranty_Case__c newCase;
    
    public static testmethod void test1(){
       
        CreateTestData();
        
        ApexPages.currentPage().getParameters().put('Id', newCase.Id);   
        ApexPages.StandardController controller = new ApexPages.StandardController(newCase);
        
        WarrantyComments_Controller wrtyCommnts = new WarrantyComments_Controller(controller);
        
        wrtyCommnts.commentType = 'Internal';
        wrtyCommnts.Go();
        wrtyCommnts.onCancel();
        
     }
     
      public static testmethod void test2(){
       
        CreateTestData();

        ApexPages.currentPage().getParameters().put('Id', newCase.Id);           
        ApexPages.StandardController controller = new ApexPages.StandardController(newCase);
        
        WarrantyComments_Controller wrtyCommnts = new WarrantyComments_Controller(controller);
        
        wrtyCommnts.commentType = 'External';
        wrtyCommnts.Go();
        wrtyCommnts.onCancel();
        
     }
     
     
     public static void CreateTestData(){
     
       RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
                system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
       dealerAccount = new Account();
            dealerAccount.name = 'testDealerAccount';
            dealerAccount.RecordTypeId = dealer.id;
            dealerAccount.Dealer_Attributes_Text__c = 'EIX';
            dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
   
        veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Altima';
        veh.Make_Name__c = 'Nissan';
        insert veh;
    
        newCase = new Warranty_Case__c();        
        newCase.Dealer__c=dealerAccount.Id;
        newCase.Vehicle__c = veh.Id;
        newCase.Repair_Work_Order__c = '123456';
        newCase.Job_Line_Number__c = 'A';
        newCase.Customer_Concern__c = 'Blah';
        newCase.Repair_Work_Order_Open_Date__c=Date.today();
        newCase.Vehicle_Mileage__c=12000;
        newCase.Primary_Failed_Part__c='12345';
        newCase.Requestor_s_Name__c='Aaron';
        newCase.Customer_Name__c='test';
        newCase.Parts_at_Cost__c='No';
        newCase.Force_Goodwill_Coverage__c='Yes';
        newCase.Parts__c=0;
        newCase.Labor__c=0;
        newCase.Expenses__c=1;
        newCase.Requestor_s_Phone_Number__c='5555555555';
        newCase.Internal_Comments__c='test';
        newCase.Approval_Information__c='';       
        newCase.Approval_Status__c='Approved';
        newCase.Normal_Approval__c='A';
        newCase.Repeat_Repair_Review__c='A';
        newCase.Mileage__c='A';
        newCase.Duplicate_Campaign_Different_Dealer__c='A';
        newCase.Goodwill_Approval__c='A';
        //HOST_Error_Message__c, HOST_Reference_Number__c,
        //Host_Comments__c
        newCase.HOST_Reference_Number__c = 'N12345678'; 
        
        insert newCase;
        
     }
}