/**********************************************************************
Name: Controller_ShareCaseWithDealer
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Controller of Share Case With Dealer Page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 06/11/2012 Created
***********************************************************************/
public class Controller_ShareCaseWithDealer {
    private static final String DEALER_INACTIVE = 'Dealer Code is not listed as an Active Dealer. Please confirm, reenter a valid Dealer Code, and try again to Share Case with Dealer.';
    private static final String NO_EMAIL_SELECTED = 'You have not selected any users to receive email notifications. Please either confirm you intended this by clicking "Share with Dealer" again, or select users to receive email notifications and click "Share with Dealer"';
    private static final String DEALER_PORTAL_DISABLED = 'The Dealer Portal is not enabled for the Dealer you have selected. Please contact your manager or Managed Services.';
    private static final String NO_SHARE_USERS = 'No users are associated with the selected dealer to share the case with.';
    private static final String SERVICE_MANAGER_NO_EMAIL = 'Service Manager does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String SALES_MANAGER_NO_EMAIL = 'Sales Manager does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String PARTS_MANAGER_NO_EMAIL = 'Parts Manager does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String DOM_NO_EMAIL = 'DOM does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String FOM_NO_EMAIL = 'FOM does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String CSM_NO_EMAIL = 'CSM does not have an active email address to send to. Please deselect that user/those users and either select different user(s) or click "Share with Dealer" with no users selected.';
    private static final String CASE_ID = 'caseId';
    private static final String CASE_EMPTY = 'No Case was specified.';
    private static final String DEALER_EMPTY = 'A Dealer must be specified.';

    public Id caseId {get; set; }
    public Case dbCase { get; set; }
    public Case screenCase { get; set; }
    public Boolean emailServiceManager { get; set; }
    public Boolean emailSalesManager { get; set; }
    public Boolean emailPartsManager { get; set; }
    public Boolean emailDOM { get; set; }
    public Boolean emailFOM { get; set; }
    public Boolean emailCSM { get; set; }
    public Account servicingDealer { get; set; }
    public String dealerCode { get; set; }
    public List<String> portalEmailAddresses { get; set; }
    public List<String> userEmailAddresses { get; set; }
    public Boolean noEmailErrorGiven { get; set; }
    public String nissanInfiniti { get; set; }

    public Controller_ShareCaseWithDealer() {
        caseId = ApexPages.currentPage().getParameters().get(CASE_ID);
        screenCase = new Case();
        emailServiceManager = false;
        emailSalesManager = false;
        emailPartsManager = false;
        emailDOM = false;
        emailFOM = false;
        emailCSM = false;
        noEmailErrorGiven = false;
        if (caseId != null) {
            dbCase = [select Id, Servicing_Dealer__c, Data_Net__c, Datanet_Dealer_Date__c, CaseNumber, Subject, AccountId from Case where Id = :caseId];
            screenCase.Servicing_Dealer__c = dbCase.Servicing_Dealer__c;
            updateDealerCode();
        } else {
            // If no caseId is passed in, give a warning.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, CASE_EMPTY));
        }
    }
    
    public void updateDealerCode() {
        if (screenCase.Servicing_Dealer__c != null) {
            servicingDealer = [select Id, Dealer_Inactive_Indicator__c, Dealer_Code__c, CSR_Assigned__c,
                                      Service_Manager__c, Sales_Manager__c, Parts_Manager__c, Dealer_Portal_Enabled__c
                               from Account 
                               where Id = :screenCase.Servicing_Dealer__c];
            dealerCode = servicingDealer.Dealer_Code__c;
        }
    }

    public PageReference shareAction() {
        if (caseId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, CASE_EMPTY));
            return null;
        }
        
        // Get dealer information
        if (screenCase.Servicing_Dealer__c != null) {
            portalEmailAddresses = new List<String>();
            userEmailAddresses = new List<String>();
            servicingDealer = [select Id, Name, Dealer_Inactive_Indicator__c, Dealer_Code__c, CSR_Assigned__c,
                                      Service_Manager__c, Sales_Manager__c, Parts_Manager__c, DOM_Stage_User__r.Email__c,
                                      FOM_Stage_User__r.Email__c, CSR_Assigned__r.Email, Service_Manager__r.Email, Sales_Manager__r.Email,
                                      Parts_Manager__r.Email, Dealer_Portal_Enabled__c, Make_Name__c
                               from Account
                               where Id = :screenCase.Servicing_Dealer__c];

            if (servicingDealer != null && servicingDealer.Make_Name__c != null) {
                if (servicingDealer.Make_Name__c == 'INFINITI') {
                    nissanInfiniti = 'Infiniti';
                } else {
                    nissanInfiniti = 'Nissan';
                }
            } else {
                nissanInfiniti = 'Nissan';
            }
                            
            // Get users to share Case with
            List<User> shareUsers = [select Id, Profile.Name
                                     from user 
                                     where Profile.Name in ('Dealer Sales or Service Manager','Dealer Parts Manager',
                                                            'Infiniti Sales or Service Manager','Infiniti Parts Manager') 
                                     and profile.userlicense.name = 'Gold Partner' 
                                     and contact.accountid = :screenCase.Servicing_Dealer__c
                                     and isactive = true];

            // If no Users were returned to share with, give an error
            if (shareUsers.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, NO_SHARE_USERS));
            }

            List<CaseShare> caseShares = [Select Id
                                          From CaseShare 
                                          Where RowCause = 'Manual' 
                                          And UserOrGroupId in (select Id from User where profile.userlicense.name = 'Gold Partner') 
                                          And Case.RecordType.Name in ('CA','CA Email Infiniti','CA Email Nissan','T5','Roadside Assistance','CA Closed Case')
                                          And CaseId = :caseId
                                          AND UserOrGroupId not in :shareUsers];
    
            // Do validations and add errors to the page if found
            doValidations();
            
            // If any errors were found, return to the page without sharing/emailing
            if (ApexPages.hasMessages()) {
                return null;
            }

            // Share the Case with the list of Users
            List<CaseShare> shares = new List<CaseShare>();
            for (User u: shareUsers) {
                CaseShare cs = new CaseShare();
                cs.CaseId = caseId;
                cs.UserOrGroupId = u.Id;
                cs.CaseAccessLevel = 'Edit';
                shares.add(cs);
            }
            
            insert shares;
            delete caseShares;
            
            // Send email to lists of Users and pass in a Case for each one for merge fields
            sendEmails();
            
            dbCase.Servicing_Dealer__c = screenCase.Servicing_Dealer__c;
            dbCase.Data_Net__c = true;
            dbCase.Datanet_Dealer_Date__c = System.today();
            dbCase.Service_Manager_Notified__c = emailServiceManager;
            dbCase.Sales_Manager_Notified__c = emailSalesManager;
            dbCase.Parts_Manager_Notified__c = emailPartsManager;
            dbCase.DOM_Notified__c = emailDOM;
            dbCase.FOM_Notified__c = emailFOM;
            dbCase.CSM_Notified__c = emailCSM;
            dbCase.Shared_With__c = servicingDealer.Name;
            dbCase.Shared_via_Portal__c = true;
            update dbCase;
        } else {
            // If dealer is not specified, give a warning.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, DEALER_EMPTY));
            return null;
        }

        // Return to view the case
        return new ApexPages.standardController(new Case(ID=caseId)).view();
    }
    
    private void sendEmails() {
        String url = null;
        
        // Send emails to portal users
        if (!portalEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage portalMail = new Messaging.SingleEmailMessage();
            
            portalMail.setSenderDisplayName('CA');
            portalMail.setSubject('Consumer Affairs Case #' + dbCase.CaseNumber + ': ' + dbCase.Subject);
            if (ApexPages.currentPage().getHeaders() != null &&
                  ApexPages.currentPage().getHeaders().get('Host') != null &&
                  ApexPages.currentPage().getHeaders().get('Host').contains('cs9')) {
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
            portalMail.setPlainTextBody('There is a new Consumer Affairs Case that requires your attention.  Please click the link below to review the Case and take appropriate action: ' + url + '?caseId=' + dbCase.Id);
            portalMail.setToAddresses(portalEmailAddresses);
    
            portalMail.setSaveAsActivity(false);

            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {portalMail});
            }
        }
        
        // Send emails to non-portal users
        if (!userEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage userMail = new Messaging.SingleEmailMessage();
            
            userMail.setSenderDisplayName('CA');
            userMail.setSubject('Consumer Affairs Case #' + dbCase.CaseNumber + ': ' + dbCase.Subject);
            if (ApexPages.currentPage().getHeaders() != null &&
                  ApexPages.currentPage().getHeaders().get('Host') != null &&
                  ApexPages.currentPage().getHeaders().get('Host').contains('cs9')) {
                url = System.label.NissanQA;
            } else {
                url = System.label.NissanProd;
            }
            userMail.setPlainTextBody('There is a new Consumer Affairs Case that requires your attention.  Please click the link below to review the Case and take appropriate action: ' + url + '/' + dbCase.Id);
            userMail.setToAddresses(userEmailAddresses);
    
            userMail.setSaveAsActivity(false);

            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {userMail});
            }
        }
    }

    private void doValidations() {
        // Check to make sure Servicing Dealer selected is active.  If not, give an error.
        if (servicingDealer.Dealer_Inactive_Indicator__c == true) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, DEALER_INACTIVE));
        }
        
        // Ensure that at least 1 role has been selected to email
        if (!emailServiceManager && !emailSalesManager && !emailPartsManager && 
            !emailDOM && !emailFOM && !emailCSM && !noEmailErrorGiven) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, NO_EMAIL_SELECTED));
            noEmailErrorGiven = true;
        }
        
        if (servicingDealer.Dealer_Portal_Enabled__c == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, DEALER_PORTAL_DISABLED));
        }
        
        // For each role to send an email to, make sure a valid email address is found and add it to
        // the list.  If not address is found for any, add an error message.
        if (emailServiceManager == true) {
            if (servicingDealer.Service_Manager__r.Email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, SERVICE_MANAGER_NO_EMAIL));
            } else {
                portalEmailAddresses.add(servicingDealer.Service_Manager__r.Email);
            }
        }
        if (emailSalesManager == true) {
            if (servicingDealer.Sales_Manager__r.Email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, SALES_MANAGER_NO_EMAIL));
            } else {
                portalEmailAddresses.add(servicingDealer.Sales_Manager__r.Email);
            }
        }
        if (emailPartsManager == true) {
            if (servicingDealer.Parts_Manager__r.Email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, PARTS_MANAGER_NO_EMAIL));
            } else {
                portalEmailAddresses.add(servicingDealer.Parts_Manager__r.Email);
            }
        }
        if (emailDOM) {
            if (servicingDealer.DOM_Stage_User__r.Email__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, DOM_NO_EMAIL));
            } else {
                userEmailAddresses.add(servicingDealer.DOM_Stage_User__r.Email__c);
            }
        }
        if (emailFOM) {
            if (servicingDealer.FOM_Stage_User__r.Email__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, FOM_NO_EMAIL));
            } else {
                userEmailAddresses.add(servicingDealer.FOM_Stage_User__r.Email__c);
            }
        }
        if (emailCSM) {
            if (servicingDealer.CSR_Assigned__r.Email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, CSM_NO_EMAIL));
            } else {
                userEmailAddresses.add(servicingDealer.CSR_Assigned__r.Email);
            }
        }
    }

    public PageReference cancelAction() {
        // Return to view the case
        return new ApexPages.standardController(new Case(ID=caseId)).view();
    }
/*
    @isTest(SeeAllData=true)
    static void TestShareCase() {
        RecordType maritzTypeRT = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
        RecordType caTypeRT = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        PageReference objPageRef = Page.ShareCaseWithDealer;
        Controller_ShareCaseWithDealer objController;
        String strURL;

        Account acct = new Account(FirstName = 'First', LastName = 'Last', PersonMailingCity = 'City', PersonMailingState= 'AK',
                                   PersonMailingPostalCode = '12345', RecordTypeId = maritzTypeRT.Id);
        insert acct;
        
        Account dealer = [select Id
                          from Account
                          where RecordType.Name = 'Dealer'
                          and Dealer_Inactive_Indicator__c = false
                          and Dealer_Portal_Enabled__c = true
                          and CSR_Assigned__r.Email != null
                          and Service_Manager__r.Email != null
                          and Sales_Manager__r.Email != null
                          and Parts_Manager__r.Email != null
                          and DOM_Stage_User__r.Email__c != null
                          and FOM_Stage_User__r.Email__c != null
                          limit 1];

        Vehicle__c v = new Vehicle__c(Vehicle_Identification_Number__c = '1N345678901234567',
                                      Name = '1N345678901234567',
                                      Model_Year__c = '2009',
                                      Make_Name__c = 'MakeName',
                                      Model_Line_Name__c = 'ModelLineName');
        insert v;

        Case c = new Case(AccountId = acct.Id,
                          Vehicle_Name__c = v.Id,
                          RecordTypeId = caTypeRT.Id,
                          Servicing_Dealer__c = dealer.Id,
                          Subject = 'Test Subject');
        insert c;
        
        c = [select Id, DocumentId__c
             from case
             where id = :c.Id];

        objPageRef.getParameters().put(CASE_ID, c.Id);
        Test.setCurrentPage(objPageRef);

        Test.startTest();       
        //test share case
        objController = new Controller_ShareCaseWithDealer();
        objController.emailServiceManager = true;
        objController.emailSalesManager = true;
        objController.emailPartsManager = true;
        objController.emailDOM = true;
        objController.emailFOM = true;
        objController.emailCSM = true;
        PageReference p = objController.shareAction();
        cleanTestInput(objController);

        Test.stopTest();
    }
*/
/*
    public List<String> portalEmailAddresses { get; set; }
    public List<String> userEmailAddresses { get; set; }
    public Boolean noEmailErrorGiven { get; set; }
    public String nissanInfiniti { get; set; }

*/


    private static void cleanTestInput(Controller_ShareCaseWithDealer objController) {
    }

}