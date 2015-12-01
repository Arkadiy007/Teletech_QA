/**********************************************************************
Name: DealerQuotesRequest_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a new Dealer_Quotes_Request is created, fill in
Salesforce internal Ids by looking them up from
external ids provided.

Look up related Cases and update when DQR Survey data is
received.
 
Related Class : DealerQuotesRequestClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 04/05/2011 Created
1.1 - Bryan Fry 08/02/2011 Added code to update related Case when Survey
                           data is added to DQR.
***********************************************************************/

trigger DealerQuotesRequest_Before on Dealer_Quotes_Request__c (before insert, before update) {
    Set<String> customerIds = new Set<String>();
    Set<String> dealerExternalIds = new Set<String>();
    
    // Construct a Set of Customer_IDs from the Dealer_Quote_Requests input through Trigger.new
    for (Dealer_Quotes_Request__c req : Trigger.new) {
        if (req.Customer_ID__c != null)
            customerIds.add(req.Customer_ID__c);
        if (req.Dealer_Id__c != null)
            dealerExternalIds.add(req.Dealer_Id__c + System.label.Dealer_USA);
    }  

    List<Account> accList = new List<Account>([select Id, Customer_ID__c
                                               from Account 
                                               where Customer_ID__c  in: customerIds]);

    List<Lead> leadList = new List<Lead>([select id, Customer_ID__c
                                          from Lead 
                                          where Customer_ID__c  in: customerIds
                                          and isConverted = false]);
                                               
    List<Account> dealerList = new List<Account>([select id, Dealer_Code__c
                                                  from Account
                                                  where Dealer_External_Id__c in :dealerExternalIds]);
    
    Map<String,Account> accMap = new Map<String,Account>();
    Map<String,Lead> leadMap = new Map<String,Lead>();
    Map<String,Account> dealerMap = new Map<String,Account>();
    
    for (Account acc: accList)
        accMap.put(acc.Customer_Id__c, acc);

    for (Lead ld: leadList) 
        leadMap.put(ld.Customer_Id__c, ld);
    
    for (Account dealer: dealerList)
        dealerMap.put(dealer.Dealer_Code__c, dealer);
    
    // Loop through Dealer_Quotes_Requests in Trigger.new and set the AccountId for each
    for (Dealer_Quotes_Request__c req : Trigger.new) {
        Account acct = accMap.get(req.Customer_ID__c);
        if (acct != null)
            req.Account__c = acct.id;
        Lead ld = leadMap.get(req.Customer_ID__c);
        if (ld != null)
            req.Lead__c = ld.id;
        Account dealer = dealerMap.get(req.Dealer_Id__c);
        if (dealer != null)
            req.DQR_Dealer__c = dealer.id;
    }
    
    /***
      When DQRs are updated with Survey data, find and update Cases based on values set.
    ***/
    List<Dealer_Quotes_Request__c> dqrs = new List<Dealer_Quotes_Request__c>();
    List<Id> dqrIds = new List<Id>();
    Dealer_Quotes_Request__c dqr;
    
    // Look for rows being updated with DQR Survey information. Process the rows identified.
    if (Trigger.isUpdate) {
    	for (Integer i = 0; i< Trigger.size; i++) {
    		if (Trigger.old[i].ActionFlag__c == null &&
    		    	Trigger.new[i].ActionFlag__c == 'Yes') {
    			// This row is being updated with survey information
    			// and needs to be processed.
    			dqrs.add(Trigger.new[i]);
    			dqrIds.add(Trigger.new[i].Id);
    		}
    	}
    }
    
    // Get a List of Cases related to the DQRs that are being updated with Survey information.
    List<Case> dqrCases = [select Id, Subject, Status, Survey_Verbatim__c, Survey_Response_Date__c,
                                  Priority, Action_Flag__c, OwnerId, Dealer_Quotes_Request__c
                           from Case
                           where Dealer_Quotes_Request__c in :dqrs];
                           
    // Create a list of Case Ids to get calls for.
    List<Id> caseIds = new List<Id>();
    for (Case c: dqrCases) {
    	caseIds.add(c.Id);
    }
    
    List<Call__c> calls = [select Id, Case__c
                           from Call__c
                           where Case__c in :caseIds
                           and Outcome__c = 'Spoke with Correct Person'];
    
    Set<Id> correctCustomer = new Set<Id>();
    for (Call__c call: calls) {
    	correctCustomer.add(call.Case__c);
    }
    
    // Create a map of DQR Id to DQR record to allow cases and DQRs to be matched.
    Map<String,Dealer_Quotes_Request__c> dqrById = new Map<String,Dealer_Quotes_Request__c>();
    for (Dealer_Quotes_Request__c adqr: dqrs) {
    	dqrById.put(adqr.Id, adqr);
    }

    // For all Cases returned, match them with the associated DQR record.S  et values based
    // on the Status of the Case and whether the correct customer was already contacted.
    for (Case dqrCase: dqrCases) {
    	dqr = dqrById.get(dqrCase.Dealer_Quotes_Request__c);
    	if (dqrCase.Status == 'Closed') {
    		dqrCase.Status = 'Open';
    		dqrCase.Subject = 'Reopen Survey ' + dqrCase.Subject;
    		dqrCase.Survey_Verbatim__c = dqr.Verbatim_Comments__c;
    		dqrCase.Survey_Response_Date__c = dqr.Survey_Response_Date__c;
    		dqrCase.Decile_Score__c = DQRClass.getDQRPriority(dqr.FFScore__c);
    		dqrCase.Action_Flag__c = dqr.ActionFlag__c == 'Yes' ? true : false;
    		if (dqr.Net_Promoter_Score__c != null) {
    			dqrCase.Survey_NPS_Score_1__c = dqr.Net_Promoter_Score__c;
    		}
    		/*if (dqr.FFScore__c != null) {
    			try {
    				dqrCase.FF_Score__c = Integer.valueOf(dqr.FFScore__c);
    			} catch (Exception e) {}
    		}*/
    		dqrCase.Sentiment_Band__c = dqr.SentimentBandRow__c;
    		dqrCase.Lead_Comments_Long__c = dqr.Lead_Comments__c;
    		dqrCase.OwnerId = '00GF0000002IDyG';
    	} else if (!correctCustomer.contains(dqrCase.Id)) {
    		dqrCase.Subject = 'Survey ' + dqrCase.Subject;
    		dqrCase.Survey_Verbatim__c = dqr.Verbatim_Comments__c;
    		dqrCase.Survey_Response_Date__c = dqr.Survey_Response_Date__c;
    		dqrCase.Decile_Score__c = DQRClass.getDQRPriority(dqr.FFScore__c);
    		dqrCase.Action_Flag__c = dqr.ActionFlag__c == 'Yes' ? true : false;
    		if (dqr.Net_Promoter_Score__c != null) {
    			dqrCase.Survey_NPS_Score_1__c = dqr.Net_Promoter_Score__c;
    		}
    		/*if (dqr.FFScore__c != null) {
    			try {
    				dqrCase.FF_Score__c = Integer.valueOf(dqr.FFScore__c);
    			} catch (Exception e) {}
    		}*/
    		dqrCase.Sentiment_Band__c = dqr.SentimentBandRow__c;
    		dqrCase.Lead_Comments_Long__c = dqr.Lead_Comments__c;
    		dqrCase.OwnerId = '00GF0000002IDyG';
    	} else if (correctCustomer.contains(dqrCase.Id)) {
    		dqrCase.Subject = 'Survey ' + dqrCase.Subject;
    		dqrCase.Survey_Verbatim__c = dqr.Verbatim_Comments__c;
    		dqrCase.Survey_Response_Date__c = dqr.Survey_Response_Date__c;
    		dqrCase.Decile_Score__c = DQRClass.getDQRPriority(dqr.FFScore__c);
    		dqrCase.Action_Flag__c = dqr.ActionFlag__c == 'Yes' ? true : false;
    		if (dqr.Net_Promoter_Score__c != null) {
    			dqrCase.Survey_NPS_Score_1__c = dqr.Net_Promoter_Score__c;
    		}
    		/*if (dqr.FFScore__c != null) {
    			try {
    				dqrCase.FF_Score__c = Integer.valueOf(dqr.FFScore__c);
    			} catch (Exception e) {}
    		}*/
    		dqrCase.Sentiment_Band__c = dqr.SentimentBandRow__c;
    		dqrCase.Lead_Comments_Long__c = dqr.Lead_Comments__c;
    	}
    }
    
    // Update Cases that got DQR updates
    update dqrCases;
}