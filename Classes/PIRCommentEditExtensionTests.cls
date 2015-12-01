@isTest
public class PIRCommentEditExtensionTests {
	@isTest
	static void saveAndNewShouldRedirectToNewPIRPage(){
		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(new PIR_Comment__c());

			PIRCommentEditExtension editExtension = new PIRCommentEditExtension(sc);
        
			PageReference pageRef = Page.PIRCommentEdit;
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.saveAndNew().getUrl().contains('PIRCommentEdit'));


		Test.stopTest();
	}

	@isTest
	static void saveShouldRedirectToParentSRPageIfAllValidationsArePassed(){
		Part__c part = sObjectFactory.createPart();
		insert part;

		Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR_Comment__c-2222', part);
		insert pir;


		Test.startTest();

			ApexPages.StandardController sc = new ApexPages.StandardController(new PIR_Comment__c());
			PIRCommentEditExtension editExtension = new PIRCommentEditExtension(sc);
        
			PageReference pageRef = Page.PIRCommentEdit;
			pageRef.getParameters().put('retUrl', String.valueOf(pir.Id));
			Test.setCurrentPage(pageRef);
   
			System.assert(editExtension.save().getUrl().contains(String.valueOf(pir.Id)));

		Test.stopTest();
	}
}