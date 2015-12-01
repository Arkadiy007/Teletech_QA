public class NNALeadServiceClient { 
	public static String getLeadGuidResponce(String XMLBody){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		
		req.setEndpoint(Label.Case_Send_to_Dealer_URL);
		req.setHeader('Action', 'ProcessAdfPox');
		req.setHeader('Content-Type', 'text/xml; charset=utf-8');
		req.setMethod('POST');
		req.setBody(XMLBody);

		HttpResponse res = h.send(req);
		return res.getBody();
	}

	public static String queryLeadStatus(String XMLBody){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
	
		req.setEndpoint(Label.Case_Query_Lead_Status_URL);
		req.setHeader('SOAPAction', 'QueryLeadStatus');
		req.setHeader('Content-Type', 'text/xml; charset=utf-8');
		req.setMethod('POST');
		req.setBody(XMLBody);
		System.DEBUG(XMLBody);
		HttpResponse res = h.send(req);
		System.DEBUG(res);
		return res.getBody();
	}
}