@isTest
public class PIREditControllerTests {
	@isTest
	static void saveAndNewShouldRedirectToNewPIRPage(){
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Part_Incident_Report__c());

			PIREditController editExtension = new PIREditController(sc);
        
			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.saveAndNew().getUrl().contains('PIREdit'));

			//also, check for Layout
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}

	@isTest
	static void saveSendAndNewShouldRedirectToNewPIRPage(){
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Part_Incident_Report__c());

			PIREditController editExtension = new PIREditController(sc);
        
			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.saveSendAndNew().getUrl().contains('PIREdit'));

			//also, check for Layout
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}

	@isTest
	static void saveAndSend_ShouldPopulateLastModifiedByCustomer(){
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Part_Incident_Report__c(PIR_Number__c = 'Test 1'));

			PIREditController editExtension = new PIREditController(sc);
        
			PageReference pageRef = Page.SREdit;
			Test.setCurrentPage(pageRef);
			editExtension.saveAndSend();


			System.assertEquals(1, [SELECT Count() FROM Part_Incident_Report__c WHERE Name = 'Test 1' AND Last_Modified_By_Customer__c != null]);
			//also, check for Layout
			System.assert(!editExtension.isSupplierLayout);

		Test.stopTest();
	}


	@isTest
	static void onsaveIfCommentsNotNull_PIRCommentShouldBeCreated(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		insert pir;


		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Part_Incident_Report__c());
			PIREditController editExtension = new PIREditController(sc);
			editExtension.comments = 'Test Comment';
        
			PageReference pageRef = Page.PIREdit;
			pageRef.getParameters().put('id', String.valueOf(pir.Id));
			Test.setCurrentPage(pageRef);
   
			editExtension.save();

		Test.stopTest();

			System.assertEquals('Test Comment', [SELECT Comment__c FROM PIR_Comment__c LIMIT 1][0].Comment__c);
	}

	@isTest
	static void ifYouUpdateSRWithClaimStatusEqualsToClosed_ClosedDateShouldBePopulated(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('Test PIR', part);
		insert pir;		

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(pir);
			
			PageReference pageRef = Page.SREdit;
			pageRef.getParameters().put('id', String.valueOf(pir.Id));
			Test.setCurrentPage(pageRef);

			PIREditController editExtension = new PIREditController(sc);
			pir = (Part_Incident_Report__c) editExtension.pirController.getRecord();
			pir.RAN_Number__c = 'Test RAN';
			pir.PIR_Status__c = 'Closed';

			editExtension.save();


			System.assertEquals(1, [SELECT Count() FROM Part_Incident_Report__c WHERE PIR_Status__c = 'Closed' AND Closed_Date__c != null]);
			//also, check for Layout
			System.assert(!editExtension.isGoldPartner);
			
		Test.stopTest();

	}


}