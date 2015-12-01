public class TestingCookies {
	
	public TestingCookies() {
		
	}
	
	private final String COOKIE_NAME = 'LiveAgentSession';
    private final Integer COOKIE_DURATION = 300;
    
    public String savedValue {get;set;}
    public String retrievedValue {get;set;}
	
	
	public void createCookie() {
		try{
			savedValue = DateTime.now().format('HH:mm:ss');
			
	    	Cookie userCookie = new Cookie(COOKIE_NAME, savedValue , null,
	    		COOKIE_DURATION, false);
	    	ApexPages.currentPage().setCookies(new Cookie[] {userCookie});
	    	
	    	ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.INFO, 'Cookie successfully saved with the value ' + savedValue);
            ApexPages.addMessage(msg);
    	}
    	catch(Exception ex) {	
    		ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
    	}
	}
	
	public void retrieveCookie() {
		try {
			Cookie cookieSession = 
	    		ApexPages.currentPage().getCookies().get(COOKIE_NAME);
			if (cookieSession != null) {
			    retrievedValue = cookieSession.getValue();
			}
			
			ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.INFO, 'Cookie successfully retrieved with the value ' + retrievedValue);
            ApexPages.addMessage(msg);
		}
		catch(Exception ex) {
			ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
		}
		
		
	}
	

}