/**********************************************************************
Name: Controller_CreateNewContact_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests ths Apex class Controller_CreateNewContact.

Related Page : Controller_CreateNewContact 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vijaya D. 01/31/2011 Created                        
***********************************************************************/

@isTest
private class Controller_CreateNewContact_Test {
    private static Controller_CreateNewContact obj ; 
    private static String personType;
    private static RecordType personTypeRT;
   
    public static void testData() {
        personType = System.Label.AccRTTMS;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        
        Task task = new Task();
        insert task;
                
        Account account = new Account();
        account.tms_customer_Id__c = 'test';
        account.FirstName = 'test1' ;
        account.LastName = 'test';
        account.RecordTypeId = personTypeRT.id;
        insert account;
        
        Campaign camp = new Campaign();    
        camp.Name = 'test';    
        camp.StartDate = date.newinstance(1960, 2, 17);    
        camp.EndDate = date.newinstance(1960, 5, 20);    
        camp.IsActive = true;   
        insert camp;        
        
        Contact contact = new Contact();    
        contact.LastName = 'Test';        
        insert contact;
         
        CampaignMember campmem = new CampaignMember();    
        campmem.CampaignId = camp.id;    
        campmem.ContactId = contact.id;    
        insert campmem;
        
        ApexPages.currentPage().getParameters().put(system.label.callId, task.id);
        ApexPages.currentPage().getParameters().put(system.label.campId, campmem.id);
        
        obj = new Controller_CreateNewContact();
    }
    
    static testmethod void testgetCustomerAccountOne() {
        testData();
        List<TMS_Webservices_Utility.Record> records = new List<TMS_Webservices_Utility.Record>();
        records.add(new TMS_Webservices_Utility.Record(system.label.TMSW_Customer_ID, 'test'));
        test.startTest();
        Account account = obj.getCustomerAccount(records);
        test.stopTest();
        
        System.assert(account != null);

    }
    
    static testmethod void testgetCustomerAccountTwo() {
        testData();
        List<TMS_Webservices_Utility.Record> records = new List<TMS_Webservices_Utility.Record>();
        records.add(new TMS_Webservices_Utility.Record('TMSW Customer ID', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('First Name', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Last Name', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Work Phone Number', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Home Phone Number', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Email', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('City', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Postal Zip', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Province Code', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Address1', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('Address2', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('PersonMailingPostalCode', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('PersonMailingPostalCode', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('PersonMailingState', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('PersonMailingStreet', 'test1'));
        records.add(new TMS_Webservices_Utility.Record('PersonMailingCountry', 'test1'));
        
        test.startTest();
        Account account = obj.getCustomerAccount(records);
        test.stopTest();
        
        System.assert(account != null);
    }
    
    static testmethod void testFillContactInfo() {
        testData();
        ApexPages.currentPage().getParameters().put('associatedCustomer', 'test');
        obj.associatedAccounts.put('test', new Account());
        
        test.startTest();
        obj.fillContactInfo();
        test.stopTest();
        
        system.assert(obj.account != null);
    }
    
    static testmethod void testSaveOne() {
        testData();
        obj.account = new Account(LastName = 'Test');
        
        test.startTest();
        PageReference page = obj.save();
        test.stopTest();
        
        //System.assert(page != null);
    }
    
    static testmethod void testSaveTwo() {
        testData();
        obj.account = new Account(LastName = 'Test');
        obj.account.tms_customer_Id__c = 'test1';
        obj.account.RecordTypeId = personTypeRT.id;
        insert obj.account;
        
        test.startTest();
        PageReference page = obj.save();
        test.stopTest();
        
        System.assert(page != null);
    }
}