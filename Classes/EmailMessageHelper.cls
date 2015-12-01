/*************************************************************************************
  Name: EmailMessageHelper
  =======================================================================================
  History: 

  VERSION AUTHOR         DATE         DETAIL 
  1.02 - Vivek Batham   1/23/2015    Created Helper class for EmailMessage Triggers.
  Added logic for reopening/creating a Case 
  based on a Customer reply on 30 days duration
  ****************************************************************************************/

public with sharing class EmailMessageHelper {

    // After Insert
    public static void handleAfterInsertEvent(List<EmailMessage> emailMsges) {
        //1.05 Vladimir Martynenko: Maritz Backfeet Stage Object Creation;
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForEmail__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(emailMsges);
            }
         }
        //get the next workday
        DateTime createDate = System.now();
        HolidayCalculator holidayDates = new HolidayCalculator(createDate.date());
        DateTime targetDate = holidayDates.nextWorkDay(createDate);
        targetDate = targetDate.addDays(1);
        targetDate = holidayDates.nextWorkDay(targetDate);

        //012K00000008XjuIAE Manage Services, 012K00000008XjuIAE Part, 012A0000000OkbxIAC General, 012F0000000y9yCIAQ DPIC
        List<EmailMessage> emails = [select TextBody, FromAddress, FromName, Subject, ActivityId, CreatedDate, Parent.ContactId, Parent.Origin, Parent.RecordTypeId from EmailMessage where Incoming = true and ID in :Trigger.new];

        Map<ID,EmailMessage> taskIDs = new Map<ID,EmailMessage> ();
        for (EmailMessage e : emails) {
            if (e.Parent.RecordTypeId == CaseClass.DPIC_RT && e.ActivityId != null)
            taskIDs.put(e.ActivityId, e);
        }

        List<Task> tasksToUpdate = new List<Task> ();
        List<Task> relatedTasks = [Select ActivityDate From Task Where ID in :taskIDs.keySet()];
        for (Task t : relatedTasks) {
            EmailMessage e = taskIDs.get(t.ID);

            //If the Date that calls the method occurs after the compDate, the return value is negative.
            t.ActivityDate = targetDate.Date();
            t.Subject = '24hr Email Reply Required';
            tasksToUpdate.add(t);
        }
        try {
            if (tasksToUpdate.size() > 0)
            update tasksToUpdate;
        } catch(DMLException e) {
            taskIDs.get(e.getDmlId(0)).addError('Exception occured while updating Task related to the email message: ' + e.getMessage());
        }

        CaseClass.Email2Case_CreateAccountByEmailMessage(emails);

        
    }


    // Before Insert event
    public static void handleBeforeInsertEvent(List<EmailMessage> emailMsges) {

        Map<String,Schema.RecordTypeInfo> recorTypemap = Schema.Sobjecttype.Case.getRecordTypeInfosByName();
        List<Case> casesToUpsert = new List<Case> ();
        List<Case> parrentCases = new List<Case> ();
        Map<Id,EmailMessage> parrentCaseIds = new Map<Id,EmailMessage> ();
        Map<Id,EmailMessage> parentEmails = new Map<Id,EmailMessage> ();
        List<EmailMessage> eMsgToUpdate = new List<EmailMessage> ();
        String nissanQueueId;
        String infinityQueueId;
        Map<String, Case_Reopen_Settings__c> casReOpenMap = Case_Reopen_Settings__c.getAll();

        String nissanRecordTypeId = recorTypemap.get(Label.CA_Email_Nissan).getRecordTypeId();
        String infinityRecordTypeId = recorTypemap.get(Label.CA_Email_Infiniti).getRecordTypeId();
        String caSalesServiceRecordTypeId = recorTypemap.get(Label.CA_Sales_Service).getRecordTypeId();
        String t5RecordTypeId = recorTypemap.get(Label.T5).getRecordTypeId();
        String caRecordTypeId = recorTypemap.get(Label.CA).getRecordTypeId();



        for (QueueSObject queObj : Database.query('Select Queue.Name, QueueId, Id From QueueSobject where Queue.Name IN ' + Label.Queue_Name)) {
            if (queObj.Queue.Name == Label.CA_Email_Nissan) {
                nissanQueueId = queObj.QueueId;
            }
            if (queObj.Queue.Name == Label.CA_Email_Infiniti) {
                infinityQueueId = queObj.QueueId;
            }
        }

        for (EmailMessage e : emailMsges) {
            parrentCaseIds.put(e.ParentId, e);
        }

        parrentCases = [SELECT Id, OwnerId, CaseNumber, LastModifiedById, Owner.Name, LastModifiedBy.Name, Days_Closed__c, Subject,
                        RecordTypeId, RecordType.Name, Status, CA_CaseReopenCount__c, ContactId, AccountId, Make__c, Type
                        FROM Case WHERE Id IN :parrentCaseIds.keySet()];

        Case casobj;
        for (Case c : parrentCases) {
            if(casReOpenMap.containsKey(c.RecordType.Name)){
                if (c.Status.equalsIgnoreCase('Closed')) {
                    if(c.Days_Closed__c <= Integer.valueOf(casReOpenMap.get(c.RecordType.Name).Days_After_Reply__c)){
                        casobj = new Case(Id = c.Id, Status = 'Open', CA_CaseReopenCount__c = c.CA_CaseReopenCount__c + 1, RecordTypeId = caRecordTypeId, Follow_Up_Date__c = Date.today());
                        if (c.Type.equalsIgnoreCase(Label.CA_Email_Nissan)) {
                            casobj.RecordTypeId = nissanRecordTypeId;
                        }
                        if (c.Type.equalsIgnoreCase(Label.CA_Email_Infiniti)) {
                            casobj.RecordTypeId = infinityRecordTypeId;
                        }
                        if (c.Type.equalsIgnoreCase('Sales & Service')) {
                            casobj.RecordTypeId = caSalesServiceRecordTypeId;
                        }
                        if (c.Type.equalsIgnoreCase(Label.T5)) {
                            casobj.RecordTypeId = t5RecordTypeId;
                        }
                        
                        if(c.RecordType.Name.equalsIgnoreCase('CCC') || c.RecordType.Name.equalsIgnoreCase('IB Case') || c.RecordType.Name.equalsIgnoreCase('Lead Survey') || c.RecordType.Name.equalsIgnoreCase('Lease Loyalty')
                    		|| c.RecordType.Name.equalsIgnoreCase('Customer Connection Follow up') || c.RecordType.Name.equalsIgnoreCase('Sales & Service Record Type')){
                    		
                    		casobj.Subject = c.Subject != null && !c.Subject.contains('REOPEN') ? 'REOPEN '+c.Subject : c.Subject;
                    		casobj.Priority = 'High';
                    		casobj.RecordTypeId = c.RecordTypeId;	
                    	}
                    	if(casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c != null && casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c != ''){
                    		casobj.OwnerId = casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c;
                    	}
                        casesToUpsert.add(casobj);
                    }
                    else {
                    	if(casReOpenMap.get(c.RecordType.Name).Create_New_Post_Reply__c){
                        EmailMessage prevEmail = parrentCaseIds.get(c.Id);
                        System.debug('prevEmail::' + prevEmail);
                         casobj = new Case(Status = 'Open', ContactId = c.ContactId, AccountId = c.AccountId, ParentId = c.Id, Subject = prevEmail.Subject, Description = prevEmail.TextBody,
                                                   OwnerId = (c.Make__c != null && c.Make__c.ContainsIgnoreCase('NISSAN')) ? nissanQueueId : infinityQueueId);

						if(c.RecordType.name == 'CA Closed Case'){
							casobj.RecordtypeId = (c.Make__c != null && c.Make__c.ContainsIgnoreCase('NISSAN')) ? nissanRecordTypeId : infinityRecordTypeId;
						}else{
							casobj.RecordtypeId = c.RecordTypeId;
						}
						
						 
                        if(c.RecordType.Name.equalsIgnoreCase('CCC') || c.RecordType.Name.equalsIgnoreCase('IB Case') || c.RecordType.Name.equalsIgnoreCase('Lead Survey') || c.RecordType.Name.equalsIgnoreCase('Lease Loyalty')
                    		|| c.RecordType.Name.equalsIgnoreCase('Customer Connection Follow up') || c.RecordType.Name.equalsIgnoreCase('Sales & Service Record Type')){
                    		
                    		casobj.Subject = c.Subject != null && !c.Subject.contains('REOPEN') ? 'REOPEN '+c.Subject : c.Subject;
                    		casobj.Priority = 'High';	
                    	}
                    	
                    	if(casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c != null && casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c != ''){
                    		casobj.OwnerId = casReOpenMap.get(c.RecordType.Name).Case_OwnerId__c;
                    	}
						
						casesToUpsert.add(casobj);
						
                        parentEmails.put(prevEmail.ParentId, prevEmail);

                        //tasksToCreate.add(new Task(OwnerId = c.OwnerId, Subject = prevEmail.)) 
                    	}                   
                    }
                }
            }
        }

        if (casesToUpsert.size() > 0) {
            Database.upsert(casesToUpsert, false);
            System.debug('casesToUpsert::' + casesToUpsert);

            for (Case cas : casesToUpsert) {
                if (cas.ParentId != null && parentEmails.get(cas.ParentId) != null) {
                    if (cas.ParentId == parentEmails.get(cas.ParentId).ParentId) {
                        parentEmails.get(cas.ParentId).ParentId = cas.Id;
                    }
                }
            }

        }

    }
}