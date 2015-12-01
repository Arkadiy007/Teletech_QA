/*
  Page Title: NCIVehicleServiceContractsRest
  Author: Aaron Bessey
  Create Date: 3/25/2015
  Last Update: 3/25/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

@RestResource(urlMapping = '/casl/api/v1/asp/*')
global class NCIVehicleServiceContractsRest {
    global class VehicleServiceContractHandler
    {
        public Long requestId { get; set; }
        public String status { get; set; }
        public String type { get; set; }
        public List<VehicleServiceContract> vehicleServiceContracts { get; set; }
        public ResultHandler result { get; set; }

        public VehicleServiceContractHandler()
        {
            vehicleServiceContracts = new List<VehicleServiceContract>();
            result = new ResultHandler();
        }
        public VehicleServiceContractHandler(Long iRID, String sStatus, String sType)
        {
            requestId = iRID;
            status = sStatus;
            type = sType;
            vehicleServiceContracts = new List<VehicleServiceContract>();
            result = new ResultHandler();
        }
    }

    global class VehicleServiceContract
    {
        public String vinCode { get; set; }
        public String agreementNumber { get; set; }
        public String actionCode { get; set; }
        public String applicationDate { get; set; }
        public String applicationNumber { get; set; }
        public String cancelDate { get; set; }
        public Decimal cancelAmount { get; set; }
        public String cancelReason { get; set; }
        public Integer cancelOdometer { get; set; }
        public String agreementType { get; set; }
        public String trackingNumber { get; set; }
        public String customerAddress { get; set; }
        public String customerCity { get; set; }
        public String customerEmail { get; set; }
        public String customerFirstName { get; set; }
        public String customerLastName { get; set; }
        public String customerMiddleName { get; set; }
        public String refundAmount { get; set; }
        public String customerHomePhone { get; set; }
        public String customerWorkPhone { get; set; }
        public String customerProvince { get; set; }
        public String customerPostalCode { get; set; }
        public String dealerName { get; set; }
        public String dealerNetAmount { get; set; }
        public String dealerCode { get; set; }
        public String dealerProvince { get; set; }
        public String deductibleAmount { get; set; }
        public String startDate { get; set; }
        public String endDate { get; set; }
        public integer endOdometer { get; set; }
        public String lienHolderName { get; set; }
        public integer startOdometer { get; set; }
        public String planCode { get; set; }
        public String planDuration { get; set; }
        public String planType { get; set; }
        public Decimal customerPriceAmount { get; set; }
        public String transferDate { get; set; }
        public String vehicleValue { get; set; }
    }

    global class ResultHandler
    {
        public integer code { get; set; }
        public string message { get; set; }
    }

    @HttpGet
    global static VehicleServiceContractHandler getVSCs()
    {
        VehicleServiceContractHandler vsch = new VehicleServiceContractHandler();
        vsch.requestId = 1234567890; //123456800;
        vsch.status = 'success';
        vsch.type = 'Response';
        vsch.result.code = 200;
        vsch.result.message = 'test message';

        String vinCode = RestContext.request.params.get('vinCode');

        List <Vehicle_Service_Contract__c> vehicleServiceContracts = [Select Id, Name,
                                                                      Action_Code__c,
                                                                      Added_Date__c,
                                                                      Application_Number__c,
                                                                      Batch_Date__c,
                                                                      Batch_Number__c,
                                                                      Batch_Status__c,
                                                                      Cancel_Date__c,
                                                                      Cancel_Effective_Date__c,
                                                                      Cancel_Fee__c,
                                                                      Cancellation_Reason__c,
                                                                      Cancel_Mileage__c,
                                                                      CancelMileage__c,
                                                                      Cancel_Refund_Percent__c,
                                                                      Cancel_Requested_By__c,
                                                                      ContractTypeTranslated__c,
                                                                      Contract_Type__c,
                                                                      Account_Id__c,
                                                                      CustomerName__c,
                                                                      Customer_Address__c,
                                                                      Customer_City__c,
                                                                      Customer_Email__c,
                                                                      Customer_Middle_Name__c,
                                                                      Customer_Net_Refund__c,
                                                                      CustomerNetRefund__c,
                                                                      Customer_Primary_Phone__c,
                                                                      Customer_Secondary_Phone__c,
                                                                      Customer_State__c,
                                                                      Customer_Zip__c,
                                                                      Dealer__c,
                                                                      Dealer_Net_Refund__c,
                                                                      DealerNetRefund__c,
                                                                      Dealer_Number__c,
                                                                      Dealer_State__c,
                                                                      Deductible_Amount__c,
                                                                      DeductibleDollars__c,
                                                                      Effective_Date__c,
                                                                      Expire_Date__c,
                                                                      Expire_Mileage__c,
                                                                      ExpireMileage__c,
                                                                      Finance_Term__c,
                                                                      Last_Transaction_Date__c,
                                                                      Lienholder_City__c,
                                                                      Lienholder_Name__c,
                                                                      Lienholder_State__c,
                                                                      Lienholder_Street__c,
                                                                      Lienholder_Zip__c,
                                                                      Odometer__c,
                                                                      Oil_Change__c,
                                                                      Owner_Name__c,
                                                                      Paid_to_Date__c,
                                                                      Plan_Code__c,
                                                                      Plan_Term__c,
                                                                      Plan_Type__c,
                                                                      Policy_Number__c,
                                                                      Price_Code__c,
                                                                      Printed_Date__c,
                                                                      Product__c,
                                                                      Program_Code__c,
                                                                      Purchase_Price__c,
                                                                      PurchasePrice__c,
                                                                      Request_Received_Date__c,
                                                                      Source__c,
                                                                      Transaction_Date__c,
                                                                      Transfer_Date__c,
                                                                      Vehicle_Option__c,
                                                                      Vehicle_Price__c,
                                                                      Vehicle_Type__c,
                                                                      VIN__c,
                                                                      Customer_First_Name__c,
                                                                      Customer_Last_Name__c,
                                                                      Vehicle_Id__c,
                                                                      Who_Processed_Cancel__c,
                                                                      Who_Received_Refund__c
                                                                      from Vehicle_Service_Contract__c where vin__c=:vinCode];
        VehicleServiceContract vsc;
        List<VehicleServiceContract> vscs = new List<VehicleServiceContract>();
        for (Vehicle_Service_Contract__c serviceContract : vehicleServiceContracts)
        {
            vsc = new VehicleServiceContract();
            vsc.vinCode = vinCode;
            vsc.actionCode = serviceContract.Action_Code__c;
            vsc.applicationDate = String.valueOfGMT(serviceContract.Added_Date__c);
            vsc.applicationNumber = serviceContract.Application_Number__c;
            vsc.cancelDate = String.valueOfGMT(serviceContract.Cancel_Date__c);
            vsc.cancelAmount = serviceContract.Cancel_Fee__c!=null ? Decimal.valueOf(serviceContract.Cancel_Fee__c):0;
            vsc.cancelReason = serviceContract.Cancellation_Reason__c;
            vsc.cancelOdometer = Integer.valueOf(serviceContract.CancelMileage__c);
            vsc.agreementType = serviceContract.ContractTypeTranslated__c;
            vsc.trackingNumber = serviceContract.CustomerName__c;
            vsc.customerAddress = serviceContract.Customer_Address__c;
            vsc.customerCity = serviceContract.Customer_City__c;
            vsc.customerEmail = serviceContract.Customer_Email__c;
            vsc.customerFirstName = serviceContract.Customer_First_Name__c;
            vsc.customerLastName = serviceContract.Customer_Last_Name__c;
            vsc.customerMiddleName = serviceContract.Customer_Middle_Name__c;
            vsc.refundAmount = serviceContract.Customer_Net_Refund__c;
            vsc.customerHomePhone = serviceContract.Customer_Primary_Phone__c;
            vsc.customerWorkPhone = serviceContract.Customer_Secondary_Phone__c;
            vsc.customerProvince = serviceContract.Customer_State__c;
            vsc.customerPostalCode = serviceContract.Customer_Zip__c;
            vsc.dealerName = serviceContract.Dealer__c;
            vsc.dealerNetAmount = serviceContract.Dealer_Net_Refund__c;
            vsc.dealerCode = serviceContract.Dealer_Number__c;
            vsc.dealerProvince = serviceContract.Dealer_State__c;
            vsc.deductibleAmount = serviceContract.Deductible_Amount__c;
            vsc.startDate = String.valueOfGMT(serviceContract.Effective_Date__c);
            vsc.endDate = String.valueOfGMT(serviceContract.Expire_Date__c);
            vsc.endOdometer = Integer.valueOf(serviceContract.ExpireMileage__c);
            vsc.lienHolderName = serviceContract.Lienholder_Name__c;
            vsc.startOdometer = serviceContract.Odometer__c!=null ? Integer.valueOf(serviceContract.Odometer__c): 20000;
            vsc.planCode = serviceContract.Plan_Code__c;
            vsc.planDuration = serviceContract.Plan_Term__c;
            vsc.planType = serviceContract.Plan_Type__c;
            vsc.agreementNumber = serviceContract.Policy_Number__c;
            vsc.customerPriceAmount = serviceContract.PurchasePrice__c;
            vsc.transferDate = String.valueOfGMT(serviceContract.Transfer_Date__c);
            vsc.vehicleValue = serviceContract.Vehicle_Price__c;

            vscs.add(vsc);
        }
        
        vsch.vehicleServiceContracts = vscs;

        return vsch;
    }
}