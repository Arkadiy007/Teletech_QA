/**********************************************************************
  Name:OnetimeTreadMigrationCode_Before
  Copyright ? notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger updates Case Categories, whenever new record created for OnetimeTreadMigration_Code__c object
  ======================================================
  History:
 
  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina 02/24/2015 Created
 ***********************************************************************/
trigger OnetimeTreadMigrationFlags_Before on OnetimeTreadMigration_Flags__c (before insert)  { 
	List<String> caseIds = new List<String>();
	//get all case Ids
	for(OnetimeTreadMigration_Flags__c onetimeMigration : trigger.new){
		caseIds.add(onetimeMigration.Salesforce_Case_Id__c);
	}
	//map cases and its ids
	Map<String, Case> mapCases = new Map<String, Case>();
	for(Case caseItem : [SELECT ID FROM Case WHERE ID IN :caseIds]){
		if(mapCases.get(String.valueOf(caseItem.Id).substring(0, 15)) == null){
			mapCases.put(String.valueOf(caseItem.Id).substring(0, 15), caseItem);
		}
	}
	//map for migration codes
	Map<Integer, OnetimeTreadMigration_Flags__c> migrationCodes= new Map<Integer, OnetimeTreadMigration_Flags__c>();
	Integer counter = 0;
	//map cases and migration codes
	Map<Integer, Integer> casesCodes= new Map<Integer, Integer>();
	Integer counterCasesCodes = 0;
	//list of cases to update
	List<Case> casesToUpdate = new List<Case>();
	Set<ID> checkDuplic = new Set<ID>();
	for(OnetimeTreadMigration_Flags__c onetimeMigration : trigger.new){
		Case ca = mapCases.get(onetimeMigration.Salesforce_Case_Id__c);
		//if case is found set indicators and effective dates
		if(ca != null && !checkDuplic.contains(ca.ID)){
			onetimeMigration.Salesforce_Case_Id__c = ca.id;
			// fire indicator
			if(onetimeMigration.Fire_Flag__c.equals('Y') || onetimeMigration.Fire_Flag__c.equals('y')){
				ca.Fire_Indicator__c = true;
				ca.Fire_Date__c = onetimeMigration.Fire_Date__c;
			}else{
				ca.Fire_Indicator__c = false;
				ca.Fire_Date__c = null;
			}

			// death/injury indicator
			if(onetimeMigration.Death_Injury_Flag__c.equals('Y') || onetimeMigration.Death_Injury_Flag__c.equals('y')){
				ca.Injury_Indicator__c = true;
				ca.Injury_Date__c = onetimeMigration.Death_Injury_Date__c;
			}else{
				ca.Injury_Indicator__c = false;
				ca.Injury_Date__c = null;
			}

			//goodwill offered indicator
			if(onetimeMigration.Goodwill_Flag__c.equals('Y') || onetimeMigration.Goodwill_Flag__c.equals('y')){
				ca.Goodwill_Offered__c = true;
				ca.Goodwill_Offered_Date__c = onetimeMigration.Goodwill_Date__c;
			}else{
				ca.Goodwill_Offered__c = false;
				ca.Goodwill_Offered_Date__c = null;
			}

			// property damage indicator
			if(onetimeMigration.Property_Damage_Flag__c.equals('Y') || onetimeMigration.Property_Damage_Flag__c.equals('y')){
				ca.Property_Damage_Indicator__c = true;
				ca.Property_Damage_Date__c = onetimeMigration.Property_Damage_Date__c;
			}else{
				ca.Property_Damage_Indicator__c = false;
				ca.Property_Damage_Date__c = null;
			}

			//rollover indicator
			if(onetimeMigration.Rollover_Flag__c.equals('Y') || onetimeMigration.Rollover_Flag__c.equals('y')){
				ca.Rollover_Indicator__c = true;
				ca.Rollover_Date__c = onetimeMigration.Rollover_Date__c;
			}else{
				ca.Rollover_Indicator__c = false;
				ca.Rollover_Date__c = null;
			}

			//sent to legal indicator
			if(onetimeMigration.Sent_to_Legal_Flag__c.equals('Y') || onetimeMigration.Sent_to_Legal_Flag__c.equals('y')){
				ca.Sent_to_Legal_Indicator__c = true;
				ca.Sent_to_Legal_Date__c = onetimeMigration.Sent_to_Legal_Date__c;
			}else{
				ca.Sent_to_Legal_Indicator__c = false;
				ca.Sent_to_Legal_Date__c = null;
			}
			//add to maps			
			checkDuplic.add(ca.ID);
			casesToUpdate.add(ca);
			casesCodes.put(counterCasesCodes, counter);
			counterCasesCodes++;	
		}else if(ca != null && checkDuplic.contains(ca.ID)){
			onetimeMigration.Successful__c = false;
			onetimeMigration.Error_Description__c = 'Case is already in update list';
		}else if(ca == null){
		//if case not found
			onetimeMigration.Successful__c = false;
			onetimeMigration.Error_Description__c = 'Case not found';
		}
		migrationCodes.put(counter, onetimeMigration);
		counter++;
	}
	// Update  Cases
	if (!casesToUpdate.isEmpty()) {
		// Insert rows
		Database.SaveResult[] dbResults = Database.update(casesToUpdate, false);
		// If there are any results, handle the errors
		if (!dbResults.isEmpty())
		{
			// Loop through results returned
			for (integer row = 0; row <casesToUpdate.size(); row++)
			{
				// If the current row was not sucessful, handle the error.
				if (!dbResults[row].isSuccess())
				{
					// Get the error for this row and populate corresponding fields
					Database.Error err = dbResults[row].getErrors() [0];
					migrationCodes.get(casesCodes.get(row)).Successful__c = false;
					migrationCodes.get(casesCodes.get(row)).Error_Description__c = err.getMessage();			
				}else{					
					migrationCodes.get(casesCodes.get(row)).Successful__c = true;
					migrationCodes.get(casesCodes.get(row)).Error_Description__c = '';
				}
			}
		}
	}
}