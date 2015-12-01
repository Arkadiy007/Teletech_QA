public class PreviousSolutionsController {
    public Boolean relatedRecordsAvailable {get { if(relatedRecords.size() > 0){ return true; } else {return false;}}}
    public List<CSVHandler.CaseWrapper> relatedRecords {get; Set;}   
    public Map<String, String> stringFilters {get; set;}

	Public Date startTimeFilter {get; set;}
	Public Date endTimeFilter {get; set;}

	private ApexPages.StandardController recordController {get; set;}	

    public PreviousSolutionsController(ApexPages.StandardController sc){
		relatedRecords = new List<CSVHandler.CaseWrapper>();
		recordController = sc;

		stringFilters = new Map<String, String>();
		stringFilters.put('model_line', '');
		stringFilters.put('model_year', '');
		stringFilters.put('model_make', '');
		stringFilters.put('dealer_code', '');
		stringFilters.put('district_code', '');
		stringFilters.put('regiona', '');
		stringFilters.put('dtc_1', '');
		stringFilters.put('dtc_2', '');
		stringFilters.put('dtc_3', '');
		stringFilters.put('related_field_inspection', '');
		stringFilters.put('subject', '');
		stringFilters.put('factory_installed_options', '');
		stringFilters.put('head_unit', '');
		stringFilters.put('manufacture_date', '');
		stringFilters.put('component_code', '');

		stringFilters.put('component_code_issue', '');
		stringFilters.put('positive_confirmation', '');
		stringFilters.put('model_variation', '');

		stringFilters.put('symptomatic_object', '');
		stringFilters.put('recommended_object', '');
		stringFilters.put('recommended_action', '');


		relatedRecords = GetCases();
		//HerokuApi.CreateRecords(createRecord());
    
		if (relatedRecords.size() == 0){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'No records were returned from Heroku');
			ApexPages.addMessage(myMsg);
		}
		
	}

	private List<CSVHandler.CaseWrapper> GetCases() {
		
		Map<String,Object> params = new Map<String,Object>();
		params.put('table_name', 'sfdcdatafeed');		
		populateParamsForCase(params);


		/* 	mockResponse
		*/
		if (params.size() == 1){
			params.put('model_line', new List<String>{'ALTIMA', 'Rogue'});
			params.put('model_year', '2015');
			params.put('model_make', 'NISSAN');
			params.put('dealer_code', '2831');
			params.put('district_code', '12');
			params.put('dtc_1', 'B2636');
			params.put('dtc_2', 'B2636');
			params.put('related_field_inspection', 'Clicking noise');
			params.put('dtc_3', 'B2636');
			params.put('subject', 'System Account NNAINT');
			params.put('factory_installed_options', 'B93C03H01L92R09X01');
			params.put('head_unit', 'DA2.2.kai');
			params.put('manufacture_date', '2014-05-27');
		}
		
	

		String herokuResponse = HerokuApi.GetCaseRecords(params);
		return CSVHandler.getDecodedCasesFromCsv(herokuResponse);
	}


	public Pagereference search() {
		
		Map<String,Object> params = new Map<String,Object>();
		params.put('table_name', 'sfdcdatafeed');		
		
		for(String key : stringFilters.keySet()){
			if (String.isNotEmpty(stringFilters.get(key))){
				params.put(key, (Object) stringFilters.get(key));
			}
		}
		
		if (startTimeFilter != null)
		{
			params.put('created_date_start', (Object) startTimeFilter);
		}

		if (endTimeFilter != null)
		{
			params.put('created_date_end', (Object) endTimeFilter);
		}

		String herokuResponse = HerokuApi.GetCaseRecords(params);
		relatedRecords = CSVHandler.getDecodedCasesFromCsv(herokuResponse);

		return null;
	}
		
	

	private void populateParamsForCase(Map<String, Object> params){
		if(recordController.getId() != null){
			Id recordId = recordController.getId();
			Case tempCaseHolder = [SELECT Id, Recommended_Action__c, Model_Line__c, Incident_RO_Date__c, Engine_Number__c, Recommended_Object__c, What_action_was_taken__c, Symptomatic_Object__c, Dealer__r.Previous_Mailing_Country__c, Dealer__r.DealerCodeNCV__c, Dealer__r.District_Code__c, Dealer__r.RegionName__c, Case_Age__c, RecordTypeId, Component_Code__c, Component_Code_Issue__c, CreatedDate, DTC_1__c, DTC_2__c, DTC_3__c, LastModifiedBy.Name, Subject, DTS_Field_Inspection__c, Vehicle_Name__r.Engine_Number__c, Vehicle_Name__r.Factory_Installed_Options__c, Vehicle_Name__r.Head_Unit__c, Vehicle_Name__r.Make_Name__c, Vehicle_Name__r.Manufacturer_Date__c, Vehicle_Name__r.Model_Line_Name__c, Vehicle_Name__r.Model_Name__c, ModelIDFromVehicle__c, Vehicle_Name__r.Model_Year__c FROM Case WHERE Id = :recordId LIMIT 1][0];
			params.put('model_line', tempCaseHolder.Model_Line__c);
			params.put('model_year', tempCaseHolder.Vehicle_Name__r.Model_Year__c);
			params.put('dealer_code', tempCaseHolder.Dealer__r.DealerCodeNCV__c);
		}
	}
	
	private Map<String, Object> createRecord(){
		Map<String, Object> params = new Map<String, Object>(); 
		
		if(recordController.getId() != null){
			Id recordId = recordController.getId();
		
			Case tempCaseHolder = [SELECT Id, Recommended_Action__c, Model_Line__c, Incident_RO_Date__c, Engine_Number__c, Recommended_Object__c, What_action_was_taken__c, Symptomatic_Object__c, Dealer__r.Previous_Mailing_Country__c, Dealer__r.DealerCodeNCV__c, Dealer__r.District_Code__c, Dealer__r.RegionName__c, Case_Age__c, RecordTypeId, Component_Code__c, Component_Code_Issue__c, CreatedDate, DTC_1__c, DTC_2__c, DTC_3__c, LastModifiedBy.Name, Subject, DTS_Field_Inspection__c, Vehicle_Name__r.Engine_Number__c, Vehicle_Name__r.Factory_Installed_Options__c, Vehicle_Name__r.Head_Unit__c, Vehicle_Name__r.Make_Name__c, Vehicle_Name__r.Manufacturer_Date__c, Vehicle_Name__r.Model_Line_Name__c, Vehicle_Name__r.Model_Name__c, ModelIDFromVehicle__c, Vehicle_Name__r.Model_Year__c FROM Case WHERE Id = :recordId LIMIT 1][0];
			params.put('Id', tempCaseHolder.Id);
			params.put('model_year', tempCaseHolder.Dealer__r.Previous_Mailing_Country__c);
			params.put('dealer_code', tempCaseHolder.Dealer__r.DealerCodeNCV__c);
			params.put('district_code', tempCaseHolder.Dealer__r.District_Code__c);
			params.put('regiona', tempCaseHolder.Dealer__r.Previous_Mailing_Country__c);
			params.put('age', tempCaseHolder.Case_Age__c);
			params.put('case_record_type', tempCaseHolder.RecordTypeId);
			params.put('component_code', tempCaseHolder.Component_Code__c);
			params.put('component_code_issue', tempCaseHolder.Component_Code_Issue__c);
			params.put('created_date', tempCaseHolder.CreatedDate);
			params.put('dtc_1', tempCaseHolder.DTC_1__c);
			params.put('dtc_2', tempCaseHolder.DTC_2__c);
			params.put('dtc_3', tempCaseHolder.DTC_3__c);
			params.put('last_modified_by_full_name', tempCaseHolder.LastModifiedBy.Name);
			params.put('recommended_action', tempCaseHolder.Recommended_Action__c);
			params.put('recommended_object', tempCaseHolder.Recommended_Object__c);
			params.put('subject', tempCaseHolder.Subject);
			params.put('symptom_action', tempCaseHolder.What_action_was_taken__c);
			params.put('symptomatic_object', tempCaseHolder.Symptomatic_Object__c);
			params.put('related_field_inspection', tempCaseHolder.DTS_Field_Inspection__c);
			params.put('ro', tempCaseHolder.Incident_RO_Date__c);
			params.put('engine', tempCaseHolder.Engine_Number__c);
			params.put('factory_installed_options', tempCaseHolder.Vehicle_Name__r.Factory_Installed_Options__c);
			params.put('head_unit', tempCaseHolder.Vehicle_Name__r.Head_Unit__c);
			params.put('make', tempCaseHolder.Vehicle_Name__r.Make_Name__c);
			params.put('manufacture_date', tempCaseHolder.Vehicle_Name__r.Manufacturer_Date__c);
			params.put('model_line', tempCaseHolder.Vehicle_Name__r.Model_Line_Name__c);
			params.put('model_name', tempCaseHolder.Vehicle_Name__r.Model_Name__c);
			params.put('model_variation', tempCaseHolder.ModelIDFromVehicle__c);
			params.put('model_year', tempCaseHolder.Vehicle_Name__r.Model_Year__c);
		
			params.put('table_name', 'sfdcdatafeed');		
		}

		return params;
	}
}