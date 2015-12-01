public class EqaNotificationEscalationCS_Controller {
	public EQA_Profiles__c eqaProfiles_Cs { get; set; }
	public List<EqaProfiles_Wrapper> eqaProfilesList { get; set; }
	List<Profile> profiles = [select id, Name from Profile];
	public EQA_Notification_Settings__c eqaNotificationCS { get; set; }
	public EQA_Escalation_Settings__c eqaEscalationCS { get; set; }
	public Notification_Settings__c notificationCs {get; set;}
	public List<EqaCor_Wrapper> eqaOwnerRulesList {get; set;}
	public String csId_toDel { get; set; }
	public String csName_toDel { get; set; }

	//constructor
	public EqaNotificationEscalationCS_Controller() {
		//Dealer_Backfeed_XML_Enabled__c
		eqaProfiles_Cs = EQA_Profiles__c.getOrgDefaults();
		eqaProfilesList = new List<EqaProfiles_Wrapper> ();
		eqaProfilesList.add(new EqaProfiles_Wrapper(eqaProfiles_Cs, 'Org Defaults', null));
		for (Profile profileId : profiles) {
			if (EQA_Profiles__c.getValues(profileId.Id) != null) {
				eqaProfilesList.add(new EqaProfiles_Wrapper(EQA_Profiles__c.getValues(profileId.Id), profileId.Name, profileId.Id));
			}
		}
		eqaNotificationCS = EQA_Notification_Settings__c.getOrgDefaults();
		eqaEscalationCS = EQA_Escalation_Settings__c.getOrgDefaults();
		notificationCs = Notification_Settings__c.getOrgDefaults();
		eqaOwnerRulesList = filleqaOwnerRulesList();
	}


	//cancel
	public void Cancel() {

	}

	public List<EqaCor_Wrapper> filleqaOwnerRulesList(){
		List<EqaCor_Wrapper> listSettings = new List<EqaCor_Wrapper> ();

		for (EQA_Owner_Rules__c item : EQA_Owner_Rules__c.getall().values()) {
			listSettings.add(new EqaCor_Wrapper(item));
		}
		return listSettings;
	}

	public void SaveEqaNotificationsSettings() {
		Database.SaveResult result = DataBase.update(eqaNotificationCS, false);

		if (!result.isSuccess()) {
			for (Database.Error err : result.getErrors()) {
				System.debug(err);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not updated, something bad happened!'));
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully updated!'));
		}
	}

	public void SaveEqaEscalationSettings() {
		Database.SaveResult result = DataBase.update(eqaEscalationCS, false);

		if (!result.isSuccess()) {
			for (Database.Error err : result.getErrors()) {
				System.debug(err);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not updated, something bad happened!'));
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully updated!'));
		}
	}
	public void SaveNotificationsSettings() {
		Database.SaveResult result = DataBase.update(notificationCs, false);

		if (!result.isSuccess()) {
			for (Database.Error err : result.getErrors()) {
				System.debug(err);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not updated, something bad happened!'));
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully updated!'));
		}
	}
	//wrapper for eqa profiles custom setting
	class EqaProfiles_Wrapper {
		public Boolean validationRules { get; set; }
		public Boolean validationRulesMc { get; set; }
		public String profileName { get; set; }
		public Id profileId { get; set; }
		public Id csId { get; set; }

		public EqaProfiles_Wrapper(EQA_Profiles__c cs, String profname, Id profId) {
			validationRules = cs.Validation_Rules__c;
			csId = cs.Id;
			validationRulesMc = cs.Validation_Rules_for_MC__c;
			profileName = profname;
			profileId = profId;
		}
	}

	class EqaCor_Wrapper{
		public String currentOwner {get ; set ;}
		public Boolean edit {get ; set ;}
		public String profileId {get ; set ;}
		public ID csId {get ; set ;}
		public String csName {get ; set ;}

		public EqaCor_Wrapper(EQA_Owner_Rules__c cs){
			currentOwner = cs.Current_Owner__c;
			edit = cs.Edit__c;
			profileId = cs.Profile_Id__c;
			csName = cs.Name;
			csId = cs.Id;
		}

	}

	public void addEqaCor(){
	System.debug(eqaOwnerRulesList.size());
		eqaOwnerRulesList.add(0, new EqaCor_Wrapper(new EQA_Owner_Rules__c(Current_Owner__c='', Profile_Id__c='', name='1' + datetime.now().getTime())));
		System.debug(eqaOwnerRulesList.size());
		System.debug(eqaOwnerRulesList[0]);
	}

	public void SaveEqaCor(){
		List<EQA_Owner_Rules__c> eqaOwnerRulesList_toUpsert = new List<EQA_Owner_Rules__c> ();

		for (EqaCor_Wrapper cs : eqaOwnerRulesList) {

			eqaOwnerRulesList_toUpsert.add(new EQA_Owner_Rules__c(id = cs.csid,
																Name = cs.currentOwner + cs.profileId,
																Current_Owner__c = cs.currentOwner,
																Edit__c = cs.edit,
																Profile_Id__c = cs.profileId));
		}

		Database.UpsertResult[] result = DataBase.upsert(eqaOwnerRulesList_toUpsert, false);

		eqaOwnerRulesList.clear();
		for (EQA_Owner_Rules__c cs : eqaOwnerRulesList_toUpsert) {
			eqaOwnerRulesList.add(new EqaCor_Wrapper(cs));
		}

		for (Database.UpsertResult r : result) {
			if (!r.isSuccess()) {
				for (Database.Error err : r.getErrors()) {
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
				}
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings were successfully updated/inserted!'));
		}
	}

	public void delEqaCor(){
		if (CSId_toDel != null && CSId_toDel != '') {

			Database.DeleteResult delResult = DataBase.delete((Id) CSId_toDel, false);

			if (!delResult.isSuccess()) {
				for (Database.Error err : delResult.getErrors()) {
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not deleted, something bad happened!'));
				}
			}
		}
				
		for (Integer i = 0; i < eqaOwnerRulesList.size(); i++) {
				if (eqaOwnerRulesList[i].csName == CSName_toDel) {
					eqaOwnerRulesList.remove(i);
					break;
				}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully deleted!'));
		}
	}
	public void SaveEqaProfiles() {

		List<EQA_Profiles__c> eqaProfilesListToUpsert = new List<EQA_Profiles__c> ();

		for (EqaProfiles_Wrapper cs : eqaProfilesList) {

			eqaProfilesListtoUpsert.add(new EQA_Profiles__c(id = cs.csid,
			                                                Validation_Rules__c = cs.validationRules,
			                                                Validation_Rules_for_MC__c = cs.validationRulesMc));

		}

		Database.UpsertResult[] result = DataBase.upsert(eqaProfilesListToUpsert, false);

		eqaProfilesList.clear();
		eqaProfiles_Cs = EQA_Profiles__c.getOrgDefaults();
		eqaProfilesList = new List<EqaProfiles_Wrapper> ();
		eqaProfilesList.add(new EqaProfiles_Wrapper(eqaProfiles_Cs, 'Org Defaults', null));
		for (Profile profileId : profiles) {
			if (EQA_Profiles__c.getValues(profileId.Id) != null) {
				eqaProfilesList.add(new EqaProfiles_Wrapper(EQA_Profiles__c.getValues(profileId.Id), profileId.Name, profileId.Id));
			}


		}

		for (Database.UpsertResult r : result) {
			if (!r.isSuccess()) {
				for (Database.Error err : r.getErrors()) {
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
				}
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom settings were successfully updated/inserted!'));
		}
	}
}