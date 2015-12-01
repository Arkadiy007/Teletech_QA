public class AutoCaseAssignmentExtensions {
    
    List<Case> caEmailNissanCaseList = new List<Case>();
    List<Case> myAssignedCases = new List<Case>();
    
    public Integer caNissanCases{get; set;}
    public List<Case> myTotalAssignedCases{get; set;}    
    
    public AutoCaseAssignmentExtensions(ApexPages.StandardController controller) {
        myAssignedCases = new List<Case>();
        myTotalAssignedCases = new List<Case>();
        loadQueueData();        
    }
    
    
    public void loadQueueData(){
    
        caNissanCases = 0;
        myAssignedCases.clear();
        myTotalAssignedCases.clear();
        
        Group grp = [select Id from Group where Name =: Label.CA_Email_Nissan and Type = 'Queue' Limit 1];
        
        for(Case cas : [Select Id, CaseNumber, Status from Case where OwnerId =: UserInfo.getUserId() AND Status != 'Closed']){
            myTotalAssignedCases.add(cas);
            if(cas.Status != 'Pending'){
                myAssignedCases.add(cas);
            }
        }
        caEmailNissanCaseList = [Select Id, OwnerId, Status from Case where OwnerId =: grp.Id AND Status != 'Closed' Order By CreatedDate];
        
        if(caEmailNissanCaseList.size() > 0){
           caNissanCases = caEmailNissanCaseList.size();
        }
        
    }
    
    public PageReference assignCase(){  
        
        if(myAssignedCases.size() > 0){        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.Cases_Already_Assigned));            
        }else{
            if(caEmailNissanCaseList.size() <= 0){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Empty_Queue_Cases)); 
            }else{
            try{
            caEmailNissanCaseList = [Select Id, OwnerId, Status from Case where Owner.Name =: Label.CA_Email_Nissan AND Status != 'Closed' Order By CreatedDate];
            if(caEmailNissanCaseList.size() > 0){
                caEmailNissanCaseList[0].OwnerId = UserInfo.getUserId();
                update caEmailNissanCaseList[0];
            }
            loadQueueData();
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ex.getMessage()));  
            }
            }
        }      
        
        return null;
    }
    
}