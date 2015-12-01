@isTest
public class SRIEditExtensionTest {

	@isTest
	static void saveAndNewShouldRedirectToNewSRIPage(){
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new Sorting_Report_Item__c());

			SRIEditExtension editExtension = new SRIEditExtension(sc);
        
			PageReference pageRef = Page.SortingReportItemEdit;
			Test.setCurrentPage(pageRef);
   
			System.assertEquals(editExtension.saveAndNew(), null);

		Test.stopTest();
	}

	@isTest
	static void saveShouldRedirectToParentSRPageIfAllValidationsArePassed(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		pir.Sorting_Required__c = true;
		pir.Average_Sort_Time_Per_Part__c = 100;
		insert pir;

		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;


		Test.startTest();
			Sorting_Report_Item__c sri = new Sorting_Report_Item__c();
			sri.Sorting_Report__c = sr.Id;
			sri.Part_Incident_Report__c = pir.Id;

			ApexPages.StandardController sc = new ApexPages.StandardController(sri);
			SRIEditExtension editExtension = new SRIEditExtension(sc);
        
			PageReference pageRef = Page.SortingReportItemEdit;
			pageRef.getParameters().put('retUrl', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.save().getUrl().contains(String.valueOf(sr.Id)));

		Test.stopTest();
	}

	@isTest
	static void ifErrorOccurs_PagereferenceShouldBeNullSaveAndSend(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		pir.Sorting_Required__c = true;
		pir.Average_Sort_Time_Per_Part__c = 100;
		insert pir;

		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;


		Test.startTest();
			Sorting_Report_Item__c sri = new Sorting_Report_Item__c();
			sri.Sorting_Report__c = sr.Id;

			ApexPages.StandardController sc = new ApexPages.StandardController(sri);
			SRIEditExtension editExtension = new SRIEditExtension(sc);
        
			PageReference pageRef = Page.SortingReportItemEdit;
			pageRef.getParameters().put('retUrl', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.saveAndNew() == null);

		Test.stopTest();
	}

	@isTest
	static void ifErrorOccurs_PagereferenceShouldBeNullSave(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		pir.Sorting_Required__c = true;
		pir.Average_Sort_Time_Per_Part__c = 100;
		insert pir;

		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;


		Test.startTest();
			Sorting_Report_Item__c sri = new Sorting_Report_Item__c();
			sri.Sorting_Report__c = sr.Id;

			ApexPages.StandardController sc = new ApexPages.StandardController(sri);
			SRIEditExtension editExtension = new SRIEditExtension(sc);
        
			PageReference pageRef = Page.SortingReportItemEdit;
			pageRef.getParameters().put('retUrl', String.valueOf(sr.Id));
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.save() == null);

		Test.stopTest();
	}
}