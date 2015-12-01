/**********************************************************************
Name: Customer_Stage_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Creates Account record from Customer Stage
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 3/29/2012 Created
***********************************************************************/
trigger Customer_Stage_Before on Customer_Stage__c (before insert) {
    Map<Integer, Account> customerIds = new Map<Integer, Account>();
	Map<Integer, Customer_Stage__c> updateStageList = new Map<Integer, Customer_Stage__c>();
	Integer index = 0;
	
	//Maritz may send duplicated customers
	Set<String> dedup = new Set<String>();
	for (Customer_Stage__c req : Trigger.new) {
		if (!dedup.contains(req.CUST_ContactID__c)) {
			dedup.add(req.CUST_ContactID__c);
			
			updateStageList.put(index, req);
	    	customerIds.put(index, DQRClass.fillAccount(req));
	    	index++;
		} else {
			req.Error_Message__c = 'Another record with the same ContactID has been used for upserting.'; 
			req.Successful__c = 'Y';
			req.RelatedID__c = NULL;
		}
	}
	
	Set<String> createds = new Set<String>();
	if (customerIds.size() > 0) {
		Database.UpsertResult[] dbResult = database.upsert(customerIds.values(), Account.Customer_ID__c, false);
		for (integer row = 0; row < customerIds.size(); row++) {
			Customer_Stage__c req = updateStageList.get(row);
			
			Database.UpsertResult result = dbResult[row];
			if (!result.isSuccess()) {
				Database.Error err = dbResult[row].getErrors()[0];
                req.Error_Message__c = Text_Util.TruncateString('Failed to upsert the customer ' + customerIds.values()[row].Customer_ID__c + ': ' + err.getMessage(), 255);
                req.Successful__c = 'N';
	            req.RelatedID__c = NULL;
			} else {
				req.RelatedID__c = result.getID();
				req.Error_Message__c = ''; 
				req.Successful__c = 'Y';
				
				createds.add(req.CUST_ContactID__c);
			}
		}
	}
	
    List<Dealer_Quotes_Request_Lead_Stage__c> DQRLs = [Select Type__c, Successful__c, Stage_Status__c, RelatedID__c, Name, Id, Error_Message__c, DQRL_zone__c, 
														DQRL_spanish_lead__c, DQRL_script_10_decile_score__c, DQRL_salutation__c, DQRL_region__c, DQRL_purchase_timeframe__c, 
														DQRL_preferred_method__c, DQRL_lead_score__c, DQRL_lead_id__c, DQRL_lead_date__c, DQRL_lead_comments__c, 
														DQRL_lead_category__c, DQRL_last_name__c, DQRL_interest_vehicle_vin__c, DQRL_interest_vehicle_trim__c, 
														DQRL_interest_vehicle_transmission__c, DQRL_interest_vehicle_odometer__c, DQRL_interest_vehicle_model_year__c, 
														DQRL_interest_vehicle_model__c, DQRL_interest_vehicle_interior_color__c, DQRL_interest_vehicle_exterior_color__c, 
														DQRL_interest_vehicle_bodystyle__c, DQRL_first_name__c, DQRL_division__c, DQRL_district__c, DQRL_dealer_name__c, 
														DQRL_dealer_main_phone__c, DQRL_dealer_internet_phone__c, DQRL_dealer_id__c, DQRL_dealer_address__c, DQRL_contact_zip__c, 
														DQRL_contact_state_province__c, DQRL_contact_phoneno__c, DQRL_contact_id__c, DQRL_contact_email__c, DQRL_contact_city__c, 
														DQRL_contact_address__c, DQRL_area__c, DQRL_User_Defined_Text9__c, DQRL_User_Defined_Text8__c, DQRL_User_Defined_Text7__c, 
														DQRL_User_Defined_Text6__c, DQRL_User_Defined_Text5__c, DQRL_User_Defined_Text4__c, DQRL_User_Defined_Text3__c, 
														DQRL_User_Defined_Text2__c, DQRL_User_Defined_Text1__c, DQRL_User_Defined_Text10__c, DQRC_ContactID__c, DQRC_CDIId__c 
													From Dealer_Quotes_Request_Lead_Stage__c
													Where Successful__c <> 'Y' and DQRC_ContactID__c in: createds];
	if (DQRLs.size() > 0) {
		DQRClass.buildDQRs(DQRLs);
		Database.SaveResult[] dbResult = database.update(DQRLs, false);
	}
}