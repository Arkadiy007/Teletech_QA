@isTest
public class MCRelatedPIRsExtensionTests {
	
	@isTest
	static void ifNoSROnMonetaryClaim_relatedRecordsAvailableShouldBeFalse(){
		Part__c part = sObjectFactory.createPart();
		insert part;
		
		Monetary_Claim__c mc = sObjectFactory.createMC(null, null);
		insert mc;
		
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(mc);

			MCRelatedPIRsExtension editExtension = new MCRelatedPIRsExtension(sc);
        
			System.assertEquals(false, editExtension.relatedRecordsAvailable);
			System.assertEquals(null, editExtension.setCon);
		Test.stopTest();	
	}

	@isTest
	static void ifSROnMonetaryClaimWithRelatedSRI_relatedRecordsAvailableShouldBeTrue(){
		Part__c part = sObjectFactory.createPart();
		insert part;
		
		Sorting_Report__c sr = sObjectFactory.createSR(part);
		insert sr;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR-000001', part);
		pir.Supplier_Response__c = 'Accept';
		pir.Sorting_Required__c = true;
		pir.Average_Sort_Time_Per_Part__c = 20;
		insert pir;

		Sorting_Report_Item__c sri = sObjectFactory.createSRI(sr, pir);
		insert sri;


		sr.Supplier_Response__c = 'Accept';
		update sr;

		Monetary_Claim__c mc = sObjectFactory.createMC(sr, null);
		insert mc;
		
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(mc);

			MCRelatedPIRsExtension editExtension = new MCRelatedPIRsExtension(sc);
        
			System.assertEquals(true, editExtension.relatedRecordsAvailable);
			System.assertEquals(1, editExtension.sortingReportItems.size());
		Test.stopTest();	
	}

}