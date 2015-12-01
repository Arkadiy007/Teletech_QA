/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class NissanChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
   	public NissanChangePasswordController() {}
    
   	public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        NissanChangePasswordController controller = new NissanChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}