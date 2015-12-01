/**********************************************************************
Name: AdhocCampaign_Before_Test
Copyright � notice: Nissan Motor Company
======================================================
Purpose:
Test class for AdhocCampaign_Before trigger and MappingHelper class.

Related Class : AdhocCampaign_Before trigger and MappingHelper class
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy sychev 07/07/2015 Created                        
***********************************************************************/
@isTest
private Class AdhocCampaign_Before_Test { 
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
	static testmethod void testOnCaseRecordCreation() {
		Adhoc_Campaign_Object__c adhocRecord = new Adhoc_Campaign_Object__c(Name = 'test', Address1__c = 'testAddr1', Address2__c = 'testAddr2', 
																			BankruptcyFL__c = 'testBank', BonusCashCode__c = 'testBonus',
																			City__c = 'testCity', CustomerAccountNumber__c = '12345', dealer__c = '12346');

		test.startTest();
		insert adhocRecord;

		Case[] c = [SELECT Id FROM Case];
		System.assertEquals(1, c.size());
		test.stopTest();
		
	}

	static testmethod void testOnBulkCaseRecordCreation() {
		Adhoc_Campaign_Object__c adhocRecord;
		Adhoc_Campaign_Object__c[] adhocRecords = new Adhoc_Campaign_Object__c[]{};
		for (Integer i = 0; i<700; i++) {
			adhocRecord = new Adhoc_Campaign_Object__c(Name = 'test' + String.valueOf(i), Address1__c = 'testAddr1', Address2__c = 'testAddr2', 
																			BankruptcyFL__c = 'testBank', BonusCashCode__c = 'testBonus',
																			City__c = 'testCity', CustomerAccountNumber__c = '12345', dealer__c = '12346');
			adhocRecords.add(adhocRecord);
		}

		test.startTest();
		insert adhocRecords;

		Case[] c = [SELECT Id FROM Case];
		System.assertEquals(700, c.size()); 
		test.stopTest();
		
	}

	/*---------------------HELPERS-------------------------------*/
	@testSetup static void setupMappings() {
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
		relatedRecTypeId = MappingHelper.getRecordTypeByName(RELATED_OBJECT_FOR_CASE_LOOKUP, REC_TYPE_FOR_DEALER_LOOKUP);
		lookupMappings.add(createLookupMappings(name, 'dealer__c', relatedRecTypeId, 'Dealer_Code__c', 'Dealer__c'));
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

	@testSetup static void setupAccounts() {
		Account[] accounts = new Account[] {};
		//Setup Customer account
		//Id relatedRecTypeId = MappingHelper.getRecordTypeByName(RELATED_OBJECT_FOR_CASE_LOOKUP, REC_TYPE_FOR_ACCOUNTID_LOOKUP);
		accounts.add(new Account(Name = 'customer', Customer_ID__c = '12345'));
		//Setup Dealer account
		//relatedRecTypeId = MappingHelper.getRecordTypeByName(RELATED_OBJECT_FOR_CASE_LOOKUP, REC_TYPE_FOR_DEALER_LOOKUP);
		accounts.add(new Account(Name = 'dealer', Customer_ID__c = '12346'));

		insert accounts;
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