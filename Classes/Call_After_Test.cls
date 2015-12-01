/**********************************************************************
Name: Call_After_Test 
Copyright Â© notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Call_After" Apex Trigger.

Related to: Call_After
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 05/08/2013 Created
1.1 - Bryan Fry 10/11/2013 Changed to Call_After
***********************************************************************/
@isTest
private Class Call_After_Test {    
    static testMethod void Call_CreateCaseCommentTest() {
        System.Debug('***** Call_CreateCaseCommentTest *****');
        
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        RecordType callVCSRT = [select id, name from recordtype where name = 'VCS' and sobjecttype = 'Call__c' limit 1];
        
        List<Case> testCases = new List<Case> {
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone'),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone'),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone')
        };
        insert testCases;
    
        List<Call__c> testCalls = new List<Call__c> {
            new Call__c(Case__c = testCases[0].Id, Call_Type__c = 'Inbound', Notes__c = 'Test Note', Status__c = 'Not Started', RecordTypeId = callVCSRT.Id),
            new Call__c(Case__c = testCases[1].Id, Call_Type__c = 'Inbound', Notes__c = 'Test Note', Status__c = 'Not Started', RecordTypeId = callVCSRT.Id),
            new Call__c(Case__c = testCases[2].Id, Call_Type__c = 'Inbound', Notes__c = 'Test Note', Status__c = 'Complete', RecordTypeId = callVCSRT.Id)
        };
        insert testCalls[0];
        insert testCalls[1];
        
        test.startTest();
            try {
                testCalls[0].Status__c = 'Complete';
                update testCalls[0];
            } catch (Exception e) {
                System.Debug(e.getMessage());
            }
            try {
                insert testCalls[2];
            } catch (Exception e) {
                System.Debug(e.getMessage());
            }
        
        test.stopTest();
    }
}