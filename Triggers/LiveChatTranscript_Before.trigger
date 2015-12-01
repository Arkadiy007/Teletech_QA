trigger LiveChatTranscript_Before on LiveChatTranscript (before insert) {
   for (LiveChatTranscript chat : Trigger.new) {
        
        // Make the relation against Survey
        List<Surveys__c> surveyList = [SELECT Id, CreatedDate,
            Live_Agent_Chat_Session_Start_Time__c
            FROM Surveys__c
            WHERE RecordType.Name = 'Live Agent'
            AND Live_Chat_Transcript__c = null
            AND Live_Agent_Visitor_IP__c = :chat.IpAddress
            ORDER BY CreatedDate DESC
            LIMIT 1];
        
        if (surveyList.size() > 0) {
            Decimal MinDiff;
            
            Long chatStartTime;
            if (chat.StartTime != null) {
                chatStartTime = chat.StartTime.getTime();   
            }
            else {
                if (chat.RequestTime != null) {
                    chatStartTime = chat.RequestTime.getTime(); 
                }
            }
            
            if (chatStartTime != null) {
                if (surveyList[0].Live_Agent_Chat_Session_Start_Time__c == null) {
                    minDiff = (surveyList[0].CreatedDate.getTime() - chatStartTime) / 60000;
                    
                    //If the Start Time is empty we define a limit of 30 mins
                    if (minDiff >= -30 && minDiff <= 30) {
                        chat.Survey__c = surveyList[0].Id;
                    }
                }
                else {
                    minDiff = (surveyList[0].Live_Agent_Chat_Session_Start_Time__c.getTime() - chatStartTime) / 60000;
                    
                    //In some cases the start time has presented a difference of some minutes
                    if (minDiff >= -15 && minDiff <= 15) {
                        chat.Survey__c = surveyList[0].Id;
                    }   
                }   
            }
        }
        
        //Make the relation with the Pre_Chat_Data object
        List<Pre_Chat_Data__c> relatedPreChat;
        
        if (chat.Pre_Chat_Data__c != null) {
            relatedPreChat = [SELECT Id, AccountId__c, Disposition_Code__c
                FROM Pre_Chat_Data__c
                WHERE Id = :chat.Pre_Chat_Data__c];
        }
        else {
            relatedPreChat = [SELECT Id, AccountId__c, Disposition_Code__c
                FROM Pre_Chat_Data__c
                WHERE Session_Id__c = :chat.Session_Id__c];
        }
        
        if (relatedPreChat.size() > 0) {
            chat.Pre_Chat_Data__c = relatedPreChat[0].Id;
            chat.Disposition_Code__c = relatedPreChat[0].Disposition_Code__c;
            
            if (relatedPreChat[0].AccountId__c != null) {
                chat.AccountId = relatedPreChat[0].AccountId__c;    
            }
        }
    } 
}