//Generated by wsdl2apex

public class Nna360ClaimMasterServiceSoap {
    public class DealerVehicleClaimOutput {
        public Nna360ClaimMasterServiceSoap.DealerVehicleClaim DealerVehicleClaimData;
        private String[] DealerVehicleClaimData_type_info = new String[]{'DealerVehicleClaimData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'DealerVehicleClaimData'};
    }
    public class DealerWarrantyClaimLine {
        public String WarrantyClaimLineBusinessId;
        public String WorkOrderNumber;
        public String Vin;
        public String ClaimLineNumber;
        public String ClaimServiceTechNumber;
        public String PNCCode;
        public String PNCDescription;
        public String ComplaintDescription;
        public String CauseDescription;
        public String DiagnosisDescription;
        public String CorrectionDescription;
        public String ErrorDescription;
        public String SubmittedAmount;
        public String PaidAmount;
        public String ClaimTypeCode;
        public String ClaimCoverageCode;
        public String DispositionCode;
        public String ClaimDeniedReasonCode;
        public String WorkOrderLineStatusCode;
        public String PrimaryFailedPart;
        public String VehicleClaimAuthorizationIndicator;
        public String ClaimApprovedCoverageCode;
        public String PrimaryOperationCode;
        public String OriginalPurchaseDate;
        public String OriginalPurchaseMiles;
        public String PrimaryFailedPartDescription;
        private String[] WarrantyClaimLineBusinessId_type_info = new String[]{'WarrantyClaimLineBusinessId','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderNumber_type_info = new String[]{'WorkOrderNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimLineNumber_type_info = new String[]{'ClaimLineNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimServiceTechNumber_type_info = new String[]{'ClaimServiceTechNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PNCCode_type_info = new String[]{'PNCCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PNCDescription_type_info = new String[]{'PNCDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ComplaintDescription_type_info = new String[]{'ComplaintDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] CauseDescription_type_info = new String[]{'CauseDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DiagnosisDescription_type_info = new String[]{'DiagnosisDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] CorrectionDescription_type_info = new String[]{'CorrectionDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ErrorDescription_type_info = new String[]{'ErrorDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] SubmittedAmount_type_info = new String[]{'SubmittedAmount','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PaidAmount_type_info = new String[]{'PaidAmount','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimTypeCode_type_info = new String[]{'ClaimTypeCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCoverageCode_type_info = new String[]{'ClaimCoverageCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DispositionCode_type_info = new String[]{'DispositionCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimDeniedReasonCode_type_info = new String[]{'ClaimDeniedReasonCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderLineStatusCode_type_info = new String[]{'WorkOrderLineStatusCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryFailedPart_type_info = new String[]{'PrimaryFailedPart','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleClaimAuthorizationIndicator_type_info = new String[]{'VehicleClaimAuthorizationIndicator','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimApprovedCoverageCode_type_info = new String[]{'ClaimApprovedCoverageCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryOperationCode_type_info = new String[]{'PrimaryOperationCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OriginalPurchaseDate_type_info = new String[]{'OriginalPurchaseDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OriginalPurchaseMiles_type_info = new String[]{'OriginalPurchaseMiles','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryFailedPartDescription_type_info = new String[]{'PrimaryFailedPartDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyClaimLineBusinessId','WorkOrderNumber','Vin','ClaimLineNumber','ClaimServiceTechNumber','PNCCode','PNCDescription','ComplaintDescription','CauseDescription','DiagnosisDescription','CorrectionDescription','ErrorDescription','SubmittedAmount','PaidAmount','ClaimTypeCode','ClaimCoverageCode','DispositionCode','ClaimDeniedReasonCode','WorkOrderLineStatusCode','PrimaryFailedPart','VehicleClaimAuthorizationIndicator','ClaimApprovedCoverageCode','PrimaryOperationCode','OriginalPurchaseDate','OriginalPurchaseMiles','PrimaryFailedPartDescription'};
    }
    public class Dealer {
        public String Vin;
        public Nna360ClaimMasterServiceSoap.DealerClaim[] DealerClaimData;
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'1','1','false'};
        private String[] DealerClaimData_type_info = new String[]{'DealerClaimData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin','DealerClaimData'};
    }
    public class WarrantyClaimLine {
        public String WarrantyClaimLineBusinessId;
        public String DealerNumber;
        public String WorkOrderNumber;
        public String Vin;
        public String ClaimLineNumber;
        public String ClaimServiceTechNumber;
        public String PNCCode;
        public String PNCDescription;
        public String ComplaintDescription;
        public String CauseDescription;
        public String DiagnosisDescription;
        public String CorrectionDescription;
        public String ErrorDescription;
        public String SubmittedAmount;
        public String PaidAmount;
        public String ClaimTypeCode;
        public String ClaimCoverageCode;
        public String DispositionCode;
        public String ClaimDeniedReasonCode;
        public String WorkOrderLineStatusCode;
        public String PrimaryFailedPart;
        public String VehicleClaimAuthorizationIndicator;
        public String ClaimApprovedCoverageCode;
        public String PrimaryOperationCode;
        public String OriginalPurchaseDate;
        public String OriginalPurchaseMiles;
        public String PrimaryFailedPartDescription;
        private String[] WarrantyClaimLineBusinessId_type_info = new String[]{'WarrantyClaimLineBusinessId','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DealerNumber_type_info = new String[]{'DealerNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderNumber_type_info = new String[]{'WorkOrderNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimLineNumber_type_info = new String[]{'ClaimLineNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimServiceTechNumber_type_info = new String[]{'ClaimServiceTechNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PNCCode_type_info = new String[]{'PNCCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PNCDescription_type_info = new String[]{'PNCDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ComplaintDescription_type_info = new String[]{'ComplaintDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] CauseDescription_type_info = new String[]{'CauseDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DiagnosisDescription_type_info = new String[]{'DiagnosisDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] CorrectionDescription_type_info = new String[]{'CorrectionDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ErrorDescription_type_info = new String[]{'ErrorDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] SubmittedAmount_type_info = new String[]{'SubmittedAmount','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PaidAmount_type_info = new String[]{'PaidAmount','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimTypeCode_type_info = new String[]{'ClaimTypeCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCoverageCode_type_info = new String[]{'ClaimCoverageCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DispositionCode_type_info = new String[]{'DispositionCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimDeniedReasonCode_type_info = new String[]{'ClaimDeniedReasonCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderLineStatusCode_type_info = new String[]{'WorkOrderLineStatusCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryFailedPart_type_info = new String[]{'PrimaryFailedPart','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleClaimAuthorizationIndicator_type_info = new String[]{'VehicleClaimAuthorizationIndicator','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimApprovedCoverageCode_type_info = new String[]{'ClaimApprovedCoverageCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryOperationCode_type_info = new String[]{'PrimaryOperationCode','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OriginalPurchaseDate_type_info = new String[]{'OriginalPurchaseDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OriginalPurchaseMiles_type_info = new String[]{'OriginalPurchaseMiles','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] PrimaryFailedPartDescription_type_info = new String[]{'PrimaryFailedPartDescription','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyClaimLineBusinessId','DealerNumber','WorkOrderNumber','Vin','ClaimLineNumber','ClaimServiceTechNumber','PNCCode','PNCDescription','ComplaintDescription','CauseDescription','DiagnosisDescription','CorrectionDescription','ErrorDescription','SubmittedAmount','PaidAmount','ClaimTypeCode','ClaimCoverageCode','DispositionCode','ClaimDeniedReasonCode','WorkOrderLineStatusCode','PrimaryFailedPart','VehicleClaimAuthorizationIndicator','ClaimApprovedCoverageCode','PrimaryOperationCode','OriginalPurchaseDate','OriginalPurchaseMiles','PrimaryFailedPartDescription'};
    }
    public class VehicleClaim_Output {
        public Nna360ClaimMasterServiceSoap.VehicleClaim[] VehicleClaimData;
        private String[] VehicleClaimData_type_info = new String[]{'VehicleClaimData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'VehicleClaimData'};
    }
    public class Claim {
        public String WarrantyClaimBusinessId;
        public String DealerNumber;
        public String WorkOrderNumber;
        public String Vin;
        public String TransactionDate;
        public String VehicleRepairOpenDate;
        public String VehicleRepairCloseDate;
        public String VehicleMileageNumber;
        public String ClaimCustomerFirstName;
        public String ClaimCustomerLastName;
        public String ClaimCustomerStreetAddress1;
        public String ClaimCustomerStreetAddress2;
        public String ClaimCustomerZip;
        public String ClaimCustomerCity;
        public String ClaimCustomerStateProvince;
        public String ClaimCustomerPhone;
        public String OwnerIndicator;
        public Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] WarrantyClaimLineData;
        private String[] WarrantyClaimBusinessId_type_info = new String[]{'WarrantyClaimBusinessId','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DealerNumber_type_info = new String[]{'DealerNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderNumber_type_info = new String[]{'WorkOrderNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] TransactionDate_type_info = new String[]{'TransactionDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleRepairOpenDate_type_info = new String[]{'VehicleRepairOpenDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleRepairCloseDate_type_info = new String[]{'VehicleRepairCloseDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleMileageNumber_type_info = new String[]{'VehicleMileageNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerFirstName_type_info = new String[]{'ClaimCustomerFirstName','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerLastName_type_info = new String[]{'ClaimCustomerLastName','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStreetAddress1_type_info = new String[]{'ClaimCustomerStreetAddress1','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStreetAddress2_type_info = new String[]{'ClaimCustomerStreetAddress2','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerZip_type_info = new String[]{'ClaimCustomerZip','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerCity_type_info = new String[]{'ClaimCustomerCity','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStateProvince_type_info = new String[]{'ClaimCustomerStateProvince','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerPhone_type_info = new String[]{'ClaimCustomerPhone','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OwnerIndicator_type_info = new String[]{'OwnerIndicator','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WarrantyClaimLineData_type_info = new String[]{'WarrantyClaimLineData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyClaimBusinessId','DealerNumber','WorkOrderNumber','Vin','TransactionDate','VehicleRepairOpenDate','VehicleRepairCloseDate','VehicleMileageNumber','ClaimCustomerFirstName','ClaimCustomerLastName','ClaimCustomerStreetAddress1','ClaimCustomerStreetAddress2','ClaimCustomerZip','ClaimCustomerCity','ClaimCustomerStateProvince','ClaimCustomerPhone','OwnerIndicator','WarrantyClaimLineData'};
    }
    public class DealerClaim {
        public String WarrantyClaimBusinessId;
        public String WorkOrderNumber;
        public String Vin;
        public String TransactionDate;
        public String VehicleRepairOpenDate;
        public String VehicleRepairCloseDate;
        public String VehicleMileageNumber;
        public String ClaimCustomerFirstName;
        public String ClaimCustomerLastName;
        public String ClaimCustomerStreetAddress1;
        public String ClaimCustomerStreetAddress2;
        public String ClaimCustomerZip;
        public String ClaimCustomerCity;
        public String ClaimCustomerStateProvince;
        public String ClaimCustomerPhone;
        public String OwnerIndicator;
        public Nna360ClaimMasterServiceSoap.DealerWarrantyClaimLine[] DealerWarrantyClaimLineData;
        private String[] WarrantyClaimBusinessId_type_info = new String[]{'WarrantyClaimBusinessId','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] WorkOrderNumber_type_info = new String[]{'WorkOrderNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] TransactionDate_type_info = new String[]{'TransactionDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleRepairOpenDate_type_info = new String[]{'VehicleRepairOpenDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleRepairCloseDate_type_info = new String[]{'VehicleRepairCloseDate','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] VehicleMileageNumber_type_info = new String[]{'VehicleMileageNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerFirstName_type_info = new String[]{'ClaimCustomerFirstName','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerLastName_type_info = new String[]{'ClaimCustomerLastName','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStreetAddress1_type_info = new String[]{'ClaimCustomerStreetAddress1','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStreetAddress2_type_info = new String[]{'ClaimCustomerStreetAddress2','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerZip_type_info = new String[]{'ClaimCustomerZip','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerCity_type_info = new String[]{'ClaimCustomerCity','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerStateProvince_type_info = new String[]{'ClaimCustomerStateProvince','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] ClaimCustomerPhone_type_info = new String[]{'ClaimCustomerPhone','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] OwnerIndicator_type_info = new String[]{'OwnerIndicator','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','1','false'};
        private String[] DealerWarrantyClaimLineData_type_info = new String[]{'DealerWarrantyClaimLineData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyClaimBusinessId','WorkOrderNumber','Vin','TransactionDate','VehicleRepairOpenDate','VehicleRepairCloseDate','VehicleMileageNumber','ClaimCustomerFirstName','ClaimCustomerLastName','ClaimCustomerStreetAddress1','ClaimCustomerStreetAddress2','ClaimCustomerZip','ClaimCustomerCity','ClaimCustomerStateProvince','ClaimCustomerPhone','OwnerIndicator','DealerWarrantyClaimLineData'};
    }
    public class VehicleClaim {
        public String Vin;
        public Nna360ClaimMasterServiceSoap.Claim[] ClaimData;
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'1','1','false'};
        private String[] ClaimData_type_info = new String[]{'ClaimData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin','ClaimData'};
    }
    public class DealerVehicleClaim {
        public String DealerNumber;
        public Nna360ClaimMasterServiceSoap.Dealer[] DealerData;
        private String[] DealerNumber_type_info = new String[]{'DealerNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'1','1','false'};
        private String[] DealerData_type_info = new String[]{'DealerData','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'DealerNumber','DealerData'};
    }
    public class DealerVehicleClaimInput {
        public String DealerNumber;
        private String[] DealerNumber_type_info = new String[]{'DealerNumber','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'DealerNumber'};
    }
    public class VehicleClaim_Input {
        public String[] Vin;
        private String[] Vin_type_info = new String[]{'Vin','http://xmlns.nissan.com/scm/nna/ClaimMasterService',null,'1','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin'};
    }
    public class WS_IG_ClaimMasterService_EXP_IG_ClaimMasterServiceHttpPort {
        public String endpoint_x; //  'http://localhost:9080/MM_ClaimMasterServiceWeb/sca/WS_IG_ClaimMasterService_EXP';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/ClaimMasterService', 'Nna360ClaimMasterServiceSoap'};
        public Nna360ClaimMasterServiceSoap.DealerVehicleClaim getDealerVehicleClaimData(String DealerNumber) {
            Nna360ClaimMasterServiceSoap.DealerVehicleClaimInput request_x = new Nna360ClaimMasterServiceSoap.DealerVehicleClaimInput();
            request_x.DealerNumber = DealerNumber;
            Nna360ClaimMasterServiceSoap.DealerVehicleClaimOutput response_x;
            Map<String, Nna360ClaimMasterServiceSoap.DealerVehicleClaimOutput> response_map_x = new Map<String, Nna360ClaimMasterServiceSoap.DealerVehicleClaimOutput>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://xmlns.nissan.com/scm/nna/ClaimMasterService',
              'getDealerVehicleClaimDataRequest',
              'http://xmlns.nissan.com/scm/nna/ClaimMasterService',
              'getDealerVehicleClaimDataResponse',
              'Nna360ClaimMasterServiceSoap.DealerVehicleClaimOutput'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.DealerVehicleClaimData;
        }
        public Nna360ClaimMasterServiceSoap.VehicleClaim[] getVehicleClaimData(String[] Vin) {
            Nna360ClaimMasterServiceSoap.VehicleClaim_Input request_x = new Nna360ClaimMasterServiceSoap.VehicleClaim_Input();
            request_x.Vin = Vin;
            Nna360ClaimMasterServiceSoap.VehicleClaim_Output response_x;
            Map<String, Nna360ClaimMasterServiceSoap.VehicleClaim_Output> response_map_x = new Map<String, Nna360ClaimMasterServiceSoap.VehicleClaim_Output>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://xmlns.nissan.com/scm/nna/ClaimMasterService',
              'getVehicleClaimDataRequest',
              'http://xmlns.nissan.com/scm/nna/ClaimMasterService',
              'getVehicleClaimDataResponse',
              'Nna360ClaimMasterServiceSoap.VehicleClaim_Output'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.VehicleClaimData;
        }
    }
}