/**********************************************************************
Name: Controller_ByVinsInAccount_VSC
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Call vehicle sercie contract web service, and updates Vehicle_Service_Contract__c info by given a set of VINs
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 	12/23/2011 Created
***********************************************************************/
public class Controller_ByVinsInAccount_VSC {
	public String ResponseOutput { get; set; }
	private List<Vehicle_Ownership_History__c> vehicle;
    private Vehicle__c inputVehicle;
	private Vehicle_Service_Contract__c inputVSC;
	
    public Controller_ByVinsInAccount_VSC(ApexPages.StandardController controller) {
    	inputVSC = [Select VIN__c From Vehicle_Service_Contract__c where ID =: controller.getRecord().ID];
        
    	List<Vehicle__c> vs = [Select ID, 
        					Vehicle_identification_Number__c, 
                            Last_Claim_Retrieve_Date__c,
                            Last_Recall_Retrieve_Date__c,
                           	Last_RepairOrder_Retrieve_Date__c,
                            Last_Warranty_Retrieve_Date__c,
                            Last_VSC_Retrieve_Date__c
        				From Vehicle__c 
        				where Vehicle_identification_Number__c =: inputVSC.VIN__c];
		if (vs.size() > 0) {
			inputVehicle = vs[0];
			
	        vehicle = [Select Owner__c, 
		        				Vehicle__c, 
		        				Primary_Owner_Indicator__c, 
		        				Original_Owner_Indicator__c, 
		        				Claimed_Owner_Indicator__c, 
		        				Current_Owner_Indicator__c
					        From Vehicle_Ownership_History__c
					        Where Vehicle__c =: inputVehicle.ID];
        }
    }
	
	public PageReference doSearch() {
		ResponseOutput = '';
		
        String vin = inputVSC.VIN__c;
        if (vin != null && vin.length() != 0) {
			List<Vehicle_Service_Contract__c> VSCs = new List<Vehicle_Service_Contract__c>();		
			List<Generic_Text__c> wsComments = new List<Generic_Text__c>();
			Boolean VSC = false;
			Boolean updateVehicle = false;
			
			//preparing ***************************
			ResponseOutput = 'Vehicle ' + vin + '.';
			
	//Web Services ========================================
			
			//VSC call-out ***************************
			if (inputVehicle == null || !Text_Util.isSameDay(inputVehicle.Last_VSC_Retrieve_Date__c)) {
				Map<String, ID> mapVINs = new Map<String, ID>();
				if (inputVehicle != null)
					mapVINs.put(vin, inputVehicle.ID);
				//collect vins and owners - VSC requires to populate AccountID
				Map<String, Vehicle_Ownership_History__c> mapOwners = new Map<String, Vehicle_Ownership_History__c>();
				if (vehicle != null && vehicle.size() > 0)
					mapOwners.put(vin, vehicle[0]);
				try {
					Controller_ByVinsInAccount_VSC.callout(mapVINs, mapOwners, VSCs, wsComments);
					VSC = true;
				} catch (CalloutException ex) {
				    ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts CalloutException ' + ex.getMessage() + '.';
				}
			}
			
	        //VSC upsert ***************************
	        try {
	        	if (VSC) {
	        		Controller_ByVinsInAccount_VSC.dmlOperations(VSCs, wsComments);
	        		if (inputVehicle != null) {
	        			inputVehicle.Last_VSC_Retrieve_Date__c = datetime.now();
	        			updateVehicle = true;
		        	}
	        	}
	        } catch (DMLException ex) {
	            ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts  DMLException ' + ex.getMessage() + '.';
	           	VSC = false;
	        }
	        
	//Update Vehicle Last Retrieve Date ========================================
	        try {
	        	if (updateVehicle)
	        		update inputVehicle;
	        	if (VSC)
	        		ResponseOutput = ResponseOutput + ' Status: Successful.';
	        } catch (DMLException ex) {
	            ResponseOutput = ResponseOutput + ' Status: Update Vehicle DMLException ' + ex.getMessage() + '.';
	        }
        }
        
        return null;
	}
	
    public static void callout(Map<String, ID> mapVINs, Map<String, Vehicle_Ownership_History__c> mapOwners, List<Vehicle_Service_Contract__c> VSCs, List<Generic_Text__c> wsComments) {
        Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_IG_VehicleServiceContractMasterServiceHttpPort service = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract_IG_VehicleServiceContractMasterServiceHttpPort();
		//service.clientCertName_x = System.label.NNA360_Client_Cert;
/************************************************************/
        service.inputHttpHeaders_x=new Map<String,String>();
        Blob headerValue = Blob.valueOf(system.label.Service_Proxy_UserName + ':' + system.label.Service_Proxy_Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
/************************************************************/
		List<String> listVins = new List<String> (mapVINs.keySet());
        
		System.Debug('*** VSC listVins ' + listVins);
        Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] response;
		if (Test.isRunningTest())
        	response = mockVSCResponse();
        else
			response = service.getVehicleServiceContractData(listVINs);
 		System.Debug('*** VSC response ' + response);
        if (response == null || response.size() == 0)
        	return;
        
        List<String> dealerCodes = new List<String>();
        
        for (Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract contract : response) {
	        Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts[] contractData = contract.VehicleServiceContractsData;
	        if (contractData != null) {
				for (Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts c : contractData) {
		            Vehicle_Service_Contract__c v = new Vehicle_Service_Contract__c();
		            VSCs.add(v);
		            
		            v.Policy_Number__c = c.PolicyNumber;
		            v.Name = v.Policy_Number__c;
		            v.Vehicle_Type__c = c.VehicleType;
		            v.Vehicle_Price__c = c.VehiclePrice;
		            v.Vehicle_Option__c = c.VehicleOption;
		            v.VIN__c = contract.Vin;
		            if (mapVINs.containsKey(contract.Vin))
		                v.Vehicle_Id__c = mapVINs.get(contract.Vin);
		            v.Transfer_Date__c = Text_Util.CCYYMMDDtoDate(c.TransferDate);
		            v.Transaction_Date__c = Text_Util.CCYYMMDDtoDate(c.TransactionDate);
		            v.Source__c = c.Source;
		            v.Request_Received_Date__c = Text_Util.CCYYMMDDtoDate(c.RequestReceivedDate);
		            v.Purchase_Price__c = c.PurchasePrice;
		            v.Program_Code__c = c.ProgramCode;
		            v.Product__c = c.Product;
		            v.Printed_Date__c = Text_Util.CCYYMMDDtoDate(c.PrintedDate);
		            v.Price_Code__c = c.PriceCode;
		            v.Plan_Type__c = c.PlanType;
		            v.Plan_Term__c = c.PlanTerm;
		            v.Plan_Code__c = c.PlanCode;
		            v.Paid_to_Date__c = Text_Util.BooleanLookup(c.PaidToDate, false);
		            v.Odometer__c = c.Odometer;
		            v.Lienholder_Zip__c = c.LienholderZip;
		            v.Lienholder_Street__c = c.LienholderStreet;
		            v.Lienholder_State__c = c.LienholderState;
		            v.Lienholder_Name__c = c.LienholderName;
		            v.Lienholder_City__c = c.LienholderCity;
		            v.Finance_Term__c = c.FinanceTerm;
		            v.Expire_Mileage__c = c.ExpireMileage;
		            v.Expire_Date__c = Text_Util.CCYYMMDDtoDate(c.ExpireDate);
		            v.Effective_Date__c = Text_Util.CCYYMMDDtoDate(c.EffectiveDate);
		            v.Deductible_Amount__c = c.DeductibleAmount;
		            v.Dealer_State__c = c.DealerState;
		            v.Dealer_Number__c = c.DealerNumber.Trim();
		            if (v.Dealer_Number__c.length() > 0)
	            		dealerCodes.add(v.Dealer_Number__c);
		            v.Dealer_Net_Refund__c = c.DealerNetRefund;
		            v.Customer_Zip__c = c.CustomerZip;
		            v.Customer_State__c = c.CustomerState;
		            v.Customer_Secondary_Phone__c = Text_Util.validatePhone(c.CustomerSecondaryPhone);
		            v.Customer_Primary_Phone__c = Text_Util.validatePhone(c.CustomerPrimaryPhone);
		            v.Customer_Net_Refund__c = c.CustomerNetRefund;
		            v.Customer_Middle_Name__c = c.CustomerMiddleName;
		            v.Customer_Last_Name__c = c.CustomerLastName;
		            v.Customer_First_Name__c = c.CustomerFirstName;
		            v.Customer_Email__c = c.CustomerEmail;
		            v.Customer_City__c = c.CustomerCity;
		            v.Customer_Address__c = c.CustomerAddress;
		            v.Contract_Type__c = c.ContractType;
		            v.Cancel_Requested_By__c = c.CancelRequestedBy;
		            v.Cancel_Refund_Percent__c = c.CancelRefundPercent;
		            v.Cancel_Mileage__c = c.CancelMileage;
		            v.Cancel_Fee__c = c.CancelFee;
		            v.Cancel_Effective_Date__c = Text_Util.CCYYMMDDtoDate(c.CancelEffectiveDate);
		            v.Cancel_Date__c = Text_Util.CCYYMMDDtoDate(c.CancelDate);
		            v.Application_Number__c = c.ApplicationNumber;
		            v.Added_Date__c = Text_Util.CCYYMMDDtoDate(c.AddedDate);
		            if (mapOwners.containsKey(contract.Vin))
		                v.Account_Id__c = mapOwners.get(contract.Vin).Owner__c;
		           	v.OwnerId = System.Label.Batch_Record_Owner;
		            // v.Who_Received_Refund__c
		           	// v.Cancellation_Reason__c
		            // v.LastTransactionDate
				}
	        }
	        
	        Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments[] contractComments = contract.VehicleServiceContractCommentsData;
	        if (contractComments != null) {
	        	for (Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments c : contractComments) {
		            Generic_Text__c t = new Generic_Text__c();
		            wsComments.add(t);
		            
	        		t.Line_Number__c = Integer.valueOf(c.LineNumber);
					t.Comment_Text__c = c.CommentText;
					t.VIN__c = c.Vin;
					t.Origination_Source__c = System.label.Origination_Source_Webservice;
					t.Origination_Type__c = 'VSC Comments';
					//t.LastModifiedBy = LastUpdated;
	        	}
	        }
        }
        
        Map<String, ID> dealerMap = Text_Util.getDealderIDMap(dealerCodes);
        if (dealerMap.size() > 0) {
            for (Vehicle_Service_Contract__c v : VSCs)
                v.Dealer__c = dealerMap.get(v.Dealer_Number__c);
        }
        
        System.Debug('*** VSC VSCs ' + VSCs);
    }		
	
    public static void dmlOperations(List<Vehicle_Service_Contract__c> VSCs, List<Generic_Text__c> wsComments) {					
        Set<String> vinsInComments = new Set<String>();
		for (Generic_Text__c t : wsComments)			//get all vins that have comment data
			vinsInComments.add(t.VIN__c);
		
        if (VSCs.size() > 0)
            upsert VSCs Policy_Number__c;
        
        List<Generic_Text__c> vscCommentsToInsert = new List<Generic_Text__c>();
        List<Generic_Text__c> vscCommentsToUpdate = new List<Generic_Text__c>();
        List<Generic_Text__c> vscCommentsToDelete = new List<Generic_Text__c>();
        Map <String, List<Generic_Text__c>> existingLinesByVin = new Map <String, List<Generic_Text__c>>();
        Map <String, Decimal> maxLineNoByVin = new Map <String, Decimal>();
        if (vinsInComments.size() > 0) {
        	Map <String, List<Generic_Text__c>> wsLinesByVin = CommentLinesByVin(wsComments);

        	List<Generic_Text__c> existingCommentLines = [select ID, Line_Number__c, Comment_Text__c, VIN__c from Generic_Text__c where VIN__c in :vinsInComments order by VIN__c, Line_Number__c];
        	Map <String, List<Generic_Text__c>> sfLinesByVin = CommentLinesByVin(existingCommentLines);
        	
        	for (String vin : wsLinesByVin.keySet()) {
        		List<Generic_Text__c> wsLines = wsLinesByVin.get(vin);
        		List<Generic_Text__c> sfLines = new List<Generic_Text__c>();
        		if (sfLinesByVin.containsKey(vin))
        			sfLines = sfLinesByVin.get(vin);
        		
        		for (Generic_Text__c t1 : wsLines) {
	        		Boolean bFound = false;
        			for (Generic_Text__c t : sfLines) {
        				if (t1.Line_Number__c == t.Line_Number__c) {
			        		t.Line_Number__c = t1.Line_Number__c;
							t.Comment_Text__c = t1.Comment_Text__c;
							t.VIN__c = t1.VIN__c;
							t.Origination_Source__c = t1.Origination_Source__c;
							t.Origination_Type__c = t1.Origination_Type__c;
							
        					vscCommentsToUpdate.add(t);
        					
        					bFound = true;
        					break;
        				}
        			}
        			
        			if (!bFound) {
        				Generic_Text__c t = new Generic_Text__c();
		        		t.Line_Number__c = t1.Line_Number__c;
						t.Comment_Text__c = t1.Comment_Text__c;
						t.VIN__c = t1.VIN__c;
						t.Origination_Source__c = t1.Origination_Source__c;
						t.Origination_Type__c = t1.Origination_Type__c;
						t.OwnerId = System.Label.Batch_Record_Owner;
    					vscCommentsToInsert.add(t);
        			}
        		}
        		
        		for (Generic_Text__c t : sfLines) {
        			Boolean bFound = false;
        			for (Generic_Text__c t1 : wsLines) {
        				if (t1.Line_Number__c == t.Line_Number__c) {
        					bFound = true;
        					break;
        				}
        			}
        			
        			if (!bFound) {
        				vscCommentsToDelete.add(t);
        			}
        		}
        		/*
        		if (sfLines.size() > wsLines.size()) {
        			for (Integer i = wsLines.size(); i < sfLines.size(); i++)
        				vscCommentsToDelete.add(sfLines[i]);
        		}
        		
        		Integer counts = sfLines.size() > wsLines.size() ? wsLines.size() : sfLines.size();
    			for (Integer i = 0; i < counts; i++) {
    				Generic_Text__c t = sfLines[i];
    				Generic_Text__c t1 = wsLines[i];
	        		t.Line_Number__c = t1.Line_Number__c;
					t.Comment_Text__c = t1.Comment_Text__c;
					t.VIN__c = t1.VIN__c;
					t.Origination_Source__c = t1.Origination_Source__c;
					t.Origination_Type__c = t1.Origination_Type__c;
    				vscCommentsToUpdate.add(t);
    			}
        		
        		if (wsLines.size() > sfLines.size()) {
        			for (Integer i = sfLines.size(); i < wsLines.size(); i++)
        				vscCommentsToInsert.add(wsLines[i]);
        		}*/
        	}
        }
        
        if (vscCommentsToDelete.size() > 0)
            delete vscCommentsToDelete;

        if (vscCommentsToUpdate.size() > 0)
            update vscCommentsToUpdate;

        if (vscCommentsToInsert.size() > 0)
            insert vscCommentsToInsert;
    }
    
    private static Map<String, List<Generic_Text__c>> CommentLinesByVin(List<Generic_Text__c> commentLines) {
		Map<String, List<Generic_Text__c>> mapComments = new Map<String, List<Generic_Text__c>>();
    	for (Generic_Text__c t : commentLines) {
			List<Generic_Text__c> commentByLineNo;
			if (mapComments.containsKey(t.VIN__c))
				commentByLineNo = mapComments.get(t.VIN__c);
			else {
				commentByLineNo = new List<Generic_Text__c>();
            	mapComments.put(t.VIN__c, commentByLineNo);
			}
			commentByLineNo.add(t);
    	}
    	return mapComments;
    }
    
    /**
    	test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
    	ByVinsInAccount_TestUtil.TestData();
    	Test.startTest();
    	
		Map<String, ID> mapVINs = new Map<String, ID>();
		List<Vehicle_Service_Contract__c> VSCs = new List<Vehicle_Service_Contract__c>();
		List<Generic_Text__c> wsComments = new List<Generic_Text__c>();
		Map<String, Vehicle_Ownership_History__c> mapOwners = new Map<String, Vehicle_Ownership_History__c>();
		for (Vehicle_Ownership_History__c v : ByVinsInAccount_TestUtil.testOwners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
	        mapVINs.put(vin, v.Vehicle__c);
	        mapOwners.put(vin, v);
		}
		
		callout(mapVINs, mapOwners, VSCs, wsComments);
		dmlOperations(VSCs, wsComments);
		
    	Test.stopTest();
	}
    
    /**
    	test Controller_ByVinsInVSC
    */
    static testMethod void testByVinsInVSC() {
    	Account testAcc = new Account();
        testAcc.name = 'Test Account';
        testAcc.Customer_ID__c = ByVinsInAccount_TestUtil.CUSTOMER_ID;
        insert testAcc; 
        
		Vehicle__c testVehicle = new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101');
		insert testVehicle;
		
        Vehicle_Ownership_History__c testOwner = new Vehicle_Ownership_History__c(Owner__c = testAcc.ID, Vehicle__c = testVehicle.ID);
        insert testOwner;

		//testing upserting existing Vehicle_Service_Contract__c 
        Vehicle_Service_Contract__c testVSC = new Vehicle_Service_Contract__c();
        testVSC.Vehicle_Id__c = testVehicle.ID;
        testVSC.VIN__c = 'VIN01000010000101';
        testVSC.Policy_Number__c = 'PLCY##';
        
        insert testVSC;
        
    	Test.startTest();

    	Controller_ByVinsInAccount_VSC controller = new Controller_ByVinsInAccount_VSC(new ApexPages.StandardController(testVSC));
    	controller.doSearch();
		
    	Test.stopTest();
    }
    
	/**
		create mock response for Controller_ByVinsInAccount_VSC
	*/
	public static Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] mockVSCResponse() {
		Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] response = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract(),
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract(),
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContract()
		};
		
		//Vehicle Service Contracts Data is null
		response[0].Vin = 'VIN01000010000100';
		
		//existing Vehicle Service Contracts Data
		response[1].Vin = 'VIN01000010000101';
		response[1].VehicleServiceContractsData = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts()
		};
		response[1].VehicleServiceContractsData[0].Vin = response[1].Vin;
		response[1].VehicleServiceContractsData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
		response[1].VehicleServiceContractsData[0].PolicyNumber = 'PLCY##';
		response[1].VehicleServiceContractCommentsData = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments(),
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments()
		};
        response[1].VehicleServiceContractCommentsData[0].Vin = response[1].Vin;
        response[1].VehicleServiceContractCommentsData[0].LineNumber = '1';
        response[1].VehicleServiceContractCommentsData[0].CommentText = 'CommentText1 In WS';
        response[1].VehicleServiceContractCommentsData[1].Vin = response[1].Vin;
        response[1].VehicleServiceContractCommentsData[1].LineNumber = '3';
        response[1].VehicleServiceContractCommentsData[1].CommentText = 'CommentText2 In WS';
		
		//new Vehicle Service Contracts Data
		response[2].Vin = 'VIN01000010000102';
		response[2].VehicleServiceContractsData = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts()
		};
		response[2].VehicleServiceContractsData[0].Vin = response[2].Vin;
		response[2].VehicleServiceContractsData[0].DealerNumber = ByVinsInAccount_TestUtil.DEALER_CODE;
		response[2].VehicleServiceContractsData[0].PolicyNumber = 'PLCY#$';
		response[2].VehicleServiceContractsData[0].TransferDate = '2012-12-21 00:00:00.0';
		response[2].VehicleServiceContractsData[0].PaidToDate = '0';
        
        return response;
    }
}