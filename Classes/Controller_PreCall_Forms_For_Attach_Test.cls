/**********************************************************************
Name: Controller_PreCall_Forms_For_Attach_Test
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_PreCall_Forms_For_Attachment 

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 01/05/2015 Created
***********************************************************************/
@isTest
public class Controller_PreCall_Forms_For_Attach_Test { 
	private static String warrantyCaseRecordTypeNameEngine = 'Engine VCAN';
	private static String warrantyCaseRecordTypeNameCVT = 'Trans VCAN';
	private static String warrantyCaseRecordTypeNameLEAF = 'Leaf Precall';
	private static String dealerRecordTypeName = 'Dealer';
	private static String nissanRecordTypeName = 'Nissan';

    static testMethod void testCreateAttachmentRequest() {
        Warranty_Case__c warrantyCaseRecord = setWarrantyCase(warrantyCaseRecordTypeNameEngine);

        Test.setCurrentPageReference(new PageReference('PreCall_Forms_For_Attachment'));
        System.currentPageReference().getParameters().put('id', warrantyCaseRecord.Id);
        
        Controller_PreCall_Forms_For_Attachment controller = new Controller_PreCall_Forms_For_Attachment();

		controller.fileSize = 1000;
        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.fileName = 'test';
        controller.upload();

        Attachment[] attachments = new List<Attachment>();
        attachments  = [SELECT Id, ParentId FROM Attachment];

        System.assertEquals(1, attachments.size());
    }

	static testMethod void testNotCreateAttachmentRequest() {
        Warranty_Case__c warrantyCaseRecord = setWarrantyCase(warrantyCaseRecordTypeNameEngine);

        Test.setCurrentPageReference(new PageReference('PreCall_Forms_For_Attachment'));
        System.currentPageReference().getParameters().put('id', warrantyCaseRecord.Id);
        
        Controller_PreCall_Forms_For_Attachment controller = new Controller_PreCall_Forms_For_Attachment();

        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.fileName = 'test';
        controller.upload();

        Attachment[] attachments = new List<Attachment>();
        attachments  = [SELECT Id, ParentId FROM Attachment];

        System.assertEquals(0, attachments.size());
    }

    static testMethod void testFinishWithoutAttaching() {
        Warranty_Case__c warrantyCaseRecord = setWarrantyCase(warrantyCaseRecordTypeNameCVT);

        Test.setCurrentPageReference(new PageReference('PreCall_Forms_For_Attachment'));
        System.currentPageReference().getParameters().put('id', warrantyCaseRecord.Id);
        
        Controller_PreCall_Forms_For_Attachment controller = new Controller_PreCall_Forms_For_Attachment();

		String testString;
		testString = controller.instruction;
		testString = controller.messageBeforeNextButton;
		//controller.messageBeforeNextButton;

        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.fileName = 'test';
        controller.next();

        Attachment[] attachments = new List<Attachment>();
        attachments  = [SELECT Id, ParentId FROM Attachment];

        System.assertEquals(0, attachments.size());
    }

	static testMethod void testFileIsNotSelectedAndNameIsBlank() {
        Warranty_Case__c warrantyCaseRecord = setWarrantyCase(warrantyCaseRecordTypeNameCVT);

        Test.setCurrentPageReference(new PageReference('PreCall_Forms_For_Attachment'));
        System.currentPageReference().getParameters().put('id', warrantyCaseRecord.Id);
        
        Controller_PreCall_Forms_For_Attachment controller = new Controller_PreCall_Forms_For_Attachment();

		String testString;
		testString = controller.instruction;
		testString = controller.messageBeforeNextButton;
		//controller.messageBeforeNextButton;

        controller.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.next();

		controller.fileName = 'test';
		controller.attachment.Body = null;
		controller.next();

        Attachment[] attachments = new List<Attachment>();
        attachments  = [SELECT Id, ParentId FROM Attachment];

        System.assertEquals(0, attachments.size());
    }
	
	// HELPERS-----------------------------------------------------------//
	private static Warranty_Case__c  setWarrantyCase(String recType) {
		//retrieving Warranty_Case__c record type
		List<RecordType> rt = Database.query('SELECT Id, Name FROM RecordType WHERE Name=: recType');
		//creation of Warranty_Case__c record
		Date repair_Work_Order_Open_Date = Date.today();
		Account testAccount = setDealerAccount();
        Vehicle__c testVehicle = setVehicle();
		Warranty_Case__c warrantyCaseRecord = New Warranty_Case__c (RecordTypeId = rt[0].Id, Customer_Name__c = 'test', Approval_Status__c = 'Pending',
                                                                    Requestor_s_Name__c = 'testReq', Vehicle_Mileage__c = 120, Repair_Work_Order_Open_Date__c = repair_Work_Order_Open_Date, 
																	When_was_TECH_LINE_contacted__c = repair_Work_Order_Open_Date, Vehicle__c = testVehicle.Id, Dealer__c = testAccount.Id, 
																	Job_Line_Number__c = '123', Repair_Work_Order__c = '123'
                                                                    ); 
		insert warrantyCaseRecord;
		return warrantyCaseRecord;
	}

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