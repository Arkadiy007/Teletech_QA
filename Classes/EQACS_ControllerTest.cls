@isTest
public class EQACS_ControllerTest { 

	private static void setupTestData(){
		List<EQA_Quick_Reports_API_Names__c> EQAQuickReportsAPINamesCS = new List<EQA_Quick_Reports_API_Names__c>();
		List<EQA_Quick_Reports_Fields__c> EQAQuickReportsFieldsCS = new List<EQA_Quick_Reports_Fields__c>();
		List<EQA_Quick_Reports_Filters__c> EQAQuickReportsFiltersCS = new List<EQA_Quick_Reports_Filters__c>();
		List<EQA_Owner_Rules__c> EQAOwnerRuleCS = new List<EQA_Owner_Rules__c>();

		EQAQuickReportsAPINamesCS.add(new EQA_Quick_Reports_API_Names__c(Name = 'EQAAPI1',
																		Object_API_Name__c = 'API_Name',
																		Report_Name__c = 'Rep Name'));
		EQAQuickReportsAPINamesCS.add(new EQA_Quick_Reports_API_Names__c(Name = 'EQAAPI2',
																		Object_API_Name__c = 'API_Name1',
																		Report_Name__c = 'Rep Name2'));

		insert EQAQuickReportsAPINamesCS;

		EQAQuickReportsFieldsCS.add(new EQA_Quick_Reports_Fields__c(Name = 'EQAField1',
																	isDisplayable__c =true,
																	Field_API_Name__c = 'testt',
																	Report_Name__c = 'Rep Name'));
		EQAQuickReportsFieldsCS.add(new EQA_Quick_Reports_Fields__c(Name = 'EQAField2',
																	isDisplayable__c =false,
																	Field_API_Name__c = 'testt',
																	Report_Name__c = 'Rep Name2'));
		insert EQAQuickReportsFieldsCS;

		EQAQuickReportsFiltersCS.add(new EQA_Quick_Reports_Filters__c(Name = 'EQAFiltr1',
																	Report_Name__c = 'Rep Name',
																	Type__c = 'Boolean'));
		insert EQAQuickReportsFiltersCS;

		Profile p = [SELECT Id, Name FROM Profile LIMIT 1];

		EQAOwnerRuleCS.add(new EQA_Owner_Rules__c(Name = 'EQAOwnerRule1',
												Current_Owner__c = 'EQA',
												Profile_Id__c = ((String)p.id).substring(0,15)));
		EQAOwnerRuleCS.add(new EQA_Owner_Rules__c(Name = 'EQAOwnerRule2',
												Current_Owner__c = 'Supplier',
												Profile_Id__c = ((String)p.id).substring(0,15)));
		insert EQAOwnerRuleCS;

		List<EQA_Profiles__c> eqaProfiles_Cs = new List<EQA_Profiles__c>(); 
		eqaProfiles_Cs.add(EQA_Profiles__c.getOrgDefaults());
		eqaProfiles_Cs[0].Validation_Rules__c = true;
		eqaProfiles_Cs[0].Validation_Rules_for_MC__c = true;
		//eqaProfiles_Cs.add( new EQA_Profiles__c(Validation_Rules__c = true, Validation_Rules_for_MC__c = true));

		upsert eqaProfiles_Cs;

	}

	@isTest
	static void Del_EQAQuickReports_Test(){
		setupTestData();
		
		Test.startTest();

		EQACS_Controller controller = new EQACS_Controller();
		System.assertEquals(2, controller.EQAQuickReportsFieldsCS_Wrapped.size());
		System.assertEquals(1, controller.EQAQuickReportsFiltersCS_Wrapped.size());
		System.assertEquals(2, controller.EQAQuickReportsAPINamesCS_Wrapped.size());

		controller.CSId_toDel = controller.EQAQuickReportsFieldsCS_Wrapped[0].csId;
		controller.CSName_toDel = controller.EQAQuickReportsFieldsCS_Wrapped[0].Name;
		controller.csType = 'EQA_Quick_Reports_Fields__c';

		controller.Del();
		
		Test.stopTest();

		System.assertEquals(1, controller.EQAQuickReportsFieldsCS_Wrapped.size());
		System.assertEquals(1, [SELECT id FROM EQA_Quick_Reports_Fields__c].size());
	
	}
	
	@isTest
	static void Save_EQAQuickReports_Test(){
		setupTestData();
		
		Test.startTest();

		EQACS_Controller controller = new EQACS_Controller();

		controller.Add_EQAQuickReportsAPINames();
		controller.Add_EQAQuickReportsAPINames();
		controller.Add_EQAQuickReportsFields();
		controller.Add_EQAQuickReportsFilters();

		System.assertEquals(4, controller.EQAQuickReportsAPINamesCS_Wrapped.size());
		System.assertEquals(3, controller.EQAQuickReportsFieldsCS_Wrapped.size());
		System.assertEquals(2, controller.EQAQuickReportsFiltersCS_Wrapped.size());

		controller.CSId_toDel = controller.EQAQuickReportsAPINamesCS_Wrapped[3].csId;
		controller.CSName_toDel = controller.EQAQuickReportsAPINamesCS_Wrapped[3].Name;
		controller.csType = 'EQA_Quick_Reports_API_Names__c';

		controller.Del();

		controller.EQAQuickReportsAPINamesCS_Wrapped[2].reportName ='Report3';
		controller.Save_EQAQuickReportsAPINames();

		controller.EQAQuickReportsFiltersCS_Wrapped[1].reportNameList = new List<String> {'Report3'};
		controller.Save_EQAQuickReportsFilters();

		controller.EQAQuickReportsFieldsCS_Wrapped[0].reportNameList = new List<String> {'Report3', 'Rep Name'};
		controller.Save_EQAQuickReportsFields();
		
		Test.stopTest();

		System.assertNotEquals(null, controller.EQAQuickReportsAPINamesCS_Wrapped[2].csId);
		System.assertEquals(3, [SELECT id FROM EQA_Quick_Reports_API_Names__c].size());
		System.assertEquals(3, [SELECT id FROM EQA_Quick_Reports_Fields__c].size());
		System.assertEquals(2, [SELECT id FROM EQA_Quick_Reports_Filters__c].size());
	
	}
	
	@isTest
	static void EQAOwnerRules_Test(){
		setupTestData();
		
		Test.startTest();

		EQACS_Controller controller = new EQACS_Controller();
		System.assertEquals(2, controller.eqaOwnerRulesList.size());

		controller.CSId_toDel = controller.eqaOwnerRulesList[1].csId;
		controller.CSName_toDel = controller.eqaOwnerRulesList[1].csName;
		controller.csType = 'EQA_Owner_Rules__c';

		controller.delEqaCor();
		System.assertEquals(1, controller.eqaOwnerRulesList.size());
		System.assertEquals(1, [SELECT id FROM EQA_Owner_Rules__c].size());

		controller.addEqaCor();

		controller.eqaOwnerRulesList[1].currentOwner = 'Customer';
		controller.eqaOwnerRulesList[1].profileId = controller.eqaOwnerRulesList[0].profileId;

		controller.SaveEqaCor();
		
		Test.stopTest();

		System.assertEquals(2, controller.eqaOwnerRulesList.size());
		System.assertEquals(2, [SELECT id FROM EQA_Owner_Rules__c].size());
	
	}

	@isTest
	static void EQAProfiles_Test(){
		setupTestData();
		
		Test.startTest();

		EQACS_Controller controller = new EQACS_Controller();
		System.assertEquals(1, controller.eqaProfilesList.size());

		controller.eqaProfilesList[0].validationRules = false;

		controller.SaveEqaProfiles();
		
		Test.stopTest();

		System.assertEquals(false, EQA_Profiles__c.getOrgDefaults().Validation_Rules__c);
	
	}
}