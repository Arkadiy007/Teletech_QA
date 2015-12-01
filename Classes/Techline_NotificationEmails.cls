/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class manages the email alerts that are sent when a Tech Line case is 
created.

Class:              Techline_NotificationEmails
Author:             Rohdenburg S.
Date:               01/17/2014
Version:            1.0
Last Updated:       06/23/2014
    * 01/17/2014  SR - Stubbed
    * 01/19/2014  SR - Implemented
    * 02/24/2014  SR - Renamed and cleaned up
    * 02/25/2014  SR - Modified the trigger conditions for Not3 and Not4
    * 02/26/2014  SR - Added the Notification History object tracking
    * 03/14/2014  SR - Fix for the Model Year
    * 03/21/2014  SR - New changes
    * 06/13/2014  SR - Changed the FROM address for the Confirmation emails
    * 06/16/2014  SR - Implemented 2 new notifications (Supervisor and Safety)
    * 06/23/2014  SR - Incremented the test coverage 
*/

public class Techline_NotificationEmails
{
    // -------- Constants --------
    private final String RECORD_TYPE_NOT_1 = 'Dealer/Heads Up Alert';
    private final String RECORD_TYPE_NOT_REPAIR = 'Days Down/Repair Attempts';
    private final String RECORD_TYPE_NOT_5 = 'Vehicle';
    private final String RECORD_TYPE_REGULAR = 'Regular Notification';
    private final String TEMPLATE_1 = 'Case_Creation';
    private final String TEMPLATE_2 = 'HEADS_UP';
    private final String TEMPLATE_3 = 'DTS_Notification';
    private final String TEMPLATE_4 = 'Days_Down_Repair_Attempts';
    private final String TEMPLATE_5 = 'Vehicle_Issue_500_miles';
    private final String TEMPLATE_FSSS = 'FSSS Notification';
    private final String TEMPLATE_SAFETY = 'Safety_Concern';
    private final String FSSS_EMAIL_ADDRESS = 'jackson.hisey@Nissan-Usa.com';
    private final String FQI_EMAIL_ADDRESS = 'FQITaskForce@nissan-usa.com';
    private final String DTS_EMAIL_ADDRESS = 'dtsfieldrequest@nissan-usa.com';
    private final String NOTIF_STATUS_NEW = 'NEW';
    private final String NOTIF_STATUS_SENT = 'SENT';
    private final String NOTIF_HEADS_UP = 'Heads up';
    private final String NOTIF_DTS = 'DTS Request';
    private final String NOTIF_SAFETY = 'Safety Concern';
    private final String FROM_ADDRESS_SFDC = 'techlinesfdc@nissan-usa.com';
    private final String FROM_ADDRESS_ID_SFDC = '0D2F00000004EWn'; //PROD
      
    // -------- Constructor --------
    public Techline_NotificationEmails(){
        caseComments = new List<CaseComment>();
    }

    // -------- Variables --------
    private ValidationUtility datacheck = new ValidationUtility();
  
    // -------- Properties --------
    public String notificationsSent {get; set;}
    private Techline_Alert__c techAlert {get; set;}
    private List<String> dealerEmails {get; set;}
    private List<String> headsupEmails {get; set;}
    private List<CaseComment> caseComments {get; set;}
  
    /*
    private Contact con {get; set;}
    //Workaround for sending the email template to a contact
    public Contact getTempContact() {
        if (con == null) {
            con = new Contact();
            con.FirstName = 'Auto-generated';
            con.LastName = 'Contact';
            con.Email = 'no-reply@organization.com';
            insert con;
        }
        return con;
    }*/
  
    // -------- Methods --------
    //It checks and sends all the Techline notifications
    public void sendTechLineEmails(Case techLineCase, Boolean isInserting,Boolean sendHeadsUp,Boolean sendDTS) {
        
        List<EmailTemplate> allEmailTemplates =  [Select DeveloperName, Id From EmailTemplate];
        Map<String,Id> templateIds = new Map<String,Id>();
        if (allEmailTemplates.size() > 0) {
            for (EmailTemplate e: allEmailTemplates) {
                templateIds.put(e.DeveloperName,e.Id);
            }
        }
        
        List<Techline_Notification_History__c> notifHistory = 
            retrieveNotificationHistory(techLineCase.Id);
    
        if (!checkNotificationSent(notifHistory, TEMPLATE_1) && isInserting) {
            sendNotification1(techLineCase,templateIds);
        }
    
      /*  if (!checkNotificationSent(notifHistory, TEMPLATE_2)) {
            sendNotification2(techLineCase);
        }
      */  
       // if (!checkNotificationSent(notifHistory, TEMPLATE_2)) {
       if (sendHeadsUp) {
            sendNotification2(techLineCase,templateIds);
       }
    
    
    
        /*if (!checkNotificationSent(notifHistory, TEMPLATE_3)) {
            sendNotification3(techLineCase,templateIds);
        }*/
    
    /* Requested to remove Days Down Repair notices
        if (!checkNotificationSent(notifHistory, TEMPLATE_4)) {
            sendNotification4(techLineCase);
        }
    */
    
        if (!checkNotificationSent(notifHistory, TEMPLATE_5)) {
            sendNotification5(techLineCase,templateIds);
        }
    
        if (!checkNotificationSent(notifHistory, TEMPLATE_FSSS)) {
            sendNotificationForFSSS(techLineCase,templateIds);
        }
        
        if (!checkNotificationSent(notifHistory, TEMPLATE_SAFETY)) {
            sendNotificationSafetyConcern(techLineCase,templateIds);
        }
        
        /*if (!checkNotificationSent(notifHistory, TEMPLATE_SUPERVISOR)) {
            sendNotificationSupervisorReview(techLineCase);
        }*/
        
        if (caseComments != null && caseComments.size() > 0) {
            insert caseComments;
        }
    
        /*// It deletes the Temp Contact
        if (con != null) {
            delete con;
        }*/
    }
    
    // It retrieve all the notifications that have been sent for each case
    private List<Techline_Notification_History__c> retrieveNotificationHistory(
        Id caseId) {
        List<Techline_Notification_History__c> history = [
            SELECT Notification__c
            FROM Techline_Notification_History__c
            WHERE Case__c = :caseId];
      
            return history;
    }
    
    // It checks if the notification has been already sent
    private Boolean checkNotificationSent(
        List<Techline_Notification_History__c> history, 
        String notificationName) {
    
        for (Techline_Notification_History__c notification : history) {
            if (notification.Notification__c == notificationName) {
                return true;
            }
        }
    
        return false;
    }
  
    // It sends the notification 1 for Techline Cases. It only save a history 
    // record, since the email is delayed by a workflow rule
    private void sendNotification1(Case techLineCase,Map<String,Id> templateidmap) {
        // If any of these checkboxes are checked, don't send the Notification 
        if (techLineCase.FFFS__c || techLineCase.Brakes__c || 
            techLineCase.Supervisor_Review__c || techLineCase.Steering__c || 
            techLineCase.Unintended_Acceleration__c || 
            techLineCase.Other_Concern__c ||
            techLineCase.SRS__c) {
            return;
        }
    
        Techline_Alert__c alert = retrieveTechlineAlert(
            techLineCase.DealerCode__c);
      
        if (alert != null && dealerEmails != null && dealerEmails.size() > 0) {
            //String templateId = getTemplateId(TEMPLATE_1);
            String templateId = templateidmap.get(TEMPLATE_1);
            
            if (templateId != null) {
                //sendTechlineEmail(dealerEmails, techLineCase.Id, templateId);
                saveHistory(techLineCase.Id, TEMPLATE_1, NOTIF_STATUS_NEW);
            }
        }
    }
  
    // It sends the notification 2 for Techline Cases
    private void sendNotification2(Case techLineCase,Map<String,Id> templateidmap) {
        if (!techLineCase.Critical_Status_Flag__c) {
            return;
        }
    
        Techline_Alert__c alert = retrieveTechlineAlert(
            techLineCase.DealerCode__c);
          
        if (alert != null && headsupEmails != null && 
            headsupEmails.size() > 0) {
            addEmailToList(headsupEmails, FROM_ADDRESS_SFDC);
            //String templateId = getTemplateId(TEMPLATE_2);
            String templateId = templateidmap.get(TEMPLATE_2);
            
            if (templateId != null) {
                sendTechlineEmail(headsupEmails, techLineCase.Id, templateId, 
                    null);
                saveHistory(techLineCase.Id, TEMPLATE_2, NOTIF_STATUS_SENT);
                addCaseComment(techLineCase.Id, NOTIF_HEADS_UP, headsupEmails);
            }
        }
    }
  
    // It sends the notification 3 for Techline Cases
    private void sendNotification3(Case techLineCase,Map<String,Id> templateidmap) {
        if (!techLineCase.DTS_Notification__c) {
            return;
        }
    
        Techline_Alert__c alert = retrieveTechlineAlert(
            techLineCase.DealerCode__c);
        
        if (alert != null && headsupEmails != null && 
            headsupEmails.size() > 0) {
            String templateId = templateidmap.get(TEMPLATE_3);
            //String templateId = getTemplateId(TEMPLATE_3);
            headsupEmails.add(DTS_EMAIL_ADDRESS);
            addEmailToList(headsupEmails, FROM_ADDRESS_SFDC);

            if (templateId != null) {
                sendTechlineEmail(headsupEmails, techLineCase.Id, templateId,
                    null);
                saveHistory(techLineCase.Id, TEMPLATE_3, NOTIF_STATUS_SENT);
                addCaseComment(techLineCase.Id, NOTIF_DTS, headsupEmails);
            }
        }
    }
  
    // It sends the notification 4 for Techline Cases
    private void sendNotification4(Case techLineCase) {
        // TODO: Cast attempts and ask >=2
        if (techLineCase.Calculated_Days_Down__c >= 5 || 
            techLineCase.Repair_Attempts__c == '2' ||
            techLineCase.Repair_Attempts__c == '3' ||
            techLineCase.Repair_Attempts__c == '4' ||
            techLineCase.Repair_Attempts__c == '5' ||
            techLineCase.Repair_Attempts__c == '6' ||
            techLineCase.Repair_Attempts__c == '7' ||
            techLineCase.Repair_Attempts__c == '8' ||
            techLineCase.Repair_Attempts__c == '9') {
        
            Techline_Alert__c alert = retrieveAlertDaysDownRepair();
            String templateId = getTemplateId(TEMPLATE_4);
                
            if (alert != null && templateId != null) {
                List<String> headsUpRepairedEmails = getHeadsUpEmails(alert);
                  
                if (headsUpRepairedEmails != null && 
                    headsUpRepairedEmails.size() >  1) {

                    sendTechlineEmail(headsUpRepairedEmails, techLineCase.Id, 
                        templateId, FROM_ADDRESS_ID_SFDC);
                    saveHistory(techLineCase.Id, TEMPLATE_4, 
                        NOTIF_STATUS_SENT);
                }
            }
        }
    }
      
    // It sends the notification 5 for Techline Cases
    private void sendNotification5(Case techLineCase,Map<String,Id> templateidmap) {
        if (techlineCase.Model_Line__c == null ||
            techlineCase.Model_Year__c == null ||
            techlineCase.Current_Mileage__c == null) {
            return;
        }
    
        if (existTechlineAlertNot5(techLineCase)) {
           //String templateId = getTemplateId(TEMPLATE_5);
           String templateId = templateidmap.get(TEMPLATE_5);
           
            if (templateId != null) {
                List<String> FQIlist = new List<String> {FQI_EMAIL_ADDRESS};
                sendTechlineEmail(FQIlist, techLineCase.Id, templateId, null);
                saveHistory(techLineCase.Id, TEMPLATE_5, NOTIF_STATUS_SENT);
            }
        }
    }
  
    //It sends the notification for FSSS
    public void sendNotificationForFSSS(Case techLineCase,Map<String,Id> templateidmap) {
        if (!techLineCase.FFFS__c) {
            return;
        }
    
        List<String> toEmails = new List<String>{FSSS_EMAIL_ADDRESS};
        //String templateId = getTemplateId(TEMPLATE_FSSS);
        String templateId = templateidmap.get(TEMPLATE_FSSS);
        
        if (templateId != null) {
            sendTechlineEmail(toEmails, techLineCase.Id, templateId, null);
            saveHistory(techLineCase.Id, TEMPLATE_FSSS, NOTIF_STATUS_SENT);
        }
    }
    
    //It sends the Safety Concern notification
    public void sendNotificationSafetyConcern(Case techLineCase,Map<String,Id> templateidmap) {
        if (!techLineCase.Safety_Concern__c) {
            return;
        }

        List<String> toEmails = retrieveRegularEmails(NOTIF_SAFETY);
        //String templateId = getTemplateId(TEMPLATE_SAFETY);
        String templateId = templateidmap.get(TEMPLATE_SAFETY);
        
        if (templateId != null && toEmails != null && toEmails.size() > 0) {
            sendTechlineEmail(toEmails, techLineCase.Id, templateId, null);
            saveHistory(techLineCase.Id, TEMPLATE_SAFETY, NOTIF_STATUS_SENT);
        }
    }
    
    /*//It sends the Supervisor Review notification
    public void sendNotificationSupervisorReview(Case techLineCase) {
        if (!techLineCase.Supervisor_Review__c) {
            return;
        }
    
        List<String> toEmails = retrieveRegularEmails(NOTIF_SUPERVISOR);
        String templateId = getTemplateId(TEMPLATE_SUPERVISOR);
        if (templateId != null && toEmails != null && toEmails.size() > 0) {
            sendTechlineEmail(toEmails, techLineCase.Id, templateId, null);
            saveHistory(techLineCase.Id, TEMPLATE_SUPERVISOR, 
                NOTIF_STATUS_SENT);
        }
    }*/
  
    // It retrieves the Techline Alert object searching by Dealer Code
    private Techline_Alert__c retrieveTechlineAlert(String dealerCode) {
        if (techAlert != null) {
            return techAlert;
        }
        
        if (dealerCode == null || dealerCode == '') {
            return null;
        }
        
        List<Techline_Alert__c> alert = [SELECT Id, Dealer_Email_1__c, 
            Dealer_Email_2__c, Dealer_Email_3__c, Dealer_Email_4__c, 
            Dealer_Email_5__c, Dealer_Email_6__c, Dealer_Email_7__c,
            Dealer_Email_8__c, Dealer_Email_9__c, Dealer_Email_10__c,
            Heads_Up_Email_1__c, Heads_Up_Email_2__c, Heads_Up_Email_3__c,
            Heads_Up_Email_4__c, Heads_Up_Email_5__c, Heads_Up_Email_6__c,
            Heads_Up_Email_7__c, Heads_Up_Email_8__c, Heads_Up_Email_9__c,
            Heads_Up_Email_10__c
            FROM Techline_Alert__c
            WHERE RecordType.Name = :RECORD_TYPE_NOT_1
            AND Dealer_Code__c = :dealerCode
            LIMIT 1];
          
        if (alert.size() > 0) {
            techAlert = alert[0];
            dealerEmails = getDealerEmails(techAlert);
            headsupEmails = getHeadsUpEmails(techAlert);
        }
        
        return techAlert;
    }
  
    // It retrieves the Techline Alert object for the Notification 3
    private Techline_Alert__c retrieveAlertDaysDownRepair() {
        List<Techline_Alert__c> alert = [SELECT 
            Heads_Up_Email_1__c, Heads_Up_Email_2__c, Heads_Up_Email_3__c,
            Heads_Up_Email_4__c, Heads_Up_Email_5__c, Heads_Up_Email_6__c,
            Heads_Up_Email_7__c, Heads_Up_Email_8__c, Heads_Up_Email_9__c,
            Heads_Up_Email_10__c
            FROM Techline_Alert__c
            WHERE RecordType.Name = :RECORD_TYPE_NOT_REPAIR
            LIMIT 1];
            
        if (alert.size() > 0) {
            return alert[0]; 
        }
        else {
            return null;
        }
    }
  
    // It checks if exist the Techline Alert object for the Notification 5
    private Boolean existTechlineAlertNot5(Case techlineCase) {
        Integer modelYear;
        if (techlineCase.Model_Year__c != null &&
            techlineCase.Model_Year__c.length() == 6) {
            modelYear = Integer.valueOf(
            techlineCase.Model_Year__c.substring(0,4)); 
        }
        else {
            modelYear = Integer.valueOf(techlineCase.Model_Year__c);
        }
    
        List<Techline_Alert__c> alert = [SELECT Id
            FROM Techline_Alert__c
            WHERE RecordType.Name = :RECORD_TYPE_NOT_5
            AND Make__c = :techlineCase.Make__c
            AND Model_Line__c = :techlineCase.Model_Line__c
            AND Model_Year__c = :modelYear
            AND Mileage__c >= :techlineCase.Current_Mileage__c
            LIMIT 1];
    
        return (alert.size() > 0);
    }
  
    // It retrieves the email addresses for a regular notification
    private List<String> retrieveRegularEmails(String alertName) {
        List<String> emailAddresses = new List<String>();
        
        List<Techline_Alert__c> alert = [SELECT To_Email__c, To_Email_2__c,
            To_Email_3__c, CC_1__c, CC_2__c, CC_3__c, CC_4__c, CC_5__c, 
            CC_6__c, CC_7__c, CC_8__c, CC_9__c, CC_10__c, CC_11__c, CC_12__c,
            CC_13__c, CC_14__c, CC_15__c
            FROM Techline_Alert__c
            WHERE RecordType.Name = :RECORD_TYPE_REGULAR
            AND Name = :alertName
            LIMIT 1];
      
        if (alert.size() > 0) {
            if (alert[0].To_Email__c != null && datacheck.IsEmailFormat(
                alert[0].To_Email__c)) {
                emailAddresses.Add(alert[0].To_Email__c);
            }
            
            if (alert[0].To_Email_2__c != null && datacheck.IsEmailFormat(
                alert[0].To_Email_2__c)) {
                emailAddresses.Add(alert[0].To_Email_2__c);
            }
            
            if (alert[0].To_Email_3__c != null && datacheck.IsEmailFormat(
                alert[0].To_Email_3__c)) {
                emailAddresses.Add(alert[0].To_Email_3__c);
            }
            
            if (alert[0].CC_1__c != null && datacheck.IsEmailFormat(
                alert[0].CC_1__c)) {
                emailAddresses.Add(alert[0].CC_1__c);
            }
            
            if (alert[0].CC_2__c != null && datacheck.IsEmailFormat(
                alert[0].CC_2__c)) {
                emailAddresses.Add(alert[0].CC_2__c);
            }
            
            if (alert[0].CC_3__c != null && datacheck.IsEmailFormat(
                alert[0].CC_3__c)) {
                emailAddresses.Add(alert[0].CC_3__c);
            }
            
            if (alert[0].CC_4__c != null && datacheck.IsEmailFormat(
                alert[0].CC_4__c)) {
                emailAddresses.Add(alert[0].CC_4__c);
            }
            
            if (alert[0].CC_5__c != null && datacheck.IsEmailFormat(
                alert[0].CC_5__c)) {
                emailAddresses.Add(alert[0].CC_5__c);
            }
            
            if (alert[0].CC_6__c != null && datacheck.IsEmailFormat(
                alert[0].CC_6__c)) {
                emailAddresses.Add(alert[0].CC_6__c);
            }
            
            if (alert[0].CC_7__c != null && datacheck.IsEmailFormat(
                alert[0].CC_7__c)) {
                emailAddresses.Add(alert[0].CC_7__c);
            }
            
            if (alert[0].CC_8__c != null && datacheck.IsEmailFormat(
                alert[0].CC_8__c)) {
                emailAddresses.Add(alert[0].CC_8__c);
            }
            
            if (alert[0].CC_9__c != null && datacheck.IsEmailFormat(
                alert[0].CC_9__c)) {
                emailAddresses.Add(alert[0].CC_9__c);
            }
            
            if (alert[0].CC_10__c != null && datacheck.IsEmailFormat(
                alert[0].CC_10__c)) {
                emailAddresses.Add(alert[0].CC_10__c);
            }
            
            if (alert[0].CC_11__c != null && datacheck.IsEmailFormat(
                alert[0].CC_11__c)) {
                emailAddresses.Add(alert[0].CC_11__c);
            }
            
            if (alert[0].CC_12__c != null && datacheck.IsEmailFormat(
                alert[0].CC_12__c)) {
                emailAddresses.Add(alert[0].CC_12__c);
            }
            
            if (alert[0].CC_13__c != null && datacheck.IsEmailFormat(
                alert[0].CC_13__c)) {
                emailAddresses.Add(alert[0].CC_13__c);
            }
            
            if (alert[0].CC_14__c != null && datacheck.IsEmailFormat(
                alert[0].CC_14__c)) {
                emailAddresses.Add(alert[0].CC_14__c);
            }
            
            if (alert[0].CC_15__c != null && datacheck.IsEmailFormat(
                alert[0].CC_15__c)) {
                emailAddresses.Add(alert[0].CC_15__c);
            }
        }
        
        return emailAddresses;
    }
  
    // It retrieves the email addesses from the Techline Alert object, and
    // creates a List of String with them
    private List<String> getDealerEmails(Techline_Alert__c alert) {
        List<String> dealerEmails = new List<String>();
    
        if (alert.Dealer_Email_1__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_1__c)) {
            dealerEmails.Add(alert.Dealer_Email_1__c);
        }

        if (alert.Dealer_Email_2__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_2__c)) {
            dealerEmails.Add(alert.Dealer_Email_2__c);
        }
    
        if (alert.Dealer_Email_3__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_3__c)) {
            dealerEmails.Add(alert.Dealer_Email_3__c);
        }
    
        if (alert.Dealer_Email_4__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_4__c)) {
            dealerEmails.Add(alert.Dealer_Email_4__c);
        }
    
        if (alert.Dealer_Email_5__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_5__c)) {
            dealerEmails.Add(alert.Dealer_Email_5__c);
        }
    
        if (alert.Dealer_Email_6__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_6__c)) {
            dealerEmails.Add(alert.Dealer_Email_6__c);
        }
    
        if (alert.Dealer_Email_7__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_7__c)) {
            dealerEmails.Add(alert.Dealer_Email_7__c);
        }
    
        if (alert.Dealer_Email_8__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_8__c)) {
            dealerEmails.Add(alert.Dealer_Email_8__c);
        }
    
        if (alert.Dealer_Email_9__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_9__c)) {
            dealerEmails.Add(alert.Dealer_Email_9__c);
        }
    
        if (alert.Dealer_Email_10__c != null && 
            datacheck.IsEmailFormat(alert.Dealer_Email_10__c)) {
            dealerEmails.Add(alert.Dealer_Email_10__c);
        }
    
        return dealerEmails;
    }
  
    // It retrieves the Heads Up email addesses from the Techline Alert 
    // object, and creates a List of String with them. It also includes
    // the agent's email
    private List<String> getHeadsUpEmails(Techline_Alert__c alert) {
        List<String> headsUpEmails = new List<String>();
        
        headsUpEmails.Add(UserInfo.getUserEmail());
        
        if (alert.Heads_Up_Email_1__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_1__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_1__c);
        }
        
        if (alert.Heads_Up_Email_2__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_2__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_2__c);
        }
        
        if (alert.Heads_Up_Email_3__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_3__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_3__c);
        }
        
        if (alert.Heads_Up_Email_4__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_4__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_4__c);
        }
        
        if (alert.Heads_Up_Email_5__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_5__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_5__c);
        }
        
        if (alert.Heads_Up_Email_6__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_6__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_6__c);
        }
        
        if (alert.Heads_Up_Email_7__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_7__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_7__c);
        }
        
        if (alert.Heads_Up_Email_8__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_8__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_8__c);
        }
        
        if (alert.Heads_Up_Email_9__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_9__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_9__c);
        }
        
        if (alert.Heads_Up_Email_10__c != null && 
            datacheck.IsEmailFormat(alert.Heads_Up_Email_10__c)) {
            headsUpEmails.Add(alert.Heads_Up_Email_10__c);
        }
        
        return headsUpEmails;
      }
  
    // It retrieves the Template Id searching by Name
    public String getTemplateId(String templateName) {
        List<EmailTemplate> emailTemplate = [SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1];
    
        if (emailTemplate.size() > 0) {
            return emailTemplate[0].Id;
        }
        else {
            return null;
        }
    }
  
    // It sends the email
    public void sendTechlineEmail(List<String> toAddresses, Id caseId, 
        Id templateId, String fromAddresId) {
        //-----------------------------------------------------------------
        if (System.Label.Send_Techline_Alert != 'Yes') {
            toAddresses.Clear();
            toAddresses.Add('wrmtyr@gmail.com');
            toAddresses.Add('digeshshah@teletech.com');
            toAddresses.Add('vivek_batham@teletech.com');
        }
        //-----------------------------------------------------------------
        
        //Taking 1 address from the List, and set it to the contact in order 
        //to fill the To field in the email
        Contact c;
       
        if (Test.isRunningTest()) {
            c = [select Email FROM Contact WHERE FirstName='Auto-generated' LIMIT 1];
        } else {
            c = [SELECT Email FROM Contact 
            WHERE Id = :System.Label.TECH_LINE_Notification_Contact_Id];
        }
        c.Email = toAddresses[0];
        update c;
        toAddresses.Remove(0);
        
        //Send the email        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (!datacheck.IsStringNullOrEmpty(fromAddresId)) {
            mail.setOrgWideEmailAddressId(fromAddresId);
        }
        mail.setCcAddresses(toAddresses);
        mail.setTargetObjectId(System.Label.TECH_LINE_Notification_Contact_Id);
        mail.setWhatId(caseId);
        mail.setTemplateId(templateId);
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  
    // It saves a log of the sent notificationsin
    private void saveHistory(Id caseId, String templateName, String status) {
        Techline_Notification_History__c history = 
            new Techline_Notification_History__c();
    
        history.Case__c = caseId;
        history.Notification__c = templateName;
        history.Status__c = status;
        insert history;
    }
    
    // It sends the confirmation email. This method is called from a trigger
    // 1 hour later than the moment when the history record was saved
    public Boolean sendConfirmationEmail(Id caseId) {
        Boolean result;
        try {
            Case techLineCase = [SELECT Id, DealerCode__c
                FROM Case
                WHERE Id = :caseId];
            
            Techline_Alert__c alert = retrieveTechlineAlert(
                techLineCase.DealerCode__c);
          
            if (alert != null && dealerEmails != null && 
                dealerEmails.size() > 0) {
                String templateId = getTemplateId(TEMPLATE_1);
                if (templateId != null) {
                    sendTechlineEmail(dealerEmails, techLineCase.Id, 
                        templateId, FROM_ADDRESS_ID_SFDC);
                }
            }
            
            result = true;
        }
        catch (Exception ex) {
            result = false;
        }
        
        /*// It deletes the Temp Contact
        if (con != null) {
            delete con;
        }*/
        
        return result;
    }
    
    //It saves a case comment confirming that the notification has been sent
    private void addCaseComment(Id caseId, String notificationName, 
        List<String> toAddresses) {
        String commentBody = '';
        commentBody += notificationName;
        commentBody += ' sent on ';
        commentBody += String.valueOf(DateTime.now());
        commentBody += ' to ';
        
        for (String emailAddress : toAddresses) {
            commentBody += emailAddress + ', ';
        } 
        commentBody = commentBody.substring(0, commentBody.length() - 2);
        
        CaseComment cc = new CaseComment();
        cc.ParentId = caseId;
        cc.CommentBody = commentBody;
        caseComments.add(cc);
    }
    
    //It checks if a list contains a specific value, and add it in case of not
    private void addEmailToList(List<String> headsUpEmails, String newEmail) {
        if (headsUpEmails != null) {
            for (String emailValue : headsUpEmails) {
                if (emailValue == newEmail) {
                    return;
                }
            }
            headsUpEmails.add(newEmail);    
        }
    }
  
    // -------- Test --------
    static testMethod void ClassTest()
    {
    
    
        Contact con = new Contact();
        con.FirstName = 'Auto-generated';
        con.LastName = 'Contact';
        con.Email = 'no-reply@organization.com';
        insert con;
            
        Account dealer = new Account();
        dealer.RecordTypeId = '012A0000000OfI0';
        dealer.Name = 'TestDealer';
        dealer.Dealer_Code__c = '1234';
        insert dealer;
    
        Vehicle__c veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Versa';
        veh.Make_Name__c = 'Nissan';
        insert veh;
        
    
    
        Case techlineCase = new Case();
        techlineCase.Issue_Type__c = 'Full';
        techLineCase.Dealer__c = dealer.Id;
        techLineCase.Critical_Status_Flag__c = true;
        techLineCase.DTS_Notification__c = true;
        techLineCase.Repair_Attempts__c = '2';
        techLineCase.Vehicle_Name__c = veh.Id;
        techLineCase.Current_Mileage__c = 10;
        insert techLineCase;
    
        Case techlineCaseFFFS = new Case();
        techlineCaseFFFS.Issue_Type__c = 'Full';
        techlineCaseFFFS.Dealer__c = dealer.Id;
        techlineCaseFFFS.FFFS__c = true;
        techlineCaseFFFS.Safety_Concern__c = true;
        insert techlineCaseFFFS;
    
        techLineCase = [SELECT Id, DealerCode__c, FFFS__c, Brakes__c,
            Supervisor_Review__c, Steering__c, Unintended_Acceleration__c,
            Other_Concern__c, SRS__c, Critical_Status_Flag__c, 
            DTS_Notification__c, Calculated_Days_Down__c, Repair_Attempts__c,
            Make__c, Model_Line__c, Model_Year__c, Current_Mileage__c, 
            Safety_Concern__c
            FROM Case
            WHERE Id = :techLineCase.Id];
      
        techlineCaseFFFS = [SELECT Id, DealerCode__c, FFFS__c, Brakes__c,
            Supervisor_Review__c, Steering__c, Unintended_Acceleration__c,
            Other_Concern__c, SRS__c, Critical_Status_Flag__c, 
            DTS_Notification__c, Calculated_Days_Down__c, Repair_Attempts__c,
            Make__c, Model_Line__c, Model_Year__c, Current_Mileage__c,
            Safety_Concern__c
            FROM Case
            WHERE Id = :techlineCaseFFFS.Id];
      
        Techline_Alert__c alert = new Techline_Alert__c();
        alert.RecordTypeId = 
        Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
            ).get('Dealer/Heads Up Alert').getRecordTypeId();
        alert.Dealer_Code__c = '1234';
        alert.Dealer_Email_1__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_1__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_2__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_2__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_3__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_3__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_4__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_4__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_5__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_5__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_6__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_6__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_7__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_7__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_8__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_8__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_9__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_9__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_10__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_10__c = 'wrmtyr@gmail.com';
        insert alert;
    
        Techline_Alert__c alertDaysDown = new Techline_Alert__c();
        alertDaysDown.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Days Down/Repair Attempts').getRecordTypeId();
        alertDaysDown.Heads_Up_Email_1__c = 'wrmtyr@gmail.com';
        insert alertDaysDown;
    
        Techline_Alert__c alertVehicle = new Techline_Alert__c();
        alertVehicle.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Vehicle').getRecordTypeId();
        alertVehicle.Make__c = 'Nissan';
        alertVehicle.Model_Line__c = 'Versa';
        alertVehicle.Model_Year__c = 2014;
        alertVehicle.Mileage__c = 500;
        insert alertVehicle;
        
        Techline_Alert__c alertSafetyConcern = new Techline_Alert__c();
        alertSafetyConcern.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Regular Notification').getRecordTypeId();
        alertSafetyConcern.Name = 'Safety Concern';
        alertSafetyConcern.To_Email__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.To_Email_2__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.To_Email_3__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_1__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_2__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_3__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_4__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_5__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_6__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_7__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_8__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_9__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_10__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_11__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_12__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_13__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_14__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_15__c = 'wrmtyr@gmail.com';
        insert alertSafetyConcern;
    
        Techline_NotificationEmails tne = new 
            Techline_NotificationEmails();
        tne.sendTechLineEmails(techLineCase, true,true,true);
        
        Techline_NotificationEmails tneFFFS = new 
            Techline_NotificationEmails();
        tneFFFS.sendTechLineEmails(techlineCaseFFFS, false,false,false);    
    }
}