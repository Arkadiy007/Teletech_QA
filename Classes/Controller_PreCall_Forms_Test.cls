/**********************************************************************
Name: Controller_PreCall_Forms_Test
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_PreCall_Forms

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 03/06/2015 Created
***********************************************************************/
@isTest
public class Controller_PreCall_Forms_Test {
	private static String dealerRecordTypeName = 'Dealer';
	private static String nissanRecordTypeName = 'Nissan';

	static testmethod void testOnNullWarrantyCaseId() {
		Account dealer = setDealerAccount();
		Vehicle__c veh = setVehicle();

		PageReference pageRef = Page.PreCall_Forms;
		Test.setCurrentPage(pageRef);
		Controller_PreCall_Forms controllerPreCallForms = new Controller_PreCall_Forms();

		PageReference pageRefOID = controllerPreCallForms.getOID();
		PageReference pageRefNull = new PageReference('/apex/PreCall_Forms_For_Attachment?id=' + null);
		System.assertEquals(pageRefOID.getURL(), pageRefNull.getURL());
	}

	// HELPERS-----------------------------------------------------------//
	private static Account  setDealerAccount() {
		//retrieving Dealer record type
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=:dealerRecordTypeName');
		//creation of Dealer Account
		Account dealer = new Account(RecordTypeId = rt[0].Id, Dealer_Code__c = '123', Name = 'TestDealer');

		insert dealer;
		return dealer;
	}

	private static Vehicle__c  setVehicle() {
		//retrieving Dealer record type
		String sobjectTypeVeh = 'Vehicle__c'; 
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=: nissanRecordTypeName AND SobjectType=: sobjectTypeVeh');
		//creation of Vehicle
		Vehicle__c veh = new Vehicle__c(RecordTypeId = rt[0].Id, Vehicle_identification_Number__c = '11111111111111111');

		insert veh;
		return veh;
	}
 }