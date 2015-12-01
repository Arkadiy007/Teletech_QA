/**********************************************************************
Name: Event_Trigger_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test Event Before Trigger
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 2/21/2012 Created 
***********************************************************************/
@isTest
private class Event_Trigger_Test {

    static testMethod void myUnitTest() {
        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];
        
        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = '012F0000000y9y7';
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
        	Event testEvent = new Event(WhatId = caseRec.Id, Subject = 'A');
        	insert testEvent;
        } catch (Exception e) {
        
        }
        Test.stopTest();
    }
}