global with sharing class NNAPortalLogin {
 
  //set username/ password variables via page
    global String username {get; set;}
    global String password {get; set;}
 
    global NNAPortalLogin () {
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
    }
    
    global PageReference login() {
 		
     	PageReference p = Site.login(username, password, Label.NNA_Portal);
 		
        //if p==null, no login
        if (p == null) {
              return null;
        } else {
              return p;
        }
    }
 
    //test data provided by salesforce

 
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        NNAPortalLogin controller = new NNAPortalLogin ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';
 
        System.assertEquals(controller.login(),null);
    }

}