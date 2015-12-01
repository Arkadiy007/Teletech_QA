/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class EQAForgotPasswordController {
	public String username { get; set; }
	public String loginPage {get {return Site.getBaseUrl() + '/EQAPortalLogin'; } set;}
	public EQAForgotPasswordController() {
		System.debug('************ in contr');
	}

	public PageReference forgotPassword() {
	System.debug('***username ' + username);
		if (username != '' || username != null) {
			System.debug('************ before success');
			boolean success = Site.forgotPassword(username);
			System.debug('************ success = ' + success);
			PageReference pr = Page.EQAForgotPasswordConfirm;
			System.debug('************ pr = ' + pr);
			pr.setRedirect(true);

			if (success) {
				return pr;
			}
		}
		return null;
	}

	public PageReference Cancel() {

		PageReference pr = Page.EQAPortalLogin;
		pr.setRedirect(true);
		return pr;

	}
	

}