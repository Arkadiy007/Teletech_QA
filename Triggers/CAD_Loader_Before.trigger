/**********************************************************************
Name: CAD_Loader_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CAD_Loader table data into the Case table
for the one-time initial load of ZCA Cases.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 1/16/2012 Created
***********************************************************************/
trigger CAD_Loader_Before on CAD_Loader__c (before insert) {
	private static final String DEFAULT_DESCRIPTION = 'Legacy ZCA Case';
    
    // Case Record Type Ids
    Id openCaseRecordTypeId;
    Id closedCaseRecordTypeId; 

	// Handle each batch of CAD_Loader rows returned and insert corresponding records into Case
    CAD_Loader__c cad;
    CAD_Loader__c doneCad;
    Map<Integer,CAD_Loader__c> cadMap = new Map<Integer,CAD_Loader__c>();
    	
    List<Case> cases = new List<Case>();
    Case c;
    	
    List<Account> accounts = new List<Account>();
    Account acct;

    List<Vehicle__c> vehicles = new List<Vehicle__c>();
    Vehicle__c vehicle;
    	
    List<Error_Log__c> errors = new List<Error_Log__c>();
    	    	
    Integer ins = 0;
    	
    List<Case> casesInserted = new List<Case>();

    Map<Integer,Case> vehicleMap = new Map<Integer,Case>();
    List<Case> updateVehicleCases = new List<Case>();

    RecordType rt = [select Id from RecordType where SobjectType = 'Case' and Name = 'CA'];
    openCaseRecordTypeId = rt.Id;

	rt = [select Id from RecordType where SobjectType = 'Case' and Name = 'CA Closed Case'];
	closedCaseRecordTypeId = rt.Id;

    // Construct Cases and Accounts from input List
    for (Cad_Loader__c cadLoader: Trigger.new) {
    	try {
	   		c = Batch_Util.getCase(cadLoader, openCaseRecordTypeId, closedCaseRecordTypeId);
	   		cases.add(c);
	   		
	   		acct = Batch_Util.getAccount(cadLoader);
	   		accounts.add(acct);
	   		
			vehicle = Batch_Util.getVehicle(cadLoader);
			vehicles.add(vehicle);
	
    		// Save the input CAD_Loader record to a numbered Map where the key of the Map is the
    		// index of the CAD_Loader in the original input.
    		cadMap.put(ins,cadLoader);
    		ins++;
           } catch (Exception err) {
           	errors.add(new Error_Log__c(Record_ID__c = cad.Id,
                                   Record_Type__c = 'CAD_Loader__c', 
                                   Error_Message__c = err.getMessage(), 
                                   TimeStamp__c = System.now(), 
                                   Operation_Name__c = 'Batch_ZCA_Case_Loader', 
                                   Source__c='Salesforce', 
                                   Log_Type__c = 'Error', 
                                   Log_Level__c = 1));
           }
   	}
   	
   	// Create new Vehicle__c objects for any Vehicles in the list that do not already exist.  These will
   	// then be linked automatically to the Cases when they are inserted.
		Text_Util.linkVehiclesByVIN(vehicles, errors);
   	
   	// If any Account rows are in the list, insert them and handle any errors.
	if (!accounts.isEmpty()) {   
   		// Insert rows
   		Database.SaveResult[] acctResults = Database.insert(accounts, false);
			// If there are any results, handle the errors
   		if (!acctResults.isEmpty()) 
   		{
   			// Loop through results returned
   			for (integer row = 0; row < accounts.size(); row++)
   			{
   				// If the current row was not sucessful, handle the error.
   				if (!acctResults[row].isSuccess())
   				{
   					// Get the error for this row and add it to a list of Error_Log rows.
   					Database.Error err = acctResults[row].getErrors()[0];
                   	errors.add(new Error_Log__c(Record_ID__c = (cadMap.get(row)).Id,
                        			Record_Type__c = 'CAD_Loader__c', 
                                   Error_Message__c = err.getMessage(), 
                                   TimeStamp__c = System.now(), 
                                   Operation_Name__c = 'Batch_ZCA_Case_Loader.Accounts', 
                                   Source__c='Salesforce', 
                                   Log_Type__c = 'Error', 
                                  	Log_Level__c = 1));
   				} else {
   					cases[row].AccountId = acctResults[row].getID();
   				}
   			}
   		}
   	}

   	// Insert cases
   	if (!cases.isEmpty()) {
   		Database.SaveResult[] caseResults = Database.insert(cases, false);
		// If there are any results, handle the errors
   		if (!caseResults.isEmpty()) 
   		{
   			// Loop through results returned
   			for (integer row = 0; row < cases.size(); row++)
   			{
				// If the current row was not sucessful, handle the error.
				if (!caseResults[row].isSuccess())
   				{
   					// Get the error for this row and add it to a list of Error_Log rows.
   					Database.Error err = caseResults[row].getErrors()[0];
                   	errors.add(new Error_Log__c(Record_ID__c = (cadMap.get(row)).Id,
                          			Record_Type__c = 'CAD_Loader__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_ZCA_Case_Loader.Cases',
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                   	Log_Level__c = 1));
                                   	
                    doneCad = cadMap.get(row);
                    doneCad.Successful__c = 'N';
                    doneCad.Error_Message__c = err.getMessage();
   				} else {
   					// If the current row was successful, set it to successful
   					doneCad = cadMap.get(row);
                    doneCad.Successful__c = 'Y';
   				}
   			}
   		}
   	}
    		    	        
    // If any errors were returned, add them to the Error_Log table.
    if (!errors.isEmpty()) {
		// Insert rows
        Database.SaveResult[] dbResults = Database.insert(errors, false);
    }
}