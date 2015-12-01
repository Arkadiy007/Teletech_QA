/**********************************************************************
Name: Controller_DealerSearch
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of Dealer Search page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 06/16/2011 Created
***********************************************************************/
public with sharing class Controller_DealerSearch {
	public Controller_DealerSearch() {
		ExcludeInactive = true;
	}
	
    public Boolean ExcludeInactive { get; set; }
	private static final String NO_CRITERIA = 'Please provide search criteria.';
	private static final String NO_ROW_FOUND = 'No record is found with your input.';
	private static final String MANY_ROWS_FOUND = 'More than 1000 records are returned.';

    public String Zip { get; set; }
    public String City { get; set; }
    public String Code { get; set; }
    public String DealerName { get; set; }
    public Boolean CommercialVehicle { get; set; }
    public Boolean GTR { get; set; }
    public Boolean Rental { get; set; }
    public Boolean ElectricVehicle { get; set; }
    public String SelectedState { get; set; }
    public String SelectedBrand { get; set; }
	
	//populate State dropdown list. the mapStateCodeDesc is for locating state full name by selected state code
	private Map<String, String> mapStateCodeDesc = new Map<String, String>();
    public List<SelectOption> StateList {
    	 get {
    	 	if (StateList == null) {
    	 		StateList = new List<SelectOption>();
    	 		StateList.add(new SelectOption('-1', ''));

    	 		List<State__c> states = [Select s.Order__c, s.Name__c, s.Name From State__c s ORDER BY s.Order__c];
    	 		for (State__c s : states) {
    	 			StateList.add(new SelectOption(s.Name, s.Name__c));
    	 			mapStateCodeDesc.put(s.Name, s.Name__c);
    	 		}
    	 	}
    	 	return StateList;
    	 }
    	 set;
   	}
   	
   	public List<SelectOption> BrandList{
   		get{
   			if(BrandList == null){
   				BrandList = new List<SelectOption>();
   				BrandList.add(new SelectOption('-1', '--None--'));
   				
   				List<String> bList = Label.Brand.split(';');
   				
   				for(String s : bList){
   					BrandList.add(new SelectOption(s, s));
   				}
   			}
   			return BrandList;   			
   		}
   		
   		set;
   	}

    public List<Account> SearchResults {
    	get {
    		if (SearchResults == null)
    			SearchResults = new List<Account>();
    		return SearchResults;
    	}
    	set; 
	}
	
	//build query string:
	// Find keyword in Name Field where:
	//	if City is provided, billingcity like '%somecity%''
	//	and if Zip is provided, billingpostalcode like '%somezip%''
	//	and if State is provided, billingstate = state_code or billingstate = state_full_name
	//	and if Code is provided, dealer_code = somecode
	//	and if any of the flags is checked, (flag1 = true or flag2 = true...)
    private String populateQuery() 
    {
    	String strWhere = '';
    	
        if (ExcludeInactive == true)
 			strWhere = strWhere + ' and Dealer_Inactive_Indicator__c = false';

    	//append Name criterion to where clause
    	if (DealerName != null && DealerName != '')
			strWhere = strWhere + ' and Name like \'%' + String.escapeSingleQuotes(DealerName) + '%\'';

		//append City criterion to where clause
    	if (City != null && City != '')
			strWhere = strWhere + ' and BillingCity like \'%' + String.escapeSingleQuotes(City) + '%\'';

		//append Zip criterion to where clause
        if (Zip != null && Zip != '')
 			strWhere = strWhere + ' and BillingPostalCode like \'%' + String.escapeSingleQuotes(Zip) + '%\'';
		
		if(SelectedBrand != '-1'){
			strWhere = strWhere + ' and Make_Name__c = \'' + SelectedBrand + '\'';
		}
		
		//append State criterion to where clause
        if (SelectedState != '-1')
 			strWhere = strWhere + ' and (BillingState = \'' + SelectedState + '\' or BillingState = \'' + String.escapeSingleQuotes(mapStateCodeDesc.get(SelectedState)) + '\')';

		//append Code criterion to where clause
        if (Code != null && Code != '')
 			strWhere = strWhere + ' and Dealer_Code__c = \'' + String.escapeSingleQuotes(Code) + '\'';

		//build flags checkbox fields or-list
		String strWhereCheck;
        if (ElectricVehicle == true)
 			strWhereCheck = ' Electric_Vehicle_Dealer__c = true';

        if (CommercialVehicle == true) {
 			if (strWhereCheck == null)
 				strWhereCheck = ' Nissan_Commercial_Vehicle_Dealer__c = true';
 			else
 				strWhereCheck = strWhereCheck + ' or Nissan_Commercial_Vehicle_Dealer__c = true';
        }

        if (GTR == true) {
 			if (strWhereCheck == null)
 				strWhereCheck = ' Nissan_GTR_Dealer__c = true';
 			else 
 				strWhereCheck = strWhereCheck + ' or Nissan_GTR_Dealer__c = true';
        }

        if (Rental == true) {
 			if (strWhereCheck == null)
 				strWhereCheck = ' Nissan_Rental_Car_Dealer__c = true';
 			else 
 				strWhereCheck = strWhereCheck + ' or Nissan_Rental_Car_Dealer__c = true';
        }
        
        //append flags criteria to where clause
        if (strWhereCheck != null)
 			strWhere = strWhere + ' and (' + strWhereCheck + ')';

    	return strWhere;
    }

    public PageReference searchAction() {
        SearchResults.clear();

		//get query statement
		String strWhere = populateQuery();
		//no criteria are provided, will show error
		if (strWhere == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_CRITERIA));
			return null;
		}

    	String strSearch = 'Select count(Id) counts From Account where RecordType.Name = \'Dealer\'' + strWhere;
		AggregateResult[] groupedResults = Database.query(strSearch);
		if (Integer.ValueOf(groupedResults[0].get('counts')) > 1000) {  	// too many rows are found
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, MANY_ROWS_FOUND));
			return null;
		}

    	strSearch = 'Select ID, Name, Dealer_Code__c, Make_name__c, BillingStreet, BillingState, BillingCity, BillingPostalCode, Phone, Electric_Vehicle_Dealer__c, Nissan_Commercial_Vehicle_Dealer__c, Nissan_GTR_Dealer__c, Nissan_Rental_Car_Dealer__c, Dealer_Inactive_Indicator__c From Account where RecordType.Name = \'Dealer\'' + strWhere + ' ORDER BY Name';
    	SearchResults = database.query(strSearch);

		Integer recordCounts = SearchResults.size();
		
		//only 1 row is found, redirect to the detail page
		if(recordCounts == 1)
			return new ApexPages.standardController(new Account(ID=SearchResults[0].ID)).view();
		else if (recordCounts == 0)			// no row is found
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, NO_ROW_FOUND));

        return null;
    }

    public Boolean ShowResultList {
		get {
			return !ApexPages.hasMessages();
		}
    }
    
    static testMethod void TestDealerSearch() {
    	//cope with current test code data access issue in SF. ---->
    	List<State__c> testStates = [Select Order__c, Name__c, Name From State__c Where Name in ('NY', 'VI')];
    	if (testStates.size() == 0) {
    		testStates = new List<State__c> {new State__c (Order__c = 99, Name__c = 'New York', Name = 'NY'), 
    													new State__c (Order__c = 98, Name__c = 'Virgin Islands', Name = 'VI')};
    		insert testStates;
    	}
    	//<----
        RecordType dealerTypeRT = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
    	PageReference objPageRef = Page.DealerSearch;
		Controller_DealerSearch objController;
		String strURL;

		List<Account> toCreate = new List<Account>();
		Account unique = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Unique Dealer');
		toCreate.add(unique);

		for (Integer i = 0; i < 200; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer ' + i);
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in City ' + i, BillingCity = 'Some Town');
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZip ' + i, BillingCity = 'Some Zip Town', BillingPostalCode = '07610');
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState ' + i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'NY');
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState ' + i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'New York');
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState EV ' + i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'VI', Electric_Vehicle_Dealer__c = true);
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState EV GTR ' + i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'VI', Electric_Vehicle_Dealer__c = true, Nissan_GTR_Dealer__c = true);
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState EV GTR LCV ' + i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'VI', Electric_Vehicle_Dealer__c = true, Nissan_GTR_Dealer__c = true, Nissan_Commercial_Vehicle_Dealer__c = true);
			toCreate.add(a);
		}

		for (Integer i = 0; i < 100; i++) {
			Account a = new Account(RecordTypeID = dealerTypeRT.ID, Name = 'The Dealer in CityZipState EV GTR LCV Rental ' + i, Dealer_Code__c = '56789'+i, BillingCity = 'Some Zip Town State', BillingPostalCode = '07610', BillingState = 'VI', Electric_Vehicle_Dealer__c = true, Nissan_GTR_Dealer__c = true, Nissan_Rental_Car_Dealer__c = true, Nissan_Commercial_Vehicle_Dealer__c = true);
			toCreate.add(a);
		}

    	insert toCreate;

    	Test.setCurrentPage(objPageRef);
    	objController = new Controller_DealerSearch();

    	Test.startTest();
    	//test state drop-down list
    	system.debug(objController.StateList);
    	//to cover when StateList already exists
    	system.assert(objController.StateList[0].getValue() == '-1');
    	objController.SelectedState = '-1';
    	objController.SelectedBrand = '-1';

    	//test no criteria provided
    	system.debug('Test --- No criteria provided');
    	objController.ExcludeInactive = false;
    	objController.searchAction();
		system.assert(objController.ShowResultList == false);
		system.assert(ApexPages.getMessages()[0].getDetail() == NO_CRITERIA);

		//test No row found
    	system.debug('Test --- No row found');
    	objController.Code = '12345';
    	objController.searchAction();
    	system.assert(objController.SearchResults.Size() == 0);
		system.assert(objController.ShowResultList == false);
		system.assert(ApexPages.getMessages()[1].getDetail() == NO_ROW_FOUND);
		cleanTestInput(objController);

		//test too many rows found 
		system.debug('Test --- too many rows are found');
		objController.ExcludeInactive = true;
    	objController.DealerName = 'Dealer';
    	objController.searchAction();
		system.assert(objController.ShowResultList == false);
		system.debug(ApexPages.getMessages());
		cleanTestInput(objController);

		//test 1 row found 
		//test search by combinations
		system.debug('Test --- search by combinations');
		objController.DealerName = 'Dealer';
		objController.Code = '567890';
    	objController.City = 'Town';
    	objController.SelectedState = 'VI';
    	objController.Zip = '07610';
    	objController.CommercialVehicle = true;
    	objController.GTR = true;
    	objController.ElectricVehicle = true;
    	objController.Rental = true;
    	PageReference p = objController.searchAction();
    	system.assert(objController.SearchResults.Size() == 1);
		system.debug('/' + objController.SearchResults[0].ID == p.getUrl());
		cleanTestInput(objController);

		//Test 1 criteria:
		//test search by only state code
		system.debug('Test --- search by only state code');
    	objController.SelectedState = 'NY';
    	objController.searchAction();
		system.assert(objController.SearchResults.size() >= 2);
		cleanTestInput(objController);

		//test search by only GTR
		system.debug('Test --- search by only GTR');
    	objController.GTR = true;
    	objController.searchAction();
		system.debug(objController.SearchResults.size());
		cleanTestInput(objController);

		//test search by only CommercialVehicle
		system.debug('Test --- search by only CV');
    	objController.CommercialVehicle = true;
    	objController.searchAction();
		system.debug(objController.SearchResults.size());
		cleanTestInput(objController);

		//test search by only ElectricVehicle
		system.debug('Test --- search by only ElectricVehicle');
    	objController.ElectricVehicle = true;
    	objController.searchAction();
		system.debug(objController.SearchResults.size());
		cleanTestInput(objController);

		//test search by only Rental
		system.debug('Test --- search by only Rental');
    	objController.Rental = true;
    	objController.searchAction();
		system.debug(objController.SearchResults.size());
		cleanTestInput(objController);

    	Test.stopTest();
    }
    
    private static void cleanTestInput(Controller_DealerSearch objController) {
    	objController.DealerName = null;
		objController.Code = null;
    	objController.City = null;
    	objController.SelectedState = '-1';
    	objController.Zip = null;
    	objController.CommercialVehicle = false;
    	objController.GTR = false;
    	objController.ElectricVehicle = false;
    	objController.Rental = false;
    }
}