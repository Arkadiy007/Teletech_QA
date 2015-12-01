public class Batch_Util {
	private static final String DEFAULT_DESCRIPTION = 'Legacy ZCA Case';
	
    public static final String CONCERN_TYPE = 'Concern';
    public static final String CATEGORY_TYPE = 'Category';
    public static final String SUBCATEGORY_TYPE = 'Subcategory';
    public static final String SYMPTOM_TYPE = 'Symptom';
	
	public static Case getCase(CAD_Loader__c cad, Id openCaseRecordTypeId, Id closedCaseRecordTypeId) {
		Case c = new Case();
		
		// Field not writeable
		//c.Action_Code__c = cad.CA_ACTION_CODE__c;
		c.Accident_Indicator__c = Text_Util.BooleanLookup(cad.Accident_Flag__c,false);
		c.Airbag_Indicator__c = Text_Util.BooleanLookup(cad.Airbag_Flag__c, false);
		//c.Beyond_Basic_Warranty_Miles__c = Text_Util.DecimalValueOf(cad.Beyond_Basic_Warnty_Miles__c);
		//c.Beyond_Basic_Warranty_Months__c = Text_Util.DecimalValueOf(cad.Beyond_Basic_Warnty_Mos__c);
		//c.Beyond_PT_Warranty_Miles__c = Text_Util.DecimalValueOf(cad.Beyond_PT_Warnty_Miles__c);
		//c.Beyond_PT_Warranty_Months__c = Text_Util.DecimalValueOf(cad.Beyond_PT_Warnty_Months__c);
		c.Callback_Count__c = Text_Util.DecimalValueOf(cad.Callback_Count__c);
		c.Callback_Date_CYMD__c = cad.Callback_Date_CYMD__c;
		c.Callback_UserId__c = cad.Callback_UserId__c;
		c.Call_Disposition_Code__c = cad.Call_Disposition_Code__c;
		c.Case_External_Id__c = cad.Document_Id__c;
		c.Channel_Designation_Code__c = cad.Channel_Designation_Code__c;
		c.Check_Request_Origin__c = cad.Check_Request_Origin__c;
		c.Classification__c = cad.Classification_Code__c;
		c.ClosedDate = Text_Util.CCYYMMDDNoDashesToDateTime(cad.Close_Date_CYMD__c);
		c.Considered_Vehicle_Make__c = cad.Considered_Vehicle_Make__c;
		c.Considered_Vehicle_Model__c = cad.Considered_Vehicle_Model__c;
		c.Mailing_City__c = cad.Consumer_City__c;
		c.Home_Phone__c = cad.Consumer_Day_Phone__c;
		c.EveningPhone__c = cad.Consumer_Eve_Phone__c;
		c.First_Name__c = cad.Consumer_First_Name__c;
		c.Last_Name__c = cad.Consumer_Last_Name__c;
		c.Middle_Initial__c = cad.Consumer_MI__c;
		c.Mailing_State__c = cad.Consumer_State__c;
		c.Mailing_Street__c = cad.Consumer_Street__c;
		c.Mailing_Street_2__c = cad.Consumer_Street_2__c;
		c.Mailing_Zip_Code__c = cad.Consumer_Zip_Code__c;
		c.Current_Vehicle_Lease_Exp_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Current_Vehicle_Lease_Exp_Dt__c);
		c.Current_Vehicle_Lease_Indicator__c = Text_Util.BooleanLookup(cad.Current_Vehicle_Lease_Flag__c, false);
		c.Datanet_Dealer_Count__c = cad.Datanet_Dealer_Count__c;
		c.Datanet_Dealer_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Datanet_Dealer_Date_CYMD__c);
		c.Datanet_Dealer_Indicator__c = Text_Util.BooleanLookup(cad.Datanet_Dealer_Flag__c, false);
		c.Dealer_Referral_Code__c = cad.Dealer_Referral_Code__c;
		c.Dealer_Update_By_User_Id__c = cad.Dealer_Update_By_User_Id__c;
		c.Dealer_Update_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Dealer_Update_Date_CYMD__c);
		c.Dealer_CA_Manager_Name__c = cad.Dlr_CA_Mgr_Name__c;
		c.Description = DEFAULT_DESCRIPTION;
		c.Legacy_Case_Number__c = cad.Document_Id__c;
		c.Email2__c = cad.Email_Address__c;
		c.Exec_Received_Date__c =cad.Exec_Received_Date__c != null ? Date.valueOf(cad.Exec_Received_Date__c) : null;
		c.Fire_Indicator__c = Text_Util.BooleanLookup(cad.Fire_Flag__c, false);
		c.Follow_Up_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Follow_Up_Date_CYMD__c);
		c.Vehicle_Year__c = cad.Full_Model_Year__c;
		c.Goodwill_Offered__c = Text_Util.BooleanLookup(cad.Goodwill_Claim_Flag__c, false);
		c.IIR_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.IIR_Date_CYMD__c);
		c.Incident_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Incident_Date__c);
		c.Incoming_Car_Indicator__c = Text_Util.BooleanLookup(cad.Incoming_Car_Flag__c, false);
		c.Injury_Indicator__c = Text_Util.BooleanLookup(cad.Injury_Flag__c, false);
		c.Letter_Received_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Letter_Received_Date__c);
		c.Nearest_Infiniti_Dealer__c = cad.Nearest_Infiniti_Dealer__c;
		c.Vehicles_Owned__c = Text_Util.DecimalValueOf(cad.Nis_Inf_Vehicles_Owned__c);
		c.Vehicle_Model__c = cad.NMC_Model_Code__c;
		c.Do_Not_Contact__c = Text_Util.BooleanLookup(cad.No_Contact_Flag__c, false);
		c.Number_Injured__c = Text_Util.DecimalValueOf(cad.Number_Injured__c);
		c.CreatedDate = Text_Util.CCYYMMDDNoDashesToDateTime(cad.Open_Date_CYMD__c);
		c.Originator_Region__c = cad.Originator_Region__c;
		c.OwnerId = '005A0000001Y7EkIAK';
		c.Part_Number_1__c = cad.Part_Number__c;
		c.Previous_Repair_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Previous_Repair_Date__c);
		c.Previous_Repair_Location__c = cad.Previous_Repair_Location__c;
		c.Property_Damage_Indicator__c = Text_Util.BooleanLookup(cad.Property_Damage_Flag__c, false);
		c.RecordTypeId = c.ClosedDate != null ? closedCaseRecordTypeId : openCaseRecordTypeId;
		c.Reopened_Times__c = Text_Util.DecimalValueOf(cad.Reopen_Count__c);
		c.Reopen_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Reopen_Date_CYMD__c);
		c.Resend_Request_Indicator__c = cad.Resend_Request_Flag__c;
		c.Responsibility_Code__c = cad.Responsibility_Code__c;
		c.Responsible_Dealer_Number__c = cad.Responsible_Dealer_Number__c;
		c.Retail_Dealer__c = cad.Retail_Dealer_Number__c;
		c.Road_Service_Call_Indicator__c = cad.Road_Service_Call_Flag__c;
		c.Road_Service_Call_Number__c = cad.Road_Service_Call_Number__c;
		c.Rollover_Indicator__c = Text_Util.BooleanLookup(cad.Rollover_Flag__c, false);
		c.Reopen_Callback_Count__c = Text_Util.DecimalValueOf(cad.Ropn_Cbk_Cnt__c);
		c.Reopen_Callback_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Ropn_Cbk_Date_CYMD__c);
		c.Reopen_Callback_UserId__c = cad.Ropn_Cbk_UserId__c;
		c.Reopen_New_UserId__c = cad.Ropn_New_UserId__c;
		c.Reopen_Other_Count__c = Text_Util.DecimalValueOf(cad.Ropn_Oth_Cnt__c);
		c.Reopen_Other_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Ropn_Oth_Date_CYMD__c);
		c.Reopen_Other_UserId__c = cad.Ropn_Oth_UserId__c;
		c.Safety_Indicator__c = Text_Util.BooleanLookup(cad.Safety_Related_Flag__c, false);
		c.Selected_Dealer_Number__c = cad.Selected_Dealer_Number__c;
		c.Sent_To_Legal_Indicator__c = Text_Util.BooleanLookup(cad.Sent_To_Legal_Flag__c, false);
		c.Service_Dealer_Number__c = cad.Servicing_Dealer_Number__c;
		c.Severity_Rating_Code__c = cad.Severity_Rating_Code__c;
		c.Special_Remark_Line_Count__c = cad.Spcl_Rmrk_Ln_Cnt__c;
		c.Stage_Status__c = System.Label.Stage_Status_Done;
		c.State_Of_Incident__c = cad.State_Of_Incident__c;
		c.Status = c.ClosedDate != null ? 'Closed' : 'Open';
		c.Survey_Dealer_Number__c = cad.Survey_Dealer_Number__c;
		c.Survey_Request_Date__c = cad.Survey_Request_DateYMD__c;
		c.Survey_Source__c = cad.Survey_Source__c;
		c.Survey_Type__c = cad.Survey_Type__c;
		c.Tel_Survey_Indicator__c = cad.Tel_Survey_Flag__c != 'Y' ? 'N' : 'Y';
		c.Third_Party_Involvement__c = cad.Third_Party_Involvement__c;
		c.Type = 'HOST';
		c.In_Service_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Vehicle_In_Svc_Date_CYMD__c);
		c.Vehicle_Maintained_Location__c = cad.Vehicle_Maint_Location__c;
		c.Current_Mileage__c = Text_Util.DecimalValueOf(cad.Vehicle_Mileage__c);
		c.Vehicle_Purchased_Miles__c = cad.Vehicle_Purchase_Mileage__c;
		c.VehiclePurchasedType__c = cad.Vehicle_Purchase_Type__c;
		c.VIN__c = cad.VIN_Number__c;
		c.When_Plan_Purchase__c = cad.When_Plan_Purchase__c;
		c.Who_Contacted_Us__c = getWhoContactedUs(cad.Originator_Code__c);
		c.Origin = getOrigin(cad.Originator_Code__c);
		
		return c;
	}
	    
    public static String getWhoContactedUs(String originatorCode) {
	    String value;
	    
    	if (originatorCode != null) {
	    	String key = originatorCode.substring(0,1);
	    	
			if (key == 'A')
				value = 'Attorney';
			else if (key == 'B')
				value = 'Consumer Agency / B.B.B.';
			else if (key == 'C')
				value = 'Consumer'; 
			else if (key == 'D')
				value = 'Dealer';
			else if (key == 'E')
				value = 'Executive / Executive Offices';
			else if (key == 'F')
				value = 'Foreign Distributor';
			else if (key == 'H')
				value = 'CCG Infiniti Consumer Affairs';
			else if (key == 'I')
				value = 'In-Field Comment';
			else if (key == 'J')
				value = 'Japan / Nissan Motor Ltd.';
			else if (key == 'K')
				value = 'Contact Retailer / Internet';
			else if (key == 'L')
				value = 'Legal Department';
			else if (key == 'N')
				value = 'NHTSA/ DOT/ Government';
			else if (key == 'R')
				value = 'Roadside (Infiniti)';
			else if (key == 'S')
				value = 'Survey'; 
			else if (key == 'T')
				value = 'NMMC/Smyrna/MVEP';
			else if (key == 'X')
				value = 'Downgraded Executive';
			else
				value = '1Problem';
    	}
		
		return value;
    }
    
    public static String getOrigin(String originatorCode) {
    	String value;
    	
    	if (originatorCode != null) {
	    	String key = originatorCode.substring(1,2);
	    	
	    	if (key == 'E')
	    		value = 'Email';
	    	else if (key == 'T')
	    		value = 'Phone'; 
	    	else if (key == 'L')
	    		value = 'Letter / Fax';
	    	else if (key == 'I')
	    		value = 'In-Person / Lobby';
	    	else
				value = '2Problem';
    	} 
			
		return value;
    }
    
    public static Account getAccount(CAD_Loader__c cad) {
    	Account acct = new Account();
    	
    	acct.Do_Not_Email_In__c = cad.Email_Flag__c;
    	acct.Language_Preference__c = cad.Language_code__c;
    	acct.Salutation = cad.Consumer_Prefix__c;
    	acct.FirstName = cad.Consumer_First_Name__c;
    	acct.MiddleName__c = cad.Consumer_MI__c;
    	acct.LastName = cad.Consumer_Last_Name__c;
    	acct.PersonMailingStreet = cad.Consumer_Street__c + ' ' + cad.Consumer_Street_2__c;
    	acct.PersonMailingCity = cad.Consumer_City__c;
    	acct.PersonMailingState = cad.Consumer_State__c;
    	acct.PersonMailingPostalCode = cad.Consumer_Zip_Code__c;
    	acct.Phone = cad.Consumer_Day_Phone__c;
    	acct.PersonHomePhone = cad.Consumer_Eve_Phone__c;
    	acct.PersonEmail = cad.Email_Address__c;
    	
    	return acct;
    }

	public static Vehicle__c getVehicle(CAD_Loader__c cad) {
		Vehicle__c vehicle = new Vehicle__c();
		vehicle.In_Service_Date__c = Text_Util.CCYYMMDDNoDashesToDate(cad.Vehicle_In_Svc_Date_CYMD__c);
		vehicle.Latest_Recorded_Mileage_Number__c = Text_Util.DecimalValueOf(cad.Vehicle_Mileage__c);
		vehicle.Latest_Recorded_Mileage_Units__c = 'M';
		vehicle.Model_Code__c = cad.NMC_Model_Code__c;
		vehicle.Model_Line_Name__c = cad.Model_Line__c;
		vehicle.Model_Year__c = getModelYear(cad.Full_Model_Year__c);
		vehicle.Vehicle_Identification_Number__c = cad.VIN_Number__c;
		
		return vehicle;
	}

	public static String getModelYear(String mfModelYear) {
		String year = '';
		
		if (mfModelYear != null && mfModelYear.length() == 3) {
			year = mfModelYear.substring(0,2);
			String halfYear = mfModelYear.substring(2,3);
			
			Integer yearInt = Integer.valueOf(year);
			if (yearInt >= 59)
				year = '19' + year;
			else
				year = '20' + year;
				
			if (halfYear == '5')
				year = year + '.5';			
		}
		
		return year;
	}

    public static void fillCodeMaps(Map<String, Code__c> concerns,
                                    Map<String, Code__c> categories,
                                    Map<String, Code__c> subcategories,
                                    Map<String, Code__c> symptoms) {
    	// Get all Categorization Code records so we can set the Salesforce Id for the lookup.
    	List<Code__c> codes = [select Id, Type__c, Code__c, Description__c 
    	                       from Code__c
    	                       where Type__c in (:CONCERN_TYPE, :CATEGORY_TYPE, :SUBCATEGORY_TYPE, :SYMPTOM_TYPE)];

		for (Code__c code: codes) {
			if (code.Type__c == CONCERN_TYPE) {
				concerns.put(code.Code__c, code);
			} else if (code.Type__c == CATEGORY_TYPE) {
				categories.put(code.Code__c, code);
			} else if (code.Type__c == SUBCATEGORY_TYPE) {
				subcategories.put(code.Code__c, code);
			} else if (code.Type__c == SYMPTOM_TYPE) {
				symptoms.put(code.Code__c, code);
			}
		}
    }

	// Create a Case_Categorization object from the input CATEG_Loader__c and populate the
	// Case Id from the Case.
	public static Case_Categorization__c getCaseCategorization(CATEG_Loader__c cat, Case c,
	                                                           Map<String, Code__c> concerns,
	                                                           Map<String, Code__c> categories,
	                                                           Map<String, Code__c> subcategories,
	                                                           Map<String, Code__c> symptoms) {
		Case_Categorization__c cc = new Case_Categorization__c();
		Code__c code;
		
		cc.Case__c = c.Id;
		code = categories.get(cat.Category_Code__c);
		cc.Category__c = code != null ? code.Id : null;
		cc.Category_Code__c = cat.Category_Code__c;
		code = concerns.get(cat.Concern_Code__c);
		cc.Concern__c = code != null ? code.Id : null;
		cc.Concern_Code__c = cat.Concern_Code__c;
		cc.Major_Component_Code__c = cat.Major_Component_Code__c;
		cc.Root_Cause__c = cat.Root_Cause__c;
		cc.Stage_Status__c = System.Label.Stage_Status_Done;
		code = subcategories.get(cat.Subcategory_Code__c);
		cc.Subcategory__c = code != null ? code.Id : null;
		cc.Subcategory_Code__c = cat.Subcategory_Code__c;
		code = symptoms.get(cat.Symptom_Code__c);
		cc.Symptom__c = code != null ? code.Id : null;
		cc.Symptom_Code__c = cat.Symptom_Code__c;
		cc.Stage_Status__c = System.Label.Stage_Status_Done;
		
		return cc;
	}
	
	// Set the Root Cause flag from the CATEG_Loader__c table to the Case appropriately.
	public static void setRootCauseFlags(CATEG_Loader__c cat, Case c) {
		if (cat.Root_Cause__c != null && 
		    cat.Root_Cause__c != c.Legacy_Root_Cause__c && 
		    cat.Root_Cause__c != c.Legacy_Root_Cause_2__c) {
		    	
			if (c.Legacy_Root_Cause__c == null || c.Legacy_Root_Cause__c.length() == 8) {
				c.Legacy_Root_Cause__c = cat.Root_Cause__c;
			} else if (c.Legacy_Root_Cause_2__c == null || c.Legacy_Root_Cause_2__c.length() == 8) {
				c.Legacy_Root_Cause_2__c = cat.Root_Cause__c;
			}
		}
	}
}