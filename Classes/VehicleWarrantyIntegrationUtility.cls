public class VehicleWarrantyIntegrationUtility{

    public static List<ServiceHistoryWrapHelper> claimscallout(Map<String, Id> mapVINs){
        List<ServiceHistoryWrapHelper> SRHs = new List<ServiceHistoryWrapHelper>();
        
        Integration_Settings__c settings = Integration_Settings__c.getValues(Label.Claims_Webservice);
        
                
        if(!settings.IsActive__c){
            return null;
        }
        
        Nna360ClaimMasterServiceSoap.WS_IG_ClaimMasterService_EXP_IG_ClaimMasterServiceHttpPort service = new Nna360ClaimMasterServiceSoap.WS_IG_ClaimMasterService_EXP_IG_ClaimMasterServiceHttpPort();
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
		/************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        service.endpoint_x = settings.Endpoint_URL__c;
        service.timeout_x = Integer.valueOf(settings.Timeout__c);
        Blob headerValue = Blob.valueOf(settings.Username__c + ':' + settings.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
		/************************************************************/
		
        List<String> listVins = new List<String> (mapVINs.keySet());
        
        Nna360ClaimMasterServiceSoap.VehicleClaim[] response;
        
        response = service.getVehicleClaimData(listVINs);
        
        System.Debug('*** Claim response ' + response);
        if (response == null || response.size() == 0)
            return null;
        
        List<String> dealerCodes = new List<String>();
        Map<String, Service_Repair_History__c> deduppedClaim = new Map<String, Service_Repair_History__c>();
        
        for (Nna360ClaimMasterServiceSoap.VehicleClaim vc : response) {
            //Vehicle_ID__c is required
            if (!mapVINs.containsKey(vc.Vin)) 
                continue;
            
            Nna360ClaimMasterServiceSoap.Claim[] claimData = vc.ClaimData;
            if (claimData == null) 
                continue;
            
            integer x = 0;
            for (Nna360ClaimMasterServiceSoap.Claim c : claimData) {
                Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] claimLines = c.WarrantyClaimLineData;
                //will not accept any claim without claimline
                if (claimLines == null || claimLines.size() == 0)
                    continue;
                
                //claim header 
                Service_Repair_History__c srh = new Service_Repair_History__c();
                srh.WS_SRH_Record_Type__c = 'Claim';
                
                srh.Dealer_Number__c = c.DealerNumber.Trim();
                if (srh.Dealer_Number__c.length() > 0)
                    dealerCodes.add(srh.Dealer_Number__c);
                srh.Work_Order_Number__c = c.WorkOrderNumber;
                srh.Vehicle_Identification_Number__c = vc.Vin;
                srh.Vehicle_ID__c = mapVINs.get(vc.Vin);
                srh.Transaction_Date__c = Text_Util.CCYYMMDDtoDateTime(c.TransactionDate);
                srh.Vehicle_Repair_Open_Date__c = Text_Util.CCYYMMDDtoDateTime(c.VehicleRepairOpenDate);
                srh.Vehicle_Repair_Close_Date__c = Text_Util.CCYYMMDDtoDateTime(c.VehicleRepairCloseDate);
                srh.Vehicle_Mileage_Number__c = Text_Util.DecimalValueOf(c.VehicleMileageNumber);
                srh.Claim_Customer_First_Name__c = c.ClaimCustomerFirstName;
                srh.Claim_Customer_Last_Name__c = c.ClaimCustomerLastName;
                srh.Claim_Customer_Street_Address1__c = c.ClaimCustomerStreetAddress1;
                srh.Claim_Customer_Street_Address2__c = c.ClaimCustomerStreetAddress2;
                srh.Claim_Customer_Zip__c = c.ClaimCustomerZip;
                srh.Claim_Customer_City__c = c.ClaimCustomerCity;
                srh.Claim_Customer_State_Province__c = c.ClaimCustomerStateProvince;
                srh.Claim_Customer_Phone__c = c.ClaimCustomerPhone;
                srh.Owner_Indicator__c = Text_Util.BooleanLookup(c.OwnerIndicator, false);
                
                //claim lines. combining header and lines in flattened model
                for (Nna360ClaimMasterServiceSoap.WarrantyClaimLine claimLine : claimLines) {
                    String businessID = c.DealerNumber + '_' + c.WorkOrderNumber + '_' + vc.Vin;
                    String key = businessID + '_' + claimLine.ClaimLineNumber;
                    if (!deduppedClaim.containsKey(key)) {
                        Service_Repair_History__c srhl = srh.clone();
                        deduppedClaim.put(key, srhl);
                        
                        srhl.Warranty_Claim_Line_Business_ID__c = key;
                        //srhl.Warranty_Claim_Line_Business_ID__c = c.WarrantyClaimBusinessId + '_' + claimLine.ClaimLineNumber;
                        //srhl.Dealer_Number__c = claimLine.DealerNumber;
                        //srhl.Work_Order_Number__c = claimLine.WorkOrderNumber;
                        //srhl.Vehicle_Identification_Number__c = vclaimLine.Vin;
                        srhl.Claim_Line_Number__c = claimLine.ClaimLineNumber;
                        srhl.Claim_Service_Tech_Number__c = claimLine.ClaimServiceTechNumber;
                        srhl.Complaint_Description__c = claimLine.ComplaintDescription;
                        srhl.Cause_Description__c = claimLine.CauseDescription;
                        srhl.Diagnosis_Description__c = claimLine.DiagnosisDescription;
                        srhl.Correction_Description__c = claimLine.CorrectionDescription;
                        srhl.Error_Description__c = claimLine.ErrorDescription;
                        srhl.Submitted_Amount__c = Text_Util.DecimalValueOf(claimLine.SubmittedAmount);
                        srhl.Paid_Amount__c = Text_Util.DecimalValueOf(claimLine.PaidAmount);
                        srhl.Claim_Type_Code__c = claimLine.ClaimTypeCode;
                        srhl.Claim_Coverage_Code__c = claimLine.ClaimCoverageCode;
                        srhl.Disposition_Code__c = claimLine.DispositionCode;
                        srhl.Claim_Deny_Reason_Code__c = claimLine.ClaimDeniedReasonCode;
                        srhl.Work_Order_Line_Status_Code__c = claimLine.WorkOrderLineStatusCode;
                        srhl.PNC_Code__c = claimLine.PNCCode;
                        srhl.PNC_Code_Description__c = claimLine.PNCDescription;
                        srhl.Primary_Failed_Part__c = claimLine.PrimaryFailedPart;
                        srhl.Vehicle_Claim_Authorization_Number__c = claimLine.VehicleClaimAuthorizationIndicator;
                        srhl.Claim_Approved_Coverage_Code__c = claimLine.ClaimApprovedCoverageCode;
                        srhl.Primary_Operation_Code__c = claimLine.PrimaryOperationCode;
                        //AAB 9/29/2014 - 3 new fields
                        srhl.Original_Purchase_Date__c = Text_Util.CCYYMMDDtoDateTime(claimLine.OriginalPurchaseDate);
                        srhl.Original_Purchase_Miles__c = claimLine.OriginalPurchaseMiles;
                        srhl.Primary_Failed_Part_Description__c = claimLine.PrimaryFailedPartDescription;
                        if(srhl.Complaint_Description__c != null && srhl.Complaint_Description__c != ''){
			                srhl.Complaint_Description_2__c = srhl.Complaint_Description__c;
			            }else if(srhl.PNC_Code_Description__c != null && srhl.PNC_Code_Description__c != ''){
			                srhl.Complaint_Description_2__c = srhl.PNC_Code_Description__c;
			            }else{
			               srhl.Complaint_Description_2__c = srhl.Primary_Operation_Code_Description__c;
			            }
                        
                        SRHs.add(new ServiceHistoryWrapHelper(++x, srhl));
                    } else {
                        Service_Repair_History__c srhl = deduppedClaim.get(key);
                        srhl.Claim_Service_Tech_Number__c = Text_Util.valueConcatenation(claimLine.ClaimServiceTechNumber, srhl.Claim_Service_Tech_Number__c);
                    }
                }
            }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (ServiceHistoryWrapHelper v : SRHs)
                v.servicehistory.Dealer_ID__c = dealerMap.get(v.servicehistory.Dealer_Number__c);
        }
        
        return SRHs;
    
    }
    
    
    
    
    
    // WARRANTY CALLOUT
    
     public static List<WarrantyInformationWrapper> warrantyCallout(Set<String> VINs, Map<Integer, Warranty_Information__c> wrtyInfoMap) {
        List<WarrantyInformationWrapper> WRTs = new List<WarrantyInformationWrapper>();
        WarrantyInformationWrapper wInfo;
        List<Vehicle__c> vehs  = new List<Vehicle__c>();
        Map<String, Warranty_Information_Order__c> wrtyInfoOrderMap = Warranty_Information_Order__c.getAll();
        Map<Integer, Warranty_Information__c> tempWrtyInfoMap = new Map<Integer, Warranty_Information__c>();
        
        Boolean isBranded = false;
        Boolean isWarrantyExcluded = false;
        Integration_Settings__c settings = Integration_Settings__c.getValues(Label.WarrantyService);
    	
    	if(Test.isRunningTest()){
        	settings = new Integration_Settings__c(Name=Label.Claims_Webservice, Endpoint_URL__c = 'https://b2bws.dev.na.nissan.biz', IsActive__c = true, Username__c = 'abc@xyz.com', Password__c = 'pwd123', Timeout__c = 30000 );
        	insert settings;
        }
        
    	if(!settings.IsActive__c){
    		return null;
    	}
        
        vehs = [Select Id, Warranty_Exclusion__c, Branded_Title__c from Vehicle__c where Name =: VINs];
        
        Nna360WarrantyMasterServiceSoap.WarrantyMasterService_IG_VehicleWarrantyCoverageServiceHttpPort service = new Nna360WarrantyMasterServiceSoap.WarrantyMasterService_IG_VehicleWarrantyCoverageServiceHttpPort();
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
        /************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        service.endpoint_x = settings.Endpoint_URL__c;
        service.timeout_x = Integer.valueOf(settings.Timeout__c);
        Blob headerValue = Blob.valueOf(settings.Username__c + ':' + settings.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        /************************************************************/
        List<String> listVins = new List<String> (VINs);
        System.Debug('*** Warranty listVins ' + listVins);
        
        Nna360WarrantyMasterServiceSoap.VehicleCoverage[] response;
        if (Test.isRunningTest())
            response = VehicleWarrantyIntegrationMockResponses.mockWarrantyResponse();
        else
            response = service.getVehicleCoverageData(listVins);
        System.Debug('*** Warranty response ' + response);
        if (response == null || response.size() == 0)
            return null;
        
        List<String> dealerCodes = new List<String>();
        integer i = 0;
        integer j = 0;
        integer orderSize = wrtyInfoOrderMap.size();
                
        for (Nna360WarrantyMasterServiceSoap.VehicleCoverage v : response) {
            if (!VINs.contains(v.Vin)) 
                continue;
            
            Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] warranties = v.ApplicableWarrantyData;
            Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] warrantyExclusions = v.WarrantyExclusionsData;
            Nna360WarrantyMasterServiceSoap.BrandedInfo[] brandeds = v.BrandedInfoData;
                        
            Map<String,Warranty_Information__c> latestWarrantyMap = new Map<String,Warranty_Information__c>();
            Warranty_Information__c latestWarranty;
            
            if (brandeds != null) {
                for (Nna360WarrantyMasterServiceSoap.BrandedInfo w : brandeds) {
                    Warranty_Information__c wrt = new Warranty_Information__c(
                        Warranty_Information_Business_ID__c = null, 
                        Warranty_Expiration_Miles__c = null, 
                        Warranty_Expiration_Date__c = null, 
                        Warranty_Exclusion_Name__c = null, 
                        Warranty_Exclusion_Code__c = null, 
                        Warranty_Description__c = null, 
                        WS_Warranty_Record_Type__c = null, 
                        Vehicle_Identification_Number__c = null, 
                        Vehicle_ID__c = null, 
                        Title_Number__c = null, 
                        State_Code__c = null, 
                        Source_Record_Date__c = null, 
                        Source_ID_Code__c = null, 
                        Record_Type_Code__c = null, 
                        Polk_Run_Date__c = null, 
                        Override_Expire_Date__c = null, 
                        Model_Year__c = null, 
                        Duplicate_Code__c = null, 
                        Coverage_Record_Type__c = null, 
                        Branded_Title_Indicator__c = false, 
                        Branded_Override_Indicator__c = false, 
                        Branded_Description__c = null, 
                        Branded_Code__c = null,
                        Source_Last_Update_Date__c = null);
                   
                    wrt.WS_Warranty_Record_Type__c = 'BrandedInfo';
                    wrt.Vehicle_Identification_Number__c = v.Vin;
                    
                    wrt.State_Code__c = w.StateCode;
                    wrt.Model_Year__c = w.ModelYear;
                    wrt.Source_Record_Date__c = Text_Util.CCYYMMDDtoDate(w.SourceRecordDate);
                    wrt.Record_Type_Code__c = w.RecordTypeCode;
                    wrt.Polk_Run_Date__c = Text_Util.CCYYMMDDtoDate(w.PolkRunDate);
                    wrt.Source_ID_Code__c = w.SourceIDCode;
                    wrt.Duplicate_Code__c = w.DuplicateCode;
                    wrt.Title_Number__c = w.TitleNumber;
                    wrt.Branded_Code__c = w.BrandedCode;
                    wrt.Branded_Description__c = w.BrandedDescription;
                    wrt.Override_Expire_Date__c = Text_Util.CCYYMMDDtoDate(w.OverrideExpirationDate);
                    wrt.Source_Last_Update_Date__c = Text_Util.CCYYMMDDHHMISStoDateTime(w.SourceLastUpdateDate);
                    
                    wrt.Warranty_Information_Business_ID__c = 'bi_' + v.Vin + '_' + w.StateCode + '_' + w.RecordTypeCode + '_' + w.SourceIDCode + '_' + w.BrandedDescription + '_' + w.DuplicateCode;
                    
                    wrtyInfoMap.put(++i, wrt);
                    isBranded = true;
                }
            }
            
            if (warrantyExclusions != null) {
                for (Nna360WarrantyMasterServiceSoap.WarrantyExclusions w : warrantyExclusions) {
                    Warranty_Information__c wrt = new Warranty_Information__c(
                        Warranty_Information_Business_ID__c = null, 
                        Warranty_Expiration_Miles__c = null, 
                        Warranty_Expiration_Date__c = null, 
                        Warranty_Exclusion_Name__c = null, 
                        Warranty_Exclusion_Code__c = null, 
                        Warranty_Description__c = null, 
                        WS_Warranty_Record_Type__c = null, 
                        Vehicle_Identification_Number__c = null, 
                        Vehicle_ID__c = null, 
                        Title_Number__c = null, 
                        State_Code__c = null, 
                        Source_Record_Date__c = null, 
                        Source_ID_Code__c = null, 
                        Record_Type_Code__c = null, 
                        Polk_Run_Date__c = null, 
                        Override_Expire_Date__c = null, 
                        Model_Year__c = null, 
                        Duplicate_Code__c = null, 
                        Coverage_Record_Type__c = null, 
                        Branded_Title_Indicator__c = false, 
                        Branded_Override_Indicator__c = false, 
                        Branded_Description__c = null, 
                        Branded_Code__c = null,
                        Source_Last_Update_Date__c = null);
                        
                    
                    wrtyInfoMap.put(++i, wrt);
                    
                    wrt.WS_Warranty_Record_Type__c = 'WarrantyExclusions';
                    wrt.Vehicle_Identification_Number__c = v.Vin;
                                        
                    wrt.Warranty_Exclusion_Name__c = w.WarrantyExclusionDescription;
                    wrt.Warranty_Exclusion_Code__c = w.WarrantyExclusionCode;
                    
                    wrt.Warranty_Information_Business_ID__c = 'we_' + v.Vin + '_' + w.WarrantyExclusionDescription;
                    isWarrantyExcluded = true;
                }
            }
            
            
            if (warranties != null) {
                for (Nna360WarrantyMasterServiceSoap.ApplicableWarranty w : warranties) {
                    Warranty_Information__c wrt = new Warranty_Information__c(
                        Warranty_Information_Business_ID__c = null, 
                        Warranty_Expiration_Miles__c = null, 
                        Warranty_Expiration_Date__c = null, 
                        Warranty_Exclusion_Name__c = null, 
                        Warranty_Exclusion_Code__c = null, 
                        Warranty_Description__c = null, 
                        WS_Warranty_Record_Type__c = null, 
                        Vehicle_Identification_Number__c = null, 
                        Vehicle_ID__c = null, 
                        Title_Number__c = null, 
                        State_Code__c = null, 
                        Source_Record_Date__c = null, 
                        Source_ID_Code__c = null, 
                        Record_Type_Code__c = null, 
                        Polk_Run_Date__c = null, 
                        Override_Expire_Date__c = null, 
                        Model_Year__c = null, 
                        Duplicate_Code__c = null, 
                        Coverage_Record_Type__c = null, 
                        Branded_Title_Indicator__c = false, 
                        Branded_Override_Indicator__c = false, 
                        Branded_Description__c = null, 
                        Branded_Code__c = null,
                        Source_Last_Update_Date__c = null);
                    wrt.WS_Warranty_Record_Type__c = 'ApplicableWarranty';
                    wrt.Vehicle_Identification_Number__c = v.Vin;                   
                    
                    wrt.Warranty_Description__c = w.WarrantyDescription;
                    System.debug('w.WarrantyDescription:::'+w.WarrantyDescription);
                    if(wrtyInfoOrderMap!= null && wrtyInfoOrderMap.containsKey(w.WarrantyDescription)){
                    	j = Integer.valueOf(wrtyInfoOrderMap.get(w.WarrantyDescription).Order__c) - 1;
                    }else{
                    	j = orderSize++; 
                    }
                    wrt.Warranty_Expiration_Date__c = Text_Util.CCYYMMDDtoDate(w.WarrantyExpirationDate);
                    wrt.Warranty_Expiration_Miles__c = Text_Util.DecimalValueOf(w.WarrantyExpirationMiles);
                    
                    wrt.Warranty_Information_Business_ID__c = 'aw_' + v.Vin + '_' + w.WarrantyDescription;    
                    
                    String key = v.Vin + w.WarrantyDescription;
                    latestWarranty = latestWarrantyMap.get(key);
                    if (latestWarranty != null && wrt.Warranty_Expiration_Date__c != null) {
                        if (latestWarranty.Warranty_Expiration_Date__c != null &&
                                wrt.Warranty_Expiration_Date__c.daysBetween(latestWarranty.Warranty_Expiration_Date__c) < 0) {
                            latestWarrantyMap.put(key, wrt);
                           
                            tempWrtyInfoMap.put(++j, wrt);
                        }
                    } else if (latestWarranty == null) {
                        latestWarrantyMap.put(key, wrt); 
                        System.debug('wrt::'+wrt);                        
                         tempWrtyInfoMap.put(++j, wrt);
                    }
                   
                }
               
            }
            
            
            
            
            //Name
            //Last_User_ID__c
            //Last_Update_Date__c
            //Coverage_Record_Type__c
            //Branded_Title_Indicator__c
            //Branded_Override_Indicator__c
        }
        
        System.debug('wrtyInfoMap:::'+wrtyInfoMap);
        System.debug('tempWrtyInfoMap:::'+tempWrtyInfoMap.size() +'---'+tempWrtyInfoMap);
        if(wrtyInfoMap.size() > 0){       	
                
	        for(Integer m=0; m < wrtyInfoMap.size(); m++){
	        	wInfo = new WarrantyInformationWrapper(m+1, wrtyInfoMap.get(m+1));
	            WRTs.add(wInfo);
	        }
        
        }
        
        if(tempWrtyInfoMap.size() > 0){       	
            integer x = wrtyInfoMap.size();
            List<Integer> tempList = new List<Integer>();
            tempList.addAll(tempWrtyInfoMap.keyset());
            tempList.sort();
            integer y = 1;
            for(Integer m : tempList){
            	wInfo = new WarrantyInformationWrapper(y+x, tempWrtyInfoMap.get(m));
	            WRTs.add(wInfo);
	            y++;
            }
        }
        
       
    	for(Vehicle__c veh : vehs){
    		veh.Branded_Title__c = isBranded;
    		veh.Warranty_Exclusion__c = isWarrantyExcluded;
    	}
        
        if(!vehs.isEmpty())	
       	 Database.update(vehs, false);
        
               
        System.Debug('*** Warranty WRTs ' + WRTs);
        return WRTS;
    }
    
    public static List<ServiceHistoryWrapHelper> repairOrderCallout(Set<String> VINs, List<ServiceHistoryWrapHelper> ROs) {
        Nna360RepairOrderServiceSoap.RepairOrderSoap service = new Nna360RepairOrderServiceSoap.RepairOrderSoap();		
		Nna360RepairOrderServiceSoap.ServiceAuthHeader header = new Nna360RepairOrderServiceSoap.ServiceAuthHeader();
		header.UserName = system.label.Nna360_RepairOrder_UserName;
		header.Password = system.label.Nna360_RepairOrder_Password;
		service.ServiceAuthHeader = header;
		
        Nna360RepairOrderServiceSoap.ArrayOfString listVins = new Nna360RepairOrderServiceSoap.ArrayOfString();
        listVins.string_x = new List<String> (VINs);
        
        Nna360RepairOrderServiceSoap.RepairOrderResponse response;
        response = service.GetRepairOrdersByVIN(listVins);
        
        System.Debug('*** Repair Order response ' + response);
        
        if (response.Status != 'Success')
        	return null;
        	
        List<String> dealerCodes = new List<String>();
        List<String> customerIds = new List<String>();
        Map<String, Integer> mapOpSeq = new Map<String, Integer>();
        
        Nna360RepairOrderServiceSoap.ArrayOfVehicle vehicleArray = response.Vehicles;
        Nna360RepairOrderServiceSoap.Vehicle[] vehicles = vehicleArray.Vehicle;        
       	if (vehicles == null || vehicles.size() == 0)
       		return null;
       	
        for (Nna360RepairOrderServiceSoap.Vehicle v : vehicles) {
            //Vehicle_ID__c is required
        	if (!VINs.contains(v.Vin)) 
        		continue;
        	
            Nna360RepairOrderServiceSoap.ArrayOfRepairOrder repairOrderArray = v.RepairOrders;
            Nna360RepairOrderServiceSoap.RepairOrder[] repairOrders = repairOrderArray.RepairOrder;
           	if (repairOrders == null || repairOrders.size() == 0)
           		continue;
            
            integer x = 0;
            for (Nna360RepairOrderServiceSoap.RepairOrder r : repairOrders) {
                Nna360RepairOrderServiceSoap.ArrayOfOpCode opCodeArray = r.Details;
                Nna360RepairOrderServiceSoap.OpCode[] opCodes = opCodeArray.OpCode;
                //will not accept any repairorder without opcode
                if (opCodes == null || opCodes.size() == 0)
                	continue;
                
                Service_Repair_History__c srh = new Service_Repair_History__c();
                srh.WS_SRH_Record_Type__c = 'Repair Order';
                
                //Dealer_Repair_Order_Number__c is required for upserting
                srh.Dealer_Repair_Order_Number__c = r.Number_x;                
                srh.Vehicle_Identification_Number__c = v.VIN;
                
                srh.Contact_Id__c = r.ContactId.Trim();
                if (srh.Contact_Id__c.length() > 0)
                	customerIds.add(srh.Contact_Id__c);
                srh.CDIID__c = r.CDIID;
                srh.Claim_Customer_First_Name__c = Text_Util.TruncateString(r.FirstName, 20);
                srh.Claim_Customer_Middle_Intial__c = r.MiddleInit;
                srh.Claim_Customer_Last_Name__c = r.LastName;
                srh.Claim_Customer_Street_Address1__c = r.Line1;
                srh.Claim_Customer_Street_Address2__c = r.Line2;
                srh.Claim_Customer_City__c = r.City;
                srh.Claim_Customer_State_Province__c = r.State;
                srh.Claim_Customer_Zip__c = r.Zip;
                srh.Claim_Customer_Phone__c = r.HomePhone;
                srh.Claim_Customer_Work_Phone__c = r.WorkPhone;
                srh.Claim_Customer_Email_Address__c = r.EmailAddress;
                srh.Domain_Id__c = r.DomainId;
                srh.Vehicle_Repair_Close_Date__c = Text_Util.MMDDCCYYtoDateTime(r.CloseDate);
                srh.Vehicle_Mileage_Number__c = Text_Util.DecimalValueOf(r.Mileage);
                srh.Parts_Amount__c = r.PartsAmount; 
                srh.Labor_Amount__c = r.LaborAmount;
                srh.Repair_Order_Total_Amount__c = r.TotalAmount;
                srh.Customer_Name_Type__c = r.CustNameType;
                srh.Total_Customer_Labor_Amount__c = r.CustLaborAmount;
                srh.Total_Customer_Parts_Amount__c = r.CustPartsAmount;
                srh.Total_Customer_Misc_Amount__c = r.CustMiscAmount;
                srh.Total_Warranty_Labor_Amount__c = r.WarrantyLaborAmount;
                srh.Total_Warranty_Parts_Amount__c = r.WarrantyPartsAmount;
                srh.Total_Warranty_Misc_Amount__c = r.WarrantyMiscAmount;
                srh.Total_Internal_Labor_Amount__c = r.InternalLaborAmount;
                srh.Total_Internal_Parts_Amount__c = r.InternalPartsAmount;
                srh.Total_Internal_Misc_Amount__c = r.InternalMiscAmount;
                srh.Dealer_Number__c = r.DealerCode.Trim();
                if (srh.Dealer_Number__c.length() > 0)
                	dealerCodes.add(srh.Dealer_Number__c);
               	
                for (Nna360RepairOrderServiceSoap.OpCode o : opCodes) {
                	Service_Repair_History__c srh1 = srh.clone();
                	
                	String partKey = r.DealerCode + '_' + r.Number_x + '_' + v.VIN + '_' + o.Code + '_' + o.PayType + '_';
                	
					Integer i = 1;
                	if (mapOpSeq.containsKey(partKey)) {
                		i = mapOpSeq.get(partKey);
                		i++;
                	}
                	mapOpSeq.put(partKey, i);
                	
                	srh1.Warranty_Claim_Line_Business_ID__c = partKey + String.valueOf(i);
                	
                  	srh1.Primary_Operation_Code__c = o.Code;                    
                    srh1.Service_Technician_Identifier__c = o.TechNum;
                    srh1.Pay_Type__c = o.PayType;
                    srh1.Primary_Operation_Code_Description__c = o.OpCodeDesc;
                    
                    Nna360RepairOrderServiceSoap.ArrayOfPart partArray = o.Parts;
                    if (partArray != null) {
						String[] parts = partArray.Part;
						if (parts != null) {
							for (String p : parts){
								srh1.Primary_Failed_Part__c = Text_Util.valueConcatenation(p, srh1.Primary_Failed_Part__c);
							}
						}
                    }
                    
                    if(srh1.Complaint_Description__c != null && srh1.Complaint_Description__c != ''){
			                srh1.Complaint_Description_2__c = srh1.Complaint_Description__c;
		            }else if(srh1.PNC_Code_Description__c != null && srh1.PNC_Code_Description__c != ''){
		                srh1.Complaint_Description_2__c = srh1.PNC_Code_Description__c;
		            }else{
		               srh1.Complaint_Description_2__c = srh1.Primary_Operation_Code_Description__c;
		            }
                    
	                ROs.add(new ServiceHistoryWrapHelper(++x, srh1));
                }
            }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (ServiceHistoryWrapHelper srh : ROs)
                srh.servicehistory.Dealer_ID__c = dealerMap.get(srh.servicehistory.Dealer_Number__c);
        }
        
        Map<String, Account> customerMap = Text_Util.getCustomerIDMap(customerIds);
        if (customerMap.size() > 0) {
            for (ServiceHistoryWrapHelper srh : ROs) {
            	if (customerMap.containsKey(srh.servicehistory.Contact_ID__c)) {
	            	Account a = customerMap.get(srh.servicehistory.Contact_ID__c);
	                srh.servicehistory.Customer__c = a.ID;
            	}
            }
        }
        
        System.Debug('*** Repair Order ROs ' + ROs);
        
        return ROs;
    }
    
     // Dealer Claims Callout
    public static List<Service_Repair_History__c> dealerClaimscallout(String dealerNumber){
        Integration_Settings__c settings = Integration_Settings__c.getValues(Label.Claims_Webservice);
        Map<String, ID> dealerMap = new Map<String, ID>();
        List<String> vins = new List<String>();
        
        if(Test.isRunningTest()){
        	settings = new Integration_Settings__c(Name=Label.Claims_Webservice, Endpoint_URL__c = 'https://b2bws.dev.na.nissan.biz', IsActive__c = true, Username__c = 'abc@xyz.com', Password__c = 'pwd123', Timeout__c = 30000 );
        	insert settings;
        }
        
        if(!settings.IsActive__c){
            return null;
        }
        List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
        
        Nna360ClaimMasterServiceSoap.WS_IG_ClaimMasterService_EXP_IG_ClaimMasterServiceHttpPort service = new Nna360ClaimMasterServiceSoap.WS_IG_ClaimMasterService_EXP_IG_ClaimMasterServiceHttpPort();
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
/************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        service.endpoint_x = settings.Endpoint_URL__c;
        service.timeout_x = Integer.valueOf(settings.Timeout__c);
        Blob headerValue = Blob.valueOf(settings.Username__c + ':' + settings.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
/************************************************************/
        
        Nna360ClaimMasterServiceSoap.DealerVehicleClaim response;
        
        if (Test.isRunningTest())
            response = VehicleWarrantyIntegrationMockResponses.mockDealerClaimResponse();
        else
            response = service.getDealerVehicleClaimData(dealerNumber);
        System.Debug('*** Claim response ' + response);
        if (response == null || response.DealerData == null || response.DealerData.size() == 0){
            return null;
        }
        
        List<String> dealerCodes = new List<String>();
		Service_Repair_History__c sHistory;
		        
        if(response.DealerNumber == dealerNumber){
        	dealerMap = Text_Util.getDealderIDMap(new List<String>{dealerNumber});
      
        	if(response.DealerData.size() > 0){
        		for(Nna360ClaimMasterServiceSoap.Dealer dealer : response.DealerData){
        			
        			if(dealer.DealerClaimData.size() > 0){
        				
        			 for(Nna360ClaimMasterServiceSoap.DealerClaim dealerClaim : dealer.DealerClaimData){
        				sHistory = new Service_Repair_History__c(Warranty_Claim_Line_Business_ID__c = dealerClaim.WarrantyClaimBusinessId, Work_Order_Number__c = dealerClaim.WorkOrderNumber,
        							  Vehicle_Identification_Number__c = dealerClaim.Vin, Transaction_Date__c = Text_Util.CCYYMMDDtoDateTime(dealerClaim.TransactionDate), Vehicle_Repair_Open_Date__c = Text_Util.CCYYMMDDtoDateTime(dealerClaim.VehicleRepairOpenDate),
        							  Vehicle_Repair_Close_Date__c = Text_Util.CCYYMMDDtoDateTime(dealerClaim.VehicleRepairCloseDate),  Vehicle_Mileage_Number__c = Text_Util.DecimalValueOf(dealerClaim.VehicleMileageNumber),
        							  Claim_Customer_First_Name__c = dealerClaim.ClaimCustomerFirstName, Claim_Customer_Last_Name__c = dealerClaim.ClaimCustomerLastName, Claim_Customer_Phone__c = dealerClaim.ClaimCustomerPhone,
        							  Claim_Customer_Street_Address1__c = dealerClaim.ClaimCustomerStreetAddress1, Claim_Customer_Street_Address2__c = dealerClaim.ClaimCustomerStreetAddress2, Dealer_Number__c = dealerNumber,
        							  Claim_Customer_Zip__c = dealerClaim.ClaimCustomerZip, Claim_Customer_City__c = dealerClaim.ClaimCustomerCity,  Claim_Customer_State_Province__c = dealerClaim.ClaimCustomerStateProvince,
        							  Dealer_ID__c = dealerMap != null ? dealerMap.get(dealerNumber) : null, Owner_Indicator__c = Text_Util.BooleanLookup(dealerClaim.OwnerIndicator, false));
        				vins.add(dealerClaim.Vin);
        			
        				if(dealerClaim.DealerWarrantyClaimLineData != null && dealerClaim.DealerWarrantyClaimLineData.size() > 0)
        					for(Nna360ClaimMasterServiceSoap.DealerWarrantyClaimLine wrtyLine : dealerClaim.DealerWarrantyClaimLineData){
        					 Service_Repair_History__c srhl = sHistory.clone();
        					 srhl.Warranty_Claim_Line_Business_ID__c = wrtyLine.WarrantyClaimLineBusinessId;
        					 srhl.Claim_Line_Number__c = wrtyLine.ClaimLineNumber;
        					 srhl.Claim_Type_Code__c = wrtyLine.ClaimTypeCode;
        					 srhl.Work_Order_Line_Status_Code__c = wrtyLine.WorkOrderLineStatusCode;
	        				 srhl.PNC_Code__c = wrtyLine.PNCCode;
	                         srhl.PNC_Code_Description__c = wrtyLine.PNCDescription;
	                         srhl.Primary_Failed_Part__c = wrtyLine.PrimaryFailedPart;
	                         srhl.Vehicle_Claim_Authorization_Number__c = wrtyLine.VehicleClaimAuthorizationIndicator;
	                         srhl.Claim_Approved_Coverage_Code__c = wrtyLine.ClaimApprovedCoverageCode;
	                         srhl.Primary_Operation_Code__c = wrtyLine.PrimaryOperationCode; 
	                         srhl.Complaint_Description__c = wrtyLine.ComplaintDescription;
                     		 srhl.Cause_Description__c = wrtyLine.CauseDescription;
                     		 srhl.Error_Description__c = wrtyLine.ErrorDescription;
                       		 srhl.Diagnosis_Description__c = wrtyLine.DiagnosisDescription;
                       		 srhl.Submitted_Amount__c = Text_Util.DecimalValueOf(wrtyLine.SubmittedAmount);
                       		 srhl.Paid_Amount__c = Text_Util.DecimalValueOf(wrtyLine.PaidAmount);
                       		 srhl.Correction_Description__c = wrtyLine.CorrectionDescription;
                       		 srhl.Original_Purchase_Date__c = Text_Util.CCYYMMDDtoDateTime(wrtyLine.OriginalPurchaseDate);
	                         srhl.Original_Purchase_Miles__c = wrtyLine.OriginalPurchaseMiles;
	                         srhl.Primary_Failed_Part_Description__c = wrtyLine.PrimaryFailedPartDescription;
	                         srhl.Claim_Service_Tech_Number__c = wrtyLine.ClaimServiceTechNumber;
	                         srhl.Claim_Coverage_Code__c = wrtyLine.ClaimCoverageCode;
	                         srhl.Disposition_Code__c = wrtyLine.DispositionCode;
	        			
	        			     SRHs.add(srhl);	
        					}
	        			}	
        			}			  
        		}
        	}
        	
        	  Map<String, ID> vinIdMap = Text_Util.getVehicleIDMap(vins);
		      if (vinIdMap.size() > 0) {
		            for (Service_Repair_History__c v : SRHs)
		                v.Vehicle_ID__c = dealerMap.get(v.Vehicle_Identification_Number__c);
		      }
        }
        
        System.Debug('*** Service Histories ' + SRHs);
        return SRHs;
       
    
    }
    
    
}