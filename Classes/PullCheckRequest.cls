global class PullCheckRequest{

    webservice static String validatePullCheck(String chkId){
        
        String statusMessage = '';
        
        Check_Request__c chk = [Select Id, Issue_Date__c from Check_Request__c where Id =: chkId];
        
        if(chk != null){
            if(chk.Issue_Date__c == null){
                statusMessage = 'OK';            
            }else{
                if(chk.Issue_Date__c == Date.today()){
                   integer timetoIssueDate = Datetime.now().hourGMT(); 
                   if(timetoIssueDate > 5 && timetoIssueDate < 18){
                       statusMessage = 'OK';
                   }else{
                       statusMessage = Label.Check_Cut_Off;
                   } 
                }
                else{
                   statusMessage = System.Label.Issue_Date_In_Past; 
                }
            
            }
        
        }
        
        return statusMessage;
    
    }    

}