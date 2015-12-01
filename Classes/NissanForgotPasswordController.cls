/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class NissanForgotPasswordController {
    public String username {get; set;}   
       
    public NissanForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.NissanForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
  	
  	 public static testMethod void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	NissanForgotPasswordController controller = new NissanForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}