public with sharing class ClaimFormThankYouController {

    public String caseNumber { get; set; }
    public boolean isSuccess {get; set;}
    
    public ClaimFormThankYouController(){
        
        if(apexpages.currentpage().getparameters().get('caseNum') != null){
            caseNumber = apexpages.currentpage().getparameters().get('caseNum');
            isSuccess = true;
        }else{
            isSuccess = false;
        }
        
    }
}