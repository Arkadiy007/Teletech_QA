/**********************************************************************
Name: Batch_Jobs_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for several Batch jobs.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 11/25/2011 Created 
***********************************************************************/
@isTest
private class Batch_Jobs_Test {
    static testMethod void Batch_VCS_Alert_Close_Test() {
        Case testCase = new Case(RecordTypeId = '012F0000000yH3M', TCU_Activation_Status__c = true, Status = 'Open', CreatedDate = Date.newInstance(2013,1,1));
        insert testCase;
        Case testCase2 = new Case(Lease_Maturity_Date__c = Date.newInstance(2014,12,8),RecordTypeId = '012F0000000yAbx', TCU_Activation_Status__c = true, Status = 'Open', CreatedDate = Date.newInstance(2013,1,1));
        insert testCase2;
        
        
        
        Test.startTest();
    
            Batch_VCS_Alert_Close batch = new Batch_VCS_Alert_Close();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   

    static testMethod void Batch_VCS_Alert_Email_Test() {
        Case testCase = new Case(RecordTypeId = '012F0000000yH3M', TCU_Activation_Status__c = false, IC_Subscription_Status__c = true,
                                 IPA_Subscription_Status__c = true, Status = 'Open', CreatedDate = Date.newInstance(2013,1,1));
        insert testCase;
        
        Test.startTest();
    
            Batch_VCS_Alert_Email batch = new Batch_VCS_Alert_Email();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_Close_CCC_Related_Cases_Test() {
        Case testCase = new Case(RecordTypeId = '012A0000000xekoIAA', Status = 'Open', CreatedDate = Date.newInstance(2013,1,1));
        insert testCase;
        
        Test.startTest();
    
            Batch_Close_CCC_Related_Cases batch = new Batch_Close_CCC_Related_Cases();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_LEAFCase_CreateCall_Test() {
        Case testCase = new Case(RecordTypeId = '012A0000000xeks', Status = 'Open');
        insert testCase;
        
        Test.startTest();
    
            Batch_LEAFCase_CreateCall batch = new Batch_LEAFCase_CreateCall();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_VCSCase_CreateCall_Test() {
        Case testCase = new Case(RecordTypeId = '012F0000000yFNi', Status = 'Open');
        insert testCase;
        
        Test.startTest();
    
            Batch_VCSCase_CreateCall batch = new Batch_VCSCase_CreateCall();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_VCSCaseStaging_DataLoad_Test() {
        Case testCase = new Case(RecordTypeId = '012F0000000yFNiIAM', Status = 'Open', Spam_Remove_From_Backfeed__c = false);
        insert testCase;
        
        Test.startTest();
    
            Batch_VCSCaseStaging_DataLoad batch = new Batch_VCSCaseStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_Vehicle_Head_Unit_Test() {
        Code__c testCode = new Code__c(Type__c = 'Head_Unit', Code__c = '2014_84114', Secondary_Code__c = 'P02', Description__c = '08IT');
        insert testCode;
        
        Vehicle__c testVehicle = new Vehicle__c(Model_Year__c = '2014', Model_Code__c = '84114', Factory_Installed_Options__c = 'P02');
        insert testVehicle;
        
        Test.startTest();
    
            Batch_Vehicle_Head_Unit batch = new Batch_Vehicle_Head_Unit();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }
    
    static testMethod void Batch_VCS_Alert_Update_Sharing() {
        Case testCase = new Case(RecordTypeId = '012F0000000yH3M', Status = 'Open');
        insert testCase;
        
        Test.startTest();
    
            Batch_VCS_Alert_Update_Sharing batch = new Batch_VCS_Alert_Update_Sharing();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }

    static testMethod void Batch_CA_Update_Sharing() {
        Case testCase = new Case(RecordTypeId = '012F0000000y9y7IAA', Status = 'Open');
        insert testCase;
        
        Test.startTest();
    
            Batch_CA_Update_Sharing batch = new Batch_CA_Update_Sharing();
            Database.executeBatch(batch);
    
        Test.stopTest();
    } 
}