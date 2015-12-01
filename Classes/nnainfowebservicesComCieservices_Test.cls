/**********************************************************************
Name: nnainfowebservicesComCieservices_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for nnainfowebservicesComCieservicesNna36.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd. Siddiqui 03/02/2011 Created 
***********************************************************************/

@isTest
private global class nnainfowebservicesComCieservices_Test{
    public static Account prefferedAccount = new Account();
    public static Contact contact = new Contact();
    private static nnainfowebservicesComCieservicesNna36 obj = new nnainfowebservicesComCieservicesNna36() ;
    private static nnainfowebservicesComCieservicesNna36.GetCCTransactionHistoryResponse_element getCCResobj = new nnainfowebservicesComCieservicesNna36.GetCCTransactionHistoryResponse_element();
    private static nnainfowebservicesComCieservicesNna36.CustomerThin custobj = new nnainfowebservicesComCieservicesNna36.CustomerThin();
    private static nnainfowebservicesComCieservicesNna36.ArrayOfCCTransaction arrayCCobj = new nnainfowebservicesComCieservicesNna36.ArrayOfCCTransaction();
    private static nnainfowebservicesComCieservicesNna36.Phone phoneobj = new  nnainfowebservicesComCieservicesNna36.Phone();
    private static nnainfowebservicesComCieservicesNna36.CCTransactionsResponse CCTranobj = new nnainfowebservicesComCieservicesNna36.CCTransactionsResponse();
    private static nnainfowebservicesComCieservicesNna36.SearchForCustomerResponse_element  searchCustResobj = new nnainfowebservicesComCieservicesNna36.SearchForCustomerResponse_element();
    private static nnainfowebservicesComCieservicesNna36.CustomersThinResponse custResobj = new nnainfowebservicesComCieservicesNna36.CustomersThinResponse();
    private static nnainfowebservicesComCieservicesNna36.SaveCustomerResponse_element saveCustResObj = new nnainfowebservicesComCieservicesNna36.SaveCustomerResponse_element();
    private static nnainfowebservicesComCieservicesNna36.ArrayOfCustomerThin arrayCustobj = new nnainfowebservicesComCieservicesNna36.ArrayOfCustomerThin();
    private static nnainfowebservicesComCieservicesNna36.SearchForCustomer_element searchCustobj = new nnainfowebservicesComCieservicesNna36.SearchForCustomer_element();
    private static nnainfowebservicesComCieservicesNna36.GetCustomerResponse_element getCustResobj = new nnainfowebservicesComCieservicesNna36.GetCustomerResponse_element();
    private static nnainfowebservicesComCieservicesNna36.ArrayOfPhone arrayPhoneobj = new nnainfowebservicesComCieservicesNna36.ArrayOfPhone();
    private static nnainfowebservicesComCieservicesNna36.CCTransaction CCTransobj = new nnainfowebservicesComCieservicesNna36.CCTransaction();
    private static nnainfowebservicesComCieservicesNna36.GetCCTransactionHistory_element getCCobj = new nnainfowebservicesComCieservicesNna36.GetCCTransactionHistory_element() ;
    private static nnainfowebservicesComCieservicesNna36.GetCustomer_element getCustobj = new nnainfowebservicesComCieservicesNna36.GetCustomer_element() ;
    private static nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap NNAobj = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap() ;
    
    static void TestData() {
        String dealerType = System.Label.AccRTDealer;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        prefferedAccount.name = 'Test';
        prefferedAccount.RecordTypeId = dealerTypeRT.Id;
        insert prefferedAccount; 
        contact.lastName = 'Test';
        contact.accountId = prefferedAccount.id;
        insert contact;
    }
    
    static testmethod void testGetCustomer() {
        TestData();
        
        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        nnainfowebservicesComCieservicesNna36.CustomerResponse resobj = NNAobj.GetCustomer(contact.Id);
        test.stopTest();
    }
    
    static testmethod void testSearchForCustomer() {
        TestData();
        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        nnainfowebservicesComCieservicesNna36.CustomersThinResponse CustThinResobj = NNAobj.SearchForCustomer('fname' , 'lname' , 'addr1' , '123456' , '121923' , 'test@nissan.com' , 'A123'  );
        test.stopTest();
    }
    
    static testmethod void testGetCCTransactionHistory() {
        TestData();
        
        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        nnainfowebservicesComCieservicesNna36.CCTransactionsResponse CCTransRespobj = NNAobj.GetCCTransactionHistory('1234' , '3456'  );
        test.stopTest();
    }

	global class WebServiceMockImpl1 implements WebServiceMock {
	   global void doInvoke(
			   Object stub,
			   Object request,
			   Map<String, Object> response,
			   String endpoint,
			   String soapAction,
			   String requestName,
			   String responseNS,
			   String responseName,
			   String responseType) {
		   nnainfowebservicesComCieservicesNna36.GetCustomerResponse_element respElement = new nnainfowebservicesComCieservicesNna36.GetCustomerResponse_element();
		   respElement.CustomerResponse = new nnainfowebservicesComCieservicesNna36.CustomerResponse();
		   response.put('response_x', respElement); 
	   }
	}

	global class WebServiceMockImpl2 implements WebServiceMock {
	   global void doInvoke(
			   Object stub,
			   Object request,
			   Map<String, Object> response,
			   String endpoint,
			   String soapAction,
			   String requestName,
			   String responseNS,
			   String responseName,
			   String responseType) {
		   nnainfowebservicesComCieservicesNna36.SearchForCustomerResponse_element respElement = new nnainfowebservicesComCieservicesNna36.SearchForCustomerResponse_element();
		   respElement.CustomersThinResponse = new nnainfowebservicesComCieservicesNna36.CustomersThinResponse();
		   response.put('response_x', respElement); 
	   }
	}

	global class WebServiceMockImpl3 implements WebServiceMock {
	   global void doInvoke(
			   Object stub,
			   Object request,
			   Map<String, Object> response,
			   String endpoint,
			   String soapAction,
			   String requestName,
			   String responseNS,
			   String responseName,
			   String responseType) {
		   nnainfowebservicesComCieservicesNna36.GetCCTransactionHistoryResponse_element respElement = new nnainfowebservicesComCieservicesNna36.GetCCTransactionHistoryResponse_element();
		   respElement.CCTransactionsResponse = new nnainfowebservicesComCieservicesNna36.CCTransactionsResponse();
		   response.put('response_x', respElement); 
	   }
	}
}