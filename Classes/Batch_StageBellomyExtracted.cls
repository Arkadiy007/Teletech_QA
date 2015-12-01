/**********************************************************************
Name: Batch_StageBellomyExtracted
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Updating all cases to Extracted. 
         Scheduled to be run on every Thursday 8 am CST.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        08/24/2014    Created

***********************************************************************/
global class Batch_StageBellomyExtracted implements Database.Batchable<sObject>, Schedulable {
    global String query;
   
    public static String getQuery() {
        return 'SELECT Id, Batch_Status__c FROM StageBellomyCases__c where Batch_Status__c != \'Extracted\'';
    }
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
               
        return Database.getQueryLocator(query);
    } 
    
      
    global void execute(Database.BatchableContext BC, List<StageBellomyCases__c> lstBelCases) {        
       List<StageBellomyCases__c> casesToUpdate = new List<StageBellomyCases__c>();
       
       for(StageBellomyCases__c cas : lstBelCases){  
           cas.Batch_Status__c = 'Extracted';        
           casesToUpdate.add(cas);                           
       }
        if(casesToUpdate.size() > 0){
            Database.update(casesToUpdate, false);
        
        }
    }  
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){  
        
    } 
    
    global void execute(SchedulableContext SC) {       
        Batch_StageBellomyExtracted scheduleJob = new Batch_StageBellomyExtracted();
        Database.executeBatch(scheduleJob);
        
    }
    
}