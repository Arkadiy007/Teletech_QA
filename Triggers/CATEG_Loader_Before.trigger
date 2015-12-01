/**********************************************************************
Name: Batch_ZCA_CaseCategory_Loader
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CATEG_Loader table data into the Case_Categorization table
for the one-time initial load of ZCA Cases.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 1/31/2012 Created
***********************************************************************/
trigger CATEG_Loader_Before on CATEG_Loader__c (before insert) {
    
    private Map<String,Code__c> concerns = new Map<String,Code__c>();
    private Map<String,Code__c> categories = new Map<String,Code__c>();
    private Map<String,Code__c> subcategories = new Map<String,Code__c>();
    private Map<String,Code__c> symptoms = new Map<String,Code__c>();

    CATEG_Loader__c doneCat;
    Case_Categorization__c caseCat;
    List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
    Map<Integer,CATEG_Loader__c> catMap = new Map<Integer,CATEG_Loader__c>();
    List<CATEG_Loader__c> updateCatList = new List<CATEG_Loader__c>();
    	
    List<String> documentIds = new List<String>();
    List<Case> cases = new List<Case>();
    Map<String,Case> documentIdCaseMap = new Map<String,Case>();
    Case c;

    List<Error_Log__c> errors = new List<Error_Log__c>();
    	    	
    Integer ins = 0;    	
    	
    // Fill maps with codes for Categorization data
    Batch_Util.fillCodeMaps(concerns, categories, subcategories, symptoms);
    	
    // Get List of Document_IDs from CATEG_Loader to lookup cases
    for (CATEG_Loader__c cat: Trigger.new) {
  		documentIds.add(cat.Document_ID__c);
    }
    	
    // Get Case information
    cases = [select Id, DocumentId__c, Legacy_Root_Cause__c, Legacy_Root_Cause_2__c 
             from Case 
             where Case_External_Id__c in :documentIds];
    	
    // Construct a map of Document_Id to Case object
    for (Case ca: cases) {
    	documentIdCaseMap.put(ca.DocumentId__c, ca);
    }
    	
    // Construct Case_Categorizations and set Root Cause codes on Cases
    for (CATEG_Loader__c cat: Trigger.new) {
	   	try {
	   		c = documentIdCaseMap.get(cat.Document_Id__c);
	   		
    		caseCat = Batch_Util.getCaseCategorization(cat, c, concerns, categories, subcategories, symptoms);

			Batch_Util.setRootCauseFlags(cat, c);
    		
    		if (c != null && cat.Concern_Code__c != null) {
    			caseCats.add(caseCat);

				// Save the input CATEG_Loader record to a numbered Map where the key of the Map is the
				// index of the CATEG_Loader in the original input.
				catMap.put(ins,cat);
				ins++;
    		}
        } catch (Exception err) {
        	errors.add(new Error_Log__c(Record_ID__c = cat.Id,
                                        Record_Type__c = 'CATEG_Loader__c', 
                                        Error_Message__c = err.getMessage(), 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'Batch_ZCA_CaseCategory_Loader', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
        }
    }
    	
    // Insert Case_Categorization__c records
    if (!caseCats.isEmpty()) {
    	Database.SaveResult[] results = Database.insert(caseCats, false);

		// If there are any results, handle the errors
    	if (!results.isEmpty()) 
    	{
    		// Loop through results returned
    		for (integer row = 0; row < caseCats.size(); row++)
    		{
    			// If the current row was not sucessful, handle the error.
    			if (!results[row].isSuccess())
    			{
    				// Get the error for this row and add it to a list of Error_Log rows.
    				Database.Error err = results[row].getErrors()[0];
                   	errors.add(new Error_Log__c(Record_ID__c = (catMap.get(row)).Id,
                     			Record_Type__c = 'CATEG_Loader__c', 
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_ZCA_CaseCategory_Loader.CaseCategorizations',
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                                   	
                    doneCat = catMap.get(row);
                    doneCat.Successful__c = 'N';
                    doneCat.Error_Message__c = err.getMessage();
    			} else {
    				// If the current row was successful, set it to successful
    				doneCat = catMap.get(row);
                    doneCat.Successful__c = 'Y';
    			}
    		}
    	}
    }    		
    	
    // Update Cases now that root causes have been set.
	if (!cases.isEmpty()) {
    	Database.SaveResult[] results = Database.update(cases, false);

		// If there are any results, handle the errors
    	if (!results.isEmpty()) 
    	{
    		// Loop through results returned
    		for (integer row = 0; row < cases.size(); row++)
    		{
    			// If the current row was not sucessful, handle the error.
    			if (!results[row].isSuccess())
    			{
    				// Get the error for this row and add it to a list of Error_Log rows.
    				Database.Error err = results[row].getErrors()[0];
                   	errors.add(new Error_Log__c(Record_ID__c = (cases.get(row)).Id,
                          			Record_Type__c = 'Cases', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_ZCA_CaseCategory_Loader.UpdateCases', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                   	Log_Level__c = 1));
    			}
    		}
    	}
    }

    // If any errors were returned, add them to the Error_Log table.
    if (!errors.isEmpty()) {
		// Insert rows
        Database.SaveResult[] results = Database.insert(errors, false);
    }
}