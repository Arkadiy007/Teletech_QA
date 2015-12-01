trigger ChatterPulseAdd on FeedItem (after insert) {

    //Create a list to store the update tracker
    List<CP_Chatter_Pulse__c> listChatterPulse = new List<CP_Chatter_Pulse__c>();
    
    for (FeedItem myFeedItem : trigger.new)
    
        {
        //Grab the ParentID and FeedItem type of the object where this Chatter post is being created.
        String parentId = myFeedItem.parentId;
        String postType = 'Feed: ' + myFeedItem.type; //Prefix with "Feed" to keep seperate from Comments
        
        listChatterPulse.add(new CP_Chatter_Pulse__c(Chatter_User__c = myFeedItem.CreatedById ,
        Reporting_Date__c = date.valueOf(myFeedItem.CreatedDate), Update_Type__c = postType, 
        Related_Record__c = parentId));
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