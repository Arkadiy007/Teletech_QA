public class WarrantyComments_Controller {

Public String cmts {get;set;}
    Public Warranty_Case__c wc {get;set;}
    Public List<selectOption> options {get;set;}
    Public String commentType {get;set;}

    public WarrantyComments_Controller(ApexPages.StandardController controller) {
    
        wc = [select Id, Internal_Comments__c, External_Comments__c from Warranty_Case__c where Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        options = new List<selectOption>();
        options.add(new selectOption('Internal', 'Internal'));
        options.add(new selectOption('External', 'External'));
    
    }
    
    
    Public Pagereference Go(){
        String now = String.ValueOf(system.now());
        
        if(commentType == 'Internal'){
    
        if(wc.Internal_Comments__c== null){
            wc.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            wc.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update wc;
        }
        
         if(commentType == 'External'){
    
        if(wc.External_Comments__c == null){
            wc.External_Comments__c = '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            wc.External_Comments__c += '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update wc;
        }
        
        Pagereference p = new Pagereference('/'+wc.Id);
     
         return p;
    
    }
    
    public PageReference oncancel(){
        Pagereference p = new Pagereference('/'+wc.Id);
     
         return p;
    }
}