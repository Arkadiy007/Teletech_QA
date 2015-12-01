@isTest
private class NNALeadServicesHandler_Test {

	static testmethod void testCallLeadService() { 
		NNALeadServicesHandler.LeadApprovalResponse nl;
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new NNALeadServicesHandler_Test.MockHttpResponseGenerator());
		String xml = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
		'<s:Body>' +
		'<QueryLeadStatus xmlns="http://www.uslqs.com/LeadServices/1">' +
		'<leadGuidID>1111111</leadGuidID>' +
		'</QueryLeadStatus>' +
		'</s:Body>' +
		'</s:Envelope>';
		nl = NNALeadServicesHandler.callLeadService(xml);

		test.stopTest();
		System.assertEquals('1111111', nl.LeadGUId);
		System.assertEquals('301', nl.ResponseCode);
		System.assertEquals('test1', nl.ResponceDetail);
		System.assertEquals('11', nl.ResponseTime);
	}
	static testmethod void testCallLeadSoapService() {
		NNALeadServicesHandler.LeadApprovalResponse nls;
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new NNALeadServicesHandler_Test.MockHttpResponseGenerator());
		String GUIdSoap = '1111112';
		nls = NNALeadServicesHandler.callLeadSoapService(GUIdSoap);

		test.stopTest();
		System.assertEquals('1111112', nls.LeadGUId);
		System.assertEquals('302', nls.ResponseCode);
		System.assertEquals('test2', nls.ResponceDetail);
		System.assertEquals('12', nls.ResponseTime);
	}

	public class MockHttpResponseGenerator implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			if (req.getBody().contains('1111111'))
			res.setBody('<LeadGUId>1111111</LeadGUId><ResponseTime>11</ResponseTime><ResponseCode>301</ResponseCode><ResponseDetails>test1</ResponseDetails>');
			if (req.getBody().contains('1111112'))
			res.setBody('<LeadGUId>1111112</LeadGUId><ResponseTime>12</ResponseTime><ResponseCode>302</ResponseCode><ResponseDetails>test2</ResponseDetails>');
			return res;
		}
	}


}