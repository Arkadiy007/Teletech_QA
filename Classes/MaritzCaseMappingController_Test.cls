/**********************************************************************
Name: MaritzCaseMappingController_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for MaritzCaseMappingController
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class MaritzCaseMappingController_Test { 
	private static String SOURCE_OBJECT = 'Adhoc_Campaign_Object__c';
	private static String TARGET_OBJECT = 'Case';
	// For Field-to-Field mapping
	private static Map<String,String> SOURCE_TO_TARGET_FIELDS_MAP = new MAp<String,String> {'Address1__c' => 'Accident_Indicator__c',
																							'Address2__c' => 'Action_Flag__c',
																							'BankruptcyFL__c' => 'Additional_Days_Down__c',
																							'BonusCashCode__c' => 'Agent_Comments__c',
																							'City__c' => 'Alert_Trigger_Verbatim__c'};
	private static String CASE_RECORD_TYPE_NAME = 'CA';
	private static String RELATED_OBJECT_FOR_CASE_LOOKUP = 'Account';
	//RecordType name for Account ID lookup
	private static String REC_TYPE_FOR_ACCOUNTID_LOOKUP = 'Master';
	//RecordType name for Dealer lookup
	private static String REC_TYPE_FOR_DEALER_LOOKUP = 'Dealer';

	private static String OWNER_NAME = 'Aaron Bessey';
	private static String OWNER_TYPE = 'user';

	/*---------------------TESTS---------------------------------*/
	static testmethod void testOnFirstMappingsCreation() {
		PageReference pageRef = Page.MaritzCaseMapping;
		Test.setCurrentPage(pageRef);

		MaritzCaseMappingController controller = new MaritzCaseMappingController();
		controller.IntermMappingObject = SOURCE_OBJECT;
		controller.recalcDependValues();

		//Set Field-to-Field mapping
		controller.mappings[0].Source_field__c =  controller.mappingFields[1].getValue();

		//Set RecordType mapping
		controller.recordTypeMapping.Record_Type_Name__c =  controller.recordTypeSO[1].getValue();

		//Set Lookup mapping
		
		controller.lookupEntytyMapping[0].externalIdsOfTheRelateedObject =  controller.lookupEntytyMapping[0].externalIdsOfTheRelateedObjectSO[0].getValue();
		controller.lookupEntytyMapping[0].recordTypeOfTheRelatedObject =  controller.lookupEntytyMapping[0].recordTypeOfTheRelatedObjectSO[0].getValue();
		controller.lookupEntytyMapping[0].fieldOfIntermediateObject =  controller.lookupEntytyMapping[0].fieldsOfIntermediateObjectSO[2].getValue();
		
		//Set Static value mapping
		controller.addAdditionalMappingRow();
		controller.mappingsAdditional[0].Target_field__c = controller.targetMappingFieldsSO[2].getValue();
		controller.mappingsAdditional[0].Value_of_the_target_field__c = 'test';
		
		//Set Ownership mapping
		controller.targetOwnerMapping.Owner_Name__c = 'some user';
		controller.targetOwnerMapping.Type_Of_Ownership__c = MaritzCaseMappingController.USER_RADIOBUTTON_VALUE;
		
		Test.startTest();
		//Save mappings
		controller.mappingsPreview();
		controller.closeMappingsPreview();
		controller.saveMappings();
		

		Maritz_Case_Mappings__c[] fTFM = [SELECT Id FROM Maritz_Case_Mappings__c];
		Maritz_Case_Mappings_ForAdditionalFields__c[] statM = [SELECT Id FROM Maritz_Case_Mappings_ForAdditionalFields__c];
		Maritz_Mappings_Ownership__c[] ownershipM = [SELECT Id FROM Maritz_Mappings_Ownership__c];
		Maritz_Mappings_Record_Type__c[] rectypeM = [SELECT Id FROM Maritz_Mappings_Record_Type__c];
		Maritz_Mappings_Lookups__c[] lookupM = [SELECT Id FROM Maritz_Mappings_Lookups__c];
		Test.stopTest();

		System.assertEquals(1, fTFM.size());
		System.assertEquals(1, lookupM.size());
		System.assertEquals(1, rectypeM.size());
		System.assertEquals(1, ownershipM.size());
		System.assertEquals(1, statM.size());
	}

	static testmethod void testOnMappingsCreationWhenSomeMappingAreExisted() {
		PageReference pageRef = Page.MaritzCaseMapping;
		Test.setCurrentPage(pageRef);

		//setup mappings
		setupMappings();

		MaritzCaseMappingController controller = new MaritzCaseMappingController();
		controller.IntermMappingObject = SOURCE_OBJECT;
		controller.recalcDependValues();

		//Set Field-to-Field mapping
		controller.mappings[0].Source_field__c =  controller.mappingFields[1].getValue();

		//Set RecordType mapping
		controller.recordTypeMapping.Record_Type_Name__c =  controller.recordTypeSO[1].getValue();

		//Set Lookup mapping
		
		controller.lookupEntytyMapping[0].externalIdsOfTheRelateedObject =  controller.lookupEntytyMapping[0].externalIdsOfTheRelateedObjectSO[0].getValue();
		controller.lookupEntytyMapping[0].recordTypeOfTheRelatedObject =  controller.lookupEntytyMapping[0].recordTypeOfTheRelatedObjectSO[0].getValue();
		controller.lookupEntytyMapping[0].fieldOfIntermediateObject =  controller.lookupEntytyMapping[0].fieldsOfIntermediateObjectSO[2].getValue();
		
		//Set Static value mapping
		controller.addAdditionalMappingRow();
		controller.mappingsAdditional[1].Target_field__c = controller.targetMappingFieldsSO[2].getValue();
		controller.mappingsAdditional[1].Value_of_the_target_field__c = 'test';
		
		//Set Ownership mapping
		controller.targetOwnerMapping.Owner_Name__c = 'some user';
		controller.targetOwnerMapping.Type_Of_Ownership__c = MaritzCaseMappingController.USER_RADIOBUTTON_VALUE;
		
		Test.startTest();
		//Save mappings
		controller.saveMappings();
		

		Maritz_Case_Mappings__c[] fTFM = [SELECT Id FROM Maritz_Case_Mappings__c];
		Maritz_Case_Mappings_ForAdditionalFields__c[] statM = [SELECT Id FROM Maritz_Case_Mappings_ForAdditionalFields__c];
		Maritz_Mappings_Ownership__c[] ownershipM = [SELECT Id FROM Maritz_Mappings_Ownership__c];
		Maritz_Mappings_Record_Type__c[] rectypeM = [SELECT Id FROM Maritz_Mappings_Record_Type__c];
		Maritz_Mappings_Lookups__c[] lookupM = [SELECT Id FROM Maritz_Mappings_Lookups__c];
		Test.stopTest();

		System.assertEquals(5, fTFM.size());
		System.assertEquals(1, lookupM.size());
		System.assertEquals(1, rectypeM.size());
		System.assertEquals(1, ownershipM.size());
		System.assertEquals(1, statM.size());
	}

	/*---------------------HELPERS-------------------------------*/
	static void setupMappings() {
		//Setup Field-to-Field mappings
		Maritz_Case_Mappings__c[] fieldToFieldMappings = new Maritz_Case_Mappings__c[]{};
		Integer name = 0;
		for (String sField : SOURCE_TO_TARGET_FIELDS_MAP.keySet()) {
			fieldToFieldMappings.add(createFieldToFieldmapping(name, sField, SOURCE_TO_TARGET_FIELDS_MAP.get(sField)));
			name++;
		}

		//Setup RecordType mapping
		Id recTypeId = MappingHelper.getRecordTypeByName(TARGET_OBJECT, CASE_RECORD_TYPE_NAME);
		Maritz_Mappings_Record_Type__c recordTypeMapping = new Maritz_Mappings_Record_Type__c();
		recordTypeMapping.Name = string.valueof(name);
		recordTypeMapping.Record_Type_Name__c = recTypeId;
		recordTypeMapping.Source_object__c = SOURCE_OBJECT;
		recordTypeMapping.Target_object__c = TARGET_OBJECT;
		name++;

		//Setup Lookup mappings
		Maritz_Mappings_Lookups__c[] lookupMappings = new Maritz_Mappings_Lookups__c[] {};
		Id relatedRecTypeId = MappingHelper.getRecordTypeByName(RELATED_OBJECT_FOR_CASE_LOOKUP, REC_TYPE_FOR_ACCOUNTID_LOOKUP);
		lookupMappings.add(createLookupMappings(name, 'CustomerAccountNumber__c', relatedRecTypeId, 'Customer_ID__c', 'AccountId'));
		name++;

		//Setup Static mappings
		Maritz_Case_Mappings_ForAdditionalFields__c[] staticMapping = new Maritz_Case_Mappings_ForAdditionalFields__c[] {};
		staticMapping.add(createStaticMapping(name, 'test', 'Subject'));
		name++;

		//Setup Ownership mapping
		Maritz_Mappings_Ownership__c ownershipMapping = createOwnershipmappings(name, OWNER_NAME, OWNER_TYPE);
		
		//Insert of the mappings
		insert fieldToFieldMappings;
		insert recordTypeMapping;
		insert lookupMappings;
		insert staticMapping;
		insert ownershipMapping;
	}

	static Maritz_Case_Mappings__c createFieldToFieldmapping(Integer name, String sourceField, String targetField) {
		Maritz_Case_Mappings__c result = new Maritz_Case_Mappings__c();
		result.Name = string.valueof(name);
		result.Source_field__c = sourceField;
		result.Source_object__c = SOURCE_OBJECT;
		result.Target_field__c = targetField;
		result.Target_object__c = TARGET_OBJECT;
		return result;
	}

	static Maritz_Mappings_Lookups__c createLookupMappings(Integer name, String sourceField, String recType, String externId, String targetField) {
		Maritz_Mappings_Lookups__c result = new Maritz_Mappings_Lookups__c();
		result.Name = string.valueof(name);
		result.External_Id_field__c = externId;
		result.Record_type__c = recType;
		result.Source_field__c = sourceField;
		result.Source_object__c = SOURCE_OBJECT;
		result.Target_lookup_field__c = targetField;
		result.Target_object__c = TARGET_OBJECT;
		return result;
	}

	static Maritz_Case_Mappings_ForAdditionalFields__c createStaticMapping(Integer name, String sourceValue, String targaetField) {
		Maritz_Case_Mappings_ForAdditionalFields__c result = new Maritz_Case_Mappings_ForAdditionalFields__c();
		result.Name = string.valueof(name);
		result.Source_object__c = SOURCE_OBJECT;
		result.Target_field__c = targaetField;
		result.Target_object__c = TARGET_OBJECT;
		result.Value_of_the_target_field__c = sourceValue;
		return result; 
	}

	static Maritz_Mappings_Ownership__c createOwnershipMappings(Integer name, String ownerName, String ownerType) {
		Maritz_Mappings_Ownership__c result = new Maritz_Mappings_Ownership__c();
		result.Name = string.valueof(name);
		result.Owner_Name__c = ownerName; 
		result.Source_object__c = SOURCE_OBJECT;
		result.Target_object__c = TARGET_OBJECT;
		result.Type_Of_Ownership__c = ownerType;
		return result;
	}
}