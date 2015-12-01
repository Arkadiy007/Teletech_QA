public class DailyApiLimits_Controller {
	private static string url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/limits/';
	@TestVisible
	List<ApiLimit> apiLimits = new List<ApiLimit>();

	public List<ApiLimit> getapiLimits(){	
	// Instantiate a new http object
        Http h = new Http();

         // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer ' + userInfo.getSessionId());//'C1VaBofzvcXpn3UUnRT4L6h2u');
		System.debug(userInfo.getSessionId());
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
        string jsonInput = res.getBody();
        System.debug(JSON.deserializeUntyped(jsonInput));
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
		apiLimits = new List<ApiLimit>();
        for(String key : m.keySet()){
			ApiLimit apiLimitItem = new ApiLimit();
			apiLimitItem.limitName = key;
			Map<String, Object> dim = (Map<String, Object>)m.get(key);
			apiLimitItem.limitReamain = (String.valueOf(dim.get('Remaining')));
			apiLimitItem.limitMax = (String.valueOf(dim.get('Max')));
			apiLimits.add(apiLimitItem);
		}	
		return apiLimits;
	}
	@TestVisible
	class ApiLimit{
		public String limitName{get;set;}
		public String limitMax{get;set;}
		public String limitReamain{get;set;}
	}

}