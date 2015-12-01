/**********************************************************************
Name: WS_SSLCG_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for WS_SSLCG.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 02/28/2011 Created 
***********************************************************************/
@isTest
private global class WS_SSLCG_Test  {
    
    static testmethod void testCreate() {
        WS_SSLCG.SoapSsoAuthServicePort obj = new WS_SSLCG.SoapSsoAuthServicePort();
        WS_SSLCG.createResponse  obj1 = new WS_SSLCG.createResponse ();
        WS_SSLCG.authAndPersonTO  obj2 = new WS_SSLCG.authAndPersonTO  ();
        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        obj.create('authLogin', 'personHashId', 11);
        test.stopTest();
    }
    
    static testmethod void testValidate() {
        WS_SSLCG.SoapSsoAuthServicePort obj = new WS_SSLCG.SoapSsoAuthServicePort();
        WS_SSLCG.validateResponse obj1 = new WS_SSLCG.validateResponse();
        test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        obj.validate('token');
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
		   WS_SSLCG.createResponse respElement = new WS_SSLCG.createResponse();
		   respElement.token = '';
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
		   WS_SSLCG.validateResponse respElement = new WS_SSLCG.validateResponse();
		   respElement.return_x = new WS_SSLCG.authAndPersonTO();
		   response.put('response_x', respElement); 
	   }
	}
}