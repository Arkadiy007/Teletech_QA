/*
Page Title: Customer_Loyalty_Component
Author: Aaron Bessey
Create Date: 11/10/2014
Last Update: 11/10/2014
Updated By: Aaron Bessey

Revisions:
AAB - Initial Creation
*/

public class Customer_Loyalty_Component {
    /*Properties */
    Public Account customer {get; set;}
    Public Boolean reapeatCustomer {get; set;}
    Public List<Vehicle_Ownership_History__c> listVehicleOwnership {get; set;}
    Public Boolean NMACCustomer {get; set;}
    Public Boolean NCFCustomer {get; set;}
    Public Boolean FleetCustomer {get; set;}
    
    Public Boolean NESNACustomer {get; set;}
    Public Boolean NOTORCustomer {get; set;}
    Public Boolean SocialCustomer {get; set;}
    Public Boolean TechlineCustomer {get; set;}
    Public Boolean WarrantyCustomer {get; set;}
    Public Boolean VPPCustomer {get; set;}
    Public Boolean PreOwnedCustomer {get; set;}
    Public Boolean CustomerPayCustomer {get; set;}
    Public Boolean Repurchase {get; set;}
    Public Boolean Defect {get;set;}
    Public Boolean hasNissan {get;set;}
    Public Boolean hasInfiniti {get;set;}
    Public Boolean hasLeaf {get;set;}
    private Boolean showDebugLogs; 
    Public Customer_Loyalty_Component__c CLCSettings {get;set;}
    Public Id socialRecordTypeId {get; set;}
    Public Id techlineRecordTypeId {get; set;}
    
    public Customer_Loyalty_Component(ApexPages.StandardController stdController) {
        customer = (Account) stdController.getRecord();
        Id aid = stdController.getId();
        
        CLCSettings = Customer_Loyalty_Component__c.getOrgDefaults();
        List<String> rtNames = new List<String>();
        rtNames.add(CLCSettings.Social_Support_Record_Name__c);
        rtNames.add(CLCSettings.Techline_Case_Type__c);
        List<RecordType> rts = [select id, Name from RecordType where SobjectType='Case' and Name in :rtNames Limit 2];
        
        for(RecordType rt: rts)
        {
            socialRecordTypeId = (rt.Name==CLCSettings.Social_Support_Record_Name__c) ? rt.Id : socialRecordTypeId;
            techlineRecordTypeId = (rt.Name==CLCSettings.Techline_Case_Type__c) ? rt.Id : techlineRecordTypeId;
        }
        
        //AAB - this is only true in tests.
        aid = (aid==null) ? '001M000000dlICNIA2' : aid;        
        
        customer = [Select Id, Name, isPersonAccount from Account where Id=:aid limit 1];
        if(Test.isRunningTest()==true || Label.Enable_Debug_Logging=='true')
        {
            showDebugLogs = true;
        }
        
        hasNissan = false;
        hasInfiniti = false;
        hasLeaf = false;
        reapeatCustomer = getRepeatCustomer();   
       //NMACCustomer = getNMACCustomer();
        
        FleetCustomer = getFleetCustomer();
        NCFCustomer = getNCFCustomer();
        NOTORCustomer = getNOTORCustomer();
        SocialCustomer = getSocialCustomer();
        TechlineCustomer = getTechlineCustomer();
        WarrantyCustomer = getWarrantyCustomer();
        NESNACustomer = getNESNACustomer();
        VPPCustomer = getVPPCustomer();
        PreOwnedCustomer = getPreOwnedCustomer();
        CustomerPayCustomer = getCustomerPay();
        Repurchase = false; 
        Defect = false;
    }
    
    public PageReference performRefresh() {
     reapeatCustomer = getRepeatCustomer();   
       //NMACCustomer = getNMACCustomer();
        
        FleetCustomer = getFleetCustomer();
        NCFCustomer = getNCFCustomer();
        NOTORCustomer = getNOTORCustomer();
        SocialCustomer = getSocialCustomer();
        TechlineCustomer = getTechlineCustomer();
        WarrantyCustomer = getWarrantyCustomer();
        NESNACustomer = getNESNACustomer();
        VPPCustomer = getVPPCustomer();
        PreOwnedCustomer = getPreOwnedCustomer();
        CustomerPayCustomer = getCustomerPay();
    
    return null;
    
    
    }
    
    
    
    public Boolean getVPPCustomer()
    {
        List<Vehicle_Retail_Sale__c> lstVRS = 
            [
                Select SALE_TYPE__C from Vehicle_Retail_Sale__c
                where 
                OWNER_ID__C = :customer.Id and SALE_TYPE__C='VPP'
                limit 1
            ];
        
        if(lstVRS!=null && lstVRS.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public Boolean getPreOwnedCustomer()
    {
        List<Vehicle_Service_Contract__c> lstVSC = 
            [
                Select Id from Vehicle_Service_Contract__c
                where 
                Account_Id__c = :customer.Id
                limit 1
            ];
        
        if(lstVSC!=null && lstVSC.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    public Boolean getNESNACustomer()
    {
        List<Vehicle_Service_Contract__c> lstVSC = 
            [
                Select Id from Vehicle_Service_Contract__c
                where 
                Account_Id__c = :customer.Id
                limit 1
            ];
        
        if(lstVSC!=null && lstVSC.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    public Boolean getCustomerPay()
    {
        List<Service_Repair_History__c> lstSRH = 
            [
                Select Id from Service_Repair_History__c
                where 
                Customer__c = :customer.Id and
                (Coverage_Code_Pay_Type__c = 'C' or
                 Coverage_Code_Pay_Type__c = 'CP')
                limit 1
            ];
        
        if(lstSRH!=null && lstSRH.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public Boolean getWarrantyCustomer()
    {
        List<Vehicle_Ownership_History__c> Vehicles = 
            [
                Select Id, Vehicle__c
                from Vehicle_Ownership_History__c
                where
                Owner__c = :customer.Id
                Limit 1
            ];
        
        List<Id> vehicleIds = new List<Id>();
        for(Vehicle_Ownership_History__c voh :Vehicles)
        {
            vehicleIds.Add(voh.vehicle__c);
        }
        
        List<Warranty_Case__c> warrantyCases = 
            [
                Select Id
                from Warranty_case__c
                where
                vehicle__c in :vehicleIds
                Limit 1
            ];
        
        if(warrantyCases!=null && warrantyCases.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public Boolean getSocialCustomer()
    {
        List<Case> socialCases = 
            [
                Select Id
                from Case
                where
                RecordTypeId = :socialRecordTypeId                
                and AccountId = :customer.Id
                Limit 1
            ];
        
        if(socialCases!=null && socialCases.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public Boolean getTechlineCustomer()
    {
        List<Case> techlineCases = 
            [
                Select Id
                from Case
                where
                RecordTypeId = :techlineRecordTypeId
                and AccountId = :customer.Id
                Limit 1
            ];
        
        if(techlineCases!=null && techlineCases.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public Boolean getNOTORCustomer()
    {
        List<Notor__c> notorCases = 
            [
                Select Id
                from Notor__C
                where
                Person_Account__c = :customer.Id
                Limit 1
            ];
        
        if(notorCases!=null && notorCases.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /*public Boolean getNMACCustomer()
    {
        List<Vehicle_Ownership_History__c> nmacVehicles = 
            [
                Select Id, NMAC_Lease_Loan_Indicator__c
                from Vehicle_Ownership_History__c
                where
                NMAC_Lease_Loan_Indicator__c=true
                and Owner__c = :customer.Id
                Limit 1
            ];
        
        if(nmacVehicles!=null && nmacVehicles.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }*/
    
    public Boolean getFleetCustomer() {
     List<Vehicle_Ownership_History__c> nmacVehicles = 
            [
                Select Id
                from Vehicle_Ownership_History__c
                where
                Original_Retail_Type_Desc__c LIKE '%Fleet%' 
                and Owner__c = :customer.Id
                Limit 1
            ];
        
        if(nmacVehicles!=null && nmacVehicles.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    
    }
    
    public Boolean getNCFCustomer() {
     List<Vehicle_Ownership_History__c> nmacVehicles = 
            [
                Select Id
                from Vehicle_Ownership_History__c
                where
                Original_Retail_Type_Desc__c LIKE '%NCF%' 
                and Owner__c = :customer.Id
                Limit 1
            ];
        
        if(nmacVehicles!=null && nmacVehicles.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    
    }
    public Boolean getRepeatCustomer()
    {
        if(showDebugLogs!=null && showDebugLogs==true)
        {
            system.debug('User Info:' + customer.Id);
        }
        listVehicleOwnership = [select id, Vehicle_Make__c, Vehicle__r.Model_Name__c from Vehicle_Ownership_History__c where Owner__c = :customer.Id];
        if(listVehicleOwnership!=null && listVehicleOwnership.size()>0)
        {
            for(Vehicle_Ownership_History__c voh : listVehicleOwnership)
            {
                hasNissan = (voh.Vehicle_Make__c!=null && voh.Vehicle_Make__c=='Nissan')? true : hasNissan;   
                hasInfiniti = (voh.Vehicle_Make__c!=null && voh.Vehicle_Make__c=='Infiniti')? true : hasInfiniti;
                hasLeaf = (voh.Vehicle__r.Model_Name__c!=null && voh.Vehicle__r.Model_Name__c.contains('LEAF')) ? true : hasLeaf;
            }
            
            return (listVehicleOwnership.size()>1) ? true : false;
        }
        else
        {
            return false;
        }
    }
}