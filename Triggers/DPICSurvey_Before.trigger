trigger DPICSurvey_Before on DPICSurvey__c (before update) {
 /*
 6. Case reopen trigger = “How many of your issues did the DPIC rep at Nissan resolve”
a.  Reopen if “ None of them” selected
7.  Send Reopened cases to a new case queue called “DPIC Survey Responses”
8.  Create new DPIC case queue “DPIC Survey Responses”
9.  Email team when a case is assigned to this new queue
*/

 if (UserInfo.getName() != 'Managed Services') {  // exclude managed services
 
 Set<ID> casesToReopen = new Set<ID>();
 for (Integer i = 0; i < Trigger.new.size(); i++) {
   
   if (Trigger.new[i].SurveyResponseDateTime__c == null) {
       Trigger.new[i].SurveyResponseDateTime__c = System.now();
   }
   
   if (Trigger.new[i].Indicated_Issues_Resolved__c == '1' && Trigger.old[i].Indicated_Issues_Resolved__c != '1') {
      //if (Trigger.new[i].RecordTypeid==dpicIdList[0].Id && Trigger.new[i].Origin == 'Email to Case') {
     //  // send survey
     //   closedCaseIDs.add(Trigger.new[i].id);
     // }
     
      //sendMSG('running the checker...');
     casesToReopen.add(Trigger.new[i].SFDC_Case_Id__c);
     
     System.debug('running checker...');
 
   }
 }
   List<Case> casesToUpdate = new List<Case>();
          
   if (casesToReopen.size() > 0) {
        Id reopenQueue;
        List<Group> queuelist = [select Id from Group where Name = 'DPIC Survey Responses' and Type = 'Queue' limit 1];
 
        if (queuelist.size() > 0) {
            reopenQueue = queuelist[0].id;
        }
        
        casesToUpdate = [Select id,status,ownerid,casenumber from case where id in :casesToReopen];
        if (casesToUpdate.size() > 0 ) {
            for (Case cc : casesToUpdate) {
                cc.Status = 'Open';
                try {
                    sendMSG(cc.casenumber,cc.id);
                } catch (Exception e) {
                    System.debug('error ' + e.getMessage());
                }
                
               if (reopenQueue != null ) {
                 cc.OwnerId = reopenQueue;
               }
               
            }
               Database.SaveResult[] dbResults = Database.update(casesToUpdate, false);
        }
   
    
   
   
 }  
 }
 
    void sendMSG(String caseNumber,String caseId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'briankirsh@teletech.com', 'thomasruth@teletech.com' ,'matthew.hall@nissan-usa.com'};  //
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('DPIC Survey case reopened - 0 issues resolved (' + caseNumber + ')');

        String caseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseId;
        String caseLink = '<a href=\'' + caseUrl + '\' >'+ caseNumber + '</a>';
        
        mail.setHTMLBody('The case ' + caseLink + ' has been reopened due to no issues resolved and escalated for resolution.' );
        mail.setPlainTextBody('The case ' + caseNumber + ' has been reopened due to no issues resolved and escalated for resolution.' );
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
               
    }
 
 
}