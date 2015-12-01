/**********************************************************************
  Name: OCP_File_BeforeTests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for OCP_File_Before trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 01/19/2015 Created
 ***********************************************************************/
@isTest
public class OCP_File_BeforeTests {

	private static Group cccGroup;
	final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];

	static testMethod void testTriggerCreatesCase_ShouldCreateCaseAndNewCustomerAccount_WhenTHereIsNoCustomerAccount() {
		Vehicle__c vehicle = CreateVehicle();
		CreateGroup();
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			
			CreateQueue();
		}		

		Account dealer = CreateDealerAccount();

		OCP_File__c file = CreateOCPFIle();

		test.starttest();

		insert file;

		test.stoptest();

		Account account = [Select Id, PersonContactId FROM Account WHERE Customer_ID__c = :file.Contactid__c];

		Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Preferred_Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :account.Id];
		system.assertEquals(dealer.Id, c.Preferred_Dealer__c);
		system.assertEquals(dealer.Id, c.Dealer__c);
		system.assertEquals(vehicle.Id, c.Vehicle_Name__c);
	}

	private static void CreateGroup() {
		cccGroup = new Group(Name = 'CCC Campaign Queue', Type = 'Queue');
		insert cccGroup;
	}



	private static void CreateQueue(){
		QueueSobject cccQueue = new QueueSobject(QueueId = cccGroup.Id, SobjectType = 'Case');
		insert cccQueue;
	}

	private static OCP_File__c CreateOCPFIle() {
		OCP_File__c ocp = new OCP_File__c();
		ocp.PhoneTMID__c = '2027213961';
		ocp.Contactid__c = '85358258';
		ocp.FirstName__c = 'MARCOLIVIER';
		ocp.MiddleInitial__c = ' ';
		ocp.LastName__c = 'COPPENS';
		ocp.Address1__c = '18 FREEMAN RD';
		ocp.City__c = 'ALBANY';
		ocp.State__c = 'NY';
		ocp.ZipCode__c = '12208';
		ocp.Zip4__c = '1844';
		ocp.Make__c = 'Infiniti';
		ocp.MonthMailed__c = '12';
		ocp.VINCurrent__c = 'JNKBV61F18M271457';
		ocp.ModelNameCurrent__c = 'G35x';
		ocp.MdlyrCurrent__c = '2008';
		ocp.LeaseStartDate__c = '7312008';
		ocp.SegmentMailed__c = 'Non-captive';
		ocp.ControlGroup__c = 'FALSE';
		ocp.dealer__c = '71407';
		ocp.dealername__c = 'LIA INFINITI';
		ocp.ServiceMileage__c = '23387';
		ocp.VehicleEverOwned__c = '1';
		ocp.IMTdecile__c = '4';

		return ocp;
	}

	private static Vehicle__c CreateVehicle() {
		Vehicle__c vehicle = new Vehicle__c();
		vehicle.Vehicle_identification_Number__c = 'JNKBV61F18M271457';
		insert vehicle;

		return vehicle;
	}

	private static Account CreateCustomerAccount() {
		RecordType myRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];

		Account account = new Account();
		account.lastName = 'Account';
		account.FirstName = 'firstname';
		account.Customer_ID__c = '85358258';
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
		preferredAccount.Dealer_Code__c = '71407';
        insert preferredAccount; 

		return preferredAccount;
	}

}