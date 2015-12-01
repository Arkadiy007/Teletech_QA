/**********************************************************************
Name: Controller_LiteratureRequestLandingPage 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This controller contains the logic to get the target
for redirection for the LiteratureRequestLandingPage.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 09/22/2011 Created                              
***********************************************************************/
public with sharing class Controller_LiteratureRequestLandingPage {
	public Brochure_Request__c br {get; set;}
	ApexPages.StandardController stdController;
    private static RecordType literatureRequestRecordType;
    private static RecordType brochureRequestRecordType;
    private static String createRecordType;
    private static String accountId;
	
    public Controller_LiteratureRequestLandingPage(ApexPages.StandardController controller) {
    	stdController = controller;
    	br = (Brochure_Request__c)controller.getRecord();
    	literatureRequestRecordType = [select Id
    	                               from RecordType
    	                               where SObjectType = 'Brochure_Request__c'
    	                               and name = 'Literature Request'];
    	brochureRequestRecordType = [select Id
    	                             from RecordType
    	                             where SObjectType = 'Brochure_Request__c'
    	                             and name = 'Brochure Request'];
    	createRecordType = ApexPages.currentPage().getParameters().get('RecordType');
    	accountId = ApexPages.currentPage().getParameters().get('AccountId');
    }
		
	// If getRedir returns null, the visual page redirects to standard edit/delete page, 
	// otherwise stays in the same page with a message.
    public PageReference getRedir() {
    	PageReference pageRef;
    	if (br.ID == null) {
    		if (createRecordType == brochureRequestRecordType.Id) {
    			// New Brochure Request
    			pageRef = new PageReference('/apex/BrochureRequest?AccountId=' + accountId);
    			return pageRef;
    		} else {
    			// New Literature Request
	    		pageRef = new PageReference('/apex/LiteratureRequest?AccountId=' + accountId);
	    		return pageRef;
    		}
    	} else {
    		if (br.RecordTypeId == brochureRequestRecordType.Id) {
    			// Edit Brochure Request
    			pageRef = new PageReference('/apex/BrochureRequest?Id=' + br.Id);
    			return pageRef;
    		} else {
    			// Edit Literature Request
	    		pageRef = new PageReference('/apex/LiteratureRequest?Id=' + br.Id);
	    		return pageRef;
    		}
    	}
    }
}