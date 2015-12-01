/**********************************************************************
Name: Batch_UserLicence_Calculation
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class is used to calculate the license cost on each individual active user.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vivek Batham         06/26/2011 Initial Creation
***********************************************************************/
global class Batch_UserLicence_Calculation implements Database.Batchable<sObject> {
    private static final Integer CUTOFF_YEARS = 5;
    
    // String of query for all creatable fields on Case
    global String query;
   
    public static String getQuery() {
    	String soql = 'Select Id, UserType, IsActive, ProfileId, Profile.UserLicense.Name,  Cost_Center__c, '+
               'LastLoginDate, UserPermissionsKnowledgeUser, UserPermissionsLiveAgentUser,  Profile.Name, '+
               'SF_License__c, License_Cost_Per_Month__c FROM User WHERE IsActive = TRUE AND Cost_Center__c != \'Partner Portal\'';
        
        if(Test.isRunningTest()){
        	soql += ' LIMIT 100';
        }
        
        return soql;
    }

    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned: Insert records to be deleted into Stage_Case
    // and delete the Case record and all associated records.
    global void execute(Database.BatchableContext BC, List<User> lstUsers) {    
        decimal licCost = 0.0;
        List<User> usrsToUpdate = new List<User>();
        for(User usr : lstUsers){
            licCost = 0.0;        
            if(usr.UserType == 'Standard' || usr.Profile.UserLicense.Name == 'Salesforce'){
                licCost += 83.00;            
            }else if((usr.UserType == 'PowerPartner' || usr.Profile.UserLicense.Name == 'Gold Partner')
                  && (!(usr.Profile.Name.contains('Dealer') || usr.Profile.Name.contains('Infiniti')))){
                licCost += 9.22;  
            }
            
            if(usr.UserPermissionsKnowledgeUser){
                 licCost += 9.00; 
            }
            if(usr.UserPermissionsLiveAgentUser){
                licCost += 20;
            }
            
            usr.License_Cost_Per_Month__c = licCost;
            usrsToUpdate.add(usr); 
        }
        
        System.debug('usrsToUpdate:::'+usrsToUpdate);
        
        if(usrsToUpdate.size() > 0){
            Database.update(usrsToUpdate, false);
        }
    }
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}