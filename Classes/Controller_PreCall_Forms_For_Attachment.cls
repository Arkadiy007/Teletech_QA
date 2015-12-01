/**********************************************************************
  Name: Controller_PreCall_Forms_For_Attachment
  Copyright ?? notice: Nissan Motor Company
  ======================================================
  Purpose:
  Controller of PreCall_Forms_For_Attachment page

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev 12/29/2014 Created
  1.01 - Arkadiy Sychev 01/08/2015 added possibility to show list of the files already attached to the Warranty Case record
  1.02 - Arkadiy Sychev 04/27/2015 removed PDF creation functionality, added 'next' button navigates to PreCall_Forms_Finish page
  ***********************************************************************/
public with sharing class Controller_PreCall_Forms_For_Attachment {
    private Id warrantyCaseId { get; set; }
    public List<Attachment> attachments { get; set; }
	private List<Warranty_Case__c> warrantyCaseRecord;
	private String currentRecordTypeName;
	public Integer fileSize {get; set;}
	public Attachment attachment { get; set;}
	public String extension {get; set;}
	private Boolean wasAttachmentAdded;
	public String fileName {get; set;}
	public String intrnalFileName {get; set;}

	private static final String SERVICE_CONTRACT_CLAIM = 'Service Contract Claim';

	public String instruction { get {
			if (currentRecordTypeName == RECORDTYPE_ENGINE) {
				return INSTRUCTION_FOR_ENGINE;
			} else if (currentRecordTypeName == RECORDTYPE_CVT) {
				 return INSTRUCTION_FOR_CVT;
			} 
				 return INSTRUCTION_FOR_LEAF;
		}
		set;
		}

	public String messageBeforeNextButton {get{
		if (currentRecordTypeName == RECORDTYPE_ENGINE) {
				return MESSAGE_BEFORE_NEXT_FOR_ENGINE;
			} 
				 return MESSAGE_BEFORE_NEXT;
		}
		set;
		}

	//CONSTANTS
	private static String RECORDTYPE_ENGINE = 'Engine VCAN';
	private static String RECORDTYPE_CVT = 'Trans VCAN';
	private static String RECORDTYPE_LEAF = 'Leaf Precall';
	
	//Instruction designations
	public static String INSTRUCTION_FOR_ENGINE = 'Attach supporting documentation to verify failure and vehicle maintenance (repair order, VIN, odometer, valve train, oil pick up tube, inside lower oil pan, and failure). Attachment size should be less than 25MB.';
	public static String INSTRUCTION_FOR_CVT = 'Attach supporting documentation to verify failure (repair order, VIN, odometer, inside trans pan/debris as needed). Attachment size should be less than 25MB.';
	public static String INSTRUCTION_FOR_LEAF = 'Please upload an attachment if it is need. Attachment size should be less than 25MB.';

	//Designations before the Next button
	public static String MESSAGE_BEFORE_NEXT_FOR_ENGINE = 'Please add attachments and click Next ';
	public static String MESSAGE_BEFORE_NEXT = 'If no attachments, please click Next ';

    public Controller_PreCall_Forms_For_Attachment() {
		attachment = new Attachment();
        warrantyCaseId = apexpages.currentpage().getparameters().get('id');
		wasAttachmentAdded = false;
        if (warrantyCaseId != null && !String.isEmpty(String.valueOf(warrantyCaseId))) {
			warrantyCaseRecord = Database.query('SELECT Id, Name, Dealer_Code__c, RecordTypeId, Coverage_Type__C FROM Warranty_Case__c WHERE Id =: warrantyCaseId LIMIT 1');
            attachments = Database.query('SELECT Id, BodyLength, ContentType, Description, Name, IsPrivate FROM Attachment WHERE ParentId =: warrantyCaseId');
			String recTypeId = warrantyCaseRecord[0].RecordTypeId;

			Map<Id,Schema.RecordTypeInfo> recordTypeInfo = Warranty_Case__c.SObjectType.getDescribe().getRecordTypeInfosById();
			currentRecordTypeName = recordTypeInfo.get(recTypeId).getName();
        }
    }

    public PageReference upload() {
		if (String.isEmpty(fileName)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, set the file name before uploading'));
			//this.attachment = new Attachment();
			return ApexPages.currentPage();
		}

		if (attachment.body == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, select a file before saving'));
			return ApexPages.currentPage();
		}
		if (fileSize < 26214400) {
			
			Attachment a = attachment.clone(false, true, false, false);

			//clear body of uploaded file to remove from view state
			attachment.body = null;
 
			//create the attachment
			a.OwnerId = UserInfo.getUserId();
			a.ParentId = warrantyCaseId; // the record the file is attached to
			a.IsPrivate = false;
			a.Name = fileName + '.' + extension;

			try {
				Database.Insert(a);
				wasAttachmentAdded = true;
				a.body = null;
				attachments.add(a);
				fileName = null;
			} catch(DMLException e) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment'));
				return null;
			} finally {
				attachment = new Attachment();
			}

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attachment uploaded successfully'));
			return ApexPages.currentPage();
		} else {
			attachment.body = null;
			attachment = new Attachment();
			
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'File size is too large.  Attachment size should be less than 25MB'));
			return ApexPages.currentPage();
		}
    }

	@testVisible
	public PageReference next() {
		if (currentRecordTypeName==RECORDTYPE_ENGINE && !wasAttachmentAdded) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please, add an attachment'));
			return ApexPages.currentPage();
		}
		if (!String.isBlank(warrantyCaseRecord[0].Coverage_Type__C) && warrantyCaseRecord[0].Coverage_Type__C.equals(SERVICE_CONTRACT_CLAIM)) {
			PageReference p = new PageReference('/apex/PreCall_Forms_Finish2?id=' + warrantyCaseId);
			p.setRedirect(true);
			return p;
		} 
		PageReference p = new PageReference('/apex/PreCall_Forms_Finish?id=' + warrantyCaseId);
		p.setRedirect(true);
		return p; 
    }
}