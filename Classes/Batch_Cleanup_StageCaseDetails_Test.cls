/**********************************************************************
Name: Batch_Cleanup_StageCaseDetails_Test 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for StageCaseDetails Delete job.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 2/17/2014
***********************************************************************/   
   
@isTest
private class Batch_Cleanup_StageCaseDetails_Test {
   
    static testMethod void Batch_Cleanup_StageCaseDetails_Test () {

    
        Code__c code = new Code__c();
        code.Type__c = 'Cleanup_Days_Back';
        code.Code__c = 'Cleanup_Stage_Case_Details';
        code.Description__c = '900';
        insert code;
    


        //Account acct = new Account(LastName = 'Test', PersonMailingState = 'CO');
        //insert acct;
        
        List<Stage_Case_Detail__c> details = new List<Stage_Case_Detail__c>();
        
        Stage_Case_Detail__c d1 = new Stage_Case_Detail__c();
        details.add(d1); 
                
        insert details; 

        Test.startTest();
    
            Batch_Cleanup_StageCaseDetails batch = new Batch_Cleanup_StageCaseDetails();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
}