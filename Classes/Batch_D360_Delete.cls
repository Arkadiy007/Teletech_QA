/**********************************************************************
Name: Batch_D360_Delete
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Class deletes detail records to be replaced by new
records and calculated on the Dealer Case Summary
table for use in the D360 REST API.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/04/2014 Created
***********************************************************************/
global class Batch_D360_Delete implements Database.Batchable<sObject>{

global final String Query;
                             
global Batch_D360_Delete(){
    
    String months = system.Label.D360Months;
    
    Query = 'Select Id from Closed_Dealer_Case_Detail__c Where Case_Closed_Date__c = Last_n_Months:'+months+
        ' or Case_Closed_Date__c = This_Month';
}

global Database.QueryLocator start(Database.BatchableContext BC){return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC,List<Closed_Dealer_Case_Detail__c> scope){
    
     
    try{
    delete scope;
    }
    catch (Exception e){
        
        Error_Log__c errors = new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_D360_Summary-Delete', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error');
        insert errors;
    }
}
    
    global void finish(Database.BatchableContext BC){
        
        id batchinstanceid = database.executeBatch(new Batch_D360_Summary(),50);
        
    }

}