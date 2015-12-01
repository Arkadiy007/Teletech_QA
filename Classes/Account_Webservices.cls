/**********************************************************************
Name: Account_Webservices
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Execute TMS Web Service Calls for Account.

Related Page : Account_Webservices
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 12/29/2010 Created
1.1 - Sonali Bhardwaj 01/10/2011 Modified code to take Dealer Code from Preffered 
                                 Dealer Account for getDealerInfo API.
1.2 - Sonali Bhardwaj 01/11/2011 Modified code to take Dealer Code from Preffered 
                                 Dealer Account for all APIs which expects Dealer 
                                 Code.
1.3 - Sonali Bhardwaj 01/18/2011 As per issue RONETELETECH-86 modified code to take 
                                 cust_activity_dtl_id from CampaignMember.
1.4 - Sonali Bhardwaj 01/19/2011 Modified code to return proper error message.
1.5 - Sonali Bhardwaj 01/20/2011 Modified code to display proper parameter name.
1.6 - Sonali Bhardwaj 01/24/2011 Modified code to use utility class.
1.7 - Biswa Ray       03/02/2011 Fixed Jira issue 143 comments.
1.8 - JJ Heldman	  02/08/2012 Modified for NCI, adding a method to retrive 
								 call centre id of user and assign endpoint, username
								 and password for TMS web services based on this data,
								 defaulted to 6 based on feedback from non-agent account access                        
***********************************************************************/

public with sharing class Account_Webservices {
    Account account;
    Lead lead;
    public string appointmentDate {get; set;}
    public string appointmentTime {get; set;}
    public string error {get; set;}
    public boolean isError {get; set;}
    public boolean isSimpleRecord {get; set;}
    public boolean isServiceResponse {get; set;}
    public boolean isServiceHistoryResponse {get; set;}
    public boolean isListOfRecords {get; set;}
    public boolean isGetToken {get; set;}
    public string dealerCode {get; set;}
    public string apiName {get; set;}
    public List<TMS_Webservices_Utility.Record> records {get; set;}
    public string id {get; set;}
    public List<TMS_Webservices_Utility.ServiceResponse> serviceResponses{get; set;}
    public List<TMS_Webservices_Utility.ServiceHistoryResponse> serviceHistoryResponses{get; set;}
    public List<List<TMS_Webservices_Utility.Record>> listOfRecords {get; set;}
    public boolean havePrefferedDealerAccount {get; set;}
    public static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    public static  nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap nnaService = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap();
  	
  	// Store call centre id of user and store if the endpoint for the TMS web services (based on this id)
  	// have been set
  	private integer callCenterID;
   	public boolean serviceAccessAssigned = false;
  
    public Account_Webservices(ApexPages.StandardController controller) { 
        initialize();
    }
    
    public void initialize() {
        apiName = ApexPages.currentPage().getParameters().get(system.label.api);
        id = ApexPages.currentPage().getParameters().get(system.label.id);
        appointmentDate = ApexPages.currentPage().getParameters().get(system.label.date);
        appointmentTime = ApexPages.currentPage().getParameters().get(system.label.Time);		
        if(apiName != 'CC_Transaction_History_Lead'){
            account = [Select PersonMailingCity, PersonMailingState, PersonMailingPostalCode, Preferred_Dealer_Id__c, Dealer_Code__c, Customer_ID__c, TMS_Customer_ID__c, billingcity, billingpostalcode, billingstate, name, phone, recordtypeId from Account where id=:id limit 1];
        }
        else{
            
        lead = [Select Id, Customer_ID__c FROM Lead where id=:id];
        
            
        }
        /*
                Query the Preferred Dealer account for current account.
        */
        havePrefferedDealerAccount = false;
        List<Account> preferredDealer = new list<Account>();
        if(apiName != 'CC_Transaction_History_Lead')
            preferredDealer = [Select Dealer_Code__c from Account where id = :account.Preferred_Dealer_Id__c limit 1];
        if (preferredDealer.size() > 0) {
            dealerCode = preferredDealer[0].Dealer_Code__c;
            havePrefferedDealerAccount = true;
        }
        isError = false;
    }
    /*
        Constructor initializes apiName and id.
    */
    public Account_Webservices() { 
        apiName = ApexPages.currentPage().getParameters().get(system.label.api);
        id = ApexPages.currentPage().getParameters().get(system.label.id);
        isError = false;
    }
    
    /*
        Checks which Web-Service to call and calls corrosponding Web-Service.
    */
    public void RunWebService() {
    	
    	if(!serviceAccessAssigned)
        {
        	if(getCallCentreID() != 4)
        	{
        		TMS_Webservices_Utility.setServiceAccess(System.label.TMS_Endpoint, System.label.username, System.label.password);
        	}
        	else if(getCallCentreID() == 4)
        	{
        		TMS_Webservices_Utility.setServiceAccess(System.label.TMS_NCI_Endpoint, System.label.usernameNCI, System.label.passwordNCI);
        	}
        	
        	serviceAccessAssigned = true;
        }   
       
       
        if (apiName == system.Label.GetDealerInfo) {
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunGetDealerInfo(dealerCode);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetDealerInfo();
            isSimpleRecord  = true && !isError;
        }
     
        else if (apiName == system.Label.CheckAppointmentTime) {
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunCheckAppointmentTime(dealerCode, appointmentDate);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunCheckAppointmentTime();
            isSimpleRecord = true && !isError;
        }
        
        else if (apiName == system.Label.GetServicesDue) {
            try {
                serviceResponses = TMS_Webservices_Utility.RunGetServicesDue(account.tms_customer_id__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetServicesDue();
            isServiceResponse = true;
        }
      
        else if (apiName == system.Label.GetPrimaryContactInfo) {
            try {
                records = TMS_Webservices_Utility.RunGetPrimaryContactInfo(account.tms_customer_id__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetPrimaryContactInfo();
            isSimpleRecord = true && !isError;
        }
      
        else if (apiName == system.Label.CheckAppointment) {
            try {
                records = TMS_Webservices_Utility.RunCheckAppointment(dealerCode, appointmentDate, appointmentTime);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunCheckAppointment();
            isSimpleRecord = true && !isError;
        }
      
        else if (apiName == system.Label.GetServiceHistory) {
            try {
                serviceHistoryResponses = TMS_Webservices_Utility.RunGetServiceHistory(account.tms_customer_id__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetServiceHistory();
            isServiceHistoryResponse = true && !isError;
        }
       
        else if (apiName == system.Label.GetCommunicationHistory) {
            try {
                listOfRecords = TMS_Webservices_Utility.RunGetCommunicationHistory(account.tms_customer_id__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetCommunicationHistory();
            isListOfRecords = true && !isError;
        }
        
        else if (apiName == system.Label.GetAppointmentSubscribeURL) {
            
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
				else{
					records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURL(dealerCode, account.tms_customer_id__c);
				}
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetAppointmentSubscribeURL();
            isSimpleRecord = true && !isError;
        }
       
        else if (apiName == system.Label.GetAssociatedCustomers) {
            try {
                listOfRecords = TMS_Webservices_Utility.RunGetAssociatedCustomers(account.tms_customer_id__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetAssociatedCustomers();
            isListOfRecords = true && !isError;
        }
        
        else if (apiName == system.Label.SearchDealer) {
            try {
                listOfRecords = TMS_Webservices_Utility.RunSearchDealer(account);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunSearchDealer();
            isListOfRecords = true && !isError;
        }
      
        else if (apiName == system.Label.Getassociated_dcno_id) {
             try {
                records = TMS_Webservices_Utility.RunGetassociated_dcno_id(account.TMS_Customer_ID__c);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetassociated_dcno_id();
            isSimpleRecord = true && !isError;
        }
        
        /*
            Get Credit Card Transaction History
        */
        else if (apiName == 'CC_Transaction_History') {
            try {
                MaritzCreditCardTransactionHistory.NNA360ServiceSoap obj = new MaritzCreditCardTransactionHistory.NNA360ServiceSoap();
                
                MaritzCreditCardTransactionHistory.CCTransactionsResponse res = null;
                obj.timeout_x = 60000;
                
                if (oUtil.isUnitTesting) {
                    res = new MaritzCreditCardTransactionHistory.CCTransactionsResponse();
                    res.CCTransactions = new MaritzCreditCardTransactionHistory.ArrayOfCCTransaction();
                    res.CCTransactions.CCTransaction = new List<MaritzCreditCardTransactionHistory.CCTransaction>();
                    MaritzCreditCardTransactionHistory.CCTransaction rec = new MaritzCreditCardTransactionHistory.CCTransaction();
                    res.CCTransactions.CCTransaction.add(rec);
                }
                else {
                    res = obj.GetCCTransactionHistory(
                    account.Customer_ID__c,
                    //'103544',
                    '', 1);
                }
                records = new List<TMS_Webservices_Utility.Record>();
                TMS_Webservices_Utility.Record rec = new TMS_Webservices_Utility.Record('Message', res.Message);
                records.add(rec);
                rec = new TMS_Webservices_Utility.Record('Status', res.Status);
                records.add(rec);
                listOfRecords = new List<List<TMS_Webservices_Utility.Record>>();
                if (res.CCTransactions != null && res.CCTransactions.CCTransaction != null) {
                    for (MaritzCreditCardTransactionHistory.CCTransaction trans : res.CCTransactions.CCTransaction) {
                        List<TMS_Webservices_Utility.Record> recs = new List<TMS_Webservices_Utility.Record>();
                        TMS_Webservices_Utility.Record r = new TMS_Webservices_Utility.Record('Transaction ID', trans.CCTransactionId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Inbound Tracking ID', trans.InboundTrackingId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Outbound Tracking ID', trans.OutboundTrackingId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Person Hash ID', trans.PersonHashId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Reservation ID', trans.ReservationId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Invoice Number', trans.InvoiceNumber);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Transaction Type', trans.CCTransactionType);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Transaction Status', trans.CCTransactionStatus);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Last Modified Date', trans.LastModifiedDate);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Has Details', trans.HasDetails);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('CMR Request ID', trans.CMRequestID);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('CSR Session ID', trans.CSRSessionId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Action Type', trans.ActionType);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Number Of Attempts', trans.NumberOfAttempts);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Promo Code', trans.PromoCode);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Amount', trans.Amount);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Created Date', trans.CreateDt);
                        recs.add(r);
                        listOfRecords.add(recs);
                    }
                }
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            isSimpleRecord = true && !isError;
            isListOfRecords = true && !isError;
        }
        
        else if (apiName == 'CC_Transaction_History_Lead') {
            try {
                MaritzCreditCardTransactionHistory.NNA360ServiceSoap obj = new MaritzCreditCardTransactionHistory.NNA360ServiceSoap();
                
                MaritzCreditCardTransactionHistory.CCTransactionsResponse res = null; 
                if (oUtil.isUnitTesting) {
                    res = new MaritzCreditCardTransactionHistory.CCTransactionsResponse();
                    res.CCTransactions = new MaritzCreditCardTransactionHistory.ArrayOfCCTransaction();
                    res.CCTransactions.CCTransaction = new List<MaritzCreditCardTransactionHistory.CCTransaction>();
                    MaritzCreditCardTransactionHistory.CCTransaction rec = new MaritzCreditCardTransactionHistory.CCTransaction();
                    res.CCTransactions.CCTransaction.add(rec);
                }
                else {
                    res = obj.GetCCTransactionHistory(
                    lead.Customer_ID__c,
                    //'103544',
                    '', 1);
                }
                records = new List<TMS_Webservices_Utility.Record>();
                TMS_Webservices_Utility.Record rec = new TMS_Webservices_Utility.Record('Message', res.Message);
                records.add(rec);
                rec = new TMS_Webservices_Utility.Record('Status', res.Status);
                records.add(rec);
                listOfRecords = new List<List<TMS_Webservices_Utility.Record>>();
                if (res.CCTransactions != null && res.CCTransactions.CCTransaction != null) {
                    for (MaritzCreditCardTransactionHistory.CCTransaction trans : res.CCTransactions.CCTransaction) {
                        List<TMS_Webservices_Utility.Record> recs = new List<TMS_Webservices_Utility.Record>();
                        TMS_Webservices_Utility.Record r = new TMS_Webservices_Utility.Record('Transaction ID', trans.CCTransactionId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Inbound Tracking ID', trans.InboundTrackingId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Outbound Tracking ID', trans.OutboundTrackingId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Person Hash ID', trans.PersonHashId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Reservation ID', trans.ReservationId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Invoice Number', trans.InvoiceNumber);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Transaction Type', trans.CCTransactionType);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Transaction Status', trans.CCTransactionStatus);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Last Modified Date', trans.LastModifiedDate);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Has Details', trans.HasDetails);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('CMR Request ID', trans.CMRequestID);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('CSR Session ID', trans.CSRSessionId);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Action Type', trans.ActionType);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Number Of Attempts', trans.NumberOfAttempts);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Promo Code', trans.PromoCode);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Amount', trans.Amount);
                        recs.add(r);
                        r = new TMS_Webservices_Utility.Record('Created Date', trans.CreateDt);
                        recs.add(r);
                        listOfRecords.add(recs);
                    }
                }
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            isSimpleRecord = true && !isError;
            isListOfRecords = true && !isError;
        }
        
    }
    
    public PageReference redirectToSSLCJ() {
        String authLogin = null;
        User user = [Select LCJ_Login__c from User where id=:userinfo.getUserId() limit 1];
            if (user.LCJ_Login__c != null)
                authLogin = user.LCJ_Login__c;
                    
            
        String personHashId = null;
        Long cdbContactId = null;
        Username__c username = new Username__c();
        // Get the login name to pass to the Leaf webservice to return a token. 
          try {
            
                username = [select Customer_Name__c, portal_user_name__c, Person_Hash_ID__c, Lead_Name__c
                            from username__c 
                            where (customer_name__c = :id OR Lead_Name__c =:id)
                            and portal_type__c = 'Leaf'
                            limit 1];
                System.debug('username: ' + username);
               //authLogin = username.portal_user_name__c;
                if (username.Person_Hash_ID__c != null)     
                    personHashId = username.Person_Hash_ID__c;
                if(username.Customer_Name__c != null){    
                Account account = [Select Customer_Id__c from Account where id =:id limit 1];
                if (account.Customer_ID__c != null && account.Customer_ID__c.length() > 0){
                    cdbContactId = Long.valueOf(account.Customer_ID__c);
                
                }    
                
                }
                else if(username.Lead_Name__c != null){
                Lead lead = [Select Id, Customer_Id__c from Lead where id =:id limit 1];
                system.debug('lead: '  + lead);
                if(lead.Customer_ID__c != null && lead.Customer_ID__c.length() > 0)
                    cdbContactId = Long.valueOf(lead.Customer_ID__c);
                } 
            }        
            catch (QueryException e) {
            //authLogin = 'jduque';
        }
        /*
         System.debug('id: '  + id);  
         System.debug('Lead.id: ' + lead.id);
         System.debug('lead.Customer_ID__c : ' + lead.Customer_ID__c );
         System.debug('cdbContactId: '  + cdbContactId);    
         System.debug('account.Customer_ID__c : ' + account.Customer_ID__c );
        */
        // Use the login name to get a token.
        WS_SSLCG.SoapSsoAuthServicePort obj = new WS_SSLCG.SoapSsoAuthServicePort();
        String token;
        System.debug('username.id: '  + username.id + ' authLogin: '  + authLogin);
        if (oUtil.isUnitTesting) {
            token = '';
        }
        else if(username.Id == null){
        
        token = obj.create(authLogin,'', 0);
            
        }
       
        else {
            try{
            system.debug('authLogin, personHashId, cdbContactId' + authLogin + personHashId +  cdbContactId );
            
            token = obj.create(authLogin, personHashId, cdbContactId);
       
            
            }catch(Exception e){

               token = obj.create(authLogin,'', 0); 
                    
                
            }
            
        } 
        // Construct the URL to redirect to using the returned token
        system.debug('token: '  + token);
        String CJTargetURL = system.Label.CJ_Target_URL;
        CJTargetURL = CJTargetURL.replace('[token]', token);
        CJTargetURL = CJTargetURL.replace('[relative uri]', '');
        PageReference returnUrl = new PageReference(CJTargetURL);
        System.debug('returnURL: '  + returnURL);
  
        
        
        return returnUrl;
        
        
    }
    
    // 1st March Changes as per issue 143
   
    @future(callout=true)
    public static void callSaveCustomer(String objId) {
System.debug('in callSaveCustomer');
        String accObjId = Schema.sObjectType.Account.getKeyPrefix();
        String leadObjId = Schema.sObjectType.Lead.getKeyPrefix();
        String campaigndefinitionid = '851CA447-6F75-4FA7-AEDA-C53B380D86BF';
        string originatingPhone = '8881112222';
        String firstName, lastName, zip, line1, city, state, email, contactId, homePhone; 
        Account accObj = null;
        Lead leadObj = null;
        
        if (objId != null && objId.startsWith(accObjId)) {
            
            accObj = [Select id, firstName, PersonEmail, LastName, PersonMailingPostalCode, 
                        PersonMailingStreet, PersonMailingCity, PersonMailingState,
                        PersonHomePhone, Name from Account where id =: objId];
            firstName = accObj.firstName;
            lastName = accObj.LastName;
            zip = accObj.PersonMailingPostalCode;
            line1 = accObj.PersonMailingStreet;
            city = accObj.PersonMailingCity;
            state = accObj.PersonMailingState;
            email = accObj.PersonEmail;
            homePhone = accObj.PersonHomePhone;
        }
        else if (objId != null && objId.startsWith(leadObjId)) {
            
            leadObj = [Select Street, City, State, PostalCode, LastName, FirstName, Email, Phone From Lead where id =: objId];
            firstName = leadObj.firstName;
            lastName = leadObj.LastName;
            zip = leadObj.PostalCode;
            line1 = leadObj.Street;
            city = leadObj.City;
            state = leadObj.State;
            email = leadObj.Email;
            homePhone = leadObj.Phone;
        }
        
        nnainfowebservicesComCieservicesNna36.Customer customer = new nnainfowebservicesComCieservicesNna36.Customer();
        nnainfowebservicesComCieservicesNna36.Address address = new nnainfowebservicesComCieservicesNna36.Address();
        nnainfowebservicesComCieservicesNna36.EmailAddress emailAdd = new nnainfowebservicesComCieservicesNna36.EmailAddress();
        nnainfowebservicesComCieservicesNna36.Phone phone = new nnainfowebservicesComCieservicesNna36.Phone();
        nnainfowebservicesComCieservicesNna36.Phone[] phoneArray = new List<nnainfowebservicesComCieservicesNna36.Phone>();
        nnainfowebservicesComCieservicesNna36.ArrayOfPhone phones = new nnainfowebservicesComCieservicesNna36.ArrayOfPhone();
        
        address.Line1 = line1;
        address.City = city;
        address.State = state;
        address.ZipCode = zip;
        address.PostalCode = zip;
        
        phone.Number_x = homePhone;
        phone.Type_x = 'Home';
        phoneArray.add(phone);
        
        phones.Phone = phoneArray;
        
        customer.FirstName = firstName;
        customer.LastName = lastName;
        customer.EmailAddress = emailAdd;
        customer.Address = address;
        customer.Phones = phones;
        customer.ContactId = contactId;
System.debug('customer = ' + customer);
        nnainfowebservicesComCieservicesNna36.CustomerResponse response;
        
        if (oUtil.isUnitTesting) {
            response = new nnainfowebservicesComCieservicesNna36.CustomerResponse();
            response.Customer = new nnainfowebservicesComCieservicesNna36.Customer();
            response.Customer.ContactId = '123$%34';
        }
        else {
            response = nnaService.SaveCustomer(customer, campaigndefinitionid, originatingPhone);
        }
System.debug('response = ' + response);   

        if ((response!= null) && (response.Customer!=null)) {
            contactId = response.Customer.contactid;
            if (accObj != null) {
                accObj = [Select id from Account where id =: objId];
                accObj.customer_Id__c = contactId;
                update accObj;
            }
            else if (leadObj != null) {
                leadObj.customer_Id__c = contactId;
                update leadObj;
            }
        }
    }
    
    
   // Retrieve call centre id of the user
   public integer getCallCentreID()
   {
   		if(callCenterID == null)
   		{
   			User userRecord =  [Select Call_Centre_Id__c From User Where Id =: UserInfo.getUserId()];
   			
   			if(userRecord == null || userRecord.Call_Centre_Id__c == null)
   			{
   				callCenterID = 6;
   			}
   			else
   			{
   				callCenterID = integer.valueOf(userRecord.Call_Centre_Id__c);
   			}
   		}
   		
   		return callCenterID;
   }
}