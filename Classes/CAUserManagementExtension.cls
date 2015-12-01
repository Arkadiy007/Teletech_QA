/*************************************************************************************
Name: CAUserManagementExtension 
=======================================================================================
History: 

VERSION AUTHOR         DATE         DETAIL 
1.02 - Vivek Batham   2/09/2015    Created Extension Class to Search and Update CA
                                   Profile user's information
****************************************************************************************/

public class CAUserManagementExtension {
    
    public User userObj{get; set;}
    public Account acct{get; set;}
    public Account userMgracct{get; set;}
    public List<User> userList{get; set;}
    
    public CAUserManagementExtension(ApexPages.StandardController controller) {
        acct = new Account();
        userMgracct = new Account();
        userList = new List<User>();
    }
    
    public void userDisplay(){
        
        SearchUser();      
        
    }
    
    public void updateUser(){
        if(userList.size() > 0 && !validateUser(userList)){
           
            try{
            update userList;
            } catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            }
            SearchUser();           
        }    
    }
    
    public boolean validateUser(List<User> usrList){
        
        boolean isError = false;        
        User usr;
        
        if(userMgracct.RCAS__c != null){
              usr = [Select id, profile.name from User where Id =:userMgracct.RCAS__c limit 1];
              if(!usr.profile.name.startswith('CA')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Assigning_Manager_Profile));
                isError = true;              
              }
        }
                        
        for(User u : usrList){
                if(usr != null && usr.profile.name.startswith('CA')){
                        u.ManagerId = userMgracct.RCAS__c;
                }
                
                if(u.ZCA_Id__c != null){
                    if(u.ZCA_Id__c.length() != 7){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.ZCA_Character_Limit));
                        isError = true;
                    }
                    else{
                        u.ZCA_Id__c = u.ZCA_Id__c.toUpperCase();
                    }
                }
                if(u.Segment__c == null || u.Segment__c == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Segment_Required));
                        isError = true;
                }
                if(u.Location__c == null || u.Location__c == ''){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Location_Required));
                        isError = true;
                }
        }
        
        return isError;
    }
    
    public void SearchUser(){
    
         if(acct.RCAS__c != null){
            userList = [Select Id, Name, ManagerId, Manager.Name, Segment__c, ZCA_Id__c, Location__c from User where Id =:acct.RCAS__c AND Profile.Name like 'CA%'];    
            
            if(userList.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, label.Valid_CA_User));  
            }
            
        }else{
        
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Select_User));  
        }
    }

}