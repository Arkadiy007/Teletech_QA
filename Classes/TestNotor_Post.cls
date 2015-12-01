/**********************************************************************
Name: TestNotor_Post 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Notor_Post .
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestNotor_Post {
    
    
    public static testmethod void test1(){
        
         
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Notor_Id__c = '12345', 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', warranty_app_amount__c='25', warranty_vcan_delete__c=true );
        insert u;
        
        RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
                system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
        Account dealerAccount = new Account();
            dealerAccount.name = 'testDealerAccount';
            dealerAccount.RecordTypeId = dealer.id;
            dealerAccount.Dealer_Attributes_Text__c = 'EIX';
            dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
        
        
        
        ApexPages.currentPage().getParameters().put('notorId', '12345');
        ApexPages.currentPage().getParameters().put('firstName', 'TestFName');
        ApexPages.currentPage().getParameters().put('lastName', 'LName');
        ApexPages.currentPage().getParameters().put('homePhoneNumber', '9876545678');
        ApexPages.currentPage().getParameters().put('mobilePhoneNumber', '9874535687');
        ApexPages.currentPage().getParameters().put('businessPhoneNumber', '4456789098');
        ApexPages.currentPage().getParameters().put('emailAddress', 'abc@ed.com');
        ApexPages.currentPage().getParameters().put('company', 'CCompany');
        ApexPages.currentPage().getParameters().put('address', 'tAdd1');
        ApexPages.currentPage().getParameters().put('address2', 'tAdd2');
        ApexPages.currentPage().getParameters().put('city', 'city');
        ApexPages.currentPage().getParameters().put('state', 'TN');
        ApexPages.currentPage().getParameters().put('zipCode', '40202');
        ApexPages.currentPage().getParameters().put('accountNumber', '1235589');
        ApexPages.currentPage().getParameters().put('dealerCode', '0987');
        ApexPages.currentPage().getParameters().put('administratorName', 'DName');
        ApexPages.currentPage().getParameters().put('administratorPhone', 'tAdd2');
        ApexPages.currentPage().getParameters().put('administratorEmail', 'AdminName');
        ApexPages.currentPage().getParameters().put('specialistName', 'SName');
        ApexPages.currentPage().getParameters().put('specialistPhoneNumber', '9876545678');
        ApexPages.currentPage().getParameters().put('specialistEmail', 'abc@gmail.com');
        ApexPages.currentPage().getParameters().put('salesAmount', '8789');
        ApexPages.currentPage().getParameters().put('serviceAmount', '768');
        
        
        Notor_Post ntrPost = new Notor_Post();
        
        ntrPost.submitNotor();
    }
    
}