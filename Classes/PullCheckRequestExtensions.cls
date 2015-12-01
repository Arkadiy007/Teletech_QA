public class PullCheckRequestExtensions {
    
    private string chkId;
    public PullCheckRequestExtensions(ApexPages.StandardController controller) {
        tempChk = new Check_Request__c();
        chk = new Check_Request__c();
        useExistingAddressChk = false;
        hasError = false;
        chkId = ((Check_Request__c)controller.getRecord()).Id;
        
        String statMsg = PullCheckRequest.validatePullCheck(chkId);
        if(statMsg == 'OK'){
        loadCheckRequestData(chkId);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, statMsg));
            hasError = true;
        }
        
    }
    
    public Check_Request__c chk { get; set; }
    public Check_Request__c tempChk{get; set;}
    public String customerName { get; set; }
    public String mailToName { get; set; }
    public String mailToName1 { get; set; }
    public String mailToName2 { get; set; }
    public boolean hasError { get; set; }
   
    public boolean useExistingAddressChk { get; set; }
    
    public PageReference save(){
    
        if(!useExistingAddressChk){
            if(!validatePCfields()){
            chk.PC_Mail_To_Name__c = tempChk.PC_Mail_To_Name__c;
            chk.PC_Mail_To_Name1__c = tempChk.PC_Mail_To_Name1__c;
            chk.PC_Mail_To_Name_2__c = tempChk.PC_Mail_To_Name_2__c;
            chk.PC_Mail_To_Address__c = tempChk.PC_Mail_To_Address__c;
            chk.PC_Mail_To_City__c = tempChk.PC_Mail_To_City__c;
            chk.PC_Mail_To_Country__c = tempChk.PC_Mail_To_Country__c;
            chk.PC_Mail_To_Zip__c = tempChk.PC_Mail_To_Zip__c; 
            chk.PC_Mail_To_State__c = tempChk.PC_Mail_To_State__c != null ? tempChk.PC_Mail_To_State__c.toUpperCase(): null;
            
            
            }else{
                return null;
            }       
        }else{
        
            if(chk.PC_Reason__c == 'Federal Express' && (tempChk.PC_Phone_Number__c == null || tempChk.PC_Phone_Number__c == '')){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.PC_Phone_Number_Required));
            return null;
            }
            chk.PC_Mail_To_Name__c = '';
            chk.PC_Mail_To_Name1__c = '';
            chk.PC_Mail_To_Name_2__c = '';
            chk.PC_Mail_To_Address__c = '';
            chk.PC_Mail_To_City__c = '';
            chk.PC_Mail_To_Country__c = '';
            chk.PC_Mail_To_Zip__c = ''; 
            chk.PC_Mail_To_State__c ='';
            //chk.PC_Phone_Number__c = '';
            
        }
        chk.PC_Phone_Number__c = tempChk.PC_Phone_Number__c;
        
        try{
           Database.saveResult savResult = Database.update(chk, false);
           
           if(savResult.isSuccess()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Record saved successfully!'));
                PageReference pgRef = new PageReference('/'+chkId);
                return pgRef;
           }else{
               if(savResult.getErrors()[0] != null){
                 String errMsg = savResult.getErrors()[0].getMessage(); 
                   if(errMsg.contains(Label.Valid_PC_Zip_Code)){    
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Valid_PC_Zip_Code));
                   }
                   else if(errMsg.contains(Label.Valid_PC_Zip_Code_Canada)){    
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Valid_PC_Zip_Code_Canada));
                   }
                   else{
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured while saving.'));
                   }
              }
           }
           
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ex.getMessage()));            
        }
    
        return null;
    }
    
    public PageReference cancel(){
        PageReference pgRef = new PageReference('/'+chkId);        
        return pgRef;
    }
    
    public PageReference evaluatePCFields(){
        if(useExistingAddressChk){
            tempChk.PC_Mail_To_Name__c = '';
            tempChk.PC_Mail_To_Name1__c = '';
            tempChk.PC_Mail_To_Name_2__c = '';
            tempChk.PC_Mail_To_Address__c = '';
            tempChk.PC_Mail_To_City__c = '';
            tempChk.PC_Mail_To_Country__c = '';
            tempChk.PC_Mail_To_Zip__c = '';
            tempChk.PC_Mail_To_State__c = '';
           // tempChk.PC_Phone_Number__c = '';
        }
        
        System.debug('tempChk:::'+tempChk);
                 
        return null;
    }
    
    private void loadCheckRequestData(String chkId){        
         
        chk = [SELECT Id, PC_Reason__c, Address__c, City__c, State__c, Zip__c, PC_Mail_To_Name__c, PC_Mail_To_Name1__c, PC_Mail_To_Name_2__c, PC_Phone_Number__c,
                      PC_Mail_To_Address__c, PC_Mail_To_City__c, PC_Mail_To_Country__c, PC_Mail_To_Zip__c, Business_Name_1__c, Business_Name_2__c,
                      Payable_To_First_Name__c, Payable_To_Last_Name__c, PC_Mail_To_State__c, Case__r.Contact.HomePhone 
               FROM Check_Request__c where Id =: chkId];
               
        if(chk != null){
            if(chk.Payable_To_First_Name__c != null){
                customerName = chk.Payable_To_First_Name__c +' ';
            }
            if(chk.Payable_To_Last_Name__c != null){
                customerName += chk.Payable_To_Last_Name__c;
            }           
            if(customerName != null && customerName != ''){
             mailToName = customerName; 
             mailToName1 = chk.Business_Name_1__c;
             mailToName2 = chk.Business_Name_2__c;           
            }else{
              mailToName = chk.Business_Name_1__c;
              mailToName1 = chk.Business_Name_2__c;
            }
            
           
            tempChk.PC_Mail_To_Name__c = chk.PC_Mail_To_Name__c;
            tempChk.PC_Mail_To_Name1__c = chk.PC_Mail_To_Name1__c;
            tempChk.PC_Mail_To_Name_2__c = chk.PC_Mail_To_Name_2__c;
            tempChk.PC_Mail_To_Address__c = chk.PC_Mail_To_Address__c;
            tempChk.PC_Mail_To_City__c = chk.PC_Mail_To_City__c;
            tempChk.PC_Mail_To_Country__c = chk.PC_Mail_To_Country__c;
            tempChk.PC_Mail_To_State__c = chk.PC_Mail_To_State__c != null ? chk.PC_Mail_To_State__c.toUpperCase() : null;
            tempChk.PC_Mail_To_Zip__c = chk.PC_Mail_To_Zip__c;
            tempChk.PC_Phone_Number__c = chk.PC_Phone_Number__c == null && chk.PC_Reason__c == null ? chk.Case__r.Contact.HomePhone : chk.PC_Phone_Number__c;
            
        }
    
    }
    
    private boolean validatePCfields(){
        boolean isError = false;
        
        if((tempChk.PC_Mail_To_Name__c == '' || tempChk.PC_Mail_To_Name__c == null) || (tempChk.PC_Mail_To_Address__c == null || tempChk.PC_Mail_To_Address__c == '') 
            || (tempChk.PC_Mail_To_Country__c == null || tempChk.PC_Mail_To_Country__c =='') || (tempChk.PC_Mail_To_State__c == '' || tempChk.PC_Mail_To_State__c == null) 
            || (tempChk.PC_Mail_To_Zip__c == '' || tempChk.PC_Mail_To_Zip__c == null) || (tempChk.PC_Mail_To_City__c == '' || tempChk.PC_Mail_To_City__c == null)){            
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.PC_Mailing_Address));
               isError = true;
        }
        
        if(chk.PC_Reason__c == 'Federal Express' && (tempChk.PC_Phone_Number__c == null || tempChk.PC_Phone_Number__c == '')){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.PC_Phone_Number_Required));
            isError = true;
        
        }
        
         // Look for matches in the State__c to the PC State and check if
        // matching state abbreviations is present.
        List<State__c> matches = new List<State__c>();
        if (tempChk.PC_Mail_To_State__c != '' && tempChk.PC_Mail_To_State__c != null) {
            matches = [select id, name, name__c from state__c where name =: tempChk.PC_Mail_To_State__c];
            
            if(matches.size() <= 0){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Valid_PC_Mail_to_State));
               isError = true;
            }
        }
       
        return isError;
    }
    
}