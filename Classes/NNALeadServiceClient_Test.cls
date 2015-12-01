@isTest
private class NNALeadServiceClient_Test {
	 
	static testmethod void testgetLeadGuidResponce() {
		String res;
        test.startTest(); 
		Test.setMock(HttpCalloutMock.class, new NNALeadServiceClient_Test.MockHttpResponseGenerator()); 
		String soapXML = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
												'<s:Body>' +
													'<QueryLeadStatus xmlns="http://www.uslqs.com/LeadServices/1">' +
														'<leadGuidID>' + 'test1' + '</leadGuidID>' + 
													'</QueryLeadStatus>' +
												'</s:Body>' + 
    										'</s:Envelope>';
		 res = NNALeadServiceClient.getLeadGuidResponce(soapXML);
		test.stopTest();
	 // System.assertEquals(400, res1.getStatusCode());
	  System.assert(res.contains('test1')); 
	}
	static testmethod void testQueryLeadStatus() {
		String res;
        test.startTest(); 
		Test.setMock(HttpCalloutMock.class, new NNALeadServiceClient_Test.MockHttpResponseGenerator()); 
		String soapXML = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
												'<s:Body>' +
													'<QueryLeadStatus xmlns="http://www.uslqs.com/LeadServices/1">' +
														'<leadGuidID>' + 'test2' + '</leadGuidID>' + 
													'</QueryLeadStatus>' +
												'</s:Body>' + 
    										'</s:Envelope>';
		 res = NNALeadServiceClient.queryLeadStatus(soapXML);
		test.stopTest();
	 // System.assertEquals(400, res1.getStatusCode());
	  System.assert(res.contains('test2')); 
	}
	public class MockHttpResponseGenerator implements HttpCalloutMock 
	{
      public HTTPResponse respond(HTTPRequest req) 
        {    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
          if(req.getBody().contains('test1'))
            res.setBody('<LeadGUId>test1</LeadGUId>');
			if(req.getBody().contains('test2'))
            res.setBody('<ResponseTime>test2</ResponseTime>');

                      
            return res;
        }
    }
  }