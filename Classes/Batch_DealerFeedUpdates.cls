/**********************************************************************
Name: Batch_DealerFeedUpdates
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Process the Stage Dealer records to update the
         Dealer accounts .
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        09/30/2015    Created

***********************************************************************/
global class Batch_DealerFeedUpdates implements Database.Batchable<sObject>, Database.Stateful {
    // String of query for all creatable fields on Case
    global String query;
    global Integer casesCreated;
   
    public static String getQuery() {
    
        
        return 'Select  Id, Sales_Point__c, Region_Name__c, Region_Code__c, Phone__c, OwnerId, Nissan_Rental_Car_Dealer__c,'+ 
                      +' Nissan_GTR_Dealer__c, Nissan_Commercial_Vehicle_Dealer__c, Name, NMAC_Dealer_Code__c, Longitude_Number__c,'+
                      +' Latitude_Number__c, IsDeleted, Electric_Vehicle_Dealer__c, Make_Name__c, District_Name__c, District_Code__c,'+
                      +' Dealer_Name__c, Dealer_Inactive__c, Dealer_Code__c, BillingStreet__c, BillingState__c, BillingPostalCode__c,'+ 
                      +' BillingCity__c, Batch_Status__c, Batch_Number__c, Batch_Date__c, Area__c, Area_Name__c' 
                      +' From Stage_Dealer__c where Batch_Status__c = \'New\'' ;
        
        
      
    }
    
     // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        return Database.getQueryLocator(query);    
    } 
    
    global void execute(Database.BatchableContext BC, List<Stage_Dealer__c> lstStgDealers) {
        Map<String, Stage_Dealer__c> mapStgDealers = new Map<String, Stage_Dealer__c>();
        Stage_Dealer__c stgDealer = new Stage_Dealer__c();
        List<Account> acctsToUpdate = new List<Account>();
        Id dealerRtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
    
        
        for(Stage_Dealer__c stg : lstStgDealers){
        	if(stg.Dealer_Code__c != null){
        	 mapStgDealers.put(stg.Dealer_Code__c +'_USA', stg);
        	}
        }
        
	        if(mapStgDealers.size() > 0){
	        
	        Map<Id, Account> accMap = new Map<Id, Account>([Select Id, Sales_Point__c, Region_Name__c, Region_Code__c, Phone, OwnerId, 
	        										Nissan_Rental_Car_Dealer__c, Nissan_GTR_Dealer__c, Nissan_Commercial_Vehicle_Dealer__c, Name, 
	        										NMAC_Dealer_Code__c, Longitude_Number__c, Latitude_Number__c, Electric_Vehicle_Dealer__c, Make_Name__c,
	        										District_Name__c, District_Code__c, Dealer_Inactive_Indicator__c, Dealer_Code__c, BillingStreet,
	        										BillingState, BillingPostalCode, BillingCity, Area__c, Area_Name__c, Dealer_External_Id__c 
	        										From Account WHERE RecordtypeId =: dealerRtypeId AND Dealer_External_Id__c IN : mapStgDealers.keyset()]) ;
	        
	        
	        
		        for(Account acc : accMap.values()){
		        	if(mapStgDealers.get(acc.Dealer_External_Id__c) != null){
		        	 Stage_Dealer__c stgRec = mapStgDealers.get(acc.Dealer_External_Id__c);	
		        		acc.Sales_Point__c = stgRec.Sales_Point__c;
		        		acc.Region_Name__c = stgRec.Region_Name__c;
		        		acc.Region_Code__c = stgRec.Region_Code__c;
		        		acc.Phone = stgRec.Phone__c;
		        		acc.Nissan_Rental_Car_Dealer__c = stgRec.Nissan_Rental_Car_Dealer__c != null ? true : false;
		        		acc.Nissan_GTR_Dealer__c = stgRec.Nissan_GTR_Dealer__c != null ? true  : false;
		        		acc.Nissan_Commercial_Vehicle_Dealer__c = stgRec.Nissan_Commercial_Vehicle_Dealer__c != null ? true: false;
		        		acc.NMAC_Dealer_Code__c = stgRec.NMAC_Dealer_Code__c;
		        		acc.Name = stgRec.Dealer_Name__c;
		        		acc.NMAC_Dealer_Code__c = stgRec.NMAC_Dealer_Code__c;
		        		acc.Longitude_Number__c = stgRec.Longitude_Number__c != null ? decimal.valueOf(stgRec.Longitude_Number__c) : null;
		        		acc.Latitude_Number__c = stgRec.Latitude_Number__c != null ? decimal.valueOf(stgRec.Latitude_Number__c) : null;
		        		acc.Electric_Vehicle_Dealer__c = stgRec.Electric_Vehicle_Dealer__c != null ? true: false;
		        		acc.Make_Name__c = stgRec.Make_Name__c;
		        		acc.District_Name__c = stgRec.District_Name__c;
		        		acc.BillingStreet = stgRec.BillingStreet__c;
		        		acc.BillingCity = stgRec.BillingCity__c;        		
		        		acc.BillingState = stgRec.BillingState__c;
		        		acc.Area__c = stgRec.Area__c;
		        		acc.Area_Name__c = stgRec.Area_Name__c;        		
		        		acc.Dealer_Inactive_Indicator__c = stgRec.Dealer_Inactive__c;
		        		acctsToUpdate.add(acc);
		        	}
		        	
		        }
	            
	        }
        
       		if(acctsToUpdate.size() > 0){
       			Database.update(acctsToUpdate, false);
       		}
    
    }  
    
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){  
    
    } 
    
}