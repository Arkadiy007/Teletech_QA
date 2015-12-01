/**********************************************************************
Name: CaseComment_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Set Stage_Status__c value on the Case Comment appropriately
when it is inserted or updated so it will be picked
up by batch processing.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Bryan Fry        11/22/2011 Created
1.1 -  Yuli Fintescu    02/09/2012 Auto-indicate on that Comment that the comment was added after the case was closed.
1.2 -  Bryan Fry        01/10/2013 Use database.update() to process errors individually and improve error reporting
1.3 -  Bryan Fry             05/23/2013 Change logic so only CA Closed Case record type has 30-day after close restriction on comments added
***********************************************************************/
trigger CaseComment_Before on CaseComment (before insert, before update) {
	
	if(Trigger_Switch__c.getInstance(Label.Trigger_CaseCommentBefore) != null && Trigger_Switch__c.getInstance(Label.Trigger_CaseCommentBefore).Disabled__c){
    	return;
    }
	
    final Pattern PREFIX_PATTERN = Pattern.compile('(^\\*\\*\\* \\[(Added|Edited) after the case is closed.\\] \\*\\*\\*)(\\r?\\n)*([\\w\\W\\s]*)');
        final static String caClosedCaseRT = '012F0000000yCuEIAU';
        
    /*
        String description  = '*** [Added after the case is closed.] ***\r\n';
        matcher myMatcher = PREFIX_PATTERN.matcher(description);
        System.debug('*** ' + myMatcher.matches());
        System.debug('*** ' + myMatcher.groupCount());
        System.debug('*** ' + myMatcher.group(1));
        System.debug('*** ' + myMatcher.group(3));
        System.debug('*** ' + myMatcher.group(4));
    */
    List<Id> caseIds = new List<Id>();
    List<Case> cases = new List<Case>();
    List<Case> updateCases = new List<Case>();
    Map<Id, List<CaseComment>> mapCaseToComments = new Map<Id,List<CaseComment>>();
    List<CaseComment> ccs = null;
    Set<CaseComment> ccsWithErrors = new Set<CaseComment>();
    Map<Id, String> ccserrors = new Map<Id, String>();
    
    for (CaseComment cc: Trigger.new) {
        caseIds.add(cc.ParentId);
        ccs = mapCaseToComments.get(cc.ParentId);
        if (ccs == null) {
            ccs = new List<CaseComment>();
            mapCaseToComments.put(cc.ParentId,ccs);
        }
        ccs.add(cc);
    }
    
    

    
    cases = [select Id, Stage_Status__c, Status, IsClosed, ClosedDate, RecordTypeId, RecordType.Name, DRT_Support_Status__c from Case where Id in :caseIds];
    Map<ID, Case> mapCases = new Map<ID, Case>(cases);
    
   for (CaseComment cc: Trigger.new) {
            Case c = mapCases.get(cc.ParentId);
            if (c.RecordType.Name == 'TECH Line Cases') {
                cc.IsPublished = true;
            
            }
    }
    
    
    
    
    if(System.label.TurnOffStageStatus != 'Yes') {
        for (Case c: cases) {   
            if (c.Stage_Status__c != System.Label.Stage_Status_Add && c.Stage_Status__c != System.Label.Stage_Status_Update) {
                c.Stage_Status__c = System.Label.Stage_Status_Update;
                updateCases.add(c);
            }
        }
        if (!updateCases.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(updateCases, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < updateCases.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to the associated CaseComment.
                        Database.Error err = dbResults[row].getErrors()[0];
                        ccs = mapCaseToComments.get(updateCases[row].Id);
                        ccsWithErrors.addAll(ccs);
                        for(CaseComment errors : ccs){
                        ccserrors.put(errors.Id, err.getmessage());
                        }
                        
                    }
                }
            }
            // Add errors to CaseComments
            /*for (CaseComment ccWithError: ccsWithErrors) {
                ccWithError.addError('You can not add a Case Comment after the Case has been closed for 90 days.Click Cancel to return to the Case.');
            }*/
            
            for (CaseComment ccWithError: ccsWithErrors) {
                String errmsg = ccserrors.get(ccWithError.Id);
                ccWithError.addError(errmsg+'<br/>Click Cancel to return to the Case.');
            }
        }
    }
    
    if (system.label.TurnOffValidation != 'Yes') {
        for (CaseComment cc: Trigger.new) {
            Case c = mapCases.get(cc.ParentId);
            
            //if case is not closed, skip
            if (c.IsClosed != true) 
                continue;
            
            if (Trigger.isInsert && c.RecordTypeId == caClosedCaseRT){
                if(c.DRT_Support_Status__c == 'DRT Assigned'){
                    if(c.ClosedDate.Date().daysBetween(System.Today()) > 90 ){
                         cc.addError('You can not add a Case Comment after the Case has been closed for 90 days.Click Cancel to return to the Case.');                      
                    }
                }else{
                    if(c.ClosedDate.Date().daysBetween(System.Today()) > 30){ 
                        cc.addError('You can not add a Case Comment after the Case has been closed for 30 days.Click Cancel to return to the Case.');
                    }
                }
                 
            }    
                 
            String oldComment = '';
            String newComment = cc.CommentBody;
            if (Trigger.isUpdate)
                oldComment = Trigger.oldMap.get(cc.Id).CommentBody;
            //commentbody is not modified, skip
            if (oldComment.equals(newComment)) 
                continue;
            
            //if CommentBody already has the prefix, skip without changing anything
            matcher myMatcher = PREFIX_PATTERN.matcher(newComment);
            if (myMatcher.matches())
                continue;
            
            String indicator = '*** [' + (Trigger.isInsert ? 'Added' : 'Edited') + ' after the case is closed.] ***\r\n';
            //user got rid of the prefix, readd it
            myMatcher = PREFIX_PATTERN.matcher(oldComment);
            if (myMatcher.matches() && myMatcher.groupCount() == 4)
                indicator = myMatcher.group(1) + myMatcher.group(3);
            
            //add prefix to the comment body
            String newCommentPart = indicator + newComment;
            cc.CommentBody = newCommentPart;
        }
    }
}