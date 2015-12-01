public without sharing class MCEscalateExtension extends EscalateBaseExtension {
    //----------------------------------------------------
    // Properties
    public final static String MC_EMAIL_TEMPLATE = 'Monetary Claim Notification For EQA';
    public final static String OWNER_EQA = 'EQA';

    //----------------------------------------------------
    // Methods
    public MCEscalateExtension(ApexPages.StandardController controller) {
        super(controller);
    }

    public override void sendEmailNotifications() {
        EmailNotificationHelper.sendNotification((Monetary_Claim__c) record, MC_EMAIL_TEMPLATE, OWNER_EQA);
        EmailNotificationHelper.sendEmails();
    }
}