/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class received all the data filled in the Contact Us form (via Post) and 
creates a Case (for Infiniti)

Class:              WebToCase
Author:				Rohdenburg S.
Date:               08/21/2013
Version:            1.0
Last Updated:       08/23/2013
    * 08/21/2013	SR - Creation
    * 08/23/2012	SR - Included the hidden fields
    * 08/23/2012	SR - Implemented the routing functionality and the dynamic
    				record type 
*/

public class WebToCaseInfiniti
{
	// -------- Constants --------
	private final String CASE_ORIGIN = 'Web';
	private final String STRING_BREAK = '\r\n';
	private final String RECORD_TYPE_MARITZ = 'Maritz';
	private final String FORM_FIRST_NAME = 'firstName';
	private final String FORM_MIDDLE_INITIAL = 'middleInitial';
	private final String FORM_LAST_NAME = 'lastName';
	private final String FORM_TWITTER_NAME = 'twitterName';
	private final String FORM_ADDRESS_1 = 'address1';
	private final String FORM_ADDRESS_UNIT = 'txtUnit';
	private final String FORM_CITY = 'city';
	private final String FORM_STATE = 'state';
	private final String FORM_ZIP = 'zip';
	private final String FORM_DAY_NUMBER_A_CODE = 'dayNumberACode';
	private final String FORM_DAY_NUMBER_PREFIX = 'dayNumberPrefix';
	private final String FORM_DAY_NUMBER_SUFFIX = 'dayNumberSuffix';
	private final String FORM_EMAIL_ADDRESS = 'emailAddress';
	private final String FORM_COMMENTS = 'comments';
	private final String HDN_TOPIC = 'formType';
	private final String HDN_INQUIRY = 'hdnInquiry';
	private final String HDN_YEAR = 'hdnYear';
	private final String HDN_STATE = 'hdnState';
	private final String HDN_ZIP = 'hdnZip';
	private final String HDN_VEHICLE_MODEL = 'hdnVehicleModel';
	private final String HDN_VEHICLE_VIN = 'hdnVehicleVin';
	private final String HDN_DEALER_NAME = 'hdnDealerName';
	private final String HDN_VEHICLE_MILEAGE = 'hdnVehicleMileage';
	private final String HDN_POLICY_NUMBER = 'hdnPolicyNumber';
	private final String SUCCESS_MESSAGE = 'The case has been succesfully ' + 
		'created';
	private final String MANDATORY_MESSAGE = 'First Name, Last Name and ' + 
		'Comments are mandatory fields';
	private final String QUEUE_INFINITI_CA = 'CA Email Infiniti';
	private final String QUEUE_INFINITI_CCC = 'CCC Email to Case CA ' + 
		'Infiniti Queue';
	
	// -------- Constructor --------
    public WebToCaseInfiniti() {
    	loadInfinitiMaps();
    	retrieveInfinitiParameters();
    }

    // -------- Variables --------
	private ValidationUtility dataCheck = new ValidationUtility();
	
	// -------- Properties --------
	public Map<String, String> topics {get; set;}
	public Map<String, String> inquiries {get; set;}
	public String firstName {get; set;}
	public String middleInitial {get; set;}
	public String lastName {get; set;}
	public String twitterName {get; set;}
	public String address1 {get; set;}
	public String txtUnit {get; set;}
	public String city {get; set;}
	public String state {get; set;}
	public String zip {get; set;}
	public String dayNumberACode {get; set;}
	public String dayNumberPrefix {get; set;}
	public String dayNumberSuffix {get; set;}
	public String emailAddress {get; set;}
	public String comments {get; set;}
	public String phone {get; set;}
	public String topic {get; set;}
	public String topicNumber {get; set;}
	public String inquiry {get; set;}
	public String vehicleYear {get; set;}
	public String vehicleState {get; set;}
	public String vehicleZip {get; set;}
	public String vehicleModel {get; set;}
	public String vehicleVin {get; set;}
	public String vehicleDealerName {get; set;}
	public String vehicleMileage {get; set;}
	public String vehiclePolicyNumber {get; set;}
	
	// -------- Methods --------
	// It creates a Case and a Person Account with the provided information  
	public void submitInfinitiForm() { 
		try {
			if (validateMandatoryFields()) {
				String accountId = getPersonAccount();
				insertCase(accountId);
				
				ApexPages.Message msg = new ApexPages.Message(
					ApexPages.Severity.INFO, SUCCESS_MESSAGE);
			    ApexPages.addMessage(msg);
		    }
		}
    	catch (Exception ex) {
    		ApexPages.Message msg = new ApexPages.Message(
    			ApexPages.Severity.ERROR, ex.getMessage());
		    ApexPages.addMessage(msg);
    	}
	}
	
	// It loads the Map objects with the fixed data of the page
	private void loadInfinitiMaps() {
		topics = new Map<String, String>();
		topics.put('1', 'Infiniti Products'); 
		topics.put('2', 'My Infiniti Vehicle');
		topics.put('3', 'Infiniti Hybrid and Electric Vehicles');
		topics.put('4', 'Certified Pre-Owned');
		topics.put('5', 'My Warranty or Extended Service Plan');
		topics.put('6', 'Vehicle Maintenance');
		topics.put('7', 'Financing Options');
		topics.put('8', 'My Loan, Lease or Online Bill Pay');
		topics.put('9', 'Infiniti Retailers');
		topics.put('10', 'Infiniti Corporate');
		topics.put('11', 'Other');
		
		inquiries = new Map<String, String>();
		inquiries.put('company','I would like additional information about ' + 
			'Infiniti or Nissan North America');
		inquiries.put('product','I would like additional information about ' + 
			'Infiniti products');
		inquiries.put('retailer','I would like additional information about ' + 
			'Infiniti retailers, the products they carry, and The Total ' + 
			'Ownership Experience');
	}
	
	// It collects all the fields from the Contact Us form
	private void retrieveInfinitiParameters() {
		Map<String,String> parameters = ApexPages.currentPage().getParameters();
		
		if (parameters.get(FORM_FIRST_NAME) != null) {
    		firstName = parameters.get(FORM_FIRST_NAME);
    		//TODO: Check this FirstName length 40 - ContactUs 50
    	}
    	
    	if (parameters.get(FORM_MIDDLE_INITIAL) != null) {
    		middleInitial = parameters.get(FORM_MIDDLE_INITIAL);
    	}
    	
    	if (parameters.get(FORM_LAST_NAME) != null) {
    		lastName = parameters.get(FORM_LAST_NAME);
    	}
    	
    	if (parameters.get(FORM_TWITTER_NAME) != null &&
    		parameters.get(FORM_TWITTER_NAME) != '@') {
    		twitterName = parameters.get(FORM_TWITTER_NAME);
    	}
    	
    	if (parameters.get(FORM_ADDRESS_1) != null) {
    		address1 = parameters.get(FORM_ADDRESS_1);
    	}
    	
    	if (parameters.get(FORM_ADDRESS_UNIT) != null) {
    		txtUnit = parameters.get(FORM_ADDRESS_UNIT);
    	}
    	
    	if (parameters.get(FORM_CITY) != null) {
    		city = parameters.get(FORM_CITY);
    	}
    	
    	if (parameters.get(FORM_STATE) != null) {
    		state = parameters.get(FORM_STATE);
    	}
    	
    	if (parameters.get(FORM_ZIP) != null) {
    		zip = parameters.get(FORM_ZIP);
    	}
    	
    	phone = '';
    	if (parameters.get(FORM_DAY_NUMBER_A_CODE) != null) {
    		dayNumberACode = parameters.get(FORM_DAY_NUMBER_A_CODE);
    		phone = parameters.get(FORM_DAY_NUMBER_A_CODE);
    	}
    	
    	if (parameters.get(FORM_DAY_NUMBER_PREFIX) != null) {
    		dayNumberPrefix = parameters.get(FORM_DAY_NUMBER_PREFIX);
    		phone += parameters.get(FORM_DAY_NUMBER_PREFIX);
    	}
    	
    	if (parameters.get(FORM_DAY_NUMBER_SUFFIX) != null) {
    		dayNumberSuffix = parameters.get(FORM_DAY_NUMBER_SUFFIX);
    		phone += parameters.get(FORM_DAY_NUMBER_SUFFIX);
    	}
    	
    	if (parameters.get(FORM_EMAIL_ADDRESS) != null && 
    		dataCheck.IsEmailFormat(parameters.get(FORM_EMAIL_ADDRESS))) {
    		emailAddress = parameters.get(FORM_EMAIL_ADDRESS);
    	}
    	
    	if (parameters.get(FORM_COMMENTS) != null) {
    		comments = parameters.get(FORM_COMMENTS);
    	}
    	
    	if (parameters.get(HDN_TOPIC) != null && 
			parameters.get(HDN_TOPIC) != '0') {
			topicNumber = parameters.get(HDN_TOPIC);
    		topic = topics.get(parameters.get(HDN_TOPIC));
    	}
    	
    	if (parameters.get(HDN_INQUIRY) != null) {
    		inquiry = inquiries.get(parameters.get(HDN_INQUIRY));
    	}
    	
    	if (parameters.get(HDN_YEAR) != null) {
    		vehicleYear = parameters.get(HDN_YEAR);
    	}
    	
    	if (parameters.get(HDN_STATE) != null) {
    		vehicleState = parameters.get(HDN_STATE);
    	}
    	
    	if (parameters.get(HDN_ZIP) != null) {
    		vehicleZip = parameters.get(HDN_ZIP);
    	}
    	
    	if (parameters.get(HDN_VEHICLE_MODEL) != null) {
    		vehicleModel = parameters.get(HDN_VEHICLE_MODEL);
    	}
    	
    	if (parameters.get(HDN_VEHICLE_VIN) != null) {
    		vehicleVin = parameters.get(HDN_VEHICLE_VIN);
    	}
    	
    	if (parameters.get(HDN_DEALER_NAME) != null) {
    		vehicleDealerName = parameters.get(HDN_DEALER_NAME);
    	}
    	
    	if (parameters.get(HDN_VEHICLE_MILEAGE) != null) {
    		vehicleMileage = parameters.get(HDN_VEHICLE_MILEAGE);
    	}
    	
    	if (parameters.get(HDN_POLICY_NUMBER) != null) {
    		vehiclePolicyNumber = parameters.get(HDN_POLICY_NUMBER);
    	}   	    		
	}
	
	// It searchs for the Person Account, and it creates one in case of 
	// not existing
	private String getPersonAccount() {
		String accountId;
		List<Account> accounts = new List<Account>();
		
		if (!dataCheck.IsStringNullOrEmpty(emailAddress)) {
			accounts = [SELECT Id 
				FROM Account 
				WHERE PersonEmail = :emailAddress
				LIMIT 1];
		}
		else if (!dataCheck.IsStringNullOrEmpty(twitterName)) {
			accounts = [SELECT Id 
				FROM Account 
				WHERE Twitter_Handle__c = :twitterName
				LIMIT 1];
		}
		else if (!dataCheck.IsStringNullOrEmpty(phone) &&
			!dataCheck.IsStringNullOrEmpty(firstName) &&
			!dataCheck.IsStringNullOrEmpty(lastName)) {
			accounts = [SELECT Id 
				FROM Account 
				WHERE Phone = :phone
				AND FirstName = :firstName
				AND LastName = :lastName
				LIMIT 1];
		}
		
		if (accounts.size() > 0) {
			accountId = accounts[0].Id;
		}
		else {
			accountId = insertPersonAccount();
		}
		
		return accountId;
	}
	
	// It inserts a Person Account record
	private String insertPersonAccount() {
		RecordType maritzAccount = [SELECT Id 
			FROM RecordType 
			WHERE DeveloperName = :RECORD_TYPE_MARITZ 
			AND SobjectType = 'Account'];
		
		Account personAccount = new Account();
		personAccount.RecordTypeId = maritzAccount.Id;
		personAccount.FirstName = firstName;
		personAccount.MiddleName__c = middleInitial;
		personAccount.LastName = lastName;
		personAccount.Twitter_Handle__c = twitterName;
		personAccount.PersonMailingStreet = address1 + ' ' + txtUnit;
		personAccount.PersonMailingCity = city;
		personAccount.PersonMailingState = state;
		personAccount.PersonMailingPostalCode = zip;
		personAccount.Phone = phone;
		personAccount.PersonEmail = emailAddress;
		insert personAccount;
		
		return personAccount.Id;
	}
	
	// It inserts a Case record
	private void insertCase(string accountId) {
		Case postedCase = new Case();
		postedCase.OwnerId = getCaseOwner(topicNumber);
		postedCase.RecordTypeId = getCaseRecordType(topicNumber);
		postedCase.Origin = CASE_ORIGIN;
		postedCase.AccountId = accountId;
		postedCase.ContactId = [Select Id from Contact where AccountId =: accountId Limit 1].Id;
		postedCase.First_Name__c = firstName;
		postedCase.Middle_Initial__c = middleInitial;
		postedCase.Last_Name__c = lastName;
		postedCase.SuppliedPhone = phone;
		postedCase.SuppliedEmail = emailAddress;
		postedCase.Description =  generateDescription();
		postedCase.Subject = topic;
		
		insert postedCase;
	}
	
	private String generateDescription() {
		String caseDescription = '';
		
		caseDescription += 'First Name: ' + 
			formatField(firstName) + STRING_BREAK;
		caseDescription += 'Middle Initial: ' + 
			formatField(middleInitial) + STRING_BREAK;
		caseDescription += 'Last Name: ' + 
			formatField(lastName) + STRING_BREAK;
		caseDescription += 'Twitter Name: ' + 
			formatField(twitterName) + STRING_BREAK;
		caseDescription += 'Street Address: ' + 
			formatField(address1) + STRING_BREAK;
		caseDescription += 'Apt. / Suite #: ' + 
			formatField(txtUnit) + STRING_BREAK;
		caseDescription += 'City: ' + 
			formatField(city) + STRING_BREAK;
		caseDescription += 'State: ' + 
			formatField(state) + STRING_BREAK;
		caseDescription += 'Zip: ' + 
			formatField(zip) + STRING_BREAK;
		caseDescription += 'Phone Number: ' + 
			formatField(phone) + STRING_BREAK;
		caseDescription += 'Email Address: ' + 
			formatField(emailAddress) + STRING_BREAK;
		caseDescription += 'Topic: ' + 
			formatField(topic) + STRING_BREAK;
		caseDescription += 'Inquiry: ' + 
			formatField(inquiry) + STRING_BREAK;
		caseDescription += 'Comments: ' + 
			formatField(comments) + STRING_BREAK;
		
		//Vehicle Information
		if (!datacheck.IsStringNullOrEmpty(vehicleYear)) {
			caseDescription += STRING_BREAK + 'VEHICLE INFORMATION' + 
				STRING_BREAK;
			caseDescription += 'Year: ' + 
				formatField(vehicleYear) + STRING_BREAK;
			caseDescription += 'State: ' + 
				formatField(vehicleState) + STRING_BREAK;
			caseDescription += 'Zip: ' + 
				formatField(vehicleZip) + STRING_BREAK;
			caseDescription += 'Model: ' + 
				formatField(vehicleModel) + STRING_BREAK;
			caseDescription += 'VIN: ' + 
				formatField(vehicleVin) + STRING_BREAK;
			caseDescription += 'Dealer Name: ' + 
				formatField(vehicleDealerName) + STRING_BREAK;
			caseDescription += 'Mileage: ' + 
				formatField(vehicleMileage) + STRING_BREAK;
		}
		else if (!datacheck.IsStringNullOrEmpty(vehicleVin)) {
			caseDescription += STRING_BREAK + 'Policy Number: ' + 
				formatField(vehiclePolicyNumber) + STRING_BREAK;
			caseDescription += 'VIN: ' + 
				formatField(vehicleVin) + STRING_BREAK;
		}
		
		return caseDescription;
	}
	
	// It replace a null or an empty field by a '-'
	private String formatField(String field) {
		if (dataCheck.IsStringNullOrEmpty(field)) {
			return '-';
		}
		else {
			return field;	
		}	
	}
	
	// It validates if all the mandatory fields were provided
	private Boolean validateMandatoryFields() {
		if (dataCheck.IsStringNullOrEmpty(firstName) ||
			dataCheck.IsStringNullOrEmpty(lastName) ||
			dataCheck.IsStringNullOrEmpty(comments)) { 
			
			ApexPages.Message msg = new ApexPages.Message(
				ApexPages.Severity.WARNING, MANDATORY_MESSAGE);
		    ApexPages.addMessage(msg);
		    
			return false;
		}
		
		return true;
	}
	
	// It routes the case according to the selected topic
	private String getCaseOwner(String topicNumber) {
		QueueSobject currentQueue;
		
		if (topicNumber == '1') {
			currentQueue = [SELECT QueueId 
				FROM QueueSobject 
				WHERE Queue.Name = :QUEUE_INFINITI_CCC];
		}
		else {
			currentQueue = [SELECT QueueId 
				FROM QueueSobject 
				WHERE Queue.Name = :QUEUE_INFINITI_CA];
		}
		
		return currentQueue.QueueId;
	}
	
	// It gets the case record type according to the selected topic
	private String getCaseRecordType(String topicNumber) {
		RecordType caseRecordType;
		
		if (topicNumber == '1') {
			caseRecordType = [SELECT Id 
				FROM RecordType 
				WHERE DeveloperName = 'CCC'
				AND SobjectType = 'Case'];
		}
		else {
			caseRecordType = [SELECT Id 
				FROM RecordType 
				WHERE DeveloperName = 'CA_Email_Infiniti'
				AND SobjectType = 'Case'];
		}
		
		return caseRecordType.Id;
	}		
	
}