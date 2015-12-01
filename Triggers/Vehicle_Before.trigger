// Vehicle_Before trigger
 // 1/31/2014   -   William Taylor Lines 5-31 to populate Model Line Series


trigger Vehicle_Before on Vehicle__c (before insert, before update) {
	
   // Get and construct Map of ModelYear_ModelCode keys to code entries with option and head unit information.
    List<Code__c> codes = [Select Id, Code__c, Secondary_Code__c, Description__c From Code__c where Type__c = 'Head_Unit' Order By code__c, secondary_code__c Nulls Last];
    List<Code__c> modelHeadUnits = null;
    Map<String, List<Code__c>> headUnitMap = new Map<String,List<Code__c>>();
    Set<String> modelCodes = new Set<String>();
    Set<String> modelYears = new Set<String>();
    static final String SEPARATOR = '_';
    String key;
        
    for (Code__c code: codes) {
    	modelYears.add(code.Code__c.substringBefore(SEPARATOR));
        modelCodes.add(code.Code__c.substringAfter(SEPARATOR));
    	
        modelHeadUnits = headUnitMap.get(code.Code__c);
        if (modelHeadUnits == null) {
            modelHeadUnits = new List<Code__c>();
            headUnitMap.put(code.Code__c, modelHeadUnits);
        }
        modelHeadUnits.add(code);
    }
    
    List<Code__c> modelLineSeriesList = [select Value__c, Description__c from Code__c where Type__c = 'MOD LINE/SERIES'];
    Map<String,String> modelLineSeries = new Map<String,String>();
    for(Code__c modelLine: modelLineSeriesList) {
        modelLineSeries.put(modelLine.Value__c, modelLine.Description__c);
    }
    
    if (Trigger.isInsert) {
        for (Vehicle__c v : Trigger.New) {
            if (v.Model_Line_Series__c == null || v.Model_Line_Series__c == '') {
                if (v.Name != null) {                 //user selects name, use name to change VIN
                    v.Vehicle_Identification_Number__c = v.Name;
                } else {                              //user selects VIN, use VIN to change name
                    v.Name = v.Vehicle_Identification_Number__c;
                }
                if (v.Vehicle_Identification_Number__c != null ) {
                    if (v.Vehicle_Identification_Number__c.length() > 10) {
                        v.Model_Line_Series__c = modelLineSeries.get(v.Vehicle_Identification_Number__c.substring(3,8));
                    }
                }
            }
            
            if(v.Head_Unit__c == null || v.Head_Unit__c == ''){
               if((modelYears != null && modelYears.contains(v.Model_Year__c)) && (modelCodes != null && modelCodes.contains(v.Model_code__c))){
              	
	            key = v.Model_Year__c + SEPARATOR + v.Model_Code__c;
	            modelHeadUnits = headUnitMap.get(key);
	            VehicleTriggerHelper.handleinsertupdatEvent(v, modelHeadUnits);
              }
            }
        }
    } else {
        for (Vehicle__c v : Trigger.New) {
            if (v.Model_Line_Series__c == null || v.Model_Line_Series__c == '') {
                if (v.Vehicle_Identification_Number__c != null) {
                    if (v.Vehicle_Identification_Number__c.length() >= 10) {
                        v.Model_Line_Series__c = modelLineSeries.get(v.Vehicle_Identification_Number__c.substring(3,8));
                    }
                }
            }
            
            if(v.Head_Unit__c == null || v.Head_Unit__c == ''){
            	if((modelYears != null && modelYears.contains(v.Model_Year__c)) && (modelCodes != null && modelCodes.contains(v.Model_code__c))){
	            key = v.Model_Year__c + SEPARATOR + v.Model_Code__c;
	            modelHeadUnits = headUnitMap.get(key);
	            VehicleTriggerHelper.handleinsertupdatEvent(v, modelHeadUnits);
            }
           }            
        }
    
    
    }
    
}
/*
before update) {
Set<ID> nameChanged = new Set<ID>();
for (Vehicle__c v : Trigger.New) {
    if (Trigger.isUpdate) {
        Vehicle__c old = Trigger.oldMap.get(v.ID);
        
        if (!Text_Util.equalsIgnoreCase(old.Name, v.Name) || 
            !Text_Util.equalsIgnoreCase(old.Vehicle_Identification_Number__c, v.Vehicle_Identification_Number__c))
            nameChanged.add(v.Id);
    }
}

if (nameChanged.size() > 0) {
    for (Vehicle__c v : [Select ID, Name, Vehicle_Identification_Number__c,
                            (Select ID, Vehicle_ID__c, Vehicle_Identification_Number__c From Warranties__r), 
                            (Select ID, VIN__c, Vehicle_Id__c From Vehicle_Service_Contracts__r), 
                            (Select ID, External_Vehicle_Identification_Number__c, Vehicle_Identification_Number__c From Vehicle_Retail_Sales__r), 
                            (Select ID, Vehicle_Identification_Number__c, Vehicle__c From Recalls__r), 
                            (Select ID, Vehicle_ID__c, Vehicle_Identification_Number__c From Service_Repairs_History__r), 
                            (Select ID, Vehicle_Name__c, VIN__c From Cases__r), 
                            (Select ID, Vehicle__c, Vehicle_Identification_Number__c From Buybacks__r) 
                        From Vehicle__c Where ID in: nameChanged]) {
        if (v.Warranties__r.size() > 0 ||
                v.Vehicle_Service_Contracts__r.size() > 0 ||
                v.Vehicle_Retail_Sales__r.size() > 0 ||
                v.Recalls__r.size() > 0 ||
                v.Service_Repairs_History__r.size() > 0 ||
                v.Cases__r.size() > 0 ||
                v.Buybacks__r.size() > 0)
            v.addError('You cannot change the VIN if the vehicle is associated with any Buyback, Case, Claim/Repair, Contract, Warranty or Retail Sale records.');
    }
}

for (Vehicle__c v : Trigger.New) {
    if (Trigger.isUpdate) {
        Vehicle__c old = Trigger.oldMap.get(v.ID);
        
        if (!Text_Util.equalsIgnoreCase(old.Name, v.Name)) { //user changes name, use name to change VIN
            v.Vehicle_Identification_Number__c = v.Name;
        } else if (!Text_Util.equalsIgnoreCase(old.Vehicle_Identification_Number__c, v.Vehicle_Identification_Number__c)) { //user changes VIN, use VIN to change name
            if (v.Vehicle_Identification_Number__c != null)
                v.Name = v.Vehicle_Identification_Number__c;
            else
                v.Vehicle_Identification_Number__c = v.Name; //Vehicle_Identification_Number__c field cannot be null unless Name is null.
        }
    } else if (Trigger.isInsert) {
        if (v.Name != null) //user selects name, use name to change VIN
            v.Vehicle_Identification_Number__c = v.Name;
        else //user selects VIN, use VIN to change name
            v.Name = v.Vehicle_Identification_Number__c;
    }
}
*/