trigger AccountEmailScrub_Before on Account (before insert, before update) {

    Account newAccount;

    for (Account acct: Trigger.new) {
        if(acct.IsPersonAccount && acct.PersonEmail != null && !acct.PersonEmail.endsWith('.qa')) {
            //System.debug(acct.PersonEmail + '__is the email we are changing...');
            acct.HasQAUpdatedEmail__c = true;
            acct.PersonEmail = acct.PersonEmail + '.qa';
        }
    }
}