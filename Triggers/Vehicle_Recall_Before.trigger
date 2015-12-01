trigger Vehicle_Recall_Before on Vehicle_Recall__c (before insert, before update) {
	List<Vehicle_Recall__c> recalls = new List<Vehicle_Recall__c>();
	Set<String> vins = new Set<String>();
	List<Vehicle__c> vehicles = null;
	Map<String,Id> mapVINs = new Map<String,Id>();
	List<String> dealerCodes = new List<String>();
	Map<String, Master_Recall_Campaign__c> vrmsToInsert = new Map<String, Master_Recall_Campaign__c>();

	Set<String> recallIds = new Set<String>();
	Map<String,Vehicle_Recall__c> recallIdRecalls = new Map<String,Vehicle_Recall__c>();
	Set<String> existingMasterRecallIds = new Set<String>();
	Vehicle_Recall__c recall;
	
	// Create Set and Map of recall identifiers
	for (Vehicle_Recall__c vr: Trigger.new) {
		recallIds.add(vr.Recall_Identifier__c);
		if (!recallIdRecalls.containsKey(vr.Recall_Identifier__c)) {
			recallIdRecalls.put(vr.Recall_Identifier__c, vr);
		}
	}
	
	// Get Master Recall Campaigns matching the ones passed in.  This will be used to find Recall Identifiers
	// without Master Recall Campaigns so they can be created.
	List<Master_Recall_Campaign__c> existingMasters = [select Id, Vehicle_Recall_Business_Id__c
	                                                   from Master_Recall_Campaign__c
	                                                   where Vehicle_Recall_Business_Id__c in :recallIds];

	// Create a set of the Recall Ids that already exist
	for (Master_Recall_Campaign__c mrc: existingMasters) {
		existingMasterRecallIds.add(mrc.Vehicle_Recall_Business_Id__c);
	}

	// Find Recall Ids passed in not in the list that already exist and create Master Recall Campaigns for them
	for (String recallId: recallIds) {
		if (!existingMasterRecallIds.contains(recallId)) {
			recall = recallIdRecalls.get(recallId);

			// Construct Master_Recall_Campaign__c records
	       	Master_Recall_Campaign__c vrm = new Master_Recall_Campaign__c();       		
			vrm.Vehicle_Recall_Business_ID__c = recall.Recall_Identifier__c;
			vrm.Source_Create_Date__c = recall.Source_Create_Date__c; 
			vrm.Source_Update_Date__c = recall.Source_Update_Date__c;
			vrm.Date_Mailed__c = recall.Date_Mailed__c;
			vrm.Claim_Indicator__c = recall.Claim_Indicator__c;
	        vrm.Dealer_Submitted_Claim_Code__c = recall.Dealer_Submitted_Claim_Code__c;
			vrm.Distributor_Code__c = recall.Distributor_Code__c;
			vrm.Recall_Primary_Description__c = recall.Recall_Primary_Description__c;
			vrm.Recall_Secondary_Description__c = recall.Recall_Secondary_Description__c;
			vrm.Effective_Date__c = recall.Effective_Date__c;
			vrm.Recall_Type_Code__c = recall.Recall_Type_Code__c;
			vrm.Local_Vendor_Code__c = recall.Local_Vendor_Code__c;
			vrm.Extended_Warranty_Indicator__c = recall.Extended_Warranty_Indicator__c; 
			vrm.Special_Claim_Requirement_Validation_Ind__c = recall.Special_Claim_Requirement_Validation_Ind__c;
			vrm.Component_Code__c = recall.Component_Code__c;
			vrm.Recall_Status__c = recall.Recall_Status__c; 
			vrm.Recall_Identifier__c = recall.Recall_Identifier__c;
			vrm.Name = recall.Recall_Identifier__c;
			if (recall.Recall_Primary_Description__c != null) {
				String str = recall.Recall_Primary_Description__c.trim();
				str = str.substring(str.trim().lastIndexOf(' ') + 1, str.trim().length());
				if (str.startsWith('NTB') || str.startsWith('ITB'))
				    vrm.TSB_Number__c = str;
			}
			vrm.OwnerId = System.Label.Batch_Record_Owner;
				
			vrmsToInsert.put(recall.Recall_Identifier__c, vrm);
		}
	}

	// Insert the Master Recall Campaigns
    try {
	    if (vrmsToInsert.size() > 0) {
	        insert vrmsToInsert.values();
	    }

    } catch (Exception e) {
		System.Debug('*** There is an Exception *** ' + e.getMessage());
       	System.Debug('*** Error rows *** ' + vrmsToInsert);
    } 

    for (Vehicle_Recall__c vr : Trigger.new) {
		// Stop the insert from happening if the effective date is empty or in the future.
		if (vr.Effective_Date__c == NULL || vr.Effective_Date__c > System.today()) {
    		vr.addError('Row cannot be inserted when effective Date is empty or in the future.');
    		continue;
		} else {
			recalls.add(vr);
		}
		
		// Add to list of VINs
		if (vr.Vehicle_Identification_Number__c != null) {
			vins.add(vr.Vehicle_Identification_Number__c);
		}
    }

	// Get Vehicles from VINs
	vehicles = [select id, vehicle_identification_number__c 
	            from Vehicle__c
	            where Vehicle_Identification_Number__c in :vins];

	// Make a map from VINs to Vehicle__c Ids
	for (Vehicle__c vehicle: vehicles) {
		mapVINs.put(vehicle.Vehicle_Identification_Number__c, vehicle.Id);
	}
	
	for (Vehicle_Recall__c vr : recalls) {
		// Set the Salesforce link to Vehicle__c
   		if (vr.Vehicle_Identification_Number__c != null && vr.Vehicle_Identification_Number__c.length() > 0) {
    		vr.Vehicle__c = mapVINs.get(vr.Vehicle_Identification_Number__c);
   		}

		// Determine and set TSB_Number__c from the Recall_Primary_Description__c
		if (vr.Recall_Primary_Description__c != null) {
			String str = vr.Recall_Primary_Description__c.trim();
			str = str.substring(str.trim().lastIndexOf(' ') + 1, str.trim().length());
			if (str.startsWith('NTB') || str.startsWith('ITB'))
			    vr.TSB_Number__c = str;
		}

		// Construct list of dealer codes
		if (vr.Dealer_Submitted_Claim_Code__c != null) {
			vr.Dealer_Submitted_Claim_Code__c = vr.Dealer_Submitted_Claim_Code__c.Trim();
			if (vr.Dealer_Submitted_Claim_Code__c.length() > 0) {
	          	dealerCodes.add(vr.Dealer_Submitted_Claim_Code__c);
			}
		}

		// Construct and set Vehicle_Recall_Business_Id__c if it's not set
		if (vr.Vehicle_Recall_Business_ID__c == null) {
			vr.Vehicle_Recall_Business_ID__c = vr.Recall_Identifier__c + '_' + vr.Vehicle_Identification_Number__c;
		}
    }

    // Set Dealer__c Salesforce Id 
    Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
    if (dealerMap.size() > 0) {
        for (Vehicle_Recall__c vr : recalls) {
            vr.Dealer__c = dealerMap.get(vr.Dealer_Submitted_Claim_Code__c);
        }
    }

	// Only set Master_Recall_Campaign__c for inserts
	if (Trigger.isInsert) {
	    // Get Master_Recall_Campaign__c rows for all Recall Identifiers 
	    List<Master_Recall_Campaign__c> sfMasters = [Select ID, Recall_Identifier__c 
	                                                 From Master_Recall_Campaign__c 
	                                                 WHERE Recall_Identifier__c in: recallIds];
	
	    Map<String, Master_Recall_Campaign__c> existingVRMs = new Map<String, Master_Recall_Campaign__c>();
	    for (Master_Recall_Campaign__c vrm : sfMasters)
			existingVRMs.put(vrm.Recall_Identifier__c, vrm);
	    
	    // Set Master_Recall_Campaign__c values on Vehicle_Recall__c rows to be inserted
		for (Vehicle_Recall__c vr : recalls) {
	        if (existingVRMs.containsKey(vr.Recall_Identifier__c)) {
	        	vr.Master_Recall_Campaign__c = existingVRMs.get(vr.Recall_Identifier__c).ID;
	        } else {
	        	System.Debug('*** No Master *** ' + vr.Recall_Identifier__c + ' Recall missing ' + vr);
	        }
		}
	}
}