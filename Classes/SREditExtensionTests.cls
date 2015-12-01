@isTest
public class SREditExtensionTests {

	@isTest
	static void saveAndNewShouldRedirectToNewSRPage() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report__c());

			SREditExtension editExtension = new SREditExtension(sc);

			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);

			System.assert(editExtension.saveAndNew().getUrl().contains('SREdit'));

			//also, check for Layout
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}



	@isTest
	static void saveSendAndNewShouldRedirectToNewSRPage() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report__c());

			SREditExtension editExtension = new SREditExtension(sc);
			editExtension.selectedPlant = 'St. Petersburg';
			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);

			editExtension.saveSendAndNew();
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}

	@isTest
	static void saveAndSend_ShouldPopulateLastModifiedByCustomer() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report__c(Sorting_Report_Number__c = 'Test 1'));

			SREditExtension editExtension = new SREditExtension(sc);

			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);
			editExtension.selectedPlant = 'Test';
			editExtension.saveAndSend();


			System.assert([SELECT Count() FROM Sorting_Report__c WHERE Name = 'Test 1' AND Last_Modified_By_Customer__c != null] > 0);
			//also, check for Layout
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}

	@isTest
	static void saveShouldRedirectToParentSRPageIfAllValidationsArePassed() {
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		insert pir;

		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;


		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report__c());
			SREditExtension editExtension = new SREditExtension(sc);

			PageReference pageRef = Page.SREdit;
			pageRef.getParameters().put('id', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);

			editExtension.save();

		Test.stopTest();

		System.assertEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Sorting_Report__c LIMIT 1] [0].OwnerId);
	}
/*
	@isTest
	static void forCustomer_PlantShouldBePrepopulated() {
		Account customerAccount = createPortalAccount('NMGR', 'Plant', false);
		customerAccount.Plant__c = 'St. Petersburg';
		insert customerAccount;

		Contact cust = 


		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report__c());
			SREditExtension editExtension = new SREditExtension(sc);

			PageReference pageRef = Page.SREdit;
			pageRef.getParameters().put('id', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);

			editExtension.save();

		Test.stopTest();

		System.assertEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Sorting_Report__c LIMIT 1] [0].OwnerId);
	}

*/

	@isTest
	static void ifYouUpdateSRWithClaimStatusEqualsToClosed_ClosedDateShouldBePopulated(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;		

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(sr);
			
			PageReference pageRef = Page.SREdit;
			pageRef.getParameters().put('id', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);

			SREditExtension editExtension = new SREditExtension(sc);
			sr = (Sorting_Report__c) editExtension.srController.getRecord();
			sr.Status__c = 'Closed';
			editExtension.save();


			System.assertEquals(1, [SELECT Count() FROM Sorting_Report__c WHERE Status__c = 'Closed' AND Closed_Date__c != null AND Reopen_Count__c = 0]);
			//also, check for Layout
			System.assert(!editExtension.isGoldPartner);


			//reopen sr
			sr.Status__c = 'Open';
			editExtension.save();

			System.assertEquals(1, [SELECT Count() FROM Sorting_Report__c WHERE Reopen_Count__c > 0]);
			
			//refresh reopen count and close opportunity
			sr.Status__c = 'Closed';
			sr.Reopen_Count__c = null;
			editExtension.save();


			//reopen sr
			sr.Status__c = 'Open';
			editExtension.save();
			System.assertEquals(1, [SELECT Count() FROM Sorting_Report__c WHERE Reopen_Count__c > 0]);
			
		Test.stopTest();

	}

	private static User createPortalUser(String userName, String profileName, Id contactId, Boolean needInsert) {
		// Create user for the contact
		Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
		User portalUser = new User(
		                           Username = userName + System.currentTimeMillis(),
		                           ContactId = contactId,
		                           ProfileId = portalProfile.Id,
		                           Alias = 'Nissan',
		                           Email = 'Nissan@test.com',
		                           EmailEncodingKey = 'UTF-8',
		                           LastName = 'Kumar',
		                           CommunityNickname = 'nissan' + System.currentTimeMillis(),
		                           TimeZoneSidKey = 'America/Los_Angeles',
		                           LocaleSidKey = 'en_US',
		                           LanguageLocaleKey = 'en_US'
		);

		if (needInsert) {
			insert portalUser;
		}

		return portalUser;
	}

	private static Account createPortalAccount(String name, String recordType, Boolean needInsert) {
		// Create account
		Account portalAccount = new Account(
		                                    Name = name,
		                                    RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, recordType)
		);

		if (needInsert) {
			insert portalAccount;
		}

		return portalAccount;
	}

	private static Contact createPortalContact(String firstName, String lastName, Id accountId, Boolean needInsert) {
		// Create contact for the account, which will enable partner portal for account
		Contact portalContact = new Contact(
		                                    FirstName = firstName,
		                                    Lastname = lastName,
		                                    AccountId = accountId,
		                                    Email = lastName + '@nissan.com',
		                                    RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Contact.SObjectType, 'Contact')
		);

		if (needInsert) {
			insert portalContact;
		}

		return portalContact;
	}

}