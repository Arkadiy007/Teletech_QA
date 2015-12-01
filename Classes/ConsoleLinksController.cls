public with sharing class ConsoleLinksController {
    
    public String linkUrl {get; set;}
    
    public List<MCC_Console_Links__mdt> infinitiConLinks{get; set;}
    public List<MCC_Console_Links__mdt> nissanConLinks{get; set;}
    
    public PageReference launchNissan(){
        
        PageReference pgRef = new PageReference(linkUrl);
        return pgRef;
    }
    
    public ConsoleLinksController(){
        infinitiConLinks = new List<MCC_Console_Links__mdt>();
        nissanConLinks = new List<MCC_Console_Links__mdt>();
        
        for(MCC_Console_Links__mdt link :  [Select Id, MasterLabel, Link_URL__c, Infiniti_Link__c From MCC_Console_Links__mdt]){
                
          if(link.Infiniti_Link__c){
              infinitiConLinks.add(link);
          }else{
              nissanConLinks.add(link);
          }
        }
        
    }    
    
}