/**********************************************************************
Name: Batch_VCS_Alert_Email
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class sends emails for VCS Alert cases that meet
the criteria.
Rules:
Any open case where dealer disposition is blank or TCU = 0
      Email after 7 days once from case open. Set flag so this is only done once.
Any open case where TCU = 0
      Email every 14 days from open
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     11/22/2013 Created
***********************************************************************/
//Batch_VCS_Alert_Email batch = new Batch_VCS_Alert_Email();
//Database.executeBatch(batch);
global class Batch_VCS_Alert_Email implements Database.Batchable<sObject> {
    global String queryBase = 'Select Id, Customer_Declined__c, CreatedDate, TCU_Activation_Status__c, Email_Reminder_Sent__c, ' +
                                     'Servicing_Dealer__r.Sales_Manager__c, Servicing_Dealer__r.Sales_Manager__r.Email, Make__c, Subject ' +
                              'From Case c ' +
                              'Where IsClosed = false ' +
                              'and RecordTypeId = \'012F0000000yH3M\' ' +
                              'and (TCU_Activation_Status__c = true or Customer_Declined__c = null)';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = queryBase;

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases) {
        String ownerId;
        List<Case> casesToUpdate = new List<Case>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Date createdDate;
        Date today = System.today();
        Integer days;
        String url = null;
        Id salesManagerId = null;
        Messaging.SingleEmailMessage emailMessage = null;
        String nissanInfiniti = null;
        Account dealer = null;


        for (Case c : cases) {
            if (c.Servicing_Dealer__r.Sales_Manager__c != null && c.Servicing_Dealer__r.Sales_Manager__r.Email != null) {
                salesManagerId = c.Servicing_Dealer__r.Sales_Manager__c;
                createdDate = Date.valueOf(c.createdDate);
                days = createdDate.daysBetween(today);
                
                if (days >= 7 && 
                      (c.Customer_Declined__c == null || c.TCU_Activation_Status__c == false) &&
                      c.Email_Reminder_Sent__c == false) {
                    // Construct 7-day email reminder
                    c.Email_Reminder_Sent__c = true;
                    casesToUpdate.add(c);

                    // Construct 7-day email reminder
                    emailMessage = new Messaging.SingleEmailMessage();
                    url = getPortalURL(c.Make__c);
                    emailMessage.setSenderDisplayName('Enrollment Alert');
                    emailMessage.setTargetObjectId(salesManagerId);
                    emailMessage.setSaveAsActivity(false);
                    emailMessage.setReplyTo(System.Label.Support_Reply_To_Email);
                    emailMessage.setSubject('Reminder Enrollment Alert ' + c.Subject);
                    emailMessage.setPlainTextBody(getSevenDayEmailBody(c, url));
                    
                    emailMessages.add(emailMessage);
                    
                } else if (Math.mod(days, 14) == 0 && c.TCU_Activation_Status__c == false) {
                    // Construct every 14th day email reminder
                    emailMessage = new Messaging.SingleEmailMessage();
                    url = getPortalURL(c.Make__c);
                    emailMessage.setSenderDisplayName('Enrollment Alert');
                    emailMessage.setTargetObjectId(salesManagerId);
                    emailMessage.setSaveAsActivity(false);
                    emailMessage.setReplyTo(System.Label.Support_Reply_To_Email);            
                    emailMessage.setSubject('Reminder Enrollment Alert ' + c.Subject);
                    emailMessage.setPlainTextBody(getFourteenDayEmailBody(c, url));

                    emailMessages.add(emailMessage);
                }
            }
        }
        
        // Send emails
        if (!Test.isRunningTest() && !emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
        
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (!casesToUpdate.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(casesToUpdate, false);
            for (integer row = 0; row < casesToUpdate.size(); row++) {
                if (!dbResults[row].isSuccess()) {
                    Database.Error err = dbResults[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = casesToUpdate[row].Id,
                                Record_Type__c = 'Case',
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_VCS_Alert_Email',
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                }
            }
        }

        // Log errors
        if (!errors.isEmpty())
            Database.SaveResult[] dbResults = Database.insert(errors, false);
    }

    private String getPortalURL (String make) {
        String nissanInfiniti = 'Nissan';
        String url;
        if (make != null && make == 'Infiniti') {
            nissanInfiniti = 'Infiniti';
        }
        if (System.URL.getSalesforceBaseUrl().getHost().left(2).equalsIgnoreCase('cs')) {
            if (nissanInfiniti == 'Infiniti') {
                url = System.label.InfinitiRetailerPortalQA;
            } else {
                url = System.label.NissanDealerPortalQA;
            }
        } else {
            if (nissanInfiniti == 'Infiniti') {
                url = System.label.InfinitiRetailerPortalProd;
            } else {
                url = System.label.NissanDealerPortalProd;
            }
        }
        
        return url;
    }

    private String getSevenDayEmailBody(Case c, String url) {
        String emailBody = 'Our records show that there is still an open Enrollment Alert for this VIN.  Please click the link below to review ' +
                           'the Case and take appropriate action: ' + url + '?caseId=' + c.Id;
        
        return emailBody;
    }

    private String getFourteenDayEmailBody(Case c, String url) {
        String emailBody = 'Our records show that this VIN still has a Telematics Communications Unit (TCU) that has not been ' +
                           'activated.  Please click the link below to review the Case and take appropriate action: ' + url + '?caseId=' + c.Id;
        
        return emailBody;
    }

    global void finish(Database.BatchableContext BC){
    }
}