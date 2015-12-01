/**********************************************************************
Name: Form_Trigger_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test Form Trigger
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 2/21/2012 Created 
***********************************************************************/
@isTest
private class Form_Trigger_Test {

    static testMethod void myUnitTest() {
        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        insert caseRec;
        
            Code__c concern = new Code__c(Type__c = 'Concern', Code__c = 'OA', Description__c = 'VEHICLE CONCERNS');
            Code__c category = new Code__c(Type__c = 'Category', Code__c = 'AA', Description__c = 'AUDIO/VIDEO/NAVI');
            Code__c subcategory = new Code__c(Type__c = 'Subcategory', Code__c = '136500', Description__c = 'STARTER');
            Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'ZA', Description__c = 'ACCESSORIES DISCREPANCY');
        Code__c rootcause = new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'RootCause', Description__c = 'RootCause');
        insert rootcause;
        
        List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
        Case_Categorization__c caseCat = new Case_Categorization__c();
        caseCat.Concern__c = concern.Id;
        caseCat.Category__c = category.Id;
        caseCat.Subcategory__c = subcategory.Id;
        caseCat.Symptom__c = symptom.Id;
        caseCat.Case__c = caseRec.Id;
        caseCats.add(caseCat);
        insert caseCats;
        
        caseRec.Status = 'Closed';
        caseRec.Special_Root_Cause_Closing_Code__c = rootcause.Id;
        update caseRec;
        
        Test.startTest();
        try {
            Form__c testForm = new Form__c(Case__c = caseRec.Id);
            insert testForm;
        } catch (Exception e) {
        
        }
        Test.stopTest();
    }

    static testMethod void TestFormAfter() {
        RecordType iirRT = [select id, name from recordtype where name = 'IIR' and sobjecttype = 'Form__c' limit 1];
        Set<String> profileNames = new Set<String>();
        Set<String> profileIds = new Set<String>();
        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec.DRT_Support_IIR_Status__c = 'Rejected';
        insert caseRec;
        
        for(String s : System.label.Form_Profile_Updates.split(',')){
            profileNames.add(s.Trim());
        }
        
        for(Profile prof : [Select Id, Name from Profile where Name IN : profileNames]){
            profileIds.add(prof.Id);
        }
        
        Test.startTest();
        try {
            Form__c testForm = new Form__c(Case__c = caseRec.Id, RecordTypeID = iirRT.Id);
            insert testForm;
            
            update testForm;
            
            if(!profileIds.contains(userinfo.getProfileId())){
            System.assert([Select DRT_Support_IIR_Status__c from Case where Id =: caseRec.Id].DRT_Support_IIR_Status__c == 'Pending');          
            }else{
            System.assert(!([Select DRT_Support_IIR_Status__c from Case where Id =: caseRec.Id].DRT_Support_IIR_Status__c == 'Pending')); 
            }
            
        } catch (Exception e) {
        
        }
        Test.stopTest();
    }
}