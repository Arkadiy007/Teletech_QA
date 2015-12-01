trigger TechlineNotificationHistory_Before on Techline_Notification_History__c (before update) {
	private static final String STATUS_UPDATING = 'UPDATING';
	private static final String STATUS_SENT = 'SENT';
	private static final String STATUS_ERROR = 'ERROR';
	//private static final String STATUS_PENDING_CI = 'PENDINGCI';
	
	for (Techline_Notification_History__c tnh: Trigger.new) {
		if (tnh.Status__c == STATUS_UPDATING) {
			Techline_NotificationEmails notifClass = new Techline_NotificationEmails();
			Boolean finishedOK = notifClass.sendConfirmationEmail(tnh.Case__c);
			
			if (finishedOK) {
				tnh.Status__c = STATUS_SENT;	
			}
			else {
				tnh.Status__c = STATUS_ERROR;
			}
			
			
			/* //New Design 
			tnh.Body__c = notifClass.getEmailBody(tnh.Case__c, tnh.Notification__c);
			//tnh.Subject__c = notifClass.getEmailBody(tnh.Case__c, tnh.Notification__c);
			tnh.Status__c = notifClass.NOTIF_STATUS_PENDING_CI;
			*/
		}
	}
}