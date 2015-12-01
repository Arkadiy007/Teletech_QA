trigger Account_BeforeDelete on Account (before delete) {
	Id profileId = UserInfo.getProfileId();

	if (profileId == '00eF0000000eFEBIA2' ||
		profileId == '00eF0000000eCrJIAU' ||
		profileId == '00eF0000000eCrnIAE' ||
		profileId == '00eF0000000eFT1IAM' ||
		profileId == '00eF0000000eFT2IAM' ||
		profileId == '00eF0000000eFT3IAM' ||
		profileId == '00eF0000000eFT4IAM' ||
		profileId == '00eF0000000eFT5IAM' ||
		profileId == '00eF0000000eFT6IAM' ||
		profileId == '00eF0000000eFT7IAM' ||
		profileId == '00eF0000000eFT9IAM' ||
		profileId == '00eF0000000eFTAIA2') {
			for (Account acct: Trigger.old) {
		    	acct.addError('Cannot delete Account.');
			}
	}
}