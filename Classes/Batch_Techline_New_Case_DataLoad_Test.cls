/**********************************************************************
Name:  Batch_TechlineLegacyCStage_Load_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline Legacy Comments Outbound
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 1-31-2014
***********************************************************************/   
   
@isTest
private class Batch_Techline_New_Case_DataLoad_Test {
   
    static testMethod void Batch_Techline_New_Case_DataLoad_Test() {

        List<OneTimeTechlineLoad__c> cases = new List<OneTimeTechlineLoad__c>();
        OneTimeTechlineLoad__c c1 = new OneTimeTechlineLoad__c(
            CONSUMER_NAME__c = 'ZYXABC',
            IN_SERVICE_DATEYMD__c = '20110101',
            LOCATION_CODE__c = 'MINI');
        cases.add(c1); 
                
        insert cases; 
 
        Test.startTest();
    
        Batch_Techline_New_Case_DataLoad batch = new Batch_Techline_New_Case_DataLoad();
        Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
}