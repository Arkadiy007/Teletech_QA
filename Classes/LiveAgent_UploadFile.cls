/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller of the page with the same name for uploading files as Attachments
associated to an Account

Class:              LiveAgent_UploadFile
Author:				Rohdenburg S.
Date:               05/27/2013
Version:            1.0
Last Updated:       07/05/2013
    * 05/27/2013	SR - Implemented
    * 07/05/2013	SR - Cleaned up according to the Code Review
*/

public class LiveAgent_UploadFile
{
	// -------- Constants --------
	private final String PARAMETER_ACCOUNT_ID = 'AccountId';
	
	// -------- Constructor --------
    public LiveAgent_UploadFile() {
    	if (Apexpages.CurrentPage().getParameters().containsKey(
    	PARAMETER_ACCOUNT_ID)) {
    		accountId = Apexpages.CurrentPage().getParameters().get(
    			PARAMETER_ACCOUNT_ID);
    		showUploadControl = true;
    		showInvalidURL = false;
    	}
    	else {
    		showUploadControl = false;
    		showInvalidURL = true;
    	}
    	
    	showThanksMessage = false;	
    }

    // -------- Variables --------
	private String fileName;
	private Integer fileSize;
	private Blob fileBody;
	
	// -------- Properties --------
	public Boolean showUploadControl {get;set;}
	public Boolean showInvalidURL {get;set;}
	public Boolean showThanksMessage {get;set;}
	public String accountId {get;set;}
	
	public String getFileName() {
		return this.fileName;
	}
	
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	
	public Blob getFileBody() {
		return this.fileBody;
	}
	
	public void setFileBody(Blob fileBody) {
		this.fileBody = fileBody;
		setFileSize(this.fileBody.size());
	}

	public Integer getFileSize() {
		return this.fileSize;
	}

	public void setFileSize(Integer fileSize) {
		this.fileSize = fileSize;
	}
	
	// -------- Methods --------
	// It inserts the uploaded file as an Account Attachment object
	public void processUpload() {
		Attachment attachment = new Attachment();
		attachment.Body = this.fileBody;
		attachment.Name = this.fileName;
		attachment.ParentId = accountId;
		Database.insert(attachment);
		
		fileBody = Blob.valueOf('  ');
		showUploadControl = false;
		showThanksMessage = true;
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		// Inserting the needed objects
    	Account acc = new Account();
    	acc.Name = 'TeleTech';
    	insert acc;
    	
    	// Load the page with a URL that doesn't contain the AccountId 
		LiveAgent_UploadFile invalidUpload = new LiveAgent_UploadFile();
		
		// Load the page with a URL that doesn't contain the AccountId
		ApexPages.currentPage().getParameters().put('AccountId',acc.Id);
		LiveAgent_UploadFile upload = new LiveAgent_UploadFile();
		
		// Upload a File
		upload.setFileName('fileName');
		upload.setFileBody(Blob.valueOf('  '));
		upload.accountId = acc.Id; 
		upload.processUpload();
		
		// Properties gets
		upload.getFileName();
		upload.getFileBody();
		upload.getFileSize();
	}
}