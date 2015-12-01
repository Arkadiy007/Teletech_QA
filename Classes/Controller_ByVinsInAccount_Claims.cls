/**********************************************************************
Name: Controller_ByVinsInAccount_Claims
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Call claim web service, and updates Service_Repair_History__c info by given a set of VINs
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu     12/23/2011 Created
2.0 - Aaron Bessey      09/29/2014 Modified to accept 3 new params
3.0 - Vivek Batham		03/25/2014 Modified for changed webservice
***********************************************************************/
public class Controller_ByVinsInAccount_Claims {
    public static void callout(Map<String, ID> mapVINs, List<Service_Repair_History__c> SRHs) {
    	
    	Integration_Settings__c settings = Integration_Settings__c.getValues(Label.Claims_Webservice);
    	
    	if(Test.isRunningTest()){
        	settings = new Integration_Settings__c(Name=Label.Claims_Webservice, Endpoint_URL__c = 'https://b2bws.dev.na.nissan.biz', IsActive__c = true, Username__c = 'abc@xyz.com', Password__c = 'pwd123', Timeout__c = 30000 );
        	insert settings;
        }
        
    	if(!settings.IsActive__c){
    		return;
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
        
        if (Test.isRunningTest())
            response = mockClaimResponse();
        else
            response = service.getVehicleClaimData(listVINs);
        System.Debug('*** Claim response ' + response);
        if (response == null || response.size() == 0)
            return;
        
        List<String> dealerCodes = new List<String>();
        Map<String, Service_Repair_History__c> deduppedClaim = new Map<String, Service_Repair_History__c>();
        
        for (Nna360ClaimMasterServiceSoap.VehicleClaim vc : response) {
            //Vehicle_ID__c is required
            if (!mapVINs.containsKey(vc.Vin)) 
                continue;
            
            Nna360ClaimMasterServiceSoap.Claim[] claimData = vc.ClaimData;
            if (claimData == null) 
                continue;
           
           System.debug('Size of resp::'+claimData.size()); 
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
                    System.debug('key::'+key);
                    if (!deduppedClaim.containsKey(key)) {
                        Service_Repair_History__c srhl = srh.clone();
                        SRHs.add(srhl);
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
                    } else {
                        Service_Repair_History__c srhl = deduppedClaim.get(key);
                        srhl.Claim_Service_Tech_Number__c = Text_Util.valueConcatenation(claimLine.ClaimServiceTechNumber, srhl.Claim_Service_Tech_Number__c);
                    }
                }
            }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (Service_Repair_History__c v : SRHs)
                v.Dealer_ID__c = dealerMap.get(v.Dealer_Number__c);
        }
        
        System.Debug('*** Claim SRHs ' + SRHs);
    }
    
    public static void dmlOperations(List<Service_Repair_History__c> SRHs) {
        if (SRHs.size() > 0)
            upsert SRHs Warranty_Claim_Line_Business_ID__c;
    }
    
    /**
        test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
        ByVinsInAccount_TestUtil.TestData();
        Test.startTest();
        
        Map<String, ID> mapVINs = new Map<String, ID>();
        List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
        for (Vehicle__c v : ByVinsInAccount_TestUtil.testVehicles)
            mapVINs.put(v.Vehicle_identification_Number__c, v.Id);
        
        callout(mapVINs, SRHs);
        dmlOperations(SRHs);
        
        Test.stopTest();
    }
    
    /**
        create mock response for Controller_ByVinsInAccount_Claims
    */
    public static Nna360ClaimMasterServiceSoap.VehicleClaim[] mockClaimResponse() {
        Nna360ClaimMasterServiceSoap.VehicleClaim[] response = new Nna360ClaimMasterServiceSoap.VehicleClaim[] {
            new Nna360ClaimMasterServiceSoap.VehicleClaim(),
            new Nna360ClaimMasterServiceSoap.VehicleClaim(),
            new Nna360ClaimMasterServiceSoap.VehicleClaim(),
            new Nna360ClaimMasterServiceSoap.VehicleClaim()
        };
        
        //ClaimData is null
        response[0].Vin = 'VIN01000010000100';
        //extisting claim
        response[1].Vin = 'VIN01000010000101';
        response[1].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
            new Nna360ClaimMasterServiceSoap.Claim()
        };
        response[1].ClaimData[0].Vin = response[1].Vin;
        response[1].ClaimData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
        response[1].ClaimData[0].WorkOrderNumber = 'WO0@@';
        response[1].ClaimData[0].TransactionDate = '2012-12-21 00:00:00.0';
        response[1].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
            new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
        };
        response[1].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
        
        //new claim data
        response[2].Vin = 'VIN01000010000102';
        response[2].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
            new Nna360ClaimMasterServiceSoap.Claim()
        };
        response[2].ClaimData[0].Vin = response[2].Vin;
        response[2].ClaimData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
        response[2].ClaimData[0].WorkOrderNumber = 'WO0@#';
        response[2].ClaimData[0].VehicleRepairCloseDate = '0001-01-01 00:00:00.0';
        response[2].ClaimData[0].VehicleMileageNumber = '10000';
        response[2].ClaimData[0].OwnerIndicator = 'Y';
        response[2].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
            new Nna360ClaimMasterServiceSoap.WarrantyClaimLine(),
            new Nna360ClaimMasterServiceSoap.WarrantyClaimLine(),
            new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
        };
        response[2].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
        response[2].ClaimData[0].WarrantyClaimLineData[0].SubmittedAmount = '100.00';
        response[2].ClaimData[0].WarrantyClaimLineData[0].PaidAmount = '100.00';
        //AAB 09/29/2014 - adding test claim line data
        response[2].ClaimData[0].WarrantyClaimLineData[0].OriginalPurchaseDate = '2013-08-23 00:00:00.0';
        response[2].ClaimData[0].WarrantyClaimLineData[0].OriginalPurchaseMiles = '61854';
        response[2].ClaimData[0].WarrantyClaimLineData[0].PrimaryFailedPartDescription = 'SEAL-OILDRIVE PINION';
        response[2].ClaimData[0].WarrantyClaimLineData[1].ClaimLineNumber = '02';
        response[2].ClaimData[0].WarrantyClaimLineData[1].ClaimServiceTechNumber = 'C';
        response[2].ClaimData[0].WarrantyClaimLineData[1].PrimaryFailedPart = 'P';
        response[2].ClaimData[0].WarrantyClaimLineData[2].ClaimLineNumber = '02';
        response[2].ClaimData[0].WarrantyClaimLineData[2].ClaimServiceTechNumber = 'D';
        response[2].ClaimData[0].WarrantyClaimLineData[2].PrimaryFailedPart = 'P';
        
        //ClaimLine is null
        response[3].Vin = 'VIN01000010000103';
        response[3].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
            new Nna360ClaimMasterServiceSoap.Claim()
        };
        
        return response;
    }
}