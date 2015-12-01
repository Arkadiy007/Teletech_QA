public with sharing class Controller_PreCall_Forms_Finish {
    private Id warrantyCaseId { get; set; }
	public String warCaseRecordName { get; set; }
	  
    public List<Attachment> attachments { get; set; }
	private PageReference pagePDF;
	private String pdfName;
	private List<Warranty_Case__c> warrantyCaseRecord;
	public Attachment pdf { get; set; }
	private String currentRecordTypeName;

	//CONSTANTS
	private static String RECORDTYPE_ENGINE = 'Engine VCAN';
	private static String RECORDTYPE_CVT = 'Trans VCAN';
	private static String RECORDTYPE_LEAF = 'Leaf Precall';
	private final static String EMAIL_TEMPLATE_NAME = 'PreCall Form Email';

	private Boolean wasPDFCreated;
    public Controller_PreCall_Forms_Finish() {
        warrantyCaseId = apexpages.currentpage().getparameters().get('id');
        if (warrantyCaseId != null && !String.isEmpty(String.valueOf(warrantyCaseId))) {
			warrantyCaseRecord = Database.query('SELECT Id, Name, Dealer_Code__c, RecordTypeId, Send_a_copy_of_this_form_to__c, Customer_Name__c, Vehicle__r.Vehicle_identification_Number__c FROM Warranty_Case__c WHERE Id =: warrantyCaseId');
			warCaseRecordName = warrantyCaseRecord[0].Name;

			wasPDFCreated = getWasPDFCreated();

			String recTypeId = warrantyCaseRecord[0].RecordTypeId;

			Map<Id,Schema.RecordTypeInfo> recordTypeInfo = Warranty_Case__c.SObjectType.getDescribe().getRecordTypeInfosById();
			currentRecordTypeName = recordTypeInfo.get(recTypeId).getName();
        }
    }

    public PageReference finish() {
		wasPDFCreated = getWasPDFCreated();
		createPDF();
        return new PageReference('javascript: self.close();');
    }

	public PageReference new_PreCall_Form() {
		wasPDFCreated = getWasPDFCreated();
		createPDF();
		PageReference p = new PageReference('/apex/PreCall_Forms');
		p.setRedirect(true);
		return p;
	}

	public PageReference redirectToPDF() {
		wasPDFCreated = getWasPDFCreated();
		createPDF();
		return pagePDF;
    }

	@testVisible 
	public void createPDF() {
		if(pagePDF == null) {
			//determination of what VF page template should be used
			if (currentRecordTypeName == RECORDTYPE_ENGINE) {
				pagePDF = Page.PreCall_Forms_PDF_Engine;
			} else if (currentRecordTypeName == RECORDTYPE_CVT) {
				 pagePDF = Page.PreCall_Forms_PDF_CVT;
			} else {
				 pagePDF = Page.PreCall_Forms_PDF_LEAF;
			}

			//generation and attaching PDF
			pagePDF.getParameters().put('id', warrantyCaseId);
			if (!wasPDFCreated) {
				Blob pdfBlob;

				// trick for unit tests 
				if (Test.IsRunningTest()) {
					pdfBlob = Blob.valueOf('UNIT.TEST');
				} else {
	 				pdfBlob = pagePDF.getContent(); 
				}

				pdf = new Attachment(parentId = warrantyCaseId, name = pdfName, body = pdfBlob); 
				insert pdf;

				if (null != warrantyCaseRecord[0].Send_a_copy_of_this_form_to__c && !String.isBlank(String.valueOf(warrantyCaseRecord[0].Send_a_copy_of_this_form_to__c))) {
					try {
							// Create the email attachment
							Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
							emailAttachment.setFileName(pdfName);
							emailAttachment.setBody(pdfBlob);

							// Create the email
							Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
							email.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
							email.setToAddresses(new String[] {String.valueOf(warrantyCaseRecord[0].Send_a_copy_of_this_form_to__c)});
							Integer vinLength = warrantyCaseRecord[0].Vehicle__r.Vehicle_identification_Number__c.length();
							String lastSixChar = warrantyCaseRecord[0].Vehicle__r.Vehicle_identification_Number__c.substring(vinLength - 6); 
							email.setSenderDisplayName('Nissan and Infiniti Support ');
							email.setSubject('PCC Pre-Call Form ' + lastSixChar);
							String textBody = '<p style="font-style: italic;"> Disclaimer: Please do not reply to this message. Replies to this message are not monitored. </p>';

							email.setHtmlBody(textBody);

							Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
					} catch(Exception e) {
						System.debug(e.getMessage());
					}
				}
				wasPDFCreated = true;
			}
		}
	}

	//HELP METHODS--------------------------
	private String getDate() {
		DateTime now = DateTime.NOW();
		String month = checkLength(String.valueOf(now.month()));
		String day = checkLength(String.valueOf(now.day()));
		String year = checkLength(String.valueOf(now.year()));

		return month + day + year.substring(2);
	}

	private String checkLength(String val) {
		if (String.isNotBlank(val) && val.length()==1) {
			val = '0' + val;
		}
		return val;
	}

	private String getPDFName () {
		return 'Pre-call_Type_' + warrantyCaseRecord[0].Name+ '_' + warrantyCaseRecord[0].Dealer_Code__c + '_' + getDate() + '.pdf';
	}

	private Boolean getWasPDFCreated() {
		attachments = Database.query('SELECT Id, BodyLength, ContentType, Description, Name, IsPrivate FROM Attachment WHERE ParentId =: warrantyCaseId');
		Boolean result = false;
		pdfName = getPDFName();
		for (Attachment a : attachments) {
			if (a.Name.equalsIgnoreCase(pdfName)) {
				result = true;
			}
		}
		return result;
	}
}