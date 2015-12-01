@istest
public class DTSComments_Controller_Test {

 public static testMethod void testComments() {
        // Instantiate a new controller with all parameters in the page

    DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c(Internal_Comments__c='Internal comments', External_Comments__c='External Comments');        
    insert dts;
    
      ApexPages.currentPage().getParameters().put('id',dts.id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(dts);

        DTSComments_Controller controller = new DTSComments_Controller(sc); 
        controller.commentType = 'Internal';
        controller.go();
        
        
    }   
    
    
    public static testMethod void testComments2() {
        // Instantiate a new controller with all parameters in the page

    DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c();        
    insert dts;
    
      ApexPages.currentPage().getParameters().put('id',dts.id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(dts);

        DTSComments_Controller controller = new DTSComments_Controller(sc); 
        controller.commentType = 'External';
        controller.go();
        
        
    }   
  


}