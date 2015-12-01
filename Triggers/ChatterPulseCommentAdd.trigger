trigger ChatterPulseCommentAdd on FeedComment (after insert) {

    //Create a list to store the update tracker
    List<CP_Chatter_Pulse__c> listChatterPulse = new List<CP_Chatter_Pulse__c>();
    
    for (FeedComment myFeedComment : trigger.new)
    
        {
        //Grab the ParentID and FeedComment type of the object where this Chatter post is being created.
        String parentId = myFeedComment.parentId;
        String postType = 'Comment: ' + myFeedComment.CommentType; //Prefix with "Comment" to keep seperate from Comments

        //Insert the counter, Note: FeedItem insert triggers don't run for changes to the user status.
        //Need to add a user object update trigger and detect a change to the CurrentStatus field.
        
        listChatterPulse.add(new CP_Chatter_Pulse__c(Chatter_User__c = myFeedComment.CreatedById ,
        Reporting_Date__c = date.valueOf(myFeedComment.CreatedDate), Update_Type__c = postType, Related_Record__c = parentId ));
        }
        
    if(listChatterPulse.size() > 0)
    {
        try {
            insert listChatterPulse;
        }
        catch (exception e) {
            //Likely that the user does not have access to create records
        }            
    }

}