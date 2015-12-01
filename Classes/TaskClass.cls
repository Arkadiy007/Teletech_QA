/**********************************************************************
Name: TaskClass 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Updating CallDisposition field of case with Call Result field of Task. 
Related Trigger: Task_After
Related Trigger: Task_Before
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 1/11/2011 Created
1.1 - Biswa Ray           1/12/2011 Updated Code to insert Notes depending upon Task's 
                                    description field change.
1.2 - Mohd Afraz Siddiqui 1/13/2011 As per issue RONETELETECH-89 added 
                                    code to populate fields on Task to 
                                    support Call Resolution service.
1.3 - Biswa Ray           1/17/2011 As per issue RONETELETECH-72 task's Custom 
                                    "Disposition" field value will be copied 
                                    to it's corresponding case's disposition field.
1.4 - Mohd Afraz Siddiqui 1/17/2011 As per Jira issue RONETELETECH-98 removed
                                    hard coded Ids of Case.
1.5 - Bryan Fry           1/21/2011 Updated code for updating fields per updated
                                    CallResolution mapping.
1.6 - S. Rohdenburg		  5/16/2012 Updated code for filling the 
									CampaignName field in the Task object.
1.7 - S. Rohdenburg		  6/13/2012 Get the call_centre_id checking the 
									Campaign name    
1.8 - Vivek Batham		  1/15/2015 Added utility method for Chatter post to DTS 
									Agents for DTS Requests                               
                                
***********************************************************************/

public class TaskClass {

	public static List <Schema.sObjectType> references = Schema.sObjectType.Note.fields.ParentId.getReferenceTo();        
    public static Note objNote;
    
    // -------- Constants --------
	private static final string NCI_TEXT = 'NCI';
    
    /*
        Check is this task is created for Case then update Disposition__c
        and return the Case.
    */ 
    public static Case updateCase(Task newTask){
        Case caseRec;
        String caseId = newTask.WhatId;
        String caseObjId = Schema.sObjectType.Case.getKeyPrefix();
        /*
            Check if this task is of Case.
            if yes then update the Disposition__c field of case.
        */
        if(caseId != null && caseId.startsWith(caseObjId)){
            caseRec = new Case(Id = caseId);
          /*  if(newTask.CallDisposition__c != null && caseRec != null) {
                caseRec.Disposition__c = newTask.CallDisposition__c;
                              
            }  */
        }
        return caseRec;
    }
   
    /*
        Method to Check if Description of Task has been changed or not. 
        if Changed then return the Note.  
    */ 
    public static Note createNote(Task oldTask, Task newTask) {
        String oldDescription = null;
        if (oldTask != null)
            oldDescription = oldTask.Description;
        String newDescription = newTask.Description;
        Id taskOwnerId = newTask.OwnerId;
        if (newDescription != null && newDescription != oldDescription) {
            if(newTask.Accountid != null) {
                objNote = new Note(Title = newTask.Subject, ParentId = newTask.Accountid, 
                                   OwnerId = taskOwnerId, Body = newDescription);
            }
        }
        return objNote;
    }
    
    /*
        Populate Task fields with respective Account fields.
    */
    public static void updateAccountFields(Task task, Account account) {
        
        task.Salutation__c = account.Salutation;
        task.First_Name__c = account.FirstName;
        task.Middle_Name__c = account.MiddleName__c;
        task.Last_Name__c = account.LastName;
        task.Street__c = account.PersonMailingStreet;
        task.City__c= account.PersonMailingCity;
        task.State__c = account.PersonMailingState;
        task.Country__c = account.PersonMailingCountry;
        task.Postal_Code__c = account.PersonMailingPostalCode;
        task.Phone__c = account.PersonHomePhone;
        task.Phone_Extension__c = account.Home_Phone_Extension__c;
        task.Phone_Consent__c = account.Home_Phone_Do_Not_Call__c;
        task.Home_Sequence__c = account.Home_Phone_Sequence__c;
        task.Work_Phone__c = account.PersonOtherPhone;
        task.Work_Phone_Extension__c = account.Other_Phone_Extension__c;
        task.Work_Phone_Consent__c = account.Other_Phone_Do_Not_Call_In__c;
        task.Work_Sequence__c = account.Other_Phone_Sequence__c;
        task.Mobile_Phone__c = account.PersonMobilePhone;
        task.Mobile_Phone_Consent__c = account.Mobile_Phone_Do_Not_Call_Indicator__c;
        task.Mobile_Sequence__c = account.Mobile_Phone_Sequence__c;
        task.Email__c = account.PersonEmail;
        task.Email_Consent__c = account.Do_Not_Email_In__c;
        task.Work_Email__c = account.Alternate_Email__c;
        task.Work_Email_Consent__c = account.Alternate_Email_Do_Not_Email__c;
        task.Dealer_Code__c = account.Preferred_Dealer_Id__r.Dealer_Code__c;

        // Make sure only "Home", "Work", or "" are sent as email type values.
        if (task.Email__c == null || task.Email__c == '')
            Task.Email_Type_1__c = '';
        else if (account.Email_Type_1__c == System.label.Email_Type_Home || account.Email_Type_1__c == System.label.Email_Type_Work)
            task.Email_Type_1__c = account.Email_Type_1__c;
        else
            task.Email_Type_1__c = System.label.Email_Type_Home;

        if (task.Work_Email__c == null || task.Email__c == '')
            Task.Email_Type_2__c = '';
        else if (account.Email_Type_2__c == System.label.Email_Type_Home || account.Email_Type_2__c == System.label.Email_Type_Work)
            task.Email_Type_2__c = account.Email_Type_2__c;
        else
            task.Email_Type_2__c = System.label.Email_Type_Home;
    }
    
    /*
        Populate Task fields with respective User fields.
    */
    public static void updateUserFields(Task task, User user) {
        task.Agent_Id__c = user.Agent_Id__c;
        //task.Call_Centre_Id__c = user.Call_Centre_Id__c;
    }
    
    /*
        Populate Task fields with respective Disposition__c fields.
    */
    public static void updateDispositionFields(Task task, Disposition__c disposition) {
        task.TMS_Disposition__c = disposition.TMS_Id__c;
        task.Dialer_Disposition__c = disposition.Dialer_Code__c;
        
        if (task.Deceased__c == false && disposition.Name == system.label.Disposition_Name_Decesed)
            task.Deceased__c = true;
        else if (task.Deceased__c == true && disposition.Name != system.label.Disposition_Name_Decesed)
            task.Deceased__c = false;
    }

    /*
        Populate Task fields with respective Vehicle__c fields.
    */
    public static void updateVehicleFields(Task task, Vehicle__c vehicle) {
        task.Odometer_Units__c = vehicle.Latest_Recorded_Mileage_Units__c;
        task.Odometer_Reading__c = vehicle.Latest_Recorded_Mileage_Number__c;
        task.PMG_Type__c = vehicle.PMG_Type__c;
    }
    
    /*
        Populate Task fields with respective CampaignMember fields.
    */
    public static void updateCampaignMemberFields(Task task, CampaignMember member) {
        task.Service_Marketing_Call_Id__c = String.valueOf(member.Service_Marketing_Call_Id__c);
        task.Call_Phone__c = member.Phone_1__c;
        task.Language__c = member.Language__c;
        task.Preferred_Phone_Type__c = member.Preferred_Phone_Type__c;
        task.Preferred_Mail_Type__c = member.Preferred_Mail_Type__c;
        task.Preferred_Call_time__c = member.Preferred_Call_Time__c;
        task.Service_Marketing_Call_Type__c = member.Service_Marketing_Call_Type__c;
        task.CampaignName__c = member.RecordType.Name;
                
        User agent = [SELECT Call_Centre_Id__c FROM User WHERE Id =: task.OwnerId];
		string CCID = agent.Call_Centre_Id__c;

		if(member.RecordType.Name.contains(NCI_TEXT))
		{
			task.Call_Centre_Id__c = '4';
		}
		else
		{
			if(CCID == null || CCID == '4')		
			{
				task.Call_Centre_Id__c = '7';			
			}
			else			
			{
				task.Call_Centre_Id__c = CCID;			
			}
		}
		
    }
    
    /*
        Create Chatter posts with Mention.
    */
    public static void createChatterMention(Task t,  Map<String, String> taskCaseMap, Map<Id, Case> caseMap){
    	
      if(taskCaseMap != null && taskCaseMap.containsKey(t.Id) && (t.Owner.Profile.Name == 'DTS' || t.Owner.Profile.Name == 'DTS Manager')){
      	String recipient = t.OwnerId;
        String text = 'Hello '+t.Owner.Name+', \n\n'; 
        text+='Task : '+URL.getSalesforceBaseUrl().toExternalForm() + '/'+t.Id +'\n';
        
        if(taskCaseMap.get(t.Id) != null && (caseMap.get(taskCaseMap.get(t.Id)) != null)){
        text += 'Case: '+caseMap.get(taskCaseMap.get(t.Id)).CaseNumber + ' ('+URL.getSalesforceBaseUrl().toExternalForm()+'/'+taskCaseMap.get(t.Id)+')\n';
        
        text += 'Provide your Field Inspection date and update the status of this task. \n\n';
        if(caseMap.get(taskCaseMap.get(t.Id)).Recordtype.Name.contains('CA') || caseMap.get(taskCaseMap.get(t.Id)).Recordtype.Name.contains('T5')){
	        if(caseMap.get(taskCaseMap.get(t.Id)).Account.Name != null){
	        text += 'Customer Name: '+ caseMap.get(taskCaseMap.get(t.Id)).Account.Name + '\n';
	        }else{
	          text += 'Customer Name: \n';	
	        }
        }else if(caseMap.get(taskCaseMap.get(t.Id)).Recordtype.Name.containsignorecase('TECH LINE')){
        	 if(caseMap.get(taskCaseMap.get(t.Id)).Customer_Name__c != null){
	        text += 'Customer Name: '+ caseMap.get(taskCaseMap.get(t.Id)).Customer_Name__c + '\n';
	        }else{
	          text += 'Customer Name: \n';	
	        }
        }
        if(caseMap.get(taskCaseMap.get(t.Id)).Vehicle_Name__r.Make_Model__c != null){
          text += 'Model Year: '+ caseMap.get(taskCaseMap.get(t.Id)).Vehicle_Name__r.Make_Model__c + '\n';
        }else{
          text += 'Model Year: \n';
        }
        if(caseMap.get(taskCaseMap.get(t.Id)).VIN__c != null){
          text += 'VIN: '+ caseMap.get(taskCaseMap.get(t.Id)).VIN__c + '\n';
        }else{
          text += 'VIN: \n';
        }
        if(caseMap.get(taskCaseMap.get(t.Id)).RecordType.Name.contains('TECH LINE') ){
	        if(caseMap.get(taskCaseMap.get(t.Id)).Dealer__r.Name != null){
	          text += 'Dealer Name: '+ caseMap.get(taskCaseMap.get(t.Id)).Dealer__r.Name + '\n';
	        }else{
	          text += 'Dealer Name: \n'; 	
	        }
	        if(caseMap.get(taskCaseMap.get(t.Id)).Dealer__r.Dealer_Code__c != null){
	          text += 'Dealer Code: '+caseMap.get(taskCaseMap.get(t.Id)).Dealer__r.Dealer_Code__c + '\n\n Notes to DTS: \n';
	        }else{
	          text += 'Dealer Code: \n\n Notes to DTS: \n'; 	
	        }
        }else if(caseMap.get(taskCaseMap.get(t.Id)).RecordType.Name.contains('CA') || caseMap.get(taskCaseMap.get(t.Id)).Recordtype.Name.contains('T5')){
        	if(caseMap.get(taskCaseMap.get(t.Id)).Servicing_Dealer__r.Name != null){
	          text += 'Dealer Name: '+ caseMap.get(taskCaseMap.get(t.Id)).Servicing_Dealer__r.Name + '\n';
	        }else{
	          text += 'Dealer Name: \n'; 	
	        }
	        if(caseMap.get(taskCaseMap.get(t.Id)).Servicing_Dealer__r.Dealer_Code__c != null){
	          text += 'Dealer Code: '+caseMap.get(taskCaseMap.get(t.Id)).Servicing_Dealer__r.Dealer_Code__c + '\n\n Notes to DTS: \n';
	        }else{
	          text += 'Dealer Code: \n\n Notes to DTS: \n'; 	
	        }
        }
               
        if(t.Description != null){
        	text += t.Description;
        }
        
        }
        
        ConnectApiHelper.sendPrivateMessageToRecipients(text, recipient);    
        //ConnectApiHelper.postFeedItemWithMentions(null, UserInfo.getUserId(), text);
     }   
    }
    
    public static void sendCompletedActivityEmail(List<Task> tasks){
      
       Set<Id> caseIds = new Set<Id>();	
       Map<String, Case> taskCaseMap = new Map<String, Case>();
       String caseId = '';
       
       for(Task tsk : tasks){
       	caseId = tsk.WhatId;
       	if(tsk.WhatId != null && (caseId.startswith(Schema.sObjectType.Case.getKeyPrefix()))){
       		caseIds.add(tsk.WhatId);
       	}
       }
       
       if(caseIds.size() > 0){
       for(Case cas : [Select Id, CaseNumber from Case where Id IN : caseIds]){
       	taskCaseMap.put(cas.Id, cas);
       }
       
       for(Task t : [Select Id, OwnerId, Owner.Name, LastModifiedById, WhatId, ActivityDate, Subject from Task where Id IN : tasks]){
       
       if(taskCaseMap.containskey(t.WhatId)){	
	       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	   	   List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
	   	   
	   	   message.setTargetObjectId(t.LastModifiedById);
	   	   message.setSaveAsActivity(false);
	   	   message.setPlainTextBody('Assigned to: '+t.Owner.Name +'\n Related To: '+taskCaseMap.get(t.WhatId).CaseNumber +'\n Due Date: '+t.ActivityDate +'\n\n Click here to view: '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+t.Id );
	   	   message.setSubject('Task Completed - '+t.Subject);
	   	   messages.add(message);
	   	   
	   	   System.debug('msg:::'+messages);
	   	   Messaging.sendEmail(messages);
       }
       }
       }
    }
     
}