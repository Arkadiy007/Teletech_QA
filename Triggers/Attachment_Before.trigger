/**********************************************************************
Name: Attachment_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Attachments cannot be added to a closed case.
Attachments cannot be deleted other than by admins.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Yuli Fintescu	02/09/2012 Created
1.1 - 
***********************************************************************/
trigger Attachment_Before on Attachment (before insert, before delete) {
    if (Trigger.isInsert) {
		// ********** Attachments cannot be added to a closed case
		// This blocking is dependent on the Custom Label Block_CA_Closed_Case_Attachments.
		// If that value is 'No', do not block attachemnts. Otherwise, block them.
		if (System.Label.Block_CA_Closed_Case_Attachments != 'No') {
		    Set<ID> caseIds = new Set<ID>();
			for (Attachment t: Trigger.new) {
				caseIds.add(t.ParentId);
			}
	
			List<Case> cases = [select Id, IsClosed from Case where Id in :caseIds and RecordType.Name in ('CA', 'CA Closed Case', 'CA Email Infiniti', 'CA Email Nissan', 'CA EXEC', 'Roadside Assistance', 'T5', 'TECH LINE') and IsClosed = true];
			Map<ID, Case> mapCases = new Map<ID, Case>(cases);
			for (Attachment t: Trigger.new) {
				if (mapCases.containsKey(t.ParentId))
					t.addError('Attachments cannot be added to a closed case.');
			}
		}
    } else if (Trigger.isDelete) {
    	// ********** Only admins can delete Attachments
    	Id userId = UserInfo.getUserId();
    	User u = [select id, profile.name, profile.userlicense.name from User where Id = :userId];
    	if (u.Profile.Name != 'System Administrator' && 
    	    u.Profile.Name != 'System Admin Config' &&
    	    u.Profile.Name != 'Managed Services' &&
			u.Profile.Name != 'EQAInternalPortal User' &&
			u.Profile.Name != 'EQA' &&
    	    u.Profile.Name != 'CA Admin')
    	{
	    	for (Attachment a: Trigger.old) {
	    		a.addError('Attachments can only be deleted by administrator users.');
	    	}
    	}
    }
}