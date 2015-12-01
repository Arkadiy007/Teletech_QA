/**********************************************************************
Name: CAT_Loader_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CAT_Loader table data into the CaseComment table
for the one-time initial load of ZCA Cases.
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 2/17/2012 Created
***********************************************************************/
trigger CAT_Loader_Before on CAT_Loader__c (before insert) {
       
    CAT_Loader__c doneCat;
    CaseComment comment;
    List<CaseComment> comments = new List<CaseComment>();
    Map<Integer,CAT_Loader__c> catMap = new Map<Integer,CAT_Loader__c>();
    List<CAT_Loader__c> updateCatList = new List<CAT_Loader__c>();
    	
    List<String> documentIds = new List<String>();
    List<Case> cases = new List<Case>();
    Map<String,Case> documentIdCaseMap = new Map<String,Case>();
    Case c;

    List<Error_Log__c> errors = new List<Error_Log__c>();
    	    	
    Integer ins = 0;    	
    	    	
    // Get List of Document_IDs from CAT_Loader to lookup cases
    for (CAT_Loader__c cat: Trigger.new) {
    	if (cat.Document_ID_Text__c != null)
    		documentIds.add(cat.Document_ID_Text__c);
    }

    // Get Case information
    cases = [select Id, DocumentId__c 
             from Case 
             where Case_External_Id__c in :documentIds];	

    // Construct a map of Document_Id to Case object
    for (Case ca: cases) {
    	documentIdCaseMap.put(ca.DocumentId__c, ca);
    }
    	
    // Construct CaseComments
    for (CAT_Loader__c cat: Trigger.new) {
    	try {
	   		c = documentIdCaseMap.get(cat.Document_Id_Text__c);
	   		if (c != null) {
	    		comment = new CaseComment();
	    		comment.CommentBody = cat.Comment_Text__c;
	    		comment.ParentId = c.Id;
	    		if (cat.comment_type__c == 'Dealer Instruction') {
	    			comment.IsPublished = true;
	    		} else {
	    			comment.IsPublished = false;
	    		}
	    		comments.add(comment);
	    		catMap.put(ins,cat);
	    		ins++;
	   		} else {
	   			System.debug('null case ' + cat.Document_id_Text__c);
	   		}
        } catch (Exception err) {
        	errors.add(new Error_Log__c(Record_ID__c = cat.Id,
                                        Record_Type__c = 'CAT_Loader__c', 
                                        Error_Message__c = err.getMessage().substring(0,255), 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'CAT_Loader_Before', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
        }
    }

    // Insert CaseComment records
    if (!comments.isEmpty()) {
    	Database.SaveResult[] results = Database.insert(comments, false);

		// If there are any results, handle the errors
    	if (!results.isEmpty()) 
    	{
    		// Loop through results returned
    		for (integer row = 0; row < comments.size(); row++)
    		{
    			// If the current row was not sucessful, handle the error.
    			if (!results[row].isSuccess())
    			{
    				// Get the error for this row and add it to a list of Error_Log rows.
    				Database.Error err = results[row].getErrors()[0];
                   	errors.add(new Error_Log__c(Record_ID__c = (catMap.get(row)).Id,
                     			Record_Type__c = 'CAT_Loader__c', 
                                Error_Message__c = err.getMessage().substring(0,255),
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'CAT_Loader_Before.Comments',
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
    	
    // If any errors were returned, add them to the Error_Log table.
    if (!errors.isEmpty()) {
		// Insert rows
        Database.SaveResult[] results = Database.insert(errors, false);
    }
}