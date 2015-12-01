/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class NissanSiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global String caseId {get; set;}
    global String userId {get; set;}
    global String dealerCode {get; set;}

    global NissanSiteLoginController() {
    	String userIdParam = ApexPages.currentPage().getParameters().get('userId');
    	String keyParam = ApexPages.currentPage().getParameters().get('ancryptedUserId');
    	String dealerCodeParam = ApexPages.currentPage().getParameters().get('dealerCode');
    	
    	if (userIdParam != null && keyParam != null && dealerCodeParam != null) {
            userId = userIdParam;
            password = keyParam;
            dealerCode = dealerCodeParam;
            username = Text_Util.createPortalUsername(userId, dealerCode);
        } else {
            userId = null;
            password = null;
            dealerCode = null;
            username = null;
        }
        
        System.debug('userId = ' + userIdParam + ', key = ' + keyParam + ', dealerCode = ' + dealerCodeParam + ', username = ' + username);
    }

    global PageReference redirectIfLoggedIn() {
        PageReference redirect = null;
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        String portalStartURL = System.Label.PortalStartURL;
        
        if (caseId != null) {
        	portalStartURL = '/' + caseId;
        }

        if (username != null && userId != null && password != null && dealerCode != null) {
System.debug('login username = ' + username + ', password = ' + password + ', dealerCode = ' + dealerCode);
            redirect = Site.login(username, password, portalStartURL);
        }
System.debug('redirect = ' + redirect);
if (ApexPages.hasMessages()) {
    System.debug('messages = ' + ApexPages.getMessages());
}
        return redirect;
    }

    global PageReference login() {
    	String startURL = System.Label.PortalStartURL;
    	String startURLParam = ApexPages.currentPage().getParameters().get('startURL');
    	if (startURLParam != null) {
    		// Get the Case Id after the "nissandealerportal" portion of the URL.
            startURL = startURLParam.substring(Site.getPrefix().length() + 1);
    	}

    	caseId = ApexPages.currentPage().getParameters().get('caseId');

    	if (caseId != null && caseId != '') {
            startURL = '/' + caseId;
    	}
    	
    	String portalUsername = Text_Util.createPortalUsername(username, dealerCode);
System.debug('login username = ' + portalUsername + ', password = ' + password);
    	PageReference pr = Site.login(portalUsername, password, startURL);
        if (ApexPages.hasMessages()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Dealer_Portal_Login_Error));
        }
System.debug('pr = ' + pr);
if (ApexPages.hasMessages()) {
    System.debug('messages = ' + ApexPages.getMessages());
}
        return pr;
    }
    
    global static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        NissanSiteLoginController controller = new NissanSiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}