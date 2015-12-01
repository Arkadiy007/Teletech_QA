trigger DataFix_CAD_Trigger on CAD_Loader__c (after update) {
	if (System.label.TurnOnDataFix == 'Yes' || Test.isRunningTest()) {
		Map<String, User> userMap = new Map<String, User>();
		for (User u : [Select ZCA_Id__c From User Where ZCA_Id__c <> NULL and IsActive = true]) {
			userMap.put(u.ZCA_Id__c, u);
		}
		
    	Map<String, String> whoTookAction = 
                    new Map<String, String>
                    { 
                        'N' => 'National (CRR and RCAS)',
                        'D' => 'Dealer-Infield',
                        'V' => 'Vendor (Infiniti)'
					} ;

    	Map<String, String> howActionTaken = 
                    new Map<String, String>
                    { 
                        'E' => 'E-Mail or Other Electronic Means',
                        'L' => 'Letter',
                        'T' => 'Telephone',
                        'P' => 'Personal Contact'
					} ;
		Map<String, String> whatActionTaken = 
                    new Map<String, String>
                    { 
						'1A' => '1A	Repaired – Under Warranty', 
						'1B' => '1B	Repaired – NNA Goodwill (entire repair)', 
						'1C' => '1C	Repaired – NNA Goodwill (portion of repair)', 
						'1D' => '1D	NNA Provided Loan Vehicle', 
						'1E' => '1E	Repaired – Covered Security + Plus / EPP', 
						'1F' => '1F	Repaired – Dealer Paid', 
						'1G' => '1G	Repaired – Customer Paid', 
						'1H' => '1H	Repaired – Under Recall', 
						'1I' => '1I	Repaired – Part Supplied', 
						'1J' => '1J	Repaired – Technical Information Provided', 
						'2A' => '2A	Customer Reimbursement by NNA', 
						'2B' => '2B	Customer Offered Partial Reimbursement', 
						'2C' => '2C	Customer Reimbursement by Dealer', 
						'2D' => '2D	Customer Reimbursement by Other', 
						'2E' => '2E	NNA Reimbursed for Sales Tax', 
						'2G' => '2G	NNA Reimbursed Lease Disposition Fee', 
						'2M' => '2M	NNA Offered Maintenance Service or Credit', 
						'2P' => '2P	NNA Offered Purchase Incentive', 
						'2S' => '2S	NNA Offered Security + Plus / EPP Agreement', 
						'2W' => '2W	NNA Offered ECW (Extended Component Warranty)', 
						'2Y' => '2Y	NNA Offered an Accessory', 
						'3A' => '3A	Declined – Not Covered Under Warranty', 
						'3B' => '3B	Declined – Out of Warranty', 
						'3C' => '3C	Declined – Dealer / Customer Issue', 
						'3D' => '3D	Declined – Maintenance Item', 
						'3E' => '3E	Declined – Lack of Maintenance', 
						'3F' => '3F	Declined – Vehicle Not Involved in Recall', 
						'3G' => '3G	Declined – Non-NNA Service Contract', 
						'3H' => '3H	Declined – Owner Would Not Allow Inspection', 
						'3I' => '3I	Declined – Normal Wear', 
						'3J' => '3J	Declined – Independent Repair', 
						'3K' => '3K	Declined – Vehicle Modified', 
						'3L' => '3L	Declined – Rental Car Request', 
						'3M' => '3M	Declined – Insufficient Documentation', 
						'3N' => '3N	Declined – Non-Nissan Vehicle', 
						'4A' => '4A	Customer No Longer Owns Vehicle', 
						'4B' => '4B	Lack of Customer Response', 
						'4C' => '4C	Unable to Contact Customer', 
						'4D' => '4D	Customer Refused Assistance', 
						'4E' => '4E	Customer Demands Impossible to Satisfy', 
						'6A' => '6A	Vehicle Performs Normally', 
						'6B' => '6B Vehicle Delivered', 
						'7A' => '7A Part Available Only as Assembly', 
						'7B' => '7B Non – NNA Accessory / Equipment', 
						'8B' => '8B Roadside Assistance Resolved, Tow Truck Dispatch', 
						'8C' => '8C Referred Customer Inquiry to Appropriate Dept for Handling', 
						'8D' => '8D Provided Security+Plus/Quality Guard/Maintenance', 
						'8E' => '8E Provided Warranty Information', 
						'8F' => '8F Provided Vehicle Information', 
						'8G' => '8G Provided Other Information', 
						'8M' => '8M Marketing/Advertising Concern',
						'5B' => '5B Voluntary Dealer Trade/Repurchase - Dlr Inventory - 2 vehs', 
						'5C' => '5C Voluntary NNA Trade/Repurchase - NNA Inventory - 2 vehs', 
						'5D' => '5D Mandated Trade/Repurchase - NNA Inventory - 1-2 vehs', 
						'5E' => '5E Legal Department Repurchase', 
						'5F' => '5F Voluntary NNA Repurchase/Trade - NNA Inventory - 1 veh', 
						'5G' => '5G Voluntary NNA Vehicle Donation/Crush - 1 veh', 
						'9B' => '9B Repaired - Settlement', 
						'9C' => '9C Repaired - Mandated', 
						'9D' => '9D Customer Reimbursement - Settlement', 
						'9E' => '9E Customer Reimbursement - Mandated', 
						'9F' => '9F Mandated Denial Decision - Judgment awarded to Nissan', 
						'9G' => '9G Security Plus / Maintenance Plus / ECW - Settlement', 
						'9H' => '9H DTS Inspection - Settlement', 
						'9I' => '9I Customer Ineligible for BBB Handling', 
						'9J' => '9J Interim Repair Decision', 
						'9T' => '9T Closed for Arbitration'
                    } ;

		Map<String, CAD_Loader__c> docIds = new Map<String, CAD_Loader__c>();
		for(CAD_Loader__c c : Trigger.new) {
			if (c.DOCUMENT_ID__c != null)
				docIds.put(c.DOCUMENT_ID__c, c);
		}
		
		List<Case> casesToUpdate = new List<Case>();
		List<Case> cases = [Select ID, Case_External_Id__c, 
								Who_Took_Action__c, 
								How_was_the_action_taken__c, 
								What_action_was_taken__c,
								Servicing_Dealer__c, Service_Dealer_Number__c,
								OwnerID,
								Legacy_Root_Cause__c, Legacy_Root_Cause_2__c
							From Case 
							Where Case_External_Id__c in: docIds.keySet() and 
								(Who_Took_Action__c = NULL or How_was_the_action_taken__c = NULL or What_action_was_taken__c = NULL or 
								Servicing_Dealer__c = NULL or Service_Dealer_Number__c = NULL or
								OwnerID =: System.label.Batch_Record_Owner or Legacy_Root_Cause__c <> NULL or Legacy_Root_Cause_2__c <> NULL)];
		for (Case c : cases) {
			if (docIds.containsKey(c.Case_External_Id__c)) {
				Boolean toupdate = false;
				CAD_Loader__c cad = docIds.get(c.Case_External_Id__c);
				
				String actionCode = cad.CA_ACTION_CODE__c;
				if (actionCode != null && actionCode.length() == 4) {
					if (c.Who_Took_Action__c == null) {
						String who = actionCode.substring(0, 1);
						if (whoTookAction.containsKey(who))
							c.Who_Took_Action__c = whoTookAction.get(who);
						else
							c.Who_Took_Action__c = who;
						
						toupdate = true;
					}
					
					if (c.How_was_the_action_taken__c == null) {
						String how = actionCode.substring(1, 2);
						if (howActionTaken.containsKey(how))
							c.How_was_the_action_taken__c = howActionTaken.get(how);
						else
							c.How_was_the_action_taken__c = how;
						
						toupdate = true;
					}
					
					if (c.What_action_was_taken__c == null) {
						String what = actionCode.substring(2, 4);
						if (whatActionTaken.containsKey(what))
							c.What_action_was_taken__c = whatActionTaken.get(what);
						else
							c.What_action_was_taken__c = what;
						
						toupdate = true;
					}
				}
				
				String cadMgr = cad.DIST_MGR_NAME__c, zcaid = '';
				if (cadMgr != null && cadMgr != '') {
					if (cadMgr.startsWith('*'))
						zcaid = cadMgr.substring(1, cadMgr.length());
					else
						zcaid = cadMgr;
					
					if (c.OwnerID == System.label.Batch_Record_Owner && userMap.containsKey(zcaid)) {
						c.OwnerID = userMap.get(zcaid).ID;
						toupdate = true;
					}
				}
				
				String svcNo = cad.SERVICING_DEALER_NUMBER__c;
				if (svcNo != NULL && svcNo != '') {
					if (c.Servicing_Dealer__c == NULL || c.Service_Dealer_Number__c == null) {
						c.Service_Dealer_Number__c = svcNo;
						toupdate = true;
					}
				}
				
				Boolean isRoot1Bad = (c.Legacy_Root_Cause__c != null && c.Legacy_Root_Cause__c.length() == 8);
				Boolean isRoot2Bad = (c.Legacy_Root_Cause_2__c != null && c.Legacy_Root_Cause_2__c.length() == 8);
				
				if (isRoot1Bad && !isRoot2Bad) {//root 1 is bad and root 2 is good, swap
					c.Legacy_Root_Cause__c = c.Legacy_Root_Cause_2__c;
					c.Legacy_Root_Cause_2__c = NULL;
					toupdate = true;
				} else if (isRoot1Bad && isRoot2Bad) {//root 1 is bad and root 2 is also bad, clear both
					c.Legacy_Root_Cause__c = NULL;
					c.Legacy_Root_Cause_2__c = NULL;
					toupdate = true;
				} else if (!isRoot1Bad && !isRoot2Bad) {//root 1 is good and root 2 is also good, do nothing
					//do nothing
				} else if (!isRoot1Bad && isRoot2Bad) {//root 1 is good and root 2 is bad, clear root2
					c.Legacy_Root_Cause_2__c = NULL;
					toupdate = true;
				}
				
				if (toupdate) {
					c.Stage_Status__c = System.label.Stage_Status_None;
					casesToUpdate.add(c);
				}
			}
		}
		
		if (casesToUpdate.size() > 0)
			Database.update(casesToUpdate, false);
	}
}