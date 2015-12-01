/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller for managing the Post of the external Notor page

Class:              Notor_Post
Author:				Rohdenburg S.
Date:               05/05/14
Version:            1.0
Last Updated:       07/16/14
    * 05/05/14		SR - Created as POC
    * 05/09/14		SR - Included all the fields
    * 07/16/14		SR - Added new fields
*/

public class Notor_Post
{
	// -------- Constants --------
	private final String PARAM_USER_NOTOR_ID = 'notorId';
	private final String PARAM_FIRST_NAME = 'firstName';
	private final String PARAM_LAST_NAME = 'lastName';
	private final String PARAM_HOME_PHONE = 'homePhoneNumber';
	private final String PARAM_MOBILE_PHONE = 'mobilePhoneNumber';
	private final String PARAM_BUSINESS_PHONE = 'businessPhoneNumber';
	private final String PARAM_EMAIL = 'emailAddress';
	private final String PARAM_COMPANY = 'company';
	private final String PARAM_ADDRESS = 'address';
	private final String PARAM_ADDRESS_2 = 'address2';
	private final String PARAM_CITY = 'city';
	private final String PARAM_STATE = 'state';
	private final String PARAM_ZIP_CODE = 'zipCode';
	private final String PARAM_ACCOUNT_NUMBER = 'accountNumber';
	private final String PARAM_DEALER_CODE = 'dealerCode';
	private final String PARAM_DEALER_NAME = 'dealerName';
	private final String PARAM_ADMIN_NAME = 'administratorName';
	private final String PARAM_ADMIN_PHONE = 'administratorPhone';
	private final String PARAM_ADMIN_EMAIL = 'administratorEmail';
	private final String PARAM_SPECIALIST_NAME = 'specialistName';
	private final String PARAM_SPECIALIST_PHONE = 'specialistPhoneNumber';
	private final String PARAM_SPECIALIST_EMAIL = 'specialistEmail';
	private final String PARAM_SALES_AMOUNT = 'salesAmount';
	private final String PARAM_SERVICE_AMOUNT = 'serviceAmount';
	
	// -------- Constructor --------
    public Notor_Post(){
    	retrieveParameterValues();
    }

    // -------- Variables --------
	private ValidationUtility datacheck = new ValidationUtility();
	
	// -------- Properties --------
	public String userNotorId {get; set;}
	public String firstName {get; set;}
	public String lastName {get; set;}
	public String homePhoneNumber {get; set;}
	public String mobilePhoneNumber {get; set;}
	public String businessPhoneNumber {get; set;}
	public String emailAddress {get; set;}
	public String company {get; set;}
	public String address {get; set;}
	public String address2 {get; set;}
	public String city {get; set;}
	public String state {get; set;}
	public String zipCode {get; set;}
	public String accountNumber {get; set;}
	public String dealerCode {get; set;}
	public String dealerName {get; set;}
	public String administratorName {get; set;}
	public String administratorPhone {get; set;}
	public String administratorEmail {get; set;}
	public String specialistName {get; set;}
	public String specialistPhone {get; set;}
	public String specialistEmail {get; set;}
	public String salesAmount {get; set;}
	public String serviceAmount {get; set;}
	
	// -------- Methods --------
	// This method collects the value of the POST parameters  
	private void retrieveParameterValues() {
		Map<String,String> parameters = ApexPages.currentPage().getParameters();
		
		if (parameters.get(PARAM_USER_NOTOR_ID) != null) {
    		userNotorId = parameters.get(PARAM_USER_NOTOR_ID);
    	}
		
		if (parameters.get(PARAM_FIRST_NAME) != null) {
    		firstName = parameters.get(PARAM_FIRST_NAME);
    	}
    	
    	if (parameters.get(PARAM_LAST_NAME) != null) {
    		lastName = parameters.get(PARAM_LAST_NAME);
    	}
    	
    	if (parameters.get(PARAM_HOME_PHONE) != null) {
    		homePhoneNumber = parameters.get(PARAM_HOME_PHONE);
    	}
    	
    	if (parameters.get(PARAM_MOBILE_PHONE) != null) {
    		mobilePhoneNumber = parameters.get(PARAM_MOBILE_PHONE);
    	}
    	
    	if (parameters.get(PARAM_BUSINESS_PHONE) != null) {
    		businessPhoneNumber = parameters.get(PARAM_BUSINESS_PHONE);
    	}
    	
    	if (parameters.get(PARAM_EMAIL) != null) {
    		emailAddress = parameters.get(PARAM_EMAIL);
    	}
    	
    	if (parameters.get(PARAM_COMPANY) != null) {
    		company = parameters.get(PARAM_COMPANY);
    	}
    	
    	if (parameters.get(PARAM_ADDRESS) != null) {
    		address = parameters.get(PARAM_ADDRESS);
    	}
    	
    	if (parameters.get(PARAM_ADDRESS_2) != null) {
    		address2 = parameters.get(PARAM_ADDRESS_2);
    	}
    	
    	if (parameters.get(PARAM_CITY) != null) {
    		city = parameters.get(PARAM_CITY);
    	}
    	
    	if (parameters.get(PARAM_STATE) != null) {
    		state = parameters.get(PARAM_STATE);
    	}
    	
    	if (parameters.get(PARAM_ZIP_CODE) != null) {
    		zipCode = parameters.get(PARAM_ZIP_CODE);
    	}
    	
    	if (parameters.get(PARAM_ACCOUNT_NUMBER ) != null) {
    		accountNumber = parameters.get(PARAM_ACCOUNT_NUMBER );
    	}
    	
    	if (parameters.get(PARAM_DEALER_CODE) != null) {
    		dealerCode = parameters.get(PARAM_DEALER_CODE);
    	}
    	
    	if (parameters.get(PARAM_DEALER_NAME) != null) {
    		dealerName = parameters.get(PARAM_DEALER_NAME);
    	}
    	
    	if (parameters.get(PARAM_ADMIN_NAME) != null) {
    		administratorName = parameters.get(PARAM_ADMIN_NAME);
    	}
    	
    	if (parameters.get(PARAM_ADMIN_PHONE) != null) {
    		administratorPhone = parameters.get(PARAM_ADMIN_PHONE);
    	}
    	
    	if (parameters.get(PARAM_ADMIN_EMAIL) != null) {
    		administratorEmail = parameters.get(PARAM_ADMIN_EMAIL);
    	}
    	
    	if (parameters.get(PARAM_SPECIALIST_NAME) != null) {
    		specialistName = parameters.get(PARAM_SPECIALIST_NAME);
    	}
    	
    	if (parameters.get(PARAM_SPECIALIST_PHONE) != null) {
    		specialistPhone = parameters.get(PARAM_SPECIALIST_PHONE);
    	}
    	
    	if (parameters.get(PARAM_SPECIALIST_EMAIL) != null) {
    		specialistEmail = parameters.get(PARAM_SPECIALIST_EMAIL);
    	}
    	
    	if (parameters.get(PARAM_SALES_AMOUNT) != null) {
    		salesAmount = parameters.get(PARAM_SALES_AMOUNT);
    	}
    	
    	if (parameters.get(PARAM_SERVICE_AMOUNT) != null) {
    		serviceAmount = parameters.get(PARAM_SERVICE_AMOUNT);
    	}
	}
	
	//It submits the Notor
	public void submitNotor() {
		try {
			Notor__c currentNotor = new Notor__c();
			
			if (!datacheck.IsStringNullOrEmpty(userNotorId)) {
				List<User> informedUser = [SELECT Id FROM User 
					WHERE Notor_Id__c = :userNotorId]; 
				
				if (informedUser != null && informedUser.size() > 0) {
					currentNotor.OwnerId = informedUser[0].Id;	
				}
			}
			
			currentNotor.First_Name__c = firstName;
			currentNotor.Last_Name__c = lastName;
			currentNotor.Home_Phone_Number__c = homePhoneNumber;
			currentNotor.Mobile_Phone_Number__c = mobilePhoneNumber;
			currentNotor.Business_Phone_Number__c = businessPhoneNumber;
			currentNotor.Email_Address__c = emailAddress;
			currentNotor.Company__c = company;
			currentNotor.Address__c = address;
			currentNotor.Address_2__c = address2;
			currentNotor.City__c = city;
			currentNotor.State__c = state;
			currentNotor.Zip_Code__c = zipCode;
			currentNotor.Account_Number__c = accountNumber;
			currentNotor.Dealer_Code__c = dealerCode;
			currentNotor.Dealer_Name__c = dealerName;
			currentNotor.Dealership_Administrator_Name__c = administratorName;
			currentNotor.Dealership_Administrator_Phone__c = administratorPhone;
			currentNotor.Dealership_Administrator_Email__c = administratorEmail;
			currentNotor.Customer_Retention_Specialist_Name__c = specialistName;
			currentNotor.Customer_Retention_Specialist_Phone__c = specialistPhone;
			currentNotor.Customer_Retention_Specialist_Email__c = specialistEmail;
			
			if (!datacheck.IsStringNullOrEmpty(salesAmount)) {
				currentNotor.Sales_Amount__c = Decimal.valueOf(salesAmount);	
			}
			else {
				currentNotor.Sales_Amount__c = 0;
			}
			
			if (!datacheck.IsStringNullOrEmpty(serviceAmount)) {
				currentNotor.Service_Amount__c = Decimal.valueOf(serviceAmount);
			}
			else {
				currentNotor.Service_Amount__c = 0;
			}
			
			insert currentNotor;
			
			ApexPages.Message msg = new ApexPages.Message(
				ApexPages.Severity.INFO, 'A new NOTOR record has been successfully created');
		    ApexPages.addMessage(msg);
		    
		    /*ApexPages.Message msg = new ApexPages.Message(
				ApexPages.Severity.WARNING, 'Posted First Name: ' + firstName);
		    ApexPages.addMessage(msg);*/
	    }
		catch (Exception ex) {
			ApexPages.Message msg = new ApexPages.Message(
				ApexPages.Severity.ERROR, ex.getMessage());
		    ApexPages.addMessage(msg);
		}
	}
	
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		
	}
}