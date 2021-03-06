//Generated by wsdl2apex

public class Nna360VehicleServiceContractsServiceSoap {
    public class VehicleServiceContractComments {
        public String Vin;
        public String LastUpdated;
        public String LineNumber;
        public String CommentText;
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LastUpdated_type_info = new String[]{'LastUpdated','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LineNumber_type_info = new String[]{'LineNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CommentText_type_info = new String[]{'CommentText','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin','LastUpdated','LineNumber','CommentText'};
    }
    public class VehicleServiceContract {
        public String Vin;
        public Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts[] VehicleServiceContractsData;
        public Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments[] VehicleServiceContractCommentsData;
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] VehicleServiceContractsData_type_info = new String[]{'VehicleServiceContractsData','http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','VehicleServiceContracts','0','-1','false'};
        private String[] VehicleServiceContractCommentsData_type_info = new String[]{'VehicleServiceContractCommentsData','http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','VehicleServiceContractComments','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin','VehicleServiceContractsData','VehicleServiceContractCommentsData'};
    }
    public class VehicleServiceContracts {
        public String CustomerMiddleName;
        public String CancelDate;
        public String CustomerFirstName;
        public String CustomerLastName;
        public String DeductibleAmount;
        public String EffectiveDate;
        public String ExpireMileage;
        public String ExpireDate;
        public String TransactionDate;
        public String TransferDate;
        public String DealerNumber;
        public String DealerState;
        public String PrintedDate;
        public String CancelMileage;
        public String PolicyNumber;
        public String Vin;
        public String CancelFee;
        public String Source;
        public String PaidToDate;
        public String Product;
        public String VehicleType;
        public String VehiclePrice;
        public String ApplicationNumber;
        public String CustomerNetRefund;
        public String DealerNetRefund;
        public String CancelRefundPercent;
        public String AddedDate;
        public String CustomerPrimaryPhone;
        public String CustomerCity;
        public String CustomerSecondaryPhone;
        public String CustomerState;
        public String CustomerAddress;
        public String CustomerZip;
        public String CustomerEmail;
        public String LienholderCity;
        public String LienholderName;
        public String LienholderState;
        public String LienholderStreet;
        public String LienholderZip;
        public String PlanCode;
        public String ProgramCode;
        public String VehicleOption;
        public String PurchasePrice;
        public String PriceCode;
        public String PlanType;
        public String FinanceTerm;
        public String CancelRequestedBy;
        public String RequestReceivedDate;
        public String ContractType;
        public String Odometer;
        public String CancelEffectiveDate;
        public String PlanTerm;
        public String LastTransactionDate;
        private String[] CustomerMiddleName_type_info = new String[]{'CustomerMiddleName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelDate_type_info = new String[]{'CancelDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerFirstName_type_info = new String[]{'CustomerFirstName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerLastName_type_info = new String[]{'CustomerLastName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DeductibleAmount_type_info = new String[]{'DeductibleAmount','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EffectiveDate_type_info = new String[]{'EffectiveDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExpireMileage_type_info = new String[]{'ExpireMileage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExpireDate_type_info = new String[]{'ExpireDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TransactionDate_type_info = new String[]{'TransactionDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TransferDate_type_info = new String[]{'TransferDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DealerNumber_type_info = new String[]{'DealerNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DealerState_type_info = new String[]{'DealerState','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PrintedDate_type_info = new String[]{'PrintedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelMileage_type_info = new String[]{'CancelMileage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PolicyNumber_type_info = new String[]{'PolicyNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelFee_type_info = new String[]{'CancelFee','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Source_type_info = new String[]{'Source','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PaidToDate_type_info = new String[]{'PaidToDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Product_type_info = new String[]{'Product','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] VehicleType_type_info = new String[]{'VehicleType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] VehiclePrice_type_info = new String[]{'VehiclePrice','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ApplicationNumber_type_info = new String[]{'ApplicationNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerNetRefund_type_info = new String[]{'CustomerNetRefund','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DealerNetRefund_type_info = new String[]{'DealerNetRefund','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelRefundPercent_type_info = new String[]{'CancelRefundPercent','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AddedDate_type_info = new String[]{'AddedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerPrimaryPhone_type_info = new String[]{'CustomerPrimaryPhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerCity_type_info = new String[]{'CustomerCity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerSecondaryPhone_type_info = new String[]{'CustomerSecondaryPhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerState_type_info = new String[]{'CustomerState','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerAddress_type_info = new String[]{'CustomerAddress','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerZip_type_info = new String[]{'CustomerZip','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerEmail_type_info = new String[]{'CustomerEmail','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LienholderCity_type_info = new String[]{'LienholderCity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LienholderName_type_info = new String[]{'LienholderName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LienholderState_type_info = new String[]{'LienholderState','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LienholderStreet_type_info = new String[]{'LienholderStreet','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LienholderZip_type_info = new String[]{'LienholderZip','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PlanCode_type_info = new String[]{'PlanCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ProgramCode_type_info = new String[]{'ProgramCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] VehicleOption_type_info = new String[]{'VehicleOption','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PurchasePrice_type_info = new String[]{'PurchasePrice','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PriceCode_type_info = new String[]{'PriceCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PlanType_type_info = new String[]{'PlanType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FinanceTerm_type_info = new String[]{'FinanceTerm','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelRequestedBy_type_info = new String[]{'CancelRequestedBy','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RequestReceivedDate_type_info = new String[]{'RequestReceivedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ContractType_type_info = new String[]{'ContractType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Odometer_type_info = new String[]{'Odometer','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CancelEffectiveDate_type_info = new String[]{'CancelEffectiveDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PlanTerm_type_info = new String[]{'PlanTerm','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LastTransactionDate_type_info = new String[]{'LastTransactionDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerMiddleName','CancelDate','CustomerFirstName','CustomerLastName','DeductibleAmount','EffectiveDate','ExpireMileage','ExpireDate','TransactionDate','TransferDate','DealerNumber','DealerState','PrintedDate','CancelMileage','PolicyNumber','Vin','CancelFee','Source','PaidToDate','Product','VehicleType','VehiclePrice','ApplicationNumber','CustomerNetRefund','DealerNetRefund','CancelRefundPercent','AddedDate','CustomerPrimaryPhone','CustomerCity','CustomerSecondaryPhone','CustomerState','CustomerAddress','CustomerZip','CustomerEmail','LienholderCity','LienholderName','LienholderState','LienholderStreet','LienholderZip','PlanCode','ProgramCode','VehicleOption','PurchasePrice','PriceCode','PlanType','FinanceTerm','CancelRequestedBy','RequestReceivedDate','ContractType','Odometer','CancelEffectiveDate','PlanTerm','LastTransactionDate'};
    }
    public class VehicleServiceContract_Output {
        public Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] VehicleServiceContractData;
        private String[] VehicleServiceContractData_type_info = new String[]{'VehicleServiceContractData','http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','VehicleServiceContract','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'VehicleServiceContractData'};
    }
    public class VehicleServiceContract_IG_VehicleServiceContractMasterServiceHttpPort {
        public String endpoint_x = System.label.Nna360_EndPoint_VehicleServiceContract;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService', 'Nna360VehicleServiceContractsServiceSoap'};
        public Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] getVehicleServiceContractData(String[] Vin) {
            Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Input request_x = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Input();
            Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Output response_x;
            request_x.Vin = Vin;
            Map<String, Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Output> response_map_x = new Map<String, Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Output>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService',
              'getVehicleServiceContractDataRequest',
              'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService',
              'getVehicleServiceContractDataResponse',
              'Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_Output'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.VehicleServiceContractData;
        }
    }
    public class VehicleServiceContract_Input {
        public String[] Vin;
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/VehicleServiceContractMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin'};
    }
}