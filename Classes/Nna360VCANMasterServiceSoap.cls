public class Nna360VCANMasterServiceSoap {

    public class VCANMasterServiceHttpPort {
        //public String endpoint_x = 'http://requestb.in/q8n1lpq8';//http://requestb.in/nv9oqfnv';
        public String endpoint_x = System.label.NNA_360_Endpoint_VCan;
        
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        //AAB 7/22/2014 - set to a default of 120000 instead of 120
        public Integer timeout_x = 120000;
        // Nna360VCANMasterServiceSoap.VCANDetails[]    previous return value
        private String[] ns_map_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService', 'Nna360VCANMasterServiceSoap'};
        public Nna360VCANMasterServiceSoap.viewVCANResp viewVCAN(String[] Vin, String[] WONumber, String[] WOLine, String[] ServiceFacility) {
            Nna360VCANMasterServiceSoap.viewVCAN_Input vcanInput = new Nna360VCANMasterServiceSoap.viewVCAN_Input();
            vcanInput.VIN=Vin;
            vcanInput.WONumber=WONumber;
            vcanInput.WOLine = WOLine ;
            vcanInput.ServiceFacility = ServiceFacility;
            
            Nna360VCANMasterServiceSoap.viewVCAN_Request request_x = new Nna360VCANMasterServiceSoap.viewVCAN_Request();
            Nna360VCANMasterServiceSoap.viewVCANResp response_x;
            
            Nna360VCANMasterServiceSoap.viewVCAN_Query nnaQuery = new Nna360VCANMasterServiceSoap.viewVCAN_Query();
            nnaQuery.viewVCANInput = vcanInput;
            request_x.VCANQuery = nnaQuery;
            
            
            Map<String, Nna360VCANMasterServiceSoap.viewVCANResp> response_map_x = new Map<String, Nna360VCANMasterServiceSoap.viewVCANResp>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
              'viewVCAN',
              'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
              'viewVCANResponse',
              'Nna360VCANMasterServiceSoap.viewVCANResp'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;    //return response_x.viewVCANResponse.viewVCANResp.VCANDetails
        }
    }
   

   
    public class ApprovalAmounts {
        public String[] Parts;
        public String[] LBR;
        public String[] Expense;
        public String[] Total;
        private String[] Parts_type_info = new String[]{'Parts','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LBR_type_info = new String[]{'LBR','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Expense_type_info = new String[]{'Expense','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Total_type_info = new String[]{'Total','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'Parts','LBR','Expense','Total'};
    }
    public class ActApprovalCondition {
        public String[] NormalApproval;
        public String[] RepairReview;
        public String[] MileageProgressReview;
        public String[] CampaignDiffDealer;
        public String[] GoodwillApproval;
        private String[] NormalApproval_type_info = new String[]{'NormalApproval','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RepairReview_type_info = new String[]{'RepairReview','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MileageProgressReview_type_info = new String[]{'MileageProgressReview','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CampaignDiffDealer_type_info = new String[]{'CampaignDiffDealer','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GoodwillApproval_type_info = new String[]{'GoodwillApproval','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'NormalApproval','RepairReview','MileageProgressReview','CampaignDiffDealer','GoodwillApproval'};
    }
    
    
    public class VCANDetails {
            public Nna360VCANMasterServiceSoap.ApprovalAmounts ApprovalAmounts;
            public Nna360VCANMasterServiceSoap.ActApprovalCondition ActApprovalCondition;
            public String VCANRefNumber;
            public String AffiliateCode;
            public String WONumber;
            public String WOLine;
            public String ServiceFacility;
            public String VIN;
            public String WOOpenDate;
            public String Miles;
            public String PFPPO;
            public String CallerName;
            public String CallerPhone;
            public String CallerExt;
            public String CustomerName;
            public String PartsAtCost;
            public String[] ApprovalComments;
            public String ForceGoodwill;
            public String ApprovalStatus;
            public String ApprId;
            public String ApprDate;
            public String EnteredByUserId;
            public String EnteredDate;
            public String ChangedByUserId;
            public String ChangedDate;
            public String LanId;
            public String Message;
            private String[] ApprovalAmounts_type_info = new String[]{'ApprovalAmounts','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','ApprovalAmounts','0','10','false'};
            private String[] ActApprovalCondition_type_info = new String[]{'ActApprovalCondition','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','ActApprovalCondition','0','10','false'};
            private String[] VCANRefNumber_type_info = new String[]{'VCANRefNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] AffiliateCode_type_info = new String[]{'AffiliateCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] WONumber_type_info = new String[]{'WONumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] WOLine_type_info = new String[]{'WOLine','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ServiceFacility_type_info = new String[]{'ServiceFacility','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] VIN_type_info = new String[]{'VIN','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] WOOpenDate_type_info = new String[]{'WOOpenDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] Miles_type_info = new String[]{'Miles','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] PFPPO_type_info = new String[]{'PFPPO','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] CallerName_type_info = new String[]{'CallerName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] CallerPhone_type_info = new String[]{'CallerPhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] CallerExt_type_info = new String[]{'CallerExt','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] CustomerName_type_info = new String[]{'CustomerName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] PartsAtCost_type_info = new String[]{'PartsAtCost','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ApprovalComments_type_info = new String[]{'ApprovalComments','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ForceGoodwill_type_info = new String[]{'ForceGoodwill','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ApprovalStatus_type_info = new String[]{'ApprovalStatus','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ApprId_type_info = new String[]{'ApprId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ApprDate_type_info = new String[]{'ApprDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] EnteredByUserId_type_info = new String[]{'EnteredByUserId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] EnteredDate_type_info = new String[]{'EnteredDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ChangedByUserId_type_info = new String[]{'ChangedByUserId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] ChangedDate_type_info = new String[]{'ChangedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] LanId_type_info = new String[]{'LanId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
            private String[] field_order_type_info = new String[]{'ApprovalAmounts','ActApprovalCondition','VCANRefNumber','AffiliateCode','WONumber','WOLine','ServiceFacility','VIN','WOOpenDate','Miles','PFPPO','CallerName','CallerPhone','CallerExt','CustomerName','PartsAtCost','ApprovalComments','ForceGoodwill','ApprovalStatus','ApprId','ApprDate','EnteredByUserId','EnteredDate','ChangedByUserId','ChangedDate','LanId','Message'};
            
    }

    public class viewVCAN_Request {
        public Nna360VCANMasterServiceSoap.viewVCAN_Query VCANQuery;
        private String[] VCANQuery_type_info = new String[]{'viewVCANReq','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANQuery','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VCANQuery'};
    }
    
    public class viewVCAN_Query {
        public Nna360VCANMasterServiceSoap.viewVCAN_Input viewVCANInput;
        private String[] viewVCANInput_type_info = new String[]{'VCANQuery','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANQuery','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'viewVCANInput'};
    }
    

    public class viewVCAN_Input {
        public String[] VIN;
        public String[] ServiceFacility;
        public String[] WOLine;
        public String[] WONumber;
        private String[] VIN_type_info = new String[]{'VIN','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] ServiceFacility_type_info = new String[]{'ServiceFacility','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] WOLine_type_info = new String[]{'WOLine','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] WONumber_type_info = new String[]{'WONumber','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VIN','ServiceFacility','WOLine','WONumber'};
    }
    public class viewVCAN_Output {
        public Nna360VCANMasterServiceSoap.VCANDetails vcanDetails;
        private String[] vcanDetails_type_info = new String[]{'vcanDetails','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','vcanDetails','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'vcanDetails'};
    }
    
    
    public class viewVCANResp {
        public Nna360VCANMasterServiceSoap.viewVCAN_Output viewVCANResp;
        private String[] viewVCANResp_type_info = new String[]{'viewVCANResp','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','viewVCANResp','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'viewVCANResp'};
    }

    
}