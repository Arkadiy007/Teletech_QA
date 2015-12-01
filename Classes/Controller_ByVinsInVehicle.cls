/**********************************************************************
Name: Controller_ByVinsInVehicle
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of ByVINsInVehicle page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 01/16/2012 Created
***********************************************************************/
public class Controller_ByVinsInVehicle {
    public String ResponseOutput { get; set; }
    private List<Vehicle_Ownership_History__c> vehicle;
    private Vehicle__c inputVehicle;
    
    public Controller_ByVinsInVehicle(ApexPages.StandardController controller) {
        inputVehicle = [Select ID, 
                            Vehicle_identification_Number__c, 
                            Last_Claim_Retrieve_Date__c,
                            Last_Recall_Retrieve_Date__c,
                            Last_RepairOrder_Retrieve_Date__c,
                            Last_VSC_Retrieve_Date__c
                        From Vehicle__c 
                        where ID =: controller.getRecord().ID];
        
        vehicle = [Select Owner__c, 
                            Vehicle__c, 
                            Primary_Owner_Indicator__c, 
                            Original_Owner_Indicator__c, 
                            Claimed_Owner_Indicator__c, 
                            Current_Owner_Indicator__c
                        From Vehicle_Ownership_History__c
                        Where Vehicle__c =: controller.getRecord().ID];
    }
    
    public PageReference doSearch() {
        ResponseOutput = '';
        Boolean updateVehicle = false;
        
        String vin = inputVehicle.Vehicle_identification_Number__c;
        if (vin != null && vin.length() != 0) {
            List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
            List<Vehicle_Recall__c> VRs = new List<Vehicle_Recall__c>();
            List<Service_Repair_History__c> ROs = new List<Service_Repair_History__c>();
            List<Vehicle_Service_Contract__c> VSCs = new List<Vehicle_Service_Contract__c>();       
            List<Generic_Text__c> wsComments = new List<Generic_Text__c>();
            List<Warranty_Information__c> WRTs = new List<Warranty_Information__c>();
            Boolean CL = false;
            Boolean RC = false;
            Boolean RO = false;
            Boolean VSC = false;
            //Boolean WI = false;
            
            //preparing ***************************
            ResponseOutput = 'Vehicle ' + vin + '.';
            
    //Web Services ========================================
    
            Id profileId=userinfo.getProfileId();
            Profile profileName = [Select Id,Name from Profile where id=:profileId];
            //system.debug('ProfileName'+profileName.name);
            Boolean runClaimAnyway = false;
            String theseProfiles = System.label.Warranty_Claim_Override_Profiles;
            String[] profiles = theseProfiles.split(',');
            
            if (profiles.size() > 0) { 
                  for (String p : profiles) {
                    if (profileName.name == p) { runClaimAnyway = true; }
                  }
            }
            
            //Claim call-out  ***************************
            if (!Text_Util.isSameDay(inputVehicle.Last_Claim_Retrieve_Date__c) || runClaimAnyway) {
                Map<String, ID> mapVINs = new Map<String, ID>();
                mapVINs.put(vin, inputVehicle.ID);
                try {
                    Controller_ByVinsInAccount_Claims.callout(mapVINs, SRHs);
                    CL = true;
                } catch (CalloutException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Claims CalloutException ' + ex.getMessage() + '.';
                }
            }
            
            //Recall call-out ***************************
            if (!Text_Util.isSameDay(inputVehicle.Last_Recall_Retrieve_Date__c)) {
                Map<String, ID> mapVINs = new Map<String, ID>();
                mapVINs.put(vin, inputVehicle.ID);
                try {
                    Controller_ByVinsInAccount_Recalls.callout(mapVINs, VRs);
                    RC = true;
                } catch (CalloutException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Recalls CalloutException ' + ex.getMessage() + '.';
                }
            }

            //Repair Order call-out ***************************
            if (!Text_Util.isSameDay(inputVehicle.Last_RepairOrder_Retrieve_Date__c)) {
                Map<String, ID> mapVINs = new Map<String, ID>();
                mapVINs.put(vin, inputVehicle.ID);
                try {
                    Controller_ByVinsInAccount_RepairOrders.callout(mapVINs, ROs);
                    RO = true;
                } catch (Controller_ByVinsInAccount_RepairOrders.NNACalloutException ex) {
                    ResponseOutput = ResponseOutput + 'Repair Orders NNACalloutException ' + ex.getMessage() + '.';
                } catch (CalloutException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Repair Orders CalloutException ' + ex.getMessage() + '.';
                }
            }
        
            //VSC call-out ***************************
            if (!Text_Util.isSameDay(inputVehicle.Last_VSC_Retrieve_Date__c)) {
                Map<String, ID> mapVINs = new Map<String, ID>();
                mapVINs.put(vin, inputVehicle.ID);
                //collect vins and owners - VSC requires to populate AccountID
                Map<String, Vehicle_Ownership_History__c> mapOwners = new Map<String, Vehicle_Ownership_History__c>();
                if (vehicle.size() > 0)
                    mapOwners.put(vin, vehicle[0]);
                try {
                    Controller_ByVinsInAccount_VSC.callout(mapVINs, mapOwners, VSCs, wsComments);
                    VSC = true;
                } catch (CalloutException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts CalloutException ' + ex.getMessage() + '.';
                }
            }
            
            //Warranty call-out ***************************
           /* if (!Text_Util.isSameDay(inputVehicle.Last_Warranty_Retrieve_Date__c)) {
                Map<String, ID> mapVINs = new Map<String, ID>();
                mapVINs.put(vin, inputVehicle.ID);
                try {
                    Controller_ByVinsInAccount_Warranties.callout(mapVINs, WRTs);
                    WI = true;
                } catch (CalloutException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Warranties CalloutException ' + ex.getMessage() + '.';
                }
            }*/
            
    //DML ========================================
            
            //Claim upsert ***************************
            try {
                if (CL) {
                    Controller_ByVinsInAccount_Claims.dmlOperations(SRHs);
                    inputVehicle.Last_Claim_Retrieve_Date__c = datetime.now();
                    updateVehicle = true;
                }
            } catch (DMLException ex) {
                ResponseOutput = ResponseOutput + ' Status: Claims DMLException ' + ex.getMessage() + '.';
                CL = false;
            }
            
            //Recall upsert ***************************
            try {
                if (RC) {
                    Controller_ByVinsInAccount_Recalls.dmlOperations(VRs);
                    inputVehicle.Last_Recall_Retrieve_Date__c = datetime.now();
                    updateVehicle = true;
                }
            } catch (DMLException ex) {
                ResponseOutput = ResponseOutput + ' Status: Recalls DMLException ' + ex.getMessage() + '.';
                RC = false;
            }

        //Repair Order upsert ***************************
            try {
                if (RO) {
                    Controller_ByVinsInAccount_RepairOrders.dmlOperations(ROs);
                    inputVehicle.Last_RepairOrder_Retrieve_Date__c = datetime.now();
                    updateVehicle = true;
                }
            } catch (DMLException ex) {
                ResponseOutput = ResponseOutput + ' Status: Repair Orders DMLException ' + ex.getMessage() + '.';
                RO = false;
            }
            
            //VSC upsert ***************************
            try {
                if (VSC) {
                    Controller_ByVinsInAccount_VSC.dmlOperations(VSCs, wsComments);
                    inputVehicle.Last_VSC_Retrieve_Date__c = datetime.now();
                    updateVehicle = true;
                }
            } catch (DMLException ex) {
                ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts  DMLException ' + ex.getMessage() + '.';
                VSC = false;
            }
            //Warrranty upsert ***************************
            /*try {
                if (WI) { 
                    Controller_ByVinsInAccount_Warranties.dmlOperations(WRTs);
                    inputVehicle.Last_Warranty_Retrieve_Date__c = datetime.now();
                    updateVehicle = true;
                }
            } catch (DMLException ex) {
                ResponseOutput = ResponseOutput + ' Status: Warranties DMLException ' + ex.getMessage() + '.';
                WI = false;
            }*/
    
    //Update Vehicle Last Retrieve Date ========================================
            if (updateVehicle == true) {
                try {
                    update inputVehicle;
    
                    if (CL && RC && RO && VSC)
                        ResponseOutput = ResponseOutput + ' Status: Successful.';
                } catch (DMLException ex) {
                    ResponseOutput = ResponseOutput + ' Status: Update Vehicle DMLException ' + ex.getMessage() + '.';
                }
            }
        }
        
        return null;
    }    
   
}