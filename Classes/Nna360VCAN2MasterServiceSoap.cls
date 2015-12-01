public class Nna360VCAN2MasterServiceSoap {
  public class DG_VCANResponseFaultBO {        
      public String referrenceID;        
      public String faultCode;        
      public String faultMessage;        
      private String[] referrenceID_type_info = new String[]{'referrenceID','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};        
      private String[] faultCode_type_info = new String[]{'faultCode','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};        private String[] faultMessage_type_info = new String[]{'faultMessage','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};        
      private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
      private String[] field_order_type_info = new String[]{'referrenceID','faultCode','faultMessage'};    
  }
  
    public class VCANMasterServiceHttpPort {
        //public String endpoint_x = 'http://requestb.in/1i2ra8k1';//http://requestb.in/143wp6n1';
        public String endpoint_x = System.label.NNA_360_Endpoint_VCan;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x =120000;
        private String[] ns_map_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService', 'Nna360VCAN2MasterServiceSoap'};

      



        public Nna360VCAN2MasterServiceSoap.viewVCANResp viewVCAN(String Vin, String WONumber, String WOLine, String ServiceFacility,String Hb_User, String Hb_Password) {
            Nna360VCAN2MasterServiceSoap.viewVCAN_Input vcanInput = new Nna360VCAN2MasterServiceSoap.viewVCAN_Input();
            vcanInput.VIN=Vin;
            vcanInput.WONumber=WONumber;
            vcanInput.WOLine = WOLine;
            vcanInput.ServiceFacility = ServiceFacility;
            Nna360VCAN2MasterServiceSoap.viewVCAN_Request request_x = new Nna360VCAN2MasterServiceSoap.viewVCAN_Request();
            Nna360VCAN2MasterServiceSoap.viewVCANResp response_x;
            Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO fault_x;
            Nna360VCAN2MasterServiceSoap.viewVCAN_Query nnaQuery = new Nna360VCAN2MasterServiceSoap.viewVCAN_Query();
            nnaQuery.viewVCANInput = vcanInput;
            nnaQuery.Hb_User = Hb_User;
            nnaQuery.Hb_Password = Hb_Password;
            
            system.debug('User:' + Hb_User + ' Pass:' + Hb_Password);
            
            request_x.VCANQuery = nnaQuery;
            Map<String, Nna360VCAN2MasterServiceSoap.viewVCANResp> response_map_x = new Map<String, Nna360VCAN2MasterServiceSoap.viewVCANResp>();
            response_map_x.put('response_x', response_x);
            
            try
            {
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
                      'Nna360VCAN2MasterServiceSoap.viewVCANResp'}
                    );
            }
            catch(System.CalloutException ex)
            {
                system.debug('Message:' + ex.getMessage());
                
                response_x = new Nna360VCAN2MasterServiceSoap.viewVCANResp();
                
                Nna360VCAN2MasterServiceSoap.viewVCAN_Output errorOutput = new Nna360VCAN2MasterServiceSoap.viewVCAN_Output();
                Nna360VCAN2MasterServiceSoap.viewVCANResp errorResponse = new Nna360VCAN2MasterServiceSoap.viewVCANResp();
                errorOutput.MessageDescription = 'An error occured while attempting to view VCAN: ' + ex.getMessage();
                errorResponse.viewVCANResp = errorOutput;
                response_x = errorResponse;
                
                return response_x;  
                
            }
            
            
            response_x = response_map_x.get('response_x');
            
            return response_x;    
        }
        
          public Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO viewVCANErr(String Vin, String WONumber, String WOLine, String ServiceFacility,String Hb_User, String Hb_Password) {
            Nna360VCAN2MasterServiceSoap.viewVCAN_Input vcanInput = new Nna360VCAN2MasterServiceSoap.viewVCAN_Input();
            vcanInput.VIN=Vin;
            vcanInput.WONumber=WONumber;
            vcanInput.WOLine = WOLine;
            vcanInput.ServiceFacility = ServiceFacility;
            Nna360VCAN2MasterServiceSoap.viewVCAN_Request request_x = new Nna360VCAN2MasterServiceSoap.viewVCAN_Request();
            Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO response_x;
            Nna360VCAN2MasterServiceSoap.viewVCAN_Query nnaQuery = new Nna360VCAN2MasterServiceSoap.viewVCAN_Query();
            nnaQuery.viewVCANInput = vcanInput;
            nnaQuery.Hb_User = Hb_User;
            nnaQuery.Hb_Password = Hb_Password;
              
            system.debug('User:' + Hb_User + ' Pass:' + Hb_Password);
            
            request_x.VCANQuery = nnaQuery;
            Map<String, Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO> response_map_x = new Map<String, Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO>();
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
              'DG_VCANResponseFaultBO',
              'Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO'}
            );
            
            response_x = response_map_x.get('response_x');
            
            return response_x;    
        }
        
        
        public Nna360VCAN2MasterServiceSoap.createVCANResp createVCAN(Nna360VCAN2MasterServiceSoap.VCANDetails vcanDetails,String Hb_User, String Hb_Password) {
            Nna360VCAN2MasterServiceSoap.createVCAN_Input vcanInput = new Nna360VCAN2MasterServiceSoap.createVCAN_Input();
            Nna360VCAN2MasterServiceSoap.createVCAN_Request request_x = new Nna360VCAN2MasterServiceSoap.createVCAN_Request();
            vcanInput.vcanDetails = vcanDetails;
            request_x.createVCANReq = vcanInput;
            vcanInput.Hb_User = Hb_User;
            vcanInput.Hb_Password = Hb_Password;
            
            system.debug('User:' + Hb_User + ' Pass:' + Hb_Password);
            
            Nna360VCAN2MasterServiceSoap.createVCANResp response_x;
            Map<String, Nna360VCAN2MasterServiceSoap.createVCANResp> response_map_x = new Map<String, Nna360VCAN2MasterServiceSoap.createVCANResp>();
            response_map_x.put('response_x', response_x);
            try {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
              'createVCAN',
              'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
              'createVCANResponse',
              'Nna360VCAN2MasterServiceSoap.createVCANResp'}
            );
            response_x = response_map_x.get('response_x');
            } catch (Exception e) {
                Nna360VCAN2MasterServiceSoap.createVCAN_Output errorOutput = new Nna360VCAN2MasterServiceSoap.createVCAN_Output();
                Nna360VCAN2MasterServiceSoap.createVCANResp errorResponse = new Nna360VCAN2MasterServiceSoap.createVCANResp();
                errorOutput.MessageDescription = 'An error occured while attempting to create.' + e.getMessage();
                errorResponse.createVCANResp = errorOutput;
                response_x = errorResponse;
                
                
            }
            
            return response_x;
        }
        
        public Nna360VCAN2MasterServiceSoap.updateVCANResp updateVCAN(Nna360VCAN2MasterServiceSoap.VCANDetails vcanDetails,String Hb_User, String Hb_Password) {
            Nna360VCAN2MasterServiceSoap.updateVCAN_Input vcanInput = new Nna360VCAN2MasterServiceSoap.updateVCAN_Input();
            Nna360VCAN2MasterServiceSoap.updateVCAN_Request request_x = new Nna360VCAN2MasterServiceSoap.updateVCAN_Request();
            vcanInput.vcanDetails = vcanDetails;
            request_x.updateVCANReq = vcanInput;
            vcanInput.Hb_User = Hb_User;
            vcanInput.Hb_Password = Hb_Password;
            
            system.debug('User:' + Hb_User + ' Pass:' + Hb_Password);
            
            Nna360VCAN2MasterServiceSoap.updateVCANResp response_x;
            Map<String, Nna360VCAN2MasterServiceSoap.updateVCANResp> response_map_x = new Map<String, Nna360VCAN2MasterServiceSoap.updateVCANResp>();
            response_map_x.put('response_x', response_x);
            try {
                WebServiceCallout.invoke(
                  this,
                  request_x,
                  response_map_x,
                  new String[]{endpoint_x,
                  '',
                  'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
                  'updateVCAN',
                  'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
                  'updateVCANResponse',
                  'Nna360VCAN2MasterServiceSoap.updateVCANResp'}
                );
                response_x = response_map_x.get('response_x');
                
            } catch (Exception e) {
                Nna360VCAN2MasterServiceSoap.updateVCAN_Output errorOutput = new Nna360VCAN2MasterServiceSoap.updateVCAN_Output();
                Nna360VCAN2MasterServiceSoap.updateVCANResp errorResponse = new Nna360VCAN2MasterServiceSoap.updateVCANResp();
                errorOutput.MessageDescription = 'An error occured while attempting to update: ' + e.getMessage();
                errorResponse.updateVCANResp = errorOutput;
                response_x = errorResponse;
                
                
            }
            return response_x;
        }
    
        public Nna360VCAN2MasterServiceSoap.deleteVCANResp deleteVCAN(Nna360VCAN2MasterServiceSoap.vcanQueryData queryData,String Hb_User, String Hb_Password) {
            Nna360VCAN2MasterServiceSoap.deleteVCAN_Input vcanInput = new Nna360VCAN2MasterServiceSoap.deleteVCAN_Input();
            Nna360VCAN2MasterServiceSoap.deleteVCAN_Request request_x = new Nna360VCAN2MasterServiceSoap.deleteVCAN_Request();
            vcanInput.VCANQuery = queryData;
            request_x.deleteVCANReq = vcanInput;
            vcanInput.Hb_User = Hb_User;
            vcanInput.Hb_Password = Hb_Password;
            
            system.debug('User:' + Hb_User + ' Pass:' + Hb_Password);
            
            
            Nna360VCAN2MasterServiceSoap.deleteVCANResp response_x;
            Map<String, Nna360VCAN2MasterServiceSoap.deleteVCANResp> response_map_x = new Map<String, Nna360VCAN2MasterServiceSoap.deleteVCANResp>();
            response_map_x.put('response_x', response_x);
            try
            {
                WebServiceCallout.invoke(
                  this,
                  request_x,
                  response_map_x,
                  new String[]{endpoint_x,
                  '',
                  'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
                  'deleteVCAN',
                  'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',
                  'deleteVCANResponse',
                  'Nna360VCAN2MasterServiceSoap.deleteVCANResp'}
                );
                response_x = response_map_x.get('response_x');
            }
            catch (Exception e) {
                Nna360VCAN2MasterServiceSoap.deleteVCAN_Output errorOutput = new Nna360VCAN2MasterServiceSoap.deleteVCAN_Output();
                Nna360VCAN2MasterServiceSoap.deleteVCANResp errorResponse = new Nna360VCAN2MasterServiceSoap.deleteVCANResp();
                errorOutput.MessageDescription = 'An error occured while attempting to delete: ' + e.getMessage();
                errorResponse.deleteVCANResp = errorOutput;
                response_x = errorResponse;
            }
            
            return response_x;
        }
    
    }

    public class ApprovalAmounts {
        public String Parts;
        public String LBR;
        public String Expense;
        public String Total;
        private String[] Parts_type_info = new String[]{'Parts','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LBR_type_info = new String[]{'LBR','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Expense_type_info = new String[]{'Expense','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Total_type_info = new String[]{'Total','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'Parts','LBR','Expense','Total'};
    }
    public class ActApprovalCondition {
        public String NormalApproval;
        public String RepairReview;
        public String MileageProgressReview;
        public String CampaignDiffDealer;
        public String GoodwillApproval;
        private String[] NormalApproval_type_info = new String[]{'NormalApproval','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RepairReview_type_info = new String[]{'RepairReview','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MileageProgressReview_type_info = new String[]{'MileageProgressReview','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CampaignDiffDealer_type_info = new String[]{'CampaignDiffDealer','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GoodwillApproval_type_info = new String[]{'GoodwillApproval','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'NormalApproval','RepairReview','MileageProgressReview','CampaignDiffDealer','GoodwillApproval'};
    }
    
    public class VCANDetails {
            public Nna360VCAN2MasterServiceSoap.ApprovalAmounts ApprovalAmounts;
            public Nna360VCAN2MasterServiceSoap.ActApprovalCondition ActApprovalCondition;
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
    public class createVCAN_Request {
        public Nna360VCAN2MasterServiceSoap.createVCAN_Input createVCANReq;
        private String[] createVCANReq_type_info = new String[]{'createVCANReq','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] Hb_User_type_info = new String[]{'Hb_User','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Hb_Password_type_info = new String[]{'Hb_Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'}; 
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'createVCANReq'};
    }
    public class updateVCAN_Request {
        public Nna360VCAN2MasterServiceSoap.updateVCAN_Input updateVCANReq;
        public String Hb_User;
        public String Hb_Password;
        private String[] updateVCANReq_type_info = new String[]{'updateVCANReq','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'updateVCANReq'};
    }
    public class deleteVCAN_Request {
        public Nna360VCAN2MasterServiceSoap.deleteVCAN_Input deleteVCANReq;
        private String[] deleteVCANReq_type_info = new String[]{'deleteVCANReq','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'deleteVCANReq'};
    }
    
    public class viewVCAN_Request {
        public Nna360VCAN2MasterServiceSoap.viewVCAN_Query VCANQuery;
        private String[] VCANQuery_type_info = new String[]{'viewVCANReq','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANQuery','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VCANQuery'};
    }
    
    public class viewVCAN_Query {
        public Nna360VCAN2MasterServiceSoap.viewVCAN_Input viewVCANInput;
        public String Hb_User;
        public String Hb_Password;
        private String[] viewVCANInput_type_info = new String[]{'VCANQuery','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANQuery','0','1','false'};
        private String[] Hb_User_type_info = new String[]{'Hb_User','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Hb_Password_type_info = new String[]{'Hb_Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'}; 
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'viewVCANInput','Hb_User','Hb_Password'};
    }
    

    public class viewVCAN_Input {
        public String VIN;
        public String ServiceFacility;
        public String WOLine;
        public String WONumber;
        private String[] VIN_type_info = new String[]{'VIN','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] ServiceFacility_type_info = new String[]{'ServiceFacility','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] WOLine_type_info = new String[]{'WOLine','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] WONumber_type_info = new String[]{'WONumber','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VIN','ServiceFacility','WOLine','WONumber'};
    }
    public class createVCAN_Input {
        public Nna360VCAN2MasterServiceSoap.VCANDetails vcanDetails;
        public String Hb_User;
        public String Hb_Password;
        private String[] vcanDetails_type_info = new String[]{'vcanDetails','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] Hb_User_type_info = new String[]{'Hb_User','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Hb_Password_type_info = new String[]{'Hb_Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'}; 
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'vcanDetails','Hb_User','Hb_Password'};
    }
    public class updateVCAN_Input {
        public Nna360VCAN2MasterServiceSoap.VCANDetails vcanDetails;
        public String Hb_User;
        public String Hb_Password;
        private String[] vcanDetails_type_info = new String[]{'vcanDetails','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] Hb_User_type_info = new String[]{'Hb_User','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Hb_Password_type_info = new String[]{'Hb_Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'}; 
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'vcanDetails','Hb_User','Hb_Password'};
    }
    public class deleteVCAN_Input {
        public Nna360VCAN2MasterServiceSoap.vcanQueryData VCANQuery;
        public String Hb_User;
        public String Hb_Password;
        private String[] VCANQuery_type_info = new String[]{'VCANQuery','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] Hb_User_type_info = new String[]{'Hb_User','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Hb_Password_type_info = new String[]{'Hb_Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'}; 
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VCANQuery','Hb_User','Hb_Password'};
    }
    

    public class viewVCAN_Output {
        public Nna360VCAN2MasterServiceSoap.VCANDetails vcanDetails;
        public String MessageCode;
        public String MessageDescription;
        private String[] vcanDetails_type_info = new String[]{'vcanDetails','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','vcanDetails','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'vcanDetails'};
    }

    public class createVCAN_Output {
        public String VCANRefNumber;
        public String MessageCode;
        public String MessageDescription;
        public Nna360VCAN2MasterServiceSoap.vcanQueryData VCANKeys;
        private String[] VCANKeys_type_info = new String[]{'VCANKeys','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANKeys','0','1','false'};
        private String[] VCANRefNumber_type_info = new String[]{'VCANRefNumber','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] MessageCode_type_info = new String[]{'MessageCode','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] MessageDescription_type_info = new String[]{'MessageDescription','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VCANRefNumber','MessageCode','MessageDescription','VCANKeys'};
    }

    
    public class updateVCAN_Output {
        public String MessageCode;
        public String MessageDescription;
        public Nna360VCAN2MasterServiceSoap.vcanQueryData VCANKeys;
        private String[] VCANKeys_type_info = new String[]{'VCANKeys','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANKeys','0','1','false'};
        private String[] MessageCode_type_info = new String[]{'MessageCode','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] MessageDescription_type_info = new String[]{'MessageDescription','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'MessageCode','MessageDescription','VCANKeys'};
    }
    
    public class deleteVCAN_Output {
        public String MessageCode;
        public String MessageDescription;
        public Nna360VCAN2MasterServiceSoap.vcanQueryData VCANKeys;
        private String[] VCANKeys_type_info = new String[]{'VCANKeys','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','VCANKeys','0','1','false'};
        private String[] MessageCode_type_info = new String[]{'MessageCode','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] MessageDescription_type_info = new String[]{'MessageDescription','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'MessageCode','MessageDescription'};
    }
    public class viewVCANResp {
        public Nna360VCAN2MasterServiceSoap.viewVCAN_Output viewVCANResp;
        private String[] viewVCANResp_type_info = new String[]{'viewVCANResp','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','viewVCANResp','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'viewVCANResp'};

    }
    
    public class createVCANResp {
        public Nna360VCAN2MasterServiceSoap.createVCAN_Output createVCANResp;
        private String[] createVCANResp_type_info = new String[]{'createVCANResp','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'createVCANResp'};
    
    }
    public class updateVCANResp {
        public Nna360VCAN2MasterServiceSoap.updateVCAN_Output updateVCANResp;
        private String[] updateVCANResp_type_info = new String[]{'updateVCANResp','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'updateVCANResp'};
    }
    public class deleteVCANResp {
        public Nna360VCAN2MasterServiceSoap.deleteVCAN_Output deleteVCANResp;
        private String[] deleteVCANResp_type_info = new String[]{'deleteVCANResp','http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'deleteVCANResp'};

    }
    
    public class vcanQueryData {
        public String VIN;
        public String ServiceFacility;
        public String WOLine;
        public String WONumber;
        private String[] VIN_type_info = new String[]{'VIN','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] ServiceFacility_type_info = new String[]{'ServiceFacility','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] WOLine_type_info = new String[]{'WOLine','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] WONumber_type_info = new String[]{'WONumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://na/nissan/com/warranty/LB_WarrantyVCANService/IG_WarrantyVCANService','false','false'};
        private String[] field_order_type_info = new String[]{'VIN','ServiceFacility','WOLine','WONumber'};
    
    }
    
    
    
    
}