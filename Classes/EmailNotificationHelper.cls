public without sharing class EmailNotificationHelper {

  private static List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
    
  public static Id currentOwnerId {get; set;}
  public static final String currentUserName;
  public static final String currentUserType;
  public static final Boolean isPortalUser;

  //------------
  private static Map<Id, Boolean> disableAutomatedSharingMap = new Map<Id, Boolean>();
  
  public static void disabledAutoSharing(SObject so) {
    disableAutomatedSharingMap.put(
      (Id) so.get('Id'),
      true
    );
  }

  public static void enableAutoSharing(SObject so) {
    disableAutomatedSharingMap.put(
      (Id) so.get('Id'),
      false
    );
  }
  //-------------

  static {
    User u = [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name,  Contact.Name FROM User WHERE Id = :UserInfo.getUserId()];

    if (null != u.Contact.Name) {
      currentUserName = u.Contact.Name;
    } else {
      currentUserName = u.Name;
    }

    currentUserType = getUserType(u.Profile.Name);
    isPortalUser = (u.Profile.UserLicense.Name == 'Gold Partner');
  }

    /**
      *
      *
      *
      *  PIR Notification
      *
      *
      *
      */

    public static void sendNotifications(Map<Id, Part_Incident_Report__c> newMap, Map<Id, Part_Incident_Report__c> oldMap){
        List<Part_Incident_Report__c> pirThatAreRequireSending = getAllPIRsThatAreRequireSending(newMap);

        if (pirThatAreRequireSending.size() > 0){
            // for EQA full license 
            if (!isPortalUser && (currentUserType == 'EQA')) {
              // retrieve all owners from pirs
              List<Id> ownerIdsList = new List<Id>();
              for (Part_Incident_Report__c pir : pirThatAreRequireSending) {
                ownerIdsList.add(pir.ownerId);
              }

              Map<Id, User> usersMap = new Map<Id, User>(
                      [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name, Contact.Name 
                         FROM User 
                        WHERE Id IN :ownerIdsList]);

              for (Part_Incident_Report__c pir : pirThatAreRequireSending) {
                pir.Save_And_Send_Flag__c = false;
                User u = usersMap.get(pir.OwnerId);
                if (null != u) {
                  String newCurrentOwner = getUserType(u.Profile.Name);
                  if ('Customer' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Customer', 'Customer');
                    pir.Current_Owner__c = 'Customer';
                  } else if ('Supplier' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Supplier', 'Supplier');
                    pir.Current_Owner__c = 'Supplier';
                  } else if ('EQA' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(pir, 'PIR Notification For EQA', 'EQA');
                    pir.Current_Owner__c = 'EQA';
                  }
                }
              }
            } else {
              for (Part_Incident_Report__c pir : pirThatAreRequireSending){
                  if (pir.Last_Modified_By_Supplier__c >= pir.Last_Modified_By_Customer__c || (pir.Last_Modified_By_Customer__c == null && pir.Last_Modified_By_Supplier__c != null)){ 
                      EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Customer', 'Customer');
                      pir.Current_Owner__c = 'Customer';
                      pir.Save_And_Send_Flag__c = false;
                      if(currentOwnerId != null){
                          pir.OwnerId = currentOwnerId;
                      }
                  }
                  else if(pir.Last_Modified_By_Supplier__c <= pir.Last_Modified_By_Customer__c || (pir.Last_Modified_By_Supplier__c == null && pir.Last_Modified_By_Customer__c != null)){
                      EmailNotificationHelper.sendNotification(pir, 'PIR Notification For Supplier', 'Supplier');
                      pir.Current_Owner__c = 'Supplier';    
                      pir.Save_And_Send_Flag__c = false;
                      if(currentOwnerId != null){
                          pir.OwnerId = currentOwnerId;
                      }
                  }
              }
            }
        }
    }

    public static void populateLastModifiedFields(Map<Id, Part_Incident_Report__c> newMap, Map<Id, Part_Incident_Report__c> oldMap){
        Set<String> customerFieldAPINames = getCustomerFieldSetAPINames(newMap.values()[0]);
        Set<String> supplierFieldAPINames = getSupplierFieldSetAPINames(newMap.values()[0]);

        for (Part_Incident_Report__c pir : newMap.values()){
            if (fieldsAreChanged(supplierFieldAPINames, pir, oldMap.get(pir.id))){  
                pir.Last_Modified_By_Supplier__c = System.now();
            }
            else if(fieldsAreChanged(customerFieldAPINames, pir, oldMap.get(pir.id))){
                pir.Last_Modified_By_Customer__c = System.now();
            }
        }
    }

    private static List<Part_Incident_Report__c> getAllPIRsThatAreRequireSending(Map<Id, Part_Incident_Report__c> newMap){
        List<Part_Incident_Report__c> pirThatAreRequireSending = new List<Part_Incident_Report__c>();
        for (Part_Incident_Report__c pir : newMap.values()){
            if (true != disableAutomatedSharingMap.get(pir.Id)){
                pirThatAreRequireSending.add(pir);
            }
        }

        return pirThatAreRequireSending;
    }


        
    /**
      *
      *
      *
      *  MC Notification
      *
      *
      *
      */

    public static void sendNotifications(Map<Id, Monetary_Claim__c> newMap, Map<Id, Monetary_Claim__c> oldMap){

 
        List<Monetary_Claim__c> mcThatAreRequireSending = getAllMCsThatAreRequireSending(newMap);


        if (mcThatAreRequireSending.size() > 0){
            // for EQA full license 
            if (!isPortalUser && (currentUserType == 'EQA')) {
              // retrieve all owners from pirs
              List<Id> ownerIdsList = new List<Id>();
              for (Monetary_Claim__c mc : mcThatAreRequireSending) {
                ownerIdsList.add(mc.ownerId);
              }

              Map<Id, User> usersMap = new Map<Id, User>(
                      [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name, Contact.Name 
                         FROM User 
                        WHERE Id IN :ownerIdsList]);

              for (Monetary_Claim__c mc : mcThatAreRequireSending) {
                mc.Save_And_Send_Flag__c = false;
                User u = usersMap.get(mc.OwnerId);
                if (null != u) {
                  String newCurrentOwner = getUserType(u.Profile.Name);
                  if ('Customer' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For Customer', 'Customer');
                    mc.Current_Owner__c = 'Customer';
                  } else if ('Supplier' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For Supplier', 'Supplier');
                    mc.Current_Owner__c = 'Supplier';
                  } else if ('EQA' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For EQA', 'EQA');
                    mc.Current_Owner__c = 'EQA';
                  }
                }
              }
            } else {
              for (Monetary_Claim__c mc : mcThatAreRequireSending){
                  if (mc.Last_Modified_By_Supplier__c > mc.Last_Modified_By_Customer__c || (mc.Last_Modified_By_Customer__c == null && mc.Last_Modified_By_Supplier__c != null)){ 
                      EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For Customer', 'Customer');             
                      mc.Current_Owner__c = 'Customer';
                      mc.Save_And_Send_Flag__c = false; 
                      if(currentOwnerId != null){
                          mc.OwnerId = currentOwnerId;
                      }
                  }
                  else if(mc.Last_Modified_By_Supplier__c < mc.Last_Modified_By_Customer__c || (mc.Last_Modified_By_Supplier__c == null && mc.Last_Modified_By_Customer__c != null)){
                      EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For Supplier', 'Supplier');
                      mc.Current_Owner__c = 'Supplier';
                      mc.Save_And_Send_Flag__c = false; 
                      if(currentOwnerId != null){
                          mc.OwnerId = currentOwnerId;
                      }     
                  }
              }
            }
        }
    }

    public static void populateLastModifiedFields(Map<Id, Monetary_Claim__c> newMap, Map<Id, Monetary_Claim__c> oldMap){
        Set<String> customerFieldAPINames = getCustomerFieldSetAPINames(newMap.values()[0]);
        Set<String> supplierFieldAPINames = getSupplierFieldSetAPINames(newMap.values()[0]);

        for (Monetary_Claim__c mc : newMap.values()){
            if (fieldsAreChanged(supplierFieldAPINames, mc, oldMap.get(mc.id))){    
                mc.Last_Modified_By_Supplier__c = System.now();
            }
            else if(fieldsAreChanged(customerFieldAPINames, mc, oldMap.get(mc.id))){
                mc.Last_Modified_By_Customer__c = System.now();
            }
        }
    }



    private static List<Monetary_Claim__c> getAllMCsThatAreRequireSending(Map<Id, Monetary_Claim__c> newMap){
        List<Monetary_Claim__c> mcThatAreRequireSending = new List<Monetary_Claim__c>();

        for (Monetary_Claim__c mc : newMap.values()){
            if (true != disableAutomatedSharingMap.get(mc.Id)){
                mcThatAreRequireSending.add(mc);
            }
        }

        return mcThatAreRequireSending;
    }

    /**
      *
      *
      *
      *  SR Notification
      *
      *
      *
      */

    public static void sendNotifications(Map<Id, Sorting_Report__c> newMap, Map<Id, Sorting_Report__c> oldMap){
        List<Sorting_Report__c> srThatAreRequireSending = getAllSRsThatAreRequireSending(newMap);

        if (srThatAreRequireSending.size() > 0){
            // for EQA full license 
            if (!isPortalUser && (currentUserType == 'EQA')) {
              // retrieve all owners from pirs
              List<Id> ownerIdsList = new List<Id>();
              for (Sorting_Report__c sr : srThatAreRequireSending) {
                ownerIdsList.add(sr.ownerId);
              }

              Map<Id, User> usersMap = new Map<Id, User>(
                      [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name, Contact.Name 
                         FROM User 
                        WHERE Id IN :ownerIdsList]);

              for (Sorting_Report__c sr : srThatAreRequireSending) {
                sr.Save_And_Send_Flag__c = false;
                User u = usersMap.get(sr.OwnerId);
                if (null != u) {
                  String newCurrentOwner = getUserType(u.Profile.Name);
                  if ('Customer' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For Customer', 'Customer');
                    sr.Current_Owner__c = 'Customer';
                  } else if ('Supplier' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For Supplier', 'Supplier');
                    sr.Current_Owner__c = 'Supplier';
                  } else if ('EQA' == newCurrentOwner) {
                    EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For EQA', 'EQA');
                    sr.Current_Owner__c = 'EQA';
                  }
                }
              }
            } else {
              for (Sorting_Report__c sr : srThatAreRequireSending){
                  if (sr.Last_Modified_By_Supplier__c > sr.Last_Modified_By_Customer__c || (sr.Last_Modified_By_Customer__c == null && sr.Last_Modified_By_Supplier__c != null)){ 
                      EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For Customer', 'Customer');
                      sr.Current_Owner__c = 'Customer';
                      sr.Save_And_Send_Flag__c = false;
                      if(currentOwnerId != null){
                          sr.OwnerId = currentOwnerId;
                      }
                  }
                  else if(sr.Last_Modified_By_Supplier__c < sr.Last_Modified_By_Customer__c || (sr.Last_Modified_By_Supplier__c == null && sr.Last_Modified_By_Customer__c != null)){
                      EmailNotificationHelper.sendNotification(sr, 'Sorting Report Notification For Supplier', 'Supplier');
                      sr.Current_Owner__c = 'Supplier';
                      sr.Save_And_Send_Flag__c = false;
                      if(currentOwnerId != null){
                          sr.OwnerId = currentOwnerId;
                      }     
                  }
              }
            }
        }
    }

    public static void populateLastModifiedFields(Map<Id, Sorting_Report__c> newMap, Map<Id, Sorting_Report__c> oldMap){
        
        Set<String> customerFieldAPINames = getCustomerFieldSetAPINames(newMap.values()[0]);
        Set<String> supplierFieldAPINames = getSupplierFieldSetAPINames(newMap.values()[0]);

        for (Sorting_Report__c sr : newMap.values()){
            if (fieldsAreChanged(supplierFieldAPINames, sr, oldMap.get(sr.id))){    
                sr.Last_Modified_By_Supplier__c = System.now();
            }
            else if(fieldsAreChanged(customerFieldAPINames, sr, oldMap.get(sr.id))){
                sr.Last_Modified_By_Customer__c = System.now();
            }
        }

    }

    private static List<Sorting_Report__c> getAllSRsThatAreRequireSending(Map<Id, Sorting_Report__c> newMap){
        List<Sorting_Report__c> srThatAreRequireSending = new List<Sorting_Report__c>();
        for (Sorting_Report__c sr : newMap.values()){
            if (true != disableAutomatedSharingMap.get(sr.Id)){
                srThatAreRequireSending.add(sr);
            }
        }

        return srThatAreRequireSending;
    }

    private static Boolean fieldsAreChanged(Set<String> fieldApiNames, sObject newObject, sObject oldObject){
        for (String fieldAPIName : fieldApiNames){
            if (newObject.get(fieldAPIName) != oldObject.get(fieldAPIName)){
                return true;
            }
        }
        return false;
    }

    private static Set<String> getCustomerFieldSetAPINames(sObject reportObject){
        Set<String> customerFieldAPINames = new Set<String>();
        
        if (reportObject.getSObjectType() == Part_Incident_Report__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Part_Incident_Report__c.FieldSets.Customer_Information.getFields()) {
                    customerFieldAPINames.add(fieldMember.getFieldPath());
                }
        }

        if (reportObject.getSObjectType() == Sorting_Report__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Sorting_Report__c.FieldSets.Customer_Information.getFields()) {
                    customerFieldAPINames.add(fieldMember.getFieldPath());
                }
        }


        if (reportObject.getSObjectType() == Monetary_Claim__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Monetary_Claim__c.FieldSets.Customer_Information.getFields()) {
                    customerFieldAPINames.add(fieldMember.getFieldPath());
                }
        }

        return customerFieldAPINames;
    }

    private static Set<String> getSupplierFieldSetAPINames(sObject reportObject){
        Set<String> supplierFieldAPINames = new Set<String>();
        
        if (reportObject.getSObjectType() == Part_Incident_Report__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Part_Incident_Report__c.FieldSets.Supplier_Information.getFields()) {
                    supplierFieldAPINames.add(fieldMember.getFieldPath());
                }
        }

         if (reportObject.getSObjectType() == Sorting_Report__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Sorting_Report__c.FieldSets.Supplier_Information.getFields()) {
                    supplierFieldAPINames.add(fieldMember.getFieldPath());
                }
        }

        if (reportObject.getSObjectType() == Monetary_Claim__c.sObjectType){
            for (Schema.FieldSetMember fieldMember : SObjectType.Monetary_Claim__c.FieldSets.Supplier_Information.getFields()) {
                    supplierFieldAPINames.add(fieldMember.getFieldPath());
                }
        }

        return supplierFieldAPINames;
    }

    public static void sendNotification(Sorting_Report__c sr, String reportName, String userType){
        List<Contact> receivers = new List<Contact>();
        if (userType == 'Customer') {
            receivers = getCustomersForSR(sr);
        }
        else if (userType == 'Supplier') {
            receivers = getSuppliersForSR(sr);
        }
        
        if (receivers.isEmpty()) {
          receivers = getEQAContacts();
          userType = 'EQA';
        }

        EmailTemplate emailTemplate = getEmailTemplateId(reportName);
        if (receivers.size() > 0 && emailTemplate != null) {
            // grab sorting report
            Id srId = sr.Id;
            Sorting_Report__c srRecord = (Sorting_Report__c) Database.query(
              selectAllFields(Sorting_Report__c.SObjectType) + ' WHERE ID = :srId'
            );

            // process the merge fiedls
            String subject = mergeEmailTemplateFields(srRecord, emailTemplate.Subject);
            String htmlBody = mergeEmailTemplateFields(srRecord, emailTemplate.HtmlValue);
            String plainBody = mergeEmailTemplateFields(srRecord, emailTemplate.Body);
        
            for (Contact receiver : receivers) {
                if (receiver.Send_EQA_Notifications__c) { 
                    String fromUser = currentUserType;
                    String toUser = userType;

                    if (true == EQA_Notification_Settings__c.getOrgDefaults().Include_Name_for_Notification_Email__c) {
                      fromUser += ' ' + currentUserName;
                      toUser += ' ' + receiver.Name;
                    }

                    String currHtmlBody = String.format(htmlBody, new String[] {fromUser, toUser});
                    String currPlainBody = String.format(plainBody, new String[] {fromUser, toUser});
                    lstMsgsToSend.add(createEmail(receiver.Id, subject, currHtmlBody, currPlainBody)); 
                }
            }
        }
    }

    public static void sendNotification(Part_Incident_Report__c pir, String reportName, String userType){
        List<Contact> receivers = new List<Contact>();
        if (userType == 'Customer') {
            receivers = getCustomersForPIR(pir);
        }
        else if (userType == 'Supplier') {
            receivers = getSuppliersForPIR(pir);
        }

        if (receivers.isEmpty()) {
          receivers = getEQAContacts();
          userType = 'EQA';
        }

        EmailTemplate emailTemplate = getEmailTemplateId(reportName);
        if (receivers.size() > 0 && emailTemplate != null) {
            // grab part incident report
            Id pirId = pir.Id;
            Part_Incident_Report__c pirRecord = (Part_Incident_Report__c) Database.query(
              selectAllFields(Part_Incident_Report__c.SObjectType) + ' WHERE ID = :pirId'
            );

            // process the merge fiedls
            String subject = mergeEmailTemplateFields(pirRecord, emailTemplate.Subject);
            String htmlBody = mergeEmailTemplateFields(pirRecord, emailTemplate.HtmlValue);
            String plainBody = mergeEmailTemplateFields(pirRecord, emailTemplate.Body);

            for (Contact receiver : receivers) {
                if (receiver.Send_EQA_Notifications__c) {
                    String fromUser = currentUserType;
                    String toUser = userType;

                    if (true == EQA_Notification_Settings__c.getOrgDefaults().Include_Name_for_Notification_Email__c) {
                      fromUser += ' ' + currentUserName;
                      toUser += ' ' + receiver.Name;
                    }
                    
                    String currHtmlBody = String.format(htmlBody, new String[] {fromUser, toUser});
                    String currPlainBody = String.format(plainBody, new String[] {fromUser, toUser});
                    lstMsgsToSend.add(createEmail(receiver.Id, subject, currHtmlBody, currPlainBody));  
                }
            }
        }
    }

    public static void sendNotification(Monetary_Claim__c mc, String reportName, String userType){
        List<Contact> receivers = new List<Contact>();
        if (userType == 'Customer') {
            receivers = getCustomersForMC(mc);
        }
        else if (userType == 'Supplier') {
            receivers = getSuppliersForMC(mc);
        }

        if (receivers.isEmpty()) {
          receivers = getEQAContacts();
          userType = 'EQA';
        }
        
        EmailTemplate emailTemplate = getEmailTemplateId(reportName);
        if (receivers.size() > 0 && emailTemplate != null) {
            // grab part incident report
            Id mcId = mc.Id;
            Monetary_Claim__c mcRecord = (Monetary_Claim__c) Database.query(
              selectAllFields(Monetary_Claim__c.SObjectType) + ' WHERE ID = :mcId'
            );

            // process the merge fiedls
            String subject = mergeEmailTemplateFields(mcRecord, emailTemplate.Subject);
            String htmlBody = mergeEmailTemplateFields(mcRecord, emailTemplate.HtmlValue);
            String plainBody = mergeEmailTemplateFields(mcRecord, emailTemplate.Body);

            for (Contact receiver : receivers){
                if (receiver.Send_EQA_Notifications__c) {
                    String fromUser = currentUserType;
                    String toUser = userType;

                    if (true == EQA_Notification_Settings__c.getOrgDefaults().Include_Name_for_Notification_Email__c) {
                      fromUser += ' ' + currentUserName;
                      toUser += ' ' + receiver.Name;
                    }

                    String currHtmlBody = String.format(htmlBody, new String[] {fromUser, toUser});
                    String currPlainBody = String.format(plainBody, new String[] {fromUser, toUser});
                    lstMsgsToSend.add(createEmail(receiver.Id, subject, currHtmlBody, currPlainBody)); 
                }
            }
        }
    }

    public static void sendEmails(){
        if (lstMsgsToSend.size() > 0 && !Test.isRunningTest()){
            Messaging.sendEmail(lstMsgsToSend);
            lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        }
    }

    public static String mergeEmailTemplateFields(SObject relatedRecord, String text) {
      // replace value from custom settings
      text = text.replaceAll('\\{!\\$Setup.EQA_Notification_Settings__c.Hours_To_Send_Idle_Notification__c\\}', 
          '' + EQA_Notification_Settings__c.getOrgDefaults().Hours_To_Send_Idle_Notification__c
        );

      // match fields
      Matcher m = Pattern.compile('(\\{![A-Za-z0-9_.]+\\})').matcher(text);
      while (m.find()) {
        String merge_field = m.group(0);
        String field = merge_field.substring(2, merge_field.length() - 1).substringAfter('.');
        
        String value;
        if (field == 'Link') {
          value = URL.getSalesforceBaseUrl().toExternalForm() + '/' + relatedRecord.get('Id');
        } else {
          try {
            value = (String) relatedRecord.get(field);
          } catch(Exception ex) { 
          }
        }

        if (null != value) {
          text = text.replace(merge_field, value);
        } else {
          text = text.replace(merge_field, '');
        }
      }

      return text;
    } 

    public static Messaging.SingleEmailMessage createEmail(Id recipientId, String subject, String htmlBody, String plainBody) {
        // build the email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId(recipientId);
        mail.setSaveAsActivity(false);

        mail.setSubject(subject);
        mail.setHtmlBody(htmlbody);
        mail.setPlainTextBody(plainBody);

        return mail;
    }

    public static Messaging.SingleEmailMessage createEmail(EmailTemplate template, Id recipientId, Id relatedToId) {
        // build the email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId(recipientId);
        mail.setTemplateId(template.Id);
        mail.setWhatId(relatedToId);
        mail.setSaveAsActivity(false);

        return mail;
    }

    public static List<Contact> getCustomersForSR(Sorting_Report__c sr){
        List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :sr.Customer__c LIMIT 1];

        if (customerAccounts.size() > 0){
            for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
            }
            if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }

                    if (currentOwnerId == null){
                        selectEQAUser();
                    }
                }
            return customerAccounts[0].Contacts;
        }

        return new List<Contact>();
    }

    public static List<Contact> getSuppliersForSR(Sorting_Report__c sr){
        Id supplierId = getSupplierID(sr);
        if (supplierId != null){
            List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :supplierId LIMIT 1];

            if (customerAccounts.size() > 0){
                for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
                }
                
                if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }

                    if (currentOwnerId == null){
                        selectEQAUser();
                    }   
                }
                return customerAccounts[0].Contacts;
            }
        }
        
        return new List<Contact>();
    }

    private static Id getSupplierID(Sorting_Report__c sr){
        List<Sorting_Report__c> sortingReportAdditionalInfo = [SELECT Part__r.Supplier__c FROM Sorting_Report__c WHERE Id = :sr.id LIMIT 1];

        if (sortingReportAdditionalInfo.size() > 0){
            return sortingReportAdditionalInfo[0].Part__r.Supplier__c;
        }

        return null;
    }

    public static List<Contact> getCustomersForPIR(Part_Incident_Report__c pir){
        List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c , Email FROM Contacts) FROM Account WHERE Id = :pir.Customer__c LIMIT 1];

        if (customerAccounts.size() > 0){
            for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
                }
            if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }

                if (currentOwnerId == null){
                     selectEQAUser();
                }       
            }

            return customerAccounts[0].Contacts;
        }

        return new List<Contact>();
    }

    public static List<Contact> getSuppliersForPIR(Part_Incident_Report__c pir){
        Id supplierId = getSupplierID(pir);
        if (supplierId != null){
            List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :supplierId LIMIT 1];

            if (customerAccounts.size() > 0){
                for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
                }

                if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }
                    
                    if (currentOwnerId == null){
                         selectEQAUser();
                    }       
                }
                return customerAccounts[0].Contacts;
            }
        }
        
        return new List<Contact>();
    }

    private static Id getSupplierID(Part_Incident_Report__c sr){
        List<Part_Incident_Report__c> pirAdditionalInfo = [SELECT Part__r.Supplier__c FROM Part_Incident_Report__c WHERE Id = :sr.id LIMIT 1];

        if (pirAdditionalInfo.size() > 0){
            return pirAdditionalInfo[0].Part__r.Supplier__c;
        }

        return null;
    }


    public static List<Contact> getCustomersForMC(Monetary_Claim__c mc){
        List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :mc.Customer__c LIMIT 1];

        if (customerAccounts.size() > 0){
            for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
            }
                if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }

                    if (currentOwnerId == null){
                        selectEQAUser();
                    }       
                }
            return customerAccounts[0].Contacts;
        }

        return new List<Contact>();
    }

    public static List<Contact> getSuppliersForMC(Monetary_Claim__c mc){
        Id supplierId = getSupplierID(mc);
        if (supplierId != null){
            List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :supplierId LIMIT 1];

            if (customerAccounts.size() > 0){
                for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
                }

                if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }
                    if (currentOwnerId == null){
                        selectEQAUser();
                    }   
                    
                }
                return customerAccounts[0].Contacts;
            }
        }

        if (currentOwnerId == null){
            selectEQAUser();
        }   

        return new List<Contact>();
    }

    private static Id getSupplierID(Monetary_Claim__c mc){
        List<Monetary_Claim__c> mcAdditionalInfo = [SELECT Sorting_Report__c, Part_Incident_Report__c, Sorting_Report__r.Part__r.Supplier__c, Part_Incident_Report__r.Part__r.Supplier__c FROM Monetary_Claim__c WHERE Id = :mc.id LIMIT 1];

        if (mcAdditionalInfo.size() > 0){
            if (mcAdditionalInfo[0].Sorting_Report__c != null){
                return mcAdditionalInfo[0].Sorting_Report__r.Part__r.Supplier__c;
            }
            else if (mcAdditionalInfo[0].Part_Incident_Report__c != null){
                return mcAdditionalInfo[0].Part_Incident_Report__r.Part__r.Supplier__c;
            }
        }

        return null;
    }


       

    private static EmailTemplate getEmailTemplateId(String emailTemplateName){
        List<EmailTemplate> emailTemplates = [
                SELECT Id, Subject, HtmlValue, Body
                  FROM EmailTemplate  
                 WHERE Name = :emailTemplateName
        ];

        if (emailTemplates.size() > 0){
            return emailTemplates[0];
        }

        return null;
    }

    private static Id getUserIdFromContactID(Id contactId){
        List<User> users = [SELECT Id  FROM User WHERE ContactId = :contactId];
        if (users.size() > 0){
            return users[0].id;
        }

        return null;
    }

    private static void selectEQAUser(){
        EQA_Escalation_Settings__c setting = EQA_Escalation_Settings__c.getOrgDefaults();

        if(setting != null){
        List<Account> customerAccounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :setting.Portal_Account_ID__c LIMIT 1];

            if (customerAccounts.size() > 0){
                for(Contact primaryContact: customerAccounts[0].Contacts){
                    if(primaryContact.EQA_Records_Owner__c){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                    }   
                }

                if (currentOwnerId == null){
                    for(Contact primaryContact: customerAccounts[0].Contacts){
                        currentOwnerId = getUserIdFromContactID(primaryContact.id);
                        
                        if(currentOwnerId != null){
                            break;
                        }
                    }
                }
            }
        }
    }
    
  public static List<Contact> getEQAContacts() {
    EQA_Escalation_Settings__c setting = EQA_Escalation_Settings__c.getOrgDefaults();

    if (null != setting) {
      List<Account> accounts = [SELECT Id, (SELECT Id, Name, Send_EQA_Notifications__c, EQA_Records_Owner__c, Email FROM Contacts) FROM Account WHERE Id = :setting.Portal_Account_ID__c LIMIT 1];
      if (!accounts.isEmpty()) {
        // find contacts with EQA Records Owner checkbox
        for (Contact c : accounts[0].Contacts) {
          if (true == c.EQA_Records_Owner__c) currentOwnerId = getUserIdFromContactID(c.id);
          if (null != currentOwnerId) break;
        }

        // if not exists get random contact
        if (null == currentOwnerId) {
          for(Contact c: accounts[0].Contacts) {
            currentOwnerId = getUserIdFromContactID(c.id);
            if(currentOwnerId != null) break;
          }
        }

        return accounts[0].Contacts;
      }
    }

    return new List<Contact>();
  }

  private static String getUserType(String profileName) {
    if (profileName.contains('Customer')) {
      return 'Customer';
    } else if (profileName.contains('Supplier')) {
      return 'Supplier';
    } else {
      return 'EQA';
    }
  }

  /** Select all fields from object that can be edited and created by the current user
   * @param fields describing sObjects
   */
  public static String selectAllFields(Schema.SObjectType o) {
    Map<String,Schema.SObjectField> fieldsMap = Schema.describeSObjects(new String[] { String.valueOf(o) }) [0].fields.getMap();

    String[] fields = new String[] {};
    for (String key : fieldsMap.keySet()) {
      Schema.DescribeFieldResult field = fieldsMap.get(key).getDescribe();
      fields.add(key);
    }

    return String.format('SELECT {0} FROM {1}', new String[] {String.join(fields, ','), String.valueOf(o)});
  }
}