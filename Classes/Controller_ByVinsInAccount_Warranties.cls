/**********************************************************************
Name: Controller_ByVinsInAccount_Claims
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Call vehicle coverage web service, and updates Warranty_Information__c info by given a set of VINs
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu     12/23/2011 Created
***********************************************************************/
public class Controller_ByVinsInAccount_Warranties {
    public static void callout(Map<String, ID> mapVINs, List<Warranty_Information__c> WRTs) {
        Nna360WarrantyMasterServiceSoap.WarrantyMasterService_IG_VehicleWarrantyCoverageServiceHttpPort service = new Nna360WarrantyMasterServiceSoap.WarrantyMasterService_IG_VehicleWarrantyCoverageServiceHttpPort();
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
/************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        Blob headerValue = Blob.valueOf(system.label.Service_Proxy_UserName + ':' + system.label.Service_Proxy_Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
/************************************************************/
        List<String> listVins = new List<String> (mapVINs.keySet());
        System.Debug('*** Warranty listVins ' + listVins);
        Nna360WarrantyMasterServiceSoap.VehicleCoverage[] response;
        if (Test.isRunningTest())
            response = mockWarrantyResponse();
        else
            response = service.getVehicleCoverageData(listVins);
        System.Debug('*** Warranty response ' + response);
        if (response == null || response.size() == 0)
            return;
        
        List<String> dealerCodes = new List<String>();
        
        for (Nna360WarrantyMasterServiceSoap.VehicleCoverage v : response) {
            if (!mapVINs.containsKey(v.Vin)) 
                continue;
            
            Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] warranties = v.ApplicableWarrantyData;
            Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] warrantyExclusions = v.WarrantyExclusionsData;
            Nna360WarrantyMasterServiceSoap.BrandedInfo[] brandeds = v.BrandedInfoData;
            
            ID vehicleID = mapVINs.get(v.Vin);
            Map<String,Warranty_Information__c> latestWarrantyMap = new Map<String,Warranty_Information__c>();
            Warranty_Information__c latestWarranty;
            
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
                    wrt.Vehicle_ID__c = vehicleID;
                    
                    wrt.Warranty_Description__c = w.WarrantyDescription;
                    wrt.Warranty_Expiration_Date__c = Text_Util.CCYYMMDDtoDate(w.WarrantyExpirationDate);
                    wrt.Warranty_Expiration_Miles__c = Text_Util.DecimalValueOf(w.WarrantyExpirationMiles);
                    
                    wrt.Warranty_Information_Business_ID__c = 'aw_' + v.Vin + '_' + w.WarrantyDescription;    
                    
                    String key = v.Vin + w.WarrantyDescription;
                    latestWarranty = latestWarrantyMap.get(key);
                    if (latestWarranty != null && wrt.Warranty_Expiration_Date__c != null) {
                        if (latestWarranty.Warranty_Expiration_Date__c != null &&
                                wrt.Warranty_Expiration_Date__c.daysBetween(latestWarranty.Warranty_Expiration_Date__c) < 0) {
                            latestWarrantyMap.put(key, wrt);
                        }
                    } else if (latestWarranty == null) {
                        latestWarrantyMap.put(key, wrt);
                    }
                }
                
                WRTs.addAll(latestWarrantyMap.values());
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
                    WRTs.add(wrt);
                    wrt.WS_Warranty_Record_Type__c = 'WarrantyExclusions';
                    wrt.Vehicle_Identification_Number__c = v.Vin;
                    wrt.Vehicle_ID__c = vehicleID;
                    
                    wrt.Warranty_Exclusion_Name__c = w.WarrantyExclusionDescription;
                    wrt.Warranty_Exclusion_Code__c = w.WarrantyExclusionCode;
                    
                    wrt.Warranty_Information_Business_ID__c = 'we_' + v.Vin + '_' + w.WarrantyExclusionDescription;
                }
            }
            
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
                    WRTs.add(wrt);
                    wrt.WS_Warranty_Record_Type__c = 'BrandedInfo';
                    wrt.Vehicle_Identification_Number__c = v.Vin;
                    wrt.Vehicle_ID__c = vehicleID;
                    
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
                }
            }
            
            //Name
            //Last_User_ID__c
            //Last_Update_Date__c
            //Coverage_Record_Type__c
            //Branded_Title_Indicator__c
            //Branded_Override_Indicator__c
        }
        
        System.Debug('*** Warranty WRTs ' + WRTs);
    }
    
    public static void dmlOperations(List<Warranty_Information__c> WRTs) {
        if (WRTs.size() > 0)
            upsert WRTs Warranty_Information_Business_ID__c;
    }
        
    /**
        test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
        ByVinsInAccount_TestUtil.TestData();
        Test.startTest();
        
        Map<String, ID> mapVINs = new Map<String, ID>();
        List<Warranty_Information__c> WRTs = new List<Warranty_Information__c>();
        for (Vehicle__c v : ByVinsInAccount_TestUtil.testVehicles)
            mapVINs.put(v.Vehicle_identification_Number__c, v.Id);
        
        callout(mapVINs, WRTs);
        dmlOperations(WRTs);
        
        Test.stopTest();
    }
    
    /**
        create mock response for Controller_ByVinsInAccount_Warranties
    */
    public static Nna360WarrantyMasterServiceSoap.VehicleCoverage[] mockWarrantyResponse() {
        Nna360WarrantyMasterServiceSoap.VehicleCoverage[] response = new Nna360WarrantyMasterServiceSoap.VehicleCoverage[] {
            new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
            new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
            new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
            new Nna360WarrantyMasterServiceSoap.VehicleCoverage()
        };
        
        //VehicleCoverageData is null
        response[0].Vin = 'VIN01000010000100';
        
        //new warrranty data
        response[1].Vin = 'VIN01000010000102';
        response[1].WarrantyExclusionsData = new Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] {
            new Nna360WarrantyMasterServiceSoap.WarrantyExclusions()
        };
        response[1].WarrantyExclusionsData[0].WarrantyExclusionCode = 'W';
        response[1].WarrantyExclusionsData[0].WarrantyExclusionDescription = 'WE DESC';
        
        response[2].Vin = 'VIN01000010000103';
        response[2].BrandedInfoData = new Nna360WarrantyMasterServiceSoap.BrandedInfo[] {
            new Nna360WarrantyMasterServiceSoap.BrandedInfo()
        };
        response[2].BrandedInfoData[0].StateCode = 'CO';
        response[2].BrandedInfoData[0].RecordTypeCode = '#';
        response[2].BrandedInfoData[0].SourceIDCode = '!!';
        response[2].BrandedInfoData[0].BrandedCode = 'B';
        response[2].BrandedInfoData[0].BrandedDescription = 'BRND DESC';
        response[2].BrandedInfoData[0].SourceLastUpdateDate = '2012-03-14 19:18:36.0';
        
        //existing warranty data
        response[3].Vin = 'VIN01000010000101';
        response[3].ApplicableWarrantyData = new Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] {
            new Nna360WarrantyMasterServiceSoap.ApplicableWarranty()
        };
        response[3].ApplicableWarrantyData[0].WarrantyDescription = 'AW Description';
        
        return response;
    }
}