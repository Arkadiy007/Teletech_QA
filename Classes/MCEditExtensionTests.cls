@isTest
public class MCEditExtensionTests {

	@isTest
	static void saveAndNewShouldRedirectToNewMCPage() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Monetary_Claim__c());

			MCEditExtension editExtension = new MCEditExtension(sc);

			PageReference pageRef = Page.MCEdit;
			Test.setCurrentPage(pageRef);

			System.assert(editExtension.saveAndNew().getUrl().contains('MCEdit'));

			//also, check for Layout
			System.assert(!editExtension.isGoldPartner);

		Test.stopTest();
	}



	@isTest
	static void saveSendAndNewShouldRedirectToNewMCPage() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Monetary_Claim__c());

			MCEditExtension editExtension = new MCEditExtension(sc);
			editExtension.selectedPlant = 'St. Petersburg';
			PageReference pageRef = Page.MCEdit;
			Test.setCurrentPage(pageRef);

			editExtension.saveSendAndNew();
			System.assert(!editExtension.isGoldPartner);

		Test.stopTest();
	}

	@isTest
	static void saveAndSend_ShouldPopulateLastModifiedByCustomer() {
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Monetary_Claim__c(Monetary_Claim_Number__c = 'Test 1'));

			MCEditExtension editExtension = new MCEditExtension(sc);

			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);
			editExtension.saveAndSend();


			System.assert([SELECT Count() FROM Monetary_Claim__c WHERE Name = 'Test 1' AND Last_Modified_By_Customer__c != null] > 0);
			//also, check for Layout
			System.assert(!editExtension.isGoldPartner);

		Test.stopTest();
	}


	@isTest
	static void ifYouUpdateMCWithClaimStatusEqualsToClosed_ClosedDateShouldBePopulated(){
		Monetary_Claim__c mc = sObjectFactory.createMC(null, null);
		insert mc;		

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(mc);
			
			PageReference pageRef = Page.MCEdit;
			pageRef.getParameters().put('id', String.valueOf(mc.Id));
			Test.setCurrentPage(pageRef);

			MCEditExtension editExtension = new MCEditExtension(sc);
			mc = (Monetary_Claim__c) editExtension.mcController.getRecord();
			mc.Claim_Status__c = 'Closed';
			editExtension.save();


			System.assertEquals(1, [SELECT Count() FROM Monetary_Claim__c WHERE Claim_Status__c = 'Closed' AND Closed_Date__c != null AND Reopen_Count__c = 0]);
			//also, check for Layout
			System.assert(!editExtension.isGoldPartner);


			//reopen mc
			mc.Claim_Status__c = 'Open';
			editExtension.save();

			//refresh reopen count and close opportunity
			mc.Claim_Status__c = 'Closed';
			mc.Reopen_Count__c = null;
			editExtension.save();


			//reopen mc
			mc.Claim_Status__c = 'Open';
			editExtension.save();
			System.assertEquals(1, [SELECT Count() FROM Monetary_Claim__c WHERE Claim_Status__c = 'Open']);
			
		Test.stopTest();

	}

 }