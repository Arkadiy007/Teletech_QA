public class EQACS_Controller { 
	public List<EQA_Quick_Reports_Fields_Wrapper> EQAQuickReportsFieldsCS_Wrapped {get;set;}
	public List<EQA_Quick_Reports_API_Names_Wrapper> EQAQuickReportsAPINamesCS_Wrapped {get;set;}
	public List<EQA_Quick_Reports_Filters_Wrapper> EQAQuickReportsFiltersCS_Wrapped {get;set;}	

	public List<SelectOption> typePickList {get; private set;}
	public List<SelectOption> reportNamePickList {get; private set;}
	public List<SelectOption> currentOwnerPickList {get; private set;}
	public List<SelectOption> profilePickList {get; private set;}
	
	public String CSId_toDel {get;set;}
	public String CSName_toDel {get;set;}
	public String csType {get;set;}
	private List<EQA_Quick_Reports_Fields__c> EQAQuickReportsFieldsCS;
	private List<EQA_Quick_Reports_API_Names__c> EQAQuickReportsAPINamesCS;
	private List<EQA_Quick_Reports_Filters__c> EQAQuickReportsFiltersCS;
	public EQA_Profiles__c eqaProfiles_Cs { get; set; }
	public List<EqaProfiles_Wrapper> eqaProfilesList { get; set; }
	public List<Profile> profiles = [select id, Name from Profile];
	public EQA_Notification_Settings__c eqaNotificationCS { get; set; }
	public EQA_Escalation_Settings__c eqaEscalationCS { get; set; }
	public Notification_Settings__c notificationCs {get; set;}
	public List<EqaCor_Wrapper> eqaOwnerRulesList {get; set;}	
	   
	//constructor
    public EQACS_Controller(){

		//EQA_Quick_Reports_Fields__c
		EQAQuickReportsFieldsCS = EQA_Quick_Reports_Fields__c.getAll().values();
		EQAQuickReportsAPINamesCS = EQA_Quick_Reports_API_Names__c.getAll().values();
		EQAQuickReportsFiltersCS = EQA_Quick_Reports_Filters__c.getAll().values();
		EQAQuickReportsFieldsCS_Wrapped = new List<EQA_Quick_Reports_Fields_Wrapper>();
		EQAQuickReportsAPINamesCS_Wrapped = new List<EQA_Quick_Reports_API_Names_Wrapper>();
		EQAQuickReportsFiltersCS_Wrapped = new List<EQA_Quick_Reports_Filters_Wrapper>();
		
		for(EQA_Quick_Reports_Fields__c cs : EQAQuickReportsFieldsCS){
			EQAQuickReportsFieldsCS_Wrapped.add(new EQA_Quick_Reports_Fields_Wrapper(cs));
		}

		reportNamePickList = new List<SelectOption>();
		for(EQA_Quick_Reports_API_Names__c cs : EQAQuickReportsAPINamesCS){
			EQAQuickReportsAPINamesCS_Wrapped.add(new EQA_Quick_Reports_API_Names_Wrapper(cs));
			reportNamePickList.add(new SelectOption(cs.Report_Name__c, cs.Report_Name__c));
		}

		for(EQA_Quick_Reports_Filters__c cs : EQAQuickReportsFiltersCS){
			EQAQuickReportsFiltersCS_Wrapped.add(new EQA_Quick_Reports_Filters_Wrapper(cs));
		}

		//Case RecordTypes picklist
		typePickList = new List<SelectOption>();
		typePickList.add(new SelectOption('String', 'String'));
		typePickList.add(new SelectOption('Datetime', 'Datetime'));
		typePickList.add(new SelectOption('Date', 'Date'));
		typePickList.add(new SelectOption('Boolean', 'Boolean'));

		//Profile picklist
		profilePickList = new List<SelectOption>();
        profilePickList.add(new SelectOption('', '-----'));
		/*for (Profile p : profiles){
			profilePickList.add(new SelectOption(p.Id, p.Name));
		}*/

		//Current Owner picklist
		currentOwnerPickList = new List<SelectOption>();
        currentOwnerPickList.add(new SelectOption('', '-----'));
		currentOwnerPickList.add(new SelectOption('Customer', 'Customer'));
		currentOwnerPickList.add(new SelectOption('Supplier', 'Supplier'));
		currentOwnerPickList.add(new SelectOption('EQA', 'EQA'));

		//EQA_Profiles__c
		eqaProfiles_Cs = EQA_Profiles__c.getOrgDefaults();
		eqaProfilesList = new List<EqaProfiles_Wrapper> ();
		eqaProfilesList.add(new EqaProfiles_Wrapper(eqaProfiles_Cs, 'Org Defaults', null));
		for (Profile profileId : profiles) {
			
			profilePickList.add(new SelectOption(profileId.Id, profileId.Name));

			if (EQA_Profiles__c.getValues(profileId.Id) != null) {
				eqaProfilesList.add(new EqaProfiles_Wrapper(EQA_Profiles__c.getValues(profileId.Id), profileId.Name, profileId.Id));
			}
		}
		eqaNotificationCS = EQA_Notification_Settings__c.getOrgDefaults();
		eqaEscalationCS = EQA_Escalation_Settings__c.getOrgDefaults();
		notificationCs = Notification_Settings__c.getOrgDefaults();
		eqaOwnerRulesList = filleqaOwnerRulesList();


    }
     
	//wrapper for EQA_Quick_Reports_Fields__c custom settings 
   	class EQA_Quick_Reports_Fields_Wrapper  {
		
		public Id csId {get; set;}
		public String name {get;set;}
        public String fieldAPIName{get;set;}
     	public String fieldLabel {get;set;}
        public String reportName {get;set;}
		public String[] reportNameList {get;set;} //for multiselect picklist
        public Boolean isDisplayable {get;set;}
		public Boolean isLookup {get;set;}
		public Boolean isReportable {get;set;}
        
		public EQA_Quick_Reports_Fields_Wrapper(EQA_Quick_Reports_Fields__c cs){
			csId = cs.Id;
            name = cs.Name;
			fieldAPIName = cs.Field_API_Name__c;
			fieldLabel = cs.Field_Label__c;
			reportName = cs.Report_Name__c;
			isDisplayable = cs.isDisplayable__c;
			isLookup = cs.isLookup__c;
			isReportable = cs.isReportable__c;
			reportNameList = (reportName != null && reportName != '')? reportName.split(',',0) : null;
        }     
    }

	//wrapper for EQA_Quick_Reports_API_Names__c custom settings 
   	class EQA_Quick_Reports_API_Names_Wrapper  {
		
		public Id csId {get; set;}
		public String name {get;set;}
        public String reportName{get;set;}
     	public String objectAPIName {get;set;}
        
		public EQA_Quick_Reports_API_Names_Wrapper(EQA_Quick_Reports_API_Names__c cs){
			csId = cs.Id;
            name = cs.Name;
			reportName = cs.Report_Name__c;
			objectAPIName = cs.Object_API_Name__c;
        }     
    }
	
	//wrapper for EQA_Quick_Reports_Filters__c custom settings 
   	class EQA_Quick_Reports_Filters_Wrapper  {
		
		public Id csId {get; set;}
		public String name {get;set;}
        public String fieldAPIName{get;set;}
     	public String fieldLabel {get;set;}
        public String reportName {get;set;}
		public String[] reportNameList {get;set;} //for multiselect picklist
        public String type {get;set;}
        
		public EQA_Quick_Reports_Filters_Wrapper(EQA_Quick_Reports_Filters__c cs){
			csId = cs.Id;
            name = cs.Name;
			fieldAPIName = cs.Field_API_Name__c;
			fieldLabel = cs.Field_Label__c;
			reportName = cs.Report_Name__c;
			type = cs.Type__c;
			reportNameList = (reportName != null && reportName != '')? reportName.split(',',0) : null;
        }     
    }

	//deletes Dealer_Backfeed_Business_Rules__c custom setting
	public void Del(){

		if(CSId_toDel != null && CSId_toDel != ''){

			Database.DeleteResult delResult = DataBase.delete((Id)CSId_toDel, false);
 
			if (!delResult.isSuccess()) { 
				for (Database.Error err : delResult.getErrors()){
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Custom setting was not deleted, something bad happened!'));
				  }
			}
		}

		if (csType == 'EQA_Quick_Reports_Fields__c'){
			for (Integer i = 0; i < EQAQuickReportsFieldsCS_Wrapped.size(); i++){
				if (EQAQuickReportsFieldsCS_Wrapped[i].name == CSName_toDel){
					EQAQuickReportsFieldsCS_Wrapped.remove(i);
					break;
				}
			}
		} else if (csType == 'EQA_Quick_Reports_API_Names__c'){
			for (Integer i = 0; i < EQAQuickReportsAPINamesCS_Wrapped.size(); i++){
				if (EQAQuickReportsAPINamesCS_Wrapped[i].name == CSName_toDel){
					EQAQuickReportsAPINamesCS_Wrapped.remove(i);
					break;
				}
			}
		} else if (csType == 'EQA_Quick_Reports_Filters__c'){
			for (Integer i = 0; i < EQAQuickReportsFiltersCS_Wrapped.size(); i++){
				if (EQAQuickReportsFiltersCS_Wrapped[i].name == CSName_toDel){
					EQAQuickReportsFiltersCS_Wrapped.remove(i);
					break;
				}
			}
        } else if (csType == 'EQA_Owner_Rules__c'){
			for (Integer i = 0; i < eqaOwnerRulesList.size(); i++){
				if (eqaOwnerRulesList[i].csname == CSName_toDel){
					eqaOwnerRulesList.remove(i);
					break;
				}
			}
		}
	
        if(ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'Custom setting was successfully deleted!' ));
        }
    }

	//Adds custom setting
	public void Add_EQAQuickReportsFields(){
        EQAQuickReportsFieldsCS_Wrapped.add(new EQA_Quick_Reports_Fields_Wrapper (new EQA_Quick_Reports_Fields__c(id = null, Name = 'EQAQRF_CS_' + datetime.now().getTime())));
    }

	public void Add_EQAQuickReportsAPINames(){
        EQAQuickReportsAPINamesCS_Wrapped.add(new EQA_Quick_Reports_API_Names_Wrapper (new EQA_Quick_Reports_API_Names__c(id = null, Name = 'EQAQRAPIN_CS_' + datetime.now().getTime())));
    }

	public void Add_EQAQuickReportsFilters(){
        EQAQuickReportsFiltersCS_Wrapped.add(new EQA_Quick_Reports_Filters_Wrapper (new EQA_Quick_Reports_Filters__c(id = null, Name = 'EQAQRFil_CS_' + datetime.now().getTime())));
    }
	
	//saves custom setting
	public void Save_EQAQuickReportsFields(){
		
		List<EQA_Quick_Reports_Fields__c> EQAQuickReportsFieldsCS_toUpsert = new List<EQA_Quick_Reports_Fields__c>();

		for(EQA_Quick_Reports_Fields_Wrapper cs : EQAQuickReportsFieldsCS_Wrapped){
            if (!String.isEmpty(cs.fieldAPIName) && !String.isEmpty(cs.fieldLabel)) {                
                cs.reportName = '';
                if (cs.reportNameList!= null && !cs.reportNameList.isEmpty()){
                    for (String s : cs.reportNameList){
                        cs.reportName += s + ',';
                    }
                    cs.reportName = cs.reportName.removeEnd(',');
                }
    
                EQAQuickReportsFieldsCS_toUpsert.add(new EQA_Quick_Reports_Fields__c(id = cs.csid,
                                                                                    Name = cs.name,
                                                                                    Field_API_Name__c = cs.fieldAPIName,
                                                                                    Field_Label__c = cs.fieldLabel,
                                                                                    Report_Name__c = cs.reportName,
                                                                                    isDisplayable__c = cs.isDisplayable,
                                                                                    isLookup__c = cs.isLookup,
                                                                                    isReportable__c = cs.isReportable));
            }else {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, fill Field API Name and Field Label fields'));
                return;
            }
		}

		Database.UpsertResult[] result = DataBase.upsert(EQAQuickReportsFieldsCS_toUpsert, false);

		EQAQuickReportsFieldsCS_Wrapped.clear();
		for(EQA_Quick_Reports_Fields__c cs : EQAQuickReportsFieldsCS_toUpsert){
			EQAQuickReportsFieldsCS_Wrapped.add(new EQA_Quick_Reports_Fields_Wrapper(cs));
		}
		
		for(Database.UpsertResult r : result){
			if (!r.isSuccess()) { 
				for (Database.Error err : r.getErrors()){
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
				  }
			}
		}
	
        if(ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'Custom settings were successfully updated/inserted!' ));
        }
        
    }
	
	public void Save_EQAQuickReportsAPINames(){
		List<EQA_Quick_Reports_API_Names__c> EQAQuickReportsAPINames_toUpsert = new List<EQA_Quick_Reports_API_Names__c>();

		for(EQA_Quick_Reports_API_Names_Wrapper cs : EQAQuickReportsAPINamesCS_Wrapped){
			if (!String.isEmpty(cs.reportName) && !String.isEmpty(cs.objectAPIName)) {
			EQAQuickReportsAPINames_toUpsert.add(new EQA_Quick_Reports_API_Names__c(id = cs.csid,
																				Name = cs.name,
																				Report_Name__c = cs.reportName,
																				Object_API_Name__c = cs.objectAPIName));
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, fill Field API Name and Field Label fields'));
                return;
            }
		}

		Database.UpsertResult[] result = DataBase.upsert(EQAQuickReportsAPINames_toUpsert, false);

		EQAQuickReportsAPINamesCS_Wrapped.clear();
		for(EQA_Quick_Reports_API_Names__c cs : EQAQuickReportsAPINames_toUpsert){
			EQAQuickReportsAPINamesCS_Wrapped.add(new EQA_Quick_Reports_API_Names_Wrapper(cs));
		}
		
		for(Database.UpsertResult r : result){
			if (!r.isSuccess()) { 
				for (Database.Error err : r.getErrors()){
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
				  }
			}
		}
	
        if(ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'Custom settings were successfully updated/inserted!' ));
        }
	}

	public void Save_EQAQuickReportsFilters(){
		
		List<EQA_Quick_Reports_Filters__c> EQAQuickReportsFilters_toUpsert = new List<EQA_Quick_Reports_Filters__c>();

		for(EQA_Quick_Reports_Filters_Wrapper cs : EQAQuickReportsFiltersCS_Wrapped){
			if (!String.isEmpty(cs.fieldAPIName) && !String.isEmpty(cs.fieldLabel)) {
                cs.reportName = '';
                if (cs.reportNameList!= null && !cs.reportNameList.isEmpty()){
                    for (String s : cs.reportNameList){
                        cs.reportName += s + ',';
                    }
                    cs.reportName = cs.reportName.removeEnd(',');
                }
    
                EQAQuickReportsFilters_toUpsert.add(new EQA_Quick_Reports_Filters__c(id = cs.csid,
                                                                                    Name = cs.name,
                                                                                    Field_API_Name__c = cs.fieldAPIName,
                                                                                    Field_Label__c = cs.fieldLabel,
                                                                                    Report_Name__c = cs.reportName,
                                                                                    Type__c = cs.type));
            }else {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, fill Field API Name and Field Label fields'));
                return;
            }
        }

		Database.UpsertResult[] result = DataBase.upsert(EQAQuickReportsFilters_toUpsert, false);

		EQAQuickReportsFiltersCS_Wrapped.clear();
		for(EQA_Quick_Reports_Filters__c cs : EQAQuickReportsFilters_toUpsert){
			EQAQuickReportsFiltersCS_Wrapped.add(new EQA_Quick_Reports_Filters_Wrapper(cs));
		}
		
		for(Database.UpsertResult r : result){
			if (!r.isSuccess()) { 
				for (Database.Error err : r.getErrors()){
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, err.getStatusCode() + ': ' + err.getMessage()));
				  }
			}
		}
	
        if(ApexPages.getMessages().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'Custom settings were successfully updated/inserted!' ));
        }
	}

	//cancel
	public void Cancel(){
        
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
		public Id profileId {get ; set ;}
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
		eqaOwnerRulesList.add(new EqaCor_Wrapper(new EQA_Owner_Rules__c(Current_Owner__c='', Profile_Id__c=null, name='1' + datetime.now().getTime())));

	}

	public void SaveEqaCor(){
		List<EQA_Owner_Rules__c> eqaOwnerRulesList_toUpsert = new List<EQA_Owner_Rules__c> ();

		for (EqaCor_Wrapper cs : eqaOwnerRulesList) {
            if (!String.isEmpty(cs.profileId) || !String.isEmpty(cs.currentOwner)) {
			eqaOwnerRulesList_toUpsert.add(new EQA_Owner_Rules__c(id = cs.csid,
																Name = cs.currentOwner + cs.profileId,
																Current_Owner__c = cs.currentOwner,
																Edit__c = cs.edit,
																Profile_Id__c = ((String)cs.profileId).substring(0,15)));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, select Profile Id and Current Owner from droplist'));
                return;
            }   
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