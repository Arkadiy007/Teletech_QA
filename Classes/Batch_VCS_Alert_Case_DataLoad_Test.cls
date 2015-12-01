/**********************************************************************
Name: Batch_VCS_Alert_Case_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_VCS_Alert_Case_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 07/26/2013 Created 
***********************************************************************/
@isTest
private class Batch_VCS_Alert_Case_DataLoad_Test {

    static void setupOtherData() {
        RecordType dealerRT = [Select Id, Name From RecordType where SobjectType = 'Account' and Name = 'Dealer'];
        Account dealer = new Account(Name = 'VCS Alert Test Dealer', RecordTypeId = dealerRT.Id, Dealer_Code__c = 'VCST', Dealer_External_Id__c = 'VCST_USA');
        insert dealer;
        State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
        insert state;
    }

    static void setupStageData() {
        Stage_VCS_Alert__c stage = new Stage_VCS_Alert__c();
        stage.contact_Id__c = '987654327';
        stage.RDR_Contact_Id__c = '987654326';
        stage.first_name__c = 'Test';
        stage.middle_initial__c = 'J';
        stage.last_name__c = 'Testerton';
        stage.address1__c = '720 Spin Dr';
        stage.address2__c = '';
        stage.city__c = 'Cityville';
        stage.state__c = 'CO';
        stage.Zip_Code__c = '80231';
        stage.Zip_4__c = '5196';
        stage.Email_Address__c = 'null@devnull.com.qa';
        stage.Home_Phone__c = '5555555555';
        stage.Work_Phone__c = '';
        stage.Cell_Phone__c = '';
        stage.VIN__c = '98573528195647354';
        stage.Make__c = 'Infiniti';
        stage.Model__c = 'G37 Sedan';
        stage.Model_Year__c = '2013';
        stage.RDR_Date__c = '100113';
        stage.Purchase_Date__c = '100113';
        stage.Dealer_Code__c = 'VCST';
        stage.Subscription_Status__c = 'A';
        stage.Op_Subscription_Status__c = '1';
        stage.IC_Subscription_Status__c = '0';
        stage.NC_Subscription_Status__c = '0';
        stage.ITA_Subscription_Status__c = '0';
        stage.IPA_Subscription_Status__c = '1';
        stage.Transaction_Master_Id__c = '9999999999';
        stage.VCS_Alert_External_Id__c = '9999999999_98573528195647354';

        insert stage; 
    }

    static testMethod void Batch_VCS_Alert_Case_Test() {
        setupOtherData();
        setupStageData();
        
        Test.startTest();
    
            Batch_VCS_Alert_Case_DataLoad batch = new Batch_VCS_Alert_Case_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   

    static testMethod void Stage_VCS_Alert_Insert_Test() {        
        Test.startTest();
    
            setupStageData();
    
        Test.stopTest();
    }  
}