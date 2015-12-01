/**********************************************************************
Name: DQRClass
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Core function of creating DQR record from DQR Lead Stage. Called by DQR_Lead_Stage_Before and Customer_Stage_Before
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 3/29/2012 Created
***********************************************************************/
public with sharing class DQRClass {
    private static final Id CCC_FOLLOWUP_RECORD_TYPE = '012F0000000yBMo';
    private static final Id PRE_SELL_RECORD_TYPE = '012F0000000yD8Q';
    
    public static void buildDQRs(List<Dealer_Quotes_Request_Lead_Stage__c> DQRLs) {
        
        List<String> customerIds = new List<String>();
        Map<String, Account> dealerCodes = new Map<String, Account>();
        Set<String> leadids = new Set<String>();
        Map<String, Vehicle__c> vins = new Map<String, Vehicle__c>();
        
        for (Dealer_Quotes_Request_Lead_Stage__c req : DQRLs) {
            if (req.DQRC_ContactID__c == null || req.DQRC_ContactID__c == '')
                continue;
            
            if (req.DQRL_lead_id__c == null || req.DQRL_lead_id__c == '')
                continue;
            
            customerIds.add(req.DQRC_ContactID__c);
            leadids.add(req.DQRL_lead_id__c);
            
            if (req.DQRL_dealer_id__c != null) {
                String dealerCode = req.DQRL_dealer_id__c;
                System.Debug('**** dealerCode ' + dealerCode);
                if (!dealerCodes.containsKey(dealerCode)) {
                    dealerCodes.put(dealerCode, new Account(Dealer_Code__c = dealerCode,
                                                        Dealer_External_Id__c = dealerCode + System.label.Dealer_USA,
                                                        Region_Name__c = req.DQRL_region__c,
                                                        Region_Code__c = req.DQRL_region__c,
                                                        District_Name__c = req.DQRL_district__c,
                                                        District_Code__c = req.DQRL_district__c,
                                                        Name = req.DQRL_dealer_name__c,
                                                        Phone = req.DQRL_dealer_main_phone__c,
                                                        //req.DQRL_dealer_internet_phone__c,
                                                        BillingStreet = req.DQRL_dealer_address__c,
                                                        RecordTypeID = '012A0000000OfI0',
                                                        OwnerID = system.label.Batch_Record_Owner));
                }
            }
            
            if (req.DQRL_interest_vehicle_vin__c != null) {
                String vin = req.DQRL_interest_vehicle_vin__c, make = 'Nissan', model, recordtype = '012A0000000OfXm';
                if (req.DQRL_interest_vehicle_model__c != null) {
                    integer space = req.DQRL_interest_vehicle_model__c.indexOf(' ');
                    if (space > 0) {
                        make = req.DQRL_interest_vehicle_model__c.substring(0, space);
                        model = req.DQRL_interest_vehicle_model__c.substring(space+1, req.DQRL_interest_vehicle_model__c.length());
                        
                        if (!make.equalsIgnoreCase('Nissan'))
                            recordtype = '012A0000000OfXh';
                        else
                            recordtype = '012A0000000OfXm';
                    }
                }
                if (!vins.containsKey(vin)) {
                    vins.put(vin, new Vehicle__c(Name = req.DQRL_interest_vehicle_vin__c,
                                                Vehicle_identification_Number__c = req.DQRL_interest_vehicle_vin__c,
                                                Trim_Type__c = req.DQRL_interest_vehicle_trim__c,
                                                Transmission_Type__c = req.DQRL_interest_vehicle_transmission__c,
                                                Latest_Recorded_Mileage_Number__c = Text_Util.DecimalValueOf(req.DQRL_interest_vehicle_odometer__c),
                                                Latest_Recorded_Mileage_Units__c = 'M',
                                                Model_Year__c = req.DQRL_interest_vehicle_model_year__c,
                                                Make_Name__c = make,
                                                Model_Line_Name__c = model,
                                                //DQRL_interest_vehicle_interior_color__c
                                                Exterior_Color_Type__c = req.DQRL_interest_vehicle_exterior_color__c,
                                                Body_Style_Type__c = req.DQRL_interest_vehicle_bodystyle__c,
                                                OwnerID = system.label.Batch_Record_Owner,
                                                RecordTypeId = recordtype));
                }
            }           
        }
        
        //existing DQRs, in case the same lead gets passed to us again
        Map<String, Dealer_Quotes_Request__c> leadIDtoDQR = new Map<String, Dealer_Quotes_Request__c>();
        for (Dealer_Quotes_Request__c dqr : [Select spanish_lead__c, purchase_timeframe__c, preferred_method__c, lead_comments__c, lead_id__c, lead_date__c, 
                    lead_category__c, interest_vehicle_vin__c, interest_vehicle_trim__c, interest_vehicle_transmission__c, interest_vehicle_stock__c, 
                    interest_vehicle_odometer__c, interest_vehicle_model_year__c, interest_vehicle_model__c, interest_vehicle_interior_color__c, 
                    interest_vehicle_exterior_color__c, interest_vehicle_bodystyle__c, area__c, Street__c, State__c, Salutation__c, S2_q7__c, 
                    S2_q11__c, Region_Name__c, PostalCode__c, Phone__c, Name, LastName__c, Id, FirstName__c, Email__c, Division__c, District_Name__c, 
                    Dealer_Name__c, Dealer_Main_Phone__c, Dealer_Id__c, Dealer_Address__c, DQR_Dealer__c, Customer_ID__c, City__c, Case__c, Account__c,
                    Lead_ProviderName__c, Lead_ProviderService__c, Lead_Provider_Detail__c
                From Dealer_Quotes_Request__c d Where lead_id__c in: leadids]) {
            leadIDtoDQR.put(dqr.lead_id__c, dqr);
        }
        
        //look for existing dealer, if it does not exist, create
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Map<String, Account> dealderMap = Text_Util.linkDealersByDealerCode(dealerCodes, null, errors);
        //look for existing customer. DO Not create customer here, because it will get passed back to Maritz and update there
        Map<String, Account> customerMap = Text_Util.getCustomerIDMap(customerIds);
        //look for existing vehicle, if it does not exist, create
        Map<String, Vehicle__c> vehicleMap = Text_Util.linkVehiclesByVIN(vins, null, errors);
        System.Debug('*** DQRClass link errors ****' + errors);
        
        Integer index = -1, u = 0, i = 0, ci = 0;
        Map<Integer, Dealer_Quotes_Request__c> dqrToUpdateMap = new Map<Integer, Dealer_Quotes_Request__c>();
        Map<Integer, Dealer_Quotes_Request__c> dqrToInsertMap = new Map<Integer, Dealer_Quotes_Request__c>();
        Map<Integer, Case> caseToInsert = new Map<Integer, Case>();
        Map<Integer, Dealer_Quotes_Request_Lead_Stage__c> updateStageList = new Map<Integer, Dealer_Quotes_Request_Lead_Stage__c>();
        Map<Integer, Integer> indexMapInsert = new Map<Integer, Integer>();
        Map<Integer, Integer> indexMapUpdate = new Map<Integer, Integer>();
        Map<Integer, Integer> indexMapCaseInsert = new Map<Integer, Integer>();

        // Create options to use default case assignment rule and use with all created Cases
        Database.DMLOptions dmo = new database.DMLOptions();
        dmo.AssignmentRuleHeader.UseDefaultRule= true;
        
        for (Dealer_Quotes_Request_Lead_Stage__c req : DQRLs) {
            //always increases
            index++;
            updateStageList.put(index, req);
            
            String custID = req.DQRC_ContactID__c;
            //if customer does not exist
            if (!customerMap.containsKey(custID)) {
                req.Error_Message__c = 'Unable to find Customer ' + custID + '.';
                req.Successful__c = 'N';
                req.RelatedID__c = NULL;
                continue;
            }
            
            Account account = customerMap.get(custID);
            Dealer_Quotes_Request__c dqr = null;
            Id caseRecordTypeId  = CCC_FOLLOWUP_RECORD_TYPE;

            Case c = new Case(AccountID = account.ID, ContactID = account.PersonContactID, RecordTypeID = caseRecordTypeId);
            // Use default Case Assignment Rule
            c.setOptions(dmo);
            
            if (leadIDtoDQR.containsKey(req.DQRL_lead_id__c)) {     //if DQR record exists for the given lead
                dqr = leadIDtoDQR.get(req.DQRL_lead_id__c);
                dqrToUpdateMap.put(index, dqr);
                
                indexMapUpdate.put(u, index);
                u++;
                
                if (dqr.Case__c == null) {      //if DQR record exists for the given lead, but no case is associated. 
                    caseToInsert.put(index, c);
                    indexMapCaseInsert.put(ci, index);
                    ci++;
                }
            } else {
                dqr = new Dealer_Quotes_Request__c();
                dqrToInsertMap.put(index, dqr);
                caseToInsert.put(index, c);
                
                indexMapCaseInsert.put(ci, index);
                ci++;
                
                indexMapInsert.put(i, index);
                i++;
            }
            
            String dealerCode = req.DQRL_dealer_id__c;
            String vin = req.DQRL_interest_vehicle_vin__c;
            
            dqr.Account__c = account.ID;
            //dqr.ActionFlag__c = req.DQRL_ActionFlag__c;
            //dqr.Action_Plan__c = req.DQRL_Action_Plan__c;
            dqr.City__c = req.DQRL_contact_city__c;
            //dqr.Contacted_by_Dealer__c = req.DQRL_Contacted_by_Dealer__c;
            //dqr.Customer_Contacted__c = req.DQRL_Customer_Contacted__c;
            dqr.Customer_ID__c = custID;
            
            if (dealderMap != null && dealderMap.containsKey(dealerCode)) {
                dqr.DQR_Dealer__c = dealderMap.get(dealerCode).Id;
                dqr.Preferred_Dealer__c = dealderMap.get(dealerCode).Id;
            }
            
            //dqr.DQR_Disposition__c = req.DQRL_DQR_Disposition__c;
            dqr.Dealer_Address__c = req.DQRL_Dealer_Address__c;
            //dqr.Dealer_Follow_Up_Status__c = req.DQRL_Dealer_Follow_Up_Status__c;
            dqr.Dealer_Id__c = req.DQRL_Dealer_Id__c;
            dqr.Dealer_Internet_Phone__c = req.DQRL_Dealer_Internet_Phone__c;
            dqr.Dealer_Main_Phone__c = req.DQRL_Dealer_Main_Phone__c;
            dqr.Dealer_Name__c = req.DQRL_Dealer_Name__c;
            //dqr.Description__c = req.DQRL_Description__c;
            dqr.District_Name__c = req.DQRL_District__c;
            dqr.Division__c = req.DQRL_Division__c;
            dqr.Email__c = req.DQRL_contact_email__c;
            //dqr.FFScore__c = req.DQRL_FFScore__c;
            dqr.FirstName__c = req.DQRL_First_Name__c;
            //dqr.Follow_Up_Action__c = req.DQRL_Follow_Up_Action__c;
            //dqr.Follow_Up_Call__c = req.DQRL_Follow_Up_Call__c;
            //dqr.Follow_Up_Status__c = req.DQRL_Follow_Up_Status__c;
            //dqr.InternalFerretID__c = req.DQRL_InternalFerretID__c;
            //dqr.Key__c = req.DQRL_Key__c;
            dqr.LastName__c = req.DQRL_Last_Name__c;
            dqr.Lead_Comments__c = req.DQRL_Lead_Comments__c;
            dqr.Lead_ProviderName__c = req.DQRL_User_Defined_Text1__c;
            dqr.Lead_ProviderService__c = req.DQRL_User_Defined_Text2__c;
            dqr.Lead_Provider_Detail__c = req.DQRL_User_Defined_Text3__c;
            dqr.Lead_Category__c = req.DQRL_User_Defined_Text4__c;
            dqr.VPP_Claim_Code__c = req.DQRL_User_Defined_Text5__c;
            //dqr.Lead__c = req.DQRL_Lead__c;
            dqr.Likely_To_Purchase__c = req.DQRL_lead_score__c;
            //dqr.NPSBand__c = req.DQRL_NPSBand__c;
            //dqr.Net_Promoter_Score__c = req.DQRL_Net_Promoter_Score__c;
            //dqr.New_Dealer__c = req.DQRL_New_Dealer__c;
            dqr.Phone__c = req.DQRL_contact_PhoneNo__c;
            dqr.PostalCode__c = req.DQRL_contact_zip__c;
            //dqr.Preferred_Dealer__c = req.DQRL_Preferred_Dealer__c;
            //dqr.Priority__c = req.DQRL_Priority__c;
            //dqr.RawDataID__c = req.DQRL_RawDataID__c;
            dqr.Region_Name__c = req.DQRL_Region__c;
            //dqr.Resolving_Dealer__c = req.DQRL_Resolving_Dealer__c;
            dqr.S2_q11__c = req.DQRL_User_Defined_Text1__c;
            dqr.S2_q12ai__c = req.DQRL_User_Defined_Text2__c;
            dqr.S2_q12bi__c = req.DQRL_User_Defined_Text3__c;
            dqr.S2_q12ci__c = req.DQRL_User_Defined_Text4__c;
            dqr.S2_q12di__c = req.DQRL_User_Defined_Text5__c;
            dqr.S2_q12ei__c = req.DQRL_User_Defined_Text6__c;
            dqr.S2_q12fi__c = req.DQRL_User_Defined_Text7__c;
            dqr.S2_q13__c = req.DQRL_User_Defined_Text8__c;
            dqr.S2_q19__c = req.DQRL_User_Defined_Text9__c;
            //dqr.S2_q1_March2011__c = req.DQRL_S2_q1_March2011__c;
            //dqr.S2_q2_March2011__c = req.DQRL_S2_q2_March2011__c;
            dqr.S2_q7__c = req.DQRL_User_Defined_Text10__c;
            //dqr.Sale_Date__c = req.DQRL_Sale_Date__c;
            dqr.Salutation__c = req.DQRL_Salutation__c;
            //dqr.SentimentBandRow__c = req.DQRL_SentimentBandRow__c;
            dqr.Spare3__c = req.DQRL_script_10_decile_score__c;
            dqr.State__c = req.DQRL_contact_state_province__c;
            //dqr.Status__c = req.DQRL_Status__c;
            dqr.Street__c = req.DQRL_contact_address__c;
            //dqr.Verbatim_Comments__c = req.DQRL_Verbatim_Comments__c;
            //dqr.Vin_Purchased__c = req.DQRL_Vin_Purchased__c;
            dqr.area__c = req.DQRL_area__c;
            //dqr.brand__c = req.DQRL_brand__c;
            //dqr.contact_us_address__c = req.DQRL_contact_us_address__c;
            //dqr.contact_us_email__c = req.DQRL_contact_us_email__c;
            //dqr.contact_us_phone__c = req.DQRL_contact_us_phone__c;
            dqr.interest_vehicle_bodystyle__c = req.DQRL_interest_vehicle_bodystyle__c;
            //dqr.interest_vehicle_doors__c = req.DQRL_interest_vehicle_doors__c;
            dqr.interest_vehicle_exterior_color__c = req.DQRL_interest_vehicle_exterior_color__c;
            dqr.interest_vehicle_interior_color__c = req.DQRL_interest_vehicle_interior_color__c;
            dqr.interest_vehicle_model__c = req.DQRL_interest_vehicle_model__c;
            dqr.interest_vehicle_model_year__c = req.DQRL_interest_vehicle_model_year__c;
            dqr.interest_vehicle_odometer__c = req.DQRL_interest_vehicle_odometer__c;
            //dqr.interest_vehicle_stock__c = req.DQRL_interest_vehicle_stock__c;
            dqr.interest_vehicle_transmission__c = req.DQRL_interest_vehicle_transmission__c;
            dqr.interest_vehicle_trim__c = req.DQRL_interest_vehicle_trim__c;
            dqr.interest_vehicle_vin__c = req.DQRL_interest_vehicle_vin__c;
            dqr.lead_date__c = req.DQRL_lead_date__c;
            dqr.lead_id__c = req.DQRL_lead_id__c;
            dqr.preferred_method__c = req.DQRL_preferred_method__c;
            //dqr.privacy_link__c = req.DQRL_privacy_link__c;
            dqr.purchase_timeframe__c = req.DQRL_purchase_timeframe__c;
            //dqr.signature_name__c = req.DQRL_signature_name__c;
            //dqr.signature_title__c = req.DQRL_signature_title__c;
            dqr.spanish_lead__c = req.DQRL_spanish_lead__c;
            //dqr.survey_response_date__c = req.DQRL_survey_response_date__c;
            //dqr.survey_sent_date__c = req.DQRL_survey_sent_date__c;
            //dqr.survey_status__c = req.DQRL_survey_status__c;
            dqr.time_zone__c = req.DQRL_zone__c;
            //dqr.vehicle_image__c = req.DQRL_vehicle_image__c;
            dqr.OwnerID = system.label.Batch_Record_Owner;
            
            c.Subject = req.DQRL_division__c + ' Dealer Quote follow up';
            c.Channel_Designation_Code__c = req.DQRL_division__c;
            c.Dealer__c = dqr.DQR_Dealer__c;
            c.Preferred_Dealer__c = dqr.DQR_Dealer__c;
            c.OwnerID = system.label.Batch_Record_Owner;
            c.Contact_ID__c = req.DQRC_ContactID__c;
            c.Mailing_City__c = req.DQRL_contact_city__c;
            c.Mailing_State__c = req.DQRL_contact_state_province__c;
            c.Mailing_Street__c = req.DQRL_contact_address__c;
            //Mailing_Street_2__c
            //Mailing_Zip_Plus4__c
            c.Mailing_Zip_Code__c = req.DQRL_contact_zip__c;
            c.Email2__c = req.DQRL_contact_email__c;
            c.Home_Phone__c = req.DQRL_contact_phoneno__c;
            c.Dealer_Number__c = req.DQRL_dealer_id__c;
            c.District_Name__c = req.DQRL_district__c;
            c.Considered_Vehicle_Make__c = req.DQRL_division__c;
            c.Considered_Vehicle_Model__c = req.DQRL_interest_vehicle_model__c;
            c.Vehicle_Year__c = req.DQRL_interest_vehicle_model_year__c;
            c.Area__c = req.DQRL_area__c;
            c.DQR_Number__c = req.DQRL_lead_id__c;
            c.Maritz_Customer_Id__c = account.Maritz_Returned_Customer_Id__c;
            //c.Make__c = req.DQRL_division__c;
            c.Vehicle_DQR_Information__c = 'Interest vehicle bodystyle: ' + req.DQRL_interest_vehicle_bodystyle__c + '; ' +
                                            'Interest vehicle exterior color: ' + req.DQRL_interest_vehicle_exterior_color__c + '; ' +
                                            'Interest vehicle interior color: ' + req.DQRL_interest_vehicle_interior_color__c + '; ' +
                                            'Interest vehicle odometer: ' + req.DQRL_interest_vehicle_odometer__c + '; ' +
                                            'Interest vehicle transmission: ' + req.DQRL_interest_vehicle_transmission__c + '; ' +
                                            'Interest vehicle trim: ' + req.DQRL_interest_vehicle_trim__c + '; ' +
                                            'Interest vehicle vin: ' + req.DQRL_interest_vehicle_vin__c;

            c.Description = req.DQRL_lead_comments__c;
            c.date_sent__c = Text_Util.MMDDCCYYtoDate(req.DQRL_Lead_Date__c);
            c.Preferred_Contact_Method__c = req.DQRL_preferred_method__c;
            c.Spanish_Speaking_customer__c = Text_Util.BooleanLookup(req.DQRL_spanish_lead__c, false);
            c.Lead_Provider_Name__c = req.DQRL_User_Defined_Text1__c;
            c.Lead_Provider__c = req.DQRL_User_Defined_Text2__c;
            c.Lead_Provider_Detail__c = req.DQRL_User_Defined_Text3__c;
            c.Lead_Category__c = req.DQRL_User_Defined_Text4__c;
            c.VPP_Claim_Code__c = req.DQRL_User_Defined_Text5__c;
            c.Likely_To_Purchase__c = req.DQRL_lead_score__c;
            c.purchase_timeframe__c = req.DQRL_purchase_timeframe__c;
            c.lead_date__c = req.DQRL_lead_date__c;
            c.Surveyable__c = Text_Util.BooleanLookup(req.DQRL_User_Defined_Text6__c,false);
            if (req.DQRL_User_Defined_Text7__c != null && c.Surveyable__c != null) {
                
                
                if (req.DQRL_User_Defined_Text7__c.length() == 19) {
                    req.DQRL_User_Defined_Text7__c = req.DQRL_User_Defined_Text7__c + '-04:00';  //assumes eastern
                }
                if (req.DQRL_User_Defined_Text7__c.length() >= 25 && c.Surveyable__c) {
                    String thisTz = dealderMap.get(dealerCode).Dealer_Time_Zone__c;
                    
                    if (thisTz == 'CT') {         thisTz = 'CST';
                    } else if (thisTz == 'ET') { thisTz = 'EST';
                    } else if (thisTz == 'MT') {  thisTz = 'MST';
                    } else if (thisTz == 'PT') {  thisTz = 'PST';
                    } else if (thisTz == 'HT') {  thisTz = 'HST';
                    } else if (thisTz == 'AKT') {  thisTz = 'AKST';
                    }

                    c.SurveyGizmo24HourSent__c = checkEmail(req.DQRL_contact_email__c);
                    c.SurveyGizmoLeadCreationtime__c = getSurveyLeadDate(req.DQRL_User_Defined_Text7__c);
                    c.SurveyGizmoBatchdatetime__c = getSurveySendDate(req.DQRL_User_Defined_Text7__c,thisTz); 
                }
             }
            if (vehicleMap != null && vehicleMap.containsKey(vin)) {
                c.Vehicle_Name__c = vehicleMap.get(vin).Id;
                c.VIN__c = vin;
            }
        }
        
        //create cases
        if (caseToInsert.size() > 0) {
            Database.SaveResult[] dbResult = database.insert(CaseToInsert.values(), false);
            for (integer row = 0; row < CaseToInsert.size(); row++) {
                Database.SaveResult result = dbResult[row];
                if (!result.isSuccess()) {
                    Database.Error err = dbResult[row].getErrors()[0];
                    Dealer_Quotes_Request_Lead_Stage__c req = updateStageList.get(indexMapCaseInsert.get(row));
                    req.Error_Message__c = Text_Util.TruncateString('Failed to create the case related to the dealer quotes request: ' + err.getMessage(), 255);
                    req.Successful__c = 'N';
                    req.RelatedID__c = NULL;
                }
            }
        }
        
        //relate cases with dqrs
        for (Integer k = 0; k <= index; k++) {
            Dealer_Quotes_Request_Lead_Stage__c req = updateStageList.get(k);
            
            if (caseToInsert.containsKey(k)) {
                ID caseId = caseToInsert.get(k).Id;
                if (caseId != null) {
                    if (dqrToInsertMap.containsKey(k)) {
                        Dealer_Quotes_Request__c dqr = dqrToInsertMap.get(k);
                        dqr.Case__c = caseId;
                    } else if (dqrToUpdateMap.containsKey(k)) {
                        Dealer_Quotes_Request__c dqr = dqrToUpdateMap.get(k);
                        if (dqr.Case__c == null)
                            dqr.Case__c = caseId;
                    }
                }
            }
        }
        
        //create dqrs if dqrs do not exist
        if (dqrToInsertMap.size() > 0) {
            Database.SaveResult[] dbResult = database.insert(dqrToInsertMap.values(), false);
            for (integer row = 0; row < dqrToInsertMap.size(); row++) {
                Dealer_Quotes_Request_Lead_Stage__c req = updateStageList.get(indexMapInsert.get(row));
                
                Database.SaveResult result = dbResult[row];
                if (!result.isSuccess()) {
                    Database.Error err = dbResult[row].getErrors()[0];
                    req.Error_Message__c = Text_Util.TruncateString('Failed to create the dealer quotes request: ' + err.getMessage(), 255);
                    req.Successful__c = 'N';
                    req.RelatedID__c = NULL;
                } else {
                    req.RelatedID__c = result.getID();
                    req.Error_Message__c = '';
                    req.Successful__c = 'Y';
                }
            }
        }
        
        //update dqrs if dqrs exist
        if (dqrToUpdateMap.size() > 0) {
            Database.SaveResult[] dbResult = database.update(dqrToUpdateMap.values(), false);
            for (integer row = 0; row < dqrToUpdateMap.size(); row++) {
                Dealer_Quotes_Request_Lead_Stage__c req = updateStageList.get(indexMapUpdate.get(row));
                
                Database.SaveResult result = dbResult[row];
                if (!result.isSuccess()) {
                    Database.Error err = dbResult[row].getErrors()[0];
                    req.Error_Message__c = Text_Util.TruncateString('Failed to update the dealer quotes request: ' + err.getMessage(), 255);
                    req.Successful__c = 'N';
                    req.RelatedID__c = NULL;
                } else {
                    req.RelatedID__c = result.getID();
                    req.Error_Message__c = '';
                    req.Successful__c = 'Y';
                }
            }
        }
        
        // Put DQR Ids onto the Cases
        for (Integer k = 0; k <= index; k++) {
            if (caseToInsert.containsKey(k)) {
                Case c = caseToInsert.get(k);
                if (c.Id != null) {
                    if (dqrToInsertMap.containsKey(k)) {
                        Dealer_Quotes_Request__c dqr = dqrToInsertMap.get(k);
                        c.Dealer_Quotes_Request__c = dqr.Id;
                    } else if (dqrToUpdateMap.containsKey(k)) {
                        Dealer_Quotes_Request__c dqr = dqrToUpdateMap.get(k);
                        c.Dealer_Quotes_Request__c = dqr.Id;
                    }
                }
            }
        }

        // Update cases to include Dealer_Quotes_Request__c lookup
        if (caseToInsert.size() > 0) {
            Database.SaveResult[] dbResult = database.update(caseToInsert.values(), false);
            for (integer row = 0; row < CaseToInsert.size(); row++) {
                Database.SaveResult result = dbResult[row];
                if (!result.isSuccess()) {
                    Database.Error err = dbResult[row].getErrors()[0];
                    Dealer_Quotes_Request_Lead_Stage__c req = updateStageList.get(indexMapCaseInsert.get(row));
                    req.Error_Message__c = Text_Util.TruncateString('Failed to update the case related to the dealer quotes request: ' + err.getMessage(), 255);
                    req.Successful__c = 'N';
                    req.RelatedID__c = NULL;
                }
            }
        }
    }
    
   





    
    
    
    //create Account record by Customer Stage. The logic of each field mapping is based on CI 4_1_1_3_Customer_MLM_Salesforce
    public static Account fillAccount(Customer_Stage__c req) {
        return new Account(LastName = (req.CUST_LastName__c == null || req.CUST_LastName__c == '' ? 'X' : req.CUST_LastName__c),
                FirstName = req.CUST_FirstName__c,
                Salutation = req.CUST_Title_Prefix__c,
                RecordTypeID = '012A0000000wu5h',
                PersonMailingStreet = Text_Util.valueConcatenation_Delim(req.CUST_Address1__c, req.CUST_Address2__c, ' '),
                PersonMailingCity = req.CUST_City__c,
                PersonMailingState = req.CUST_State__c,
                PersonMailingPostalCode = Text_Util.valueConcatenation_Delim(req.CUST_ZipCode__c, req.CUST_Zip4__c, ''),
                PersonMailingCountry = req.CUST_Country__c,
                Phone = req.CUST_Mobile_Phone_Line__c,
                PersonMobilePhone = req.CUST_Mobile_Phone_Line__c,
                PersonHomePhone = req.CUST_Home_Phone__c,
                PersonOtherPhone = req.CUST_Work_Phone__c,
                PersonEmail = Text_Util.toValidEmail(req.CUST_EmailAddress__c),
                Household_ID__c = req.CUST_Household_Key__c,
                Undeliverable_Email_Address_In__c = Text_Util.BooleanLookup(req.CUST_UndeliverableEmail__c, false),
                Business_Indicator__c = Text_Util.BooleanLookup(req.CUST_Business__c, false),
                Customer_ID__c = req.CUST_ContactID__c,
                Do_Not_Contact_Indicator__c = Text_Util.BooleanLookup(req.CUST_DoNotContact__c, false),
                Do_Not_Email_In__c = req.CUST_Do_Not_Email__c,
                Do_Not_Mail_Indicator__c = Text_Util.BooleanLookup(req.CUST_DoNotMail__c, false),
                MiddleName__c = req.CUST_Middle__c,
                Undeliverable_Address_Indicator__c = Text_Util.BooleanLookup(req.CUST_SnailMailUndeliverable__c, false),
                Home_Phone_Do_Not_Call__c = TRUEFALSEtoYESNO(req.CUST_MaritzDoNotCallHome__c), //NONE, YES, NO
                Other_Phone_Do_Not_Call_In__c = TRUEFALSEtoYESNO(req.CUST_MaritzDoNotCallWork__c),
                Mobile_Phone_Do_Not_Call_Indicator__c = TRUEFALSEtoYESNO(req.CUST_MaritzDoNotCallMobile__c),
                Customer__c = Text_Util.BooleanLookup(req.CUST_OwnerFl__c, false),
                Handraiser__c = Text_Util.BooleanLookup(req.CUST_HandraiserFl__c, false),
                Lead__c = Text_Util.BooleanLookup(req.CUST_LeadFl__c, false),
                Reservationist__c = Text_Util.BooleanLookup(req.CUST_ReservationFl__c, false),
                OwnerID = system.label.Batch_Record_Owner
                //Name = CUST_FullName__c
                //CUST_FCCDoNotCallHome__c
                //CUST_FCCDoNotCallMobile__c
                //CUST_FCCDoNotCallWork__c
                //CUST_NewFl__c
                //CUST_Suffix__c
                //CUST_WebsiteAcctFl__c
                );
    }
    
    private static String TRUEFALSEtoYESNO(String input) {
        if(input == null || input == '' || input == 'NONE')
            return 'NONE';
        
        if(input == 'TRUE' || input == 'YES')
            return 'YES';
            
        return 'NO';
    }
    
    public static Boolean checkEmail(String emailAddress) {

        DateTime rightnow = DateTime.now();
        DateTime backthen;
        backthen = rightnow.addHours(-24);
        
        if (emailAddress == null || emailAddress == '') { return false;}
    
        // query case for cases that have emails that have been sent that match input
    
        String query = 'select COUNT() from case where SurveyGizmoSurveySent__c=true ' +
                       'and SurveyGizmoBatchdatetime__c >= :backthen ' +
                       'and RecordTypeID IN (\'012F0000000yBMoIAM\',\'012F0000000zXhv\')  ' +
                       ' and Contact.Email=\'' + emailAddress + '\' ';
                       
        System.debug(query);
    
        if (Database.countQuery(query) > 0) {
            return true;
        } else {
            return false;
        }
    
    }

    
    
    
    public static DateTime getSurveyLeadDate(String dtstring) {
        DateTime dt;
        Integer thisYear = Integer.valueOf(dtstring.substring(0,4));
        Integer thisMonth = Integer.valueOf(dtstring.substring(5,7));
        Integer thisDay = Integer.valueOf(dtstring.substring(8,10));
        Integer thisHour = Integer.valueOf(dtstring.substring(11,13));
        Integer thisMinute = Integer.valueOf(dtstring.substring(14,16));
        Integer thisSecond = Integer.valueOf(dtstring.substring(17,19));
        Integer thisOffSign = (Integer.valueOf(dtstring.substring(19,20)+'1')) * -1;
        Integer thisOffset = Integer.valueOf(dtstring.substring(20,22));
        thisOffset = thisOffset * thisOffSign;
        
        // Brings the date back to GMT/UTC (no offset)
        dt = Datetime.newInstanceGmt(Date.newInstance(thisYear, thisMonth, thisDay),Time.newInstance(thisHour, thisMinute, thisSecond, 0)); 
        dt = dt.addHours(thisOffset);
        
        return dt;
    
    }
    
    
    
     public static DateTime getSurveySendDate(String dtstring, String strTimezone) {
        if (strTimezone == null) {
            strTimezone = 'CST';
        }
        DateTime dt;
        Integer thisYear = Integer.valueOf(dtstring.substring(0,4));
        Integer thisMonth = Integer.valueOf(dtstring.substring(5,7));
        Integer thisDay = Integer.valueOf(dtstring.substring(8,10));
        Integer thisHour = Integer.valueOf(dtstring.substring(11,13));
        Integer thisMinute = Integer.valueOf(dtstring.substring(14,16));
        Integer thisSecond = Integer.valueOf(dtstring.substring(17,19));
        Integer thisOffSign = (Integer.valueOf(dtstring.substring(19,20)+'1')) * -1;
        Integer thisOffset = Integer.valueOf(dtstring.substring(20,22));
        thisOffset = thisOffset * thisOffSign;
        
        // Brings the date back to GMT/UTC (no offset)
        dt = Datetime.newInstanceGmt(Date.newInstance(thisYear, thisMonth, thisDay),Time.newInstance(thisHour, thisMinute, thisSecond, 0)); 
        dt = dt.addHours(thisOffset);
        // convert our new ISO 8601:2000 Date format to the requested Timezone to do the analysis
        String strConvertedDate = dt.format('yyyy-MM-dd HH:mm:ss',strTimezone);
        String strDayofWeek = dt.format('EEEE',strTimezone);
        String thisHourStr = strConvertedDate.substring(11,13);
        Integer thisHourInt = Integer.valueOf(thisHourStr);
        Integer thisMinuteInt = dt.minute();
        Integer batchHour = 0;
    
        Integer addOne = 0;
        DateTime dt2;
        Decimal thisHourM = Decimal.valueof(thisHourInt) + decimal.valueof(thisMinuteInt).divide(60,5);
        System.debug('this hourM comparing is ' + thisHourM);
        Time utcHour;
        Integer utcAddDay = 0;
        if (thisHourM >= 8 && thisHourM <= 16 && strDayofWeek != 'Saturday' && strDayofWeek != 'Sunday' ) {
            // within first block.
            if (thisHourM >= 8 && thisHourM <= 10) {
                batchHour = 14;  
            } else if (thisHourM > 10 && thisHourM <= 12) {
                batchHour = 16;
            }else if (thisHourM > 12 && thisHourM <= 14) {
                batchHour = 18;
            } else if (thisHourM > 14 && thisHourM <= 16) {
                batchHour = 20;
            }
        } else {
            
            if (thisHourM >= 0 && thisHourM < 8 && strDayofWeek != 'Saturday' && strDayofWeek != 'Sunday') {   // morning    grrn
                batchHour = 12;
            } else if (strDayOfWeek != 'Saturday' && strDayOfWeek != 'Sunday' && strDayOfWeek != 'Friday') {
                batchHour = 12;
                utcAddDay++;
            } else {
                batchHour = 12;
                addOne = 1;
            } 
        }
        Integer addhoursvar = batchHour - thisHourInt;
        
        String thisDateText = '';
        // determine date.
        if (addOne == 1) {
             // determine Monday's date, 
             dt2 = dt;
             while (thisDateText != 'Monday') {
                dt2 = dt2.addDays(1);
                utcAddDay++;
                thisDateText = dt2.format('EEEE',strTimezone);
             }
        }
        
        TimeZone tz = TimeZone.getTimeZone(strTimezone);
        Integer offsets = tz.getOffset(dt)/3600000;
    
        //strip minute, second, microsecond
        DateTime newdt2 = Datetime.newInstanceGmt(Date.newInstance(dt.yearGmt(), dt.monthGmt(),dt.dayGmt()),Time.newInstance(dt.hourGmt(),0,0,0));     
        
        newdt2 = newdt2.addHours(addhoursvar);
        newdt2 = newdt2.addDays(utcAddDay);
        
        System.debug('DT after creation: ' + String.valueofgmt(dt));
        System.debug('newDT2 after add hours and add days var: ' + String.valueofgmt(newdt2));
       
    
        String tzName = tz.getDisplayName();
        return newdt2;
   
    }
    
    
    public static String getDQRPriority(String FFScore) {
        if (FFScore == null)
            return null;
        if (FFScore == 'Legal')
            return 'Legal';
        
        Integer priority = null;
        try {
            priority = Integer.valueOf(FFScore);
        } catch (Exception e) {
            return null;
        }
        
        if (priority != null) {
            if (priority > 6) {
                return '3';
            } else if (priority >= 0 && priority <= 2) {
                return '1';
            } else if (priority >= 3 && priority <= 6) {
                return '2';
            } else if (priority > 6) {
                return '3';
            }
        }
        
        return null;
    }
    
    static testMethod void TestCustomerStageBefore() {
        System.debug('**** TestCustomerStageBefore ****');
        
        List<Dealer_Quotes_Request_Lead_Stage__c> testDQRLs = new List<Dealer_Quotes_Request_Lead_Stage__c>{
            new Dealer_Quotes_Request_Lead_Stage__c(DQRL_User_Defined_Text7__c='2013-11-21T20:28:50-05:00',DQRL_User_Defined_Text6__c='true',DQRL_lead_id__c = 'LD12', DQRL_interest_vehicle_vin__c = 'VIN01000010000101', DQRL_dealer_id__c = 'DLR12', DQRL_dealer_name__c = 'DLR12', DQRC_ContactID__c = 'CUST1234', DQRL_interest_vehicle_model__c = 'Nissan Versa'),
            new Dealer_Quotes_Request_Lead_Stage__c(DQRL_User_Defined_Text7__c='2013-11-21T20:28:50-05:00',DQRL_User_Defined_Text6__c='true',DQRL_lead_id__c = 'LD21', DQRL_interest_vehicle_vin__c = 'VIN01000010000101', DQRL_dealer_id__c = 'DLR12', DQRL_dealer_name__c = 'DLR12', DQRC_ContactID__c = 'CUST4321', DQRL_interest_vehicle_model__c = 'Infiniti JX')
        };
        
        List<Dealer_Quotes_Request_Lead_Stage__c> testDQRLIIs = new List<Dealer_Quotes_Request_Lead_Stage__c>{
            new Dealer_Quotes_Request_Lead_Stage__c(DQRL_User_Defined_Text7__c='2013-11-21T20:28:50-05:00',DQRL_User_Defined_Text6__c='true',DQRL_lead_id__c = 'LD12', DQRL_interest_vehicle_vin__c = 'VIN01000010000101', DQRL_dealer_id__c = 'DLR12', DQRL_dealer_name__c = 'DLR12', DQRC_ContactID__c = 'CUST1234'),
            new Dealer_Quotes_Request_Lead_Stage__c(),
            new Dealer_Quotes_Request_Lead_Stage__c(DQRC_ContactID__c = 'CUST4567')
        };
        
        List<Customer_Stage__c> testCusts = new List<Customer_Stage__c>{
            new Customer_Stage__c(Type__c = 'ACCOUNT', CUST_ZipCode__c = '12345', CUST_Zip4__c = '6789', 
                CUST_Work_Phone__c = '5555555555', CUST_WebsiteAcctFl__c = 'YES', CUST_UndeliverableEmail__c = 'NO', 
                CUST_Title_Prefix__c = 'Mr.', CUST_Suffix__c = 'Jr.', CUST_State__c = 'CO', CUST_SnailMailUndeliverable__c = 'YES', 
                CUST_ReservationFl__c = 'NO', CUST_OwnerFl__c = 'TRUE', CUST_NewFl__c = 'NO', CUST_Mobile_Phone_Line__c = '555-123-4567', 
                CUST_Middle__c = '', CUST_MaritzDoNotCallWork__c = '', CUST_MaritzDoNotCallMobile__c = 'NO', 
                CUST_MaritzDoNotCallHome__c = 'YES', CUST_LeadFl__c = 'YES', CUST_LastName__c = 'Johnson', CUST_Household_Key__c = '*******ABC', 
                CUST_Home_Phone__c = '555-098-7654', CUST_HandraiserFl__c = 'YES', CUST_FullName__c = 'Jack Johnson', 
                CUST_FirstName__c = 'Jack', CUST_EmailAddress__c = 'jjohnson@BuCunZaideJiaEmailDiZhi.coop', CUST_Do_Not_Email__c = 'NO', 
                CUST_DoNotMail__c = 'TRUE', CUST_DoNotContact__c = 'NO', CUST_ContactID__c = 'CUST1234', CUST_City__c = 'Denver', 
                CUST_Business__c = 'YES', CUST_Address2__c = '123 Main St', CUST_Address1__c = 'APT 302'),
            new Customer_Stage__c(Type__c = 'ACCOUNT', CUST_ContactID__c = 'CUST1234'),
            new Customer_Stage__c(Type__c = 'ACCOUNT', CUST_ContactID__c = 'CUST4321')
        };

        Test.startTest();
            insert testDQRLs[0];
//          Dealer_Quotes_Request_Lead_Stage__c d = [Select Successful__c From Dealer_Quotes_Request_Lead_Stage__c Where ID =: testDQRLs[0].ID];
//          System.assert(d.Successful__c != 'Y');
            
            insert testCusts;
//          System.assert([Select ID, Customer_ID__c, PersonContactID From Account Where Customer_ID__c like 'CUST%'].size() > 0);
            
//          d = [Select Successful__c From Dealer_Quotes_Request_Lead_Stage__c Where ID =: testDQRLs[0].ID];
//          System.assert(d.Successful__c == 'Y');
            
            insert testDQRLs[1];
//          d = [Select Successful__c From Dealer_Quotes_Request_Lead_Stage__c Where ID =: testDQRLs[1].ID];
//          System.assert(d.Successful__c == 'Y');
            
//          List<Dealer_Quotes_Request__c> dqrs = [Select ID, Lead_id__c, Case__c, Case__r.Subject From Dealer_Quotes_Request__c Where Lead_id__c like 'LD%'];
//          System.assert(dqrs.size() > 0);
//          for (Dealer_Quotes_Request__c dqr : dqrs)
//              System.assert(dqr.Case__c != null && dqr.Case__r.Subject != null);
            
            System.Debug('*** testDQRLIIs');
            insert testDQRLIIs;
        
        Datetime s = DQRClass.getSurveySendDate('2013-11-21T20:28:50-05:00','ET');
        s = DQRClass.getSurveyLeadDate('2013-11-21T20:28:50-05:00');
        String nu = null;
        String p = getDQRPriority(nu);
        String p1 = getDQRPriority('3');
        String p2 = getDQRPriority('10');
        String p3 = getDQRPriority('0');
        
         Test.stopTest();
       
            
        
        
    }
}