/*
  Page Title: NCI_VehicleWebService
  Author: Aaron Bessey
  Create Date: 3/23/2015
  Last Update: 3/23/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

public class NCI_VehicleWebService {
    public String vinCode { get; set; }
    public Vehicle__c vehicle { get; set; }
    public String responseJSON { get; set; }
    public String responseJSONVSC { get; set; }
    public Boolean hasRecalls {get; set;}
    public Boolean isAdmin { get; set; }
    private static Datetime lastCalloutTime = System.now().addHours(-1);
    public List<Vehicle_Service_Contract__c> theseVSC {get; set;}
    public List<String> vehicleRecalls {get; set;}
    
    List<Error_Log__c> errors = new List<Error_Log__c>();
    
    public NCI_VehicleWebService(ApexPages.StandardController stdController) {
        vehicle = (vehicle__c) stdController.getRecord();
        theseVSC = new List<Vehicle_Service_Contract__c>();
        
        vehicle = [Select Id, Name,Latest_Recorded_Mileage_Number__c,Retail_Type__c, Body_Style_Code__c,Cylinders_Count__c,Latest_Recorded_Mileage_Units__c,NCI_Wholesale_Date__c,Branded_Title__c,
                   RecordTypeId,Model_Series__c,Model_Line_Series__c,NCI_Model_Code__c,NCI_Model_Name__c,PDI_Date__c,Emissions_Certification__c,
                   Body_Style_Type__c,Option_Group__c,Option_Group_Code__c,Trim_Code__c,
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
        hasRecalls = false;
        vehicleRecalls = new List<String>();
        
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
        
            // vehicle detail
            
            
            
            responseJSON = getVehicleDetail(vinCode);
            responseJSONVSC = getVehicleServiceContract(vinCode);
            System.debug(responseJSONVSC);
        
            System.debug(responseJSON);
            
            NCIVehicleDetailRest.VehicleDetailHandler vdh = (NCIVehicleDetailRest.VehicleDetailHandler) Json.deserialize(responseJSON, NCIVehicleDetailRest.VehicleDetailHandler.Class);
            NCIVehicleDetailRest.VehicleHandler vh = vdh.vehicle;
            
            UpdateExistingVehicle(vh);
            
            //vehicle service contract
            
            if (!responseJSONVSC.contains('202,\"message\":\"Vehicle Service Contract not found\"')) {
            
                NCIVehicleServiceContractsRest.VehicleServiceContractHandler vsch = (NCIVehicleServiceContractsRest.VehicleServiceContractHandler) Json.deserialize(responseJSONVSC, NCIVehicleServiceContractsRest.VehicleServiceContractHandler.Class);
                List<NCIVehicleServiceContractsRest.VehicleServiceContract> vscs = vsch.vehicleServiceContracts;
                theseVSC = UpsertVehicleServiceContract(vscs,vehicle,vincode);
            
            }
            
             Set<String> vins = new Set<String>();
             vins.add(vinCode);
             
             
             Map<String,List<String>> returnMap = Controller_NCIAccountComponentController.vehicleRecalls(vins);
            
            if(returnMap.size() > 0) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Recalls on one or more vehicles:'));
                hasRecalls = true;
                
                for (String vin : returnMap.keySet()){
        
                     List<String> s = returnMap.get(vin);
                     for (String thisRecall: s) {
                         vehicleRecalls.add(thisRecall);
                     }
                     
                                          
                }
                
            }    
            
            
        }
        
        
        
        
        
        catch(Exception ex){
              System.debug(ex);
              errors.add(new Error_Log__c(
                                    Record_Type__c = 'NCI Vehicle', 
                                    Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'NCI Vehicle Webservice System Error', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
           
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There was an error processing your request for vehicle detail.  Please refresh your browser.'));
              if (!errors.isEmpty()) {
            // Insert rows
                    Database.SaveResult[] dbResults = Database.insert(errors, false);
              }
              return null;
             
            
            
            
          
        }
        return null;
    }

    
    public static List<Vehicle_Service_Contract__c> UpsertVehicleServiceContract(List<NCIVehicleServiceContractsRest.VehicleServiceContract> vscs, Vehicle__c veh,String vc) {
        List<Vehicle_Service_Contract__c> vsctoInsert = new List<Vehicle_Service_Contract__c>();
        List<Vehicle_Service_Contract__c> vsctoUpdate = new List<Vehicle_Service_Contract__c>();

        List<Vehicle_Service_Contract__c> insertedVehiclesList = [SELECT Policy_Number__c FROM Vehicle_Service_Contract__c where vehicle_id__c = :veh.id];
        Map<String, Vehicle_Service_Contract__c> insertedVehiclesMap = new Map<String, Vehicle_Service_Contract__c>();

        for(Vehicle_Service_Contract__c v : insertedVehiclesList){
            if (!insertedVehiclesMap.containsKey(v.Policy_Number__c)) {
                insertedVehiclesMap.put(v.Policy_Number__c, v);
            }
        }
        List<Vehicle_Service_Contract__c> thisReturn = new List<Vehicle_Service_Contract__c>();
        Vehicle_Service_Contract__c serviceContract;
        
        Map<String,String> contractTypeMap = new Map<String,String>();
        
        List<NCIContractTypes__c> cts = [select id, agreement_type__c, plan_type__c, description__c from NCIContractTypes__c where Plan_Type__c != null and Agreement_Type__c != null];
        for (NCIContractTypes__c tc : cts) {
            contractTypeMap.put(tc.agreement_type__c+tc.plan_type__c,tc.description__c);
        }
        
        Map<String,String> planCodeMap = new Map<String,String>();       
        Map<String,String> planCodeTypeMap = new Map<String,String>();       
        
        Map<String,String> planCodeFeatures = new Map<String,String>();
        
        String aText = '|  &nbsp;&nbsp;&nbsp;&nbsp;(Applies to contracts sold prior to April 8, 2013 only)';
        String bText = '';
        
        
        List<NCIContractTypes__c> cts2 = [select id, plan_code__c, description__c, plan_code_type__c, Coverage_Component__c,Oil_Chngs_Maint__c, Rental__c, Towing__c, Tire__c, Roadside__c from NCIContractTypes__c where plan_code__c != null];
        for (NCIContractTypes__c tc : cts2) {
            planCodeMap.put(tc.plan_code__c,tc.description__c);
            planCodeTypeMap.put(tc.plan_code__c,tc.plan_code_type__c);
            String sep ='|';
            planCodeFeatures.put(tc.plan_code__c,'<a class=\'jqtooltip\' title=\" ' +
            'Coverage Component: ' + tc.Coverage_Component__c.replace('A',aText) + sep +
            '#Oil Changes/Maint: ' + tc.Oil_Chngs_Maint__c.replace('A',aText)+ sep +   
            'Rental: ' +  tc.Rental__c.replace('A',aText)+ sep + 
            'Towing:' + tc.Towing__c.replace('A',aText)+ sep  + 
            'Tire: ' + tc.Tire__c.replace('A',aText)+ sep  +
            'Roadside: ' +  tc.Roadside__c.replace('A',aText) + '\">'+tc.plan_code__c+'</a>');            
        }
        
        
        
        
        
        
        for(NCIVehicleServiceContractsRest.VehicleServiceContract vsc : vscs){
        serviceContract = new Vehicle_Service_Contract__c();
        serviceContract.Agreement_Type__c = vsc.agreementType;
        if (contractTypeMap.get(vsc.agreementType+vsc.planType) != null) {
            serviceContract.Contract_Type__c = contractTypeMap.get(vsc.agreementType+vsc.planType);
        }
        if (planCodeMap.get(vsc.planCode) != null) {
            serviceContract.Plan_Description__c = planCodeMap.get(vsc.planCode);
            serviceContract.Plan_Features__c = planCodeFeatures.get(vsc.planCode);
            serviceContract.Plan_Code_Type__c = planCodeTypeMap.get(vsc.planCode);
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
        serviceContract.End_Odometer__c = vsc.endOdometer;
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
        thisReturn.add(serviceContract);
        }
        return thisReturn;
        
    }

    
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



    public void UpdateExistingVehicle(NCIVehicleDetailRest.VehicleHandler vh) {
        vehicle.Name = vh.vinCode;
        vehicle.Make_Name__c = vh.make;
        vehicle.Model_Year__c = String.valueOf(vh.modelYear);
        
        vehicle.Model_Line_Code__c = vh.seriesCode;
        vehicle.Model_Line_Name__c = vh.seriesDesc;
        vehicle.Model_Line_Series__c = vh.seriesDesc;
        //vehicle.Model_Code__c = vh.modelCode;
        vehicle.Model_Name__c = vh.modelDesc;
        vehicle.NCI_Model_Code__c = vh.modelCode;
        vehicle.NCI_Model_Name__c = vh.modelDesc;       
         
        //vehicle.Factory_Installed_Options__c = vh.optionGroupDesc;

        vehicle.Option_Group__c = vh.modelOptionGroupDesc;
        
        vehicle.Option_Group_Code__c = vh.optionGroupCode;
       
        vehicle.Exterior_Color_Type__c = vh.colourDesc;
        vehicle.Colour_Code__c = vh.colourCode;
        vehicle.Trim_Type__c = vh.trimCode;
        vehicle.End_Item_Model_Code__c = vh.eimCode;
        vehicle.Vehicle_Type__c = vh.vehicleTypeDesc;
        vehicle.Manufacturer_Date__c = vh.manufactureDate;
        vehicle.Wholesale_Type_Code__c = vh.wholesaleTypeCode;
        //vehicle.Wholesale_Date__c = vh.wholesaleDate;
        vehicle.NCI_Wholesale_Date__c = vh.wholesaleDate;
        //vehicle.In_Service_Date__c = vh.warrantyStartDate;
        vehicle.Warranty_Start_Date__c = vh.warrantyStartDate;        
        vehicle.MSRP_Amount__c = vh.msrpAmount;
        vehicle.Retail_Type_Code__c = vh.originalRetailTypeCode;
        vehicle.Retail_Type__c = vh.originalRetailTypeDesc;
     // vehicle.M_F_Plant__c = vh.manufacturerPlantCode;
        system.debug(vh.vehicleEngineCylinderCount + 'is the cyclinder count');
      
       vehicle.Cylinders_Count__c = vh.vehicleEngineCylinderCount != null && vh.vehicleEngineCylinderCount != '' ? Integer.valueOf(vh.vehicleEngineCylinderCount) : null;
        //vehicle.Body_Style_Type__c = vh.bodyStyleCode;
        vehicle.Body_Style_Code__c = vh.vehicleBodyTypeCode;
     //   vehicle.Emissions_Type__c = vh.emissionsTypeCode;
        //vehicle.Transmission_Type__c = vh.transmissionTypeCode;
        vehicle.Body_Style_Code__c = vh.bodyStyleCode;
      //  vehicle.Emissions_Type_Code__c = vh.emissionsTypeCode;
     //   vehicle.Transmission_Type_Code__c = vh.transmissionTypeCode;
        update vehicle;
    }

    private Boolean IsNullOrEmptyString(String value) {
        if (value != null && value != '') {
            return false;
        }

        return true;
    }

    // Api call for getting vehicle by vin
    public static String getVehicleDetail(String vin) {
           NCIWebServiceSettings__c wsSettings;
           Blob headerValue;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        wsSettings = NCIWebServiceSettings__c.getOrgDefaults();
        req.setTimeout(Integer.valueOf(wsSettings.TimeoutSeconds__c)*1000);
        
        
       
       
        if (wsSettings.useProductionURLs__c) {
            req.setEndpoint(Label.NCI_Vehicle_Detail_Endpoint_PRD + '?vinCode=' + vin);
            headerValue = Blob.valueOf( wsSettings.NCIWSClientUserPrd__c);
            req.setHeader('clientId',System.Label.NCI_Client_IDPRD);
        } else {
            req.setEndpoint(Label.NCI_Vehicle_Detail_Endpoint + '?vinCode=' + vin);
            headerValue = Blob.valueOf( wsSettings.NCIWSClientUserQA__c);
            req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        }
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');

        if (Test.isRunningTest()) {
            return '{"requestId":1234567890123456800,"status":"success","type":"Response","vehicle":{"vinCode":"JN8AS58V18W108734","make":"NISSAN","modelYear":"2008","seriesCode":"Y","seriesDesc":"ROGUE","modelCode":"6SG18","modelDesc":"ROGUE SL AWD","optionGroupCode":"BK00","optionGroupDesc":"SL AWD PREMIUM PACKAGE","colourCode":"A33","colourDesc":"VENETIEN RED","trimCode":"W","eimCode":"FDBNLSZS35ENAA--C-","vehicleTypeName":"Truck","manufactureDate":"2011-06-23","wholesaleTypeCode":"S","wholesaleTypeDesc":"Wholesale","wholesaleDate":"2007-10-23","warrantyStartDate": "2008-05-27","msrpAmount": 33567.00,"retailTypeCode": "O","retailTypeDesc": "RetailSales","manufacturerPlantCode": null,"manufacturerPlantDesc": null,"bodyStyleCode": null,"bodyStyleDesc": null,"emissionsTypeCode": null,"emissionsTypeDesc": null,"transmissionTypeCode": null,"transmissionTypeDesc": null},"result": {"code": 200,"message": "success"}}';
        } else {
            HttpResponse res = h.send(req);
           System.debug('testing');
           System.debug(res.getBody());
           return res.getBody();
        }

        // Send the request, and return a response
    }
}