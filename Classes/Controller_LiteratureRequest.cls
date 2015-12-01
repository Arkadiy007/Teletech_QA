/**********************************************************************
Name: Controller_LiteratureRequest 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This controller contains the logic to help display and save data
on the LiteratureRequest.page.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 09/21/2011 Created                                                 
***********************************************************************/

public with sharing class Controller_LiteratureRequest {
	private static final String SELECT_ONE_PROMPT = '--Select One--';
	private static final String NONE_PROMPT = '--None--';
	private static RecordType literatureRequestRecordType;
	private static String accountId;
	
	private ApexPages.StandardController stdController;
	public Brochure_Request__c literatureRequest {
		get;set;
	}
	public Account acct {
		get;set;
	}
	
    public Controller_LiteratureRequest(ApexPages.StandardController controller) {
    	stdController = controller;
    	isSuccess = false;
		if (stdController.getId() != null) {
			// For edits, use the passed in Id to get the Literature_Request__c object and use the Literature__c
			// Id from that record to get the details of the selected Literature.
			literatureRequest = [select Id, RecordTypeId, Account_Name__c, Mailing_Street__c, Mailing_City__c,
			                            Mailing_State_Province__c, Mailing_Zip__c, Email__c, Literature_Requested__c,
			                            Use_this_to_Update_Customer_s_Info__c, Keep_me_informed_Nissan_Indicator__c,
			                            Keep_me_informed_Infiniti_Indicator__c, Send_Nissan_Email_Indicator__c,
			                            Send_Infiniti_Email_Indicator__c, Resend_Request_Indicator__c,
			                            Shipped_By__c, Tracking_Number__c
			                     from Brochure_Request__c 
			                     where Id = :stdController.getId()];
			Literature__c literature = [select Make__c, Model_Year__c, Model__c, Id
			                            from Literature__c
			                            where Id = :literatureRequest.Literature_Requested__c];
			selectedMake = literature.Make__c;
			selectedYear = literature.Model_Year__c;
			selectedModel = literature.Model__c;
			selectedLiterature = literature.Id;
		} else {
			// For creates, just get the object from the controller and set the record type and lookup
			// to Account.
	    	literatureRequestRecordType = [select Id
	    	                             from RecordType
	    	                             where SObjectType = 'Brochure_Request__c'
	    	                             and name = 'Literature Request'];
    		literatureRequest = (Brochure_Request__c)stdController.getRecord();
    		literatureRequest.RecordTypeId = literatureRequestRecordType.Id;
    		accountId = ApexPages.currentPage().getParameters().get('AccountId');
    		if (accountId != null && accountId != '' && accountId != 'null') {
    			literatureRequest.Account_Name__c = accountId;
    		}
		}
    }

	public void changeAccount() {
		// Take the new Account lookup and set the mailing fields on the screen from information
		// on the Account.  If the Account lookup is null, set the mailing fields to null as well.
		if (literatureRequest.Account_Name__c != null) {
			acct = [select PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonEmail
			        from Account
			        where id = :literatureRequest.Account_Name__c];
			
			literatureRequest.Mailing_Street__c = acct.PersonMailingStreet;
			literatureRequest.Mailing_City__c = acct.PersonMailingCity;
			literatureRequest.Mailing_State_Province__c = acct.PersonMailingState;
			literatureRequest.Mailing_Zip__c = acct.PersonMailingPostalCode;
			literatureRequest.Email__c = acct.PersonEmail;
		} else {
			literatureRequest.Mailing_Street__c = null;
			literatureRequest.Mailing_City__c = null;
			literatureRequest.Mailing_State_Province__c = null;
			literatureRequest.Mailing_Zip__c = null;
			literatureRequest.Email__c = null;
		}
	}

    public String selectedMake {
    	get;set;
    }

	public List<SelectOption> Makes {
		get {
			// Get a list of all Makes for the select list
			if (Makes == null) {
				Makes = new List<SelectOption>();
				Makes.add(new SelectOption(SELECT_ONE_PROMPT, SELECT_ONE_PROMPT));
				
				for (AggregateResult groupedResult : [SELECT Make__c, Count(ID) makeChildren 
													  FROM Literature__c
													  Where Active__c = true
													  Group By Make__c
													  Order By Make__c]) {
					String makeID = String.valueOf(groupedResult.get('Make__c'));
					String make = String.valueOf(groupedResult.get('Make__c'));
					Makes.add(new SelectOption(makeID, make));
				}
			}
			return Makes;
		}
		set;
	}
   	
    public String selectedYear {
    	get;set;
    }
    
    public List<SelectOption> Years {
    	get {
    		// Get a list of all Model Years for the select list by querying on the selected Make
            if (Years == null)
                Years = new List<SelectOption>();
            else
                Years.clear();

			Years.add(new SelectOption(NONE_PROMPT, NONE_PROMPT));
			if (selectedMake != null && selectedMake != SELECT_ONE_PROMPT) {
					
				for (AggregateResult groupedResult : [SELECT Model_Year__c, Count(ID) yearChildren 
													  FROM Literature__c
													  Where Make__c = :selectedMake
													  And Model_Year__c != null
													  And Active__c = true
													  Group By Model_Year__c
													  Order By Model_Year__c Desc]) {
					String yearID = String.valueOf(groupedResult.get('Model_Year__c'));
					String year = String.valueOf(groupedResult.get('Model_Year__c'));
					Years.add(new SelectOption(yearID, year));
				}
			}

			return Years;
		}
		set;
    }
    
    public String selectedModel {
    	get;set;
    }
    
    public List<SelectOption> Models {
        get {
        	// Get a list of all Models for the select list by querying on the selected Make and Model Year
            if (Models == null)
                Models = new List<SelectOption>();
            else
                Models.clear();

            Models.add(new SelectOption(NONE_PROMPT, NONE_PROMPT));
            if (selectedMake != null && selectedMake != SELECT_ONE_PROMPT) {
            	String queryYear = '';
            	if (selectedYear != null && selectedYear != NONE_PROMPT)
            		queryYear = selectedYear;

                for (AggregateResult groupedResult : [SELECT Model__c, Count(ID) modelChildren 
							                          FROM Literature__c 
							                          Where Make__c = :selectedMake
							                          And Model_Year__c = :queryYear
							                          And Model__c != null
							                          And Active__c = true
							                          Group By Model__c
							                          Order By Model__c]) {
                    String modelID = String.valueOf(groupedResult.get('Model__c'));
                    String model = String.valueOf(groupedResult.get('Model__c'));
                    Models.add(new SelectOption(modelID, model));
                }
            }
            return Models;
        }
        set;
    }
    
    public String selectedLiterature {
    	get;set;
    }
    
    public List<SelectOption> Literatures {
        get {
        	// Get a list of all Literatures for the select list by querying on the selected Make, Model Year, and Model
            if (Literatures == null)
                Literatures = new List<SelectOption>();
            else
                Literatures.clear();
            Literatures.add(new SelectOption(SELECT_ONE_PROMPT, SELECT_ONE_PROMPT));
            if (selectedMake != null && selectedMake != SELECT_ONE_PROMPT) {
            	String queryYear = '';
            	if (selectedYear != null && selectedYear != NONE_PROMPT)
            		queryYear = selectedYear;

            	String queryModel = '';
            	if (selectedModel != null && selectedModel != NONE_PROMPT)
            		queryModel = selectedModel;

                for (AggregateResult groupedResult : [SELECT Id, Item_Description__c
							                          FROM Literature__c
							                          Where Make__c = :selectedMake
							                          And Model_Year__c = :queryYear
							                          And Model__c = :queryModel
							                          And Item_Description__c != null
							                          And Active__c = true
							                          Group By Id, Item_Description__c
							                          Order By Item_Description__c]) {
                    String literatureID = String.valueOf(groupedResult.get('Id'));
                    String literature = String.valueOf(groupedResult.get('Item_Description__c'));
                    Literatures.add(new SelectOption(literatureID, literature));
                }
            }
            return Literatures;
        }
        set;
    }
        
    public PageReference populateEntries() {
    	// If a Literature object has been specified on the screen, assign the value to the literatureRequest object
    	literatureRequest.Literature_Requested__c = selectedLiterature == SELECT_ONE_PROMPT ? null : selectedLiterature;
    	
    	return null;
    }

	public Boolean isSuccess {get;set;}
	public void doSaveLiteratureRequest() {
		try {
			// Only save if a request for Literature has been made
			if(literatureRequest.Literature_Requested__c != null) {
				upsert literatureRequest;
				
				// If the user has selected to save the mailing information back to the customer's account,
				// get the information and update it.
				if (literatureRequest.Use_this_to_Update_Customer_s_Info__c == true && acct != null) {
					acct.PersonMailingStreet = literatureRequest.Mailing_Street__c;
					acct.PersonMailingCity = literatureRequest.Mailing_City__c;
					acct.PersonMailingState = literatureRequest.Mailing_State_Province__c;
					acct.PersonMailingPostalCode = literatureRequest.Mailing_Zip__c;
					acct.PersonEmail = literatureRequest.Email__c;
					update acct;
				}
				
				isSuccess = true;
			} 
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select Literature to request.'));
				isSuccess = false;	
			}
		} 
		catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            isSuccess = false;
		}
	}	
}