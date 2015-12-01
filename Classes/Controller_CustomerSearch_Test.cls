/**********************************************************************
Name: Controller_CustomerSearch_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_CustomerSearch.

Related Class : Controller_CustomerSearch
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 03/17/2011 Created                          
***********************************************************************/
@isTest
private class Controller_CustomerSearch_Test {
	private static Controller_CustomerSearch obj = new Controller_CustomerSearch();
	private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
	
	static testmethod void testSearchMaritzOne() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'NotFound';
		
		Test.startTest();
		obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList == true);
		System.assert(obj.noMaritzResults == true);
	}
	
	static testmethod void testSearchMaritzTwo() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'TooManyResults';
		
		Test.startTest();
		obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList == true);
		System.assert(obj.TooManyMaritzResults == true);
	}
	
	static testmethod void testSearchMaritzThree() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success';
		
		Test.startTest();
		obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList == false);
	}
	
	static testmethod void testSearchMaritzFour() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success';
		obj.searchCustomerId = '';
		obj.searchFirstname = 'First';
		obj.searchLastname = '';
		obj.SearchAddr1 = '';
		obj.searchZip = '';
		obj.searchPhone = '';
		obj.searchEmail = '';
		
		Test.startTest();
		PageReference p = obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(p == null);
	}
	
	static testmethod void testSearchMaritzID() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success';
		obj.searchCustomerId = '100';
		obj.searchFirstname = '';
		obj.searchLastname = '';
		obj.SearchAddr1 = '';
		obj.searchZip = '';
		obj.searchPhone = '';
		obj.searchEmail = '';
		
		Test.startTest();
		PageReference p = obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(p == null);
	}
	
	static testmethod void testSearchMaritzFive() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success1';
		
		Test.startTest();
		PageReference p = obj.SearchMaritz();
		Test.stopTest();
		
		System.assert(obj.OtherMaritzResults == true);
	}
	
	static testmethod void testUseExistingOne() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success';
		RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
		delete [Select id from Account where customer_id__c = '12345'];
		Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
		insert a;
		obj.selectedCustomer = '12345';
		obj.resultListMaritz = new List<Controller_CustomerSearch.mCustomerThin>();
		Controller_CustomerSearch.mCustomerThin rec = new Controller_CustomerSearch.mCustomerThin();
		rec.ContactId = '12345';
		obj.resultListMaritz.add(rec);
		
		Test.startTest();
		PageReference p = obj.UseExisting();
		Test.stopTest();
		
		System.assert(p != null);
	}
	
	static testmethod void testUseExistingTwo() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'NotFound';
		RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
		delete [Select id from Account where customer_id__c = '12345'];
		Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
		insert a;
		obj.selectedCustomer = '123456';
		obj.resultListMaritz = new List<Controller_CustomerSearch.mCustomerThin>();
		Controller_CustomerSearch.mCustomerThin rec = new Controller_CustomerSearch.mCustomerThin();
		rec.ContactId = '123456';
		obj.resultListMaritz.add(rec);
		
		Test.startTest();
		PageReference p = obj.UseExisting();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList = true);
		System.assert(obj.noMaritzResults = true);
	}
	
	static testmethod void testUseExistingThree() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'TooManyResults';
		RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
		delete [Select id from Account where customer_id__c = '12345'];
		Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
		insert a;
		obj.selectedCustomer = '123456';
		obj.resultListMaritz = new List<Controller_CustomerSearch.mCustomerThin>();
		Controller_CustomerSearch.mCustomerThin rec = new Controller_CustomerSearch.mCustomerThin();
		rec.ContactId = '123456';
		obj.resultListMaritz.add(rec);
		
		Test.startTest();
		PageReference p = obj.UseExisting();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList = true);
		System.assert(obj.TooManyMaritzResults = true);
	}
	
	static testmethod void testUseExistingFour() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success';
		RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
		delete [Select id from Account where customer_id__c = '12345'];
		Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
		insert a;
		obj.selectedCustomer = '123456';
		obj.resultListMaritz = new List<Controller_CustomerSearch.mCustomerThin>();
		Controller_CustomerSearch.mCustomerThin rec = new Controller_CustomerSearch.mCustomerThin();
		rec.ContactId = '123456';
		obj.resultListMaritz.add(rec);
		
		Test.startTest();
		PageReference p = obj.UseExisting();
		Test.stopTest();
		
		System.assert(obj.emptyMaritzList == false);
		System.assert(obj.noMaritzResults == false);
	}
	
	static testmethod void testUseExistingFive() {
		oUtil.isUnitTesting = true;
		oUtil.mockResponse = 'Success1';
		
		RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
		delete [Select id from Account where customer_id__c = '12345'];
		Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
		insert a;
		obj.selectedCustomer = '123456';
		obj.resultListMaritz = new List<Controller_CustomerSearch.mCustomerThin>();
		Controller_CustomerSearch.mCustomerThin rec = new Controller_CustomerSearch.mCustomerThin();
		rec.ContactId = '123456';
		obj.resultListMaritz.add(rec);
		
		Test.startTest();
		PageReference p = obj.UseExisting();
		Test.stopTest();
		
		System.assert(obj.OtherMaritzResults  == true);
	}
	
	static testmethod void testsearchOne() {
		oUtil.isUnitTesting = true;
		
		Test.startTest();
		PageReference p = obj.search();
		Test.stopTest();
		
	}
	
	static testmethod void testsearchTwo() {
		oUtil.isUnitTesting = true;
		obj.searchFirstname = '';
		obj.searchLastname = '';
		obj.SearchAddr1 = '';
		obj.searchZip = '';
		obj.searchPhone = '';
		obj.searchEmail = '1';
		
		Test.startTest();
		PageReference p = obj.search();
		Test.stopTest();
		
	}
	
	static testmethod void testOtherFunctions() {
		oUtil.isUnitTesting = true;
		
		Test.startTest();
		obj.reset();
		obj.createNewLead();
		obj.createNewContact();
		obj.createNewAccount();
		obj.getresultListLeads();
		obj.getresultListContacts();
		obj.getresultListAccounts();
		obj.getresultListMaritz();
		
		Test.stopTest();
		
	}
}