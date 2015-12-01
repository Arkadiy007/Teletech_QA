public class VehicleTriggerHelper{


    public static void handleinsertupdatEvent(Vehicle__c vehicle, List<Code__c> modelHeadUnits){
        
        if(modelHeadUnits != null && !modelHeadUnits.isEmpty()){
         for (Code__c headUnit: modelHeadUnits) {
                            
                // If secondary code is null, no option is required and the vehicle has the head unit.
                // If secondary code is not null and its value is found in the vehicle's options,
                // the vehicle has the head unit.
                if (headUnit.Secondary_Code__c == null ||
                    (vehicle.Factory_Installed_Options__c != null &&
                     vehicle.Factory_Installed_Options__c.contains(headUnit.Secondary_Code__c))) {
                      vehicle.Head_Unit__c = headUnit.Description__c;  
                      break;                  
               }
           }
    	}
    }

}