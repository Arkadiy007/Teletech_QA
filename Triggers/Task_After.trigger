/**********************************************************************
Name: Task_After
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Update CallDisposition field of case with Call Result field of Task. 
Related Class : TaskClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/10/2011 Created
1.1 - Biswa Ray           01/12/2011 New Notes Creation Functionality added
1.2 - Mohd Afraz Siddiqui 01/13/2011 Incorporated Comments and Headers
1.3 - Munawar Esmail      09/06/2011 Commented out New Notes Creation Functionality
1.4 - Matt Starr          03/06/2014 Add code to fix due dates for VCS tasks that are < the createdDate
1.5 - Vivek Batham        12/18/2014 Added logic for sending private Chatter messages
1.6 - Vladimir Martynenko 22/06/2015 Maritz Backfeet Stage Object creation via Maritz_Backfeed_TaskTriggerHelper.cls
1.7 - Anna Koseikina      07/15/2015 Added changes for DTS Reassignemnt task implementation
 ***********************************************************************/
trigger Task_After on Task (after insert, after update) {
    Set<Case> toUpdateCaseSet = new Set<Case>();
    List<Case> toUpdateCaseList = new List<Case>();
    List<task> tasksToUpdate = new List<Task>();
    Case caseRec = null;
    Account acc;
    Case cas;
    List<Task> tasks4update = new List<Task>();
    
    // Added for Chatter posts
    List<String> RecordTypeNames = new List<String>();
    Set<String> RecordTypeIds = new Set<String>();
    Map<String, String> taskCaseMap = new Map<String, String>();
    Map<String, Task> taskRecMap = new map<String, Task>();
    Map<Id, Case> caseMap = new Map<Id, Case>();
    Set<String> taskCompletionRTIds = new Set<String>();
	Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Task.getRecordTypeInfosByName();
	
	if(Label.Task_Completion_Record_Type != null){
		String[] taskRTypes = Label.Task_Completion_Record_Type.split(';');
		for(String s : taskRTypes){
			if(rtInfosByName.get(s) != null){
			taskCompletionRTIds.add(rtInfosByName.get(s).getRecordTypeId());
			}
		}
	}
	
    //Record Type for sending email to Completed tasks
   // Id taskCompletionRecordTypeId  = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, Label.Task_Completion_Record_Type);    
    List<Task> tasksToSendEmails = new List<Task>();

    // Custom settings maintains the Case record types for which Chatter posts need to occur
    Chatter_Settings__c chatterRec = Chatter_Settings__c.getOrgDefaults();

    // This part needs to be reevaluated once QA is refreshed
    // Added for an existing Known issue
    if(Test.IsRunningTest()){
        if(chatterRec == null){

            chatterRec = new Chatter_Settings__c(Chatter_record_Types_1__c  = 'TECH LINE,', Name = 'OrgWide');
            insert chatterRec;
        }

    }

    // Method to collect the record type Ids from Custom setting
    if(chatterRec.Chatter_Record_Types_1__c != null && (chatterRec.Chatter_Record_Types_1__c.contains(','))){
        RecordTypeNames = chatterRec.Chatter_Record_Types_1__c.split(','); 
        for(String s: RecordTypeNames){
            Id recordTypeId  = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, s);
            RecordTypeIds.add(recordTypeId);
        }
    }
    //1.6 Vladimir Martynenko: Maritz Backfeet Stage Object Creation;
    if(Trigger.isInsert){
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForTask__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(Trigger.NEW);
            }
        }
    }

    /*
        For all tasks update cases if its CallDisposition is changed. 
     */
    for(Integer i = 0; i < Trigger.new.size(); i++) {       
        caseRec = TaskClass.updateCase(Trigger.new[i]);
        if (caseRec != null) {
			if(Trigger.isUpdate){
				Task old = Trigger.oldMap.get(Trigger.new[i].ID);
				if(old.OwnerId != Trigger.new[i].OwnerId && Trigger.new[i].Subject != null && Trigger.new[i].Subject.contains('DTS Request') && (Trigger.new[i].Status != 'Complete' || Trigger.new[i].Status != 'Completed')){
					caseRec.Task_Field_Inspection_Owner__c = Trigger.new[i].OwnerId;
                
					tasksToUpdate.add(Trigger.new[i]);
					
		            toUpdateCaseSet.add(caseRec);
				}
			}
			
        }

        String taskParentId = Trigger.new[i].WhatId;

        if(RecordTypeIds != null && RecordTypeIds.size() > 0 && RecordTypeIds.contains(Trigger.new[i].RecordTypeId) && taskParentId != null && taskParentId.startswith(Schema.sObjectType.Case.getKeyPrefix()) 
                && Trigger.new[i].OwnerId != UserInfo.getUserId()){

            taskCaseMap.put(Trigger.new[i].Id, taskParentId);        

        }
        
        if(Trigger.new.size() == 1){
            Task t = Trigger.new[i];
            if(Trigger.isUpdate && taskCompletionRTIds.size() > 0 && taskCompletionRTIds.contains(t.RecordtypeId) && t.Status == 'Complete' && t.Status != Trigger.OldMap.get(t.Id).Status){
                tasksToSendEmails.add(t); 
            }
            System.debug('tasksToSendEmails::'+tasksToSendEmails);
        }
    }


    // Added for Chatter post with mention
    if(taskCaseMap.size() > 0){
        for(Case casObj : [Select Id, CaseNumber, Account.Name, VIN__c, Dealer_Name__c, DealerCode__c, DTS_Notes__c, DTS_Field_Inspection__c, Caller_Name__c, Vehicle_Name__r.Make_Model__c,
                           RecordType.Name, Servicing_Dealer__r.Name, Dealer__r.Name, Servicing_Dealer__r.Dealer_Code__c, Dealer__r.Dealer_Code__c , Customer_Name__c
                           from Case where Id IN : taskCaseMap.values()])    {

            caseMap.put(casObj.Id, casObj);

        }
        
        taskRecMap = new Map<String, Task>([Select Id, OwnerId, Owner.Name, Owner.Profile.Name, WhatId, Subject, Description from Task where Id IN : taskCaseMap.keyset()]);
    }

    /*
        Update all the cases.
     */
    try {
        if(toUpdateCaseSet.size() > 0) {
            toUpdateCaseList.addAll(toUpdateCaseSet);
            update toUpdateCaseList;
        } 
        
        
        if(tasksToSendEmails.size() > 0){
        TaskClass.sendCompletedActivityEmail(tasksToSendEmails);
        }
    }
    catch (DMLException e){
        for(Case c : toUpdateCaseList) {
            c.addError(system.label.Exception_occured_while_inserting_Task + e.getMessage());   
        }
    }

    /* 
         Creation of New Notes Functionality.

    Note note;
    List<Note> noteList = new List<Note>();

        Iterate over the list of records being processed in the trigger and
        insert notes respectively       
          for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (Trigger.isUpdate) {
                note = TaskClass.createNote(Trigger.old[i], Trigger.new[i]);
            }
            else if (Trigger.isInsert){
                note = TaskClass.createNote(null, Trigger.new[i]);
            }
            if (note!= null){           
               noteList.add(note); 
            }
        }




    try {
         if (noteList.size() > 0) {
          insert noteList;
        }
    }
    catch (DMLException e) {
        for (Note noteRec : noteList) {
            noteRec.addError(system.label.Exception_occured_while_inserting_new_notes + e.getMessage());
        }
    }
     */

    /***1.4 Modify the due date for VCS tasks that have a due date prior to the 
    created date due to time zones.***/

    for(Task t : trigger.new){

        //make chatter posts if eligible for DTS agents 
        if((Trigger.isInsert && taskRecMap != null && taskRecMap.containskey(t.Id)) ||
        	 (Trigger.isUpdate && tasksToUpdate != null && tasksToUpdate.size() > 0)){ 
        TaskClass.createChatterMention(taskRecMap.get(t.Id), taskCaseMap, caseMap);
        } 

        if(Trigger.isInsert == true && t.createdDate > t.ActivityDate 
                && t.IsRecurrence == false && t.RecordtypeId == '012F0000000yFlr'){

            Task t2 = New Task(Id = t.Id);
            Datetime duedate = t.createdDate.addDays(1);

            if (duedate.format('EEEE') != 'Saturday' && 
                    duedate.format('EEEE') != 'Sunday') {

                t2.ActivityDate = date.valueOf(t.createdDate.addDays(1));
                tasks4update.add(t2);
            }
            if (duedate.format('EEEE') == 'Saturday'){
                t2.ActivityDate = date.valueOf(t.createdDate.addDays(3));
                tasks4update.add(t2); 

            } 

            if (duedate.format('EEEE') == 'Sunday'){
                t2.ActivityDate = date.valueOf(t.createdDate.addDays(2));
                tasks4update.add(t2); 

            }
        } 
    }
    
      
    if(tasks4update.size() > 0){    
    try{
        update tasks4update;
        
    }
    catch (Exception e) {
        Error_Log__c error = new Error_Log__c(Error_Message__c = e.getMessage(), 
                TimeStamp__c = System.now(), 
                Operation_Name__c = 'After_Task_DueDateFix', 
                Source__c='Salesforce', 
                Log_Type__c = 'Error');
    }

    }
    if(tasksToUpdate.size() > 0){
    try{
        Database.update(tasksToUpdate);
    }
    catch (Exception e){
        Error_Log__c error = new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'After_Task_SendNotification', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error');
                                    
    }
    }

}