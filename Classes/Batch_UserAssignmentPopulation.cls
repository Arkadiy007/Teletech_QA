/**********************************************************************
Name: Batch_UserAssignmentPopulation 
Copyright © notice: Nissan Motor Company.
=====================================================================
Purpose: Populate User Assignment records from Account and Stage User.
         This job will only be used once.
=====================================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        01/07/2014    Created

***********************************************************************/
global class Batch_UserAssignmentPopulation implements Database.Batchable<sObject>{
    // String of query for all creatable fields on Case
    global String query;
   
    public static String getQuery() {
    
        return 'SELECT Id, SR_DTS_Stage_User__c, RGM_Stage_User__c, ORM_CSM_Stage_User__c, FOM_Stage_User__c, EVOM_Stage_User__c, LPM_Stage_User__c,'+ 
               +' DTS_B_Stage_User__c, DTS_A_Stage_User__c, DOM_Stage_User__c, DMC_Stage_User__c, COM_Stage_User__c, AGM_Stage_User__c FROM Account'
               +' WHERE RecordType.Name = \'Dealer\' AND ( SR_DTS_Stage_User__c != null OR RGM_Stage_User__c != null OR ORM_CSM_Stage_User__c != null OR FOM_Stage_User__c != null OR'
               +' EVOM_Stage_User__c != null OR DTS_B_Stage_User__c != null OR DTS_A_Stage_User__c != null OR DOM_Stage_User__c != null OR'
               +' LPM_Stage_User__c != null OR DMC_Stage_User__c != null OR COM_Stage_User__c != null OR AGM_Stage_User__c != null ) LIMIT 20';
    }
    
     // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        return Database.getQueryLocator(query);    
    } 
    
    global void execute(Database.BatchableContext BC, List<Account> lstAccounts) {
        
        List<User_Assignment__c> userList = new List<User_Assignment__c>();
        User_Assignment__c userAssign;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        for(Account acc : lstAccounts){
            
            if(acc.AGM_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'AGM', Stage_User__c = acc.AGM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.SR_DTS_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'SR DTS', Stage_User__c = acc.SR_DTS_Stage_User__c);
                userList.add(userAssign);
            }if(acc.ORM_CSM_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'ORM', Stage_User__c = acc.ORM_CSM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.FOM_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'FOM', Stage_User__c = acc.FOM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.EVOM_Stage_User__c!= null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'EVOM', Stage_User__c = acc.EVOM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.LPM_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'DTS B', Stage_User__c = acc.LPM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.DTS_B_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'DTS B', Stage_User__c = acc.DTS_B_Stage_User__c);
                userList.add(userAssign);
            }if(acc.DTS_A_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'DTS A', Stage_User__c = acc.DTS_A_Stage_User__c);
                userList.add(userAssign);
            }if(acc.DOM_Stage_User__c != null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'DOM', Stage_User__c = acc.DOM_Stage_User__c);
                userList.add(userAssign);
            }if(acc.DMC_Stage_User__c!= null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'DMC', Stage_User__c = acc.DMC_Stage_User__c);
                userList.add(userAssign);
            }if(acc.COM_Stage_User__c!= null){
                userAssign = new User_Assignment__c(Dealer__c = acc.Id, Employee_Role__c = 'COM', Stage_User__c = acc.COM_Stage_User__c);
                userList.add(userAssign);
            }        
        }
        
        if(!userList.isEmpty()){
           Database.SaveResult[] dbResults = Database.insert(userList, false);   
           
             // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < userList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = userList[row].Id,
                                    Record_Type__c = 'Account',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_UserAssignmentPopulation', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }     
        }
        
    }  
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){ 
        
    } 
    
 }