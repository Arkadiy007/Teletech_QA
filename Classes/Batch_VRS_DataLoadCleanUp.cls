/**********************************************************************
Name: ErrorLogDelete
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class cleana up Vehicle Retail Sale data after Vehicle Retails Sales file loads, run nightly.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 06/02/2011 Created
***********************************************************************/
//Select ID, Name From Vehicle_Retail_Sale__c WHERE (Vehicle_Identification_Number__c = NULL and External_Vehicle_Identification_Number__c <> NULL) or (Selling_Dealer_Name__c = NULL and External_Selling_Dealer_Name__c <> NULL) or (Owner_Id__c = NULL and External_Owner_Id__c <> NULL) LIMIT 5
global class Batch_VRS_DataLoadCleanUp implements Database.Batchable<sObject> {
	global String query = 'Select ID ' +
						'From Vehicle_Retail_Sale__c ' +
						'WHERE ((Vehicle_Identification_Number__c = NULL and External_Vehicle_Identification_Number__c <> NULL) or ' + 
							'(Selling_Dealer_Name__c = NULL and External_Selling_Dealer_Name__c <> NULL) or ' + 
							'(Owner_Id__c = NULL and External_Owner_Id__c <> NULL)) and createdDate >= 2011-03-26T00:00:00.000Z';

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Vehicle_Retail_Sale__c> lstVRStoUpdate) {
		update lstVRStoUpdate;
	}

	global void finish(Database.BatchableContext BC){
	}
}