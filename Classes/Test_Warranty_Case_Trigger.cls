/**
* This class contains unit tests for Test_Warranty_Case_Trigger
* Author: Aaron Bessey
* Date 10/20/2014
*/
@isTest
public class Test_Warranty_Case_Trigger {
    public static User createUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Warranty Agent']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', warranty_app_amount__c='25', warranty_vcan_delete__c=true );
        insert u;
        return u;
    }
    
    public static Account createDealer()
    {
        Account dealer = new Account();
        dealer.RecordTypeId = '012A0000000OfI0';
        dealer.Name = 'Bessey Nissan';
        dealer.Dealer_Code__c = '1234';
        insert dealer;
        return dealer;
    }
    
    public static Vehicle__c createVehicle()
    {
        Vehicle__c veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Altima';
        veh.Make_Name__c = 'Nissan';
        insert veh;
        return veh;
    }    
    public static Warranty_Case__c createWarrantyCase(Account dealer, Vehicle__c veh, String status)
    {
        Warranty_Case__c newCase = new Warranty_Case__c();
        
        newCase.Dealer__c=dealer.Id;
        newCase.Vehicle__c = veh.Id;
        newCase.Repair_Work_Order__c = '123456';
        newCase.Job_Line_Number__c = 'A';
        newCase.Customer_Concern__c = 'Blah';
        newCase.Repair_Work_Order_Open_Date__c=Date.today();
        newCase.Vehicle_Mileage__c=12000;
        newCase.Primary_Failed_Part__c='12345';
        newCase.Requestor_s_Name__c='Aaron';
        newCase.Customer_Name__c='test';
        newCase.Parts_at_Cost__c= 'No';
        newCase.Force_Goodwill_Coverage__c = 'No';
        newCase.Parts__c=0;
        newCase.Labor__c=0;
        newCase.Expenses__c=1;
        newCase.Requestor_s_Phone_Number__c='5555555555';
        newCase.Internal_Comments__c='test';
        newCase.Approval_Information__c='';
        if(status==null)
        {
            status = 'Approved';
        }
        newCase.Approval_Status__c=status;
        newCase.Normal_Approval__c='A';
        newCase.Repeat_Repair_Review__c='A';
        newCase.Mileage__c='A';
        newCase.Duplicate_Campaign_Different_Dealer__c='A';
        newCase.Goodwill_Approval__c='A';
        //HOST_Error_Message__c, HOST_Reference_Number__c,
        //Host_Comments__c
        newCase.HOST_Reference_Number__c = 'N12345678'; 
        
        insert newCase;
        
        //Get Latest Case
        newCase = queryWarrantyCase(newCase.Id);  
        
        return newCase;
    }
    public static Warranty_Case__c queryWarrantyCase (Id caseId)
    {
        return [select ID, Name, Dealer__c, Dealer_Code__c, Vehicle__c, Vehicle__r.Name, Repair_Work_Order__c, 
                Job_Line_Number__c, Customer_Concern__c,
                Repair_Work_Order_Open_Date__c,
                Vehicle_Mileage__c,
                Primary_Failed_Part__c,
                Requestor_s_Name__c,
                Customer_Name__c,
                Parts_at_Cost__c,
                Force_Goodwill_Coverage__c,
                Parts__c,
                Labor__c,
                Expenses__c,
                Total_Amount_Approved__c,
                Requestor_s_Phone_Number__c,
                Internal_Comments__c,
                Approval_Information__c,
                Approval_Status__c, 
                Normal_Approval__c,
                Repeat_Repair_Review__c,
                Mileage__c,
                Duplicate_Campaign_Different_Dealer__c,
                Goodwill_Approval__c,
                HOST_Error_Message__c, HOST_Reference_Number__c,
                Host_Comments__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                Vehicle_Campaign1__c,
                Vehicle_Campaign1__r.Name,
                isVCANUpdate__c, isSystemUpdate__c, isApprovalStatusChanged__c
                from Warranty_Case__c where Id =:caseId];
    }
    
    private static testmethod void main() {
        System.debug('Main code test block');
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Approved');
            Test.startTest();
            
            newCase.Parts__c = 52;
            update newCase;
            
            u.warranty_app_amount__c = null;
            update u;
            newCase.HOST_Reference_Number__c = 'N12345678';             
            update newCase;
            
           /* newCase.Repair_Work_Order__c = '654321';
            update newCase;*/
            
            u.warranty_app_amount__c = '1';
            update u;
            
            newCase.isVCANUpdate__c = true;
            newCase.Approval_Information__c = null;
            newCase.HOST_Error_Message__c = '123457777';
            newCase.HOST_Reference_Number__c = 'N12345678';
            update newCase;
            
            newCase.isVCANUpdate__c = false;
            newCase.HOST_Error_Message__c = '1234';
            newCase.HOST_Reference_Number__c = 'N12345678';
            newCase.Approval_Information__c = null;
            update newCase;
            
            newCase.isVCANUpdate__c = false;
            newCase.Vehicle_Mileage__c = null;
            newCase.HOST_Reference_Number__c = 'N12345678';             
            update newCase;
            
            newCase.Parts__c = 2;
            newCase.Vehicle_Mileage__c = 1200;
            newCase.isVCANUpdate__c = false;
            newCase.HOST_Error_Message__c = '1234555';
            newCase.HOST_Reference_Number__c = 'N12345678';
            update newCase;
            
            newCase.isVCANUpdate__c = false;
            newCase.Approval_Information__c = '**SFDCUPDATE**Test Pre update';
            update newCase;
        }
        Test.stopTest();
    }
    
    private static testmethod void isUpdateTesting() {
        System.debug('isUpdateTesting test block');
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Approved');
            Test.startTest();
            
            newCase.Customer_Concern__c = 'Test 2';
            update newCase; 
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            //AAB No Update Expected
            System.assertEquals(false, newCase.isVCANUpdate__c);
            
            System.debug('Vehicle Mileage__c null test');
            newCase.Vehicle_Mileage__c = null;
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            //AAB No Update Expected
            System.assertEquals(false, newCase.isVCANUpdate__c);
            Test.stopTest();
        }
    }
    
    private static testmethod void approvalLimitTesting()
    {
        System.debug('approvalLimitTesting test block');
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Test.startTest();
            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Approved');  
            System.debug('Total Amount Approved Testing');
            newCase.Vehicle_Mileage__c = 13000;
            newCase.Parts__c = 50000;
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);
            
            //Approval Status should be pending due to approval limit
            System.assertEquals('Pending', newCase.Approval_Status__c);
            System.assertEquals(true, newCase.isApprovalStatusChanged__c);
            
            //Confirm the Approval_Information__c is auto updating
            System.assertEquals(Label.VCAN_Auto_Update_Comment, newCase.Approval_Information__c);
            
            //AAB Nothing changes even comments are re-saved - should still result in no status change
            newCase = createWarrantyCase(dealer, veh, 'Approved');  
            System.debug('Total Amount Approved Testing');
            newCase.Vehicle_Mileage__c = 13000;
            newCase.Parts__c = 50000;
            newCase.isSystemUpdate__c = true;
            newCase.Approval_Information__c = 'Pending changed text';
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);
            
            newCase.Customer_Concern__c = 'new concerns comming';
            update newCase;
            
            newCase = queryWarrantyCase(newCase.Id);
            
            //Approval Status should be pending due to approval limit
            System.assertEquals('Approved', newCase.Approval_Status__c);
            System.assertEquals(false, newCase.isApprovalStatusChanged__c);   
            
            //Test normal approval limits case
            
            u.warranty_app_amount__c = '50';
            update u;
            
            newCase = createWarrantyCase(dealer, veh, 'Approved');            
            newCase.Parts__c = 5;
            System.debug('Total Amount Approved (p:' + newCase.Parts__c + ' l:' + newCase.Labor__c + ' E:' + newCase.Expenses__c + ':' + newCase.Total_Amount_Approved__c);
            newCase.isApprovalStatusChanged__c = true;
            update newCase;
            newCase = queryWarrantyCase(newCase.Id); 
            
            //Expected to stay approved
            System.assertEquals('Approved', newCase.Approval_Status__c);  
            System.assertEquals(false, newCase.isApprovalStatusChanged__c);
        }
        Test.stopTest();
    }
    
    private static testmethod void vcanCommentTesting() 
    {
    	System.debug('vcanCommentTesting test block');    
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Approved');
            Test.startTest();
            
            newCase.isVCANUpdate__c = false;
            newCase.Approval_Information__c = '**SFDCUPDATE**Gonna Update';
            system.debug(newCase.Approval_Information__c);
            update newCase;
            newCase = queryWarrantyCase(newCase.Id);
            
            //Confirm the Approval_Information__c is auto updating
            System.assertEquals('Gonna Update', newCase.Approval_Information__c);
            System.assertEquals(true, newCase.isVCANUpdate__c);
            
        }
        Test.stopTest();
    }  
    
    private static testmethod void testSystemUpdate()
    {
        System.debug('testSystemUpdate test block');
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Pending');
            Test.startTest();
            
            newCase.Vehicle_Mileage__c = 13259;
            newCase.Approval_Status__c = 'Approved';
            newCase.isSystemUpdate__c = true;
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            //AAB No Update Expected because system update flag
            System.assertEquals(false, newCase.isVCANUpdate__c);
            
            newCase.Parts__c = 13259;
            newCase.Approval_Status__c = 'Approved';
            newCase.isSystemUpdate__c = true;
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            //AAB No Update Expected because system update flag
            System.assertEquals('Approved', newCase.Approval_Status__c);
            Test.stopTest();
        }
    }  
    
    private static testmethod void testCommentAdd()
    {
        System.debug('testCommentAdd test block');
        User u = createUser();        
        System.runAs(u)
        {
            Account dealer = createDealer();            
            Vehicle__c veh = createVehicle();            
            Warranty_Case__c newCase = createWarrantyCase(dealer, veh, 'Approved');
            Test.startTest();
            
            newCase.Parts__c = 13259;
            newCase.Approval_Status__c = 'Approved';
            newCase.isSystemUpdate__c = true;
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            System.assertEquals(false, newCase.isVCANUpdate__c);
            
            System.debug('Adding test comment: Test Comment Add');
            newCase.Approval_Information__c = 'Test Comment Add';
            update newCase;
            
            //AAB - Get latest case
            newCase = queryWarrantyCase(newCase.Id);  
            
            //AAB No Update Expected because system update flag
            System.assertEquals('Approved', newCase.Approval_Status__c);
            System.assertEquals(true, newCase.isVCANUpdate__c);
            Test.stopTest();
        }
    }  
}