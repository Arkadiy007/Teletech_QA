/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller for the Techline Case Search

Class:              Techline_DetailedCaseSearch
Author:				Rohdenburg S.
Date:               01/23/2014
Version:            1.0
Last Updated:       03/25/2014
    * 01/23/2014	SR - Created
    * 03/13/2014	SR - Changed the field validations
    * 03/25/2014	SR - Autopopulated the Customer Name field
*/

public class Techline_CaseCreation
{
	// -------- Constants --------
	private final String RECORD_TYPE_TECH_LINE = 'TECH LINE Cases';
	private final String RECORD_TYPE_DEALER = 'Dealer';
	private final String ERROR_UNKNOWN_DEALER = '* The Dealer Code is invalid';
	private final String ERROR_CASE_NUMBER = '* The Case Number is invalid';
	private final String FIELD_DEALER = '00NF0000008Mvxy';
	private final String FIELD_VEHICLE = '00NA00000070W35';
	private final String FIELD_VIN = '00NA0000007h1yM';
	private final String FIELD_CURRENT_MILEAGE = '00NF0000008NMHH';
	private final String FIELD_ARCH_MAKE = '00NF0000008Mw2A';
	private final String FIELD_ARCH_MODEL = '00NF0000008Mw25';
	private final String FIELD_ARCH_YEAR = '00NF0000008Mvy9';
	private final String FIELD_ACCOUNT = 'cas4';
	private final String FIELD_CUSTOMER_NAME = '00NF0000008NeII';
	
	/* // QA Environment 
	private final String FIELD_CALLER_NAME = '00NZ0000001G3kS';
	private final String FIELD_DTS_FULL_NAME = '00NZ0000001GSEH';
	private final String FIELD_DTS_EMAIL = '00NZ0000001GSEM';
	private final String FIELD_DTS_CELL_PHONE = '00NZ0000001GSBn';
	private final String FIELD_DTS_OFFICE_PHONE = '00NZ0000001GSER';
	*/
	
	/* SCC - PROD Environments */ 
	private final String FIELD_CALLER_NAME = '00NF0000008sF4r';
	private final String FIELD_DTS_FULL_NAME = '00NF0000008sF9C';
	private final String FIELD_DTS_EMAIL = '00NF0000008sF4t';
	private final String FIELD_DTS_CELL_PHONE = '00NF0000008sF4s';
	private final String FIELD_DTS_OFFICE_PHONE = '00NF0000008sF4u';
	
	// -------- Constructor --------
    public Techline_CaseCreation(){
    	setInitialParameters();
    }

    // -------- Variables --------
	private ValidationUtility datacheck = new ValidationUtility();
	
	// -------- Properties --------
	public Case paramCase {get; set;}
	public Vehicle__c paramVehicle {get; set;}
	public Account paramAccount {get; set;}
	public String caseNumber {get; set;}
	public String errorMessage {get; set;}
	public Boolean showVehicleDetails {get; set;}
	public Boolean showDealerDetails {get; set;}
	public Boolean showRelatedCases {get; set;}
	public Boolean showErrorMessage {get; set;}
	public List<Account> dealers {get; set;}
	public List<Case> relatedCases {get; set;}
	public String selectedDealerId {get; set;}
	private String techlineId {get; set;}
	public Boolean redirectToPage {get; set;}
	public String redirectURL {get; set;}
	private Vehicle_Ownership_History__c lastOwner {get; set;}
	public Vehicle__c selectedVehicle {get; set;}
	
	// -------- Methods --------
	// It sets the values of the variables when the form is loaded
	public void setInitialParameters() {
		techlineId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(
				RECORD_TYPE_TECH_LINE).getRecordTypeId();
		
		paramCase = new Case();
    	paramCase.RecordTypeId = techlineId;
    	paramVehicle = new Vehicle__c();
    	paramAccount = new Account();
    	selectedVehicle = new Vehicle__c();
    	
    	showErrorMessage = false;
	}
	
	// It search for the dealer code
	public void searchDealerCase()
	{
    	showErrorMessage = false;
    	redirectToPage = false;
		
		if (!datacheck.IsStringNullOrEmpty(caseNumber)) {
			redirectToAnExistingCase();
		}
		else {
			searchDealerAndVehicle();
        }
	}
	
	// It redirects to an existing Case
	private void redirectToAnExistingCase() {
	 	List<Case> cases = [SELECT Id
			FROM Case
			WHERE CaseNumber = :caseNumber];
			
		if (cases != null && cases.size() > 0) {
			redirectURL = URL.getCurrentRequestUrl().toExternalForm();
			if (redirectURL.contains('/apex')) {
				redirectURL = redirectURL.substring(0, redirectURL.indexOf('/apex'));
				redirectURL += '/' + cases[0].Id;
				redirectToPage = true;	
			}			
		}
		else {
			errorMessage = ERROR_CASE_NUMBER;
			showErrorMessage = true;
		}
	}
	
	//It search for the Dealer and the Vehicle
	private void searchDealerAndVehicle() {
		if (!validateParameters()) {
			showErrorMessage = true;
			return;
		}
		
		showRelatedCases = false;
		
		searchDealer();
		searchVehicle();
	}
	
	// It checks the values of the filters
	private Boolean validateParameters() {
		/*if (datacheck.IsStringNullOrEmpty(paramAccount.Dealer_Code__c)) {
			errorMessage = '* Dealer Code is mandatory';
			return false;
		}*/
		
		if (datacheck.IsStringNullOrEmpty(paramAccount.Dealer_Code__c) &&
			datacheck.IsStringNullOrEmpty(paramVehicle.Name) &&
			datacheck.IsStringNullOrEmpty(caseNumber)) {
			errorMessage = '* Please enter a Dealer Code, a VIN, or a Case Number';
			return false;
		}
				
		if (!datacheck.IsStringNullOrEmpty(paramAccount.Dealer_Code__c) &&
			datacheck.IsStringNullOrEmpty(paramCase.Caller_Name__c)) {
			errorMessage = '* Caller Name is mandatory';
			return false;
		}
		
		return true;
	}
	
	// It searches for Dealer using the Dealer Code
	private void searchDealer() {
		showDealerDetails = false;
		
		if (datacheck.IsStringNullOrEmpty(paramAccount.Dealer_Code__c)) {
			return;
		}
		
		String dealerRecordTypeId = 
			Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
				RECORD_TYPE_DEALER).getRecordTypeId();
		
		dealers = [SELECT Id, Name, BillingStreet, BillingCity, BillingState,
			BillingPostalCode, Phone, DTS_A_Stage_User__r.Full_Name__c, 
			DTS_A_Stage_User__r.Email__c, DTS_A_Stage_User__r.Cell_Phone__c, 
			DTS_A_Stage_User__r.Office_Phone__c, Dealer_Inactive_Indicator__c
			FROM Account
			WHERE RecordTypeId = :dealerRecordTypeId
			AND Dealer_Code__c = :paramAccount.Dealer_Code__c];
		
		if (dealers != null && dealers.size() > 0) {
			showDealerDetails = true;
			showErrorMessage = false;
		}
		else {
			errorMessage = ERROR_UNKNOWN_DEALER;
			showErrorMessage = true;
		}
	}
	
	// It searches for the Vehicle using the VIN
	private void searchVehicle() {
		lastOwner = null;
		if (!datacheck.IsStringNullOrEmpty(paramVehicle.Name)) {
			List<Vehicle__c> vehicles = [SELECT Id, Name,
				Model_Year__c, Model_Line_Name__c , Make_Name__c,
				Open_Recall__c, Branded_Title__c, OwnerId
				FROM Vehicle__c
				WHERE Name = :paramVehicle.Name];
				
			if (vehicles != null && vehicles.size() > 0) {
				selectedVehicle = vehicles[0];
				showVehicleDetails = true;
				
				searchRelatedCases(vehicles[0].Id);
				lastOwner = searchLastOwner(vehicles[0].Id);
			}
			else {
				selectedVehicle = new Vehicle__c();
				showVehicleDetails = false;
			}
		}
		else {
			selectedVehicle = new Vehicle__c();
			showVehicleDetails = false;	
		}
	}
	
	// It searches for the Cases related to the VIN
	private void searchRelatedCases(Id vehicleId) {
		relatedCases = [SELECT Id, CaseNumber, Subject, Description, 
			CreatedDate, ClosedDate, RecordType.Name
			FROM Case
			WHERE Vehicle_Name__c = :vehicleId
			AND RecordType.Name IN ('TECH LINE Cases', 'CA', 
			'CA Email Infiniti','CA Email Nissan', 'T5', 
			'Roadside Assistance', 'CA Closed Case')
			ORDER BY CaseNumber DESC
			LIMIT 10];
		
		showRelatedCases = relatedCases != null && relatedCases.size() > 0;
	}
	
	// It redirects you to a new Case page with some auto-populated field
	public void selectDealer() {
		for (Account dealer : dealers) {
			if (dealer.Id == selectedDealerId) {
				redirectURL = getNewCaseURL(dealer, selectedVehicle);
				redirectToPage = true;
				break;
			}
		}
	}
	
	// It generates the New Case URL
	private String getNewCaseURL(Account dealer, Vehicle__c vehicle) {
		//TODO: Check the PROD Ids for the push
		String caseURL = URL.getCurrentRequestUrl().toExternalForm();
		if (caseURL.contains('/apex')) {
			caseURL = caseURL.substring(0, caseURL.indexOf('/apex'));	
		}
		caseURL += '/500/e?RecordType=' + techlineId;
		caseURL += '&CF' + FIELD_DEALER + '_lkid=' + dealer.Id;
		caseURL += '&CF' + FIELD_DEALER + '=' + dealer.Name;
		caseURL += '&' + FIELD_CALLER_NAME + '=' + paramCase.Caller_Name__c;
		
		if (paramCase.Current_Mileage__c != null) {
			caseURL += '&' + FIELD_CURRENT_MILEAGE + '=' + paramCase.Current_Mileage__c;	
		}
			
		if (vehicle.Make_Name__c != null) {
			caseURL += '&' + FIELD_ARCH_MAKE + '=' + vehicle.Make_Name__c;
		}
		
		if (vehicle.Model_Line_Name__c != null) {
			caseURL += '&' + FIELD_ARCH_MODEL + '=' + vehicle.Model_Line_Name__c;
		}
		
		if (vehicle.Model_Year__c != null) {
			caseURL += '&' + FIELD_ARCH_YEAR + '=' + vehicle.Model_Year__c;
		}
		
		if (lastOwner != null) {
			//caseURL += '&' + FIELD_ACCOUNT + '_lkid=' + lastOwner.Owner__r.Id;
			//caseURL += '&' + FIELD_ACCOUNT + '=' + lastOwner.Owner__r.Name;
			caseURL += '&' + FIELD_CUSTOMER_NAME + '=' + lastOwner.Owner__r.Name;
		}
		
		if (!datacheck.IsStringNullOrEmpty(vehicle.Name)) {
			if (showVehicleDetails) {
				caseURL += '&CF' + FIELD_VEHICLE + '_lkid=' + vehicle.Id;
				caseURL += '&CF' + FIELD_VEHICLE + '=' + vehicle.Name;
			}
			else {
				caseURL += '&' + FIELD_VIN + '=' + vehicle.Name;
			}
		}
		
		if (!datacheck.IsStringNullOrEmpty(
			dealer.DTS_A_Stage_User__r.Full_Name__c)) {
			caseURL += '&' + FIELD_DTS_FULL_NAME + '=' + 
				dealer.DTS_A_Stage_User__r.Full_Name__c;
		}
		
		if (!datacheck.IsStringNullOrEmpty(
			dealer.DTS_A_Stage_User__r.Email__c)) {
			caseURL += '&' + FIELD_DTS_EMAIL + '=' + 
				dealer.DTS_A_Stage_User__r.Email__c;
		}
		
		if (!datacheck.IsStringNullOrEmpty(
			dealer.DTS_A_Stage_User__r.Cell_Phone__c)) {
			caseURL += '&' + FIELD_DTS_CELL_PHONE + '=' + 
				dealer.DTS_A_Stage_User__r.Cell_Phone__c;
		}
		
		if (!datacheck.IsStringNullOrEmpty(
			dealer.DTS_A_Stage_User__r.Office_Phone__c)) {
			caseURL += '&' + FIELD_DTS_OFFICE_PHONE + '=' + 
				dealer.DTS_A_Stage_User__r.Office_Phone__c;
		}
		
		return caseURL;
	}
	
	// It searches the last owner of the informed Vehicle
	private Vehicle_Ownership_History__c searchLastOwner(Id vehicleId) {
		List<Vehicle_Ownership_History__c> owners = [SELECT Owner__r.Id,
			Owner__r.Name
			FROM Vehicle_Ownership_History__c
			WHERE Vehicle__c = :vehicleId
			ORDER BY End_Date__c DESC];
			
		if (owners != null && owners.size() > 0) {
			return owners[0]; 
		}
		else {
			return null;
		}
	}
	
	// It cleans all the page parameters
	public void clearParameters() {
		setInitialParameters();
		caseNumber = '';
		showVehicleDetails = false;
		showDealerDetails = false;
		showRelatedCases = false;
		
		dealers = new List<Account>();
		relatedCases = new List<Case>();
		lastOwner = null; 
		selectedDealerId = '';
		
		redirectToPage = false;
    	redirectURL = '';
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		Techline_CaseCreation cc = new Techline_CaseCreation();
		
		//Insert test records
		Case c1 = new Case();
		c1.RecordTypeId = cc.techlineId;
		c1.Type = 'FULL';
		insert c1;
		
		c1 = [SELECT CaseNumber
			FROM Case
			WHERE Id = :c1.Id];
			
		Account dealer = new Account();
		dealer.RecordTypeId = '012A0000000OfI0';
		dealer.Name = 'Sebastian';
		dealer.Dealer_Code__c = '1234';
		insert dealer;
		
		Vehicle__c veh = new Vehicle__c();
		veh.name = 'JN8AZ1FY5CW100145';
		veh.Model_Year__c = '2014';
		veh.Model_Line_Name__c = 'Altima';
		veh.Make_Name__c = 'Nissan';
		insert veh;
		
		// Search by an invalid caseNumber
		cc.caseNumber = '1111';
		cc.searchDealerCase();
		System.assert(cc.showErrorMessage);
		
		// Search by a valid caseNumber
		cc.caseNumber = c1.CaseNumber;
		cc.searchDealerCase();
		System.assert(!cc.showErrorMessage);
		
		// Search Dealer without the Code parameter
		cc.caseNumber = null;
		cc.paramAccount.Dealer_Code__c = null;
		cc.paramCase.Caller_Name__c = null;
		cc.searchDealerCase();
		System.assert(cc.showErrorMessage);
		
		// Search Dealer without the Caller parameter 
		cc.paramAccount.Dealer_Code__c = '1234';
		cc.paramCase.Caller_Name__c = null;
		cc.searchDealerCase();
		System.assert(cc.showErrorMessage);
		
		// Search by Unknow Dealer
		cc.paramAccount.Dealer_Code__c = 'XXXXX';
		cc.paramCase.Caller_Name__c = 'Sebastian';
		cc.searchDealerCase();
		System.assert(cc.showErrorMessage);
		
		// Search by a valid Dealer
		cc.paramAccount.Dealer_Code__c = '1234';
		cc.paramCase.Caller_Name__c = 'Sebastian';
		cc.searchDealerCase();
		System.assert(!cc.showErrorMessage);
		
		// Search by a valid Dealer and an invalid VIN
		cc.paramAccount.Dealer_Code__c = '1234';
		cc.paramCase.Caller_Name__c = 'Sebastian';
		cc.paramVehicle.Name = 'ZZZ';
		cc.searchDealerCase();
		System.assert(!cc.showErrorMessage);
		System.assert(!cc.showVehicleDetails);
		
		// Search with a valid Dealer and Vehicle
		cc.paramAccount.Dealer_Code__c = '1234';
		cc.paramCase.Caller_Name__c = 'Sebastian';
		cc.paramVehicle.Name = 'JN8AZ1FY5CW100145';
		cc.searchDealerCase();
		System.assert(!cc.showErrorMessage);
		System.assert(cc.showVehicleDetails);
		
		// Select a Dealer and create a new Case
		cc.selectedDealerId = dealer.Id;
		cc.selectDealer();
		
		// General Tests
		cc.clearParameters();
	}
}