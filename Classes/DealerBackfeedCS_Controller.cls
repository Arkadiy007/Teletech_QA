public class DealerBackfeedCS_Controller {

	public Dealer_Backfeed_XML_Enabled__c xmlEnabledCS { get; set; }
	public List<Dealer_Backfeed_Business_Rules_Wrapper> dealerBackfeedBusinessRulesCS_Wrapped { get; set; }
	public List<USW_Case_Mappings_Wrapper> uswCaseMappingsCS_Wrapped { get; set; }
	public List<SelectOption> RecTypeList { get; private set; }
	public List<SelectOption> devRecTypeList { get; private set; }

	public String CSId_toDel { get; set; }
	public String CSName_toDel { get; set; }
	public String csType { get; set; }

	private List<Dealer_Backfeed_Business_Rules__c> dealerBackfeedBusinessRulesCS;
	private List<USW_Case_Mappings__c> uswCaseMappingsCS;

	//constructor
	public DealerBackfeedCS_Controller() {
		//Dealer_Backfeed_XML_Enabled__c
		xmlEnabledCS = Dealer_Backfeed_XML_Enabled__c.getOrgDefaults();

		//Dealer_Backfeed_Business_Rules__c
		dealerBackfeedBusinessRulesCS = Dealer_Backfeed_Business_Rules__c.getAll().values();
		uswCaseMappingsCS = USW_Case_Mappings__c.getAll().values();
		dealerBackfeedBusinessRulesCS_Wrapped = new List<Dealer_Backfeed_Business_Rules_Wrapper> ();
		uswCaseMappingsCS_Wrapped = new List<USW_Case_Mappings_Wrapper> ();

		for (Dealer_Backfeed_Business_Rules__c cs : dealerBackfeedBusinessRulesCS) {
			dealerBackfeedBusinessRulesCS_Wrapped.add(new Dealer_Backfeed_Business_Rules_Wrapper(cs));
		}

		for (USW_Case_Mappings__c cs : uswCaseMappingsCS) {
			uswCaseMappingsCS_Wrapped.add(new USW_Case_Mappings_Wrapper(cs));
		}

		//Case RecordTypes picklist
		RecTypeList = new List<SelectOption> ();
		devRecTypeList = new List<SelectOption> ();
		RecTypeList.add(new SelectOption('', '-----'));
		devRecTypeList.add(new SelectOption('', '-----'));

		for (RecordType rt :[SELECT Id, Name, DeveloperName FROM RecordType WHERE Sobjecttype = 'Case']) {
			RecTypeList.add(new SelectOption(rt.id, rt.Name));
			devRecTypeList.add(new SelectOption(rt.DeveloperName, rt.DeveloperName));
		}

	}

	//wrapper for Dealer_Backfeed_Business_Rules__c custom settings 
	class Dealer_Backfeed_Business_Rules_Wrapper {

		public Id csId { get; set; }
		public String name { get; set; }
		public String nameValue { get; set; }
		public String originValue { get; set; }
		public String recordTypeValue { get; set; }
		public String serviceNameValue { get; set; }

		public Dealer_Backfeed_Business_Rules_Wrapper(Dealer_Backfeed_Business_Rules__c cs) {
			csId = cs.Id;
			name = cs.Name;
			nameValue = cs.NameValue__c;
			originValue = cs.OriginValue__c;
			recordTypeValue = cs.RecordTypeValue__c;
			serviceNameValue = cs.ServiceNameValue__c;
		}
	}

	//wrapper for USW_Case_Mappings__c custom settings 
	class USW_Case_Mappings_Wrapper {

		public Id csId { get; set; }
		public String name { get; set; }
		public String usFieldName { get; set; }
		public String caseRecordType { get; set; }
		public String sfFieldName { get; set; }

		public USW_Case_Mappings_Wrapper(USW_Case_Mappings__c cs) {
			csId = cs.Id;
			name = cs.Name;
			usFieldName = cs.US_Field_Name__c;
			caseRecordType = cs.Case_Record_Type__c;
			sfFieldName = cs.SF_Field_Name__c;
		}
	}

	//deletes Dealer_Backfeed_Business_Rules__c custom setting
	public void Del() {

		if (CSId_toDel != null && CSId_toDel != '') {

			Database.DeleteResult delResult = DataBase.delete((Id) CSId_toDel, false);

			if (!delResult.isSuccess()) {
				for (Database.Error err : delResult.getErrors()) {
					System.debug(err);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Custom setting was not deleted, something bad happened!'));
				}
			}
		}

		if (csType == 'Dealer_Backfeed_Business_Rules__c') {
			for (Integer i = 0; i < dealerBackfeedBusinessRulesCS_Wrapped.size(); i++) {
				if (dealerBackfeedBusinessRulesCS_Wrapped[i].name == CSName_toDel) {
					dealerBackfeedBusinessRulesCS_Wrapped.remove(i);
					break;
				}
			}
		} else if (csType == 'USW_Case_Mappings__c') {
			for (Integer i = 0; i < uswCaseMappingsCS_Wrapped.size(); i++) {
				if (uswCaseMappingsCS_Wrapped[i].name == CSName_toDel) {
					uswCaseMappingsCS_Wrapped.remove(i);
					break;
				}
			}
		}

		if (ApexPages.getMessages().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Custom setting was successfully deleted!'));
		}
	}

	//Adds custom setting
	public void Add() {
		dealerBackfeedBusinessRulesCS_Wrapped.add(new Dealer_Backfeed_Business_Rules_Wrapper(new Dealer_Backfeed_Business_Rules__c(id = null, Name = 'DBBR_CS_' + datetime.now().getTime())));
	}

	//saves custom setting
	public void Save() {

		List<Dealer_Backfeed_Business_Rules__c> dealerBackfeedBusinessRulesCS_toUpsert = new List<Dealer_Backfeed_Business_Rules__c> ();

		for (Dealer_Backfeed_Business_Rules_Wrapper cs : dealerBackfeedBusinessRulesCS_Wrapped) {
		System.debug('133' + cs.recordTypeValue);
			if (!String.isEmpty(cs.recordTypeValue)) {
				dealerBackfeedBusinessRulesCS_toUpsert.add(new Dealer_Backfeed_Business_Rules__c(id = cs.csid,
				                                                                                 Name = cs.name,
				                                                                                 NameValue__c = cs.nameValue,
				                                                                                 OriginValue__c = cs.originValue,
				                                                                                 RecordTypeValue__c = cs.recordTypeValue,
				                                                                                 ServiceNameValue__c = cs.serviceNameValue));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, select Case Record Type from picklists'));
				return;
			}
		}

		Database.UpsertResult[] result = DataBase.upsert(dealerBackfeedBusinessRulesCS_toUpsert, false);

		dealerBackfeedBusinessRulesCS_Wrapped.clear();
		for (Dealer_Backfeed_Business_Rules__c cs : dealerBackfeedBusinessRulesCS_toUpsert) {
			dealerBackfeedBusinessRulesCS_Wrapped.add(new Dealer_Backfeed_Business_Rules_Wrapper(cs));
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

	//cancel
	public void Cancel() {

	}

	public void SaveXMLEnable() {
		Database.SaveResult result = DataBase.update(xmlEnabledCS, false);

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

	public void AddUSW() {
		uswCaseMappingsCS_Wrapped.add(new USW_Case_Mappings_Wrapper(new USW_Case_Mappings__c(id = null, Name = 'USW_CS_' + datetime.now().getTime())));
	}

	public void SaveUSW() {

		List<USW_Case_Mappings__c> uswCaseMappingsCS_toUpsert = new List<USW_Case_Mappings__c> ();

		for (USW_Case_Mappings_Wrapper cs : uswCaseMappingsCS_Wrapped) {
			if (!String.isEmpty(cs.caseRecordType)) {
				uswCaseMappingsCS_toUpsert.add(new USW_Case_Mappings__c(id = cs.csid,
				                                                        Name = cs.name,
				                                                        US_Field_Name__c = cs.usFieldName,
				                                                        Case_Record_Type__c = cs.caseRecordType,
				                                                        SF_Field_Name__c = cs.sfFieldName));

			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please, select Case Record Type from picklists'));
				return;
			}
		}

		Database.UpsertResult[] result = DataBase.upsert(uswCaseMappingsCS_toUpsert, false);

		uswCaseMappingsCS_Wrapped.clear();
		for (USW_Case_Mappings__c cs : uswCaseMappingsCS_toUpsert) {
			uswCaseMappingsCS_Wrapped.add(new USW_Case_Mappings_Wrapper(cs));
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