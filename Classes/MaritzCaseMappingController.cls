/**********************************************************************
  Name: MaritzCaseMappingController
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose:
  Controller for MaritzCaseMapping page.

  Related Class : MappingHelper
  Related Page : MaritzCaseMapping
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy sychev 06/26/2015 Created                        
  ***********************************************************************/
public class MaritzCaseMappingController {
  /**
   * Controller for SW Integration Admininstration page
   */

  //--------------------------------------------------------------------------
  // Constants
  private final static String DEFAULT_PICKLIST_REC_TYPE_TEXT = '-- All --';
  private final static String DEFAULT_PICKLIST_TEXT = '-- None --';
  private final static String DEFAULT_PICKLIST_VALUE = '';
  private final static String DEFAULT_SF_OBJECT = 'Case';
  private final static String DEFAULT_INTERMEDIATE_OBJECT = 'Adhoc_Campaign_Object__c';
  private final static String ERROR_MESSAGE_FAILED_ACTIVATING = 'Failed activating synchronization job';
  private final static String NEVER_SYNCED_BEFORE_TEXT = 'Never';
  private final static String MOST_RECENT_ERROR_FORMAT = '{0} ({1} at {2})';
  private final static Integer NUMBER_LENGTH_WITH_LEADING_ZERO = 9;

  private final static String IDENTIFY_KEY_PREFIX = 'INDK-';
  private final static DateTime START_SYNC_DATE = DateTime.newInstanceGmt(1980, 1, 1);
  private final static Integer SYNC_INTERVAL = 1000;
  private final static Integer LAST_MOD_DEFAULT = 0;

  public final static String USER_RADIOBUTTON_TEXT = 'User';
  public final static String USER_RADIOBUTTON_VALUE = 'user';
  public final static String QUEUE_RADIOBUTTON_TEXT = 'Queue';
  public final static String QUEUE_RADIOBUTTON_VALUE = 'queue';

  private final static Set<String> IGNORED_LOOKUP_FIELDS = new Set<String> { 'OwnerId', 'RecordTypeId' };

  public final static String CASE_CONTACT_ID_FIELD_NAME = 'ContactId';
  public final static String CASE_ACCOUNT_ID_FIELD_NAME = 'accountid';

  public final static String DEFAULT_TEMLATE_NAME = 'Default';
  public final static String NEW_TEMPLATE = 'New';
  //--------------------------------------------------------------------------
  // Properties
  public String mappingObject = 'Case';

  Map<Id, Boolean> settingActiveStatusBeforeUSerChanges = new Map<Id, Boolean> ();

  public String selectedObjectRecordType { get; set; }
  public List<SelectOption> ObjectsRecordType { get; private set; }

  public Maritz_Case_Mappings__c[] mappings { get; private set; } /////
  public Maritz_Case_Mappings_ForAdditionalFields__c[] mappingsAdditional { get; private set; } /////
  public Maritz_Mappings_Ownership__c targetOwnerMapping { get; set; }
  public Maritz_Mappings_Record_Type__c recordTypeMapping { get; set; }
  public LookupEntytyMappingObject[] lookupEntytyMapping { get; set; }

  //Variables used for preview mappings
  public Maritz_Case_Mappings__c[] mappingsPreview { get; private set; } /////
  public Maritz_Case_Mappings_ForAdditionalFields__c[] mappingsAdditionalPreview { get; private set; } /////
  public Maritz_Mappings_Ownership__c targetOwnerMappingPreview { get; set; }
  public String recordTypeMappingPreview { get; set; }
  public LookupEntytyMappingObject[] lookupEntytyMappingPreview { get; set; }
  //

  public Id[] mappingsToDelete { get {
      if (null == mappingsToDelete) {
        mappingsToDelete = new Id[] { };
      }
      return mappingsToDelete;
    }
    set; }

  public Map<String, String> mappingLabels { get; private set; }
  public Map<String, String> mappingLabelsAdditional { get; private set; }
  public Map<String, Boolean> mappingFieldRequired { get; set; }
  public Map<String, Boolean> mappingFieldRequiredAdditional { get; set; }
  public Map<String, String> mappingLookupLabels { get; private set; }

  public Maritz_Case_Mappings_ForAdditionalFields__c[] mappingsAdditionalToDelete { get {
      if (null == mappingsAdditionalToDelete) {
        return new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
      }
      return mappingsAdditionalToDelete;
    }
    private set; } /////

  private Set<Id> existingMappingRecordIdsSet;

  public SelectOption[] targetMappingFieldsSO { get; private set; }
  public SelectOption[] mappingFields { get; private set; }
  public SelectOption[] externalMappingsFeilds { get; private set; }
  public SelectOption[] recordTypeSO { get; private set; }
  public SelectOption[] ownerTypeSO { get {
      if (null == ownerTypeSO) {
        ownerTypeSO = new SelectOption[] { };
        ownerTypeSO.add(new SelectOption(USER_RADIOBUTTON_VALUE, USER_RADIOBUTTON_TEXT));
        ownerTypeSO.add(new SelectOption(QUEUE_RADIOBUTTON_VALUE, QUEUE_RADIOBUTTON_TEXT));
      }
      return ownerTypeSO;
    }
    private set; }

  public Map<String, String> relatedLookupObjectsTypes;

  public Boolean doRecalcDependValues = true;
  public Boolean displayLogsPopup { get; set; }

  public String lastSyncDate { get; private set; }
  public String lastError { get; private set; }
  public Id lastErrorId { get; private set; }
  public Boolean lastSyncResult { get; private set; }

  public Boolean canSaveMappings { get; private set; }

  public String CaseRecordType { get; set; }

  public String getmappingObject() {
    return mappingObject;
  }

  public String IntermMappingObject {
    get {
      return DEFAULT_INTERMEDIATE_OBJECT;
    }
    set;
  }

  public Boolean displaySummeryPopup { get {
      if (null == displaySummeryPopup) {
        return false;
      }
      return displaySummeryPopup;
    }
    set; }

  public String templateName {get; set;}
  public Boolean displaySetTemplateNamePopup {get; set;}
  public Boolean isActiveSelectedTemplate {get; private set;}
  public SelectOption[] templateOptions {
    get {
      if (null == templateOptions) {
        templateOptions = new SelectOption[] {};
        templateOptions.add(new SelectOption(NEW_TEMPLATE, NEW_TEMPLATE));

        for (Maritz_Mapping_Templates__c t : Maritz_Mapping_Templates__c.getAll().values()) {
          templateOptions.add(new SelectOption(t.Name, t.Name));
        }
      }

      return templateOptions;
    }
    private set;
  }

  public String selectedTemplate {
    get; 
    set {
      if (value != selectedTemplate) {
        selectedTemplate = value;

        // Determine if selected template are active
        Maritz_Mapping_Templates__c selected = Maritz_Mapping_Templates__c.getAll().get(selectedTemplate);
        if (null != selected) {
          isActiveSelectedTemplate = selected.IsActive__c;
        } else {
          isActiveSelectedTemplate = false;
        }
      }
	  templateName = value;
    }
  }

  public Boolean displaySetActivatePopup {
	get {
		if (null == displaySetActivatePopup) {
			return false;
		}
		return displaySetActivatePopup;
	} 
	set;
	}

	public String newActiveTemplate {get; set;} 

  //--------------------------------------------------------------------------
  // Methods

  public MaritzCaseMappingController() {
    this.displaySetTemplateNamePopup = false;
  }

  public SelectOption[] getBusinessItems() {

    SelectOption[] options = new SelectOption[] { };
    options.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));
    //  Set<SelectOption> interObjectsSet = new Set<SelectOption> (intermItems);
    Map<String, SelectOption> mapOptions = new Map<string, SelectOption> ();
    mapOptions.put(DEFAULT_PICKLIST_TEXT, new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));
    for (Schema.SObjectType f : Schema.getGlobalDescribe().Values()) {
      DescribeSObjectResult describe = f.getDescribe();

      if (describe.isAccessible() && describe.isCreateable() && !describe.isCustomSetting() && describe.isUpdateable()) {
        String label = f.getDescribe().getLabel();
        String name = f.getDescribe().getName();

        mapOptions.put(label, new SelectOption(name, label));
      }
    }
    sortMap(mapOptions, options);

    return options;
  }

  //-----------------------Methods which initialize values for the mapping sections on the page-------------------------//
  // Loads existing mapping settings for selected source&target objects pair. If not all object fields are mapped - empty mappings are created in addition to existing ones
  @testVisible private Maritz_Case_Mappings__c[] tryGetExistingFieldToFieldMappings() {
    if (!MappingHelper.isEmpty(IntermMappingObject) && !MappingHelper.isEmpty(mappingObject)) {
      Maritz_Case_Mappings__c[] existingMappings = MappingHelper.loadMappings(IntermMappingObject, mappingObject, selectedTemplate);
      if (existingMappings.isEmpty()) {
        existingMappings = null;
      } else {
        Set<String> existingmappingsSet = new Set<String> ();

        // prefill selected Object and RecordType
        mappingObject = existingMappings[0].Target_Object__c;

        Maritz_Case_Mappings__c[] allFields = createFieldToFieldMappings();

        for (Maritz_Case_Mappings__c field : existingMappings) {
          existingmappingsSet.add(field.Target_Field__c);
          existingMappingRecordIdsSet.add(field.Id);
        }
        for (Maritz_Case_Mappings__c field : allFields) {
          if (!existingmappingsSet.contains(field.Target_Field__c)) {
            existingMappings.add(field);
          }
        }
        sortList(existingMappings, 'Target_Field__c');
      }

      return existingMappings;
    }
    return null;

  }

  // Loads existing additional mapping settings for selected source&target objects pair. 
  @testVisible private Maritz_Case_Mappings_ForAdditionalFields__c[] tryGetExistingAdditionalMappings() {
    Maritz_Case_Mappings_ForAdditionalFields__c[] existingMappings = MappingHelper.loadAdditionalMappings(IntermMappingObject, mappingObject, selectedTemplate);

    if (existingMappings.isEmpty()) {
      existingMappings = new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
      return existingMappings;
    }

    for (Maritz_Case_Mappings_ForAdditionalFields__c field : existingMappings) {
      existingMappingRecordIdsSet.add(field.Id);
    }
    sortList(existingMappings, 'Target_Field__c');
    return existingMappings;
  }

  @testVisible private Maritz_Mappings_Record_Type__c tryGetExistingRecordTypeMapping() {
    Maritz_Mappings_Record_Type__c[] existingRecordTypeMappings = MappingHelper.loadRecordTypeMappings(IntermMappingObject, mappingObject, selectedTemplate);
    if (existingRecordTypeMappings.isEmpty()) {
      return null;
    } else {
      existingMappingRecordIdsSet.add(existingRecordTypeMappings[0].Id);
      return existingRecordTypeMappings[0];
    }
  }

  // Load or create Maritz_Mappings_Lookups__c custom settings for current pair of the objects (intermediate and target). 
  @testVisible private LookupEntytyMappingObject[] tryGetExistingLookupMappings() {
    Maritz_Mappings_Lookups__c[] existingLookupMappings = MappingHelper.loadLookUpMappings(IntermMappingObject, mappingObject, selectedTemplate);
    
	LookupEntytyMappingObject[] resultLookupEntityMapping = new LookupEntytyMappingObject[] { };

    if (existingLookupMappings.isEmpty()) {
      Maritz_Mappings_Lookups__c[] allFields = createLookupMappings();
      sortList(allFields, 'Target_lookup_field__c');

      Map<String, SelectOption[]> externalIdsOfExternalObj = new Map<String, SelectOption[]> ();
      Map<String, SelectOption[]> recordTypesOfRelatedObj = new Map<String, SelectOption[]> ();
      for (String field : relatedLookupObjectsTypes.keySet()) {
        externalIdsOfExternalObj.putAll(getExternalIdsOfRelatedObject(field, relatedLookupObjectsTypes.get(field)));
        recordTypesOfRelatedObj.putAll(getRecordTypesOfRelatedObject(field, relatedLookupObjectsTypes.get(field)));
      }

      // Generate lookupEntytyMapping for the lookup section
      for (Maritz_Mappings_Lookups__c mapping : allFields) {
        LookupEntytyMappingObject LookupEntytyMapping;
        String targetField = mapping.Target_lookup_field__c;
        LookupEntytyMapping = new LookupEntytyMappingObject(mapping, externalIdsOfExternalObj.get(targetField), recordTypesOfRelatedObj.get(targetField), mappingFields, mappingLookupLabels);
        resultLookupEntityMapping.add(LookupEntytyMapping);
      }
    } else {
      Maritz_Mappings_Lookups__c[] allFields = createLookupMappings();
      sortList(allFields, 'Target_lookup_field__c');

      Map<String, Maritz_Mappings_Lookups__c> existingMappingsMap = new Map<String, Maritz_Mappings_Lookups__c> ();

      for (Maritz_Mappings_Lookups__c mapping : existingLookupMappings) {
        existingMappingsMap.put(mapping.Target_lookup_field__c, mapping);
        existingMappingRecordIdsSet.add(mapping.Id);
      }

      Map<String, SelectOption[]> externalIdsOfExternalObj = new Map<String, SelectOption[]> ();
      Map<String, SelectOption[]> recordTypesOfRelatedObj = new Map<String, SelectOption[]> ();
      for (String field : relatedLookupObjectsTypes.keySet()) {
        externalIdsOfExternalObj.putAll(getExternalIdsOfRelatedObject(field, relatedLookupObjectsTypes.get(field)));
        recordTypesOfRelatedObj.putAll(getRecordTypesOfRelatedObject(field, relatedLookupObjectsTypes.get(field)));
      }

      // Generate lookupEntytyMapping for the lookup section
      for (Maritz_Mappings_Lookups__c mapping : allFields) {
        LookupEntytyMappingObject LookupEntytyMapping;
        String targetField = mapping.Target_lookup_field__c;
        if (existingMappingsMap.keySet().contains(targetField)) {
          LookupEntytyMapping = new LookupEntytyMappingObject(existingMappingsMap.get(targetField), externalIdsOfExternalObj.get(targetField), recordTypesOfRelatedObj.get(targetField), mappingFields, mappingLookupLabels);
          resultLookupEntityMapping.add(LookupEntytyMapping);
        } else {
          LookupEntytyMapping = new LookupEntytyMappingObject(mapping, externalIdsOfExternalObj.get(targetField), recordTypesOfRelatedObj.get(targetField), mappingFields, mappingLookupLabels);
          resultLookupEntityMapping.add(LookupEntytyMapping);
        }
      }
    }

    return resultLookupEntityMapping;
  }

  // Load or create Maritz_Mappings_Lookups__c custom settings for current pair of the objects (intermediate and target). 
  @testVisible private Maritz_Mappings_Ownership__c tryGetExistingOwnershipMappings() {
    Maritz_Mappings_Ownership__c[] existingOwnershipMapping = MappingHelper.loadOwnershipMappings(IntermMappingObject, mappingObject, selectedTemplate);

    if (!existingOwnershipMapping.isEmpty()) {
      existingMappingRecordIdsSet.add(existingOwnershipMapping[0].id);
      return existingOwnershipMapping[0];
    }

    Maritz_Mappings_Ownership__c ownershipMapping = new Maritz_Mappings_Ownership__c(Target_object__c = mappingObject, Source_object__c = IntermMappingObject, Type_Of_Ownership__c = USER_RADIOBUTTON_VALUE);
    return ownershipMapping;
  }

  //--------------------------------------------------------//

  // Creates empty mappings for all updateable&createable fields for selected source&target objects pair
  @testVisible private Maritz_Case_Mappings__c[] createFieldToFieldMappings() {
    Maritz_Case_Mappings__c[] newMappings = new Maritz_Case_Mappings__c[] { };

    String[] lst = MappingHelper.getListWithOneObject(mappingObject);

    mappingLabels = new Map<String, String> ();
    mappingFieldRequired = new Map<String, Boolean> ();

    Map<String, Schema.DescribeFieldResult> simpleFields = initializeObjectSimpleFields(lst);


    String[] keysToSort = new String[] { };
    keysToSort.addAll(simpleFields.keySet());
    keysToSort.sort();

    // clear external options
    externalMappingsFeilds = new SelectOption[] { };

    for (String key : keysToSort) {

      Schema.DescribeFieldResult currentField = simpleFields.get(key);
      Maritz_Case_Mappings__c newMap = new Maritz_Case_Mappings__c();
      newMap.Target_Object__c = MappingObject;
      newMap.Target_Field__c = currentField.name;
      newMap.Source_Object__c = intermMappingObject;
      newMap.Source_Field__c = '';
      newMappings.add(newMap);
      mappingLabels.put(newMap.Target_Field__c, currentField.label);
      mappingFieldRequired.put(newMap.Target_Field__c, isFieldRequired(currentField)); // del

      if (currentField.isExternalId()) {
        externalMappingsFeilds.add(new SelectOption(currentField.name, currentField.label));
      }
    }

    return newMappings;
  }

  @testVisible private Maritz_Mappings_Lookups__c[] createLookupMappings() {
    String[] lst = MappingHelper.getListWithOneObject(mappingObject);

    Map<String, Schema.DescribeFieldResult> lookupFields = initializeObjectLookupFields(lst);

    Maritz_Mappings_Lookups__c[] newLookupMappings = new Maritz_Mappings_Lookups__c[] { };
    mappingLookupLabels = new Map<String, String> ();

    String[] keysToSort = new String[] { };
    keysToSort.addAll(lookupFields.keySet());
    keysToSort.sort();

    // clear external options
    externalMappingsFeilds = new SelectOption[] { };

    for (String key : keysToSort) {
      if (!key.equalsIgnoreCase(CASE_CONTACT_ID_FIELD_NAME)) {
        Schema.DescribeFieldResult currentField = lookupFields.get(key);

        Maritz_Mappings_Lookups__c newMap = new Maritz_Mappings_Lookups__c();
        newMap.Target_Object__c = MappingObject;
        newMap.Target_lookup_field__c = currentField.name;
        newLookupMappings.add(newMap);
        newMap.Source_Object__c = intermMappingObject;
        newMap.Source_Field__c = DEFAULT_PICKLIST_VALUE;
        mappingLookupLabels.put(currentField.name, currentField.label);
      }
    }

    //lookupMappings = newLookupMappings;
    return newLookupMappings;
  }
  //--------------------------------------------------------------------//

  //------------------------Methods which retrievs simple and lookup fields-------------------------------//
  // For Simple Fields
  private Map<String, Schema.DescribeFieldResult> initializeObjectSimpleFields(String[] obj) {
    DescribeSObjectResult[] res = Schema.describeSObjects(obj);
    Map<String, Schema.SObjectField> fields = res[0].fields.getMap();
    Map<String, Schema.DescribeFieldResult> simpleFields = new Map<String, Schema.DescribeFieldResult> ();
    Set<Schema.sObjectType> relatedObjects;

    for (String key : fields.keySet()) {
      Schema.DescribeFieldResult field = fields.get(key).getDescribe();
      if (field.isUpdateable() && field.isCreateable() && !(field.getType() == Schema.DisplayType.Reference)) {
        simpleFields.put(key, field);
      }
    }
    return simpleFields;
  }

  //For Lookup fields
  private Map<String, Schema.DescribeFieldResult> initializeObjectLookupFields(String[] obj) {
    DescribeSObjectResult[] res = Schema.describeSObjects(obj);
    Map<String, Schema.SObjectField> fields = res[0].fields.getMap();
    Map<String, Schema.DescribeFieldResult> lookupFields = new Map<String, Schema.DescribeFieldResult> ();
    relatedLookupObjectsTypes = new Map<String, String> ();
    Set<Schema.sObjectType> relatedObjects;

    for (String key : fields.keySet()) {
      Schema.DescribeFieldResult field = fields.get(key).getDescribe();
      if (field.isUpdateable() && field.isCreateable() && (field.getType() == Schema.DisplayType.Reference) && !IGNORED_LOOKUP_FIELDS.contains(field.Name)) {
        lookupFields.put(key, field);
        relatedObjects = new Set<Schema.sObjectType> (field.getReferenceTo());
        String objName = new List<Schema.sObjectType> (relatedObjects) [0].getDescribe().getName();
        relatedLookupObjectsTypes.put(field.Name, objName);
      }

    }
    return lookupFields;
  }
  //---------------------------------------------------------------//

  //--
  private Map<String, SelectOption[]> getExternalIdsOfRelatedObject(String targetLookup, String obj) {
    Map<String, SelectOption[]> result = new Map<String, SelectOption[]> ();

    SelectOption[] xternalIds = getExternalIds(obj);
    result.put(targetLookup, xternalIds);
    return result;
  }

  private Map<String, SelectOption[]> getRecordTypesOfRelatedObject(String targetLookup, String obj) {
    Map<String, SelectOption[]> result = new Map<String, SelectOption[]> ();

    SelectOption[] xternalIds = getRecordTypes(obj);
    result.put(targetLookup, xternalIds);
    return result;
  }
  //--

  @testVisible private Maritz_Mappings_Record_Type__c createRecordTypeMapping() {
    return new Maritz_Mappings_Record_Type__c();
  }

  // Creates a list of all Source object fields that can be used for mapping
  public void getIntermFieldsForMapping(String objectName) {

    mappingFields = new SelectOption[] { };
    mappingFields.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));

    if (objectName != DEFAULT_PICKLIST_VALUE) {
      String[] lst = new String[] { };
      lst.add(objectName);
      DescribeSObjectResult[] res = Schema.describeSObjects(lst);

      Map<String, Schema.SObjectField> fields = res[0].fields.getMap();
      Map<String, Schema.DescribeFieldResult> ssimpleFields = new Map<String, Schema.DescribeFieldResult> ();
      for (String key : fields.keySet()) {
        Schema.DescribeFieldResult field = fields.get(key).getDescribe();
        if (field.isUpdateable() && field.isCreateable()) {
          ssimpleFields.put(key, field);
        }
      }
      String[] keysToSort = new String[] { };
      keysToSort.addAll(ssimpleFields.keySet());
      keysToSort.sort();
      for (String key : keysToSort) {
        mappingFields.add(new SelectOption(ssimpleFields.get(key).getName(), ssimpleFields.get(key).getLabel()));
      }
    }
  }

  // Creates a list of all Target object fields that can be mapped (for additional mappings)
  public SelectOption[] getTargetFieldsForMapping(String objectName) {

    SelectOption[] targetMappingFields = new SelectOption[] { };
    targetMappingFields.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));

    if (objectName != DEFAULT_PICKLIST_VALUE) {
      String[] lst = new String[] { };
      lst.add(objectName);

      Map<String, Schema.DescribeFieldResult> simpleFields = initializeObjectSimpleFields(new String[] { objectName });

      String[] keysToSort = new String[] { };
      keysToSort.addAll(simpleFields.keySet());
      keysToSort.sort();
      for (String key : keysToSort) {
        targetMappingFields.add(new SelectOption(simpleFields.get(key).getName(), simpleFields.get(key).getLabel()));
      }
    }
    return targetMappingFields;
  }

  private SelectOption[] getRecordTypes(String obj) {
    SelectOption[] recordType = new SelectOption[] { };

    if (obj != DEFAULT_PICKLIST_VALUE) {
      SObjectType SObjType = Schema.getGlobalDescribe().get(obj);
      List<Schema.RecordTypeInfo> recTypeList = SObjType.getDescribe().recordTypeInfos;
      for (Schema.RecordTypeInfo rt : recTypeList) {
        recordType.add(new SelectOption(rt.recordTypeId, rt.Name));
      }
    }
    return recordType;
  }

  private SelectOption[] getExternalIds(String obj) {
    SelectOption[] externalIdFields = new SelectOption[] { };

    DescribeSObjectResult[] res = Schema.describeSObjects(MappingHelper.getListWithOneObject(obj));
    Map<String, Schema.SObjectField> fields = res[0].fields.getMap();

    for (String key : fields.keySet()) {
      Schema.DescribeFieldResult field = fields.get(key).getDescribe();
      if (field.isUpdateable() && field.isCreateable() && field.isExternalId()) {
        externalIdFields.add(new SelectOption(field.Name, field.Label));
      }
    }
    return externalIdFields;
  }

  // Closes Field Mappings popup
  public void cancelMappings() {
    IntermMappingObject = DEFAULT_PICKLIST_VALUE;
    mappings = null;
    mappingsAdditional = null;
    targetOwnerMapping = null;
    recordTypeMapping = null;
    lookupEntytyMapping = null;
  }

  //Processing of opening mappings preview popup wondow
  public void mappingsPreview() {
    if (DEFAULT_PICKLIST_VALUE != IntermMappingObject && null != IntermMappingObject) {
      //Initialization of preview variables
      mappingsPreview = new Maritz_Case_Mappings__c[] { };
      mappingsAdditionalPreview = new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
      targetOwnerMappingPreview = new Maritz_Mappings_Ownership__c();
      recordTypeMappingPreview = '';
      lookupEntytyMappingPreview = new LookupEntytyMappingObject[] { };

      //Compile mappingsPreview 
      for (Maritz_Case_Mappings__c mapping : mappings) {
        if (mapping.Source_Field__c != null && mapping.Source_Field__c != DEFAULT_PICKLIST_VALUE) {
          mappingsPreview.add(mapping);
        }
      }

      //Compile mappingsAdditionalPreview
      for (Maritz_Case_Mappings_ForAdditionalFields__c mapping : mappingsAdditional) {
        if (mapping.Target_field__c != null && mapping.Target_field__c != DEFAULT_PICKLIST_VALUE && mapping.Value_of_the_target_field__c != null && mapping.Value_of_the_target_field__c != DEFAULT_PICKLIST_VALUE) {
          mappingsAdditionalPreview.add(mapping);
        }
      }

      //Compile targetOwnerMappingPreview
      if (targetOwnerMapping.Owner_Name__c != null && targetOwnerMapping.Owner_Name__c != DEFAULT_PICKLIST_VALUE && targetOwnerMapping.Type_Of_Ownership__c != null && targetOwnerMapping.Type_Of_Ownership__c != DEFAULT_PICKLIST_VALUE) {
        targetOwnerMappingPreview = targetOwnerMapping;
      }

      //Compile recordTypeMappingPreview
      if (recordTypeMapping.Record_Type_Name__c != null) {
        recordTypeMappingPreview = MappingHelper.getRecordTypeNameById(mappingObject, recordTypeMapping.Record_Type_Name__c);
      }

      //Compile lookupEntytyMappingPreview
      for (LookupEntytyMappingObject mappingEntity : lookupEntytyMapping) {
        Maritz_Mappings_Lookups__c mapping = mappingEntity.maritzMappingsLookup;
        if (mappingEntity.maritzMappingsLookup.Source_Field__c != null && mappingEntity.maritzMappingsLookup.Source_Field__c != DEFAULT_PICKLIST_VALUE &&
            mappingEntity.maritzMappingsLookup.External_Id_field__c != null && mappingEntity.maritzMappingsLookup.External_Id_field__c != DEFAULT_PICKLIST_VALUE) {
          lookupEntytyMappingPreview.add(mappingEntity);
        }
      }
      displaySummeryPopup = true;
    }

  }

  //Close mappings preview popup wondow
  public void closeMappingsPreview() {
    displaySummeryPopup = false;
  }
  // OnChange handler for field mapping selection. Checks if all required mappings are entered before allowing to save.
  public void fieldMappingChanged() {
    Boolean result = true;
    for (Maritz_Case_Mappings__c mapping : mappings) {
      // not required check required fields, becouse some required fileds populated in business handler
      if (mapping.Source_Field__c == null || mapping.Source_Field__c == DEFAULT_PICKLIST_VALUE) {
        result = false;
        break;
      }
    }
    canSaveMappings = true;
  }

  public PageReference showTemplateNamePopup() {
    displaySetTemplateNamePopup = true;
    templateName = '';
    return null;
  }

  public PageReference closeTemplateNamePopup() {
    displaySetTemplateNamePopup = false;
    return null;
  }

  // Removes previous field mappings for Source object and saves new mappings for Source&Target objects pair. Closes Field Mappings popup.
  private Boolean saveAsNew = false;
  public PageReference saveAsNewMappings() {
    saveAsNew = true;
    return saveMappings();
  }

  public PageReference activateTemplate() {
    setTemplateActive(selectedTemplate);

    isActiveSelectedTemplate  = true;
    return null;
  }

  /**
  * @description Set the passed template active
  * @param template 
  */
  public void setTemplateActive(String template) {
	Maritz_Mapping_Templates__c[] toUpdate = new Maritz_Mapping_Templates__c[] {};
	for (Maritz_Mapping_Templates__c m : Maritz_Mapping_Templates__c.getAll().values()) {
      if (m.Name == template) {
        m.IsActive__c = true;
      } else {
        m.IsActive__c = false;
      }

      toUpdate.add(m);
    }

    update toUpdate;
  }

  public PageReference saveMappings() {
    // need specify template name
	System.debug('templateName  = ' + templateName);
	System.debug('selectedTemplate  = ' + selectedTemplate);
    if (isEmpty(templateName) && (selectedTemplate == NEW_TEMPLATE || saveAsNew == true)) {
      displaySetTemplateNamePopup = true; 
      return null;
    }

    // if create new template check that name is unique
    if (selectedTemplate == NEW_TEMPLATE) {
      if (templateName == NEW_TEMPLATE || null != Maritz_Mapping_Templates__c.getAll().get(templateName)) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please specify an unique Template Name.'));
        return null;
      }
    }

    if (DEFAULT_PICKLIST_VALUE != IntermMappingObject && null != IntermMappingObject) {
		System.debug('IntermMappingObject  = ' + IntermMappingObject);
      Map<String, Maritz_Case_Mappings__c> mappingsToUpdate = new Map<String, Maritz_Case_Mappings__c> ();
      Maritz_Mappings_Lookups__c[] lookupMappingsToUpdate = new Maritz_Mappings_Lookups__c[] { };
      Map<String, Maritz_Case_Mappings_ForAdditionalFields__c> additionalMappingsToUpdate = new Map<String, Maritz_Case_Mappings_ForAdditionalFields__c> ();
      Maritz_Mappings_Ownership__c targetOwnerMappingToUpdate = new Maritz_Mappings_Ownership__c();
	  /*
      Maritz_Case_Mappings__c[] caseMappings = mappings;
      Maritz_Case_Mappings_ForAdditionalFields__c[] addMappings = mappingsAdditional;
      Maritz_Mappings_Record_Type__c rtMapping = recordTypeMapping;
      LookupEntytyMappingObject[] lookupMappings = lookupEntytyMapping;
      Maritz_Mappings_Ownership__c ownerMapping = targetOwnerMapping;
	  */
	  Maritz_Case_Mappings__c[] caseMappings = new Maritz_Case_Mappings__c[]{};
      Maritz_Case_Mappings_ForAdditionalFields__c[] addMappings = new Maritz_Case_Mappings_ForAdditionalFields__c[]{};
      Maritz_Mappings_Record_Type__c rtMapping = new Maritz_Mappings_Record_Type__c();
      LookupEntytyMappingObject[] lookupMappings = new LookupEntytyMappingObject[]{};
      Maritz_Mappings_Ownership__c ownerMapping = new Maritz_Mappings_Ownership__c();
      if (saveAsNew == true) {
        // we need clone existing mapping for avoid overwrite existing mapping
		// Variables for cloned custom settings
		/*
		Maritz_Case_Mappings__c[] caseMappingsCloned = new Maritz_Case_Mappings__c[]{};
		Maritz_Case_Mappings_ForAdditionalFields__c[] addMappingsCloned = new Maritz_Case_Mappings_ForAdditionalFields__c[]{};
		Maritz_Mappings_Record_Type__c rtMappingCloned;//= new Maritz_Mappings_Record_Type__c() ;
		LookupEntytyMappingObject[] lookupMappingsCloned = new LookupEntytyMappingObject[]{};
		Maritz_Mappings_Ownership__c ownerMappingCloned;// = new Maritz_Mappings_Ownership__c();
		*/
		//Cloning of caseMappings
		//caseMappings[0] = caseMappings[0].clone(false, true, false, false)
        if (null != mappings) {
			//Maritz_Case_Mappings__c[] caseMappingsForClonned = new Maritz_Case_Mappings__c[]{};
			for (Maritz_Case_Mappings__c setting : mappings) {
				Maritz_Case_Mappings__c s = setting.clone(false, true, false, false);
				s.name = null;
				caseMappings.add(s);
			} 
		} 
		//Cloning of addMappings
		if (null != mappingsAdditional) {
			for (Maritz_Case_Mappings_ForAdditionalFields__c setting : mappingsAdditional) {
				Maritz_Case_Mappings_ForAdditionalFields__c s = setting.clone(false, true, false, false);
				s.name = null;
				addMappings.add(s);
			} 
		} 
		//Cloning of recordTypeMapping
		if (null != recordTypeMapping) {
			rtMapping = recordTypeMapping.clone(false, true, false, false);
			rtMapping.name = null;
		} 
		//Cloning of lookupMappings
		if (null != lookupEntytyMapping) {
			for (LookupEntytyMappingObject setting : lookupEntytyMapping) {
				Maritz_Mappings_Lookups__c lookupSetting = setting.maritzMappingsLookup.clone(false, true, false, false);
				lookupSetting.Name = null;
				lookupMappings.add(new LookupEntytyMappingObject(lookupSetting, setting.externalIdsOfTheRelateedObjectSO, setting.recordTypeOfTheRelatedObjectSO, setting.fieldsOfIntermediateObjectSO, mappingLookupLabels));
			} 
		} 
		System.debug('lookupMappings.size()  = ' + lookupMappings.size());
		//Cloning of ownerMapping
		if (null != targetOwnerMapping) {
			ownerMapping = targetOwnerMapping.clone(false, true, false, false);
			ownerMapping.name = null;
		} 
		/* old
        addMappings = (null != addMappings) ? addMappings.clone(false, true, false, false) : null;
        rtMapping = (null != rtMapping) ? rtMapping.clone(false, true, false, false) : null;
        lookupMappings = (null != lookupMappings) ? lookupMappings.clone(false, true, false, false) : null;
        ownerMapping = (null != ownerMapping) ? ownerMapping.clone(false, true, false, false) : null;
		*/
		//MAYBE THE NEXT WILL NOT BE NESESSARY
        // clear Name field of all settings
		/*
        if (null != caseMappings) {
          for (Maritz_Case_Mappings__c m : caseMappings) m.Name = null;
        }

        if (null != addMappings) {
          for (Maritz_Case_Mappings_ForAdditionalFields__c m : addMappings) m.Name = null;
        }

        // TODO: lookup

        if (null != rtMapping) {
          rtMapping.Name = null;
        }

        if (null != ownerMapping) {
          ownerMapping.Name = null;
        }
		*/
      } else {
		caseMappings = mappings;
		addMappings = mappingsAdditional;
		rtMapping = recordTypeMapping;
		lookupMappings = lookupEntytyMapping;
		ownerMapping = targetOwnerMapping;
	  }

      // Determination if new Field-to-field mappings should be created or refresh the existing/old ones
      for (Maritz_Case_Mappings__c mapping : caseMappings) {
        if (mapping.Source_Field__c != null && mapping.Source_Field__c != DEFAULT_PICKLIST_VALUE) {
          mapping.Target_Object__c = mappingObject;
          mappingsToUpdate.put(mapping.Target_Field__c, mapping);
        } else if (mapping.Id != null) {
          mappingsToDelete.add(mapping.Id);
          // clear mapping id
          mapping.Id = null;
        }
      }
	  System.debug('mappingsToUpdate.size()  = ' + mappingsToUpdate.size());
	  System.debug('mappingsToDelete.size()  = ' + mappingsToDelete.size());
      // Determination if new Additional Static mappings should be created or refresh the existing/old ones
      Set<String> keySetAdditional = new Set<String> ();
      for (Maritz_Case_Mappings_ForAdditionalFields__c mapping : addMappings) {
        if (mapping.Target_field__c != null && mapping.Target_field__c != DEFAULT_PICKLIST_VALUE && mapping.Value_of_the_target_field__c != null && mapping.Value_of_the_target_field__c != DEFAULT_PICKLIST_VALUE) {
          if (!keySetAdditional.add(mapping.Target_field__c)) {
            String fieldName = getFieldNameOftargetObject(mapping.Target_field__c);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot save two static value mappings for ' + fieldName + ' field. Only one mapping should exist for one case field.'));
            return null;
          }
          additionalMappingsToUpdate.put(mapping.Target_field__c, mapping);
        } else if (mapping.Id != null) {
          mappingsToDelete.add(mapping.Id);

          // clear mapping id
          mapping.Id = null;
        }
      }
	  System.debug('additionalMappingsToUpdate.size()  = ' + additionalMappingsToUpdate.size());
	  System.debug('mappingsToDelete.size()  = ' + mappingsToDelete.size());

      //Validations
      Set<String> keySet = mappingsToUpdate.keySet();
      String fieldName = '';
      for (String field : additionalMappingsToUpdate.keySet()) {
        if (keySet.contains(field)) {
          fieldName = getFieldNameOftargetObject(field);
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot save Field-to-Field mapping and static value mapping for ' + fieldName + ' field. Only one mapping should exist for one case field.'));
          return null;
        }
      }

      // Determination if new Record type mappings should be created or refresh the existing/old ones
      if (rtMapping.Record_Type_Name__c != null) {
        rtMapping.Target_Object__c = mappingObject;
        rtMapping.Source_object__c = IntermMappingObject;

        if (rtMapping.Id != null) {
          mappingsToDelete.add(rtMapping.Id);

          // clear mapping id
          rtMapping.Id = null;
        }
      }

	  //System.debug('mappingsToUpdate.size()  = ' + mappingsToUpdate.size());
	  System.debug('mappingsToDelete.size()  = ' + mappingsToDelete.size());

      // Determination if new Lookup mappings should be created or refresh the existing/old ones
      for (LookupEntytyMappingObject mappingEntity : lookupMappings) {
        Maritz_Mappings_Lookups__c mapping = mappingEntity.maritzMappingsLookup;
        if (mapping.Source_Field__c != null && mapping.Source_Field__c != DEFAULT_PICKLIST_VALUE && mapping.External_Id_field__c != null && mapping.External_Id_field__c != DEFAULT_PICKLIST_VALUE) {
          lookupMappingsToUpdate.add(mapping);
        } else if (mapping.Id != null) {
          mappingsToDelete.add(mapping.Id);

          // clear mapping id
          mapping.Id = null;
        }
      }

	  System.debug('lookupMappingsToUpdate.size()  = ' + lookupMappingsToUpdate.size());
	  System.debug('mappingsToDelete.size()  = ' + mappingsToDelete.size());

      // Determination if new Ownership mapping should be created or refresh the existing/old ones
      if (ownerMapping.Owner_Name__c != null && ownerMapping.Owner_Name__c != DEFAULT_PICKLIST_VALUE && ownerMapping.Type_Of_Ownership__c != null && targetOwnerMapping.Type_Of_Ownership__c != DEFAULT_PICKLIST_VALUE) {
        targetOwnerMappingToUpdate = ownerMapping;
      } else if (ownerMapping.Id != null) {
        mappingsToDelete.add(ownerMapping.Id);

        // clear mapping id
        ownerMapping.Id = null;
      }

	  //System.debug('mappingsToUpdate.size()  = ' + mappingsToUpdate.size());
	  System.debug('mappingsToDelete.size()  = ' + mappingsToDelete.size());

      Savepoint sp = Database.setSavepoint();

      // Delete all changed mappings
      Database.delete(mappingsToDelete);
      mappingsToDelete = new Id[] { };
      if (mappingsAdditionalToDelete != null) {
        Database.delete(mappingsAdditionalToDelete);
        mappingsAdditionalToDelete = new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
      }
      Integer index;

      // Get maximum index for Field-to-Field 
      if (null != mappingsToUpdate && !mappingsToUpdate.isEmpty()) {
        index = getMaximumIndex(mappingsToUpdate.values() [0].getSobjectType().getDescribe().name);
        for (Maritz_Case_Mappings__c maping : mappingsToUpdate.values()) {
          if (maping.Name == null || maping.Name == '') {
            maping.Name = leadingZero(index, NUMBER_LENGTH_WITH_LEADING_ZERO);
            maping.Template_Name__c = templateName;
            index++;
          }
        }
      }

      // Get maximum index for Record Type mappings
      if (null != rtMapping) {
        index = getMaximumIndex(rtMapping.getSobjectType().getDescribe().name);
        if (rtMapping.Name == null || rtMapping.Name == '') {
          rtMapping.Name = leadingZero(index, NUMBER_LENGTH_WITH_LEADING_ZERO);
          rtMapping.Template_Name__c = templateName;
        }
      }

      // Get maximum index for Lookup mappings
      if (null != lookupMappingsToUpdate && !lookupMappingsToUpdate.isEmpty()) {
        index = getMaximumIndex(lookupMappingsToUpdate[0].getSobjectType().getDescribe().name);

        for (Maritz_Mappings_Lookups__c maping : lookupMappingsToUpdate) {
          if (maping.Name == null || maping.Name == '') {
            maping.Name = leadingZero(index, NUMBER_LENGTH_WITH_LEADING_ZERO);
            maping.Template_Name__c = templateName;
            index++;
          }
        }
      }

      // Get maximum index for additional mappings
      if (null != additionalMappingsToUpdate && !additionalMappingsToUpdate.isEmpty()) {
        index = getMaximumIndex(additionalMappingsToUpdate.values() [0].getSobjectType().getDescribe().name);

        for (Maritz_Case_Mappings_ForAdditionalFields__c maping : additionalMappingsToUpdate.values()) {
          if (maping.Name == null || maping.Name == '') {
            maping.Name = leadingZero(index, NUMBER_LENGTH_WITH_LEADING_ZERO);
            maping.Template_Name__c = templateName;
            index++;
          }
        }
      }

      // Get maximum index for Onership mappings
      if (null != targetOwnerMappingToUpdate && null != targetOwnerMappingToUpdate.Source_object__c) {
        index = getMaximumIndex(targetOwnerMappingToUpdate.getSobjectType().getDescribe().name);
        if (targetOwnerMappingToUpdate.Name == null || targetOwnerMappingToUpdate.Name == '') {
          targetOwnerMappingToUpdate.Name = leadingZero(index, NUMBER_LENGTH_WITH_LEADING_ZERO);
          targetOwnerMappingToUpdate.Template_Name__c = templateName;
          index++;
        }
      }

      // Upsert of the all mappings
	  System.debug('mappingsToUpdate = ' + mappingsToUpdate);
	  System.debug('rtMapping = ' + rtMapping);
	  System.debug('lookupMappingsToUpdate = ' + lookupMappingsToUpdate);
	  System.debug('additionalMappingsToUpdate = ' + additionalMappingsToUpdate);
	  System.debug('targetOwnerMappingToUpdate = ' + targetOwnerMappingToUpdate);
      try {
        upsert mappingsToUpdate.values();
        if (null != rtMapping) {
          upsert rtMapping;
        }
        if (null != lookupMappingsToUpdate) {
          upsert lookupMappingsToUpdate;
        }
        if (null != additionalMappingsToUpdate) {
          upsert additionalMappingsToUpdate.values();
        }
        if (null != targetOwnerMappingToUpdate && null != targetOwnerMappingToUpdate.Source_object__c) {
          upsert targetOwnerMappingToUpdate;
        }
      } catch(Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        displaySetTemplateNamePopup = false;
        Database.rollback(sp);
        return null;
      }

      // create new template
      if (null == Maritz_Mapping_Templates__c.getAll().get(templateName) && (selectedTemplate == NEW_TEMPLATE || saveAsNew == true)) {
        Maritz_Mapping_Templates__c template = new Maritz_Mapping_Templates__c(Name = templateName);
        insert template;

        // recalc template options
        selectedTemplate = templateName;
        templateOptions.add(new SelectOption(templateName, templateName));
      }

      displaySetTemplateNamePopup = false;
      saveAsNew = false;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Mappings saved successfully'));
    }
    return null;
  }

  public void removeMapping() { //todo
    Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
    //If the contact is an existing contact then add it to the list to delete from the databse
    //if(allContactList[indexVal - 1].Id != null)
    mappingsAdditionalToDelete.add(mappingsAdditional[indexVal - 1]);
    //Remove the contact from the table    
    mappingsAdditional.remove(indexVal - 1);

  }

  /*-----------------DELETE MAPPING TEMPLATE------------------*/
  /**
  * @description The method checks if the current template is active. 
  If yes, popup to select new active template will be shown. 
  If no, deleteTemplate() will be invoked and the current tamplate will be deleted.
  * @return PageReference 
  */
  public PageReference checkIfTemplateActive() {
	// Delete current template from the templateOptions[] select list 
	for (Integer i = 0; i < templateOptions.size(); i++) {
		if (templateOptions[i].getValue().equals(selectedTemplate)) {
			templateOptions.remove(i);
			break;
		}
	}
	if (isActiveSelectedTemplate) {
		displaySetActivatePopup = true;
		return null;
	}
	return deleteTemplate();
  }

  /**
  * @description Set active template which was choosen on setActivePopup popup, before deletion 
  * @return PageReference 
  */
  public PageReference activateNewTemplateAndDelete() {
		setTemplateActive(newActiveTemplate);
		selectedTemplate = newActiveTemplate;
		return deleteTemplate();
  }

  /**
  * @description The method deletes the current template.
  * @return PageReference 
  */
  public PageReference deleteTemplate() {
	Maritz_Mapping_Templates__c templateToDelete = Maritz_Mapping_Templates__c.getAll().get(selectedTemplate);
	try {
		//Delete the mapping template
		Database.delete(templateToDelete);
		//Delete the mappings
		cleareMappings();
		displaySetActivatePopup = false;
	} catch (Exception e) {
		 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error deletion template. The template name is' + selectedTemplate));
	}
	
	return null;
  }

  /**
  * @description Cancel button on setActivePopup popup
  * @return PageReference 
  */
  public PageReference closeSetActivePopup() {
	templateOptions = null;
	displaySetActivatePopup = false;
	return null;
  }
  /*-------------------------------------*/

  public void addAdditionalMappingRow() { //todo
    if (null == mappingsAdditional) {
      mappingsAdditional = new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
    }
    Maritz_Case_Mappings_ForAdditionalFields__c newAdditionalMapping = new Maritz_Case_Mappings_ForAdditionalFields__c();
    newAdditionalMapping.Source_object__c = intermMappingObject;
    newAdditionalMapping.Target_object__c = mappingObject;

    mappingsAdditional.add(newAdditionalMapping);
  }

  public PageReference recalcDependValues() {
    // if first run create default template
    initAction();

    if (DEFAULT_PICKLIST_VALUE != IntermMappingObject && null != IntermMappingObject) {
      existingMappingRecordIdsSet = new Set<Id> ();

      // Retrieve field-to-field mappings 
      mappings = tryGetExistingFieldToFieldMappings();

      if (null == mappings) {
        mappings = createFieldToFieldMappings();
      }

      // Retrieve Static Value Mappings
      mappingsAdditional = tryGetExistingAdditionalMappings();

      // Initialize list of all Source object fields
      getIntermFieldsForMapping(IntermMappingObject);

      // Retrieve Record Type Mappings
      recordTypeSO = getRecordTypes(mappingObject);

      targetMappingFieldsSO = getTargetFieldsForMapping(mappingObject);

      lookupEntytyMapping = tryGetExistingLookupMappings();

      targetOwnerMapping = tryGetExistingOwnershipMappings();

      // Retrieve record type mapping
      recordTypeMapping = tryGetExistingRecordTypeMapping();

      if (null == recordTypeMapping) {
        recordTypeMapping = createRecordTypeMapping();
      }
    } else {
      cancelMappings();
    }
    return null;
  }

  //TODO
  public void cleareMappings() {
    try {
      if (!existingMappingRecordIdsSet.isEmpty()) {
        List<Id> listId = new List<Id> (existingMappingRecordIdsSet);
        Database.delete(listId);
        recalcDependValues();
      }
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Mappings cleared successfully'));
    } catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error clearing mappings'));
    }
  }

  //LookupEntytyMappingObject keeps structure for lookup section
  class LookupEntytyMappingObject {
    public Maritz_Mappings_Lookups__c maritzMappingsLookup {
      get {
        maritzMappingsLookup.External_Id_field__c = externalIdsOfTheRelateedObject;
        maritzMappingsLookup.Record_type__c = recordTypeOfTheRelatedObject;
        maritzMappingsLookup.Source_field__c = fieldOfIntermediateObject;

        return maritzMappingsLookup;
      }
      set;
    }
    public String targetLookupField { get; set; }
    public String externalIdsOfTheRelateedObject { get;
      set {
        if (null != value) {
          externalIdsOfTheRelateedObject = value;
        } else {
          externalIdsOfTheRelateedObject = externalIdsOfTheRelateedObjectSO[0].getValue();
        }
      }
    }
    public SelectOption[] externalIdsOfTheRelateedObjectSO { get;
      set {
        try {
          value[0].getvalue();
          externalIdsOfTheRelateedObjectSO = value;
        } catch(Exception e) {
          externalIdsOfTheRelateedObjectSO = new SelectOption[] { };
          externalIdsOfTheRelateedObjectSO.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));
        }
      }
    }
    public String recordTypeOfTheRelatedObject { get;
      set {
        if (null != value) {
          recordTypeOfTheRelatedObject = value;
        } else {
          recordTypeOfTheRelatedObject = recordTypeOfTheRelatedObjectSO[0].getValue();
        }
      }
    }
    public SelectOption[] recordTypeOfTheRelatedObjectSO { get;
      set {
        recordTypeOfTheRelatedObjectSO = new SelectOption[] { };
        recordTypeOfTheRelatedObjectSO.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_REC_TYPE_TEXT));
        try {
          value[0].getvalue();
          recordTypeOfTheRelatedObjectSO.addAll(value);
        } catch(Exception e) {

        }
      }
    }
    public String fieldOfIntermediateObject { get;
      set {
        if (null != value) {
          fieldOfIntermediateObject = value;
        } else {
          fieldOfIntermediateObject = fieldsOfIntermediateObjectSO[0].getValue();
        }
      }
    }
    public SelectOption[] fieldsOfIntermediateObjectSO { get;
      set {
        try {
          value[0].getvalue();
          fieldsOfIntermediateObjectSO = value;
        } catch(Exception e) {
          fieldsOfIntermediateObjectSO = new SelectOption[] { };
          fieldsOfIntermediateObjectSO.add(new SelectOption(DEFAULT_PICKLIST_VALUE, DEFAULT_PICKLIST_TEXT));
        }
      }
    }
    public String targetLookupFieldLabel { get; set; }

    public LookupEntytyMappingObject(Maritz_Mappings_Lookups__c lookupCustSetting, SelectOption[] ExternalIds, SelectOption[] recrdTps, SelectOption[] intermediateFields, Map<String, String> mappingLookupLabel) {
      maritzMappingsLookup = lookupCustSetting;
      externalIdsOfTheRelateedObjectSO = ExternalIds;
      recordTypeOfTheRelatedObjectSO = recrdTps;
      fieldsOfIntermediateObjectSO = intermediateFields;

      targetLookupField = lookupCustSetting.Target_lookup_field__c;
      externalIdsOfTheRelateedObject = lookupCustSetting.External_Id_field__c;
      recordTypeOfTheRelatedObject = lookupCustSetting.Record_type__c;
      fieldOfIntermediateObject = lookupCustSetting.Source_field__c;
      targetLookupFieldLabel = mappingLookupLabel.get(targetLookupField);
    }
	/*
	public Maritz_Mappings_Lookups__c clone(){
		Maritz_Mappings_Lookups__c result = new Maritz_Mappings_Lookups__c();
		result.Target_lookup_field__c = targetLookupField;
		result.External_Id_field__c = externalIdsOfTheRelateedObject;
		result.Record_type__c = recordTypeOfTheRelatedObject;
		result.Source_field__c = fieldOfIntermediateObject;

		return result;
	}
	*/
  }

  //--------------------------------------------------------------------------
  // Helpers

  public static void sortList(List<SObject> items, String sortField) {
    // Create a map that can be used for sorting
    Map<Object, SObject[]> objectMap = new Map<Object, SObject[]> ();
    for (SObject ob : items) {
      if (objectMap.get(ob.get(sortField)) == null) { // For non SObject use obj.ProperyName
        objectMap.put(ob.get(sortField), new List<SObject> ());
      }
      objectMap.get(ob.get(sortField)).add(ob);
    }

    // Sort the keys
    List<object> keys = new List<object> (objectMap.keySet());
    keys.sort();

    SObject[] results = new SObject[] { };
    for (object key : keys) {
      results.addAll(objectMap.get(key));
    }

    // Apply the sorted values to the source list
    items.clear();
    for (SObject ob : results) {
      items.add(ob);
    }
  }

  private void sortMap(Map<String, Object> items, Object[] sortedList) {
    String[] keys = new String[] { };
    keys.addAll(items.keySet());

    keys.sort();
    sortedList.clear();
    for (String k : keys) {
      sortedList.add(items.get(k));
    }
  }

  private Boolean isFieldRequired(Schema.DescribeFieldResult field) {
    return(field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate());
  }

  public static String leadingZero(Integer num, Integer countZeros) {
    String formatNumber = String.valueOf(num);
    Integer countAdditionalZero = countZeros - formatNumber.length();
    for (Integer i = 0; i < countAdditionalZero; i++) {
      formatNumber = '0' + formatNumber;
    }
    return formatNumber;
  }

  private Integer getMaximumIndex(String obj) {
    AggregateResult[] maxExistingMappingIndex = Database.query('SELECT MAX(Name) maxIndex FROM ' + obj);
    Object maxIndex = maxExistingMappingIndex[0].get('maxIndex');
    if (maxIndex == null) {
      return 0;
    }

    return Integer.valueOf(maxIndex) + 1;
  }

  private String getFieldNameOftargetObject(String fieldApiName) {
    String fieldName = '';
    if (null != targetMappingFieldsSO && !targetMappingFieldsSO.isEmpty()) {
      for (SelectOption so : targetMappingFieldsSO) {
        if (so.getValue().equals(fieldApiName)) {
          fieldName = so.getLabel();
          break;
        }
      }
    }
    return fieldName;
  }

  // check if exist mapping without template, if exists assign it to default template
  private void initAction() {
    Maritz_Mapping_Templates__c[] templates = Maritz_Mapping_Templates__c.getAll().values();
    if (templates.isEmpty()) {
      // create default Template
      Maritz_Mapping_Templates__c defaultTemplate = new Maritz_Mapping_Templates__c(
        Name = DEFAULT_TEMLATE_NAME,
        isActive__c = true
      ); 

      insert defaultTemplate;

      // assign all settings with empty template to default template
      sObject[] toUpdateMappings = new sObject[] {};

      // Maritz Case Mappings
      for (Maritz_Case_Mappings__c m : Maritz_Case_Mappings__c.getAll().values()) {
        if (isEmpty(m.Template_Name__c)) {
          m.Template_Name__c = DEFAULT_TEMLATE_NAME;
          toUpdateMappings.add(m);
        }
      }

      // Maritz_Case_Mappings_ForAdditionalFields__c
      for (Maritz_Case_Mappings_ForAdditionalFields__c m : Maritz_Case_Mappings_ForAdditionalFields__c.getAll().values()) {
        if (isEmpty(m.Template_Name__c)) {
          m.Template_Name__c = DEFAULT_TEMLATE_NAME;
          toUpdateMappings.add(m);
        }
      }

      // Maritz_Mappings_Lookups__c
      for (Maritz_Mappings_Lookups__c m : Maritz_Mappings_Lookups__c.getAll().values()) {
        if (isEmpty(m.Template_Name__c)) {
          m.Template_Name__c = DEFAULT_TEMLATE_NAME;
          toUpdateMappings.add(m);
        }
      }

      // Maritz_Mappings_Ownership__c
      for (Maritz_Mappings_Ownership__c m : Maritz_Mappings_Ownership__c.getAll().values()) {
        if (isEmpty(m.Template_Name__c)) {
          m.Template_Name__c = DEFAULT_TEMLATE_NAME;
          toUpdateMappings.add(m);
        }
      }

      // Maritz_Mappings_Record_Type__c
      for (Maritz_Mappings_Record_Type__c m : Maritz_Mappings_Record_Type__c.getAll().values()) {
        if (isEmpty(m.Template_Name__c)) {
          m.Template_Name__c = DEFAULT_TEMLATE_NAME;
          toUpdateMappings.add(m);
        }
      }

      update toUpdateMappings;

      this.selectedTemplate = DEFAULT_TEMLATE_NAME;
    } else if (isEmpty(selectedTemplate)) {
      // find active template
      for (Maritz_Mapping_Templates__c t : Maritz_Mapping_Templates__c.getAll().values()) {
        if (t.isActive__c) {
          this.selectedTemplate = t.Name;
        }
      }
    }
  }

  private Boolean isEmpty(String s) {
    return null == s || s.trim().length() == 0;
  }
}