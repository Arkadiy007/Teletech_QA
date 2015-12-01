public class VehicleWarrantyIntegrationMockResponses{

   
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
        Nna360WarrantyMasterServiceSoap.ApplicableWarranty appWrty = new Nna360WarrantyMasterServiceSoap.ApplicableWarranty();
        appWrty.WarrantyDescription = 'WarrantyDesc 1';
        appWrty.WarrantyExpirationDate = '02/02/2014';
        appWrty.WarrantyExpirationMiles = '80,000';
        
        response[3].ApplicableWarrantyData = new Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] { appWrty };
        response[3].ApplicableWarrantyData[0].WarrantyDescription = 'AW Description';
        response[3].WarrantyExclusionsData = new Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] {
            new Nna360WarrantyMasterServiceSoap.WarrantyExclusions()
        };
        response[3].WarrantyExclusionsData[0].WarrantyExclusionCode = 'W';
        response[3].WarrantyExclusionsData[0].WarrantyExclusionDescription = 'WE DESC';
        response[3].BrandedInfoData = new Nna360WarrantyMasterServiceSoap.BrandedInfo[] {
            new Nna360WarrantyMasterServiceSoap.BrandedInfo()
        };
        response[3].BrandedInfoData[0].StateCode = 'CO';
        response[3].BrandedInfoData[0].RecordTypeCode = '#';
        response[3].BrandedInfoData[0].SourceIDCode = '!!';
        response[3].BrandedInfoData[0].BrandedCode = 'B';
        response[3].BrandedInfoData[0].BrandedDescription = 'BRND DESC';
        response[3].BrandedInfoData[0].SourceLastUpdateDate = '2012-03-14 19:18:36.0';
        
        return response;
    }
    
      /**
        create mock response for Dealer Suspended Claims
    */
    public static Nna360ClaimMasterServiceSoap.DealerVehicleClaim mockDealerClaimResponse() {
        Nna360ClaimMasterServiceSoap.DealerVehicleClaim response = new Nna360ClaimMasterServiceSoap.DealerVehicleClaim();
        
        //ClaimData is null
        response.DealerNumber = '08648';
        //extisting claim        
        response.DealerData = new Nna360ClaimMasterServiceSoap.Dealer[] {
            new Nna360ClaimMasterServiceSoap.Dealer()
        };
        response.DealerData[0].Vin = 'VIN01000010000102';
        response.DealerData[0].DealerClaimData = new Nna360ClaimMasterServiceSoap.DealerClaim[]{
        	new Nna360ClaimMasterServiceSoap.DealerClaim()
        };
        
        response.DealerData[0].DealerClaimData[0].VIN = 'VIN01000010000102';        
        response.DealerData[0].DealerClaimData[0].WarrantyClaimBusinessId = '01';
        response.DealerData[0].DealerClaimData[0].WorkOrderNumber = '0938';
        response.DealerData[0].DealerClaimData[0].TransactionDate = '2012-12-21 00:00:00.0';
        //AAB 09/29/2014 - adding test claim line data
        response.DealerData[0].DealerClaimData[0].VehicleRepairOpenDate = '2013-08-23 00:00:00.0';
        response.DealerData[0].DealerClaimData[0].VehicleRepairCloseDate = '2013-08-27 00:00:00.0';
        response.DealerData[0].DealerClaimData[0].VehicleMileageNumber = '9878';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerFirstName = 'CFirst';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerLastName = 'CLast';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerStreetAddress1 = '537';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerStreetAddress2 = 'S 3rd Street';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerZip = '40202';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerStateProvince = 'KY';
        response.DealerData[0].DealerClaimData[0].ClaimCustomerPhone = '09823792873';
        response.DealerData[0].DealerClaimData[0].OwnerIndicator = 'Y';
        
        response.DealerData[0].DealerClaimData[0].DealerWarrantyClaimLineData = new  Nna360ClaimMasterServiceSoap.DealerWarrantyClaimLine[]{
        	new Nna360ClaimMasterServiceSoap.DealerWarrantyClaimLine()
        };
        
        response.DealerData[0].DealerClaimData[0].DealerWarrantyClaimLineData[0].ClaimLineNumber = 'A';
        response.DealerData[0].DealerClaimData[0].DealerWarrantyClaimLineData[0].WorkOrderNumber = '0938';
        
        return response;
    }
}