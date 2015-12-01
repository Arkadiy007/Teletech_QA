/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class NNAForgotPasswordController {
    public String username {get; set;}   
       
    public NNAForgotPasswordController() {}
    
    public PageReference forgotPassword() {
    if(username != '' || username != null){
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.NNAForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        }
        return null;
    }
    
    public PageReference Cancel() {
    
    PageReference pr = Page.NNAPortalLoginPage;
    pr.setRedirect(true);
    return pr;
    
    }
    
    
    public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        NNAForgotPasswordController controller = new NNAForgotPasswordController();
        controller.username = 'test@test.com';
        controller.forgotPassword();  
        controller.Cancel();                
        
        //System.assertEquals(controller.NNAForgotPasswordController(),null);                           
    }    

  
     
}