/**********************************************************************
Name: MasterRecallCampaign_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of the
"MasterRecallCampaign_Before" trigger.

Related to: MasterRecallCampaign_Before
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 11/07/2013 Created
***********************************************************************/
@isTest
private Class MasterRecallCampaign_Test {
    static testMethod void testInsertMasterRecallCampaign() {
        Master_Recall_Campaign__c mrc = new Master_Recall_Campaign__c();
        mrc.Name = 'TST11';

        Test.startTest();
            insert mrc;
        Test.StopTest();
    }     
}