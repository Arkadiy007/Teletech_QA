/**********************************************************************
Name: Stage_Case_Detail_Techline_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Stage_Case_Detail_Techline_Before.trigger.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/22/2011 Created 
***********************************************************************/
@isTest
private class Stage_Case_Detail_Techline_Before_Test {

    static testMethod void Batch_Techline_CaseComment_Test() {
        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'Tech Line'];
        
        Case c = new Case(RecordTypeId = rt.Id,
                          Incident_Number__c = '1234');
        insert c;
        
        List<Stage_Case_Detail__c> SCList = new List<Stage_Case_Detail__c>();
        
        Stage_Case_Detail__c scd1 = new Stage_Case_Detail__c(SFDC_Action_Code__c = 'A',
                                                            Origination_Source__c = 'Informatica',
                                                            Origination_Type__c = 'Techline',
                                                            Incident_Number__c = '1234',
                                                            Root_Cause__c = 'ZYXABC'); 
        SCList.add(scd1);

        insert SCList;
        
        Test.startTest();
    
            update SCList;
    
        Test.stopTest();
    }   
    
}