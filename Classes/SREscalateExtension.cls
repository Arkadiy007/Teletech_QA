public without sharing class SREscalateExtension extends EscalateBaseExtension {
    //----------------------------------------------------
    // Properties
    public final static String SR_EMAIL_TEMPLATE = 'Sorting Report Notification For EQA';
    public final static String OWNER_EQA = 'EQA';

    //----------------------------------------------------
    // Methods
    public SREscalateExtension(ApexPages.StandardController controller) {
        super(controller);
    }

    public override void sendEmailNotifications() {
        EmailNotificationHelper.sendNotification((Sorting_Report__c) record, SR_EMAIL_TEMPLATE, OWNER_EQA);
        EmailNotificationHelper.sendEmails();
    }
}