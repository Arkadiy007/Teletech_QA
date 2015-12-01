trigger CommunityPostbackCommentBeforeInsertUpdate on Community_Postback_Comment__c (before insert, before update) {
	List<String> userEmails = new List<String>();
	List<Id> userIds = new List<Id>();
	Map<Id, String> userIdEmailMap = new Map<Id, String>();
	Map<String, String> emailComUserMap = new Map<String, String>();
	List<CaseComment> caseComments = new List<CaseComment>();
	
	for(Community_Postback_Comment__c pComment : trigger.new) {
		userIds.add(UserInfo.getUserId()); // need record modifier's user info later
		CaseComment newCaseComment = new CaseComment();
		newCaseComment.CommentBody = pComment.Postback_Comment__c;
		newCaseComment.IsPublished = true;
		newCaseComment.ParentId = pComment.Case__c;
		
		if(trigger.isInsert && pComment.Visible_In_Self_Service_Portal__c) { // new comment made and need to create case comment
			caseComments.add(newCaseComment);
			}
		else if(trigger.isUpdate && pComment.Visible_In_Self_Service_Portal__c) {
			Community_Postback_Comment__c oldComment = trigger.oldMap.get(pComment.Id);
			if(!oldComment.Visible_In_Self_Service_Portal__c) { // comment edited and new case comment wasn't previously created
				caseComments.add(newCaseComment);
				}
			}
		}
		
	if(!caseComments.isEmpty()) {
		Database.Saveresult[] srs = Database.insert(caseComments, false); // insert case comment records
		
		for(Database.Saveresult sr: srs) {
			if(!sr.isSuccess())
				system.debug('Error creating CaseComment record :' + sr.getErrors()); // off-chance of errors; needs debug logs to be turned on
			}
		}
	
	// mapping SF user to Li user id on email
	// create user id to user email map
	for(User aUser : [SELECT Id, Email
						FROM User
						WHERE Id IN :userIds]) { // load all user's email address
		userEmails.add(aUser.Email);
		userIdEmailMap.put(aUser.Id, aUser.Email);
		}
	
	// create email to community username mapping  
	for(Li_Community_User__c comUser : [SELECT Name, Email_Address__c
											FROM Li_Community_User__c
											WHERE Email_Address__c IN : userEmails]) { //map email addresses to Lithium usernames
		emailComUserMap.put(comUser.Email_Address__c, comUser.Name);
		}
	system.debug(userIdEmailMap);
	system.debug(emailComUserMap);
	LithiumSettings__c liSetting = LithiumSettings__c.getValues('DefaultSetting'); // fetch custom setting to get default Lithium username to postback as
	for(Community_Postback_Comment__c pComment : trigger.new) {
		Id userId = UserInfo.getUserId();
		String userEmail = userIdEmailMap.get(userId);
		String liUsername = emailComUserMap.get(userEmail);
		
		if(liUsername == NULL) {
			liUsername = liSetting.Username__c;
			}
		
		pComment.Salesforce_Agent__c = liUsername; // set the salesforce agent (lithium user) to that who created/edited the comment
		}
	}