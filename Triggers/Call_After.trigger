/**********************************************************************
Name: Call_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: When a Call status is set to complete, add a 
Case Comment to the related Case with details.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry     05/08/2013 Created
1.1 - Bryan Fry     10/10/2013 Created
1.2 - Vladimir Martynenko 19/08/2015 Added logic for Maritz Backfeed Stage Object Creation
***********************************************************************/
trigger Call_After on Call__c (after insert, after update) {
    List<CaseComment> comments = new List<CaseComment>();
    CaseComment comment = null;
    Call__c call = null;
    Call__c oldCall = null;
    
    //1.2 Vladimir Martynenko: Maritz Backfeet Stage Object Creation:
    if(Trigger.isInsert){
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForCall__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(Trigger.NEW);
            }
        }
    }
    
    // Loop through all rows
    for (Integer count = 0; count < Trigger.new.size(); count++) {
        // Set the new call object, and set the old call object if this
        // is an update.
        call = Trigger.new[count];
        if (Trigger.isUpdate) {
            oldCall = Trigger.old[count];
        } else {
            oldCall = null;
        }
        
        // If the call is inserted as Complete or updated to 'Complete'
        // from a different value, create a CaseComment.
        if ((Trigger.isInsert && call.Status__c == 'Complete') ||
            (Trigger.isUpdate && oldCall.Status__c != 'Complete' && call.Status__c == 'Complete')) {
            comment = new CaseComment();
            comment.ParentId = call.Case__c;
            comment.CommentBody = 'Call #: ' + call.Name + '\r\n' + 
                                  'Call Type: ' + call.Call_Type__c + '\r\n' + 
                                  'Assigned To: ' + call.AssignedToName__c + '\r\n' +
                                  'Notes: ' + call.Notes__c;
            comments.add(comment);
        }
    }

    insert comments;
}