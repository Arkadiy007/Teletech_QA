/**********************************************************************
Name: Controller_CaseSearch
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Controller of Case Search page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 02/27/2011 Created
***********************************************************************/
public with sharing class Controller_CaseSearch {
	public Controller_CaseSearch() {
	}
	
	private static final String NO_CRITERIA = 'Please provide search criteria.';
	private static final String NO_ROW_FOUND = 'No record is found with your input.';
	private static final String MANY_ROWS_FOUND = 'More than 1000 records are returned.';
	private static final String SECTION_TOO_LONG = 'Section cannot be longer than 3 characters.';

    public String caseNumber { get; set; }
    public String dealerCode { get; set; }
    public String vehicle { get; set; }
    public String modelYear { get; set; }
    public String modelLine { get; set; }
    public String modelSeries { get; set; }
    public String partNumber { get; set; }
    public String section { get; set; }
    public String keyPartCode { get; set; }
    public String keywords { get; set; }

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

    	// Append Case Number criterion to where clause
    	if (caseNumber != null && caseNumber != '')
			strWhere = strWhere + ' and Document_Id__c like \'%' + String.escapeSingleQuotes(caseNumber) + '%\'';

    	// Append Dealer Code criterion to where clause
    	if (dealerCode != null && dealerCode != '')
			strWhere = strWhere + ' and Account.Dealer_Code__c like \'%' + String.escapeSingleQuotes(dealerCode) + '%\'';

		// Append Vehicle criterion to where clause
        if (vehicle != null && vehicle != '')
 			strWhere = strWhere + ' and Vehicle_Name__r.Name like \'%' + String.escapeSingleQuotes(vehicle) + '%\'';

		// Append Model Year criterion to where clause
        if (modelYear != null && modelYear != '')
 			strWhere = strWhere + ' and Model_Year__c like \'%' + String.escapeSingleQuotes(modelYear) + '%\'';

		// Append Model criterion to where clause
        if (modelLine != null && modelLine != '')
 			strWhere = strWhere + ' and Model_Line__c like \'%' + String.escapeSingleQuotes(modelLine) + '%\'';

		// Append Model Series criterion to where clause
        if (modelSeries!= null && modelSeries != '')
 			strWhere = strWhere + ' and Model_Series__c like \'%' + String.escapeSingleQuotes(modelSeries) + '%\'';

		// Append Part Number criterion to where clause
        if (partNumber != null && partNumber != '')
 			strWhere = strWhere + ' and Part_Number_1__c like \'%' + String.escapeSingleQuotes(partNumber) + '%\'';

		// Append Section criterion to where clause
        if (section != null && section != '')
 			strWhere = strWhere + ' and Section__c like \'%' + String.escapeSingleQuotes(section) + '%\'';

		// Append Key Part Code criterion to where clause
        if (keyPartCode != null && keyPartCode != '')
 			strWhere = strWhere + ' and Key_Part_Code__c like \'%' + String.escapeSingleQuotes(keyPartCode) + '%\'';

		// Append Short Description criterion to where clause
        if (keywords != null && keywords != '')
 			strWhere = strWhere + ' and Short_Description__c like \'%' + String.escapeSingleQuotes(keywords) + '%\'';

    	return strWhere;
    }

    public PageReference searchAction() {
        SearchResults.clear();

		// Get query statement
		String strWhere = populateQuery();
		// No criteria are provided, will show error
		if (strWhere == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_CRITERIA));
			return null;
		}

		// Section cannot be longer than 3 characters
		if (section.length() > 3) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SECTION_TOO_LONG));
			return null;
		}

    	String strSearch = 'Select count(Id) counts From Case where RecordType.Name in (\'DPIC TSO\',\'DPIC Technical Escalation\',\'DPIC Supply Escalation\')' + strWhere;
		AggregateResult[] groupedResults = Database.query(strSearch);
		if (Integer.ValueOf(groupedResults[0].get('counts')) > 1000) {  	// too many rows are found
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, MANY_ROWS_FOUND));
			return null;
		}

    	strSearch = 'Select ID, CaseNumber, Document_Id__c, Account.Dealer_Code__c, Vehicle_Name__r.Name, Model_Year__c, Model_Line__c, ' +
    	                   'Model_Series__c, Part_Number_1__c, Section__c, Key_Part_Code__c, Short_Description__c ' +
    	            'From Case where RecordType.Name in (\'DPIC TSO\',\'DPIC Technical Escalation\',\'DPIC Supply Escalation\')' + strWhere + ' ORDER BY Document_Id__c';
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
        RecordType dealerTypeRT = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
        RecordType dpicTypeRT = [select id, name from recordtype where name = 'DPIC TSO' and sobjecttype = 'Case' limit 1];
    	PageReference objPageRef = Page.CaseSearch;
		Controller_CaseSearch objController;
		String strURL;

		Account acct = new Account(Name = 'Test Dealer', Dealer_Code__c = '12345', RecordTypeId = dealerTypeRT.Id);
		insert acct;
		
		Vehicle__c v = new Vehicle__c(Vehicle_Identification_Number__c = '1N345678901234567',
									  Name = '1N345678901234567',
									  Model_Year__c = '2009',
									  Make_Name__c = 'MakeName',
									  Model_Line_Name__c = 'ModelLineName');
		insert v;

		Case c = new Case(AccountId = acct.Id,
						  Vehicle_Name__c = v.Id,
						  Model_Series__c = '321',
						  Part_Number_1__c = '567',
						  Section__c = '789',
						  Key_Part_Code__c = '9876543210',
						  Short_Description__c = 'keykey',
						  RecordTypeId = dpicTypeRT.Id);
		insert c;
		
		c = [select Id, Document_Id__c
		     from case
		     where id = :c.Id];


    	Test.setCurrentPage(objPageRef);
    	objController = new Controller_CaseSearch();

    	Test.startTest();
    	
		//test 1 row found
		objController.caseNumber = c.Document_Id__c;
		objController.dealerCode = '12345';
		objController.vehicle = '1N345678901234567';
		objController.modelYear = '2009';
		objController.modelLine = 'Model';
		objController.modelSeries = '321';
		objController.partNumber = '567';
		objController.section = '789';
		objController.keyPartCode = '9876543210';
		objController.keywords = 'keykey';
    	PageReference p = objController.searchAction();
		cleanTestInput(objController);

    	Test.stopTest();
    }
    
    private static void cleanTestInput(Controller_CaseSearch objController) {
    	objController.caseNumber = null;
    	objController.vehicle = null;
    	objController.modelYear = null;
    	objController.modelLine = null;
    	objController.modelSeries = null;
    	objController.partNumber = null;
    	objController.section = null;
    	objController.keyPartCode = null;
    	objController.keywords = null;
    }
}