/**********************************************************************
Name: Batch_CaseCategoryStaging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_CaseCategoryStaging_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/21/2012 Created 
***********************************************************************/
@isTest
private class Batch_CaseCategoryStaging_DataLoad_Test {

    static testMethod void Batch_CaseCategoryStaging_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;

        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Account acct = new Account(LastName = 'Test',PersonMailingState = 'CO');
        insert acct;
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rt.Id);
        cases.add(c1); 
                
        insert cases;
        
        Code__c concern = new Code__c(Type__c = 'Concern', Code__c = 'OA', Description__c = 'VEHICLE CONCERNS');
        Code__c category = new Code__c(Type__c = 'Category', Code__c = 'AA', Description__c = 'AUDIO/VIDEO/NAVI');
        Code__c subcategory = new Code__c(Type__c = 'Subcategory', Code__c = '136500', Description__c = 'STARTER');
        Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'ZA', Description__c = 'ACCESSORIES DISCREPANCY');
        
        List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
        Case_Categorization__c caseCat = new Case_Categorization__c();
        caseCat.Concern__c = concern.Id;
        caseCat.Category__c = category.Id;
        caseCat.Subcategory__c = subcategory.Id;
        caseCat.Symptom__c = symptom.Id;
        caseCat.Case__c = c1.Id;
        caseCat.Root_Cause__c = 'ZYXABC';
        
        caseCats.add(caseCat);
        insert caseCats;
        
        Test.startTest();
    
            Batch_CaseCategoryStaging_DataLoad batch = new Batch_CaseCategoryStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}