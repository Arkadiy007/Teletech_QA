/**********************************************************************
  Name: NissanWelcomeCalls_Before_Tests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for NissanWelcomeCalls_Before trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 03/03/2015 Created
  ***********************************************************************/
@isTest
public class NissanWelcomeCalls_Before_Tests { 
	private static Group cccGroup;

	final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];

	static testMethod void testNissanWelcomeCallsBefore_ShouldnotCreateCase_WhenTHereIsNoCustomerAccount() {
		Nissan_Daily_Welcome_Call__c call = CreateWelcomeCallInstance();

		test.starttest();

		insert call;

		test.stoptest();

		List<Case> c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where Contact_ID__c = :call.CustomerID__c];
		system.assertEquals(0, c.size());
	}

	static testMethod void testNissanWelcomeCallsBefore_ShouldCreateNewCase() {
		CreateGroups();
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {			
			CreateQueues();
		}	
		User user = CreateUser();
		Vehicle__c vehicle = CreateVehicle();
		Account customer = CreateCustomerAccount();
		Account dealer = CreateDealerAccount();
		Nissan_Daily_Welcome_Call__c welcomecall = CreateWelcomeCallInstance();

		test.starttest();

		insert welcomecall;

		test.stoptest();

		Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
		system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
		system.assertEquals(dealer.Id, c.Dealer__c);
		system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
	}

	private static void CreateQueues(){
		QueueSobject cccQueue = new QueueSobject(QueueId = cccGroup.Id, SobjectType = 'Case');
		insert cccQueue;
	}

	private static void CreateGroups(){
		cccGroup = new Group(Name='CCC Campaign Queue', Type='Queue');
		insert cccGroup;
	}

	private static User CreateUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User user = new User(Alias = 'TCS-MW', Email='standarduser@testorg.com', 
		      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		      LocaleSidKey='en_US', ProfileId = p.Id, 
		      TimeZoneSidKey='America/Los_Angeles', UserName='tst@testorg.com');
		insert user;

		return user;
	}

	private static Nissan_Daily_Welcome_Call__c CreateWelcomeCallInstance(){
		Nissan_Daily_Welcome_Call__c call = new Nissan_Daily_Welcome_Call__c();
		call.CustomerID__c = '143770668';
		call.VIN__c = '3N1CE2CP1EL407518';
		call.Retailing_Dealer_Number__c = '9080';
		call.Account_First_Name__c = 'Erin';
		call.Account_Last_name__c = 'Clark';

		return call;
	}

	private static Vehicle__c CreateVehicle() {
		Vehicle__c vehicle = new Vehicle__c();
		vehicle.Vehicle_identification_Number__c = '3N1CE2CP1EL407518';
		insert vehicle;

		return vehicle;
	}

	private static Account CreateCustomerAccount() {
		RecordType myRecordType = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1];
		
		Account account = new Account();
		account.lastName = 'Account';
        account.FirstName = 'firstname';
		account.Customer_ID__c = '143770668';
		account.Recordtypeid = myRecordType.Id;
		insert account;

		return account;
	}

	private static Account CreateDealerAccount() {
		Account preferredAccount = new Account();
        preferredAccount.name = 'Account';
        preferredAccount.RecordTypeId = dealerType.id;
        preferredAccount.Dealer_Code__c = 'Test';
        preferredAccount.Dealer_External_Id__c = 'Test_USA';
		preferredAccount.Dealer_Code__c = '9080';
        insert preferredAccount; 

		return preferredAccount;
	}
}