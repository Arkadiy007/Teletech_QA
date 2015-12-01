/**********************************************************************
Name: Batch_CheckRequest_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_CheckRequest_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 2/21/2012 Created 
***********************************************************************/
@isTest
private class Batch_CheckRequest_DataLoad_Test {

    static testMethod void Batch_CheckRequest_Test() {
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
        
        caseCats.add(caseCat);
        insert caseCats;

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;

        List<Check_Request__c> checkRequests = new List<Check_Request__c>();
        Check_Request__c cr1 = new Check_Request__c();
        cr1.Case__c = c1.id;
        cr1.Special_Comments__c = 'Special Comments';
        cr1.Check_Amount__c = 100;
        cr1.Payable_To_First_Name__c = 'First';
        cr1.Payable_To_Last_Name__c = 'ZYXABC';
        cr1.Mailing_Address_Verified__c = true;
        cr1.Approval_Indicator__c = 'Y';
        cr1.GL_Code__c = glCode.Id;
        cr1.Payment_Verification__c = true;
        checkRequests.add(cr1);
        insert checkRequests;
        
        cr1 = [select Id, Document_Id__c from Check_Request__c where Id = :cr1.Id];
        
        List<Stage_Check_Request__c> stageCheckRequests = new List<Stage_Check_Request__c>();
        Stage_Check_Request__c scr1 = new Stage_Check_Request__c();
        
        scr1.Check_Number__c = '1';
        scr1.Issue_Date__c = '20120101';
        scr1.SFDC_Case_Id__c = cr1.Document_ID__c;
        scr1.Origination_Source__c = 'Informatica';
        scr1.Origination_Type__c = 'Check Processing File';
        scr1.Payable_To_Last_Name__c = 'ZYXABC';
        stageCheckRequests.add(scr1);

        insert stageCheckRequests;
        
        Test.startTest();
    
            Batch_CheckRequest_DataLoad batch = new Batch_CheckRequest_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}