/**
 * An apex page controller that prompts the user to accept Chatter Terms of use.
 */
global with sharing class Controller_ChatterTerms {
    global Controller_ChatterTerms() {
    }

    global PageReference acceptTerms() {
        User u = [select Id, Chatter_Terms_Accepted_Date__c from User where Id = :UserInfo.getUserId()];
        if (u.Chatter_Terms_Accepted_Date__c == null) {
            u.Chatter_Terms_Accepted_Date__c = System.now();
            update u;
        }
        PageReference ref = new PageReference('/apex/ChatterTermsConfirmation');
        return ref;
    }
    
    global static testMethod void testControllerChatterTerms () {
        Test.startTest();
            // Instantiate a new controller with all parameters in the page
            Controller_ChatterTerms controller = new Controller_ChatterTerms();
            controller.acceptTerms();
        Test.stopTest();
    }    
}