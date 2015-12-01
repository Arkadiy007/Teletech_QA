public without sharing class PIREscalateExtension extends EscalateBaseExtension {
    //----------------------------------------------------
    // Properties
    public final static String PIR_EMAIL_TEMPLATE = 'PIR Notification For EQA';
    public final static String OWNER_EQA = 'EQA';

    //----------------------------------------------------
    // Methods
    public PIREscalateExtension(ApexPages.StandardController controller) {
        super(controller);
    }

    public override void sendEmailNotifications() {
        EmailNotificationHelper.sendNotification((Part_Incident_Report__c) record, PIR_EMAIL_TEMPLATE, OWNER_EQA);
        EmailNotificationHelper.sendEmails();
    }
}