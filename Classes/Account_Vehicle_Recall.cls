/**********************************************************************
Name: Account_Vehicle_Recall
Copyright © notice: Nissan Motor Company
======================================================
Purpose: Look up any open vehicle recalls for an Account
in order to display a message with that information to
an agent in a Visualforce page.

Related Page : VehicleRecallByVINsInAccount 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 10/07/2011 Created
***********************************************************************/

public with sharing class Account_Vehicle_Recall {
	private String accountId;
	
	public boolean showPowerCust{get; set;}
	public String recallMessage {
		get;set;
	}

	/* Save the AccountId passed in for the record being used */
    public Account_Vehicle_Recall (ApexPages.StandardController controller) {
		accountId = controller.getRecord().Id;
		
		showPowerCust = false;
        Date purchStartDt = Date.parse(Label.Purchase_Start_Date);
        Date purchEndDt = Date.parse(Label.Purchase_End_Date);
        
        if(Label.Show_JD_Power_Message == 'Yes'){
        List<Vehicle_Retail_Sale__c> vehRetSaleList =  [Select Id, Vehicle_Identification_Number__c, Purchase_Date__c From Vehicle_Retail_Sale__c
                                                        where Owner_Id__c =:accountId Limit 40000];
        
        if(vehRetSaleList != null && vehRetSaleList.size() > 0){
        	for(Vehicle_Retail_Sale__c vrs : vehRetSaleList){
        		if(vrs.Purchase_Date__c >= purchStartDt && vrs.Purchase_Date__c <= purchEndDt){
           		 showPowerCust = true;
        		}
        	}
        } 
        }      
    }

	/* Determine if the account passed in has an open recalls for Vehicles associated with it.
	   Set the recallMessage to be displayed on the VisualForce page. */
    public void doLookupRecalls() {
    	List<Vehicle_Ownership_History__c> vehicleRecalls = [select id, Vehicle__c 
    	                                                     from Vehicle_Ownership_History__c 
    	                                                     where Owner__c = :accountId 
    	                                                     and Vehicle__r.Open_Recall__c = true];

		if (vehicleRecalls.size() > 0) {
			recallMessage = System.Label.Vehicle_Recall_Message;
		} else {
			recallMessage = '';
		}
    }
}