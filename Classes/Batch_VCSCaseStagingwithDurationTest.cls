/**********************************************************************
Name: Batch_VCSCaseStaging_LoadwithDurationTest
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for several Batch jobs.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Vivek Batham 12/19/2014 Created 
***********************************************************************/
@isTest
private class Batch_VCSCaseStagingwithDurationTest {

    
     static testMethod void Batch_VCSCaseStagingLoadingTest() {
     
        Id RTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'VCS Support'); 
        Case testCase = new Case(RecordTypeId = RTypeId, TCU_Activation_Status__c = true, Status = 'Open', CreatedDate = Date.newInstance(2014,10,10));
        insert testCase;
        
        Test.startTest();
    
            Batch_VCSCaseStaging_LoadwithDuration batch = new Batch_VCSCaseStaging_LoadwithDuration();
            Database.executeBatch(batch);
            
          
        Test.stopTest();
        
        System.assert([Select Id from Stage_Case__c Where CreatedDate = TODAY].size() > 0 );
    }   

}