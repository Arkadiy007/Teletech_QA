/**********************************************************************
Name: DailyApiLimits_Controller_Tests
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests the Apex class DailyApiLimits_Controller.

Related Class : DailyApiLimits_Controller
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina 6/16/15 Created
***********************************************************************/

@isTest
public class DailyApiLimits_Controller_Tests {

	static testMethod void TestApiLimits() {
		DailyApiLimits_Controller controller = new DailyApiLimits_Controller();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		List<DailyApiLimits_Controller.ApiLimit> apiLimits = controller.getapiLimits();
		System.assert(null != apiLimits);
	}
	
	public class MockHttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
	 
		public HTTPResponse respond(HTTPRequest req) {
		string url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/limits/';
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals(url, req.getEndpoint());
			System.assertEquals('GET', req.getMethod());
        
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"ConcurrentAsyncGetReportInstances":{"Max":200,"Remaining":200},"ConcurrentSyncReportRuns":{"Max":20,"Remaining":20}}');
			res.setStatusCode(200);
			return res;
		}
	}
}