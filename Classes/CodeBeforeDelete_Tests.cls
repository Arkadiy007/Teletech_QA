/**********************************************************************
Name: Code_BeforeDelete_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Code_BeforeDelete Trigger.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina 03/06/2015 Created 
***********************************************************************/
@isTest
public class CodeBeforeDelete_Tests { 
	static testMethod void testDeleteUndeletable(){
	Test.startTest();
		List<Code__c> testCodes;
        CaseCategory_Dependency__c testCCD;
        testCodes = new List<Code__c>();
        testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'MJ', Description__c = 'Symptom', Active__c = TRUE));
        insert testCodes;

        testCCD = new CaseCategory_Dependency__c();
        testCCD.Concern__c = testCodes[0].ID;
        testCCD.Category__c = testCodes[1].ID;
        testCCD.Subcategory__c = testCodes[2].ID;
        testCCD.Symptom__c = testCodes[3].ID;
		testCCD.Major_Component_Code__c = 'MJ';
        insert testCCD;
		boolean expectedExceptionThrown = false;
		try{
			delete testCodes[4];			
		}
		catch(Exception e){
			expectedExceptionThrown = e.getMessage().contains('The Code cannot be deleted because it has Case Category Dependency.') ? true : false;
			
		}
		System.assertEquals(expectedExceptionThrown, true);
		Test.stopTest();
	}

}