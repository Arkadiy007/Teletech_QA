/**********************************************************************
Name: Controller_BrochureRequest 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This controller contains the logic to help display and save data
on the BrochureRequest.page.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 09/26/2011 Created
***********************************************************************/

public with sharing class Controller_BrochureRequest {
	private static final String NONE_PROMPT = '--None--';
	private static RecordType brochureRequestRecordType;
	
	private ApexPages.StandardController stdController;
	public Brochure_Request__c brochureRequest {
		get;set;
	}
	
    public Controller_BrochureRequest(ApexPages.StandardController controller) {
    	stdController = controller;
		if (stdController.getId() != null) {
			// For edits, use the passed in Id to get the Brochure_Request__c object.
			brochureRequest = [select Id, RecordTypeId, Account_Name__c, Nissan_Model_1__c, Nissan_Model_2__c,
			                          Infiniti_Model_1__c, Infiniti_Model_2__c, Keep_me_informed_Nissan_Indicator__c,
			                          Keep_me_informed_Infiniti_Indicator__c, Send_Nissan_Email_Indicator__c,
			                          Send_Infiniti_Email_Indicator__c, Resend_Request_Indicator__c,
			                          Vehicle_Identification_Number__c
			                   from Brochure_Request__c 
			                   where Id = :stdController.getId()];
		} else {
			// For creates, just get the object from the controller and set the record type and lookup
			// to Account.
	    	brochureRequestRecordType = [select Id
	    	                             from RecordType
	    	                             where SObjectType = 'Brochure_Request__c'
	    	                             and name = 'Brochure Request'];
    		brochureRequest = (Brochure_Request__c)stdController.getRecord();
    		brochureRequest.RecordTypeId = brochureRequestRecordType.Id;
    		brochureRequest.Account_Name__c = ApexPages.currentPage().getParameters().get('AccountId');
		}
    }

	public List<SelectOption> NissanBrochures {
		get {
			// Get a list of all Nissan Brochures for the select list
			if (NissanBrochures == null) {
				NissanBrochures = new List<SelectOption>();
				NissanBrochures.add(new SelectOption('', NONE_PROMPT));
				
				List<Code__c> codes = [SELECT Description__c
									   FROM Code__c 
									   WHERE Type__c = 'nissan_brochure'
									   AND Available_For_Brochure__c = true
									   ORDER BY Description__c];
				
				for (Code__c code: codes) {
					NissanBrochures.add(new SelectOption(code.Description__c, code.Description__c));
				}
			}
			return NissanBrochures;
		}
		set;
	}
	
	public List<SelectOption> InfinitiBrochures {
		get {
			// Get a list of all Infiniti Brochures for the select list
			if (InfinitiBrochures == null) {
				InfinitiBrochures = new List<SelectOption>();
				InfinitiBrochures.add(new SelectOption('', NONE_PROMPT));
				
				List<Code__c> codes = [SELECT Description__c
									   FROM Code__c 
									   WHERE Type__c = 'infiniti_brochure'
									   AND Available_For_Brochure__c = true
									   ORDER BY Description__c];
				
				for (Code__c code: codes) {
					InfinitiBrochures.add(new SelectOption(code.Description__c, code.Description__c));
				}
			}
			return InfinitiBrochures;
		}
		set;
	}

	public PageReference doSaveBrochureRequest() {
		try {
			upsert brochureRequest;
		} catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
		}
		
		return new ApexPages.StandardController(new Brochure_Request__c(ID = brochureRequest.Id)).view();
	}	
}