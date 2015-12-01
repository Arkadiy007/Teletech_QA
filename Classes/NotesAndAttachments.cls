public without sharing class NotesAndAttachments {
	public String parentRecordId {get; set;}
	
	public Map<String, String> attacIdsToOwnersNamesMap {get; set;}
	public List<Attachment> attachmentsList {get; set;}
	public Integer[] indexes {get; set;} 
	public Integer currentIndex {get; set;}

	public NotesAndAttachments(ApexPages.StandardController stdController) {
		parentRecordId = stdController.getRecord().id;
		attachmentsList = [SELECT Id, CreatedBy.Name, name, LastModifiedDate FROM Attachment WHERE ParentId =: parentRecordId];
		attacIdsToOwnersNamesMap = new Map<String, String>();
		fillingIndexesAndOwnerNames();
	}

    public Boolean areAttachmentsUpdatable { get {
			List<Profile> currentProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
			return (currentProfile.size() > 0 && (currentProfile[0].Name.equals('EQA') || currentProfile[0].Name.containsIgnoreCase('system'))) ? true : false;
		} 
		set;
	}

	public PageReference delAttacment() {
		Attachment AttacattachmrntForDelete = attachmentsList.get(currentIndex);
		attachmentsList.remove(currentIndex);
		fillingIndexesAndOwnerNames();
		try {
			delete AttacattachmrntForDelete;
		} catch (Exception e) {
			System.debug (e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}

		return null;
	}

	//-------------HELPERS-------------//
	private void fillingIndexesAndOwnerNames() {
		indexes = new List<Integer>();
		
		if (attachmentsList.size() > 0){
			Integer index = 0;
			for (Attachment a : attachmentsList) {
				attacIdsToOwnersNamesMap.put(a.id, a.CreatedBy.Name);
				indexes.add(index);
				index++;
			}
		}
	}

}