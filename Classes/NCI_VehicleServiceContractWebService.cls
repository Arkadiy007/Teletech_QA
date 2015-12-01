/*
  Page Title: NCI_VehicleServiceContractWebService
  Author: Aaron Bessey
  Create Date: 3/25/2015
  Last Update: 3/25/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

public class NCI_VehicleServiceContractWebService {
    public String vinCode { get; set; }
    public Vehicle__c vehicle { get; set; }
    public String responseJSON { get; set; }
    public Boolean isAdmin { get; set; }
    private static Datetime lastCalloutTime = System.now().addHours(-1);
    
    
    public NCI_VehicleServiceContractWebService(ApexPages.StandardController stdController) {
        vehicle = (vehicle__c) stdController.getRecord();

        vehicle = [Select Id, Name,
                   RecordTypeId,
                   Body_Style_Type__c,
                   Trim_Type__c,
                   Manufacturer_Date__c,
                   Exterior_Color_Type__c,
                   Fleet_Sales_Type_Code__c,
                   Company_Vehicle_Indicator__c,
                   Drive_Train_Type__c,
                   Factory_Installed_Options__c,
                   M_F_Plant__c,
                   Model_Line_Code__c,
                   Model_Line_Name__c,
                   Emissions_Type__c,
                   Transmission_Type__c,
                   Trim_Level_Type__c,
                   Vehicle_Type__c,
                   Wholesale_Type_Code__c,
                   In_Service_Date__c,
                   MSRP_Amount__c,
                   Make_Name__c,
                   Model_Code__c,
                   Model_Name__c,
                   Model_Year__c,
                   Sales_Type_Code__c,
                   End_Item_Model_Code__c,
                   Vehicle_identification_Number__c,
                   Wholesale_Date__c,
                   Make_Model__c from Vehicle__c where id = :vehicle.Id limit 1];
        vinCode = vehicle.Name; 

        
        checkThatUserHasAdministratorProfile();
    }

    private void checkThatUserHasAdministratorProfile(){
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where id=:profileId].Name;

        if(profileName == 'System Administrator'){
            isAdmin = true;
        }
        else{
            isAdmin = false;
        }
    }

    public pageReference initialize()
    {
        try{
        responseJSON = getVehicleServiceContract(vinCode);
        System.debug(responseJSON);
        
        //if(lastCalloutTime.addMinutes(6) <= System.now()){

        NCIVehicleServiceContractsRest.VehicleServiceContractHandler vsch = (NCIVehicleServiceContractsRest.VehicleServiceContractHandler) Json.deserialize(responseJSON, NCIVehicleServiceContractsRest.VehicleServiceContractHandler.Class);
        List<NCIVehicleServiceContractsRest.VehicleServiceContract> vscs = vsch.vehicleServiceContracts;

        UpsertVehicleServiceContract(vscs,vehicle,vincode);

        //}
        }
        catch(Exception ex){
        System.debug(ex.getMessage() + ex.getLineNumber());
        
        }
        return null;
    }


    public static void UpsertVehicleServiceContract(List<NCIVehicleServiceContractsRest.VehicleServiceContract> vscs, Vehicle__c veh,String vc) {
        List<Vehicle_Service_Contract__c> vsctoInsert = new List<Vehicle_Service_Contract__c>();
        List<Vehicle_Service_Contract__c> vsctoUpdate = new List<Vehicle_Service_Contract__c>();

        List<Vehicle_Service_Contract__c> insertedVehiclesList = [SELECT Policy_Number__c FROM Vehicle_Service_Contract__c where vehicle_id__c = :veh.id];
        Map<String, Vehicle_Service_Contract__c> insertedVehiclesMap = new Map<String, Vehicle_Service_Contract__c>();

        for(Vehicle_Service_Contract__c v : insertedVehiclesList){
            if (!insertedVehiclesMap.containsKey(v.Policy_Number__c)) {
                insertedVehiclesMap.put(v.Policy_Number__c, v);
            }
        }

        Vehicle_Service_Contract__c serviceContract;
        
        Map<String,String> contractTypeMap = new Map<String,String>();
        
        List<NCIContractTypes__c> cts = [select id, agreement_type__c, plan_type__c, description__c from NCIContractTypes__c where Plan_Type__c != null and Agreement_Type__c != null];
        for (NCIContractTypes__c tc : cts) {
            contractTypeMap.put(tc.agreement_type__c+tc.plan_type__c,tc.description__c);
        }
        
        Map<String,String> planCodeMap = new Map<String,String>();       
        Map<String,String> planCodeFeatures = new Map<String,String>();
             
        List<NCIContractTypes__c> cts2 = [select id, plan_code__c, description__c, plan_code_type__c, Coverage_Component__c,Oil_Chngs_Maint__c, Rental__c, Towing__c, Tire__c, Roadside__c from NCIContractTypes__c where plan_code__c != null];
        for (NCIContractTypes__c tc : cts2) {
            planCodeMap.put(tc.plan_code__c,tc.description__c);
            planCodeFeatures.put(tc.plan_code__c,tc.Coverage_Component__c+ ',' +tc.Oil_Chngs_Maint__c+ ',' + tc.Rental__c+ ',' + tc.Towing__c+ ',' + tc.Tire__c+ ',' + tc.Roadside__c);            
        }
        
        
        
        
        
        
        for(NCIVehicleServiceContractsRest.VehicleServiceContract vsc : vscs){
        serviceContract = new Vehicle_Service_Contract__c();
        serviceContract.Agreement_Type__c = vsc.agreementType;
        if (contractTypeMap.get(vsc.agreementType+vsc.planType) != null) {
            serviceContract.Contract_Type__c = contractTypeMap.get(vsc.agreementType+vsc.planType);
        }
        if (planCodeMap.get(vsc.planCode) != null) {
            serviceContract.Plan_Description__c = planCodeMap.get(vsc.planCode);
        }
        if (planCodeFeatures.get(vsc.planCode) != null) {
            serviceContract.Plan_Features__c = planCodeFeatures.get(vsc.planCode);
        }

        
        serviceContract.Action_Code__c = vsc.actionCode;
        serviceContract.Added_Date__c = vsc.applicationDate == '' || vsc.applicationDate == null ? null : Date.valueOf(vsc.applicationDate);
        serviceContract.Application_Number__c = vsc.applicationNumber;
        serviceContract.Cancel_Date__c = vsc.cancelDate == '' || vsc.cancelDate == null ? null : Date.valueOf(vsc.cancelDate);
        serviceContract.Cancel_Fee__c = String.valueOf(vsc.cancelAmount);
        serviceContract.Cancellation_Reason__c = vsc.cancelReason;
        serviceContract.Customer_Address__c = vsc.customerAddress;
        serviceContract.Customer_City__c = vsc.customerCity;
        serviceContract.Customer_Email__c = vsc.customerEmail;
        serviceContract.Customer_First_Name__c = vsc.customerFirstName;
        serviceContract.Customer_Last_Name__c = vsc.customerLastName;
        serviceContract.Customer_Middle_Name__c = vsc.customerMiddleName;
        serviceContract.Customer_Net_Refund__c = vsc.refundAmount;
        serviceContract.Customer_Primary_Phone__c = vsc.customerHomePhone;
        serviceContract.Customer_Secondary_Phone__c = vsc.customerWorkPhone;
        serviceContract.Customer_State__c = vsc.customerProvince;
        serviceContract.Customer_Zip__c = vsc.customerPostalCode;
        //serviceContract.Dealer__c = vsc.dealerName;
        serviceContract.Dealer_Net_Refund__c = vsc.dealerNetAmount;
        serviceContract.Dealer_Number__c = vsc.dealerCode;
        serviceContract.Dealer_State__c = vsc.dealerProvince;
        serviceContract.Deductible_Amount__c = vsc.deductibleAmount;
        serviceContract.Effective_Date__c = vsc.startDate == '' || vsc.startDate == null ? null : Date.valueOf(vsc.startDate);
        serviceContract.Expire_Date__c = vsc.endDate == '' || vsc.endDate == null ? null : Date.valueOf(vsc.endDate);
        serviceContract.Lienholder_Name__c = vsc.lienHolderName;
        serviceContract.Odometer__c = String.valueOf(vsc.startOdometer);
        serviceContract.Plan_Code__c = vsc.planCode;
        serviceContract.Plan_Term__c = vsc.planDuration;
        serviceContract.Plan_Type__c = vsc.planType;
        serviceContract.Policy_Number__c = vsc.agreementNumber;
        serviceContract.Transfer_Date__c = vsc.transferDate == '' || vsc.transferDate == null ? null : Date.valueOf(vsc.transferDate);
        serviceContract.Vehicle_Price__c = vsc.vehicleValue;
        serviceContract.Vehicle_Id__c = veh.id;
        serviceContract.VIN__c=vc;
        
        if(insertedVehiclesMap.containsKey(vsc.agreementNumber)){
            serviceContract.id = insertedVehiclesMap.get(vsc.agreementNumber).id;
            update serviceContract;
        }
        else{
            insert serviceContract;
        }
        }
    }

    private Boolean IsNullOrEmptyString(String value) {
        if (value != null && value != '') {
            return false;
        }

        return true;
    }

    // Api call for getting vehicle by vin
    public static String getVehicleServiceContract(String vin) {

        lastCalloutTime = System.now();
        NCIWebServiceSettings__c wsSettings;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        wsSettings = NCIWebServiceSettings__c.getOrgDefaults();
        req.setTimeout(Integer.valueOf(wsSettings.TimeoutSeconds__c)*1000);
        
        Blob headerValue;
        
        if (wsSettings.useProductionURLs__c) {
            req.setEndpoint(Label.NCI_VSC_Endpoint_Prd + '&vinCode=' + vin);
            headerValue = Blob.valueOf( wsSettings.NCIWSClientUserPrd__c);
            req.setHeader('clientId',System.Label.NCI_Client_IDPRD);
        } else {
            req.setEndpoint(Label.NCI_VSC_Endpoint + '&vinCode=' + vin);
            headerValue = Blob.valueOf( wsSettings.NCIWSClientUserQA__c);
            req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        }
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        req.setMethod('GET');
        System.DEBUG(req);
        String resp = '';
        
        // Send the request, and return a response
        if (Test.isRunningTest()) {
             resp = '{"vehicleServiceContracts":[{"vinCode":"1Nb432s","vehicleValue":null,"transferDate":null,"trackingNumber":null,"startOdometer":20000,"startDate":"2014-11-26","refundAmount":null,"planType":null,"planDuration":null,"planCode":null,"lienHolderName":null,"endOdometer":null,"endDate":"2015-11-26","deductibleAmount":null,"dealerProvince":null,"dealerNetAmount":null,"dealerName":null,"dealerCode":null,"customerWorkPhone":null,"customerProvince":null,"customerPriceAmount":null,"customerPostalCode":null,"customerMiddleName":null,"customerLastName":null,"customerHomePhone":null,"customerFirstName":null,"customerEmail":null,"customerCity":null,"customerAddress":null,"cancelReason":null,"cancelOdometer":null,"cancelDate":null,"cancelAmount":0,"applicationNumber":null,"applicationDate":"2014-11-26","agreementType":null,"agreementNumber":"PLNL90260357","actionCode":"P"},{"vinCode":"1Nb432s","vehicleValue":"49750","transferDate":null,"trackingNumber":"LOWINN KIBBEY","startOdometer":150,"startDate":"2014-09-06","refundAmount":"0","planType":"D","planDuration":"048","planCode":"ZND02","lienHolderName":null,"endOdometer":40150,"endDate":"2018-09-06","deductibleAmount":"0","dealerProvince":"NJ","dealerNetAmount":"0","dealerName":null,"dealerCode":"70520","customerWorkPhone":null,"customerProvince":"FL","customerPriceAmount":509.00,"customerPostalCode":"32092","customerMiddleName":null,"customerLastName":"KIBBEY","customerHomePhone":null,"customerFirstName":"LOWINN","customerEmail":null,"customerCity":"SAINT AUGUSTINE","customerAddress":"1556 DRURY CT","cancelReason":null,"cancelOdometer":150,"cancelDate":null,"cancelAmount":0,"applicationNumber":"10007022","applicationDate":"2014-10-16","agreementType":null,"agreementNumber":"MZND10007022","actionCode":null}],"type":"Response","status":"success","result":{"message":"test message","code":200},"requestId":1234567890}';
        } else {
            HttpResponse res = h.send(req);
            resp = res.getBody();
        }

        return resp;

    }
}