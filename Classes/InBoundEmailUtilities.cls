public with sharing class InBoundEmailUtilities {
    inboundEmailSettings__c inboundSettings = inboundEmailSettings__c.getOrgDefaults();
    private Static Boolean TRACE = true;
    String emailRefPrefix = '[' +inboundSettings.emailReferenceIdString__c + ':';
    String emailRefSuffix =  ':]';

    protected Notor__c theNotorCase = null;
    @TestVisible protected Messaging.InboundEmail inboundEmail;
    protected String defaultCaseOwnerId;
    
    public InBoundEmailUtilities() {
         if (inboundSettings.queueName__c != null) {
             Group[] queues = [Select Type, OwnerId, Name,id From Group where type= 'queue' and name=:inboundSettings.queueName__c];
             if (queues.size() == 1) {
                 this.defaultCaseOwnerId = queues[0].id;  
             }
        }
    }
    
    public Messaging.InboundEmailResult processInboundEmail(Messaging.InboundEmail email)   {
        Id thisContact;   
        Contact theContact; 
        Contact[] contacts = [SELECT Id, Name, AccountId, Email FROM Contact WHERE Email = :email.fromAddress ORDER BY LastModifiedDate Desc];
        
        // query the incoming email against the contact object, need
        /// to get contact in order to setTargetObjectId()

        if (contacts.size() > 0) {
            theContact = contacts[0];
            thisContact = theContact.Id;
        } else {
            // use the inboundSettings.createContact__c to determine if we need
            // to create a contact.
            if (inboundSettings.createContact__c) {
                
                // create contact
            } else {
                // use temporary contact
            }
            
        
        
        }
        
        String tempFromAddress = '';
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = true;
        this.inboundEmail = email;
        
        
        String caseNumber = extractRef(email.subject,inboundSettings.emailReferenceIdString__c);
        
        if(caseNumber == null) {   //no id, create a new notor
            // else create a new Case
            this.theNotorCase = new Notor__c();
    
            
            if(contacts.size() >0) {
               theNotorCase.Person_Account__c = theContact.AccountId;
            }
            
            theNotorCase.Web_Email__c= email.fromAddress;
            theNotorCase.Web_Name__c = email.fromName;
            theNotorCase.Status__c = 'New';
            theNotorCase.OwnerId = this.defaultCaseOwnerId;
            theNotorCase.Case_Origin__c = 'Email Service';
            theNotorCase.Subject__c = inboundSettings.emailSubjectPrefix__c + email.Subject;
            
            //Populate html description and     description
            
            theNotorCase.HTMLDescription__c = email.htmlBody;
            theNotorCase.Description__c = email.plainTextBody;
            if (theNotorCase.Description__c == null && theNotorCase.HTMLDescription__c != null) {
                theNotorCase.Description__c = theNotorCase.HTMLDescription__c.replaceAll('\\<.*?\\>','');
            }
            if (theNotorCase.HTMLDescription__c == null && theNotorCase.Description__c != null) {
                theNotorCase.HTMLDescription__c = theNotorCase.Description__c;
            }
            
            insertSObject(this.theNotorCase);
            
            createEmailMessage(theNotorCase.Id,email);
            
            
            if (inboundSettings.sendAutoReplies__c) {
                String emailReferenceString = emailRefPrefix + theNotorCase.Id + emailRefSuffix;
                
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                if (theNotorCase.Person_Account__c != null) {
                    mail.setTargetObjectId(thisContact);
                    mail.setWhatId(theNotorCase.Id);
                    mail.setSaveAsActivity(true);
                } else {
                    mail.setWhatId(theNotorCase.Id);
                    
                    mail.setToAddresses(new String[] {email.fromAddress});
                    mail.setSaveAsActivity(false);
                }    
                mail.setSubject(inboundSettings.emailSubjectPrefix__c +' Case created. ' + emailReferenceString);
                mail.setSenderDisplayName(inboundSettings.senderDisplayName__c);
                mail.setReplyTo(inboundSettings.replyToEmail__c);
                EmailTemplate templateId = [Select id, HTMLValue from EmailTemplate where name = 'NOTOR_AutoReply'];
                mail.setHtmlBody('Your case has been created. Case id:  ' + theNotorCase.Id);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
             //handleAttachments(theNotorCase, email);
            
         return result;
        } else {
            
            // we have an id, just attach the email to it
            createEmailMessage(caseNumber,email);   //Creates Task
            
            if (inboundSettings.sendAutoReplies__c) {
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                EmailTemplate templateId = [Select id, HTMLValue from EmailTemplate where name = 'Test Response'];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setHtmlBody(templateId.HTMLValue);
                String emailReferenceString = emailRefPrefix + caseNumber + emailRefSuffix;
                
                mail.setSubject(inboundSettings.emailSubjectPrefix__c +' Case updated. ' + emailReferenceString);
                mail.setSenderDisplayName('auto-reply@nissan-usa.com');
                mail.setReplyTo('testemail@k-kmbskcvesndoeyrqrq614dymfn8n6kxv1tso4jtsdpilmk5ds.c-3senxeaa.cs14.apex.sandbox.salesforce.com');
                mail.setHtmlBody('you are replying to a case, we have saved the updates to your case: ' + caseNumber);
            
            
                if (thisContact != null) {
                    mail.setTargetObjectId(thisContact);
                    mail.setWhatId(caseNumber);
                    mail.setSaveAsActivity(inboundSettings.createActivity__c);
                    
                } else {
                    mail.setToAddresses(new String[] {email.fromAddress});
                    mail.setSaveAsActivity(false);
                }
        
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                //createEmailMessage2(caseNumber,mail);
                
               
            }
            result.success = true;
            return result;
        
        }
    }
    

    @TestVisible private void insertSObject(sObject obj) {
     try {insert obj;} catch (System.DmlException e) {
     Error_log__c el = new Error_Log__c(Record_Type__c = 'inboundEmailUtility', 
                        Error_Message__c = e.getMessage() + e.getLineNumber(), 
                        TimeStamp__c = System.now(), 
                        Operation_Name__c = 'InboundEmailUtility Error', 
                        Source__c='Salesforce', 
                        Log_Type__c = 'Error', 
                        Log_Level__c = 1);
     insert el;
     }
    }
    
    private String limitLength(String input, Integer maxLength)
    {
     String results;
     if(input != null && input.length() > maxLength)
      results = input.substring(0,maxLength);
     else 
      results = input;
     return results;
    }
    
    private void createEmailMessage(String caseId,  Messaging.InboundEmail email ) {
     String value;
     Integer maxlength;
     Task theEmail = new Task();
     theEmail.WhatId = caseId;
    // theEmail.Incoming = false;
     Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();

     maxlength = F.getLength();
     theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
    // theEmail.MessageDate = datetime.now();
    // theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());  
     theEmail.Description = limitLength(email.plainTextBody,EmailMessage.HtmlBody.getDescribe().getLength());
    
     /* **** To */
     value = '';
     insertSObject(theEmail);
    }


    @TestVisible private String extractRef(String emailSubject, String refString)
    {
     String itemRef = null;
     String target = emailSubject.toLowerCase();
     String patternString;
     Pattern thePattern;
     Matcher matcher;
     
     patternString = '.*'+refString+':(.{18}):'+'.*';
     thePattern = Pattern.compile(patternString);
     matcher = thePattern.matcher(emailSubject); // do not change to lower case for this test because Id's are case sensitive
      
     if (matcher.matches()) {
      String caseId = matcher.group(1);
      if(TRACE) system.debug(Logginglevel.ERROR,'extractRef "' + caseId + '"');    
      System.debug('matcher group 0: ' + matcher.group(0));
      
      Notor__c[] matchingCases = [Select Id from Notor__c where Id = :caseId];
      if(matchingCases.size() == 1) {
       Notor__c theNotorCase = matchingCases[0];
       itemRef = theNotorCase.Id;
      }    
     }  else {
         patternString = '.*'+refString+':(.{15}):'+'.*';
         thePattern = Pattern.compile(patternString);
         matcher = thePattern.matcher(emailSubject); // do not change to lower case for this test because Id's are case sensitive
          if (matcher.matches()) {
          String caseId = matcher.group(1);
          if(TRACE) system.debug(Logginglevel.ERROR,'extractRef "' + caseId + '"');    
          System.debug('matcher group 0: ' + matcher.group(0));
          
          Notor__c[] matchingCases = [Select Id from Notor__c where Id = :caseId];
          if(matchingCases.size() == 1) {
           Notor__c theNotorCase = matchingCases[0];
           itemRef = theNotorCase.Id;
          }    
         }
     }

     return itemRef; 
    }
    
 
    
     
     
}