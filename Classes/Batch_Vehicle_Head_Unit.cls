/*********************************************************************
Name: Batch_Vehicle_Head_Unit
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class sets the Head Unit for Vehicles that match
the criteria for a certain head unit model but do not
have that data populated.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 11/05/2013 Created
***********************************************************************/
global class Batch_Vehicle_Head_Unit implements Database.Batchable<sObject> {
    public static final String SEPARATOR = '_';
 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Code__c> codes = [Select Id, Code__c, Secondary_Code__c, Description__c From Code__c where Type__c = 'Head_Unit'];
        Set<String> modelCodes = new Set<String>();
        Set<String> modelYears = new Set<String>();
        Boolean comma = false;
        
        for (Code__c code: codes) {
            modelYears.add(code.Code__c.substringBefore(SEPARATOR));
            modelCodes.add(code.Code__c.substringAfter(SEPARATOR));
        }
    
        String query = 'SELECT Factory_Installed_Options__c, Model_Code__c, Model_Year__c, Id, Head_Unit__c FROM Vehicle__c ' +
                       'where Head_Unit__c = null and model_year__c in (';
        for (String year: modelYears) {
            if (comma == true) {
                query += ', ';
            }
            query += '\'' + year + '\'';
            comma = true;
        }
        query += ') and model_code__c in (';
        
        comma = false;
        for (String code: modelCodes) {
            if (comma == true) {
                query += ', ';
            }
            query += '\'' + code + '\'';
            comma = true;
        }
        query += ') and CreatedDate = last_n_days:' + System.Label.Head_Unit_Batch_Days;
        System.debug('query::'+query);
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Vehicle__c> vehicles) {
        List<Vehicle__c> updateVehicles = new List<Vehicle__c>();
        List<Error_Log__c> errors = new List<Error_Log__c>();
    
        // Get and construct Map of ModelYear_ModelCode keys to code entries with option and head unit information.
        List<Code__c> codes = [Select Id, Code__c, Secondary_Code__c, Description__c From Code__c where Type__c = 'Head_Unit' Order By code__c, secondary_code__c Nulls Last];
        List<Code__c> modelHeadUnits = null;
        Map<String, List<Code__c>> headUnitMap = new Map<String,List<Code__c>>();
        
        for (Code__c code: codes) {
            modelHeadUnits = headUnitMap.get(code.Code__c);
            if (modelHeadUnits == null) {
                modelHeadUnits = new List<Code__c>();
                headUnitMap.put(code.Code__c, modelHeadUnits);
            }
            modelHeadUnits.add(code);
        }
        
        // Go through Vehicles returned in the batch and determine if they have a Head Unit according to the
        // headUnitMap.  If the criteria is met and a head unit is found, set it on the Vehicle object and
        // add the Vehicle to a List to be updated.
        String key;
        Boolean foundMatch = false;
        for (Vehicle__c vehicle: vehicles) {
            key = vehicle.Model_Year__c + SEPARATOR + vehicle.Model_Code__c;
            modelHeadUnits = headUnitMap.get(key);
            if (modelHeadUnits != null) {
                foundMatch = false;
                for (Code__c headUnit: modelHeadUnits) {
                    // Only continue if we have not found a head unit match for this vehicle.
                    if (!foundMatch) {
                        // If secondary code is null, no option is required and the vehicle has the head unit.
                        // If secondary code is not null and its value is found in the vehicle's options,
                        // the vehicle has the head unit.
                        if (headUnit.Secondary_Code__c == null ||
                            (vehicle.Factory_Installed_Options__c != null &&
                             vehicle.Factory_Installed_Options__c.contains(headUnit.Secondary_Code__c))) {
                            vehicle.Head_Unit__c = headUnit.Description__c;
                            updateVehicles.add(vehicle);
                            foundMatch = true;
                        }
                    }
                }
            }
        }

        if (!updateVehicles.isEmpty()) {
            Database.SaveResult[] results = Database.update(updateVehicles, false);

            if (!results.isEmpty()) {
                for (integer x = 0; x < results.size(); x++) {
                    if (!results[x].isSuccess()) {
                        Database.Error err = results[x].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateVehicles[x].Id,
                                    Record_Type__c = 'Vehicle__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_Vehicle_Head_Unit', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        
        if (!errors.isEmpty()) {
            Database.insert(errors, false);
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}