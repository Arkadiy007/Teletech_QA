public with sharing class UserAssignment{

    public static void evaluateAssignment(List<User_Assignment__c> userList, boolean isUpdate){
    
    Map<Id, List<String>> acctUserRoleMap = new Map<Id, List<String>>();
    Map<Id, List<User_Assignment__c>> acctUserMap = new Map<Id, List<User_Assignment__c>>();
    List<String> tempRoleLst = new  List<String>();
    List<User_Assignment__c> assignToDelete = new List<User_Assignment__c>();
    
    
    for(User_Assignment__c userAssign : userList){
        
        if(acctUserRoleMap.get(userAssign.Dealer__c) != null){
            tempRoleLst = acctUserRoleMap.get(userAssign.Dealer__c);
            tempRoleLst.add(userAssign.Employee_Role__c);
            acctUserRoleMap.put(userAssign.Dealer__c, tempRoleLst);
        }else{
            tempRoleLst = new  List<String>();
            tempRoleLst.add(userAssign.Employee_Role__c);
            acctUserRoleMap.put(userAssign.Dealer__c, tempRoleLst);
        }       
    }
    
    for(Account acc : [Select Id, Name, (Select Id, Name, Stage_User__c, Employee_Role__c From User_Assignments__r) 
                      from Account Where Id IN : acctUserRoleMap.keyset()]){
           
       if(!acc.User_Assignments__r.IsEmpty()){               
          acctUserMap.put(acc.Id, acc.User_Assignments__r);           
       }
    
    }
    
    
    for(User_Assignment__c userAssign : userList){
        
         if(acctUserMap.containsKey(userAssign.Dealer__c)){       
          for(User_Assignment__c ua : acctUserMap.get(userAssign.Dealer__c)){
               
             if(ua.Employee_Role__c == userAssign.Employee_Role__c){
                if(!isUpdate){               
                   assignToDelete.add(ua);  
                }
                if(isUpdate && ua.Id != userAssign.Id && (ua.Employee_Role__c == userAssign.Employee_Role__c)){
                    userAssign.addError('The Employee role is already present on the Account. Please update/delete the existing one.');
                }
             
             }           
          }
          
        } 
     }
     
     if(assignToDelete.size() > 0){
     Database.delete(assignToDelete, false);
     }
    
    }

}