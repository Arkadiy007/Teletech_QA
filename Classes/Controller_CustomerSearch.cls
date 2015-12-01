public with sharing class Controller_CustomerSearch {
    protected List<List<sObject>> searchResults  = new List<List<sObject>>{};
    public List<Lead> resultListLeads;
    public List<Contact> resultListContacts;
    public List<Account> resultListAccounts;
    
    public List<mCustomerThin> resultListMaritz; 
    public string selectedCustomer { get; set; }
    
    public String searchCustomerId{ get; set; }
    public String searchFirstname{ get; set; }
    public String searchLastname{ get; set; }
    public String searchPhone{ get; set; }
    public String searchEmail{ get; set; }
    public boolean noLeadResult{ get; set; }
    public boolean noContactResult{ get; set; }
    public boolean noAccountResult{ get; set; }  
    public boolean emptyLeadList{ get; set; }
    public boolean emptyContactList{ get; set; }
    public boolean emptyAccountList{ get; set; }
    public boolean errorShow{ get; set; }
    public String errorTitle{ get; set; }
    public String errorMessage{ get; set; }
    public String errorSeverity{ get; set; }
    public Integer numLeads{ get; set; }
    public Integer numContacts{ get; set; }
    public Integer numAccounts{ get; set; }
    public Integer numMaritz{ get; set; }
    public boolean noMaritzResults{ get; set; }
    public boolean emptyMaritzList{ get; set; }
    public boolean TooManyMaritzResults{ get; set; }
    public boolean OtherMaritzResults{ get; set; }
    public String searchAddr1 { get; set; }
    public String searchZip { get; set; }
    public static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
    public Controller_CustomerSearch ( ) {
            emptyLeadList = true;
            emptyContactList = true;
            emptyAccountList = true;
            numLeads = 0;
            numContacts = 0;
            numAccounts = 0;
            noLeadResult = false;   
            noContactResult = false;
            noAccountResult = false;
            errorShow = false;
            errorTitle = '';
            errorMessage = '';
            errorSeverity = ''; 
            emptyMaritzList = true;
            TooManyMaritzResults = false;
            OtherMaritzResults = false;
    }
    
    public List<Lead> getresultListLeads() {
        return resultListLeads;
    }

    public List<Contact> getresultListContacts() {
        return resultListContacts;
    }
    
    public List<Account> getresultListAccounts() {
        return resultListAccounts;
    }
    
    public List<mCustomerThin> getresultListMaritz() {
        return resultListMaritz;
    }
    
    public PageReference searchMaritz() {

    	
    	system.debug('### starting searchMaritz');
    	
    	if(searchCustomerId == '' && searchFirstname == '' && searchLastname == '' && SearchAddr1 == '' && searchZip == '' && searchPhone == '' && searchEmail==''){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, System.Label.sfNoSearchCriteriaError));
    		//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      		return null;
    	}
    	
    	
    	//Set all prior search results to null:
    	emptyMaritzList = false;
    	TooManyMaritzResults = false; 
    	OtherMaritzResults = false;
    	noMaritzResults = false;
    	
    	nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap svr = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap(); 
    	system.debug('### svr ' + svr);
    	svr.timeout_x = 30000;
    	
    	string customerid = searchCustomerId;
    	string firstName = searchFirstname;
    	string lastName = searchLastname;
    	string addressLine1 = SearchAddr1;
    	string zipCode = searchZip;
    	string phone = searchPhone;
		string email = searchEmail;
		string reservationId = '';
		system.debug('### start call...');
		
		System.debug('custid = ' + customerid + 
		             'fn = ' + firstName + ', ln' + lastName + ', add = ' + addressLine1 +
		             ', zip = ' + zipCode + ', phn =' + phone + ', email = ' + email +
		             ', res = ' + reservationId);
		
		nnainfowebservicesComCieservicesNna36.CustomersThinResponse ctr;
		nnainfowebservicesComCieservicesNna36.CustomerResponse response;
		if (customerid != null && customerid != '') {
	    	system.debug('### ' + response);
	    	/*
			nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap svr = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap(); 
			nnainfowebservicesComCieservicesNna36.CustomerResponse response;
			response = svr.GetCustomer('24826744');
			System.Debug('###' + response);
	    	*/
			if (Test.isRunningTest()) {
				response = new nnainfowebservicesComCieservicesNna36.CustomerResponse();
				response.Customer = new nnainfowebservicesComCieservicesNna36.Customer();
		        response.Customer.ContactId = '123';
		        response.Customer.CustomerId = '123';
		        response.Customer.FirstName = 'First';
		        response.Customer.LastName = 'Last';
		        response.Customer.Address = new nnainfowebservicesComCieservicesNna36.Address();
		        response.Customer.Address.Line1 = '123 Main St';
		        response.Customer.Address.City = 'Denver';
		        response.Customer.Address.State = 'CO';
		        response.Customer.Address.Zip4 = '80216';
		        response.Customer.Phones = new nnainfowebservicesComCieservicesNna36.ArrayOfPhone();
		        response.Customer.Phones.Phone = new nnainfowebservicesComCieservicesNna36.Phone[]{new nnainfowebservicesComCieservicesNna36.Phone()};
		        response.Customer.Phones.Phone[0].Number_x = '5555555555';
		        response.Customer.EmailAddress = new nnainfowebservicesComCieservicesNna36.EmailAddress();
		        response.Customer.EmailAddress.Email = 'test@test.com';
				response.status = 'Success';
			} else     		
    			response = svr.GetCustomer(customerid);
	    	if(response.Status == 'NotFound') { //No Match
	    		system.debug('### ' + response.Status);
	    		emptyMaritzList = true;
	    		noMaritzResults = true;
	    		return null;
	    	} else if(response.Status == 'Success') {
		    	system.debug('### ' + response.Customer);
		    	emptyMaritzList = false;
		    	if (response.Customer != null) {
			    	numMaritz = 1;
			    	noMaritzResults = false;
			    	
			    	list<mCustomerThin> mct = new list<mCustomerThin>();
		    		nnainfowebservicesComCieservicesNna36.Customer ctrx = response.Customer;
					String phoneNumber;
					for (nnainfowebservicesComCieservicesNna36.Phone p : ctrx.Phones.Phone) {
						if (p.Number_x != null && p.Number_x != '') {
							phoneNumber = p.Number_x;
							break;
						}
					}
	    			mCustomerThin mctx = new mCustomerThin();
	    			mctx.FirstName = 		ctrx.FirstName;
	    			mctx.LastName = 		ctrx.LastName;
			        mctx.Line1 = 			ctrx.Address.Line1;
			        mctx.City =			 	ctrx.Address.City;
			        mctx.State = 			ctrx.Address.State;
			        mctx.ZipCode = 			ctrx.Address.ZipCode;
			        mctx.Phone = 			phoneNumber;
			        mctx.Email = 			ctrx.EmailAddress.Email;
			        mctx.ContactId = 		ctrx.ContactId;
	    			
	    			mct.add(mctx);
					
		    		resultListMaritz = mct;
		    		system.debug('#### ' + resultListMaritz);
		    	}
	    	} else
	    		OtherMaritzResults = true;
		} else {
			if (Test.isRunningTest()) {
				ctr = new nnainfowebservicesComCieservicesNna36.CustomersThinResponse();
				nnainfowebservicesComCieservicesNna36.ArrayOfCustomerThin obj = new nnainfowebservicesComCieservicesNna36.ArrayOfCustomerThin();
				obj.CustomerThin = new List<nnainfowebservicesComCieservicesNna36.CustomerThin>();
				obj.CustomerThin.add(new nnainfowebservicesComCieservicesNna36.CustomerThin());
				ctr.CustomersThin = obj;
				ctr.status = oUtil.mockResponse;
			} else     		
				ctr = svr.SearchForCustomer(firstName, lastName, addressLine1, zipCode, phone, email, reservationId);
			
	    	if(ctr.Status == 'NotFound') { //No Match
	    		system.debug('### ' + ctr.status);
	    		emptyMaritzList = true;
	    		noMaritzResults = true;
	    		return null;
	    	}    	
	    	else if(ctr.Status == 'TooManyResults'){
	    		system.debug('### ' + ctr.status);
	    		emptyMaritzList = true;
	    		TooManyMaritzResults = true;
	    		return null;
	    	}
	    	else if(ctr.Status == 'Success') {
		    	system.debug('### ' + ctr.CustomersThin);
		    	system.debug('### ' + ctr.CustomersThin.CustomerThin.size());
		    	emptyMaritzList = false;
		    	numMaritz = ctr.CustomersThin.CustomerThin.size();
		    	if(numMaritz > 0){
		    		noMaritzResults = false;
		    	}
		    	list<mCustomerThin> mct = new list<mCustomerThin>();
	    		for(nnainfowebservicesComCieservicesNna36.CustomerThin ctrx : ctr.CustomersThin.CustomerThin){
	    			mCustomerThin mctx = new mCustomerThin();
	    			mctx.FirstName = 		ctrx.FirstName;
	    			mctx.LastName = 		ctrx.LastName;
	    			mctx.ContactId = 		ctrx.ContactId;
			        mctx.Line1 = 			ctrx.Line1;
			        mctx.City =			 	ctrx.City;
			        mctx.State = 			ctrx.State;
			        mctx.ZipCode = 			ctrx.ZipCode;
			        mctx.Phone = 			ctrx.Phone;
			        mctx.Email = 			ctrx.Email;
			        mctx.ReservationId = 	ctrx.ReservationId;
			        mctx.ContactId = 		ctrx.ContactId;
	    			
	    			mct.add(mctx);
	    		}
	    		resultListMaritz = mct;
	    		system.debug('#### ' + resultListMaritz);
	    	}
	    	else {
	    		system.debug('### ' + ctr.status);
	    		system.debug('### ' + ctr.CustomersThin.CustomerThin.size());
	    		OtherMaritzResults = true;
	    		//for(nnainfowebservicesComCieservicesNna36.CustomerThin ctrx : ctr.CustomersThin.CustomerThin){
	    	//		system.debug('### ' + );
	    		//} 
	    	}
		}	
    	
    	return null;
    }
    
    public PageReference UseExisting() {   	
    	mCustomerThin selectedmcust = new mCustomerThin();
    	PageReference pageRef = null;
    	String urlString = '';

    	for(mCustomerThin c : resultListMaritz ){
    		system.debug('### in loop selected = '+ selectedCustomer +', loop = ' +  c.contactid);
    		if(selectedCustomer == c.ContactId){
    			// If we find a matching customer, there is no
    			// need to go through the rest of the list.
    			selectedmcust = c;
    			break;
    		}    		
    	}
    	
    	system.debug('### selectedmcust' + selectedmcust);
    	
    	// Check to see if selected account already exists in Salesforce. If it does, just go
    	// to the Account edit page for the existing account.
    	List<Account> existingAccts = [select id, Customer_ID__c 
    								   from Account 
    								   where Customer_ID__c = :selectedmcust.ContactId 
    								   and RecordType.Name =: System.label.AccRTMaritz
    								   limit 1];
    	if (existingAccts != null && existingAccts.size() > 0) {
	    	System.debug('acct cust id = ' + existingAccts[0].Customer_ID__c + ', contactid = ' + selectedmcust.ContactId);
	    	if (existingAccts[0] != null && existingAccts[0].Customer_ID__c.equals(selectedmcust.ContactId)) {
	    		return new PageReference('/' + existingAccts[0].id + '/e?retURL=%2F' + existingAccts[0].id);
	    	}
    	}
    	
    	//Set all prior search results to null:
    	emptyMaritzList = false;
    	TooManyMaritzResults = false; 
    	OtherMaritzResults = false;
    	noMaritzResults = false;
    	
    	nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap svr = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap(); 
    	system.debug('### svr ' + svr);
    	svr.timeout_x = 30000;
    	
		system.debug('### start GetCustomer call...');
		
		nnainfowebservicesComCieservicesNna36.CustomerResponse response;
		if (oUtil.isUnitTesting) {
			response = new nnainfowebservicesComCieservicesNna36.CustomerResponse();
			response.status = oUtil.mockResponse;
			response.Customer = new nnainfowebservicesComCieservicesNna36.Customer();
			response.Customer.lastName = 'test';
			response.Customer.Address = new nnainfowebservicesComCieservicesNna36.Address();
			response.Customer.EmailAddress = new nnainfowebservicesComCieservicesNna36.EmailAddress();
			response.Customer.Phones = new nnainfowebservicesComCieservicesNna36.ArrayOfPhone();
			response.Customer.Phones.Phone = new List<nnainfowebservicesComCieservicesNna36.Phone>();
			nnainfowebservicesComCieservicesNna36.Phone p1 = new nnainfowebservicesComCieservicesNna36.Phone();
			p1.Type_x = 'Cell';
			nnainfowebservicesComCieservicesNna36.Phone p2 = new nnainfowebservicesComCieservicesNna36.Phone();
			p2.Type_x = 'Home';
			p2.DoNotCall = 'TRUE';
			nnainfowebservicesComCieservicesNna36.Phone p3 = new nnainfowebservicesComCieservicesNna36.Phone();
			p3.Type_x = 'Work';
			response.Customer.Phones.Phone.add(p1);
			response.Customer.Phones.Phone.add(p2);
			response.Customer.Phones.Phone.add(p3);
		}
		else {
			// Call Maritz GetCustomer service to get full customer data
    		response = svr.GetCustomer(selectedCustomer);
		}
    	System.debug('### ' + response);
    	
    	if(response.Status == 'NotFound') { //No Match
    		system.debug('### ' + response.status);
    		emptyMaritzList = true;
    		noMaritzResults = true;
    		return null;
    	}    	
    	else if(response.Status == 'TooManyResults'){
    		system.debug('### ' + response.status);
    		emptyMaritzList = true;
    		TooManyMaritzResults = true;
    		return null;
    	}
    	else if(response.Status == 'Success') {
    		nnainfowebservicesComCieservicesNna36.Customer cust = response.Customer;
    		emptyMaritzList = false;
    		noMaritzResults = false;

			// Build a MaritzCustomer object from the returned web service data,
			// insert an account based on the data, and forward to the account
			// edit page.
			MaritzCustomer mCust = new MaritzCustomer(cust);
			System.debug('customer = ' + mCust);
			Account acct = mCust.getAccount();
			System.debug('acct = ' + acct);
			acct.isInsert__c = true;
			insert acct;
			System.debug('acct id = ' + acct.id);
			urlString = '/' + acct.id + '/e?retURL=%2F' + acct.id;
			pageRef = new PageReference(urlString);
    	}
    	else {
    		system.debug('### ' + response.status);
    		OtherMaritzResults = true;
    	}

    	return pageRef;
    }
    
    public PageReference search() {
        errorShow = false;
        string tablesFields = 'lead(id, phone, company, email, firstname, Status, lastname), contact(id, phone, email, firstname, lastname, accountId), account(id, customer_id__c, phone, type, name)';
        string searchString = getSearchCriteria();
        string checkString = searchString.replace('*','').replace('?','');
        if (checkString.length() > 1) {
            try {
                searchString = 'find \'' + searchString + '\' in ALL FIELDS RETURNING ' + tablesFields;
                searchResults = search.query(searchString);
                resultListLeads = ((List<Lead>)searchResults[0]);
                numLeads = resultListLeads.size();
                emptyLeadList = resultListLeads.isEmpty() ? true : false;
                noLeadResult = emptyLeadList;
                resultListContacts = ((List<Contact>)searchResults[1]);
                numContacts = resultListContacts.size();
                emptyContactList = resultListContacts.isEmpty() ? true : false;
                noContactResult = emptyContactList;
                resultListAccounts = ((List<Account>)searchResults[2]); 
                numAccounts = resultListAccounts.size();     
                emptyAccountList = resultListAccounts.isEmpty() ? true : false;
                noAccountResult = emptyAccountList;
            } catch (Exception e) {
                // System.debug('Error when executing the search: ' + e);
                errorTitle = e.getMessage();
                errorMessage = e.getMessage();
                errorSeverity = system.label.error;
                errorShow = true;
            }
        } else if (checkString.length() == 1) {
            numLeads = 0;
            numContacts = 0;
            numAccounts = 0;
            emptyLeadList = true;
            emptyContactList = true;
            emptyAccountList = true;
            noLeadResult = false;
            noContactResult = false;
            noAccountResult = false;
            errorTitle = System.Label.sfError;
            errorMessage = System.Label.sfErrorMessage ;
            errorSeverity = system.label.error;
            errorShow = true;
        }       
        // return to the same page
        return null;
    }
 
    public PageReference reset() {
        numLeads = 0;
        numContacts = 0;
        numAccounts = 0;
        emptyLeadList = true;
        emptyContactList = true;
        emptyAccountList = true;
        searchCustomerId = '';
        searchFirstname = '';
        searchLastname = '';
        searchPhone = '';
        searchEmail = '';
        searchAddr1 = '';
        searchZip = '';
        errorTitle = '';
        errorMessage = '';
        errorSeverity = '';
        errorShow = false;
        noLeadResult = false;
        noContactResult = false;
        noAccountResult = false;
        return null;
    }

   
    private string getSearchCriteria() {
        String fullSearchString = '';
        String searchName = searchFirstname;
        if (searchName != ''){
            if (searchLastname != '') {
                searchName = searchFirstname + ' ' + searchLastname;
            }
        } else {
            searchName = searchLastname;    
        }
        fullSearchString = appendToSearchString(fullSearchString, searchCustomerId);
        fullSearchString = appendToSearchString(fullSearchString, searchName);
        fullSearchString = appendToSearchString(fullSearchString, searchAddr1);
        fullSearchString = appendToSearchString(fullSearchString, searchZip);
        fullSearchString = appendToSearchString(fullSearchString, searchPhone);
        fullSearchString = appendToSearchString(fullSearchString, searchEmail);
        return fullSearchString;
    }

    public PageReference createNewLead(){
        PageReference pageRef = new PageReference('/00Q/e?retURL=%2F00Q%2Fo' + (searchFirstname != ''?'&name_firstlea2='+ searchFirstname : '') + (searchLastname != ''?'&name_lastlea2='+ searchLastname : '') + (searchPhone != ''?'&lea8='+ searchPhone : '') + (searchEmail != ''?'&lea11='+ searchEmail : ''));
        return pageRef;
    }

    public PageReference createNewContact(){
        PageReference pageRef = new PageReference('/003/e?retURL=%2F003%2Fo' + (searchFirstname != ''?'&name_firstcon2='+ searchFirstname : '') + (searchLastname != ''?'&name_lastcon2='+ searchLastname : '') + (searchPhone != ''?'&con10='+ searchPhone : '') + (searchEmail != ''?'&con15='+ searchEmail : ''));
        return pageRef;
    }
    
    public PageReference createNewAccount(){
        PageReference pageRef = new PageReference('/001/e?retURL=%2F001%2Fo' + (searchFirstname != ''?'&name_firstadd2='+ searchFirstname : '') + (searchLastname != ''?'&name_lastadd2='+ searchLastname : '') + (searchPhone != ''?'&add10='+ searchPhone : '') + (searchEmail != ''?'&add15='+ searchEmail : ''));
        return pageRef;
    }
    
    
    private string appendToSearchString(String searchString, String newValue) {
        if (newValue != null && newValue != '') {
            if (searchString == '') {
                searchString = newValue;
            } else {
                searchString += ' OR ' + newValue;
            }
        }
        return searchString;
    }

public class mCustomerThin {
    public String ContactId{ get; set; }
    public String FirstName{ get; set; }
    public String LastName{ get; set; }
    public String Line1{ get; set; }
    public String City{ get; set; }
    public String State{ get; set; }
    public String ZipCode{ get; set; }
    public String Phone{ get; set; }
    public String Email{ get; set; }
    public String ReservationId{ get; set; }
}

public class MaritzCustomer {
	public String contactId { get; set; }
	public String customerId { get; set; }
	public String prefix { get; set; }
	public String firstName { get; set; }
	public String lastName { get; set; }
	public String middleInitial { get; set; }
	public String suffix { get; set; }
	public String doNotContact { get; set; }
	public String lastModTsp { get; set; }
	public String garbage { get; set; }
	public String business { get; set; }
	public String badWord { get; set; }
	public String isNewContact { get; set; }
	public String houseHoldKey { get; set; }
	public String line1 { get; set; }
	public String line2 { get; set; }
	public String street { get; set; }
	public String city { get; set; }
	public String state { get; set; }
	public String zipCode { get; set; }
	public String zip4 { get; set; }
	public String combinedZip { get; set; }
	public String postalCode { get; set; }
	public String code1ReturnCode { get; set; }
	public String doNotMail { get; set; }
	public String undeliverableAddress { get; set; }
	public String doNotFulfill { get; set; }
	public String dealer { get; set; }
	public String invalidState { get; set; }
	public String military { get; set; }
	public String prison { get; set; }
	public String company { get; set; }
	public String pander { get; set; }
	public String email { get; set; }
	public String doNotEmail { get; set; }
	public String undeliverableEmail { get; set; }
	public String emailFailedValidation { get; set; }
	public String homePhone { get; set; }
	public String homePhoneDoNotCall { get; set; }
	public String homePhoneFCCDoNotCall { get; set; }
	public String homePhoneMaritzDoNotCall { get; set; }
	public String workPhone { get; set; }
	public String workPhoneDoNotCall { get; set; }
	public String workPhoneFCCDoNotCall { get; set; }
	public String workPhoneMaritzDoNotCall { get; set; }
	public String mobilePhone { get; set; }
	public String mobilePhoneDoNotCall { get; set; }
	public String mobilePhoneFCCDoNotCall { get; set; }
	public String mobilePhoneMaritzDoNotCall { get; set; }
	
	public MaritzCustomer(nnainfowebservicesComCieservicesNna36.Customer cust) {
   		contactId = cust.ContactId;
		customerId = cust.CustomerId;
		prefix = cust.Prefix;
		firstName = cust.FirstName;
		lastName = cust.LastName;
		middleInitial = cust.MiddleInitial;
		suffix = cust.Suffix;
		doNotContact = cust.DoNotContact;
    	lastModTsp = cust.LastModTsp;
    	garbage = cust.Garbage;
    	business = cust.Business;
    	badWord = cust.BadWord;
    	isNewContact = cust.IsNewContact;
		houseHoldKey = cust.Address.HouseHoldKey;
		line1 = cust.Address.Line1;
		line2 = cust.Address.Line2;
		street = line1;
		if (line2 != null && line2 != '') {
			street = street + ' ' + line2;
		}
		city = cust.Address.City;
		state = cust.Address.State;
		zipCode = cust.Address.ZipCode;
		zip4 = cust.Address.Zip4;
		combinedZip = zipCode;
		if (zip4 != null && zip4 != '') {
			combinedZip = combinedZip + '-' + zip4;
		}
		postalCode = cust.Address.PostalCode;
		code1ReturnCode = cust.Address.Code1ReturnCode;
		doNotMail = cust.Address.DoNotMail;
		undeliverableAddress = cust.Address.Undeliverable;
		doNotFulfill = cust.Address.DoNotFulFill;
		dealer = cust.Address.Dealer;
		invalidState = cust.Address.InvalidState;
		military = cust.Address.Military;
		prison = cust.Address.Prison;
		company = cust.Address.Company;
		pander = cust.Address.Pander;
		email = cust.EmailAddress.Email;
		doNotEmail = cust.EmailAddress.DoNotEmail;
		undeliverableEmail = cust.EmailAddress.Undeliverable;
		emailFailedValidation = cust.EmailAddress.FailedValidation;
		homePhone = '';
		homePhoneDoNotCall = '';
		homePhoneFCCDoNotCall = '';
		homePhoneMaritzDoNotCall = '';
		workPhone = '';
		workPhoneDoNotCall = '';
		workPhoneFCCDoNotCall = '';
		workPhoneMaritzDoNotCall = '';
		mobilePhone = '';
		mobilePhoneDoNotCall = '';
		mobilePhoneFCCDoNotCall = '';
		mobilePhoneMaritzDoNotCall = '';
		for (nnainfowebservicesComCieservicesNna36.Phone phone : cust.Phones.Phone) {
			if (phone.Type_x.equals('Home')) {
				homePhone = phone.Number_x;
				homePhoneDoNotCall = phone.DoNotCall;
				homePhoneFCCDoNotCall = phone.FCCDoNotCall;
				homePhoneMaritzDoNotCall = phone.MaritzDoNotCall;
			} else if (phone.Type_x.equals('Work')) {
				workPhone = phone.Number_x;
				workPhoneDoNotCall = phone.DoNotCall;
				workPhoneFCCDoNotCall = phone.FCCDoNotCall;
				workPhoneMaritzDoNotCall = phone.MaritzDoNotCall;
			} else if (phone.Type_x.equals('Cell')) {
				mobilePhone = phone.Number_x;
				mobilePhoneDoNotCall = phone.DoNotCall;
				mobilePhoneFCCDoNotCall = phone.FCCDoNotCall;
				mobilePhoneMaritzDoNotCall = phone.MaritzDoNotCall;
			}
		}
	}
	
	public Account getAccount() {
		Account acct = new Account();
		
		acct.Customer_ID__c = contactId == null ? '' : contactId;
		acct.Salutation = prefix == null ? '' : prefix;
		acct.FirstName = firstName == null ? '' : firstName;
		acct.LastName = lastName == null ? System.label.DollarSign : lastName;
		acct.MiddleName__c = middleInitial == null ? '' : middleInitial;
		acct.Do_Not_Contact_Indicator__c = getBooleanFromString(doNotContact);
		acct.Business_Indicator__c = getBooleanFromString(business);
		acct.Household_ID__c = houseHoldKey == null ? '' : houseHoldKey;
		acct.PersonMailingStreet = street == null ? '' :street;
		acct.PersonMailingCity = city == null ? '' : city;
		acct.PersonMailingState = state == null ? '' : state;
		acct.PersonMailingPostalCode = combinedZip == null ? '' : combinedZip;
		acct.Do_Not_Mail_Indicator__c = getBooleanFromString(doNotMail);
		acct.Undeliverable_Address_Indicator__c = getBooleanFromString(undeliverableAddress);
		acct.PersonEmail = email == null ? '' : email;
		acct.Undeliverable_Email_Address_In__c = getBooleanFromString(undeliverableEmail);
		acct.PersonHomePhone = homePhone == null ? '' : homePhone;
		acct.PersonDoNotCall = getBooleanFromString(homePhoneDoNotCall);
		acct.Person_Phone_Do_Not_Call__c = getPicklistValueFromString(homePhoneDoNotCall);
		acct.Federal_Home_Phone_Do_Not_Call_In__c = getPicklistValueFromString(homePhoneFCCDoNotCall);
		acct.PersonOtherPhone = workPhone == null ? '' : workPhone;
		acct.Other_Phone_Do_Not_Call_In__c = getPicklistValueFromString(workPhoneDoNotCall);
		acct.Federal_Other_Phone_Do_Not_Call_In__c = getPicklistValueFromString(workPhoneFCCDoNotCall);
		acct.PersonMobilePhone = mobilePhone == null ? '' : mobilePhone;
		acct.Mobile_Phone_Do_Not_Call_Indicator__c = getPicklistValueFromString(mobilePhoneDoNotCall);
		acct.Federal_Mobile_Phone_Do_Not_Call_In__c = getPicklistValueFromString(mobilePhoneFCCDoNotCall);
		
		/*
		customerId
		suffix
    	lastModTsp
    	garbage
    	badWord
    	isNewContact
		code1ReturnCode
		doNotFulfill
		deale
		invalidState
		military
		prison
		company
		pander
		emailFailedValidation
		homePhoneMaritzDoNotCall
		workPhoneMaritzDoNotCall
		mobilePhoneMaritzDoNotCall
		*/
		
		return acct;
	}
	
	public String buildAccountCreateUrlString() {
		String urlString = '/001/e?retURL=%2F001%2Fo' +
		                   '&RecordType=' + System.Label.sfMaritzPARType +
		                   '&ent=Account' +
		                   '&name_firstacc2=' + firstName +
		                   '&name_lastacc2=' + lastName +
		                   '&acc10=' + homePhone +
		                   '&PersonMailingAddressStreet=' + street +
		                   '&PersonMailingAddressCity=' + city +
		                   '&PersonMailingAddressState=' + state +
		                   '&PersonMailingAddressZip=' + postalCode;
		                   
/*
						<apex:outputLink value="/001/e">
                       		<i>Select</i>								
							<apex:param name="retURL" value="%2F001%2Fo"/>
							<apex:param name="RecordType" value="{!$Label.sfMaritzPARType}"/>
							<apex:param name="ent" value="Account"/>	
                       		<apex:param name="name_firstacc2" value="{!contactItem.FirstName}"/>
							<apex:param name="name_lastacc2" value="{!contactItem.LastName}"/>
							<apex:param name="acc10" value="{!contactItem.Phone}"/>
							<apex:param name="PersonMailingAddressstreet" value="{!contactItem.Line1}"/>
							<apex:param name="PersonMailingAddressstate" value="{!contactItem.State}"/>
							<apex:param name="PersonMailingAddresszip" value="{!contactItem.ZipCode}"/>
							<apex:param name="{!$Label.sfCustomerIdField}" value="{!contactItem.ContactId}"/>
							<apex:param name="PersonEmail" value="{!contactItem.Email}"/>
							<apex:param name="PersonMailingAddresscity" value="{!contactItem.City}"/>
                        </apex:outputLink>
*/
		return urlString;
	}
	
	public Boolean getBooleanFromString(String inString) {
		Boolean outBool = false;
		if (inString != null && inString.equals('True')) {
			outBool = true;
		}
		
		return outBool;
	}

	public String getPicklistValueFromString(String inString) {
		String outString = 'None';
		
		if (inString != null) {
			if (inString.equals('True')) {
				outString = 'Yes';
			} else if (inString.equals('False')){
				outString = 'No';
			}
		}
		
		return outString;
	}

}

}