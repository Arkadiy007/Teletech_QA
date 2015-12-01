/**********************************************************************
Name: Controller_CACaseSearch
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Controller of CA Case Search page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 03/20/2011 Created
***********************************************************************/
public with sharing class Controller_CACaseSearch {
	private static final String NO_CRITERIA = 'Please provide search criteria.';
	private static final String NO_ROW_FOUND = 'No record is found with your input.';
	private static final String MANY_ROWS_FOUND = 'More than 1000 records are returned.';
	private static final String END_DATE_BEFORE_START_DATE = 'End Date cannot be before Start Date';
	private static final Integer DATE_RANGE_SIZE = 90;
	private static final string DATE_RANGE_TOO_LARGE = 'Date range cannot be larger than ' + DATE_RANGE_SIZE + ' days.';

    public String caseNumber { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String vehicle { get; set; }
    public Case inputCase { get; set; }

	public Controller_CACaseSearch() {
		inputCase = new Case();
		inputCase.Date_Email_Received__c = getDefaultStartDate();
		inputCase.Date_Email_Responded__c = getDefaultEndDate();
		
		System.debug(inputCase.Date_Email_Received__c);
	}

	// Default Start Date DATE_RANGE_SIZE days prior to today
	private Date getDefaultStartDate() {
		Date defaultStartDate = Date.today();
		defaultStartDate = defaultStartDate.addDays(-DATE_RANGE_SIZE);
		
		return defaultStartDate;
	}
	
	// Default End Date today
	private Date getDefaultEndDate() {
		return Date.today();
	}

    public List<Case> SearchResults {
    	get {
    		if (SearchResults == null)
    			SearchResults = new List<Case>();
    		return SearchResults;
    	}
    	set; 
	}
	
	// Build query string from inputs
    private String populateQuery() 
    {
    	String strWhere = '';
    	Date startDate;
    	Date endDate;
    	String startDateString;
    	String endDateString;

    	// Append Case Number criterion to where clause
    	if (caseNumber != null && caseNumber != '') {
    		String numberCaseNumber;
    		String caCaseNumber; 
    		if (caseNumber.startsWith('CA')) {
    			caCaseNumber = caseNumber;
    			numberCaseNumber = caseNumber.substring(2,caseNumber.length());
    		} else {
    			numberCaseNumber = caseNumber;
    			caCaseNumber = 'CA' + caseNumber;
    		}
    		
			strWhere = strWhere + ' and (CaseNumber = \'' + String.escapeSingleQuotes(numberCaseNumber) + '\'';
			strWhere = strWhere + ' or Legacy_Case_Number__c = \'' + String.escapeSingleQuotes(caCaseNumber) + '\')';
    	}

    	// Append First Name criterion to where clause
    	if (firstName != null && firstName != '') {
			strWhere = strWhere + ' and (Account.FirstName = \'' + String.escapeSingleQuotes(firstName) + '\'';
			strWhere = strWhere + ' or First_Name__c = \'' + String.escapeSingleQuotes(firstName) + '\')';
    	}

    	// Append Last Name criterion to where clause
    	if (lastName != null && lastName != '') {
			strWhere = strWhere + ' and (Account.LastName = \'' + String.escapeSingleQuotes(lastName) + '\'';
			strWhere = strWhere + ' or Last_Name__c = \'' + String.escapeSingleQuotes(lastName) + '\')';
    	}

    	// Append City criterion to where clause
    	if (city != null && city != '') {
			strWhere = strWhere + ' and (Account.PersonMailingCity = \'' + String.escapeSingleQuotes(city) + '\'';
			strWhere = strWhere + ' or Mailing_City__c = \'' + String.escapeSingleQuotes(city) + '\')';
    	}

    	// Append State criterion to where clause
    	if (state != null && state != '') {
			strWhere = strWhere + ' and (Account.PersonMailingState = \'' + String.escapeSingleQuotes(state) + '\'';
			strWhere = strWhere + ' or Mailing_State__c = \'' + String.escapeSingleQuotes(state) + '\')';
    	}

    	// Append Zip criterion to where clause
    	if (zip != null && zip != '') {
			strWhere = strWhere + ' and (Account.PersonMailingPostalCode = \'' + String.escapeSingleQuotes(zip) + '\'';
			strWhere = strWhere + ' or Mailing_Zip_Code__c = \'' + String.escapeSingleQuotes(zip) + '\')';
    	}

		// Append Vehicle criterion to where clause
        if (vehicle != null && vehicle != '')
 			strWhere = strWhere + ' and Vehicle_Name__r.Name = \'' + String.escapeSingleQuotes(vehicle) + '\'';

    	// Append Begin/End Date criteria to where clause
    	startDate = inputCase.Date_Email_Received__c;
    	endDate = inputCase.Date_Email_Responded__c;
		startDateString = Text_Util.getSoqlFormattedDate(startDate);
		endDateString = Text_Util.getSoqlFormattedDate(endDate);

		if (endDate < startDate) {
			System.debug('end date less than start date ' + endDate + ' > ' + startDate);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, END_DATE_BEFORE_START_DATE));
		}
		if (startDate.daysBetween(endDate) > DATE_RANGE_SIZE) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DATE_RANGE_TOO_LARGE));
		}

		strWhere = strWhere + ' and CreatedDate >= ' + startDateString;
		strWhere = strWhere + ' and CreatedDate <= ' + endDateString;

    	return strWhere;
    }

    public PageReference searchAction() {
        SearchResults.clear();

		// Get query statement
		String strWhere = populateQuery();
		if (ApexPages.hasMessages()) {
			return null;
		}
		
		// No criteria are provided, will show error
		if (strWhere == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_CRITERIA));
			return null;
		}
		System.debug('Running Query for Where Clause: ' + strWhere);

    	String strSearch = 'Select count(Id) counts From Case where RecordType.Name in (\'CA\',\'CA Closed Case\',\'CA Email Nissan\',\'CA Email Infiniti\',\'T5\',\'Roadside Assistance\')' + strWhere;
		AggregateResult[] groupedResults = Database.query(strSearch);
		if (Integer.ValueOf(groupedResults[0].get('counts')) > 1000) {  	// too many rows are found
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, MANY_ROWS_FOUND));
			return null;
		}

    	strSearch = 'Select ID, CaseNumber, DocumentId__c, Account.FirstName, Account.LastName, Account.PersonMailingCity, Account.PersonMailingState, Account.PersonMailingPostalCode, Vehicle_Name__r.Name ' +
    	            'From Case where RecordType.Name in (\'CA\',\'CA Closed Case\',\'CA Email Nissan\',\'CA Email Infiniti\',\'T5\',\'Roadside Assistance\')' + strWhere + ' ORDER BY DocumentId__c';
    	System.debug('Running Query for Search: ' + strSearch);
    	SearchResults = database.query(strSearch);

		Integer recordCounts = SearchResults.size();
		
		// If only 1 row is found, redirect to the detail page
		if(recordCounts == 1)
			return new ApexPages.standardController(new Case(ID=SearchResults[0].ID)).view();
		else if (recordCounts == 0)			// no row is found
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, NO_ROW_FOUND));

        return null;
    }

    public Boolean ShowResultList {
		get {
			return !ApexPages.hasMessages();
		}
    }
    
    static testMethod void TestCaseSearch() {
        RecordType maritzTypeRT = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
        RecordType caTypeRT = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
    	PageReference objPageRef = Page.CACaseSearch;
		Controller_CACaseSearch objController;
		String strURL;

    	State__c state = new State__c(Name = 'AK', Name__c = 'Alaska', Order__c = 1);
    	insert state;

		Account acct = new Account(FirstName = 'First', LastName = 'Last', PersonMailingCity = 'City', PersonMailingState= 'AK',
		                           PersonMailingPostalCode = '12345', RecordTypeId = maritzTypeRT.Id);
		insert acct;
		
		Vehicle__c v = new Vehicle__c(Vehicle_Identification_Number__c = '1N345678901234567',
									  Name = '1N345678901234567',
									  Model_Year__c = '2009',
									  Make_Name__c = 'MakeName',
									  Model_Line_Name__c = 'ModelLineName');
		insert v;

		Case c = new Case(AccountId = acct.Id,
						  Vehicle_Name__c = v.Id,
						  RecordTypeId = caTypeRT.Id);
		insert c;
		
		c = [select Id, DocumentId__c
		     from case
		     where id = :c.Id];


    	Test.setCurrentPage(objPageRef);
    	objController = new Controller_CACaseSearch();

    	Test.startTest();
    	
		//test 1 row found
		objController.caseNumber = c.DocumentId__c;
		objController.firstName = 'First';
		objController.lastName = 'Last';
		objController.city = 'City';
		objController.state = 'AK';
		objController.zip = '12345';
		objController.vehicle = '1N345678901234567';
    	PageReference p = objController.searchAction();
		cleanTestInput(objController);

    	Test.stopTest();
    }
    
    private static void cleanTestInput(Controller_CACaseSearch objController) {
    	objController.caseNumber = null;
    	objController.firstName = null;
    	objController.lastName = null;
    	objController.vehicle = null;
    }
}