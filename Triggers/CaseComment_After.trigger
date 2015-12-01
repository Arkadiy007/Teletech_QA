/**********************************************************************
Name: CaseComment_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Upon EVERY Case Comment saved/submitted by Dealer/Portal User, 
Create a TASK assigned to CASE OWNER with Due Date of 
24 hours in future with Subject of "Review Dealer Comment".

Upon EVERY PUBLIC Case Comment created by a non-Portal User
(NOT including PRIVATE Comments), send an Email Notification
to the Dealer user(s) that were selected when CA shared the Case 
with the Dealer initially. 
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Bryan Fry        06/21/2011 Created
                                   When dealer portal users post comments, create task for case owner to reply
                                   When comments are added to cases, send emails to associated dealer portal users.
1.1 -  Bryan Fry        12/19/2012 Removed code to send emails to dealer portal users.
1.2 -  Bryan Fry        09/23/2013 Don't create Tasks for comments on Enrollment Alert cases.
***********************************************************************/
trigger CaseComment_After on CaseComment (after insert) {
    public static final String TASK_SUBJECT = 'Review Dealer Comment';
    String url = null; 

    if (System.Label.TurnOffDealerPortal != 'Yes') {
        List<Id> caseCommentIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Task> insertTasks = new List<Task>();
        Set<Date> holidayDates = null;
    
        DateTime targetDate = System.now();
        holidayDates = HolidayCalculator.AllHolidaysOfLastCurrentAndNextYearOfDay(targetDate.date());
    
        for (CaseComment cc: Trigger.new) {
            caseCommentIds.add(cc.Id);
            caseIds.add(cc.ParentId);
        }
        
        // Get comments with Case Owner that were created by dealer portal users.
        List<CaseComment> dealerComments = [select Id, Parent.OwnerId
                                            from CaseComment 
                                            where createdby.profile.userlicense.name = 'Gold Partner' 
                                            and createdby.profile.name in ('Dealer Sales or Service Manager', 'Dealer Parts Manager') 
                                            and Id in :caseCommentIds
                                            and Parent.RecordTypeId != :System.Label.VCS_ALERT_RecordType];
    
        // Create new Tasks for Comments made by dealer portal users
        for (CaseComment dealerComment : dealerComments) {
            Task t = new Task();
            t.OwnerId = dealerComment.Parent.OwnerId;
            t.Subject = TASK_SUBJECT;
            
            targetDate = System.now();
            targetDate = targetDate.addDays(1);
            while (HolidayCalculator.isDayOff(targetDate, holidayDates))
                targetDate = targetDate.addDays(1);
            
            t.ActivityDate = targetDate.date();
            t.whatId = dealerComment.ParentId;
            
            insertTasks.add(t);
        }
        
        // Insert the Tasks
        if (insertTasks != null)
            insert insertTasks;
    }
    
    if (Trigger.new.size() == 1) {
        CaseComment cc = Trigger.new[0];
        Case parentCase = [SELECT RecordType.Name, Stage_Status__c  
            FROM Case
            WHERE Id = :cc.ParentId];           
        
     try{
        if (parentCase.RecordType.Name == 'TECH LINE Cases' && parentCase.Stage_Status__c != 'Update Processing') {
            parentCase.Stage_Status__c = 'Update Processing';
            update parentCase;
        }
     }
     Catch(Exception e){
         cc.addError(e.getmessage()+'<br/>Click Cancel to return to the Case.');
     }
        
    }
}