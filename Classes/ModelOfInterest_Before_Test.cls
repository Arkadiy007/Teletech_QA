/**********************************************************************
Name: ModelOfInterest_Before_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of trigger "ModelOfInterest_Before".

Related to: ModelOfInterest_Before
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 08/24/2011 Created

***********************************************************************/

@isTest
private Class ModelOfInterest_Before_Test{
    
    private static final String lastname = 'TestTestTest';
    private static final String make = 'TestTestTest';
    private static final String customer_id = '1234567890987654321';
    private static final Integer rowCount = 200;
    
    static testMethod void testTrigger() {
    
        RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
        
        /*
           Setup Test Data
        */
        Account acct;
        List<Account> acctList = new List<Account>();
        Model_Of_Interest__c moi;
        List<Model_Of_Interest__c> moiList = new List<Model_Of_Interest__c>();
        
        for (Integer i = 0; i < rowCount; i++) {
            acct = new Account();
            acct.lastname = lastname;
            acct.customer_id__c = customer_id + i;
            acct.recordtypeid = personType.id;
            acctList.add(acct);
            
            moi = new Model_Of_Interest__c();
            moi.customer_id__c = customer_id + i;
            moi.make__c = make;
            moiList.add(moi);
        }
        insert acctList;
        
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
        Test.startTest();
        
        insert moiList;
             
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */
       
        Test.stopTest();
              
        /*
          Query the database for the newly inserted record. 
        */
       
        moiList = [select id, Account__c from Model_Of_Interest__c where make__c = :make];
       
        /*
          Assert that the account lookup field was populated.
          
        */
        
        for (Integer i = 0; i < rowCount; i++) {
            system.assert(moiList[i].account__c != null);
        }
    }    
}