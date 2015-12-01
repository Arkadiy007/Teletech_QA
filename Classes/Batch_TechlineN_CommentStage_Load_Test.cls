/**********************************************************************
Name: Batch_TechlineN_CommentStage_Load_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline Comments
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 1-31-2014
***********************************************************************/   
   
@isTest
private class Batch_TechlineN_CommentStage_Load_Test {
   
    static testMethod void Batch_TechlineN_CommentStage_Load_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
    
        Code__c code = new Code__c();
        code.Type__c = 'Last_Run_Time';
        code.Code__c = 'Techline_Comment_Backfeed';
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
                           RecordTypeId = rt.Id,
                           Call_Recording_Id__c = 'ZYXABC');
        cases.add(c1); 
                
        insert cases; 
        
        List<CaseComment> caseComments = new List<CaseComment>();
        CaseComment cc1 = new CaseComment();
        cc1.ParentId = c1.Id;
        cc1.CommentBody = 'ZYXABC';
        caseComments.add(cc1);
        
        insert caseComments;  
        Test.startTest();
    
            Batch_TechlineNewCommentStag_DataLoad batch = new Batch_TechlineNewCommentStag_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
      static testMethod void Batch_TechlineN_CommentStage_Load_Test2() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
    
        Code__c code = new Code__c();
        code.Type__c = 'Last_Run_Time';
        code.Code__c = 'Techline_Comment_Backfeed';
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
                           RecordTypeId = rt.Id,
                           Call_Recording_Id__c = 'ZYXABC');
        cases.add(c1); 
                
        insert cases; 
        
        List<CaseComment> caseComments = new List<CaseComment>();
        CaseComment cc1 = new CaseComment();
        cc1.ParentId = c1.Id;
        cc1.CommentBody = 'ZYXABC';
        caseComments.add(cc1);
        
        insert caseComments;  
        Test.startTest();
    
            TechlineAlerts_6Year_Comment_Dataload batch = new TechlineAlerts_6Year_Comment_Dataload();
            Database.executeBatch(batch);
    
    
        Test.stopTest();
    }   
    
    
    
    
    
    
    
    
}