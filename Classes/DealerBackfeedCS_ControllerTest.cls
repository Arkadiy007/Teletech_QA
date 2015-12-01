@isTest
public class DealerBackfeedCS_ControllerTest { 

	private static void setupTestData(){
		List<Dealer_Backfeed_Business_Rules__c> dealerBackfeedBusinessRulesCS = new List<Dealer_Backfeed_Business_Rules__c>();
		List<USW_Case_Mappings__c> uswCaseMappingsCS = new List<USW_Case_Mappings__c>();

		List<RecordType> rtList =  [SELECT Id, Name, DeveloperName FROM RecordType WHERE Sobjecttype = 'Case' Limit 2];

		dealerBackfeedBusinessRulesCS.add(new Dealer_Backfeed_Business_Rules__c(Name = 'Test1',
																				NameValue__c = 'NameValueTest',
																				OriginValue__c = 'OriginValueTest',
																				RecordTypeValue__c = rtList[0].Id,
																				ServiceNameValue__c = 'SVNameValue'));
		dealerBackfeedBusinessRulesCS.add(new Dealer_Backfeed_Business_Rules__c(Name = 'Test2',
																				NameValue__c = 'NameValueTest2',
																				OriginValue__c = 'OriginValueTest2',
																				RecordTypeValue__c = rtList[1].Id,
																				ServiceNameValue__c = 'SVNameValue2'));
		insert dealerBackfeedBusinessRulesCS;

		uswCaseMappingsCS.add(new USW_Case_Mappings__c(Name = 'USW1',
													Case_Record_Type__c = rtList[0].Id,
													SF_Field_Name__c = 'SF_Field_Name1',
													US_Field_Name__c = 'US_Field_Name1'));
		uswCaseMappingsCS.add(new USW_Case_Mappings__c(Name = 'USW2',
													Case_Record_Type__c = rtList[1].Id,
													SF_Field_Name__c = 'SF_Field_Name2',
													US_Field_Name__c = 'US_Field_Name2'));
		insert uswCaseMappingsCS;
	}

	@isTest
	static void Del_Test(){
		setupTestData();
		
		Test.startTest();

		DealerBackfeedCS_Controller controller = new DealerBackfeedCS_Controller();
		System.assertEquals(2, controller.dealerBackfeedBusinessRulesCS_Wrapped.size());
		System.assertEquals(2, controller.uswCaseMappingsCS_Wrapped.size());

		controller.CSId_toDel = controller.dealerBackfeedBusinessRulesCS_Wrapped[0].csId;
		controller.CSName_toDel = controller.dealerBackfeedBusinessRulesCS_Wrapped[0].Name;
		controller.csType = 'Dealer_Backfeed_Business_Rules__c';

		controller.Del();
		
		Test.stopTest();

		System.assertEquals(1, controller.dealerBackfeedBusinessRulesCS_Wrapped.size());
		System.assertEquals(1, [SELECT id FROM Dealer_Backfeed_Business_Rules__c].size());
	
	}

	@isTest
	static void SaveUSW_Test(){
		setupTestData();
		
		Test.startTest();

		DealerBackfeedCS_Controller controller = new DealerBackfeedCS_Controller();

		controller.AddUSW();
		System.assertEquals(3, controller.uswCaseMappingsCS_Wrapped.size());
		controller.uswCaseMappingsCS_Wrapped[2].sfFieldName ='testtest';
		controller.uswCaseMappingsCS_Wrapped[2].caseRecordType ='testrecordtype';

		controller.SaveUSW();
		
		Test.stopTest();

		System.assertNotEquals(null, controller.uswCaseMappingsCS_Wrapped[2].csId);
		System.assertEquals(3, [SELECT id FROM USW_Case_Mappings__c].size());
	
	}

	@isTest
	static void Save_Test(){
		setupTestData();
		
		Test.startTest();

		DealerBackfeedCS_Controller controller = new DealerBackfeedCS_Controller();

		controller.Add();
		System.assertEquals(3, controller.dealerBackfeedBusinessRulesCS_Wrapped.size());
		controller.dealerBackfeedBusinessRulesCS_Wrapped[2].serviceNameValue ='testtest2';
		controller.dealerBackfeedBusinessRulesCS_Wrapped[2].recordTypeValue ='testrecordtype';

		controller.Save();
		
		Test.stopTest();

		System.assertNotEquals(null, controller.dealerBackfeedBusinessRulesCS_Wrapped[2].csId);
		System.assertEquals(3, [SELECT id FROM Dealer_Backfeed_Business_Rules__c].size());
	
	}
}