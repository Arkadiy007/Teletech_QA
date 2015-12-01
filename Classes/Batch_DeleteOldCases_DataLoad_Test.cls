/**********************************************************************
Name: Batch_DeleteOldCases_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_DeleteOldCases_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/21/2012 Created 
***********************************************************************/
@isTest
private class Batch_DeleteOldCases_DataLoad_Test {

    static testMethod void Batch_DeleteOldCases_Test() {
        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Account acct = new Account(LastName = 'Test', PersonMailingState = 'CO');
        insert acct;
        
        List<Case> cases = new List<Case>();
        DateTime oldDate = DateTime.newInstance(2005,1,1,1,1,1);
        System.debug('oldDate = ' + oldDate);
        Case c1 = new Case(AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rt.Id,
                           CreatedDate = oldDate/*,
                           Call_Recording_Id__c = 'ZYXABC'*/);
        cases.add(c1); 
                
        insert cases; 
        
        Test.startTest();
    
            Batch_DeleteOldCases_DataLoad batch = new Batch_DeleteOldCases_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}