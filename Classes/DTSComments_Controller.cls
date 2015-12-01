public class DTSComments_Controller {

    Public String cmts {get;set;}
    Public DTS_Field_Inspection__c dts {get;set;}
    Public List<selectOption> options {get;set;}
    Public String commentType {get;set;}

    public DTSComments_Controller(ApexPages.StandardController controller) {
    
        dts = [select Id, Internal_Comments__c, External_Comments__c from DTS_Field_Inspection__c where Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        options = new List<selectOption>();
        options.add(new selectOption('Internal', 'Internal'));
        options.add(new selectOption('External', 'External'));

    }
    
    Public Pagereference Go(){
        String now = String.ValueOf(system.now());
        
        if(commentType == 'Internal'){
    
        if(dts.Internal_Comments__c== null){
            dts.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            dts.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update dts;
        }
        
         if(commentType == 'External'){
    
        if(dts.External_Comments__c == null){
            dts.External_Comments__c = '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            dts.External_Comments__c += '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update dts;
        }
        
        Pagereference p = new Pagereference('/'+dts.Id);
     
         return p;
    
    }
    
    public PageReference oncancel(){
    Pagereference p = new Pagereference('/'+dts.Id);
     
     return p;
    }

}