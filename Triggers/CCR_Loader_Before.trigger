trigger CCR_Loader_Before on CCR_Loader__c (before insert) {
	List<CCR_Loader__c> ccrs = new List<CCR_Loader__c>();
	//collect DOCUMENT_ID__c
	Set<String> docIDs = new Set<String>();
	for (CCR_Loader__c l : Trigger.new) {
		if (l.Successful__c != 'Y') {
			ccrs.add(l);
			
			if (l.DOCUMENT_ID__c != null)
				docIDs.add(l.DOCUMENT_ID__c);
		}
	}
	System.Debug('*** ccrs ' + ccrs);
	System.Debug('*** docIDs ' + docIDs);
	
	if (ccrs.size() > 0) {
		RecordType crBBRT = [select id, name from recordtype where id = '012F0000000yCuLIAU'];
		
		//existing cases by Case_External_Id__c
		Map<String, Case> cases = new Map<String, Case>();
	    for (Case c : [Select ID, Case_External_Id__c From Case Where Case_External_Id__c in: docIDs])
	    	cases.put(c.Case_External_Id__c, c);
	   	
		Map<String, CAD_Loader__c> cads = new Map<String, CAD_Loader__c>();
	    for (CAD_Loader__c c : [Select ID, CHECK_ISSUE_DATE_CYMD__c, CHECK_NUMBER__c, DOCUMENT_ID__c From CAD_Loader__c Where DOCUMENT_ID__c in: docIDs])
	    	cads.put(c.DOCUMENT_ID__c, c);
	   	
		Map<Integer, CCR_Loader__c> updateStageList = new Map<Integer, CCR_Loader__c>();
		Map<Integer, Integer> indexMap = new Map<Integer, Integer>();
		Integer i = 0, j = 0;
		List<Check_Request__c> checksToInsert = new List<Check_Request__c>();
		Set<String> codes = new Set<String>();
		
		for (CCR_Loader__c l : ccrs) {
			//indexed and queued up all the CCR_Loader__c records
			updateStageList.put(i, l);
			
	    	if (!cases.containsKey(l.DOCUMENT_ID__c)) {	//Mark CCR_Loader__c record unsuccessful if the case by the Legacy CA does not exist
	            l.Error_Message__c = 'Could not match Legacy Case Number = ' + l.DOCUMENT_ID__c + ' in Case';
	            l.Successful__c = 'N';
	    	} else { 									//collect good Check Requests for create
				l.Error_Message__c = ''; 
				l.Successful__c = 'Y';
				
				//fill CheckRequest info with the CCR record
				Check_Request__c c = new Check_Request__c();
	    		c.Case__c = cases.get(l.DOCUMENT_ID__c).Id;
	    		c.RecordTypeId = crBBRT.Id;
				c.Mailing_Address_Verified__c = true;
				
				if (cads.containsKey(l.DOCUMENT_ID__c)) {
					c.Issue_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cads.get(l.DOCUMENT_ID__c).CHECK_ISSUE_DATE_CYMD__c);
					c.Check_Number__c = cads.get(l.DOCUMENT_ID__c).CHECK_NUMBER__c;
					System.Debug('*** cads.get(l.DOCUMENT_ID__c) ' + cads.get(l.DOCUMENT_ID__c));
				}
				c.Zip__c = l.ZIP__c;
				//l.SUPVSR_MNGR_CD__c;
				c.Requestor_Terminal_ID__c = l.RQST_TRMNL_ID__c;
				c.Requestor_Name__c = l.RQST_NAME__c;
				c.Requested_ID__c = l.RQST_ID__c;
				c.RO_Date__c = Text_Util.CCYYMMDDNoDashesToDate(l.RO_DT__c);
				c.Reimbursement_Indicator__c = l.REIM_FLG__c;
				c.Mileage__c = Text_Util.DecimalValueOf(l.MILE__c);
				c.Legacy_GL_Code__c = l.LDGR_CD__c;
				c.Legacy_GL_Account_Program__c = l.GL_ACCT_PGM__c;
				if (c.Legacy_GL_Account_Program__c != null)
					codes.add(c.Legacy_GL_Account_Program__c);
				
				//c.Case_DocumentID__c = l.DOCUMENT_ID__c;
				c.City__c = l.CUS_CITY__c;
				c.State__c = l.CUST_ST__c;
				c.Payable_To_Middle_Name__c = l.CUST_MI__c;
				if (l.CUST_LSTNAME__c != null && l.CUST_LSTNAME__c.length() > 15) {
					l.Error_Message__c = 'The Payable To Last Name field has been truncated to 15 characters long.'; 
					c.Payable_To_Last_Name__c = l.CUST_LSTNAME__c.substring(0, 15);
				} else 
					c.Payable_To_Last_Name__c = l.CUST_LSTNAME__c;
				c.Payable_To_First_Name__c = l.CUST_FRSTNAME__c;
				c.Address__c = l.CUST_ADRS__c;
				//c. = l.CHNL_CD__c;
				c.Request_Date__c = Text_Util.CCYYMMDDNoDashesToDateTime(l.CHECK_RQST_DT__c);
				c.Date_Approved__c = Text_Util.CCYYMMDDNoDashesToDate(l.CHECK_APP_DT__c);
				Decimal amount = Text_Util.DecimalValueOf(l.CHECK_AMT__c);
				c.Check_Amount__c = amount == null ? null : amount / 100.00;
				c.Business_Name_1__c = l.BUS_NAME_1__c;
				c.Business_Name_2__c = l.BUS_NAME_2__c;
				c.Approving_Manager_Name__c = l.APPR_SPVR_MGR_NAME__c;
				c.Approving_Manager_ID__c = l.APPR_SPVR_MGR_ID__c;
				c.Approval_Indicator__c = l.APPROVAL_FLAG__c;
				
				c.Status__c = 'Approved';
				c.Stage_Status__c = System.label.Stage_Status_Done;
				//c.Special_Comments__c, 
				//c.Repair_Order__c, 
				//c.Memo__c, 
				//c.Denied_Reason__c, 
				//c.Check_Type__c, 
				//c.Buyback__c, 
				
				checksToInsert.add(c);
				
				//mark the indices of CCR_Loader__c that can be created later
				indexMap.put(j, i);
				j++;
	    	}
	    	
			i++;
		}
		
        Map<String, Code__c> codeMap = Text_Util.getCodeIDMap(codes, 'GL_Code');
        if (codeMap.size() > 0) {
			for (Check_Request__c c : checksToInsert) {
				if (codeMap.containsKey(c.Legacy_GL_Account_Program__c))
					c.GL_Code__c = codeMap.get(c.Legacy_GL_Account_Program__c).ID;
			}
        }
        
	    //create Check Requests
	    if (checksToInsert.size() > 0) {
			Database.SaveResult[] dbResult = Database.insert(checksToInsert, false);
			for (integer row = 0; row < checksToInsert.size(); row++) {
				Database.SaveResult result = dbResult[row];
				if (!result.isSuccess()) {
					Database.Error err = dbResult[row].getErrors()[0];
					CCR_Loader__c l = updateStageList.get(indexMap.get(row));
	                l.Error_Message__c = Text_Util.TruncateString(Text_Util.valueConcatenation('Failed to create the check request: ' + err.getMessage(), l.Error_Message__c), 255);
	                l.Successful__c = 'N';
				}
			}
	    }
	}
}