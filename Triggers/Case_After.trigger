/**********************************************************************
  Name: Case_After
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose: 
  On change of the case description Case Comment gets created. 

  Related Apex Class: CaseClass
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL 
  1.0 - Biswa Ray 12/28/2010 Created
  1.2 - Biswa Ray 11/01/2011 Incorporated Code Comments and Headers. 
  1.3 - Bryan Fry 13/01/2011 Added code to create CaseTeamMember after 
  insert (RONETELETECH-80).
  1.4 - Yuli Fintescu 06/09/2011 Allow case to be able to assign to Case Queue
  1.5 - Bryan Fry 08/08/2011 Removed CaseTeamMember code
  1.6 - Yuli Fintescu 09/19/2011 If Case "Current Mileage" is greater than the related Vehicle's "Latest Recorded Mileage", 
  then "Current Mileage" field on the Case record should update the "Latest Recorded Mileage" on the related Vehicle upon SAVE Case command.
  1.7 - Yuli Fintescu 11/02/2011 When DPIC case is closed for US or Canada all DCB open task are automatically completed and closed.
  1.8 - Yuli Fintescu 01/25/2012 Change 1.6 logic to If Case "Current Mileage" is greater than 0, 
  then "Current Mileage" field on the Case record should update the "Latest Recorded Mileage" on the related Vehicle upon SAVE Case command.
  1.9 - Bryan Fry     06/21/2012 Remove manual sharing to dealer portal users on closed CA Cases
  1.10 -Bryan Fry     11/14/2012 Change sharing removal to look at Remove_Dealer_Sharing__c flag
  1.11 -Bryan Fry     05/01/2013 Create new Call__c record when VCS and LEAF Cases are inserted
  1.12 -Bryan Fry     09/04/2013 Send emails to FOM, Service Manager and Techline when CA Multiple Repairs flag is set.
  1.13 -Bryan Fry     09/18/2013 Comment out code to send emails when CA Multiple Repairs flag is set.
  1.14 -Bryan Fry     09/18/2013 Change VCS and LEAF Call__c logic for chat.
  1.15 -Matt Starr    08/06/2014 Added DTS functionality
  1.16 -Will Taylor   09/14/2014 Trigger adjustments for deployment
  1.17 -Aaron Bessey  09/17/2014 CaseComments have a max of 4000 characters, added code to span comments over multiple records
  1.18 -Vivek Batham  12/24/2014 Added logic for Chatter post when a DTS notification is confirmed  
  1.19-Anna Koseikina 07/15/2015 Added changes for DTS Reassignemnt task implementation
  1.20-Anna Koseikina 08/31/2015 Merged changes for Tiger Team Survey task
  ***********************************************************************/

trigger Case_After on Case(after insert, after update) {
    
    if(Trigger_Switch__c.getInstance(Label.Trigger_CaseAfter) != null && Trigger_Switch__c.getInstance(Label.Trigger_CaseAfter).Disabled__c){
        return;
    }
    private final String RECORD_TYPE_TECH_LINE = 'TECH LINE Cases';
    private final String ID_SYS_ADMIN = '00eA0000000OSONIA4';
    private final String ID_SYS_ADMIN_INTEGRATION = '00eF0000000eI1YIAU';
    private final String ID_SYS_ADMIN_CONFIG = '00eF0000000eFZOIA2';
    private final String ID_MANAGED_SERVICES = '00eF0000000eBXDIA2';
    Integer CALL_NOTE_SIZE = 3500;
    Map<ID, Vehicle__c> relatedVehicles = new Map<ID, Vehicle__c>();
    Map<ID, Case> errorCases = new Map<ID, Case>();//for collecting errors when updating vehicles
    Set<ID> closedCaseIDs = new Set<ID>();
    Set<ID> removeSharingCaseIDs = new Set<ID>();
    List<CaseShare> deleteShares = new List<CaseShare>();
    Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    Id DPICRTId = rtInfosByName.get('DPIC').getRecordTypeId();
    Id CAEmailNissanRTId = rtInfosByName.get('CA Email Nissan').getRecordTypeId(); //'012F0000000yBIrIAM';
    Id CAEmailInfinitiRTId = rtInfosByName.get('CA Email Infiniti').getRecordTypeId(); //'012F0000000yC0BIAU';
    String VCSrt = rtInfosByName.get('VCS Support').getRecordTypeId(); //'012F0000000yFNiIAM';
    String LEAFrt = rtInfosByName.get('LEAF').getRecordTypeId(); // '012A0000000xeksIAA';
    String techlineCasesId = rtInfosByName.get(RECORD_TYPE_TECH_LINE).getRecordTypeId();
    String techlineId = rtInfosByName.get('TECH LINE').getRecordTypeId();
    
    Map<String, Schema.RecordTypeInfo> callrtInfosByName = Schema.SObjectType.Call__c.getRecordTypeInfosByName();
    String leafRecordTypeId = callrtInfosByName.get('LEAF').getRecordTypeId();
    String vcsRecordTypeId = callrtInfosByName.get('VCS').getRecordTypeId();
    
    Set<Id> contactIds = new Set<Id> ();
    Map<Id,Case> dpicCases = new Map<Id,Case>();
    Claim_Form_Settings__c clmSettings = Claim_Form_Settings__c.getValues(Label.Claim_NissanVersa);
    List<User> usrList = new List<User>();
	if(clmSettings != null){
		usrList = [Select Id from User where Name =: clmSettings.Site_User_Name__c limit 1];
	}
    List<CaseShare> caseShareList = new List<CaseShare>();

    for (Case c : Trigger.New) {
        //collect the related vehicles - we only care about the cases with mileage data - 1.6 & 1.8
        if (c.Vehicle_Name__c != null && c.Current_Mileage__c != null) {
            //populate map of relatedVehicles. Note each vehicle in the map takes the greatest mileage among its related cases
            if (!relatedVehicles.containsKey(c.Vehicle_Name__c)) {
                relatedVehicles.put(c.Vehicle_Name__c, new Vehicle__c(ID = c.Vehicle_Name__c, 
                                Latest_Recorded_Mileage_Units__c = 'M', 
                                Latest_Recorded_Mileage_Number__c = c.Current_Mileage__c));
                errorCases.put(c.Vehicle_Name__c, c);
            } else {
                Vehicle__c v = relatedVehicles.get(c.Vehicle_Name__c);
                if (v.Latest_Recorded_Mileage_Number__c < c.Current_Mileage__c) {
                    v.Latest_Recorded_Mileage_Number__c = c.Current_Mileage__c;
                    errorCases.put(c.Vehicle_Name__c, c);
                }
            }
        }
        
        //collect closed cases - 1.7 & 1.10
        if (c.Status == 'Closed') {
            if (!closedCaseIDs.contains(c.ID))
                closedCaseIDs.add(c.ID);
            if (c.Remove_Dealer_Sharing__c == true && !removeSharingCaseIDs.contains(c.ID))
                removeSharingCaseIDs.add(c.ID);
        }
        if(c.recordTypeId == DPICRTId){ 
            if(c.ContactId != null){
                contactIds.Add(c.ContactId);
            }            

            dpicCases.put(c.Id, c);
        }
        
        if(Trigger.isInsert && usrList.size() > 0 && c.CreatedById == usrList[0].Id){
        	CaseShare cShare = new CaseShare(CaseId= c.Id, UserOrGroupId  = usrList[0].Id, CaseAccessLevel = 'edit');
        	caseShareList.add(cShare);
        }

    }

    //1.7 - complete DCB tasks when DPIC case is closed
    List<Task> tasksToComplete = new List<Task>();
    if (closedCaseIDs.size() > 0) {
        //collect closed DPIC cases
        Map<ID, Case> mapClosedDPICCases = new Map<ID, Case>([Select ID, Account.BillingCountry From Case Where ID IN: closedCaseIDs and RecordType.Name in ('DPIC', 'DPIC Supply Escalation', 'DPIC Parts Escalation', 'DPIC Technical Escalation')]);
        
        //collect incomplete dcb tasks related to the closed DPIC cases
        List<Task> dcbTasks = [Select t.WhatId, t.Subject, t.Id
                                From Task t 
                                WHERE t.WhatId IN: mapClosedDPICCases.keySet()
                                and t.Status <> 'Complete'
                                and (t.Subject =: System.Label.Task_Subject_24hr_Dealer_Call_Back
                                     or t.Subject =: System.Label.Task_Subject_48hr_Dealer_Call_Back
                                     or t.Subject =: System.Label.Task_Subject_24hr_Dealer_Email_Reply)];
        for (Task t : dcbTasks) {
            Case c = mapClosedDPICCases.get(t.WhatId);
            String billingCountry = c.Account.BillingCountry == null ? '' : c.Account.BillingCountry;
            
            //the following logic is based on case workflow rules: incomplete dcb tasks with subject 24hr Dealer Call Back related to closed DPIC Canada cases
            //                                                  or incomplete dcb tasks with subject 48hr Dealer Call Back related to closed DPIC Non-Canada cases
            if ((t.Subject == System.Label.Task_Subject_24hr_Dealer_Call_Back && 
                    (billingCountry.equalsIgnoreCase('Canada') || billingCountry.equalsIgnoreCase('CA'))) ||
                (t.Subject == System.Label.Task_Subject_48hr_Dealer_Call_Back && 
                    !billingCountry.equalsIgnoreCase('Canada') && !billingCountry.equalsIgnoreCase('CA')) ||
                (t.Subject == System.Label.Task_Subject_24hr_Dealer_Email_Reply)) {
                
                t.Status = 'Complete';
                tasksToComplete.add(t);
                errorCases.put(t.ID, c);
            }
        }
    }
    
    // 1.10 - Remove manual sharing to dealer portal users on closed CA Cases with Remove_Dealer_Sharing__c flag = true
    if (removeSharingCaseIDs.size() > 0) {
        // Get List of CaseShare records for closed CA Cases shared with dealer portal users
        if (System.Label.TurnOffDealerPortal != 'Yes') {
            deleteShares = [select id 
                            from CaseShare 
                            where RowCause = 'Manual' 
                            and UserOrGroupId in (select Id from User where profile.userlicense.name = 'Gold Partner') 
                            And Case.RecordType.Name in ('CA','CA Email Infiniti','CA Email Nissan','T5','Roadside Assistance','CA Closed Case')
                            And CaseId in :removeSharingCaseIds];
        }
    }
    
       
    //1.8 - update vehicles
    try {
        if (relatedVehicles.size() > 0)
            update relatedVehicles.values();
    } catch (DMLException e){
        for (Integer i = 0; i < e.getNumDml(); i++) {
            errorCases.get(e.getDmlId(i)).addError('Exception occured while updating Vehicle Mileage: ' + e.getMessage());
        }
    }
    
    //1.7 - complete tasks
    try {
        if (tasksToComplete.size() > 0)
            update tasksToComplete;
    } catch (DMLException e){
        for (Integer i = 0; i < e.getNumDml(); i++) {
            errorCases.get(e.getDmlId(i)).addError('Exception occured while completing Dealer Call Back Tasks: ' + e.getMessage());
        }
    }
    try{
    	if(caseShareList.size() > 0){
    		insert caseShareList;
    	}    	
    }catch(Exception ex){
    	
    }

    // 1.10 - Delete CaseShares
    if (System.Label.TurnOffDealerPortal != 'Yes') {
        try {
            if (!deleteShares.isEmpty()) {
                delete deleteShares;
            }
        } catch (DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorCases.get(e.getDmlId(i)).addError('Exception occured while deleting CaseShares: ' + e.getMessage());
            }       
        }
    }

    List<CaseComment> cComments = new List<CaseComment>();
 
   
   // PROD 9/12/2014    /* Id DPICRTId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'DPIC');    Id CAEmailNissanRTId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'CA Email Nissan');    Id CAEmailInfinitiRTId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'CA Email Infiniti'); */
   
    /* 
        Iterate over the list of records being processed in the trigger. If this is an update,
        insert CaseComment.       
    */
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (Trigger.isUpdate)
        {
            //AAB 9/17/2014 - Code to span large comments over multiple Case Comments
            Case newCase = Trigger.new[i];
            Case oldCase = Trigger.old[i];
            if ((newCase.Description == null && oldCase.Description != null) ||
            (newCase.Description != null && oldCase.Description != null && 
            oldCase.Description != newCase.Description)) {
                createMultipleComments(cComments, oldCase.Description, newCase.ID);
            }            
        }
        else if (Trigger.new[i].Description != null &&
                 (Trigger.new[i].RecordTypeID == DPICRTId ||
                  Trigger.new[i].RecordTypeID == CAEmailNissanRTId ||
                  Trigger.new[i].RecordTypeID == CAEmailInfinitiRTId)) 
        {
            //AAB 9/17/2014 - Code to span large comments over multiple Case Comments
            createMultipleComments(cComments, Trigger.new[i].Description, Trigger.new[i].Id);
        }
    }
    
    /*
        Insert Comments
    */
    try {
        if(cComments.size() > 0) {
          insert cComments;
        }
    }
    catch (DMLException e){
        for(CaseComment caseComment : cComments){
            caseComment.addError(system.label.Exception_occured_while_inserting_Case_Comments + e.getMessage());
        }
    }

    // 1.11 If new VCS or LEAF Case is created, create a new Task record related to it.
   /* RecordType leafRecordType = [select Id, Name from RecordType where SobjectType = 'Call__c' and Name = 'LEAF'];
    RecordType vcsRecordType = [select Id, Name from RecordType where SobjectType = 'Call__c' and Name = 'VCS'];*/
    List<Call__c> callsToInsert = new List<Call__c>();
    if (Trigger.isInsert) {
        for (Case c: Trigger.new) {
           
            if (c.RecordTypeId == VCSrt && (c.Origin == 'Phone' || c.Origin == 'Chat' || c.Origin == 'Voicemail')) {
                Call__c call = new Call__c();
                call.RecordTypeId = leafRecordTypeId;
                call.Case__c = c.Id;
                if (c.Origin == 'Chat') {
                    call.Call_Type__c = 'Chat';
                } else {
                    call.Call_Type__c = 'Inbound';
                }
                call.Status__c = 'Complete';
                call.Assigned_To__c = UserInfo.getUserId();
                call.Notes__c = c.Description == null ? null : c.Description.left(CALL_NOTE_SIZE);
                
                callsToInsert.add(call);
            } else if (c.RecordTypeId == LEAFrt && (c.Origin == 'Phone' || c.Origin == 'Chat' || c.Origin == 'Voicemail')) {
                Call__c call = new Call__c();
                call.RecordTypeId = vcsRecordTypeId;
                call.Case__c = c.Id;
                if (c.Origin == 'Chat') {
                    call.Call_Type__c = 'Chat';
                } else {
                    call.Call_Type__c = 'Inbound';
                }
                call.Status__c = 'Complete';
                call.Assigned_To__c = UserInfo.getUserId();
                call.Notes__c = c.Description == null ? null : c.Description.left(CALL_NOTE_SIZE);
                
                callsToInsert.add(call);                
            }
        }
    }
    
    if (!callsToInsert.isEmpty()) {
        insert callsToInsert;
    }
    
    /* Commented By Vivek --> Why is it needed?
    for (Case c: Trigger.new) {
        if (c.CA_Multiple_Repairs__c == true) {
        }
    }*/

    // Find Cases where CA Multiple Repairs is true
    Set<String> emailDealerIds = new Set<String>();
    List<Case> emailDealerCases = new List<Case>();
    Case newCase;
    Case oldCase;
    for (Integer count = 0; count < Trigger.new.size(); count++) {
        newCase = Trigger.new[count];
        if (Trigger.isUpdate) {
            oldCase = Trigger.old[count];
        } else {
            oldCase = null;
        }

        if (newCase.CA_Multiple_Repairs__c == true && (Trigger.isInsert || oldCase.CA_Multiple_Repairs__c != true )) {
            if (!emailDealerIds.contains(newCase.Servicing_Dealer__c)) {
                emailDealerIds.add(newCase.Servicing_Dealer__c);
            }

            emailDealerCases.add(newCase);
        }
    }


//Techline stuff

    if (Trigger.new.size() == 1) {    
        
        
        ValidationUtility datacheck = new ValidationUtility();
        List<CaseComment> caseComments = new List<CaseComment>();
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c: Trigger.new) {
            if (c.RecordTypeId == techlineCasesId) {

                //Send the notifications
                if (System.Label.Send_Techline_Alert == 'Yes') {
                    if (UserInfo.getProfileId() != ID_SYS_ADMIN &&
                        UserInfo.getProfileId() != ID_SYS_ADMIN_INTEGRATION &&
                        UserInfo.getProfileId() != ID_SYS_ADMIN_CONFIG &&
                        UserInfo.getProfileId() != ID_MANAGED_SERVICES) {
        // THE FOLLOWING IS IN PROD as of 9/12/2014

                    Boolean sendHeadsUp = false;
                    if (c.Critical_Status_Flag__c && (Trigger.isInsert || 
                      !Trigger.oldMap.get(c.ID).Critical_Status_Flag__c)) {
                      sendHeadsUp = true;
                    }
                    
                    Boolean sendDTS = false;
                    if (c.DTS_Notification__c && (Trigger.isInsert ||
                      !Trigger.oldMap.get(c.ID).DTS_Notification__c)) {
                      sendDTS = true;
                    }
        // --------
                    Techline_NotificationEmails notifications = new Techline_NotificationEmails();
                    notifications.sendTechLineEmails(c, Trigger.isInsert,sendHeadsUp,sendDTS);
                    
                    if(sendHeadsUp == true){
                        casesToUpdate.add(new Case(Id = c.Id, Critical_Status_Flag__c = false));
                    }
                    }
                } 
                
               
 // THIS DOES NOT EXIST IN THE PROD VERSION             
                //Insert a Task for Supervisor Review
                if (c.Supervisor_Review__c && 
                    (Trigger.isInsert || !Trigger.oldMap.get(c.ID).Supervisor_Review__c)) {
                    Techline_SupervisorReview sr = new Techline_SupervisorReview();
                    sr.createSupervisorTasks(c.Id, c.CaseNumber);
                }
 //----                
                // Create a case comment with some original values
                if (Trigger.isInsert) {
                    String commentBody = '';
                    if (!datacheck.IsStringNullOrEmpty(c.Problem_Analysis__c)) {
                        commentBody += 'Problem Analysis: ' + c.Problem_Analysis__c + '\n\b';
                    }
                    else {
                        commentBody += 'Problem Analysis: -\n\b';
                    }
                    
                    if (!datacheck.IsStringNullOrEmpty(c.Description)) {
                        commentBody += 'Description: ' + c.Description + '\n\b';
                    }
                    else {
                        commentBody += 'Description: -\n\b';
                    }
                    
                    if (!datacheck.IsStringNullOrEmpty(c.Initial_Recommendation__c)) {
                        commentBody += 'Initial Recommendation: ' + c.Initial_Recommendation__c + '\n\b';
                    }
                    else {
                        commentBody += 'Initial Recommendation: -\n\b';
                    }
                    
                    if (!datacheck.IsStringNullOrEmpty(c.DTC_1__c)) {
                        commentBody += 'DTC 1: ' + c.DTC_1__c + '\n\b';
                    }
                    else {
                        commentBody += 'DTC 1: -\n\b';
                    }
                    
                    if (!datacheck.IsStringNullOrEmpty(c.DTC_2__c)) {
                        commentBody += 'DTC 2: ' + c.DTC_2__c + '\n\b';
                    }
                    else {
                        commentBody += 'DTC 2: -\n\b';
                    }
                    
                    if (!datacheck.IsStringNullOrEmpty(c.DTC_3__c)) {
                        commentBody += 'DTC 3: ' + c.DTC_3__c;
                    }
                    else {
                        commentBody += 'DTC 3: -';
                    }
                    
                    /* 
                     //AAB 9/17/2014 - Span multiple comments
                    CaseComment cc = new CaseComment();
                    cc.ParentId = c.Id;
                    cc.CommentBody = commentBody;
                    insert cc;
                    */
                    createMultipleComments(caseComments,commentBody, c.Id);
                }  
            }  
        }
             
        try 
        {
            if(caseComments.size() > 0) {
              insert caseComments;
            }
        }
        catch (DMLException e){
            for(CaseComment caseComment : caseComments){
                caseComment.addError(system.label.Exception_occured_while_inserting_Case_Comments + e.getMessage());
            }
        }
               
        if(casesToUpdate.size() > 0){
            Database.update(casesToUpdate, false);
        }
    }
    
    
    /********************************
    1.15 DTS Functionality*/
    
    List<Case> dtsCases = new List<Case>();
    Set<Id> dtsCaseIds = new Set<Id>();
    Set<Id> dtsVehicleIds = new Set<Id>();
    Map<Id, CaseComment> mapCaseComments = new Map<Id, caseComment>();
    Map<Id, Vehicle_Ownership_History__c> mapVehicleOwnershipHistory = new Map<Id, Vehicle_Ownership_History__c>();
    Map<Id, Case> caseMap = new Map<Id, Case>();
    

    for(Case c : trigger.new){
        
        dtsCaseIds.Add(c.Id);
        if(c.Vehicle_Name__c!=null)
        {
            dtsVehicleIds.Add(c.Vehicle_Name__c);
        }
        
        if(trigger.IsUpdate){
        Case oldCase2 = trigger.oldMap.get(c.Id);
        
        // Removed recordtype restriction for dtsCase processing ( && c.RecordtypeId == '012F0000000y9y7' || c.RecordtypeId == '012F0000000yCuJ' ||  c.RecordtypeId == '012F0000000yFmQ')
        if(c.DTS_Inspection_Date_Confirmed__c == true && 
           oldCase2.DTS_Inspection_Date_Confirmed__c == false &&
           c.DTS_Notification__c == true &&
           c.DTS_Inspection_Task_Assigned__c != null &&
           c.Field_Inspection_Indicator__c == true
           ) {
               dtsCases.add(c);
            }
        }
    }
        
        if(dtsCases.size() > 0){
            
            List<Case> updateCases = new List<Case>();
            List<DTS_Field_Inspection__c> dtsInsert = new List<DTS_Field_Inspection__c>();
            
            for(CaseComment cc : [Select Id, ParentId, CommentBody, CreatedBy.Name, 
                                      CreatedDate from CaseComment where ParentId in :dtsCaseIds
                                      Order By CreatedDate DESC])
            {
                if(mapCaseComments.get(cc.ParentId)==null)
                {
                    mapCaseComments.put(cc.ParentId, cc);
                }
            }
            
            for(Vehicle_Ownership_History__c voh : [Select Id, Owner__c, Owner__r.Id, 
                                  Owner__r.Name, Vehicle__c from Vehicle_Ownership_History__c 
                                  where Vehicle__c in :dtsVehicleIds 
                                  order by createdDate desc])
            {
                if(mapVehicleOwnershipHistory.get(voh.Vehicle__c)==null)
                {
                    mapVehicleOwnershipHistory.put(voh.Vehicle__c, voh);
                }
            }
            
            CaseComment cc;
            Vehicle_Ownership_History__c voh;
            for(Case cas : [Select Id, Account.Name, AccountId, Vehicle_Name__c, Description, Dealer__c, DTS_Field_Inspection__c,
                                   Initial_Recommendation__c, DTS_Notes__c, Inspection_Time_Notes__c, Problem_Analysis__c,Servicing_Dealer__c,
                                   OwnerId, DTS_Inspection_Task_Assigned__c, DTS_Inspection_Date_Set__c, DealerCode__c, 
                                   CaseNumber, Vehicle_Service_Contract__c, DTS_Request_Type__c, RecordTypeId, Case_Servicing_Dealer_Code__c, Task_Field_Inspection_Owner__c
                            From Case where Id IN : dtsCases]){
                
                String lastComment = '';
                String customer = '';
                String customerName = '';
                
                caseMap.put(cas.Id, cas);
                
                String OwnerId = cas.OwnerId;
                
                if(cas.RecordTypeId == techlineCasesId || cas.RecordTypeId == techlineId){ //for Techline Cases (All Other Handled in 'else' condition
                
                    cc = mapCaseComments.get(cas.Id);
                    if(cc!=null)
                    {
                        lastComment = cc.CreatedBy.Name + ' - ' + cc.CreatedDate + '\r\n' + cc.CommentBody;
                    }
                    
                    
                    voh = mapVehicleOwnershipHistory.get(cas.Vehicle_Name__c);
                    if(voh!=null && voh.Owner__c!=null)
                     {
                        customer = voh.Owner__r.Id;    
                        if(voh.Owner__r.Name!=null)
                        {
                            customerName = voh.Owner__r.Name; 
                        }
                     }

                    DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c(
                        Dealer__c = cas.Dealer__c,
                        Dealer_Action_Observation__c = cas.Description,
                        DTS_Inspection_Date__c = cas.DTS_Field_Inspection__c,
                        Initial_Recommendation__c = cas.Initial_Recommendation__c,
                        Latest_Update__c = lastComment,
                        Internal_Comments__c = cas.DTS_Notes__c,

                        Inspection_Time_Notes__c = cas.Inspection_Time_Notes__c,
                        Problem_Analysis__c = cas.Problem_Analysis__c,
                        Related_Support_Case__c = cas.Id,
                        Requesting_Agent__c = OwnerId != null && OwnerId.startsWith('005') ? cas.OwnerId : null,
                        DTS_Inspection_Task_Assigned__c = cas.DTS_Inspection_Task_Assigned__c,
                        DTS_Inspection_Date_Set__c = cas.DTS_Inspection_Date_Set__c,
                        VIN__c = cas.Vehicle_Name__c,
                        Name = cas.CaseNumber+' '+customerName+' '+cas.DealerCode__c,
                        Customers_Concern__c =  cas.DTS_Notes__c,
                        Request_Type__c = cas.DTS_Request_Type__c);
                        if(!String.isEmpty(cas.Task_Field_Inspection_Owner__c)){
                            dts.ownerId = cas.Task_Field_Inspection_Owner__c;
                        }
                        if(customer != ''){
                        dts.Customer_Name__c = customer;
                        }
                    dtsInsert.add(dts);
                    
                    Case updateCase = new Case(Id=cas.Id);  
                        updateCase.DTS_Field_Inspection__c = null;
                        updateCase.DTS_Inspection_Date_Confirmed__c = false;
                        updateCase.DTS_Inspection_Date_Set__c = null;
                        updateCase.DTS_Inspection_Task_Assigned__c = null;
                        updateCase.DTS_Notification__c = false;
                        updateCase.DTS_Notes__c = '';
                        updateCase.DTS_Request_Type__c = null;
                        updateCase.Inspection_Time_Notes__c = 'Appointment Time:  \n\n Notes to Agent:';
                    
                    updateCases.add(updateCase);
                    
                } else {
                
                    // ALL OTHER (CA) RECORDTYPES 
                    //012F0000000y9y7  
                    
                      cc = mapCaseComments.get(cas.Id);
                      if(cc!=null)
                      {
                          lastComment = cc.CommentBody;
                      }      
                    
                    DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c(
                        Customer_Name__c = cas.AccountId,
                        Dealer__c = cas.Servicing_Dealer__c,
                        Dealer_Action_Observation__c = cas.Description,
                        DTS_Inspection_Date__c = cas.DTS_Field_Inspection__c,
                        Latest_Update__c = lastComment,
                        Related_Support_Case__c = cas.Id,
                        Requesting_Agent__c = OwnerId != null && OwnerId.startsWith('005') ? cas.OwnerId : null,
                        Vehicle_Service_Contract__c = cas.Vehicle_Service_Contract__c,
                        VIN__c = cas.Vehicle_Name__c,
                        DTS_Inspection_Task_Assigned__c = cas.DTS_Inspection_Task_Assigned__c,
                        DTS_Inspection_Date_Set__c = cas.DTS_Inspection_Date_Set__c,
                        Name = cas.CaseNumber+' '+cas.Account.Name+' '+cas.Case_Servicing_Dealer_Code__c,
                        Request_Type__c = cas.DTS_Request_Type__c,
                        Internal_Comments__c = cas.DTS_Notes__c,
                        Inspection_Time_Notes__c = cas.Inspection_Time_Notes__c,
                        Customers_Concern__c =  cas.DTS_Notes__c);
                        if(!String.isEmpty(cas.Task_Field_Inspection_Owner__c)){
                            dts.ownerId = cas.Task_Field_Inspection_Owner__c;
                        }
                            dtsInsert.add(dts);
                
                    Case updateCase = new Case(Id=cas.Id);
                    updateCase.DTS_Field_Inspection__c = null;
                    updateCase.DTS_Inspection_Date_Confirmed__c = false;
                    updateCase.DTS_Inspection_Date_Set__c = null;
                    updateCase.DTS_Inspection_Task_Assigned__c = null;
                    updateCase.DTS_Notification__c = false;
                    updateCase.DTS_Notes__c = '';
                    updateCase.DTS_Request_Type__c = null;
                    updateCase.Inspection_Time_Notes__c = 'Appointment Time:  \n\n Notes to Agent:';
                    
                    updateCases.add(updateCase);
                
                
                
                }
                
                
            }  
            
            if(dtsInsert.size() > 0){
                System.debug('dtsInsert:::'+dtsInsert);
               // insert dtsInsert;
               Database.SaveResult[] dbResults = Database.insert(dtsInsert, false);

                    // If there are any results, handle the errors
                    if (!dbResults.isEmpty())
                    {
                        // Loop through results returned
                        for (integer row = 0; row <dtsInsert.size(); row++)
                        {
                            // If the current row was not sucessful, handle the error.
                            if (!dbResults[row].isSuccess())
                            {                               // Get the error for this row
                                Database.Error err = dbResults[row].getErrors() [0];
                                Trigger.newMap.get(dtsInsert[row].Related_Support_Case__c).addError(system.label.Exception_occured_while_inserting_DTS_Field_Inspection + err.getMessage());
                            }            
                        }
                    
                }
                CaseClass.doChatterPost(dtsInsert, caseMap);
            }
            
            if(updateCases.size() > 0){
                Update updateCases;
            }
            
    }
    
    //AAB 9/17/2014 - Method to add multiple comments to the List of Case Comments provided
    public void createMultipleComments(List<CaseComment> caseComments, String commentBody, Id parentId)
    {
        CaseComment cc;
        while(commentBody.length()>0)
        {
            if(commentBody.length()>4000)
            {
                cc = new CaseComment();
                cc.ParentId = parentId;
                cc.CommentBody = commentBody.mid(0,4000);
                caseComments.Add(cc);
                commentBody = commentBody.substring(4000);
            }
            else
            {
                cc = new CaseComment();
                cc.ParentId = parentId;
                cc.CommentBody = commentBody;
                caseComments.Add(cc);
                commentBody = '';
            }                    
        }
    }
    
    if(dpicCases.size() > 0){
        CaseAfterHelper caseAfterHelperInstance = new CaseAfterHelper();
        if ((CaseAfterHelper.firstRun || Test.isRunningTest()) && Trigger.isUpdate) {
        dpicCases = new Map<ID, Case> ([Select id, owner.name, status, recordtypeid, Reason,Part_Number_1__c, contactID, caseNumber from case where id in :dpicCases.keyset()]);
            caseAfterHelperInstance.tigerTeamSurveys(dpicCases, Trigger.oldMap, contactIds);
            CaseAfterHelper.firstRun = false;
        }
    }
}