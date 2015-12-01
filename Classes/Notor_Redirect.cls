public class Notor_Redirect {
	public String redirectUrl {get; set;}
	
	public Notor_Redirect() {
		User currentUser = [SELECT Notor_Id__c
			FROM User
			WHERE Id = :UserInfo.getUserId()];
			
		redirectUrl = System.Label.Notor_Redirect_URL +
			currentUser.Notor_Id__c;  
	}
	
	public PageReference getUrlForRedirecting() {
		redirectUrl = 'www.maritz.com?userId=' + Userinfo.getUserId();
		
		ApexPages.Message msg = new ApexPages.Message(
			ApexPages.Severity.WARNING, 'This page will redirect you to ' + redirectUrl);
	    ApexPages.addMessage(msg);
	    
	    //PageReference pageRef = new PageReference(redirectUrl);
        //pageRef.setRedirect(true);
        //return pageRef;
        
        return null;
	}
}