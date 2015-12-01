/**********************************************************************
Name: CaseCategorizationBefore_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Case_Categorization_Before" Apex Trigger.

Related to: Case_Categorization_Before
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Anna Koseykina 03/09/2015 Created
***********************************************************************/

@isTest
public class CaseCategorizationBefore_Test { 

    static testmethod void testUpdateCategory(){
        /*
           create a case to test the functionality
        */
        Test.startTest();
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        Case testCase = new Case(Status = 'New', Origin = 'Phone', Description = 'Initial Description', recordTypeId = caseCART.id, Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department');
        
        List<Code__c> testCodes;
        CaseCategory_Dependency__c testCCD;
        Case_Categorization__c testCC;
        testCodes = new List<Code__c>();
        testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'MJ', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'test', Description__c = 'Symptom', Active__c = TRUE));
        insert testCodes;

        insert testCase;
        testCCD = new CaseCategory_Dependency__c();
        testCCD.Concern__c = testCodes[0].ID;
        testCCD.Category__c = testCodes[1].ID;
        testCCD.Subcategory__c = testCodes[2].ID;
        testCCD.Symptom__c = testCodes[3].ID;
        testCCD.Major_Component_Code__c = 'MJ';
        insert testCCD;

        testCC = new Case_Categorization__c();
        testCC.Case__c = testCase.ID;
        
        testCC.Concern__c = testCodes[0].ID;
        testCC.Concern_Code__c = 'CN';
        
        testCC.Category__c = testCodes[1].ID;
        testCC.Category_Code__c = 'CT';
        
        testCC.Subcategory__c = testCodes[2].ID;
        testCC.Subcategory_Code__c = '9IIII9';
        
        Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'SymptomTest', Active__c = TRUE);
        //not matching with dependency
        testCC.Symptom__c = symptom.Id;
        testCC.Symptom_Code__c = 'SM';
        
        insert testCC;
        
        testCC = [SELECT Id, Major_Component_Code__c FROM Case_Categorization__c WHERE Case__c=:testCase.Id LIMIT 1];
        System.assertEquals(testCC.Major_Component_Code__c, null);
        test.stopTest();
    }
}