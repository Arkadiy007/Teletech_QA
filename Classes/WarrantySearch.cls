/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller for the Techline Case Search

Class:              WarrantySearch
Author:				Rohdenburg S.
Date:               03/06/2014
Version:            1.0
Last Updated:       03/06/2014
    * 03/06/2014	SR - Created
    * 03/14/2014	SR - Test implementation
*/

public class WarrantySearch
{
	// -------- Constants --------
	private final String RECORD_TYPE_TECH_LINE = 'TECH LINE Cases';
	private final String RECORD_TYPE_DEALER = 'Dealer';
	private final String ERROR_UNKNOWN_DEALER = '* The Dealer Code is invalid';
	private final String ERROR_CASE_NUMBER = '* The Case Number is invalid';
	
	// -------- Constructor --------
    public WarrantySearch(){
    	setInitialParameters();
    }

    // -------- Variables --------
	private ValidationUtility datacheck = new ValidationUtility();
	
	// -------- Properties --------
	public Vehicle__c paramVehicle {get; set;}
	public Account paramAccount {get; set;}
	public String caseNumber {get; set;}
	public String errorMessage {get; set;}
	public Boolean showVehicleSection {get; set;}
	public Boolean showVehicleRelatedCases {get; set;}
	public Boolean showDealerSection {get; set;}
	public Boolean showDealerRelatedCases {get; set;}
	public Boolean showErrorMessage {get; set;}
	public List<Account> dealers {get; set;}
	public List<Case> vehicleRelatedCases {get; set;}
	public List<Case> dealerRelatedCases {get; set;}
	public Boolean redirectToPage {get; set;}
	public String redirectURL {get; set;}
	
	// -------- Methods --------
	// It sets the values of the variables when the form is loaded
	public void setInitialParameters() {
		paramVehicle = new Vehicle__c();
    	paramAccount = new Account();
    	caseNumber = '';
	}
	
	// It search for the dealer code
	public void searchWarranty()
	{
    	showErrorMessage = false;
    	redirectToPage = false;
    	
    	if (!validateParameters()) {
    		showErrorMessage = true;
			return;
    	}
		
		if (!datacheck.IsStringNullOrEmpty(caseNumber)) {
			redirectToAnExistingCase();
		}
		else {
			searchDealer();
			searchVehicle();
        }
	}
	
	// It checks the values of the filters
	private Boolean validateParameters() {
		if (datacheck.IsStringNullOrEmpty(paramAccount.Dealer_Code__c) &&
			datacheck.IsStringNullOrEmpty(paramVehicle.Name) &&
			datacheck.IsStringNullOrEmpty(caseNumber)) {
			errorMessage = '* Please enter a value for performing the search';
			return false;
		}
		
		return true;
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
	
	// It searches for Dealer using the Dealer Code
	private void searchDealer() {
		showDealerSection = false;
		showDealerRelatedCases = false;
		
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
			showDealerSection = true;
			searchRelatedCasesToTheDealer(dealers[0].Id);
		}
	}
	
	// It searches for the Vehicle using the VIN
	private void searchVehicle() {
		showVehicleSection = false;
		showVehicleRelatedCases = false;
		
		if (!datacheck.IsStringNullOrEmpty(paramVehicle.Name)) {
			List<Vehicle__c> vehicles = [SELECT Id, Name,
				Model_Year__c, Model_Line_Name__c , Make_Name__c,
				Open_Recall__c, Branded_Title__c, OwnerId
				FROM Vehicle__c
				WHERE Name = :paramVehicle.Name];
				
			if (vehicles != null && vehicles.size() > 0) {
				paramVehicle = vehicles[0];
				showVehicleSection = true;
				
				searchRelatedCasesToTheVIN(vehicles[0].Id);
			}
		}
	}
	
	// It searches for the Cases related to the VIN
	private void searchRelatedCasesToTheVIN(Id vehicleId) {
		vehicleRelatedCases = [SELECT Id, CaseNumber, Subject, Description,
			CreatedDate, ClosedDate, RecordType.Name
			FROM Case
			WHERE Vehicle_Name__c = :vehicleId
			AND RecordType.Name IN ('TECH LINE Cases', 'CA', 
			'CA Email Infiniti','CA Email Nissan', 'T5', 
			'Roadside Assistance', 'CA Closed Case', 'DPIC', 'Warranty')
			ORDER BY CaseNumber DESC
			LIMIT 10];
		
		showVehicleRelatedCases = vehicleRelatedCases != null && 
			vehicleRelatedCases.size() > 0;
	}
	
	// It searches for the Cases related to the VIN
	private void searchRelatedCasesToTheDealer(Id dealerId) {
		dealerRelatedCases = [SELECT Id, CaseNumber, Subject, Description,
			CreatedDate, ClosedDate, RecordType.Name
			FROM Case
			WHERE Dealer__c = :dealerId
			AND RecordType.Name = 'Warranty'
			ORDER BY CaseNumber DESC
			LIMIT 10];
		
		showDealerRelatedCases = dealerRelatedCases != null && 
			dealerRelatedCases.size() > 0;
	}
	
	// It clears the values entered in the page
	public void clear() {
		setInitialParameters();
		showErrorMessage = false;
    	redirectToPage = false;
    	showDealerSection = false;
		showDealerRelatedCases = false;
		showVehicleSection = false;
		showVehicleRelatedCases = false;
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		WarrantySearch ws = new WarrantySearch();
		
		//Insert test records
		Case c1 = new Case();
		c1.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(
				ws.RECORD_TYPE_TECH_LINE).getRecordTypeId();
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
		
		// Search with blank values
		ws.searchWarranty();
		System.assert(ws.showErrorMessage);
		
		// Search with an invalid caseNumber
		ws.caseNumber = '1111';
		ws.searchWarranty();
		System.assert(ws.showErrorMessage);
		
		// Search by a valid caseNumber
		ws.caseNumber = c1.CaseNumber;
		ws.searchWarranty();
		System.assert(!ws.showErrorMessage);
		
		// Search by Unknow Dealer
		ws.caseNumber = null;
		ws.paramAccount.Dealer_Code__c = 'XXXXX';
		ws.searchWarranty();
		System.assert(!ws.showDealerSection);
		
		// Search by a valid Dealer
		ws.paramAccount.Dealer_Code__c = '1234';
		ws.searchWarranty();
		System.assert(ws.showDealerSection);
		
		// Search by an invalid VIN
		ws.paramAccount.Dealer_Code__c = null;
		ws.paramVehicle.Name = 'ZZZZZZZZ';
		ws.searchWarranty();
		System.assert(!ws.showDealerSection);
		System.assert(!ws.showVehicleSection);
		
		// Search by an invalid VIN
		ws.paramAccount.Dealer_Code__c = null;
		ws.paramVehicle.Name = 'JN8AZ1FY5CW100145';
		ws.searchWarranty();
		System.assert(!ws.showDealerSection);
		System.assert(ws.showVehicleSection);		
		
		// General Tests
		ws.clear();
	}
}