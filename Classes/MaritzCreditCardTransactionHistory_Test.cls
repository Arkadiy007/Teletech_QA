/**********************************************************************
Name: MaritzCreditCardTransactionHistory_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for MaritzCreditCardTransactionHistory.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 02/28/2011 Created 
***********************************************************************/
@isTest
private global class MaritzCreditCardTransactionHistory_Test {
    
    static testmethod void testCreate() {
        MaritzCreditCardTransactionHistory.NNA360ServiceSoap obj = new MaritzCreditCardTransactionHistory.NNA360ServiceSoap();
        MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element obj1 = new MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element();
        MaritzCreditCardTransactionHistory.ArrayOfCCTransaction  obj2 = new MaritzCreditCardTransactionHistory.ArrayOfCCTransaction();
        MaritzCreditCardTransactionHistory.CCTransactionsResponse   obj3 = new MaritzCreditCardTransactionHistory.CCTransactionsResponse();
        MaritzCreditCardTransactionHistory.CCTransaction obj4 = new MaritzCreditCardTransactionHistory.CCTransaction();

		

        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        obj.GetCCTransactionHistory('referenceId', 'SessionToken', 11);
        test.stopTest();
    }

	global class WebServiceMockImpl implements WebServiceMock {
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
		   MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element respElement 
						= new MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element();
		   respElement.CCTransactionsResponse = new MaritzCreditCardTransactionHistory.CCTransactionsResponse();
		   respElement.CCTransactionsResponse.Message = '';
		   respElement.CCTransactionsResponse.status = '';
		   response.put('response_x', respElement); 
	   }
	}
}