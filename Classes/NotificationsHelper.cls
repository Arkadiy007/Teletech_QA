public class NotificationsHelper {
    private static final Map<String, String> customLookupsThatMayBeTracked = new Map<String, string> { // the map of possibly tracked lookup fields of Case object
        'lastmodifiedbyid' => 'lastmodifiedby.name',
        'part__c' => 'part__r.name',
        'part_incident_report__c' => 'part_incident_report__r.name',
        'sorting_report__c' => 'sorting_report__r.name',
        'ownerid' => 'owner.name'
    };
    
    private static Notification_Settings__c notificationSettings {get; set;}
    private static Set<String> trackedFields = new Set<String> ();
    private static Map<Id, Part_Incident_Report__c> pirsWithLookupInfo = new Map<Id, Part_Incident_Report__c>();
    private static Map<Id, Sorting_Report__c> srsWithLookupInfo = new Map<Id, Sorting_Report__c>();
    private static Map<Id, Monetary_Claim__c> mcsWithLookupInfo = new Map<Id, Monetary_Claim__c>();


    public static Boolean notificationsCreated {get {if(notificationsCreated == null) {return false;} else {return notificationsCreated;}} set;}


    public static void createNotifications(Map<Id, Part_Incident_Report__c> newMap, Map<Id, Part_Incident_Report__c> oldMap){
        getCustomSettings();
        getTrackedFieldsSetForPIR();
        getPIRsWithLookUpInfoMap(newMap);
        
        List<EQANotification__c> notificationList = new List<EQANotification__c> ();

        for (Part_Incident_Report__c pir : newMap.values()) {
                Set<String> modifiedFields = setOfChangedFields(pir, oldMap.get(pir.Id));
                
                notifyOnAnyFieldUpdateProcessing(modifiedFields, pir, oldMap.get(pir.Id), notificationList);
        }
        
        try {
            insert notificationList;
            notificationsCreated = true;
        }
        
        catch(Exception e) {
            System.debug('Exception occured on notification creation: ' + e.getMessage());
        }
    }

    public static void createNotifications(Map<Id, Sorting_Report__c> newMap, Map<Id, Sorting_Report__c> oldMap){
        getCustomSettings();
        getTrackedFieldsSetForSR();
        getSRsWithLookUpInfoMap(newMap);
        
        List<EQANotification__c> notificationList = new List<EQANotification__c> ();

        for (Sorting_Report__c pir : newMap.values()) {
                Set<String> modifiedFields = setOfChangedFields(pir, oldMap.get(pir.Id));
                
                notifyOnAnyFieldUpdateProcessing(modifiedFields, pir, oldMap.get(pir.Id), notificationList);
        }
        
        try {
            insert notificationList;            
        }
        
        catch(Exception e) {
            System.debug('Exception occured on notification creation: ' + e.getMessage());
        }
    }

    public static void createNotifications(Map<Id, Monetary_Claim__c> newMap, Map<Id, Monetary_Claim__c> oldMap){
        getCustomSettings();
        getTrackedFieldsSetForMC();
        getMCsWithLookUpInfoMap(newMap);
        
        List<EQANotification__c> notificationList = new List<EQANotification__c> ();

        for (Monetary_Claim__c pir : newMap.values()) {
                Set<String> modifiedFields = setOfChangedFields(pir, oldMap.get(pir.Id));
                
                notifyOnAnyFieldUpdateProcessing(modifiedFields, pir, oldMap.get(pir.Id), notificationList);
        }
        
        try {
            insert notificationList;            
        }
        
        catch(Exception e) {
            System.debug('Exception occured on notification creation: ' + e.getMessage());
        }
    }


    

    private static void notifyOnAnyFieldUpdateProcessing(Set<String> modifiedFieldsLocal, sObject obj, sObject oldObj,
                                                         List<EQANotification__c> notificationListLocal) {
            
        Set<String> trackedFieldsLocal = new Set<String>(trackedFields);
        Boolean isTrackingFieldsChanges = isSetsIntersection(trackedFieldsLocal, modifiedFieldsLocal);
        trackedFieldsLocal.retainAll(modifiedFieldsLocal);
        
        if (isTrackingFieldsChanges) {
            notificationListLocal.add(createNotificationWithFieldHistory(obj, oldObj, trackedFieldsLocal));
        }
    }

    private static EQANotification__c createNotificationWithFieldHistory(sObject obj, sObject oldObj, Set<String> changedFields){
        String longDescription = 'Object fields updated: <br/> ';
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(obj);

        for (String field : changedFields) {
            if (customLookupsThatMayBeTracked.containsKey(field)) {
                String lookupField = customLookupsThatMayBeTracked.get(field);
                String[] splitedFieldNameAndName = lookupField.split('\\.');
                String lookupObjectName = splitedFieldNameAndName[0];
                String lookupObjectFieldName = splitedFieldNameAndName[1];
                SObject objWithLookupInfo = getObjWithLookupInfo(obj);
                SObject lookupObject = objWithLookupInfo.getSObject(lookupObjectName);

                if (null == lookupObject) {
                    longDescription += '<br> <b>' + fieldMap.get(field).getDescribe().getLabel().removeEndIgnoreCase('id') + '</b>' + ' to \'not assigned\'';
                } else {
                    longDescription += '<br> <b>' + fieldMap.get(field).getDescribe().getLabel().removeEndIgnoreCase('id') + '</b> ' + 'changed to \''+ lookupObject.get(lookupObjectFieldName) +'\'';
                }
            } else {
                if(oldObj == null || oldObj.get(field) == null){
                    longDescription += '<br> <b>' + fieldMap.get(field).getDescribe().getLabel() + '</b> changed to \''+ obj.get(field) +'\'';
                } 
				else if (obj.get(field) == null){
                    longDescription += '<br><b>' + fieldMap.get(field).getDescribe().getLabel() + '</b> has been removed. Previous value: \''+ oldObj.get(field) +'\'';
                }   
                else{
                    longDescription += '<br> <b>' + fieldMap.get(field).getDescribe().getLabel() + '</b> changed from \''  + oldObj.get(field) + '\' to \''+ obj.get(field) +'\'';
                }
            }
        }

        EQANotification__c notification = new EQANotification__c(
                                                           Record_Id__c = String.valueOf(obj.get('Id')),
                                                           Record_Name__c = String.valueOf(obj.get('Name')),
                                                           Modified_By__c = ( Id )obj.get('LastModifiedById'),
                                                           Modification_Date__c = Datetime.valueOf(obj.get('LastModifiedDate')),
                                                           Description__c = longDescription);

        if (obj.getSObjectType() == Part_Incident_Report__c.sObjectType){
            notification.Object_Name__c = 'Part Incident Report';
        }
        else if (obj.getSObjectType() == Sorting_Report__c.sObjectType){
            notification.Object_Name__c = 'Sorting Report';     
        }
        else if (obj.getSObjectType() == Monetary_Claim__c.sObjectType){
            notification.Object_Name__c = 'Monetary Claim';
        }

        return notification;
    }

    private static Map<String, Schema.SObjectField> getFieldMap(SObject obj){
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();

        if (obj.getSObjectType() == Part_Incident_Report__c.sObjectType){
            fieldMap = Schema.SObjectType.Part_Incident_Report__c.fields.getMap();
        }
        else if (obj.getSObjectType() == Sorting_Report__c.sObjectType){
            fieldMap = Schema.SObjectType.Sorting_Report__c.fields.getMap();
        }
        else if (obj.getSObjectType() == Monetary_Claim__c.sObjectType){
            fieldMap = Schema.SObjectType.Monetary_Claim__c.fields.getMap();
        }
        return fieldMap;
    }

    private static SObject getObjWithLookupInfo(SObject obj){
        if (obj.getSObjectType() == Part_Incident_Report__c.sObjectType){
            return pirsWithLookupInfo.get((Id)obj.get('Id'));
        }
        else if (obj.getSObjectType() == Sorting_Report__c.sObjectType){
            return srsWithLookupInfo.get((Id)obj.get('Id'));
        }
        else if (obj.getSObjectType() == Monetary_Claim__c.sObjectType){
            return mcsWithLookupInfo.get((Id)obj.get('Id'));
        }


        //Exception situation - would not ever reproduce
        return null;
    }

    private static void getCustomSettings(){
        notificationSettings = Notification_Settings__c.getOrgDefaults();
        if ((notificationSettings == null) || (notificationSettings.id == null)) {
            notificationSettings = new Notification_Settings__c();
            notificationSettings.Track_All_Fields__c = true;
            insert notificationSettings;
            notificationSettings = Notification_Settings__c.getOrgDefaults();
        }
    }

    private static Set<String> setOfChangedFields(SObject newObject, SObject oldObject) {
        Set<String> result = new Set<String> ();
        for (String field : trackedFields) {
            if (newObject.get(field) != oldObject.get(field)) {
                result.add(field);
            }
        }
        return result;
    }

    private static Boolean isSetsIntersection(Set<String> trackedFieldsLocal, Set<String> changedFields) {
        changedFields.retainAll(trackedFieldsLocal);
        return changedFields.size() > 0;
    }



    private static void getTrackedFieldsSetForPIR(){
        if (notificationSettings.Track_All_Fields__c){
            trackedFields = Schema.SObjectType.Part_Incident_Report__c.fields.getMap().keySet();
        }
        else{
            try {
                for (Schema.FieldSetMember fieldMember : SObjectType.Part_Incident_Report__c.FieldSets.Fields_Tracked_Per_Update.getFields()) {
                    trackedFields.add(fieldMember.getFieldPath().toLowerCase());
                }
            }
            catch(Exception e) {
                System.debug('There are some issues with Fields_Tracked_Per_Update fieldset : ' + e.getMessage());
            }
        }
    }

    private static void getPIRsWithLookUpInfoMap(Map<Id, Part_Incident_Report__c> newMap){
        pirsWithLookupInfo = new Map<Id, Part_Incident_Report__c>([SELECT LastModifiedBy.Name, Owner.Name, Part__r.Name FROM Part_Incident_Report__c WHERE Id IN: newMap.keySet()]);
    }

    private static void getTrackedFieldsSetForSR(){
        if (notificationSettings.Track_All_Fields__c){
            trackedFields = Schema.SObjectType.Sorting_Report__c.fields.getMap().keySet();
        }
        else{
            try {
                for (Schema.FieldSetMember fieldMember : SObjectType.Sorting_Report__c.FieldSets.Fields_Tracked_Per_Update.getFields()) {
                    trackedFields.add(fieldMember.getFieldPath().toLowerCase());
                }
            }
            catch(Exception e) {
                System.debug('There are some issues with Fields_Tracked_Per_Update fieldset : ' + e.getMessage());
            }
        }
    }

    private static void getSRsWithLookUpInfoMap(Map<Id, Sorting_Report__c> newMap){
        srsWithLookupInfo = new Map<Id, Sorting_Report__c>([SELECT LastModifiedBy.Name, Owner.Name, Part__r.Name FROM Sorting_Report__c WHERE Id IN: newMap.keySet()]);
    }

    private static void getTrackedFieldsSetForMC(){
        if (notificationSettings.Track_All_Fields__c){
            trackedFields = Schema.SObjectType.Monetary_Claim__c.fields.getMap().keySet();
        }
        else{
            try {
                for (Schema.FieldSetMember fieldMember : SObjectType.Monetary_Claim__c.FieldSets.Fields_Tracked_Per_Update.getFields()) {
                    trackedFields.add(fieldMember.getFieldPath().toLowerCase());
                }
            }
            catch(Exception e) {
                System.debug('There are some issues with Fields_Tracked_Per_Update fieldset : ' + e.getMessage());
            }
        }
    }

    private static void getMCsWithLookUpInfoMap(Map<Id, Monetary_Claim__c> newMap){
        mcsWithLookupInfo = new Map<Id, Monetary_Claim__c>([SELECT LastModifiedBy.Name, Owner.Name, Sorting_Report__r.Name, Part_Incident_Report__r.Name FROM Monetary_Claim__c WHERE Id IN: newMap.keySet()]);
    }

}