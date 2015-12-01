/**********************************************************************
Name: Vehicle_Retail_Sale_Batch
Copyright © notice: Nissan Motor Company
======================================================
Purpose: Class to update Vehicle Retail Sale in Batches.

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj	03/16/2011 Created
***********************************************************************/

global class Vehicle_Retail_Sale_Batch implements Database.Batchable<sObject>{
    
    global class Vehicle_Retail_Sale_Data {
    	global String ownerId {get; set;}
    	global String dealerName {get; set;}
    	global String VIN {get; set;}
    }
    
    String query;
    Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data> dataMap;
    
    global Vehicle_Retail_Sale_Batch(string query, Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data> dataMap) {
    	this.query = query;
    	this.dataMap = dataMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Vehicle_Retail_Sale__c> scope) {
    	List<Vehicle_Retail_Sale__c> recordsToUpdate = new List<Vehicle_Retail_Sale__c>();
    	for (Vehicle_Retail_Sale__c rec : scope) {
    		Vehicle_Retail_Sale_Data data = dataMap.get(rec.id);
    		if (data != null) {
    			rec.Owner_Id__c = data.ownerId;
    			rec.Selling_Dealer_Name__c = data.dealerName;
    			rec.Vehicle_Identification_Number__c = data.VIN;
    			recordsToUpdate.add(rec);
    		}
    	}
    	
    	if (recordsToUpdate.size() > 0) {
    		update recordsToUpdate;
    	}	                  
    }

    global void finish(Database.BatchableContext BC){

    }
}