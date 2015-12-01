/**********************************************************************
Name: MappingHelper
Copyright � notice: Nissan Motor Company
======================================================
Purpose:
Helper class which contains generic methords for mapping.

======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy sychev 06/26/2015 Created                            
***********************************************************************/
public with sharing class MappingHelper { 


  // get describe for sObject fields
  public static Map<String,DescribeFieldResult> getFields(String objectName) {
    //CfG.preCondition(!CfG.isEmpty(objectName), 'object is required');

    Map<String,DescribeFieldResult> result = new Map<String,DescribeFieldResult> ();

    try {
      Map<String,Schema.SObjectField> fields = Schema.describeSObjects(new String[] { objectName }) [0].fields.getMap();

      for (String key : fields.keySet()) {
        final DescribeFieldResult fieldDescribe = fields.get(key).getDescribe();
        result.put(fieldDescribe.getName(), fieldDescribe);
      }
    } catch(Exception ex) {
      // no such object - return an empty list
    }

    return result;
  }

  // Convert Object to salesforce field type
  @testVisible public static Object convertValue(DescribeFieldResult resultField, Object data) {
    Object result;
    Schema.DisplayType resultType = resultField.getType();
    String value = String.valueOf(data);
    try {
      if (resultType == Schema.DisplayType.DATETIME) {
        try {
          result = (!IsEmptyOrBlank(value)) ? DateTime.valueOf(value) : null;
        } catch(Exception e) {
          result = JSON.deserialize('"' + value + '"', DateTime.class);
        }
      } else if (resultType == Schema.DisplayType.DATE) {
        try {
          result = (!IsEmptyOrBlank(value)) ? Date.parse(value) : null;
        } catch(Exception e) {
          DateTime dt = (DateTime) JSON.deserialize('"' + value + '"', DateTime.class);
          result = date.newInstance(dt.Year(), dt.Month(), dt.Day());
        }
      } else if (resultType == Schema.DisplayType.BOOLEAN) {
        result = (!IsEmptyOrBlank(value)) ? Boolean.valueOf(value) : false;
      } else if (resultType == Schema.DisplayType.INTEGER) {
        result = (!IsEmptyOrBlank(value)) ? Integer.valueOf(value) : null;
      } else if ((resultType == Schema.DisplayType.DOUBLE) ||
      (resultType == Schema.DisplayType.PERCENT)) {
        result = (!IsEmptyOrBlank(value)) ? Double.valueOf(value) : null;
      } else if (resultType == Schema.DisplayType.CURRENCY) {
        result = (!IsEmptyOrBlank(value)) ? Decimal.valueOf(value) : null;
      } else if ((resultType == Schema.DisplayType.STRING) ||
      (resultType == Schema.DisplayType.TEXTAREA) ||
      (resultType == Schema.DisplayType.PICKLIST) ||
      (resultType == Schema.DisplayType.ID) ||
      (resultType == Schema.DisplayType.PHONE) ||
      (resultType == Schema.DisplayType.EMAIL) ||
      (resultType == Schema.DisplayType.URL)) {
        if (!IsEmptyOrBlank(value)) {
          final Integer length = resultField.getLength();
          result = (value.length() > length) ? value.substring(0, length) : value;
        } else {
          result = null;
        }
      } else {
        //CfG.postCondition(false, 'Unsupported mapping type: ' + resultField.getName()); todo
      }
    } catch(Exception ex) {

    }

    return result;
  }

  // Get Id of related lookup field 
  public static Map<String, String> searchLookupRecords(Maritz_Mappings_Lookups__c mapping, Set<String> data) {
		Map<String, String> result = new Map<String, String>();

    //String result;
    SObject [] obj;

		// put to list only not empty values
    List<String> value = new List<String>();
		for (String v : data) {
			if (null != v && v.trim().length() > 0) {
				value.add(v);
			}
		}

    String relatedObjectName = getRelatedObjectTypeName(mapping.Target_Object__c, mapping.Target_lookup_field__c);
    if (null != relatedObjectName) {
        String query = 'SELECT Id, ' + mapping.External_Id_field__c + ' FROM ' + relatedObjectName + ' WHERE ' + mapping.External_Id_field__c + ' IN : value';

        // Try to get record type
        Id recordTypeId;
        if (null != mapping.Record_type__c && ('' != mapping.Record_type__c)) {
            query += ' AND RecordTypeId = \'' + mapping.Record_type__c + '\'';
        }

        try {
            obj = Database.query(query);    
            if (null != obj && !obj.isEmpty()) {
                for (SObject o : obj) {
                    if(null != o.get(mapping.External_Id_field__c)) {
                        result.put(String.valueOf(o.get(mapping.External_Id_field__c)), String.valueOf(o.get('Id')));
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Unable to retrieve related record by following query: ' + query);
        }
    }
        return result;
  } 

  // Get Id of related Account and Contact fields 
  public static Map<String, Map<String, String>> searchAccountLookupRecords(Maritz_Mappings_Lookups__c mapping, Set<String> data) {
		Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();

    //String result;
    SObject [] obj;

		// put to list only not empty values
    List<String> value = new List<String>();
		for (String v : data) {
			if (null != v && v.trim().length() > 0) {
				value.add(v);
			}
		}

    String relatedObjectName = getRelatedObjectTypeName(mapping.Target_Object__c, mapping.Target_lookup_field__c);
    if (null != relatedObjectName) {
        String query = 'SELECT Id, PersonContactId, ' + mapping.External_Id_field__c + ' FROM ' + relatedObjectName + ' WHERE ' + mapping.External_Id_field__c + ' IN : value';

        // Try to get record type
        Id recordTypeId;
        if (null != mapping.Record_type__c && ('' != mapping.Record_type__c)) {
            query += ' AND RecordTypeId = \'' + mapping.Record_type__c + '\'';
        }

        try {
            obj = Database.query(query);    
            if (null != obj && !obj.isEmpty()) {
                for (SObject o : obj) {
                    if(null != o.get(mapping.External_Id_field__c)) {
						Map<String, String> accountIdAndContactId = new Map<String, String>();
						accountIdAndContactId.put(String.valueOf(o.get('Id')), String.valueOf(o.get('PersonContactId'))); 
                        result.put(String.valueOf(o.get(mapping.External_Id_field__c)), accountIdAndContactId);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Unable to retrieve related record by following query: ' + query);
        }
    }
        return result;
  } 


  public static Boolean IsEmptyOrBlank(String value) {
    return value == null || value == '';
  }


  //----------------Load methods which retrieve existed mappings----------------------//
    public static Maritz_Case_Mappings__c[] loadMappings(String sourceObjectName, String targetObjectName, String template) {
       if (!isEmpty(sourceObjectName) && !isEmpty(targetObjectName)) {
            return [
                   SELECT Name, Source_Field__c, Source_Object__c, Target_Field__c, Target_Object__c
                     FROM Maritz_Case_Mappings__c 
                    WHERE Source_Object__c = : sourceObjectName 
                          AND Target_Object__c = : targetObjectName 
                          AND Template_Name__c = :template
                    ORDER BY Source_Field__c]; //ORDER BY Source_Field__c
        } else {
            return new Maritz_Case_Mappings__c[] { };
        }
    }

    public static Maritz_Mappings_Record_Type__c[] loadRecordTypeMappings(String sourceObjectName, String targetObjectName, String template) {
        if (!isEmpty(sourceObjectName) && !isEmpty(targetObjectName)) {
            return [
              SELECT Name, Record_Type_Name__c, Source_Object__c, Target_Object__c
                FROM Maritz_Mappings_Record_Type__c 
               WHERE Source_Object__c = : sourceObjectName 
                     AND Target_Object__c = : targetObjectName 
                     AND Template_Name__c = :template
               LIMIT 1]; //ORDER BY Source_Field__c
        } else {
            return new Maritz_Mappings_Record_Type__c[] { };
        }
    }

    public static Maritz_Mappings_Lookups__c[] loadLookUpMappings(String sourceObjectName, String targetObjectName, String template) {
        if (!isEmpty(sourceObjectName) && !isEmpty(targetObjectName)) {
            return [ 
              SELECT Name, External_Id_field__c, Source_Object__c, Target_Object__c, 
                     Record_type__c, Source_field__c, Target_lookup_field__c
                FROM Maritz_Mappings_Lookups__c 
               WHERE Source_Object__c = : sourceObjectName 
                     AND Target_Object__c = : targetObjectName
                     AND Template_Name__c = :template]; //ORDER BY Source_Field__c
        } else {
            return new Maritz_Mappings_Lookups__c[] { };
        }
    }

    public static Maritz_Case_Mappings_ForAdditionalFields__c[] loadAdditionalMappings(String sourceObjectName, String targetObjectName, String template) {
        if (!isEmpty(sourceObjectName) && !isEmpty(targetObjectName)) {
            return [ 
              SELECT Name, Value_of_the_target_field__c, Source_Object__c, Target_Field__c, Target_Object__c
                FROM Maritz_Case_Mappings_ForAdditionalFields__c 
               WHERE Source_Object__c = : sourceObjectName 
                     AND Target_Object__c = : targetObjectName 
                     AND Template_Name__c = :template
               ORDER BY Target_Field__c]; //ORDER BY Source_Field__c
        } else {
            return new Maritz_Case_Mappings_ForAdditionalFields__c[] { };
        }
    }

    public static Maritz_Mappings_Ownership__c[] loadOwnershipMappings(String sourceObjectName, String targetObjectName, String template) {
        if (!isEmpty(sourceObjectName) && !isEmpty(targetObjectName)) {
            return [ 
              SELECT Name, Type_Of_Ownership__c, Source_Object__c, Owner_Name__c, Target_Object__c
                FROM Maritz_Mappings_Ownership__c 
               WHERE Source_Object__c = : sourceObjectName 
                     AND Target_Object__c = : targetObjectName
                     AND Template_Name__c = :template 
               LIMIT 1]; //ORDER BY Source_Field__c
        } else {
            return new Maritz_Mappings_Ownership__c[] { };
        }
    }
    //-------------------------------------------------------------------------------//

    public static Id getRecordTypeByName (String obj, String recTypeName) {
        Id result;
        DescribeSObjectResult[] res = Schema.describeSObjects(getListWithOneObject(obj));
        if (null != res && !res.isEmpty()) {
            Schema.DescribeSObjectResult d = res[0];
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get(recTypeName);
            if (null != rtByName) {
                result = rtByName.getRecordTypeId(); 
            }
        }
        return result;
    }

    public static Id getRecordTypeById (String obj, String recTypeId) {
        Id result;
        DescribeSObjectResult[] res = Schema.describeSObjects(getListWithOneObject(obj));
        if (null != res && !res.isEmpty()) {
            Schema.DescribeSObjectResult d = res[0];
            Map<Id,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosById();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get((Id)recTypeId);
            if (null != rtByName) {
                result = rtByName.getRecordTypeId(); 
            }
        }
        
        return result;
    }

    public static String getRecordTypeNameById (String obj, String recTypeId) {
        String result;
        DescribeSObjectResult[] res = Schema.describeSObjects(getListWithOneObject(obj));
        if (null != res && !res.isEmpty()) {
            Schema.DescribeSObjectResult d = res[0];
            Map<Id,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosById();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get((Id)recTypeId);
            if (null != rtByName) {
                result = rtByName.getName(); 
            }
        }
        
        return result;
    }

    public static Boolean isEmpty(Object o) {
        if (null == o) {
          return true;
        } else if (o instanceof String) {
          return (0 == ((String)o).trim().length());
        } else if (o instanceof List<Object>) {
          return (0 == ((List<Object>)o).size());
        } else {
          return false;
        }
    }

    public static String[] getListWithOneObject(String obj) {
        String[] lst = new String[] { };
        if (obj != null) {
            lst.add(obj);
        }
        return lst;
    }

    public static String getRelatedObjectTypeName(String obj, String lookupFieldName) {
        String result;
        DescribeSObjectResult[] res = Schema.describeSObjects(getListWithOneObject(obj)); 
        Map<String,Schema.SObjectField> fields = res[0].fields.getMap();
        Schema.DescribeFieldResult field = fields.get(lookupFieldName).getDescribe();
        if (field.isUpdateable() && field.isCreateable() && (field.getType() == Schema.DisplayType.Reference)) {
            Set<Schema.sObjectType> relatedObjects = new Set<Schema.sObjectType>(field.getReferenceTo());
            result = new List<Schema.sObjectType>(relatedObjects)[0].getDescribe().getName();
        }

        return result;
    }

}