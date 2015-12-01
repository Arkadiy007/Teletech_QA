/*
Page Title: Test_Utilities
Author: Aaron Bessey
Create Date: 11/26/2014
Last Update: 11/26/2014
Updated By: Aaron Bessey
Description: Reuseable classes for testing
Usage:

User createUser(String profileName)
Account createDealer()
Account createCustomer(RecordType rt, String FirstName, String LastName)
Case createCase(Id recordTypeId, Id accountId)
Warranty_Case__c createWarrantyCase(Id vehicle)
Notor__c createNOTOR(Id customerid)
Vehicle_Ownership_History__c createOwnershipHistory(Id customerid, Id vehicleid)
Vehicle__c createVehicle(String vin)
Warranty_Case__c createWarrantyCase(Account dealer, Vehicle__c veh, String status)
Service_Repair_History__c createServiceHistory(Id customerid, Id vehicleid, String code)
Warranty_Case__c queryWarrantyCase (Id caseId)
Customer_Service_Credit__c createCustomerServiceCredit(Id dealerId, Id customerId, Id vehicleId)
Vehicle_Service_Contract__c createVSC(Id customerId)
Revisions:
AAB - Initial Creation
AAB - 01/08/2015 - Added classes for user story boards
*/

@isTest
public class Test_Utilities {
    public static User createUser(String profileName)
    {
        if(profileName==null)
        {
            profileName = 'Warranty Agent';
        }
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName]; 
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
    
    public static Account createCustomer(RecordType rt, String FirstName, String LastName)
    {
        Account customer = new Account();
        if(rt==null)
        {
            rt = [select id,Name from RecordType where SobjectType='Account' and Name='NCI' Limit 1];
        }
        customer.RecordTypeId = rt.Id;
        customer.FirstName = FirstName;
        customer.LastName = LastName;
        insert customer;
        customer = [Select Id, Name, FirstName, LastName, isPersonAccount from Account where Id=:customer.Id Limit 1];
        return customer;
    }
    
    public static Account createCustomerNoInsert(RecordType rt, String FirstName, String LastName)
    {
        Account customer = new Account();
        if(rt==null)
        {
            rt = [select id,Name from RecordType where SobjectType='Account' and Name='NCI' Limit 1];
        }
        customer.RecordTypeId = rt.Id;
        customer.FirstName = FirstName;
        customer.LastName = LastName;
        return customer;
    }
    
    public static Case createCase(Id recordTypeId, Id accountId)
    {
        Case caseRec = new Case();
        caseRec.RecordTypeId = recordTypeId;
        caseRec.Status = 'New';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec.AccountId = accountId;
        insert caseRec;
        return caseRec;
    }
    
    public static Warranty_Case__c createWarrantyCase(Id vehicle)
    {
        RecordType rt = [select id,Name from RecordType where SobjectType='Warranty_Case__c' and Name='General Inquiry' Limit 1];
        
        Warranty_Case__c wc = new Warranty_Case__c();
        wc.Vehicle__c = vehicle;
        wc.RecordTypeId = rt.Id;
        wc.Status__c = 'Closed';        
        
        insert wc;
        return wc;
    }
    
    public static Notor__c createNOTOR(Id customerid)
    {
        Notor__c notor = new Notor__c(Person_Account__c=customerid);
        insert notor;
        return notor;
    }
    
    public static Vehicle_Ownership_History__c createOwnershipHistory(Id customerid, Id vehicleid)
    {
        Vehicle_Ownership_History__c voh = new Vehicle_Ownership_History__c();
        voh.Owner__c = customerid;
        voh.Vehicle__c = vehicleid;
        insert voh;
        return voh;
    }
    
    public static Vehicle__c createVehicle(String vin)
    {
        if(vin==null)
        {
            vin = '6Z1AN0NW6FN651885';
        }
        Vehicle__c veh = new Vehicle__c();
        veh.name = vin;
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
        //newCase.Parts_at_Cost__c='NO';
        //newCase.Force_Goodwill_Coverage__c=false;
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
    public static Service_Repair_History__c createServiceHistory(Id customerid, Id vehicleid, String code)
    {
        Service_Repair_History__c SRH = new Service_Repair_History__c();
        SRH.Claim_Approved_Coverage_Code__c = code;
        SRH.Customer__c = customerid;
        SRH.Vehicle_ID__c = vehicleid;
        insert SRH;
        return SRH;        
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
    
    public static Customer_Service_Credit__c createCustomerServiceCredit(Id dealerId, Id customerId, Id vehicleId)
    {
        Customer_Service_Credit__c csc = new Customer_Service_Credit__c();
        csc.Amount__c = 10;
        csc.Debit_or_Credit__c = 'credit';
        csc.G_L__c = '1234567';
        csc.Cost_Centre__c = '1234';
        csc.Account_Name__c = dealerId;
        csc.Plus_Taxes__c = false;
        csc.Reference_Text__c = 'test credit';
        csc.Requested_By__c = 'Aaron Bessey';
        csc.Requested_Date__c = DateTime.now().date();
        csc.Dealer_Name__c = dealerId;
        csc.Customer_Name__c = customerId;
        csc.VIN__c = vehicleId;
        
        insert csc;
        return csc;
    }
    
    public static Vehicle_Service_Contract__c createVSC(Id customerId)
    {
        Vehicle_Service_Contract__c vsc = new Vehicle_Service_Contract__c();
        vsc.Name = 'PLNL90260358';
        vsc.Policy_Number__c = 'PLNL90260358';
        vsc.Account_Id__c = customerId;
        vsc.Owner_Name__c = customerid;
        insert vsc;
        return vsc;
    }
}