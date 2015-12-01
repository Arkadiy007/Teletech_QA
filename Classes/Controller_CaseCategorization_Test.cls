/**********************************************************************
Name: Controller_CaseCategorization_Test
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Test code of Controller_CaseCategorization and Controller_CaseCategorizationLineItem

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 09/13/2011 Created
1.01 - Anna Koseykina 12/19/2014 Fixed tests
***********************************************************************/
@isTest
private class Controller_CaseCategorization_Test {
	private static Case testCase;
	private static List<Code__c> testCodes;
	private static CaseCategory_Dependency__c testCCD;
	private static Case_Categorization__c testCC;
	
    public static void InitializeData() {
		testCase = new Case(Status = 'New', Origin = 'Phone', Description = 'Initial Description');
		insert testCase;
		
		testCodes = new List<Code__c>();
		testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));

		testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CX', Description__c = 'Concern No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'TX', Description__c = 'Category No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9XXXX9', Description__c = 'Subcategory No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'MX', Description__c = 'Symptom No Dependency', Active__c = TRUE));
		
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'JX', Description__c = 'Symptom', Active__c = TRUE));
		insert testCodes;
		
		testCCD = new CaseCategory_Dependency__c();
		testCCD.Concern__c = testCodes[0].ID;
		testCCD.Category__c = testCodes[1].ID;
		testCCD.Subcategory__c = testCodes[2].ID;
		testCCD.Symptom__c = testCodes[3].ID;
		testCCD.Major_Component_Code__c = 'JX';
		insert testCCD;
		
		//Note that the initial codes in testCC do not follow the dependency
		testCC = new Case_Categorization__c();
		testCC.Case__c = testCase.ID;
		
		testCC.Concern__c = testCodes[4].ID;
		testCC.Concern_Code__c = 'CX';
		
		testCC.Category__c = testCodes[5].ID;
		testCC.Category_Code__c = 'TX';
		
		testCC.Subcategory__c = testCodes[6].ID;
		testCC.Subcategory_Code__c = '9XXXX9';
		
		testCC.Symptom__c = testCodes[7].ID;
		testCC.Symptom_Code__c = 'MX';
		
		testCC.Major_Component_Code__c = 'JX';
		insert testCC;
    }

	public static void InitializeDataIdenticalCodes() {
		testCase = new Case(Status = 'New', Origin = 'Phone', Description = 'Initial Description');
		insert testCase;
		
		testCodes = new List<Code__c>();
		testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));

		testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CX', Description__c = 'Concern No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'TX', Description__c = 'Category No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9XXXX9', Description__c = 'Subcategory No Dependency', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'MX', Description__c = 'Symptom No Dependency', Active__c = TRUE));
		
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'JX', Description__c = 'Symptom', Active__c = TRUE));
		insert testCodes;
		
		testCCD = new CaseCategory_Dependency__c();
		testCCD.Concern__c = testCodes[0].ID;
		testCCD.Category__c = testCodes[1].ID;
		testCCD.Subcategory__c = testCodes[2].ID;
		testCCD.Symptom__c = testCodes[3].ID;
		testCCD.Major_Component_Code__c = 'JX';
		insert testCCD;

		testCC = new Case_Categorization__c();
		testCC.Case__c = testCase.ID;
		
		testCC.Concern__c = testCodes[0].ID;
		testCC.Concern_Code__c = 'CX';
		
		testCC.Category__c = testCodes[1].ID;
		testCC.Category_Code__c = 'TX';
		
		testCC.Subcategory__c = testCodes[2].ID;
		testCC.Subcategory_Code__c = '9XXXX9';
		
		testCC.Symptom__c = testCodes[3].ID;
		testCC.Symptom_Code__c = 'MX';
		
		//testCC.Major_Component_Code__c = 'JX';
		insert testCC;
	}
    
    static testMethod void TestCaseCategorization_PageOpen() {
    	System.debug('***** TestCaseCategorization_PageOpen *****');
    	
    	InitializeData();
		Test.startTest();
		
			PageReference objPageRef = Page.CaseCategorization;
			Controller_CaseCategorization objController;
			
			Test.setCurrentPage(objPageRef);
			Case_Categorization__c testEmptyCC = new Case_Categorization__c();
			
			//open page with null Case ID
			objController = new Controller_CaseCategorization(new ApexPages.StandardController(testEmptyCC));
			
			//simulate: set Case__c inputfield
			testEmptyCC = new Case_Categorization__c(Case__c = testCase.ID);
			objController.resetCaseCategorizations();
			
			//Add More button
			objController.doAddMoreCategories();
			System.Debug('*** NumberOfMoreCategories: ' + objController.NumberOfMoreCategories);
		
		Test.stopTest();
    }

    static testMethod void TestCaseCategorization_ModifyCCCodes() {
    	System.debug('***** TestCaseCategorization_ModifyCCCodes *****');
    	
		InitializeDataIdenticalCodes();		

		Test.startTest();
			
			PageReference objPageRef = Page.CaseCategorization;
			Controller_CaseCategorization objController;
			
			Test.setCurrentPage(objPageRef);
			
			//open page to set Case Categorization for testCC
			//Note that the initial codes in testCC do not follow the dependency
			objController = new Controller_CaseCategorization(new ApexPages.StandardController(testCC));
			//line item controller
			Controller_CaseCategorizationLineItem objLineController = new Controller_CaseCategorizationLineItem();
			objLineController.Concerns = objController.AllConcerns;
			objLineController.Index = 0;
			objController.doSaveCategorization();
			objLineController.CaseCategorizationController = objController.getThis();
			System.Debug('*** Concerns' + objLineController.Concerns);//to initialize theCC in objLineController
/*
	check dropdown options should include the codes from record. although their combination is not in the dependency table
*/
			//--None--, TX
			System.assert(objLineController.selectedCategory == testCC.Category__c);
			System.assert(objLineController.Categories.size() == 2);
			//--None--, 9XXXX9
			System.assert(objLineController.selectedSubcategory == testCC.Subcategory__c);
			System.assert(objLineController.Subcategories.size() == 2);
			//--None--, MX
			System.assert(objLineController.selectedSymptom == testCC.Symptom__c);
			System.assert(objLineController.Symptoms.size() == 2);
			//JX
			System.assert(objLineController.MajorComponentCode == 'JX');
			
/*
	set selected option to valid codes
	invalid codes should be removed from dropdown list and valid codes should be added
*/
			objLineController.selectedConcern = testCCD.Concern__c;
			objLineController.onSelectedConcernChanged();
			System.Debug('*** Concerns' + objLineController.Concerns);//to initialize theCC in objLineController
			//--None--, CT
			System.assert(objLineController.Categories.size() == 2);
			
			objLineController.selectedCategory = testCCD.Category__c;
			objLineController.onSelectedCategoryChanged();
			//--None--, 9IIII9
			System.assert(objLineController.Subcategories.size() == 2);
			
			objLineController.selectedSubcategory = testCCD.Subcategory__c;
			objLineController.onSelectedSubcategoryChanged();
			//--None--, SM
			System.assert(objLineController.Symptoms.size() == 2);
			
			objLineController.selectedSymptom = testCCD.Symptom__c;
			objLineController.populateEntries();
			
/*
	The item in the CaseCategorizations list should contains the right values
*/
			Case_Categorization__c cc = objController.CaseCategorizations[0];
			System.assert(cc.Concern__c == testCCD.Concern__c);
			System.assert(cc.Category__c == testCCD.Category__c);
			System.assert(cc.Subcategory__c == testCCD.Subcategory__c);
			System.assert(cc.Symptom__c == testCCD.Symptom__c);
			
/*
	test upsert part of objController.doSaveCategorization()
*/
			objController.doSaveCategorization();
			testCC = [Select c.Concern__c, c.Concern__r.Description__c, c.Concern_Code__c, 
					c.Category__c, c.Category__r.Description__c, c.Category_Code__c, 
					c.Subcategory__c, c.Subcategory__r.Description__c, c.Subcategory_Code__c, 
					c.Symptom__c, c.Symptom__r.Description__c, c.Symptom_Code__c, 
					c.Name, c.Major_Component_Code__c, c.Case__c 
				From Case_Categorization__c c 
				Where Case__c =: testCase.ID][0];
			System.assert(testCC.Concern__r.Description__c == 'Concern');
			System.assert(testCC.Category__r.Description__c == 'Category');
			System.assert(testCC.Subcategory__r.Description__c == 'Subcategory');
			System.assert(testCC.Symptom__r.Description__c == 'Symptom');
			
			objController = null;
			
/*
	reopen the page with saved the testCC
	check dropdown options
*/
			objController = new Controller_CaseCategorization(new ApexPages.StandardController(testCC));
			
			//line item controller
			objLineController = new Controller_CaseCategorizationLineItem();
			objLineController.Concerns = objController.AllConcerns;
			objLineController.Index = 0;
			objLineController.CaseCategorizationController = objController.getThis();
			System.Debug('*** Concerns' + objLineController.Concerns);//to initialize theCC in objLineController
			
			//--None--, CT
			System.assert(objLineController.Categories.size() == 2);
			//--None--, 9IIII9
			System.assert(objLineController.Subcategories.size() == 2);
			//--None--, SM
			System.assert(objLineController.Symptoms.size() == 2);
	
		Test.stopTest();
    }
    
    static testMethod void TestCaseCategorization_DeleteCCCodes() {
    	System.debug('***** TestCaseCategorization_DeleteCCCodes *****');
    	
		InitializeData();
   		
		Test.startTest();
			PageReference objPageRef = Page.CaseCategorization;
			Controller_CaseCategorization objController;
			
			Test.setCurrentPage(objPageRef);
			
			//open page to set Case Categorization for testCC
			objController = new Controller_CaseCategorization(new ApexPages.StandardController(testCC));
			
			//line item controller
			Controller_CaseCategorizationLineItem objLineController = new Controller_CaseCategorizationLineItem();
			objLineController.Concerns = objController.AllConcerns;
			objLineController.Index = 0;
			objLineController.CaseCategorizationController = objController.getThis();
			System.Debug('*** Concerns' + objLineController.Concerns);//to initialize theCC in objLineController
			
/*
	set concern selection to null
	the subsequence dropdowns should be cleared out
*/
			objLineController.selectedConcern = Controller_CaseCategorization.SELECT_ONE_PROMPT;
			objLineController.onSelectedConcernChanged();
			
			//the subsequence dropdowns should be cleared out
			System.assert(objLineController.Categories.size() == 1);
			System.assert(objLineController.Subcategories.size() == 1);
			System.assert(objLineController.Symptoms.size() == 1);
			
/*
	The item in the CaseCategorizations list should contains the right values
*/
			Case_Categorization__c cc = objController.CaseCategorizations[0];
			System.assert(cc.Concern__c == null);
			System.assert(cc.Category__c == null);
			System.assert(cc.Subcategory__c == null);
			System.assert(cc.Symptom__c == null);
			
/*
	test delete part of objController.doSaveCategorization(), but the last CaseCategorization cannot be deleted
*/
			objController.doSaveCategorization();
			System.assert([Select ID From Case_Categorization__c Where Case__c =: testCase.ID].size() == 1);
		
		Test.stopTest();
    }
}