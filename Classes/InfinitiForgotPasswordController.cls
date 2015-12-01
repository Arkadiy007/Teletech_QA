/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class InfinitiForgotPasswordController {
    public String username {get; set;}   
       
    public InfinitiForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.InfinitiForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
  	
  	 public static testMethod void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	InfinitiForgotPasswordController controller = new InfinitiForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}