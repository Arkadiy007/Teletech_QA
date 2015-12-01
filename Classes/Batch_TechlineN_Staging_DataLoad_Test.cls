/**********************************************************************
Name: Batch_TechlineN_Staging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline New Case Staging
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 1-31-2014
***********************************************************************/   
   
@isTest
private class Batch_TechlineN_Staging_DataLoad_Test {
   
    static testMethod void Batch_TechlineN_Staging_DataLoad_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
    
        Code__c code = new Code__c();
        code.Type__c = 'Last_Run_Time';
        code.Code__c = 'Techline_Case_Backfeed';
        code.Description__c = '';
        insert code;
    
        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'TECH LINE Cases'];

        State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
        insert state;

        //Account acct = new Account(LastName = 'Test', PersonMailingState = 'CO');
        //insert acct;
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           Issue_Type__c = 'MINI',
                           RecordTypeId = rt.Id/*,
                           Call_Recording_Id__c = 'ZYXABC'*/);
        cases.add(c1); 
                
        insert cases; 
        
        Test.startTest();
    
            Batch_Techline_New_CaseStaging_DataLoad batch = new Batch_Techline_New_CaseStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
        

        
    }   
    
    static testMethod void TechlineN_Staging_DataLoad_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
    
        Code__c code = new Code__c();
        code.Type__c = 'Last_Run_Time';
        code.Code__c = 'Techline_Case_Backfeed';
        code.Description__c = '';
        insert code;
    
        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'TECH LINE Cases'];

        State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
        insert state;

        //Account acct = new Account(LastName = 'Test', PersonMailingState = 'CO');
        //insert acct;
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           Issue_Type__c = 'MINI',
                           RecordTypeId = rt.Id/*,
                           Call_Recording_Id__c = 'ZYXABC'*/);
        cases.add(c1); 
                
        insert cases; 
        
        Test.startTest();
    
            TechlineAlerts_6Year_Case_Dataload batch = new TechlineAlerts_6Year_Case_Dataload();
            Database.executeBatch(batch);
    
        Test.stopTest();
        

        
    }   
    
    
    
    
    
}