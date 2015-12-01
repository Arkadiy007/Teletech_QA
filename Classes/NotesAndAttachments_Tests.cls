/**********************************************************************
Name: NotesAndAttachments_Tests
Copyright ?? notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for NotesAndAttachments 

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 10/21/2015 Created
***********************************************************************/
@isTest
public class NotesAndAttachments_Tests { 
	static testmethod void pageCreationTest() {
		Part_Incident_Report__c pir = createPIR();
		PageReference naa = Page.PIRNotesAndAttachments;
		Test.setCurrentPage(naa);
		System.currentPageReference().getParameters().put('id', pir.Id);

		ApexPages.StandardController sc = new ApexPages.standardController(pir);
		NotesAndAttachments controller = new NotesAndAttachments(sc);
		
		System.assertEquals((String)pir.id, controller.parentRecordId);
	}

	static testmethod void pageDelAttachmentTest() {
		Part_Incident_Report__c pir = createPIR();
		Attachment att = createAttachment(pir.Id);

		PageReference naa = Page.PIRNotesAndAttachments;
		Test.setCurrentPage(naa);
		System.currentPageReference().getParameters().put('id', pir.Id);

		ApexPages.StandardController sc = new ApexPages.standardController(pir);
		NotesAndAttachments controller = new NotesAndAttachments(sc);
		
		Boolean areAttachmentsUpdatable = controller.areAttachmentsUpdatable;
		controller.currentIndex = 0;
		PageReference delAttacment = controller.delAttacment();

		Attachment[] atts = [SELECT Id FROM Attachment WHERE ParentId =: pir.Id]; 
		
		System.assertNotEquals(null, areAttachmentsUpdatable);
		System.assertEquals(0, atts.size());
	}


	//------Helpers-----//
	private static Part_Incident_Report__c createPIR() {
		Part_Incident_Report__c pir = new Part_Incident_Report__c();
		insert pir;

		return pir;
	}

	private static Attachment createAttachment(Id parentId) {
		Blob body = Blob.valueOf('test');
		Attachment att = new Attachment(Name = 'test', ParentId = parentId, Body = body);
		insert att;

		return att;
	}
}