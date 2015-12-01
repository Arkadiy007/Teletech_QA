/*************************************************************************************
Name: RCASSearchExtension 
=======================================================================================
History: 

VERSION AUTHOR         DATE         DETAIL 
1.02 - Vivek Batham   1/30/2015    Created Extension Class to Search and Reassign Dealer
                                   Accounts in bulk as provided by the user
****************************************************************************************/

public with sharing class RCASSearchExtension {
    
    public String regionCode {get; set;}
    public String districtCode {get; set;}   
    public List<AccountWrapper> acctList{get; set;}
    public Account userAcct{get; set;}
    
    
    public RCASSearchExtension(ApexPages.StandardController controller) {
        acctList = new List<AccountWrapper>();
        userAcct = new Account();
    }
    
    public PageReference search(){
        
        if(regionCode == '' && districtCode == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter a Region or District Code to Search'));
            return null;
        }
        
        SearchAccounts();
       
       
       return null;
    }
    
    public PageReference reAssignAccounts(){
    
        List<Account> acctsToUpdate = new List<Account>();
        
        if(acctList.size() <=0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please perform the search first using the Region Code OR District Code'));
            return null;  
        }
        if(userAcct.RCAS__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter a RCAS User to Reassign to'));
            return null;        
        }
        
        for(AccountWrapper accWrap : acctList){
            
            if(accWrap.selAcct){
                if(accWrap.acctObj.RCAS__c != userAcct.RCAS__c){
                    accWrap.acctObj.RCAS__c = userAcct.RCAS__c;
                    acctsToUpdate.add(accWrap.acctObj);
                }   
           }     
                         
        }
        
        if(acctsToUpdate.size() > 0){
            Database.update(acctsToUpdate, false);
            
            SearchAccounts();
        }
    
        return null;
    }
    
    
    public void SearchAccounts(){
        acctList.clear();
        String query = 'Select Id, Name, RCAS__c, District_Code__c, Dealer_Code__c, Region_Code__c, RCAS__r.Name From Account Where RecordType.Name = \'Dealer\'';   
        
        if(regionCode != ''){
            query += ' AND Region_Code__c = \''+regionCode+ '\'';
        }  
        
        if(districtCode != ''){
           query += ' AND District_Code__c = \''+districtCode+ '\'';
        } 
        
         query += ' Limit 1000';  
        
        try{
        List<Account> accts = Database.query(query);
        for(Account acc : accts){
          acctList.add(new AccountWrapper(false, acc));        
        }
        
        if(acctList.size() <= 0){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are no records found matching the given Criteria'));  
        }
        }
        catch(Exception ex){
        
        }
    }
    
    public class AccountWrapper{
    
        public boolean selAcct {get; set;}
        public Account acctObj {get; set;}
        
        public AccountWrapper(boolean chkAcct, Account acc){
            selAcct = chkAcct;
            acctObj = acc;
        }
    
    }

}