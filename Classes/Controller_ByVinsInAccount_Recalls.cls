/**********************************************************************
Name: Controller_ByVinsInAccount_Recalls
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Call recall web service, and updates Master_Recall_Campaign__c and Vehicle_Recall__c info and relation by given a set of VINs
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu     12/23/2011 Created
***********************************************************************/
public class Controller_ByVinsInAccount_Recalls {
    public static void callout(Map<String, ID> mapVINs, List<Vehicle_Recall__c> VRs) {
        Nna360RecallServiceSoap.RecallMasterService_IG_RecallMasterServiceHttpPort service = new Nna360RecallServiceSoap.RecallMasterService_IG_RecallMasterServiceHttpPort();
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
/************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        Blob headerValue = Blob.valueOf(system.label.Service_Proxy_UserName + ':' + system.label.Service_Proxy_Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
/************************************************************/
        List<String> listVins = new List<String> (mapVINs.keySet());
        
        System.Debug('*** Recall listVins ' + listVins);
        Nna360RecallServiceSoap.VehicleRecall[] response;
        
        if (Test.isRunningTest())
            response = mockRecallResponse();
        else
            response = service.getVehicleRecallData(listVins);
        System.Debug('*** Recall response ' + response);
        if (response == null || response.size() == 0)
            return;
        
        List<String> dealerCodes = new List<String>();
        
        for (Nna360RecallServiceSoap.VehicleRecall v : response) {
            Nna360RecallServiceSoap.Recall[] recalls = v.RecallData;
            if (recalls == null)
                continue;
            
            for (Nna360RecallServiceSoap.Recall r : recalls) {
                Vehicle_Recall__c vr = new Vehicle_Recall__c();
                
                vr.Effective_Date__c = Text_Util.CCYYMMDDtoDate(r.EffectiveDate);
                if (vr.Effective_Date__c == NULL || vr.Effective_Date__c > System.today())
                    continue;
                
                vr.Vehicle_Identification_Number__c = r.Vin;
                if (r.Vin.length() > 0)
                    vr.Vehicle__c = mapVINs.get(r.Vin);
                
                //vr.Vehicle__r.Channel_Code__c = r.ChannelCode;
                vr.Source_Create_Date__c = Text_Util.CCYYMMDDtoDateTime(r.SourceCreateDate);
                vr.Source_Update_Date__c = Text_Util.CCYYMMDDtoDateTime(r.SourceUpdateDate);
                vr.Date_Mailed__c = Text_Util.CCYYMMDDtoDate(r.DateMailed);
                vr.Claim_Indicator__c = r.ClaimIndicator;
                //vr.Vehicle__r.NML_Number__c = r.NMCModelCode;
                vr.Distributor_Code__c = r.DistributorCode;
                vr.Recall_Primary_Description__c = r.RecallPrimaryDescription;
                
                String str = r.RecallPrimaryDescription.trim();
                str = str.substring(str.trim().lastIndexOf(' ') + 1, str.trim().length());
                if (str.startsWith('NTB') || str.startsWith('ITB'))
                    vr.TSB_Number__c = str;
                
                vr.Recall_Secondary_Description__c = r.RecallSecondaryDescription;
                vr.Recall_Type_Code__c = r.RecallTypeCode;
                vr.Local_Vendor_Code__c = r.LocalVendorCode;
                vr.Extended_Warranty_Indicator__c = Text_Util.BooleanLookup(r.ExtendedWarrantyIndicator, false);
                vr.Special_Claim_Requirement_Validation_Ind__c = Text_Util.BooleanLookup(r.SpecialClaimRequirementValidationIndicator, false);
                vr.Component_Code__c = r.ComponentCode;
                vr.Recall_Status__c = r.RecallStatus;
                vr.Recall_Identifier__c = r.RecallIdentifier;
                
                vr.Dealer_Submitted_Claim_Code__c = r.DealerSubmittedClaimIndicator.Trim();
                if (vr.Dealer_Submitted_Claim_Code__c.length() > 0)
                    dealerCodes.add(vr.Dealer_Submitted_Claim_Code__c);
                
                vr.Vehicle_Recall_Business_ID__c = r.RecallIdentifier + '_' + r.Vin;
                VRs.add(vr);
                //Name
                //Date_Completed__c
            }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (Vehicle_Recall__c vr : VRs)
                vr.Dealer__c = dealerMap.get(vr.Dealer_Submitted_Claim_Code__c);
        }
        
        System.Debug('*** Recall VRs ' + VRs.size() + ', ' + VRs);
    }
        
    public static void dmlOperations(List<Vehicle_Recall__c> VRs) {
        Map<String, Master_Recall_Campaign__c> vrmsToUpsert = new Map<String, Master_Recall_Campaign__c>();
        Set<String> VRIDs = new Set<String>();
        for (Vehicle_Recall__c vr : VRs) {
            VRIDs.add(vr.Recall_Identifier__c);

            Master_Recall_Campaign__c vrm = new Master_Recall_Campaign__c();            
            vrm.Vehicle_Recall_Business_ID__c = vr.Recall_Identifier__c;
            vrm.Source_Create_Date__c = vr.Source_Create_Date__c; 
            vrm.Source_Update_Date__c = vr.Source_Update_Date__c;
            vrm.Date_Mailed__c = vr.Date_Mailed__c;
            vrm.Claim_Indicator__c = vr.Claim_Indicator__c;
            vrm.Dealer_Submitted_Claim_Code__c = vr.Dealer_Submitted_Claim_Code__c;
            vrm.Distributor_Code__c = vr.Distributor_Code__c;
            vrm.Recall_Primary_Description__c = vr.Recall_Primary_Description__c;
            vrm.Recall_Secondary_Description__c = vr.Recall_Secondary_Description__c;
            vrm.Effective_Date__c = vr.Effective_Date__c;
            vrm.Recall_Type_Code__c = vr.Recall_Type_Code__c;
            vrm.Local_Vendor_Code__c = vr.Local_Vendor_Code__c;
            vrm.Extended_Warranty_Indicator__c = vr.Extended_Warranty_Indicator__c; 
            vrm.Special_Claim_Requirement_Validation_Ind__c = vr.Special_Claim_Requirement_Validation_Ind__c;
            vrm.Component_Code__c = vr.Component_Code__c;
            vrm.Recall_Status__c = vr.Recall_Status__c; 
            vrm.Recall_Identifier__c = vr.Recall_Identifier__c;
            vrm.Name = vr.Recall_Identifier__c;
            vrm.Dealer__c = vr.Dealer__c;
            vrm.OwnerId = System.Label.Batch_Record_Owner;
            
            vrmsToUpsert.put(vr.Recall_Identifier__c, vrm);
        }
        
        try {
            if (vrmsToUpsert.size() > 0)
                upsert vrmsToUpsert.values() Vehicle_Recall_Business_ID__c;
        } catch (DMLException e) {
            System.Debug('*** There is DMLException *** ' + e.getMessage());
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                System.Debug('*** There is DUPLICATE_VALUE *** ' + vrmsToUpsert);
                
                try {
                    upsert vrmsToUpsert.values() Vehicle_Recall_Business_ID__c;
                } catch (DMLException ex) {
                    System.Debug('*** There is still DUPLICATE_VALUE *** ');
                }
            }
        } 
        
        List<Master_Recall_Campaign__c> sfMasters = [Select ID, Recall_Identifier__c From Master_Recall_Campaign__c WHERE Recall_Identifier__c in: VRIDs];
        Map<String, Master_Recall_Campaign__c> existingVRMs = new Map<String, Master_Recall_Campaign__c>();
        for (Master_Recall_Campaign__c vrm : sfMasters)
            existingVRMs.put(vrm.Recall_Identifier__c, vrm);
        
        List<Vehicle_Recall__c> vrsToUpsert = new List<Vehicle_Recall__c>();
        for (Vehicle_Recall__c vr : VRs) {
            if (existingVRMs.containsKey(vr.Recall_Identifier__c)) {
                vr.Master_Recall_Campaign__c = existingVRMs.get(vr.Recall_Identifier__c).ID;
                vrsToUpsert.add(vr);
            } else {
                System.Debug('*** No Master *** ' + vr.Recall_Identifier__c + ' Recall missing ' + vr);
            }
        }
        
        if (vrsToUpsert.size() > 0) 
            upsert vrsToUpsert Vehicle_Recall_Business_ID__c;
    }
        
    /**
        test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
        ByVinsInAccount_TestUtil.TestData();
        Test.startTest();
        
        Map<String, ID> mapVINs = new Map<String, ID>();
        List<Vehicle_Recall__c> VRs = new List<Vehicle_Recall__c>();
        for (Vehicle__c v : ByVinsInAccount_TestUtil.testVehicles)
            mapVINs.put(v.Vehicle_identification_Number__c, v.Id);
        
        callout(mapVINs, VRs);
        dmlOperations(VRs);
        
        Test.stopTest();
    }

    /**
        create mock response for Controller_ByVinsInAccount_Recalls
    */
    public static Nna360RecallServiceSoap.VehicleRecall[] mockRecallResponse() {
        Nna360RecallServiceSoap.VehicleRecall[] response = new Nna360RecallServiceSoap.VehicleRecall[] {
            new Nna360RecallServiceSoap.VehicleRecall(),
            new Nna360RecallServiceSoap.VehicleRecall(),
            new Nna360RecallServiceSoap.VehicleRecall(),
            new Nna360RecallServiceSoap.VehicleRecall()
        };
        
        //RecallData is null
        response[0].Vin = 'VIN01000010000100';
        
        //Recall and Master Data already exist.
        response[1].Vin = 'VIN01000010000101';
        response[1].RecallData = new Nna360RecallServiceSoap.Recall[] {
            new Nna360RecallServiceSoap.Recall()
        };
        response[1].RecallData[0].Vin = response[1].Vin;
        response[1].RecallData[0].RecallIdentifier = 'RC0!!';
        response[1].RecallData[0].DealerSubmittedClaimIndicator = ByVinsInAccount_TestUtil.DEALER_CODE;
        response[1].RecallData[0].RecallPrimaryDescription = 'ITB10-YYY';
        
        //new Recall and Master Data
        response[2].Vin = 'VIN01000010000102';
        response[2].RecallData = new Nna360RecallServiceSoap.Recall[] {
            new Nna360RecallServiceSoap.Recall()
        };
        response[2].RecallData[0].Vin = response[2].Vin;
        response[2].RecallData[0].RecallIdentifier = 'XX0X1';
        response[2].RecallData[0].EffectiveDate = '2002-12-21';
        response[2].RecallData[0].DealerSubmittedClaimIndicator = ByVinsInAccount_TestUtil.DEALER_CODE;
        response[2].RecallData[0].RecallPrimaryDescription = 'NTB10-YYY';
        response[2].RecallData[0].ExtendedWarrantyIndicator = '0';
        
        //new Recall and Master Data
        response[3].Vin = 'VIN01000010000103';
        response[3].RecallData = new Nna360RecallServiceSoap.Recall[] {
            new Nna360RecallServiceSoap.Recall()
        };
        response[3].RecallData[0].Vin = response[2].Vin;
        response[3].RecallData[0].RecallIdentifier = 'XX0X2';
        response[3].RecallData[0].EffectiveDate = '0001-01-01';
        response[3].RecallData[0].DealerSubmittedClaimIndicator = ByVinsInAccount_TestUtil.DEALER_CODE;
        response[3].RecallData[0].RecallPrimaryDescription = 'NTB10-YYY';
        response[3].RecallData[0].ExtendedWarrantyIndicator = '0';
        return response;
    }
}