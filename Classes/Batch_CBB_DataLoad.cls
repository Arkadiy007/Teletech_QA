/**********************************************************************
Name: Batch_CBB_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CBB_Loader__c table data from SAP into the Buyback__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 	01/25/2012 Created
***********************************************************************/
/*
//Batch_CBB_DataLoad batchJob = new Batch_CBB_DataLoad();
//Database.executeBatch(batchJob);
//List<CBB_Loader__c> lst = [select ID, Successful__c from CBB_Loader__c Where Successful__c <> null];
//for (CBB_Loader__c c : lst) {
//	c.Successful__c = null;
//	c.Error_Message__c = null;
//}
//update lst;
//delete [select id from error_log__c];

to get sample data
List<CBB_Loader__c> lst = [select ID, Name, CBB_NUM__c, CBB_SEQ_NUM__c, CBB_CA_FILE1__c, CBB_CA_FILE2__c, CBB_CA_FILE3__c from CBB_Loader__c order by CBB_NUM__c, CBB_SEQ_NUM__c limit 200];
System.Debug('*** CBB ' + lst);
Set<String> casein  = new Set<String>();
for (CBB_Loader__c c : lst) {
	if (c.CBB_CA_FILE1__c != null)
		casein.add('CA' + c.CBB_CA_FILE1__c);
	if (c.CBB_CA_FILE2__c != null)
		casein.add('CA' +c.CBB_CA_FILE2__c);
	if (c.CBB_CA_FILE3__c != null)
		casein.add('CA' +c.CBB_CA_FILE3__c);
}
List<Case> caseids = [select id, legacy_Case_Number__c from case where legacy_Case_Number__c in: casein];
system.debug('*** caseids ' + caseids);
List<Buyback__c> bb = [select id, Name, Case__r.CaseNumber, Case__r.Legacy_Case_Number__c from Buyback__c where Case__c in: caseids];
System.Debug('*** bb ' + bb.size() + '     ' +  bb);

for (Buyback__c b : bb) {
	System.Debug('*** b.Case__r.Legacy_Case_Number__c ' +  b.Case__c + '   ' + b.Case__r.CaseNumber + '    ' + b.Case__r.Legacy_Case_Number__c);
}
*/
global class Batch_CBB_DataLoad implements Database.Batchable<sObject> {
	ID bbRTid = '012F0000000yCk4';
	ID crBBRTid = '012F0000000yCuLIAU';
	global String query = 'Select Id, Name, Error_Message__c, Successful__c, ' + 
							 'CBB_YR_OF_VEH__c, ' + 
							 'CBB_VIN_NUM__c, ' + 
							 'CBB_VEH_MODEL_LINE__c, ' + 
							 'CBB_VEH_LOC__c, ' + 
							 'CBB_VEH_LOC_ZIP_CD__c, ' + 
							 'CBB_VEH_LOC_STATE__c, ' + 
							 'CBB_VEH_LOC_PHONE__c, ' + 
							 'CBB_VEH_LOC_DT__c, ' + 
							 'CBB_VEH_LOC_CITY__c, ' + 
							 'CBB_VEH_LOC_ADDR__c, ' + 
							 'CBB_VEH_DISP__c, ' + 
							 'CBB_VEH_DISP_DT__c, ' + 
							 'CBB_TITL_STATUS_DT__c, ' + 
							 'CBB_TITLE_STATUS__c, ' + 
							 'CBB_TITLE_LOC__c, ' + 
							 'CBB_TITLE_LOC_NM__c, ' + 
							 'CBB_TITLE_LOC_DT__c, ' + 
							 'CBB_TITLE_BRAND_DT__c, ' + 
							 'CBB_STATUS__c, ' + 
							 'CBB_STATUS_DT__c, ' + 
							 'CBB_STATE_SOLD__c, ' + 
							 'CBB_STATE_REPUR_IN__c, ' + 
							 'CBB_SOLD_AMT__c, ' + 
							 'CBB_SMM_ARRIVAL_DT__c, ' + 
							 'CBB_SEQ_NUM__c, ' + 
							 'CBB_RESP_REP__c, ' + 
							 'CBB_REPUR_AMT__c, ' + 
							 'CBB_REGION__c, ' + 
							 'CBB_NUM__c, ' + 
							 'CBB_NET_LOSS__c, ' + 
							 'CBB_MAND_VOLUNTARY__c, ' + 
							 'CBB_LEGL_REPUR_AMT__c, ' + 
							 'CBB_LEGL_CASE_FILE__c, ' + 
							 'CBB_LAST_UPDATE_TS__c, ' + 
							 'CBB_LAST_UPDATE_ID__c, ' + 
							 'CBB_DT_SOLD__c, ' + 
							 'CBB_DELETE_FLAG__c, ' + 
							 'CBB_DELAY_FLAG__c, ' + 
							 'CBB_DELAY_DT__c, ' + 
							 'CBB_DELAY_COMMENT__c, ' + 
							 'CBB_DAYS_TO_SOLD__c, ' + 
							 'CBB_DAYS_TO_GROUND__c, ' + 
							 'CBB_DAYS_IN_INV__c, ' + 
							 'CBB_DAS_VENDOR__c, ' + 
							 'CBB_DAS_VENDOR_DT__c, ' + 
							 'CBB_CUST_ZIP_CD__c, ' + 
							 'CBB_CUST_STATE__c, ' + 
							 'CBB_CUST_PHONE__c, ' + 
							 'CBB_CUST_MID_INIT__c, ' + 
							 'CBB_CUST_LAST_NM__c, ' + 
							 'CBB_CUST_FIRST_NM__c, ' + 
							 'CBB_CUST_CITY__c, ' + 
							 'CBB_CUST_ADDR2__c, ' + 
							 'CBB_CUST_ADDR1__c, ' + 
							 'CBB_CONTACT_TITLE__c, ' + 
							 'CBB_CONTACT_LNAME__c, ' + 
							 'CBB_CONTACT_FNAME__c, ' + 
							 'CBB_CHECK_ISSU_DT__c, ' + 
							 'CBB_CHECK_ISSU_DT3__c, ' + 
							 'CBB_CHECK_ISSU_DT2__c, ' + 
							 'CBB_CHANNEL_DESIG__c, ' + 
							 'CBB_CA_FILE3__c, ' + 
							 'CBB_CA_FILE3_AMT__c, ' + 
							 'CBB_CA_FILE2__c, ' + 
							 'CBB_CA_FILE2_AMT__c, ' + 
							 'CBB_CA_FILE1__c, ' + 
							 'CBB_CA_FILE1_AMT__c, ' + 
							 'CBB_ADJ_REPUR_AMT__c ' + 
							'From CBB_Loader__c Where Successful__c <> \'Y\' Order by CBB_NUM__c, CBB_SEQ_NUM__c desc';
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    } 
	
  	private void fillBuyback(Buyback__c bb, CBB_Loader__c stage) {
    	bb.RecordTypeId = bbRTid;
    	bb.Type__c = 'DRT Resolution';
		bb.Vehicle_Identification_Number__c = stage.CBB_VIN_NUM__c;
		bb.Centre_Type__c = stage.CBB_VEH_LOC__c;
    	bb.Centre_Arrival_Date__c = Text_Util.CCYYMMDDtoDateTime(stage.CBB_VEH_LOC_DT__c);
    	bb.Disposition_of_Buyback_Vehicle__c = stage.CBB_VEH_DISP__c;
		bb.Return_To_Inventory_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_VEH_DISP_DT__c);
		//bb.Disposition_Date__c;
		//bb.Title_Status_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_TITL_STATUS_DT__c);
		//bb.Title_Status__c = stage.CBB_TITLE_STATUS__c; 
		//bb.Title_Location_Code__c = stage.CBB_TITLE_LOC__c;
		//bb.Title_Location_Name__c = stage.CBB_TITLE_LOC_NM__c;
		//bb.Title_Location_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_TITLE_LOC_DT__c);
		//bb.Title_Branded_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_TITLE_BRAND_DT__c);
    	bb.Buyback_Status__c = stage.CBB_STATUS__c;
    	bb.CBB_STATUS__c = stage.CBB_STATUS__c;
    	//bb.Buyback_Status_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_STATUS_DT__c);
    	//bb.Sold_State__c = stage.CBB_STATE_SOLD__c;
		//bb.State_Repurchased_In__c = stage.CBB_STATE_REPUR_IN__c;
    	bb.Sold_Amount__c = Decimal.valueOf(stage.CBB_SOLD_AMT__c); 
    	bb.Arrived_at_Auction_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_SMM_ARRIVAL_DT__c);
		//'CBB_SEQ_NUM__c, ' + 
		//'CBB_RESP_REP__c, ' + 
		bb.Dealer_Number_Region__c = stage.CBB_REGION__c;
		//'CBB_NUM__c, ' + 
		//bb.Mand_Voluntary__c = stage.CBB_MAND_VOLUNTARY__c;
		bb.Legal_Repurchase_Amount__c = Text_Util.DecimalValueOf(stage.CBB_LEGL_REPUR_AMT__c);
		bb.Total_Repurchase_Amount_Legacy__c = Text_Util.DecimalValueOf(stage.CBB_REPUR_AMT__c);
		bb.Legal_Case__c = stage.CBB_LEGL_CASE_FILE__c;
		//'CBB_LAST_UPDATE_TS__c, ' + 
		//'CBB_LAST_UPDATE_ID__c, ' + 
    	bb.Sold_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_DT_SOLD__c);
		//'CBB_DELETE_FLAG__c, ' + 
		//bb.Delay_Indicator__c = Text_Util.BooleanLookup(stage.CBB_DELAY_FLAG__c, false);
		//bb.Delay_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_DELAY_DT__c);
		//bb.Delay_Comment__c = stage.CBB_DELAY_COMMENT__c;
		//bb.DAS_Vendor__c = stage.CBB_DAS_VENDOR__c;
		//bb.DAS_Vendor_Date__c = Text_Util.CCYYMMDDtoDate(stage.CBB_DAS_VENDOR_DT__c);
		
		String s = (stage.CBB_CONTACT_TITLE__c == null || stage.CBB_CONTACT_TITLE__c == '') ? '' : stage.CBB_CONTACT_TITLE__c;
		String s1 = (stage.CBB_CONTACT_FNAME__c == null || stage.CBB_CONTACT_FNAME__c == '') ? '' : ' ' + stage.CBB_CONTACT_FNAME__c;
		String s2 = (stage.CBB_CONTACT_LNAME__c == null || stage.CBB_CONTACT_LNAME__c == '') ? '' : ' ' + stage.CBB_CONTACT_LNAME__c;
		bb.Dealer_Contact__c = (s + s1 + s2).trim();
		
		//bb.Channel_Designation__c = stage.CBB_CHANNEL_DESIG__c;
		bb.Adjust_Repurchase_Amount__c = Text_Util.DecimalValueOf(stage.CBB_ADJ_REPUR_AMT__c);
		bb.Mailing_Address_Verified__c = true;
  	}

  	private void fillCheckRequest(Check_Request__c cr, Date issueDate, String CBB_CA_FILE_AMT) {
    	cr.RecordTypeId = crBBRTid;
    	cr.Issue_Date__c = issueDate;
		cr.Check_Amount__c = Text_Util.DecimalValueOf(CBB_CA_FILE_AMT);
  	}
  	
    global void execute(Database.BatchableContext BC, List<CBB_Loader__c> lstCBBs) {
    	Map<ID, CBB_Loader__c> updateStageList = new Map<ID, CBB_Loader__c>();
    	
    	//set of mapa: CA# to SObject
    	Map<String, CBB_Loader__c> cbbs = new Map<String, CBB_Loader__c>();
    	Map<String, Buyback__c> buybacks = new Map<String, Buyback__c>();
    	Map<String, Check_Request__c> checks = new Map<String, Check_Request__c>();
	    Map<String, Case> cases = new Map<String, Case>();
	    
    	Set<String> dedupped = new Set<String>();
    	for (CBB_Loader__c l : lstCBBs) {
    		l.Error_Message__c = ''; 
    		l.Successful__c = 'Y';
    		updateStageList.put(l.ID, l);
    		
    		//collect only the latest version of the CBB records
    		String key = l.CBB_NUM__c;
    		if (dedupped.contains(key)) {
	    		l.Error_Message__c = 'Older Version - not processed.'; 
    			continue;
    		}
    		dedupped.add(key);
    		
    		//fill buyback info with the CBB record
    		Buyback__c b = new Buyback__c();
    		fillBuyback(b, l);
    		
    		Date reportedDate = null;
    		//collect check request info by CBB_CA_FILE
    		if (l.CBB_CA_FILE1__c != null) {
	    		buybacks.put('CA' + l.CBB_CA_FILE1__c, b.clone());
	    		cbbs.put('CA' + l.CBB_CA_FILE1__c, l.clone(true));
	    		
	    		reportedDate = Text_Util.CCYYMMDDtoDate(l.CBB_CHECK_ISSU_DT__c);
	    		
	    		Check_Request__c c = new Check_Request__c();
	    		fillCheckRequest(c, reportedDate, l.CBB_CA_FILE1_AMT__c);
	    		checks.put('CA' + l.CBB_CA_FILE1__c, c);
    		}
    		
    		if (l.CBB_CA_FILE2__c != null) {
    			buybacks.put('CA' + l.CBB_CA_FILE2__c, b.clone());
    			cbbs.put('CA' + l.CBB_CA_FILE2__c, l.clone(true));
    			
    			Date issueDate = Text_Util.CCYYMMDDtoDate(l.CBB_CHECK_ISSU_DT2__c);
    			if (reportedDate == null || reportedDate > issueDate)
    				reportedDate = issueDate;
    			
	    		Check_Request__c c = new Check_Request__c();
	    		fillCheckRequest(c, issueDate, l.CBB_CA_FILE2_AMT__c);
	    		checks.put('CA' + l.CBB_CA_FILE2__c, c);
    		}
    		
    		if (l.CBB_CA_FILE3__c != null) {
    			buybacks.put('CA' + l.CBB_CA_FILE3__c, b.clone());
    			cbbs.put('CA' + l.CBB_CA_FILE3__c, l.clone(true));
    			
    			Date issueDate = Text_Util.CCYYMMDDtoDate(l.CBB_CHECK_ISSU_DT3__c);
    			if (reportedDate == null || reportedDate > issueDate)
    				reportedDate = issueDate;
    			
	    		Check_Request__c c = new Check_Request__c();
	    		fillCheckRequest(c, issueDate, l.CBB_CA_FILE3_AMT__c);
	    		checks.put('CA' + l.CBB_CA_FILE3__c, c);
    		}
    		
			if (l.CBB_CA_FILE1__c != null)
	    		buybacks.get('CA' + l.CBB_CA_FILE1__c).Legacy_Reported_Date__c = reportedDate;
			if (l.CBB_CA_FILE2__c != null)
	    		buybacks.get('CA' + l.CBB_CA_FILE2__c).Legacy_Reported_Date__c = reportedDate;
			if (l.CBB_CA_FILE3__c != null)
	    		buybacks.get('CA' + l.CBB_CA_FILE3__c).Legacy_Reported_Date__c = reportedDate;
    	}
    	
    	//existing Cases grouped by CBB_CA_FILE#
    	List<Case> sfCases = [Select ID, Legacy_Case_Number__c, (Select Id, Issue_Date__c, Check_Amount__c, Case__c From Check_Requests__r) From Case Where Legacy_Case_Number__c in: cbbs.keySet()];
	    Map<ID, Case> caseMap = new Map<ID, Case>(sfCases);
	    for (Case c : sfCases)
	    	cases.put(c.Legacy_Case_Number__c, c);
	   	
	    //collect the CA_FILE are not in SF
	    for (String key : cbbs.keySet()) {
	    	//if the case by the Legacy CA does not exist
	    	if (!cases.containsKey(key)) {
	    		CBB_Loader__c cbb = updateStageList.get(cbbs.get(key).Id);
                cbb.Error_Message__c = Text_Util.TruncateString(Text_Util.valueConcatenation('Could not match Legacy Case Number = ' + key + ' in Case', cbb.Error_Message__c), 255);
                cbb.Successful__c = 'N';
	    	}
	    }
	    
	    /**********************************************
	    	take care of buyback creation first
	    **********************************************/
	  	List<Buyback__c> buybacksToInsert = new List<Buyback__c>();
	    for (String key : cbbs.keySet()) {
	    	CBB_Loader__c cbb = updateStageList.get(cbbs.get(key).Id);
	    	
	    	if (cbb.Successful__c == 'Y') {
		    	Case c = cases.get(key);
		    	Buyback__c b = buybacks.get(key);
		    	b.Case__c = c.Id;
		    	buybacksToInsert.add(b);
	    	}
	    }
		
		Map<String, Buyback__c> buybacksWithIDs = new Map<String, Buyback__c>();
	    //create buybacks
	    if (buybacksToInsert.size() > 0) {
			Database.SaveResult[] dbResult = Database.insert(buybacksToInsert, false);
			for (integer row = 0; row < buybacksToInsert.size(); row++) {
				Buyback__c b = buybacksToInsert[row];
				Case c = caseMap.get(b.Case__c);
				CBB_Loader__c cbb = updateStageList.get(cbbs.get(c.Legacy_Case_NUmber__c).Id);
				
				Database.SaveResult result = dbResult[row];
				if (!result.isSuccess()) {
					Database.Error err = dbResult[row].getErrors()[0];
	                cbb.Error_Message__c = Text_Util.TruncateString(Text_Util.valueConcatenation('Failed to create the buyback: ' + err.getMessage(), cbb.Error_Message__c), 255);
	                cbb.Successful__c = 'N';
				} else
					buybacksWithIDs.put(c.Legacy_Case_NUmber__c, b);
			}
	    }
	   	
	    /**********************************************
	    	take care of check request updating
	    **********************************************/
	  	List<Check_Request__c> checksToUpdate = new List<Check_Request__c>();
	    //collect the CBB entries all of which CA_FILEs are in SF
	    for (String key : cbbs.keySet()) {
	    	CBB_Loader__c cbb = updateStageList.get(cbbs.get(key).Id);
	    	
	    	if (cbb.Successful__c == 'Y') {
		    	Case c = cases.get(key);
		    	List<Check_Request__c> checksInCase = c.Check_Requests__r;
				Check_Request__c cr = checks.get(key);
		    	
		    	//check request info related to the buyback
		    	for (Check_Request__c check : checksInCase) {
			    	check.Issue_Date__c = cr.Issue_Date__c;
					check.Check_Amount__c = cr.Check_Amount__c;
					if (buybacksWithIDs.containsKey(key))
						check.Buyback__c = buybacksWithIDs.get(key).ID;
					if (cr.Check_Amount__c > 0)
						checksToUpdate.add(check);
		    	}
	    	}
	    }
	    
	    if (checksToUpdate.size() > 0) {
			Database.SaveResult[] dbResult = Database.update(checksToUpdate, false);
			for (integer row = 0; row < checksToUpdate.size(); row++) {
				Check_Request__c check = checksToUpdate[row];
				Case c = caseMap.get(check.Case__c);
				CBB_Loader__c cbb = updateStageList.get(cbbs.get(c.Legacy_Case_NUmber__c).Id);

				Database.SaveResult result = dbResult[row];
				if (!result.isSuccess()) {
					Database.Error err = dbResult[row].getErrors()[0];
	                cbb.Error_Message__c = Text_Util.TruncateString(Text_Util.valueConcatenation('Failed to update Check Request of this buyback: ' + err.getMessage(), cbb.Error_Message__c), 255);
	                cbb.Successful__c = 'N';
				}
			}
	    }
	    
		if (updateStageList.size() > 0)
			Database.SaveResult[] dbResult = Database.update(updateStageList.values(), false);
    }
	
    global void finish(Database.BatchableContext BC){
    }
}