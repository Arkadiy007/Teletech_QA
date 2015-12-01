/**********************************************************************
Name: AdhocCampaign_Before
Copyright � notice: Nissan Motor Company
======================================================
Purpose:
Trigger for Adhoc_Campaign_Object__c object.

Related Class : MappingHelper
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy sychev 06/26/2015 Created                          
***********************************************************************/
trigger AdhocCampaign_Before on Adhoc_Campaign_Object__c (before insert) {
	String sourceObjectName = 'Adhoc_Campaign_Object__c';
	String targetObjectName = 'Case';

	// determine active template
	String activeTemplate;
    for (Maritz_Mapping_Templates__c t : Maritz_Mapping_Templates__c.getAll().values()) {
        if (t.isActive__c) {
			activeTemplate = t.Name;
		}
    }

	// Retrieve existing mappings
	Maritz_Case_Mappings__c[] mappings = MappingHelper.loadMappings(sourceObjectName,targetObjectName, activeTemplate);
	Maritz_Mappings_Record_Type__c[] recordTypeMapping = MappingHelper.loadRecordTypeMappings(sourceObjectName,targetObjectName, activeTemplate);
	Maritz_Mappings_Lookups__c[] lookupMappings = MappingHelper.loadLookUpMappings(sourceObjectName,targetObjectName, activeTemplate);
	Maritz_Case_Mappings_ForAdditionalFields__c[] loadAdditionalMappings = MappingHelper.loadAdditionalMappings(sourceObjectName,targetObjectName, activeTemplate);
	Maritz_Mappings_Ownership__c[] targetOwnerMapping = MappingHelper.loadOwnershipMappings(sourceObjectName,targetObjectName, activeTemplate);

	SObject[] recordsToInsert = new SObject[] { };
	List<Adhoc_Campaign_Object__c> adhocCampaignRecordsList = new List<Adhoc_Campaign_Object__c>();

	//Map<String, Map<Integer, String>> valuesOfLookupFieldsOfAllRecords = new Map<String, Map<String, String>>(){};
	Map<Maritz_Mappings_Lookups__c, Set<String>> valuesOfLookupFieldsOfAllRecords = new Map<Maritz_Mappings_Lookups__c, Set<String>>();
	Map<Maritz_Mappings_Lookups__c, Map<String, String>> idsOfRelatedLookupRecords = new Map<Maritz_Mappings_Lookups__c, Map<String, String>>();
	Map<Maritz_Mappings_Lookups__c, Map<String, Map<String, String>>> idsOfRelatedLookupRecordsAccountsAndContact = new Map<Maritz_Mappings_Lookups__c, Map<String, Map<String, String>>>();

	if (mappings.size() != 0) {
		// Get object description for target object (Case)
		Map<String,DescribeFieldResult> objectDescription = MappingHelper.getFields(targetObjectName);

		// Get user or queue which should owner of the Case records
		Id ownerId;
		if (!targetOwnerMapping.isEmpty() && targetOwnerMapping[0].Type_Of_Ownership__c == 'queue') {
			Group[] q = [SELECT Id FROM Group WHERE Type =: 'Queue' AND Name =: targetOwnerMapping[0].Owner_Name__c LIMIT 1];
			if (!q.isEmpty()) {
				ownerId = q[0].Id;
			}
		} else if (!targetOwnerMapping.isEmpty() && targetOwnerMapping[0].Type_Of_Ownership__c == 'user') {
			User[] u = [SELECT Id FROM User WHERE Name =: targetOwnerMapping[0].Owner_Name__c LIMIT 1];
			if (!u.isEmpty()) {
				ownerId = u[0].Id;
			}
		}

		// Get appropriate record type
		Id recordTypeId;
		if (null != recordTypeMapping && !recordTypeMapping.isEmpty()) {
			recordTypeId = MappingHelper.getRecordTypeById(recordTypeMapping[0].Target_Object__c, recordTypeMapping[0].Record_Type_Name__c);
			System.debug('in trigger recordTypeId = ' + recordTypeId);
		}

		// Retrieving lookup values of all records and putting it to valuesOfLookupFieldsOfAllRecords
		Set<String> valuesOfLookupFields;
		for (Maritz_Mappings_Lookups__c mapping : lookupMappings) {
			valuesOfLookupFields = new Set<String>();
			for (Adhoc_Campaign_Object__c record : Trigger.New) {
				if (null != record.get(mapping.Source_field__c)) {
					valuesOfLookupFields.add((String)record.get(mapping.Source_field__c));
				} else {
					valuesOfLookupFields.add('');
				}
			}
			valuesOfLookupFieldsOfAllRecords.put(mapping, valuesOfLookupFields);
		}

		// Retrieving related lookup records 
		Map<String, String> valueToIdMap = new Map<String, Id>();
		Map<String, Map<String, String>> valueToIdMapAccountandContact = new Map<String, Map<String, String>>();
		for (Maritz_Mappings_Lookups__c mapping : lookupMappings) {
			if (!mapping.Target_lookup_field__c.equalsIgnoreCase('accountid')) {
				valueToIdMap = MappingHelper.searchLookupRecords(mapping, valuesOfLookupFieldsOfAllRecords.get(mapping));
				idsOfRelatedLookupRecords.put(mapping, valueToIdMap);
			} else {
				valueToIdMapAccountandContact = MappingHelper.searchAccountLookupRecords(mapping, valuesOfLookupFieldsOfAllRecords.get(mapping));
				idsOfRelatedLookupRecordsAccountsAndContact.put(mapping, valueToIdMapAccountandContact);
			}
		}
		valueToIdMap = new Map<String, Id>();
		valueToIdMapAccountandContact = new Map<String, Map<String, String>>();
		for (Adhoc_Campaign_Object__c record : Trigger.New) {
			SObject targetObjest = (SObject) Type.forName(mappings[0].Target_object__c).newInstance(); 

			// Set Field-to-Field mapping
			for (Maritz_Case_Mappings__c mapping: mappings) {
				Object value = MappingHelper.convertValue(objectDescription.get(mapping.Target_Field__c), record.get(mapping.Source_Field__c));
				targetObjest.put(mapping.Target_Field__c, value);
			}

			// Set Record Type
			if (null != recordTypeId) {
				targetObjest.put('recordTypeId', recordTypeId);
			}


			// Set Lookup fields
			for (Maritz_Mappings_Lookups__c mapping : lookupMappings) {
				if (!mapping.Target_lookup_field__c.equalsIgnoreCase('accountid')) {
					valueToIdMap = idsOfRelatedLookupRecords.get(mapping);

					String idOfRelatedRecord = valueToIdMap.get(String.valueOf(record.get(mapping.Source_field__c)));
					if (null != idOfRelatedrecord) {
						targetObjest.put(mapping.Target_lookup_field__c, idOfRelatedRecord);
					}
				} else {
					valueToIdMapAccountandContact = idsOfRelatedLookupRecordsAccountsAndContact.get(mapping);

					Map<String, String> idOfRelatedRecord = valueToIdMapAccountandContact.get(String.valueOf(record.get(mapping.Source_field__c)));
					if (null != idOfRelatedrecord) {
						List<String> accountId = new List<String> (idOfRelatedRecord.keySet());
						targetObjest.put(mapping.Target_lookup_field__c, accountId[0]);
						if (!String.isBlank(idOfRelatedRecord.get(accountId[0]))) {
							targetObjest.put('ContactId', idOfRelatedRecord.get(accountId[0]));
						}
					}
				}
			}

			// Set Additionall Static mappings
			for (Maritz_Case_Mappings_ForAdditionalFields__c mapping: loadAdditionalMappings) {
				Object value = MappingHelper.convertValue(objectDescription.get(mapping.Target_Field__c), mapping.Value_of_the_target_field__c);
				targetObjest.put(mapping.Target_Field__c, value);
			}

			// Set owner Id
			if (null != ownerId) { // Should be some default user?
				targetObjest.put('ownerId', ownerId);
			}
			
			recordsToInsert.add(targetObjest);
			adhocCampaignRecordsList.add(record);

		}

		if (!recordsToInsert.isEmpty()) {
			Database.SaveResult[] dbResults = Database.insert(recordsToInsert, false);
			if (!dbResults.isEmpty()) {
				// Loop through results returned
				for (integer row = 0; row <recordsToInsert.size(); row++)	{
					// If the current row was not sucessful, handle the error.
					if (!dbResults[row].isSuccess()) {
						// Get the error for this row and populate corresponding fields
						Database.Error err = dbResults[row].getErrors() [0];
						adhocCampaignRecordsList.get(row).Successful__c = false;
						adhocCampaignRecordsList.get(row).Error_Description__c = err.getMessage();
					}else{			
						adhocCampaignRecordsList.get(row).Successful__c = true;
						adhocCampaignRecordsList.get(row).Error_Description__c = '';
						adhocCampaignRecordsList.get(row).Case_ID__c = dbResults[row].getId();
					}
				}
			}
		}
		//Database.update(adhocCampaignRecordsList, false);
	}

}