/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class received all the data filled in the Contact Us form (via Post) and 
creates a Case - FOR NISSAN FORM

Class:              WebToCaseNissan
Author:				Rohdenburg S.
Date:               08/30/2013
Version:            1.0
Last Updated:       08/30/2013
    * 08/30/2013	SR - Creation as a copy based on the W2C Infiniti class    
*/

public class WebToCaseNissan
{
	// -------- Constants --------
	private final String CASE_ORIGIN = 'Web';
	private final String STRING_BREAK = '\r\n';
	private final String RECORD_TYPE_MARITZ = 'Maritz';
	private final String NISSAN_FIRST_NAME = 'firstName'; 
	private final String NISSAN_LAST_NAME = 'lastName';
	private final String NISSAN_EMAIL_ADDRESS = 'emailAddress';
	private final String NISSAN_TWITTER_NAME = 'twitterName';
	private final String NISSAN_ADDRESS = 'address1';
	private final String NISSAN_CITY = 'city';
	private final String NISSAN_STATE = 'state';
	private final String NISSAN_ZIP = 'zip';
	private final String NISSAN_PHONE_AREA = 'phoneNumberAreaCode';
	private final String NISSAN_PHONE_PREFIX = 'phoneNumberPrefix';
	private final String NISSAN_PHONE_SUFFIX = 'phoneNumberSuffix';
	private final String NISSAN_IS_OWNER = 'isNissanOwner';
	private final String NISSAN_VIN = 'vin';
	private final String NISSAN_DEALER_NAME = 'dealerName';
	private final String NISSAN_DEALER_STATE = 'dealerState';
	private final String NISSAN_TOPIC = 'hdnQuestionText';
	private final String NISSAN_COMMENTS = 'comments';
	private final String SUCCESS_MESSAGE = 'The case has been succesfully ' + 
		'created';
	private final String MANDATORY_MESSAGE = 'First Name, Last Name and ' + 
		'Comments are mandatory fields';
	private final String QUEUE_NISSAN_CA = 'CA Email Nissan';
	private final String QUEUE_NISSAN_CCC = 'CCC Email to Case CA Nissan ' + 
		'Queue';
	private final String QUEUE_NISSAN_LEAF = 'LEAF Email to Case';
	
	// -------- Constructor --------
    public WebToCaseNissan() {
    	retrieveNissanParameters();
    }

    // -------- Variables --------
	private ValidationUtility dataCheck = new ValidationUtility();
	
	// -------- Properties --------
	public String firstName {get; set;}
	public String lastName {get; set;}
	public String emailAddress {get; set;}
	public String twitterName {get; set;}
	public String address1 {get; set;}
	public String city {get; set;}
	public String state {get; set;}
	public String zip {get; set;}
	public String phoneNumberAreaCode {get; set;}
	public String phoneNumberPrefix {get; set;}
	public String phoneNumberSuffix {get; set;}
	public String isNissanOwner {get; set;}
	public String vin {get; set;}
	public String dealerName {get; set;}
	public String dealerState {get; set;}
	public String hdnQuestionText {get; set;}
	public String comments {get; set;}
	public String phone {get; set;}
	
	// -------- Methods --------
	// It creates a Case and a Person Account with the provided information  
	public void submitNissanForm() { 
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
	
	// It collects all the fields from the Nissan Contact Us form
	private void retrieveNissanParameters() {
		Map<String,String> parameters = ApexPages.currentPage().getParameters();
		
		if (parameters.get(NISSAN_FIRST_NAME) != null) {
    		firstName = parameters.get(NISSAN_FIRST_NAME);
    	}
    	
    	if (parameters.get(NISSAN_LAST_NAME) != null) {
    		lastName = parameters.get(NISSAN_LAST_NAME);
    	}
    	
    	if (parameters.get(NISSAN_EMAIL_ADDRESS) != null) {
    		emailAddress = parameters.get(NISSAN_EMAIL_ADDRESS);
    	}
    	
    	if (parameters.get(NISSAN_TWITTER_NAME) != null &&
    		parameters.get(NISSAN_TWITTER_NAME) != '@') {
    		twitterName = parameters.get(NISSAN_TWITTER_NAME);
    	}
    	
    	if (parameters.get(NISSAN_ADDRESS) != null) {
    		address1 = parameters.get(NISSAN_ADDRESS);
    	}
    	
    	if (parameters.get(NISSAN_CITY) != null) {
    		city = parameters.get(NISSAN_CITY);
    	}
    	
    	if (parameters.get(NISSAN_STATE) != null) {
    		state = parameters.get(NISSAN_STATE);
    	}
    	
    	if (parameters.get(NISSAN_ZIP) != null) {
    		zip = parameters.get(NISSAN_ZIP);
    	}
    	
    	phone = '';
    	if (parameters.get(NISSAN_PHONE_AREA) != null) {
    		phoneNumberAreaCode = parameters.get(NISSAN_PHONE_AREA);
    		phone += phoneNumberAreaCode;
    	}
    	
    	if (parameters.get(NISSAN_PHONE_PREFIX) != null) {
    		phoneNumberPrefix = parameters.get(NISSAN_PHONE_PREFIX);
    		phone += phoneNumberPrefix;
    	}
    	
    	if (parameters.get(NISSAN_PHONE_SUFFIX) != null) {
    		phoneNumberSuffix = parameters.get(NISSAN_PHONE_SUFFIX);
    		phone += phoneNumberSuffix;
    	}
    	
    	if (parameters.get(NISSAN_IS_OWNER) != null) {
    		isNissanOwner = parameters.get(NISSAN_IS_OWNER);
    	}
    	
    	if (parameters.get(NISSAN_VIN) != null) {
    		vin = parameters.get(NISSAN_VIN);
    	}
    	
    	if (parameters.get(NISSAN_DEALER_NAME) != null) {
    		dealerName = parameters.get(NISSAN_DEALER_NAME);
    	}
    	
    	if (parameters.get(NISSAN_DEALER_STATE) != null) {
    		dealerState = parameters.get(NISSAN_DEALER_STATE);
    	}
    	
    	if (parameters.get(NISSAN_TOPIC) != null) {
    		hdnQuestionText = parameters.get(NISSAN_TOPIC);
    	}
    	
    	if (parameters.get(NISSAN_COMMENTS) != null) {
    		comments = parameters.get(NISSAN_COMMENTS);
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
		personAccount.LastName = lastName;
		personAccount.Twitter_Handle__c = twitterName;
		personAccount.PersonMailingStreet = address1;
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
		try{
		Case postedCase = new Case();
		postedCase.OwnerId = getCaseOwner(hdnQuestionText);
		postedCase.RecordTypeId = getCaseRecordType(hdnQuestionText);
		postedCase.Origin = CASE_ORIGIN;
		postedCase.AccountId = accountId;
		postedCase.ContactId = [Select Id from Contact where AccountId =: accountId Limit 1].Id;
		postedCase.First_Name__c = firstName;
		postedCase.Last_Name__c = lastName;
		postedCase.SuppliedPhone = phone;
		postedCase.SuppliedEmail = emailAddress;
		postedCase.Description =  generateDescription();
		postedCase.Subject = hdnQuestionText;
		
		insert postedCase;
		}catch (Exception ex){
			System.debug('Exception occured');
		}
	}
	
	private String generateDescription() {
		String caseDescription = '';
		
		caseDescription += 'First Name: ' + 
			formatField(firstName) + STRING_BREAK;
		caseDescription += 'Last Name: ' + 
			formatField(lastName) + STRING_BREAK;
		caseDescription += 'Email Address: ' + 
			formatField(emailAddress) + STRING_BREAK;
		caseDescription += 'Twitter Name: ' + 
			formatField(twitterName) + STRING_BREAK;
		caseDescription += 'Street Address: ' + 
			formatField(address1) + STRING_BREAK;
		caseDescription += 'City: ' + 
			formatField(city) + STRING_BREAK;
		caseDescription += 'State: ' + 
			formatField(state) + STRING_BREAK;
		caseDescription += 'Zip: ' + 
			formatField(zip) + STRING_BREAK;
		caseDescription += 'Phone Number: ' + 
			formatField(phone) + STRING_BREAK;
		
		caseDescription += 'Is Nissan Owner: ' + 
			isNissanOwner + STRING_BREAK;
		caseDescription += 'VIN: ' + 
			formatField(vin) + STRING_BREAK;
		caseDescription += 'Dealer Name: ' + 
			formatField(dealerName) + STRING_BREAK;
		caseDescription += 'Dealer State: ' + 
			formatField(dealerState) + STRING_BREAK;
		caseDescription += 'Subject: ' + 
			formatField(hdnQuestionText) + STRING_BREAK;
		caseDescription += 'Comments: ' + 
			formatField(comments) + STRING_BREAK;
		
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
	private String getCaseOwner(String subject) {
		QueueSobject currentQueue;
		
		if (subject == 'Nissan Products') {
			currentQueue = [SELECT QueueId 
				FROM QueueSobject 
				WHERE Queue.Name = :QUEUE_NISSAN_CCC];
		}
		else if (subject == 'Nissan LEAF') {
			currentQueue = [SELECT QueueId 
				FROM QueueSobject 
				WHERE Queue.Name = :QUEUE_NISSAN_LEAF];
		}
		else {
			currentQueue = [SELECT QueueId 
				FROM QueueSobject 
				WHERE Queue.Name = :QUEUE_NISSAN_CA];
		}
		
		return currentQueue.QueueId;
	}
	
	// It gets the case record type according to the selected topic
	private String getCaseRecordType(String subject) {
		RecordType caseRecordType;
		
		if (subject == 'Nissan Products') {
			caseRecordType = [SELECT Id 
				FROM RecordType 
				WHERE DeveloperName = 'CCC'
				AND SobjectType = 'Case'];
		}
		else if (subject == 'Nissan LEAF') {
			caseRecordType = [SELECT Id 
				FROM RecordType 
				WHERE DeveloperName = 'LEAF'
				AND SobjectType = 'Case'];
		}
		else {
			caseRecordType = [SELECT Id 
				FROM RecordType 
				WHERE DeveloperName = 'CA_Email_Nissan'
				AND SobjectType = 'Case'];
		}
		
		return caseRecordType.Id;
	}		
	
}