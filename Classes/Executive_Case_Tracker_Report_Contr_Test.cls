/**********************************************************************
Name: Executive_Case_Tracker_Report_Contr_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Executive_Case_Tracker_Report_Controller controller.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 09/29/2015 Created 
***********************************************************************/
@isTest

public class Executive_Case_Tracker_Report_Contr_Test { 
	final static String CA_RECORD_TYPE = 'CA';
	final static String CA_EMAIL_NISSAN_RECORD_TYPE = 'CA Email Nissan';
	final static String CA_EMAIL_INFINITI_RECORD_TYPE = 'CA Email Infiniti';

	static testmethod void testValidationRecordTypeFilter() {
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();
		controller.recordTypes = new List < String >(); 
		controller.getSettings();
		controller.generateReport();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());
	}

	static testmethod void testValidationLastModDateFromFilter() {
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();
		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE); 
		controller.settingProxyDate.lastModifiedDateFilterFrom = null;
		controller.generateReport();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());
	}

	static testmethod void testValidationLastModDateToFilter() {
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.recordTypes.add(CA_RECORD_TYPE); 
		controller.getSettings();
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = null;
		controller.generateReport();
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());
	}

	static testmethod void testOnNoRecordsMatchedTheCreterisas() {
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		controller.generateReport();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());
	}

	static testmethod void testCorrectFiltersWorks() {
		
		//Create Cases
		Case c1 = createCase(CA_RECORD_TYPE);
		Case c2 = createCase(CA_EMAIL_NISSAN_RECORD_TYPE);
		Case c3 = createCase(CA_EMAIL_INFINITI_RECORD_TYPE);

		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		controller.generateReport();

		System.assertNotEquals(null, controller.casesMap);
		System.assertEquals(3, controller.casesMap.size());

	}

	
	
	static testmethod void testCorrectReportURL() {
		
		//Create Cases
		Case c1 = createCase(CA_RECORD_TYPE);
		Case c2 = createCase(CA_EMAIL_NISSAN_RECORD_TYPE);
		Case c3 = createCase(CA_EMAIL_INFINITI_RECORD_TYPE);

		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		String reportUrl = controller.generateReport().getUrl();

		System.assertNotEquals(null, reportUrl);
		//System.assertNotEquals(3, controller.casesMap.size());

	}

	static testmethod void testCustSettingsManyRecordTypes() {
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);
		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		for (Selectoption so : controller.recordTypesSO) {
			controller.recordTypes.add(so.getvalue());
		}

		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		controller.generateReport();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(1, pageMessages.size());
	}

	static testmethod void testCaseCategorization() {
		//Create Cases
		Case c1 = createCase(CA_RECORD_TYPE);
		Case c2 = createCase(CA_EMAIL_NISSAN_RECORD_TYPE);
		Case c3 = createCase(CA_EMAIL_INFINITI_RECORD_TYPE);
		//Create Codes
		List<Code__c> testCodes;
        testCodes = new List<Code__c>();
        testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'MJ', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'test', Description__c = 'Symptom', Active__c = TRUE));
        insert testCodes;
        
		//Create CaseCategorization 1
		Case_Categorization__c testCC;
        testCC = new Case_Categorization__c();
        testCC.Case__c = c1.ID;

        testCC.Concern__c = testCodes[0].ID;
        testCC.Concern_Code__c = 'CN';
        
        testCC.Category__c = testCodes[1].ID;
        testCC.Category_Code__c = 'CT';
        
        testCC.Subcategory__c = testCodes[2].ID;
        testCC.Subcategory_Code__c = '9IIII9';
		insert testCC;

		//Create CaseCategorization 2
		Case_Categorization__c testCC1;
        testCC1 = new Case_Categorization__c();
        testCC1.Case__c = c2.ID;

        testCC1.Concern__c = testCodes[0].ID;
        testCC1.Concern_Code__c = 'CN';
        
        testCC1.Category__c = testCodes[1].ID;
        testCC1.Category_Code__c = 'CT';
        
        testCC1.Subcategory__c = testCodes[2].ID;
        testCC1.Subcategory_Code__c = '9IIII9';
		insert testCC1;

		//Create CaseCategorization 3
		Case_Categorization__c testCC2;
        testCC2 = new Case_Categorization__c();
        testCC2.Case__c = c3.ID;

        testCC2.Concern__c = testCodes[0].ID;
        testCC2.Concern_Code__c = 'CN';
        
        testCC2.Category__c = testCodes[1].ID;
        testCC2.Category_Code__c = 'CT';
        
        testCC2.Subcategory__c = testCodes[2].ID;
        testCC2.Subcategory_Code__c = '9IIII9';
		insert testCC2;

		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);
		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		controller.generateReport();

		System.assertNotEquals(null, controller.casesMap);
		System.assertEquals(3, controller.casesMap.size());
	}
	
	static testmethod void testExcelPage() {
		
		//Create Cases
		Case c1 = createCase(CA_RECORD_TYPE);
		Case c2 = createCase(CA_EMAIL_NISSAN_RECORD_TYPE);
		Case c3 = createCase(CA_EMAIL_INFINITI_RECORD_TYPE);
		Test.startTest();
		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		PageReference excelPage = controller.generateReport();
		Test.setCurrentPage(excelPage);

		Executive_Case_Tracker_Report_Controller excelController = new Executive_Case_Tracker_Report_Controller();
		//excelController.getSettings();
		//System.assert(false, excelController.setting);
		excelController.initializeDataWrapper();
		
		System.assertNotEquals(null, excelController.casesReportData);
		System.assertEquals(3, controller.casesMap.size());
		Test.stopTest();

	}
	
	static testmethod void testExcelBitsOfMarkupVariable() {
		
		//Create Cases
		Case c1 = createCase(CA_RECORD_TYPE);
		Case c2 = createCase(CA_EMAIL_NISSAN_RECORD_TYPE);
		Case c3 = createCase(CA_EMAIL_INFINITI_RECORD_TYPE);

		PageReference pageRef = Page.Executive_Case_Tracker_Reports_Page;
		Test.setCurrentPage(pageRef);

		Executive_Case_Tracker_Report_Controller controller = new Executive_Case_Tracker_Report_Controller();

		controller.getSettings();
		controller.recordTypes.add(CA_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_NISSAN_RECORD_TYPE);
		controller.recordTypes.add(CA_EMAIL_INFINITI_RECORD_TYPE);
		controller.settingProxyDate.lastModifiedDateFilterFrom = Datetime.now().addDays(-20);
		controller.settingProxyDate.lastModifiedDateFilterTo = Datetime.now().addDays(1);
		controller.executiveFlag = true;

		PageReference excelPage = controller.generateReport();
		Test.setCurrentPage(excelPage);

		Executive_Case_Tracker_Report_Controller excelController = new Executive_Case_Tracker_Report_Controller();
		//excelController.getSettings(); 
		excelController.initializeDataWrapper();

		String testStr = excelController.xlsHeader;
		testStr = excelController.rowFirstPart;
		testStr = excelController.rowSecondPart;
		testStr = excelController.worksheetOptionsOpenTag;
		testStr = excelController.worksheetOptionsCloseTag;

		System.assertNotEquals(null, testStr);
		//System.assertNotEquals(3, controller.casesMap.size());

	}
	
	//-----------------------HELPERS---------------------------//
	static Case createCase(String recType) {
		Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recType).getRecordTypeId();
		Case c = new Case(RecordTypeId = recTypeId, Executive_Referral__c = true, Description = 'test descr', 
						Executive_Actions_To_Resolve__c = 'test Executive_Actions_To_Resolve__c');
		
		insert c;
		return c; 
	}
/*
	static Case createCaseCategorization(Case c) {
		CaseCategorization cc = new Case(Case__c = c.Id, );
		
		insert cc;
		return cc; 
	}

	*/
}