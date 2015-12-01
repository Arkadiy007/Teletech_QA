/**********************************************************************
Name: Controller_ByVinsInAccount_RepairOrders
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Call repair orders web service, and updates Service_Repair_History__c info by given a set of VINs
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 	12/23/2011 Created
***********************************************************************/
/*
	nnainfowebservicesComMFServices.SessionHeader_element objSession = new nnainfowebservicesComMFServices.SessionHeader_element();
	objSession.sessionId = userInfo.getSessionID();
	nnainfowebservicesComMFServices.NNAMFServiceSoap service = new nnainfowebservicesComMFServices.NNAMFServiceSoap();
	service.SessionHeader = objSession;
	//service.endpoint_x = 'http://www.postbin.org/15jbvo7';
	service.clientCertName_x = System.label.NNA360_Client_Cert;
	List<String> listVINs = new String[] {'1N6AD0EV5AC446848'};
	nnainfowebservicesComMFServices.SVC_WO_T[] wos = service.getWorkOrdersByVIN(listVINs);
	nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap svr = new nnainfowebservicesComCieservicesNna36.NNA360ServiceSoap(); 
	svr.endpoint_x = 
	//svr.clientCertName_x = System.label.NNA360_Client_Cert;
	nnainfowebservicesComCieservicesNna36.CustomerResponse response = svr.GetCustomer('131186590');
	System.Debug(response);

    Nna360RepairOrderServiceSoap.RepairOrderSoap service = new Nna360RepairOrderServiceSoap.RepairOrderSoap();
    service.endpoint_x = 'https://nissanstage.loyaltysite.com/cieservices/NNA360s/Vehicle/RepairOrder.asmx';
    service.endpoint_x = 'https://nnainfowebservices.com/CIEServices/nna360s/vehicle/repairorder.asmx';
	service.endpoint_x = 'https://NissanStage.LoyaltySite.com/cieservices/NNA360s/Vehicle/RepairOrder.asmx';
    
    service.clientCertName_x = System.label.NNA360_Client_Cert;
    Nna360RepairOrderServiceSoap.ArrayOfString listVins = new Nna360RepairOrderServiceSoap.ArrayOfString();
    listVins.string_x = new List<String> {'3N1AB61E77L710234'};
    
	System.Debug('*** Repair Order before ' + service);
	System.Debug('*** Repair Order listVins ' + listVins.string_x);
    Nna360RepairOrderServiceSoap.RepairOrderResponse response = service.GetRepairOrdersByVIN(listVins);
    System.Debug('*** Repair Order response ' + response);
    
    delete [select id from case where record_number__c <> null limit 10000];
    
Nna360RepairOrderServiceSoap.RepairOrderSoap service = new Nna360RepairOrderServiceSoap.RepairOrderSoap();
service.endpoint_x = 'https://NissanStage.LoyaltySite.com/CIEServices/NNA360/NNA360Service.asmx';

Nna360RepairOrderServiceSoap.ServiceAuthHeader header = new Nna360RepairOrderServiceSoap.ServiceAuthHeader();
header.UserName = 'TeleTechStage';
header.Password = 'qe4pu;pbezelcarlye0a';
service.ServiceAuthHeader = header;

Nna360RepairOrderServiceSoap.ArrayOfString listVins = new Nna360RepairOrderServiceSoap.ArrayOfString();
listVins.string_x = new List<String> {'3N1AB61E77L710234'};

System.Debug('*** Repair Order before ' + service);
System.Debug('*** Repair Order listVins ' + listVins.string_x);
Nna360RepairOrderServiceSoap.RepairOrderResponse response = service.GetRepairOrdersByVIN(listVins);
System.Debug('*** Repair Order response ' + response);
*/
public class Controller_ByVinsInAccount_RepairOrders {
    public static void callout(Map<String, ID> mapVINs, List<Service_Repair_History__c> ROs) {
        Nna360RepairOrderServiceSoap.RepairOrderSoap service = new Nna360RepairOrderServiceSoap.RepairOrderSoap();
        //service.endpoint_x = 'https://www.postbin.org/15jbvo7';
        //service.clientCertName_x = System.label.NNA360_Client_Cert;
		
		Nna360RepairOrderServiceSoap.ServiceAuthHeader header = new Nna360RepairOrderServiceSoap.ServiceAuthHeader();
		header.UserName = system.label.Nna360_RepairOrder_UserName;
		header.Password = system.label.Nna360_RepairOrder_Password;
		service.ServiceAuthHeader = header;
		
        Nna360RepairOrderServiceSoap.ArrayOfString listVins = new Nna360RepairOrderServiceSoap.ArrayOfString();
        listVins.string_x = new List<String> (mapVINs.keySet());
        
		System.Debug('*** Repair Order before ' + service);
		System.Debug('*** Repair Order listVins ' + listVins.string_x);
        Nna360RepairOrderServiceSoap.RepairOrderResponse response;
        if (Test.isRunningTest())
        	response = mockRepairOrderResponse();
        else
        	response = service.GetRepairOrdersByVIN(listVins);
        System.Debug('*** Repair Order response ' + response);
        
        if (response.Status != 'Success')
            throw new NNACalloutException('Error in retrieving Repair Orders: ' + response.Status + ' - ' + response.Message);
        
        List<String> dealerCodes = new List<String>();
        List<String> customerIds = new List<String>();
        Map<String, Integer> mapOpSeq = new Map<String, Integer>();
        
        Nna360RepairOrderServiceSoap.ArrayOfVehicle vehicleArray = response.Vehicles;
        Nna360RepairOrderServiceSoap.Vehicle[] vehicles = vehicleArray.Vehicle;        
       	if (vehicles == null || vehicles.size() == 0)
       		return;
       	
        for (Nna360RepairOrderServiceSoap.Vehicle v : vehicles) {
            //Vehicle_ID__c is required
        	if (!mapVINs.containsKey(v.Vin)) 
        		continue;
        	
            Nna360RepairOrderServiceSoap.ArrayOfRepairOrder repairOrderArray = v.RepairOrders;
            Nna360RepairOrderServiceSoap.RepairOrder[] repairOrders = repairOrderArray.RepairOrder;
           	if (repairOrders == null || repairOrders.size() == 0)
           		continue;
            
            for (Nna360RepairOrderServiceSoap.RepairOrder r : repairOrders) {
                Nna360RepairOrderServiceSoap.ArrayOfOpCode opCodeArray = r.Details;
                Nna360RepairOrderServiceSoap.OpCode[] opCodes = opCodeArray.OpCode;
                //will not accept any repairorder without opcode
                if (opCodes == null || opCodes.size() == 0)
                	continue;
                
                Service_Repair_History__c srh = new Service_Repair_History__c();
                srh.WS_SRH_Record_Type__c = 'Repair Order';
                
                //Dealer_Repair_Order_Number__c is required for upserting
                srh.Dealer_Repair_Order_Number__c = r.Number_x;                
                srh.Vehicle_Identification_Number__c = v.VIN;
                srh.Vehicle_ID__c = mapVINs.get(srh.Vehicle_Identification_Number__c);
                
                srh.Contact_Id__c = r.ContactId.Trim();
                if (srh.Contact_Id__c.length() > 0)
                	customerIds.add(srh.Contact_Id__c);
                srh.CDIID__c = r.CDIID;
                srh.Claim_Customer_First_Name__c = Text_Util.TruncateString(r.FirstName, 20);
                srh.Claim_Customer_Middle_Intial__c = r.MiddleInit;
                srh.Claim_Customer_Last_Name__c = r.LastName;
                srh.Claim_Customer_Street_Address1__c = r.Line1;
                srh.Claim_Customer_Street_Address2__c = r.Line2;
                srh.Claim_Customer_City__c = r.City;
                srh.Claim_Customer_State_Province__c = r.State;
                srh.Claim_Customer_Zip__c = r.Zip;
                srh.Claim_Customer_Phone__c = r.HomePhone;
                srh.Claim_Customer_Work_Phone__c = r.WorkPhone;
                srh.Claim_Customer_Email_Address__c = r.EmailAddress;
                srh.Domain_Id__c = r.DomainId;
                srh.Vehicle_Repair_Close_Date__c = Text_Util.MMDDCCYYtoDateTime(r.CloseDate);
                srh.Vehicle_Mileage_Number__c = Text_Util.DecimalValueOf(r.Mileage);
                srh.Parts_Amount__c = r.PartsAmount; 
                srh.Labor_Amount__c = r.LaborAmount;
                srh.Repair_Order_Total_Amount__c = r.TotalAmount;
                srh.Customer_Name_Type__c = r.CustNameType;
                srh.Total_Customer_Labor_Amount__c = r.CustLaborAmount;
                srh.Total_Customer_Parts_Amount__c = r.CustPartsAmount;
                srh.Total_Customer_Misc_Amount__c = r.CustMiscAmount;
                srh.Total_Warranty_Labor_Amount__c = r.WarrantyLaborAmount;
                srh.Total_Warranty_Parts_Amount__c = r.WarrantyPartsAmount;
                srh.Total_Warranty_Misc_Amount__c = r.WarrantyMiscAmount;
                srh.Total_Internal_Labor_Amount__c = r.InternalLaborAmount;
                srh.Total_Internal_Parts_Amount__c = r.InternalPartsAmount;
                srh.Total_Internal_Misc_Amount__c = r.InternalMiscAmount;
                srh.Dealer_Number__c = r.DealerCode.Trim();
                if (srh.Dealer_Number__c.length() > 0)
                	dealerCodes.add(srh.Dealer_Number__c);
               	
                for (Nna360RepairOrderServiceSoap.OpCode o : opCodes) {
                	Service_Repair_History__c srh1 = srh.clone();
                	
                	String partKey = r.DealerCode + '_' + r.Number_x + '_' + v.VIN + '_' + o.Code + '_' + o.PayType + '_';
                	
					Integer i = 1;
                	if (mapOpSeq.containsKey(partKey)) {
                		i = mapOpSeq.get(partKey);
                		i++;
                	}
                	mapOpSeq.put(partKey, i);
                	
                	srh1.Warranty_Claim_Line_Business_ID__c = partKey + String.valueOf(i);
                	
                  	srh1.Primary_Operation_Code__c = o.Code;                    
                    srh1.Service_Technician_Identifier__c = o.TechNum;
                    srh1.Pay_Type__c = o.PayType;
                    srh1.Primary_Operation_Code_Description__c = o.OpCodeDesc;
                    
                    Nna360RepairOrderServiceSoap.ArrayOfPart partArray = o.Parts;
                    if (partArray != null) {
						String[] parts = partArray.Part;
						if (parts != null) {
							for (String p : parts){
								srh1.Primary_Failed_Part__c = Text_Util.valueConcatenation(p, srh1.Primary_Failed_Part__c);
							}
						}
                    }
                    
	                ROs.add(srh1);
                }
            }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (Service_Repair_History__c srh : ROs)
                srh.Dealer_ID__c = dealerMap.get(srh.Dealer_Number__c);
        }
        
        Map<String, Account> customerMap = Text_Util.getCustomerIDMap(customerIds);
        if (customerMap.size() > 0) {
            for (Service_Repair_History__c srh : ROs) {
            	if (customerMap.containsKey(srh.Contact_ID__c)) {
	            	Account a = customerMap.get(srh.Contact_ID__c);
	                srh.Customer__c = a.ID;
            	}
            }
        }
        
        System.Debug('*** Repair Order ROs ' + ROs);
    }
    
    public static void dmlOperations(List<Service_Repair_History__c> ROs) {
        if (ROs.size() > 0)
        	upsert ROs Warranty_Claim_Line_Business_ID__c;
    }
    
    public static void doCheckStatus() {
        Nna360RepairOrderServiceSoap.RepairOrderSoap service = new Nna360RepairOrderServiceSoap.RepairOrderSoap();
        Nna360RepairOrderServiceSoap.Response response;
        if (Test.isRunningTest())
        	response = mockRepairOrderCheckStatusResponse();
        else
        	response = service.StatusCheck();
    }
    
    public class NNACalloutException extends Exception {}
    
    /**
    	test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
    	ByVinsInAccount_TestUtil.TestData();
    	Test.startTest();
 		
		Map<String, ID> mapVINs = new Map<String, ID>();
		List<Service_Repair_History__c> ROs = new List<Service_Repair_History__c>();
		for (Vehicle__c v : ByVinsInAccount_TestUtil.testVehicles)
		    mapVINs.put(v.Vehicle_identification_Number__c, v.Id);
		
		callout(mapVINs, ROs);
		dmlOperations(ROs);
		
    	Test.stopTest();
	}
    
	/**
		test Controller_ByVinsInAccount_RepairOrders: checkStatus
	*/
    static testMethod void testByVinsInAccount_RepairOrdersStatus() {
    	Test.startTest();
    	Controller_ByVinsInAccount_RepairOrders.doCheckStatus();
    	Test.stopTest();
    }

	/**
		create mock response for Controller_ByVinsInAccount_RepairOrder: getRepairOrder
	*/
	public static Nna360RepairOrderServiceSoap.RepairOrderResponse mockRepairOrderResponse() {
		Nna360RepairOrderServiceSoap.RepairOrderResponse response = new Nna360RepairOrderServiceSoap.RepairOrderResponse();
		response.Message = 'Successful';
		response.Status = 'Success';
		response.Vehicles = new Nna360RepairOrderServiceSoap.ArrayOfVehicle();
		response.Vehicles.Vehicle = new Nna360RepairOrderServiceSoap.Vehicle[] {
			new Nna360RepairOrderServiceSoap.Vehicle(),
			new Nna360RepairOrderServiceSoap.Vehicle(),
			new Nna360RepairOrderServiceSoap.Vehicle(),
			new Nna360RepairOrderServiceSoap.Vehicle()
		};
		
		//Repair Order is null
		response.Vehicles.Vehicle[0].VIN = 'VIN01000010000100';
		response.Vehicles.Vehicle[0].RepairOrders = new Nna360RepairOrderServiceSoap.ArrayOfRepairOrder();
		
		//existing Repair Order
		response.Vehicles.Vehicle[1].VIN = 'VIN01000010000101';
		response.Vehicles.Vehicle[1].RepairOrders = new Nna360RepairOrderServiceSoap.ArrayOfRepairOrder();
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder = new Nna360RepairOrderServiceSoap.RepairOrder[] {
			new Nna360RepairOrderServiceSoap.RepairOrder()
		};
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].ContactId = ByVinsInAccount_TestUtil.CUSTOMER_ID;
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Mileage = '10000';
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Number_x = 'RO0@@';
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].DealerCode = ByVinsInAccount_TestUtil.DEALER_CODE;
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Details = new Nna360RepairOrderServiceSoap.ArrayOfOpCode();
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Details.OpCode = new Nna360RepairOrderServiceSoap.OpCode[] {
			new Nna360RepairOrderServiceSoap.OpCode()
		};
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Details.OpCode[0].Code = 'CC';
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Details.OpCode[0].PayType = 'PT';
        
        //new Repair Order data
		response.Vehicles.Vehicle[2].VIN = 'VIN01000010000102';
		response.Vehicles.Vehicle[2].RepairOrders = new Nna360RepairOrderServiceSoap.ArrayOfRepairOrder();
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder = new Nna360RepairOrderServiceSoap.RepairOrder[] {
			new Nna360RepairOrderServiceSoap.RepairOrder()
		};
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].ContactId = ByVinsInAccount_TestUtil.CUSTOMER_ID;
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Number_x = 'RO0@#';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].DealerCode = ByVinsInAccount_TestUtil.DEALER_CODE;
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details = new Nna360RepairOrderServiceSoap.ArrayOfOpCode();
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode = new Nna360RepairOrderServiceSoap.OpCode[] {
			new Nna360RepairOrderServiceSoap.OpCode(),
			new Nna360RepairOrderServiceSoap.OpCode(),
			new Nna360RepairOrderServiceSoap.OpCode()
		};
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[0].Code = 'OpCode1';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[0].TechNum = 'TechNum1';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[0].PayType = 'PayType1';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[1].Code = 'OpCode1';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[1].TechNum = 'TechNum2';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[1].PayType = 'PayType2';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[2].Code = 'OpCode1';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[2].TechNum = 'TechNum3';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[2].PayType = 'PayType2';
        
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[0].Parts = new Nna360RepairOrderServiceSoap.ArrayOfPart();
		response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Details.OpCode[0].Parts.Part = new String[] {'Part1', 'Part2', 'Part3'};
        
		//Opcode is null
		response.Vehicles.Vehicle[3].VIN = 'VIN01000010000100';
		response.Vehicles.Vehicle[3].RepairOrders = new Nna360RepairOrderServiceSoap.ArrayOfRepairOrder();
		response.Vehicles.Vehicle[3].RepairOrders.RepairOrder = new Nna360RepairOrderServiceSoap.RepairOrder[] {
			new Nna360RepairOrderServiceSoap.RepairOrder()
		};
		response.Vehicles.Vehicle[3].RepairOrders.RepairOrder[0].Details = new Nna360RepairOrderServiceSoap.ArrayOfOpCode();
		
        return response;
    }
    
	/**
		create mock response for Controller_ByVinsInAccount_RepairOrder: check status
	*/
	public static Nna360RepairOrderServiceSoap.Response mockRepairOrderCheckStatusResponse() {
		Nna360RepairOrderServiceSoap.Response response = new Nna360RepairOrderServiceSoap.Response();
		response.Message = 'Not Successful';
		response.Status = 'Unsuccess';
        return response;
    }
}