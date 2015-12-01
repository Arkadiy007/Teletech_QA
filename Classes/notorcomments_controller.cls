public class notorcomments_controller {

    Public String cmts {get;set;}
    Public Notor__c notor {get;set;}
    Public List<selectOption> options {get;set;}
    Public String commentType {get;set;}

    public notorcomments_controller(ApexPages.StandardController controller) {
    
        notor = [select Id, Internal_Comments__c, External_Comments__c from Notor__c where Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        options = new List<selectOption>();
        options.add(new selectOption('Internal', 'Internal'));
        options.add(new selectOption('External', 'External'));
    
    }
    
    
    Public Pagereference Go(){
        String now = String.ValueOf(system.now());
        
        if(commentType == 'Internal'){
    
        if(notor.Internal_Comments__c== null){
            notor.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            notor.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update notor;
        }
        
         if(commentType == 'External'){
    
        if(notor.External_Comments__c == null){
            notor.External_Comments__c = '<b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        else{
            notor.External_Comments__c += '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+cmts;
        }
        update notor;
        }
        
        Pagereference p = new Pagereference('/'+notor.Id);
     
         return p;
    
    }
    
    public PageReference oncancel(){
        Pagereference p = new Pagereference('/'+notor.Id);
     
         return p;
    }
}