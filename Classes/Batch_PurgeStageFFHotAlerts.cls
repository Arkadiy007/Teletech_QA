/**********************************************************************
Name: Batch_PurgeStageFFHotAlerts
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Deletion of Stage FF Hot Alerts which are  
         created past 30 days
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        07/24/2014    Created

***********************************************************************/
global class Batch_PurgeStageFFHotAlerts implements Database.Batchable<sObject>, Schedulable {
    global String query;
   
    public static String getQuery() {
        return 'SELECT Id FROM Stage_FF_Hot_Alerts__c where CreatedDate < LAST_N_DAYS:'+Label.Days_to_Purge_Hot_Alerts;
    }
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        
        
        if(Test.isrunningTest()){
            query += ' LIMIT 100';
        }
               
        return Database.getQueryLocator(query);
    } 
    
      
    global void execute(Database.BatchableContext BC, List<Stage_FF_Hot_Alerts__c > lstFFHotAlerts) {        
      
        if(lstFFHotAlerts.size() > 0){
            Database.delete(lstFFHotAlerts, false);        
        }
    }  
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){  
        
    } 
    
    global void execute(SchedulableContext SC) {       
        Batch_PurgeStageFFHotAlerts  scheduleJob = new Batch_PurgeStageFFHotAlerts();
        Database.executeBatch(scheduleJob);
        
    }
    
}