/**********************************************************************
Name: VSC_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Sync Vin__c to Vehicle if Vehicle_Name__c

======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli FIntescu 01/05/2012 Created
***********************************************************************/
trigger VSC_Before on Vehicle_Service_Contract__c (before insert, before update) {
    List<Vehicle_Service_Contract__c> vins = new List<Vehicle_Service_Contract__c>();
    List<Vehicle_Service_Contract__c> vids = new List<Vehicle_Service_Contract__c>();
	Set<ID> idSet = new Set<ID>();
	Set<String> vinSet = new Set<String>();
	
	for (Vehicle_Service_Contract__c vsc : Trigger.New) {
		if (Trigger.isUpdate) {
			Vehicle_Service_Contract__c old = Trigger.oldMap.get(vsc.ID);
			
			if (old.Vehicle_Id__c != vsc.Vehicle_Id__c) { //user changes vehicle, use vehicle to change VIN
            	vids.add(vsc);
            	if (vsc.Vehicle_Id__c != null)
            		idSet.add(vsc.Vehicle_Id__c);
			} else if (old.VIN__c != vsc.VIN__c)  { //user changes VIN, use VIN to change vehicle
	            vins.add(vsc);
	            if (vsc.VIN__c != null)
	            	vinSet.add(vsc.VIN__c);
	        }
		} else if (Trigger.isInsert) {
			if (vsc.Vehicle_Id__c != null) { //user selects vehicle, use vehicle to change VIN
				vids.add(vsc);
            	idSet.add(vsc.Vehicle_Id__c);
			} else if (vsc.VIN__c != null) { //user selects VIN, use VIN to change vehicle
				vins.add(vsc);
	            vinSet.add(vsc.VIN__c);
			}
		}
	}
	
	//populate Vin__c by Vehicle__c.VIN.
	Map<ID, Vehicle__c> mapRelatedVehicles = new Map<ID, Vehicle__c>([Select ID, Name, Vehicle_Identification_Number__c From Vehicle__c WHERE ID in: idSet]);
	for (Vehicle_Service_Contract__c vsc : vids) {
		if (vsc.Vehicle_Id__c == null)
			vsc.VIN__c = null;
		else {
			Vehicle__c v = mapRelatedVehicles.get(vsc.Vehicle_Id__c);
			vsc.VIN__c = v.Vehicle_Identification_Number__c;
		}
	}
	
	//Link Vin__c to Vehicle. Text_Util.linkVehiclesByVIN() also creates new Vehicles - use it with care
	Map<String, Vehicle__c> vehicleMap = Text_Util.linkVehiclesByVIN(vinSet, null);
    for (Vehicle_Service_Contract__c vsc : vins) {
        if (vsc.VIN__c == null || !vehicleMap.containsKey(vsc.VIN__c))
        	vsc.Vehicle_Id__c = null;
        else if (vehicleMap.containsKey(vsc.VIN__c))
            vsc.Vehicle_Id__c = vehicleMap.get(vsc.VIN__c).Id;
	}
}