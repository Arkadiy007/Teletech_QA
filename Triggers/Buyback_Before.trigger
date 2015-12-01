/**********************************************************************
Name: Buyback_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Sync Vin__c to Vehicle if Vehicle_Name__c

======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli FIntescu 01/05/2012 Created
***********************************************************************/
trigger Buyback_Before on Buyback__c (before insert, before update) {
	
	if(Trigger_Switch__c.getInstance(Label.Trigger_BuybackBefore) != null && Trigger_Switch__c.getInstance(Label.Trigger_BuybackBefore).Disabled__c){
    	return;
    }
    // ********** Buybacks cannot be added to a closed case
    if (Trigger.isInsert && system.label.TurnOffValidation != 'Yes') {
	    Set<ID> caseIds = new Set<ID>();
		for (Buyback__c t: Trigger.new) {
			caseIds.add(t.Case__c);
		}
		
		List<Case> cases = [select Id from Case where Id in :caseIds and IsClosed = true];
		Map<ID, Case> mapCases = new Map<ID, Case>(cases);
		for (Buyback__c t: Trigger.new) {
			if (mapCases.containsKey(t.Case__c))
				t.addError('Buybacks cannot be added to a closed case.');
		}
    }
	
	// ********** Syn vin and vehicle id
    List<Buyback__c> vins = new List<Buyback__c>();
    List<Buyback__c> vids = new List<Buyback__c>();
	Set<ID> idSet = new Set<ID>();
	Set<String> vinSet = new Set<String>();
	
	for (Buyback__c b : Trigger.New) {
		if (Trigger.isUpdate) {
			Buyback__c old = Trigger.oldMap.get(b.ID);
			
			if (old.Vehicle__c != b.Vehicle__c) { //user changes vehicle, use vehicle to change VIN
            	vids.add(b);
            	if (b.Vehicle__c != null)
            		idSet.add(b.Vehicle__c);
			} else if (old.Vehicle_Identification_Number__c != b.Vehicle_Identification_Number__c)  { //user changes VIN, use VIN to change vehicle
	            vins.add(b);
	            if (b.Vehicle_Identification_Number__c != null)
	            	vinSet.add(b.Vehicle_Identification_Number__c);
	        }
		} else if (Trigger.isInsert) {
			if (b.Vehicle__c != null) { //user selects vehicle, use vehicle to change VIN
				vids.add(b);
            	idSet.add(b.Vehicle__c);
			} else if (b.Vehicle_Identification_Number__c != null) { //user selects VIN, use VIN to change vehicle
				vins.add(b);
	            vinSet.add(b.Vehicle_Identification_Number__c);
			}
		}
	}
	
	//populate Vin__c by Vehicle__c.VIN.
	Map<ID, Vehicle__c> mapRelatedVehicles = new Map<ID, Vehicle__c>([Select ID, Name, Vehicle_Identification_Number__c From Vehicle__c WHERE ID in: idSet]);
	for (Buyback__c b : vids) {
		if (b.Vehicle__c == null)
			b.Vehicle_Identification_Number__c = null;
		else {
			Vehicle__c v = mapRelatedVehicles.get(b.Vehicle__c);
			b.Vehicle_Identification_Number__c = v.Vehicle_Identification_Number__c;
		}
	}
	
	//Link Vin__c to Vehicle. Text_Util.linkVehiclesByVIN() also creates new Vehicles - use it with care
	Map<String, Vehicle__c> vehicleMap = Text_Util.linkVehiclesByVIN(vinSet, null);
    for (Buyback__c b : vins) {
        if (b.Vehicle_Identification_Number__c == null || !vehicleMap.containsKey(b.Vehicle_Identification_Number__c))
        	b.Vehicle__c = null;
        else
            b.Vehicle__c = vehicleMap.get(b.Vehicle_Identification_Number__c).Id;
	}
}