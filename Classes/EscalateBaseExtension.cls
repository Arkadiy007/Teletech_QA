public without sharing abstract class EscalateBaseExtension { 
    //----------------------------------------------------
    // Properties
    public String errorMessage { get; set; }
    public SObject record { get; set; }

    //----------------------------------------------------
    // Methods
    public EscalateBaseExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) controller.addFields(new List<String> {'Customer__c'});
        record = controller.getRecord();
    }

    public virtual PageReference escalate() {
        // get EQA settings for determine ID of EQA internal portal account
        EQA_Escalation_Settings__c settings = EQA_Escalation_Settings__c.getOrgDefaults();
        if (null != settings && null != settings.Portal_Account_ID__c) {
            // query all contacts related to internal portal account from setting
            Contact[] contactsList = [SELECT Id, EQA_Records_Owner__c, Name FROM Contact WHERE AccountId = :settings.Portal_Account_ID__c];
            if (!contactsList.isEmpty()) {
                // determine primary contact 
                Contact primaryContact;
                for (Contact c : contactsList) {
                    if (true == c.EQA_Records_Owner__c) {
                        primaryContact = c;
                    }
                }
                
                if (null == primaryContact) {
                    // get random contact from list
                    primaryContact = contactsList[0]; // guaranteed to be random.
                }
                
                // query User assigned to primary contact
                User[] usersList = [SELECT Id FROM User WHERE ContactId = :primaryContact.Id];
                if (!usersList.isEmpty()) {
                    try {
                        record.put('OwnerId', usersList[0].Id);
                        record.put('Current_Owner__c', 'EQA');
                        EmailNotificationHelper.disabledAutoSharing(record);
                        update record;

                        // share record with current user
                        ShareHelper.share(record);

                        // send email notifications
                        sendEmailNotifications();

                        return new PageReference('/' + record.get('Id'));
                    } catch (Exception ex) {
                        errorMessage = ex.getMessage();
                    }
                } else {
                    errorMessage = 'Not exists user related to contact ' + primaryContact.Name;
                }
                
            } else {
                errorMessage = 'Not exists related contacts';
            }
            
        } else {
            errorMessage = 'EQA Internal Portal Account ID is incorrect, please check it';
        }
        
        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage );
        ApexPages.addMessage(errorMsg);
        return null;
    }
    
    public virtual PageReference back() {
        return new PageReference('/' + record.get('Id'));
    }

    public abstract void sendEmailNotifications();
}