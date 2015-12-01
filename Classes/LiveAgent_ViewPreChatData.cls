/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller of the page with the same name used in the Service Cloud Console for
the Agents to manage Chat request 

Class:              LiveAgent_ViewPreChatData
Author:				Rohdenburg S.
Date:               05/20/2013
Version:            1.0
Last Updated:       01/02/2014
    * 05/20/2013	SR - Implemented
    * 05/29/2013	SR - Cleaned up
    * 07/05/2013	SR - Cleaned up according to the Code Review
    * 07/10/2013	SR - Included the Save button and got the Site URL from a 
    				Label
    * 08/05/2013	SR - Modified for showing the attachment URL on Page Load
    * 01/02/2014	SR - Included the Record Type field
*/
public with sharing class LiveAgent_ViewPreChatData {
	
	// -------- Constants --------
	private final String LIMIT_ACCOUNT_RECORDS = '50';
	private final String ATTACHMENT_URL = 
		'/chat/LiveAgent_UploadFile?AccountId=';
    
    Id MCCRTId;
	
	// -------- Constructor --------
	public LiveAgent_ViewPreChatData.LiveAgent_ViewPreChatData(
		ApexPages.StandardController controller) {
		accountList = new List<Account>();
		showResults = false;
		showNoRecords = false;
		showSaveButton = true;
		showSearchBlock = true;
		hideMCCFields = false;
		currentPreChatDataObject = (Pre_Chat_Data__c)controller.getRecord();
		Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Pre_Chat_Data__c.getRecordTypeInfosByName();
		MCCRTId = rtInfosByName.get('MCC').getRecordTypeId();
		
		if (!datacheck.IsStringNullOrEmpty(
			currentPreChatDataObject.AccountId__c)){
			attachmentUrl = Label.LiveAgent_SiteURL + ATTACHMENT_URL + 
				currentPreChatDataObject.AccountId__c;	
		}
		
		if (currentPreChatDataObject.Live_Chat_Transcript__c != null) {
			showSaveButton = false;
			showSearchBlock = false;
		}
		
		if(currentPreChatDataObject.RecordTypeId == MCCRTId){
			hideMCCFields = true;			
		}
	} 
	
	// -------- Variables --------
	private ValidationUtility datacheck = new ValidationUtility();
	
	// -------- Properties --------
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String city {get;set;}
	public String state {get;set;}
	public String zip {get;set;}
	public String email {get;set;}
	public String caseNumber {get;set;}
	public String phone {get;set;}
	public Boolean showResults {get;set;}
	public Boolean showNoRecords {get;set;}
	public Boolean showSaveButton {get;set;}
	public Boolean showSearchBlock {get;set;}
	public String selectedAccountId {get;set;}
	public Pre_Chat_Data__c currentPreChatDataObject {get;set;}
	public List<Account> accountList {get;set;}
	public String attachmentUrl {get;set;}
	public boolean hideMCCFields {get; set;}
	
	// -------- Methods --------
	// It searchs the accounts that match the entered filters
	public void searchAccount() {
		
		String query = '';
		query += 'SELECT Id, FirstName, LastName, PersonMailingCity, ';
		query += 'PersonMailingState, PersonMailingPostalCode, PersonEmail ';
		query += 'FROM Account ';
		query += 'WHERE IsDeleted = false ';
		
		if (!datacheck.IsStringNullOrEmpty(firstName)) {
			query += 'AND FirstName = \'' + firstName + '\' ';	
		}
		
		if (!datacheck.IsStringNullOrEmpty(lastName)) {
			query += 'AND LastName = \'' + lastName + '\' ';	
		}
		
		if (!datacheck.IsStringNullOrEmpty(city)) {
			query += 'AND PersonMailingCity = \'' + city + '\' ';	
		}
		
		if (state != 'None') {
			query += 'AND PersonMailingState = \'' + state + '\' ';	
		}
		
		if (!datacheck.IsStringNullOrEmpty(zip)) {
			query += 'AND PersonMailingPostalCode = \'' + zip + '\' ';	
		}
		
		if (!datacheck.IsStringNullOrEmpty(email)) {
			query += 'AND PersonEmail = \'' + email + '\' ';	
		}
		
		if (!datacheck.IsStringNullOrEmpty(caseNumber)) {
			List<Case> caseList = [SELECT AccountId 
				FROM Case
				WHERE CaseNumber = :caseNumber];
			
			if (caseList.size() > 0) {
				query += 'AND Id = \'' + caseList[0].AccountId + '\' ';
			}
			else {
				showResults = false;
				return;
			}
		}
		
		query += 'LIMIT ' + LIMIT_ACCOUNT_RECORDS;
		
		accountList = Database.query(query);
		
		if (accountList.size() > 0) {
			showResults = true;
			showNoRecords = false;	
		}
		else {
			showResults = false;
			showNoRecords = true;
		}
	}
	
	// It associated the Pre_Chat_Data__c object to the selected Account
	public void associateAccount() {
		currentPreChatDataObject.AccountId__c = selectedAccountId;
		update currentPreChatDataObject;
		
		attachmentUrl = Label.LiveAgent_SiteURL + ATTACHMENT_URL + 
			selectedAccountId;
	}
	
	// It saves the selected Disposition Code
	public void save() {
		update currentPreChatDataObject;
		showSaveButton = false;
	}
	
	// It sets the page in edit mode
	public void edit() {
		showSaveButton = true;
		showSearchBlock = true;
	}
	
	//It cleans the Disposition value when the Record Type is changed
	public void changeRecordType() {
		currentPreChatDataObject.Disposition_Code__c = null;
		if(currentPreChatDataObject.RecordTypeId == MCCRTId){
			hideMCCFields = true;
		}else{
			hideMCCFields = false;
		}
		 
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		// Insert needed data
		Account acc = new Account();
		acc.FirstName = 'Sebastian';
		acc.LastName = 'Rohdenburg';
		acc.PersonMailingCity = 'Buenos Aires';
		acc.PersonMailingPostalCode = '1425';
		acc.PersonEmail = 'srohdenburg@teletech.com';
		insert acc;
		
		Case c1 = new Case();
		c1.AccountId = acc.Id;
		insert c1;
		
		// Instantiate the LiveAgent_ViewPreChatData class
		Pre_Chat_Data__c pcd = new Pre_Chat_Data__c(); 
		insert pcd;
		ApexPages.StandardController sc = 
			new ApexPages.standardController(pcd);
		LiveAgent_ViewPreChatData viewData = new LiveAgent_ViewPreChatData(sc);
		
		// Testing the Search by Account 
		viewData.firstName = 'Sebastian';
		viewData.LastName = 'Rohdenburg';
		viewData.city = 'Buenos Aires';
		viewData.state = 'OH';
		viewData.zip = '1425';
		viewData.email = 'srohdenburg@teletech.com';
		viewData.searchAccount();
		
		// Testing the Search by Case Number
		viewData = new LiveAgent_ViewPreChatData(sc);
		viewData.state = 'None';
		viewData.caseNumber = '123'; //c1.CaseNumber;
		viewData.searchAccount();
		
		// Associate account
		viewData.selectedAccountId = acc.Id;
		viewData.associateAccount();
		
		// Edit and Save a Disposition
		viewData.edit();
		viewData.save(); 
	}
}