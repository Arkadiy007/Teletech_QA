trigger LiveChatTranscript_After on LiveChatTranscript (after insert, after update) {
    private final Integer COMMENT_CHARS_LIMIT = 4000;


    //Vladimir Martynenko: Maritz Backfeet Stage Object Creation:
    if(Trigger.isInsert){
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForChat__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(Trigger.NEW);
            }
        }
    }

    if(Trigger.isInsert){
    for (LiveChatTranscript chat : Trigger.new) {
    
        // Make the relation against Survey
        if (chat.Survey__c != null) {
            List<Surveys__c> surveyList = [SELECT Id, 
                Live_Chat_Transcript__c, Customer__c
                FROM Surveys__c
                WHERE Id = :chat.Survey__c];
        
            if (surveyList.size() > 0) {
                surveyList[0].Live_Chat_Transcript__c = chat.Id;
                surveyList[0].Customer__c = chat.AccountId;
                update surveyList[0];
            }
        }
        
        
        //Make the relation against the Pre-Chat Object
        if (chat.Pre_Chat_Data__c != null) {
            List<Pre_Chat_Data__c> relatedPreChat = 
                [SELECT Live_Chat_Transcript__c 
                FROM Pre_Chat_Data__c
                WHERE Id = :chat.Pre_Chat_Data__c];
                
            if (relatedPreChat.size() > 0) {
                if (relatedPreChat[0].Live_Chat_Transcript__c == null) {
                    relatedPreChat[0].Live_Chat_Transcript__c = chat.Id;
                    update relatedPreChat[0];   
                }
            }
        }
        
        //Copy the transcript to the related case as case comments
        if (chat.CaseId != null && chat.Body != null) {
            
            List<Case> associatedCase = [SELECT IsClosed, ClosedDate
                FROM Case
                WHERE Id = :chat.CaseId];
            
            if (associatedCase.size() > 0) {
                if (associatedCase[0].IsClosed && associatedCase[0].ClosedDate.Date().daysBetween(System.Today()) > 30) {
                    // Closed Case older than 30 days
                    // TODO: Define action
                }
                else {
                    String transcriptText;
                    transcriptText = chat.Body.replaceAll('<br>','\n\b');
                    transcriptText = transcriptText.replaceAll('<[^>]+>',' ');
                    
                    List<String> caseCommentCollection = Text_Util.splitStringExtended(
                        transcriptText, COMMENT_CHARS_LIMIT);
                        
                    if (caseCommentCollection.size() > 0) {
                        String transcriptFirstLine = caseCommentCollection[0].substring(
                            caseCommentCollection[0].indexOf('Chat Started:'),
                            caseCommentCollection[0].indexOf('(') - 1);
                                            
                        String query = '';
                        query += 'SELECT Id ';
                        query += 'FROM CaseComment ';
                        query += 'WHERE ParentId = \'' + chat.CaseId +'\' ';
                        query += 'AND CommentBody LIKE \'' + transcriptFirstLine + '%\'';
                            
                        List<CaseComment> alreadyExistComment = Database.query(query);
                        
                        if (alreadyExistComment.size() == 0) {
                            for (String commentBlock : caseCommentCollection) {
                                CaseComment comment = new CaseComment();
                                comment.ParentId = chat.CaseId; 
                                comment.IsPublished = true;
                                comment.CommentBody = commentBlock;
                                insert comment;
                            }               
                        }
                    }
                }
            }
        }
    }
	}

}