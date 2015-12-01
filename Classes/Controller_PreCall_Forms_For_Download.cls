public with sharing class Controller_PreCall_Forms_For_Download {
  
	public Id warrantyCaseId { get; set; }
    public List<Attachment> attachments { get; set; }
	public List<Warranty_Case__c> warrantyCase { get; set; }
	//public Integer fileSize {get; set;}

    public Controller_PreCall_Forms_For_Download() {
        warrantyCaseId = apexpages.currentpage().getparameters().get('id');
        if (warrantyCaseId != null && !String.isEmpty(String.valueOf(warrantyCaseId))) {
            warrantyCase = Database.query('SELECT Id, Dealer_Code__c, Name FROM Warranty_Case__c WHERE Id =: warrantyCaseId');
        }
    }

    public Attachment attachment {
        get {
            if (attachment == null)
            attachment = new Attachment();
            return attachment;
        }
        set;
    }

    public PageReference upload() {
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = warrantyCaseId; // the record the file is attached to
        attachment.IsPrivate = false;
		
        try {
            insert attachment;
            attachment.body = null;
            attachments.add(attachment);
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment'));
            return null;
        } finally {
            attachment = new Attachment();
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attachment uploaded successfully'));
        return null;
    }

	public Id getCaseId(){
		return warrantyCaseId;
	}
    public PageReference finish() {
        return new PageReference('javascript: self.close();');
    }

}