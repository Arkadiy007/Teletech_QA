public with sharing class StopCheckPaymentController {
    
    String chkId;
    public Check_Request__c chk {get; set;}
    public String action{get; set;}
    public String reason{get; set;}
    public boolean isSuccess{get; set;}
    
    public StopCheckPaymentController(ApexPages.StandardController controller) {
        isSuccess = false;
        chk = new Check_Request__c();
        chkId = ((Check_Request__c)controller.getRecord()).Id;
        
        chk = [Select Id, Name, Stop_Payment_Void_Reason__c, Stop_Payment_Void_Req_Action__c, Stop_Payment_Void_Request_Date__c from Check_Request__c where Id =: chkId];
        
        if(chk != null && chk.Stop_Payment_Void_Req_Action__c != null){
         isSuccess = true;
         reason = chk.Stop_Payment_Void_Reason__c;
         action = chk.Stop_Payment_Void_Req_Action__c;
        }        
    }
    
    public PageReference saveChk(){
         ApexPages.getMessages().clear();
         if(!validateRequiredFields()){
             if(chk != null && chk.Id != null){    
                 chk.Stop_Payment_Void_Reason__c = reason;
                 chk.Stop_Payment_Void_Req_Action__c = action;
                 chk.Stop_Payment_Void_Request_Date__c = Date.today();
                 chk.Stop_Payment_Void_By__c = Userinfo.getUserId();
                 
                 try{
                     update chk;
                     isSuccess = true;
                     if(action == 'Stop Payment'){
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Stop_Payment_Success));
                     }else{
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Void_Payment_Success));
                     }                     
                     
                 }catch(Exception ex){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
                 }   
                 
             }
         }
         
         return null;   
    }
    
    public List<SelectOption> getReqActions()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =  Check_Request__c.Stop_Payment_Void_Req_Action__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       String labelOption = '';
       
       for( Schema.PicklistEntry f : ple)
       {
          labelOption = f.getLabel(); 
          System.debug('f.getLabel()::'+f.getLabel()+'--f.getValue()--'+f.getValue());
          if(labelOption == 'Stop Payment'){
              labelOption += ' (physical check is missing)';
          }else if(labelOption == 'Void'){
              labelOption += ' (physical check is here)';
          }else if(labelOption == 'Check Trace'){
              labelOption += ' (has check been cashed?)';
          }
          options.add(new SelectOption(f.getValue(), labelOption));
       }       
       return options;
    }
    
    
    
    public List<SelectOption> getReasonItems(){
       List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =  Check_Request__c.Stop_Payment_Void_Reason__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', '--None--'));
                    
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));          
       } 
             
       return options;
    
    }
    
    public PageReference cancel(){
        PageReference pgRef = new PageReference('/'+chkId);        
        return pgRef;
    }
    
    public boolean validateRequiredFields(){
        boolean isError = false;
        if(action == null || action == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Requested Action.'));
            isError = true;
        }
        
        System.debug('reason:::'+reason);
        if(reason == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Reason.'));
            isError = true;
        }
        
        return isError;
    }

}