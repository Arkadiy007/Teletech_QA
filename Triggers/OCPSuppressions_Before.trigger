/**********************************************************************
  Name: OCPSuppressions_Before_Tests
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose:
  This trigger creates new Case, whenever new record created for OCP_Suppression__c object

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Anna Koseikina 02/23/2015 Created
  ***********************************************************************/
trigger OCPSuppressions_Before on OCP_Suppression__c (before insert)  { 
	List <RecordType> leaseLoyaltyRecordType = [Select Id, Name from RecordType WHERE Name = :'Lease Loyalty'];
	List<String> vins = new List<String>();
	List<String> leaseTypes = new List<String>();
	for(OCP_Suppression__c suppression : trigger.new){
		if(suppression.LeaseType__c != null && suppression.LeaseType__c != ''){
			leaseTypes.add(suppression.LeaseType__c);
		}
		if(suppression.VIN__c != null && suppression.VIN__c != ''){
			vins.add(suppression.VIN__c);
		}
	}
	OCP_Suppression_Time_Period__c ocpSuppressionSettings = getOcpSuppressionSettings();
	String query = 'SELECT ID, VIN__c, Segment_Mailed__c FROM Case WHERE Status != \'Closed\' AND RecordTypeId IN :leaseLoyaltyRecordType AND VIN__c IN :vins AND Segment_Mailed__c IN :leaseTypes AND LastModifiedDate > ' + OcpSuppressionSettings.Time_Period_for_Cases__c;
	//List<Case> leaseLoyaltyOpenCases = [SELECT ID, VIN__c, Segment_Mailed__c FROM Case WHERE Status != 'Closed' AND RecordTypeId IN :leaseLoyaltyRecordType AND VIN__c IN :vins AND Segment_Mailed__c IN :leaseTypes];
	List<Case> leaseLoyaltyOpenCases = Database.query(query);
	System.debug('test');
	Map<String, List<Case>> segmentMailedVin = new Map<String, List<Case>>();
	for(Case caseItem : leaseLoyaltyOpenCases){
		if(caseItem.Segment_Mailed__c != null && caseItem.Segment_Mailed__c != '' && caseItem.VIN__c != null && caseItem.VIN__c != ''){
			if(!segmentMailedVin.keySet().contains(caseItem.Segment_Mailed__c + ' ' + caseItem.VIN__c)){
				List<Case> newList = new List<Case>();
				newList.add(caseItem);
				segmentMailedVin.put(caseItem.Segment_Mailed__c + ' ' + caseItem.VIN__c, newList);
			}else{
				segmentMailedVin.get(caseItem.Segment_Mailed__c + ' ' + caseItem.VIN__c).add(caseItem);
			}
		}
	}
	Map<Integer, OCP_Suppression__c> allSuppressions = new Map<Integer, OCP_Suppression__c>();
	Integer counter = 0;
	Map<ID,List<Integer>> caseSuppression = new Map<ID,List<Integer>>();
	//Integer counterCases = 0;
	List<Case> casesToUpdate = new List<Case>();
	Set<ID> checkDuplic = new Set<ID>();
	for(OCP_Suppression__c suppression : trigger.new){
		if(suppression.LeaseType__c != null && suppression.LeaseType__c != '' && suppression.VIN__c != null && suppression.VIN__c != ''){
			if(segmentMailedVin.get(suppression.LeaseType__c + ' ' + suppression.VIN__c) != null && segmentMailedVin.get(suppression.LeaseType__c + ' ' + suppression.VIN__c).size() > 0){
				for(Case caseItem : segmentMailedVin.get(suppression.LeaseType__c + ' ' + suppression.VIN__c)){
					if(caseItem != null){// && !checkDuplic.contains(caseItem.ID)){
						if(suppression.SuppressionType__c == 'Bankrupt' || 
								suppression.SuppressionType__c == 'Delinquent' || 
								suppression.SuppressionType__c == 'Repo' ||
								suppression.SuppressionType__c == 'Terminated'){
							caseItem.Status = 'Closed';
							caseItem.Closed_by_Suppression__c = true;
							if(!checkDuplic.contains(caseItem.ID)){
								casesToUpdate.add(caseItem);
								checkDuplic.add(caseItem.ID);
							}
							
							if(caseSuppression.get(caseItem.ID) == null){
								List<Integer> newList = new List<Integer>();
								newList.add(counter);
								caseSuppression.put(caseItem.ID, newList);
							}else{					
								caseSuppression.get(caseItem.ID).add(counter);
							}
							//caseSuppression.put(counterCases, counter);
							//counterCases++;
						}else if(suppression.SuppressionType__c == 'DoNotContact'){
							caseItem.Do_Not_Contact__c = true;
							if(!checkDuplic.contains(caseItem.ID)){
								casesToUpdate.add(caseItem);
								checkDuplic.add(caseItem.ID);
							}
							
							if(caseSuppression.get(caseItem.ID) == null){
								List<Integer> newList = new List<Integer>();
								newList.add(counter);
								caseSuppression.put(caseItem.ID, newList);
							}else{
								caseSuppression.get(caseItem.ID).add(counter);
							}
							//caseSuppression.put(counterCases, counter);
							//counterCases++;
						}else if(suppression.SuppressionType__c == 'DoNotCall' || suppression.SuppressionType__c == 'FederalDoNotCall'){
							caseItem.Home_Phone_Do_Not_Call__c = true;
							caseItem.Mobile_Phone_Do_Not_Call__c = true;
							caseItem.Work_Phone_Do_Not_Call__c = true;
							if(!checkDuplic.contains(caseItem.ID)){
								casesToUpdate.add(caseItem);
								checkDuplic.add(caseItem.ID);
							}
							if(caseSuppression.get(caseItem.ID) == null){
								List<Integer> newList = new List<Integer>();
								newList.add(counter);
								caseSuppression.put(caseItem.ID, newList);
							}else{
								caseSuppression.get(caseItem.ID).add(counter);
							}
							//caseSuppression.put(counterCases, counter);
							//counterCases++;
						}else{
							suppression.Successful__c = false;
							suppression.Error_Description__c = 'Suppression type is invalid';
						}
			
					/*}else if(caseItem != null && checkDuplic.contains(caseItem.ID)){
						suppression.Successful__c = false;
						suppression.Error_Description__c = 'Case is already in update list';*/
					}else {
						suppression.Successful__c = false;
						suppression.Error_Description__c = 'No such Case found';	
					} 
				}
			}else{
				suppression.Successful__c = false;
				suppression.Error_Description__c = 'No Cases are found';
				suppression.Case_ID__c = '';
			}
		}else{
			suppression.Successful__c = false;
			suppression.Error_Description__c = 'Lease Type or VIN is empty, search for Cases will be non-selective';
		}
		suppression.Case_ID__c = '';
		allSuppressions.put(counter, suppression);
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
					System.debug('****caseSuppression.get(row) ' + caseSuppression.get(dbResults[row].getId()) + ' dbResults[row].getId() ' + dbResults[row].getId());
							
					if(caseSuppression.get(dbResults[row].getId()).size() > 0){
						for(Integer element : caseSuppression.get(dbResults[row].getId())){
							allSuppressions.get(element).Successful__c = false;
							allSuppressions.get(element).Error_Description__c = err.getMessage();
						}
					}
								
				}else{		
				System.debug('****caseSuppression.get(row) ' + caseSuppression.get(dbResults[row].getId()) + ' dbResults[row].getId() ' + dbResults[row].getId());	
					if(caseSuppression.get(dbResults[row].getId()).size() > 0){
						for(Integer element : caseSuppression.get(dbResults[row].getId())){		
							allSuppressions.get(element).Successful__c = true;
							allSuppressions.get(element).Error_Description__c = '';
							allSuppressions.get(element).Case_ID__c = allSuppressions.get(element).Case_ID__c + ' ' + dbResults[row].getId() + ', ';
						}
					}
				}
			}
		}
	}

	private static OCP_Suppression_Time_Period__c getOcpSuppressionSettings(){
		OCP_Suppression_Time_Period__c OcpSuppressionSetting = OCP_Suppression_Time_Period__c.getOrgDefaults();
		if (OcpSuppressionSetting.Time_Period_for_Cases__c == null){
			OcpSuppressionSetting.Time_Period_for_Cases__c = 'LAST_N_QUARTERS:2';
			upsert OcpSuppressionSetting;
			OcpSuppressionSetting = OCP_Suppression_Time_Period__c.getOrgDefaults();
		}
		return OcpSuppressionSetting;
	}
}