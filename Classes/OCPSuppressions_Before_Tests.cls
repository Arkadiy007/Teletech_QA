/**********************************************************************
  Name: OCPSuppressions_Before_Tests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for OCPSuppressions_Before trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 03/03/2015 Created
  ***********************************************************************/
@isTest
public class OCPSuppressions_Before_Tests { 
	static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
	static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';

	static testMethod void testOcpSuppressions_ShouldUpdateSuppression_IfThereIsNoCaseFound() {
		OCP_Suppression__c suppression = CreateSupression('Bankrupt');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<OCP_Suppression__c> updatedsuppression = [Select Id, Successful__c, Error_Description__c FROM OCP_Suppression__c Where Id = :suppression.Id];
		system.assertEquals(false, updatedsuppression.get(0).Successful__c);
		system.assertEquals('No Cases are found', updatedsuppression.get(0).Error_Description__c);
	} 

	static testMethod void testOcpSuppressions_ShouldCloseCase_IfSuppressioTypeIsBankrupt() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('Bankrupt');
		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals('Closed', updatedCase.get(0).Status);
		system.assertEquals(true, updatedCase.get(0).Closed_by_Suppression__c);
	}

	static testMethod void testOcpSuppressions_ShouldCloseCase_IfSuppressioTypeIsDelinquent() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('Delinquent');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals('Closed', updatedCase.get(0).Status);
		system.assertEquals(true, updatedCase.get(0).Closed_by_Suppression__c);
	}

	static testMethod void testOcpSuppressions_ShouldCloseCase_IfSuppressioTypeIsRepo() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('Repo');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals('Closed', updatedCase.get(0).Status);
		system.assertEquals(true, updatedCase.get(0).Closed_by_Suppression__c);
	}

	static testMethod void testOcpSuppressions_ShouldCloseCase_IfSuppressioTypeIsTerminated() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('Terminated');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals('Closed', updatedCase.get(0).Status);
		system.assertEquals(true, updatedCase.get(0).Closed_by_Suppression__c);
	}

	static testMethod void testOcpSuppressions_ShouldUpdateDoNotContact_IfSuppressioTypeIsDoNotContact() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('DoNotContact');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals(true, updatedCase.get(0).Do_Not_Contact__c);
	}

	static testMethod void testOcpSuppressions_ShouldUpdateCase_IfSuppressioTypeIsDoNotCall() {
		testData();
		Case c = CreateCase();
		OCP_Suppression__c suppression = CreateSupression('DoNotCall');

		test.starttest();

		insert suppression;

		test.stoptest();

		List<Case> updatedCase = [Select Id, Status, Closed_by_Suppression__c, Do_Not_Contact__c, Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call__c, Work_Phone_Do_Not_Call__c FROM Case Where Id = :c.Id];
		system.assertEquals(true, updatedCase.get(0).Home_Phone_Do_Not_Call__c);
		system.assertEquals(true, updatedCase.get(0).Mobile_Phone_Do_Not_Call__c);
		system.assertEquals(true, updatedCase.get(0).Work_Phone_Do_Not_Call__c);
	}

    private static void testdata() {
        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Customer_ID__c = CUSTOMER_ID;
        insert account;

        lead.lastname = 'leadTest';
        lead.Customer_ID__c = CUSTOMER_ID;
        insert lead;

        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        insert dealer;
   }

	private static Case CreateCase(){
		Case c = new Case();
		RecordType leaseLoyaltyRecordType = [Select Id, Name from RecordType WHERE Name = :'Lease Loyalty' limit 1];
		c.recordTypeId = leaseLoyaltyRecordType.id;
		c.Status = 'Open';
		c.Segment_Mailed__c = 'leaseType';
		c.VIN__c = '5240957405';
		c.Account = account;
		insert c;
		return c;
	}

	private static OCP_Suppression__c CreateSupression(String suppressionType){
		OCP_Suppression__c suppression = new OCP_Suppression__c();
		suppression.VIN__c = '5240957405';
		suppression.LeaseType__c = 'leaseType';
		suppression.SuppressionType__c = suppressionType;
		return suppression;
	}
}