/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ByVinsInAccount_Test {
    static Account testAccount;
    static Account testDealer;
    static List<Vehicle__c> testVehicles;
    static List<String> testVINs;
    final static String DEALER_CODE = 'DLRCD!@';
    /**
    	create test data
    */
    static void TestData() {
    	testAccount = new Account();
        testAccount.name = 'Test Account';
        testAccount.Last_Retrieve_Date__c = Date.newInstance(2010, 12, 21);
        insert testAccount; 
        
    	testDealer = new Account();
        testDealer.name = 'Test Dealer';
        testDealer.Dealer_Code__C = DEALER_CODE;
        insert testDealer; 
		
        testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000102'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000103'));
        insert testVehicles;
        testVINs = new List<String> {'VIN01000010000101', 'VIN01000010000102', 'VIN01000010000103'};
        
        List<Vehicle_Ownership_History__c> testOwners = new List<Vehicle_Ownership_History__c>();
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[0].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[1].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[2].ID));
        insert testOwners;
        
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingClaim = new Service_Repair_History__c();
        existingClaim.Vehicle_ID__c = testVehicles[0].ID;
        existingClaim.Dealer_Number__c = DEALER_CODE;
        existingClaim.Work_Order_Number__c = 'WO0@@';
        existingClaim.Claim_Line_Number__c = '01';
        existingClaim.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingClaim.Transaction_Date__c = DateTime.newInstance(1999, 1, 1);
        existingClaim.Warranty_Claim_Line_Business_ID__c = existingClaim.Dealer_Number__c + '_' + existingClaim.Work_Order_Number__c + '_' + existingClaim.Vehicle_Identification_Number__c + '_' + existingClaim.Claim_Line_Number__c;
        insert existingClaim;
		
        //testing upserting existing Master_Recall_Campaign__c 
        Master_Recall_Campaign__c existingMaster = new Master_Recall_Campaign__c();
        existingMaster.Recall_Identifier__c = 'RC0!!';
        existingMaster.Dealer_Submitted_Claim_Code__c = DEALER_CODE;
        insert existingMaster;
		
		//testing upserting existing Vehicle_Recall__c 
        Vehicle_Recall__c existingRecall = new Vehicle_Recall__c();
        existingRecall.Vehicle__c = testVehicles[0].ID;
        existingRecall.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingRecall.Recall_Identifier__c = 'RC0!!';
        existingRecall.Dealer_Submitted_Claim_Code__c = DEALER_CODE;
        existingRecall.Master_Recall_Campaign__c = existingMaster.ID;
        existingRecall.Vehicle_Recall_Business_ID__c = existingRecall.Recall_Identifier__c + '_' + existingRecall.Vehicle_Identification_Number__c;
        existingRecall.Effective_Date__c = System.today();
        insert existingRecall;
		
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingRO = new Service_Repair_History__c();
        existingRO.Vehicle_ID__c = testVehicles[0].ID;
        existingRO.Dealer_Number__c = DEALER_CODE;
        existingRO.Dealer_Repair_Order_Number__c = 'RO0@@';
        existingRO.Primary_Operation_Code__c = 'CC';
        existingRO.Pay_Type__c = 'PT';
        existingRO.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingRO.Warranty_Claim_Line_Business_ID__c = existingRO.Dealer_Number__c + '_' + existingRO.Dealer_Repair_Order_Number__c + '_' + existingRO.Vehicle_Identification_Number__c + '_' + existingRO.Primary_Operation_Code__c + '_' + existingRO.Pay_Type__c;
        insert existingRO;
		
		//testing upserting existing Vehicle_Service_Contract__c 
        Vehicle_Service_Contract__c existingVSC = new Vehicle_Service_Contract__c();
        existingVSC.Vehicle_Id__c = testVehicles[0].ID;
        existingVSC.VIN__c = 'VIN01000010000101';
        existingVSC.Policy_Number__c = 'PLCY##';
        insert existingVSC;
		
        //testing upserting existing Warranty_Information__c 
        Warranty_Information__c existingWarranty = new Warranty_Information__c();
        existingWarranty.Vehicle_ID__c = testVehicles[0].ID;
        existingWarranty.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingWarranty.WS_Warranty_Record_Type__c = 'ApplicableWarranty';
        existingWarranty.Warranty_Description__c = 'AW Description';
        existingWarranty.Warranty_Information_Business_ID__c = 'aw_' + existingWarranty.Vehicle_Identification_Number__c + '_' + existingWarranty.Warranty_Description__c;
        insert existingWarranty;
		
		//testing already exist comment text.
		Generic_Text__c[] existingVSCComments = new Generic_Text__c[] {
			new Generic_Text__c(VIN__c = 'VIN01000010000101',
						        Line_Number__c = 1,
						        Comment_Text__c = 'CommentText1 In Sf'),
	        new Generic_Text__c(VIN__c = 'VIN01000010000101',
	        					Line_Number__c = 2,
	        					Comment_Text__c = 'CommentText2 In Sf'),
	        new Generic_Text__c(VIN__c = 'VIN01000010000101',
	        					Line_Number__c = 3,
	        					Comment_Text__c = 'CommentText3 In Sf')
	    };
        insert existingVSCComments;
    }
   	
    /**
    	test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
    	TestData();
    	Test.startTest();
    	Controller_ByVinsInAccountComponent component = new Controller_ByVinsInAccountComponent();
    	
    	Controller_ByVinsInAccount controller = new Controller_ByVinsInAccount(new ApexPages.StandardController(testAccount));
    	
    	component.ByVinsInAccountController = controller.getThis();
    	System.Debug(component.ByVinsInAccountController);
    	
    	component.BatchNumber = 1;
    	
    	component.ResponseOutput = 'There is error';
    	System.Debug(component.ResponseOutput);
    	
    	component.doSearch();

    	Test.stopTest();
    	/*
	    //test Controller_ByVinsInAccount_Claims
    	List<Service_Repair_History__c> claims = [Select Vehicle_Identification_Number__c, Vehicle_ID__c, Dealer_ID__c From Service_Repair_History__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(claims.size() == 1);
    	for (Service_Repair_History__c c : claims) {
    		System.assert(c.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(c.Dealer_ID__c == testDealer.ID);
    	}
	
	    //test Controller_ByVinsInAccount_Recalls
    	List<Master_Recall_Campaign__c> masters = [Select Dealer__c, TSB_Number__c, Recall_Identifier__c From Master_Recall_Campaign__c Where Recall_Identifier__c = 'RC0!!'];
    	System.assert(masters.size() == 1);
    	for (Master_Recall_Campaign__c m : masters) {
    		System.assert(m.Dealer__c == testDealer.ID);
    		System.assert(m.TSB_Number__c == 'ITB10-YYY');
    	}
		
    	List<Vehicle_Recall__c> recalls = [Select Vehicle_Identification_Number__c, Vehicle__c, Dealer__c, TSB_Number__c, Recall_Identifier__c, Master_Recall_Campaign__c From Vehicle_Recall__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(recalls.size() == 1);
    	for (Vehicle_Recall__c r : recalls) {
    		System.assert(r.Vehicle__c == testVehicles[1].ID);
    		System.assert(r.Dealer__c == testDealer.ID);
    		System.assert(r.TSB_Number__c == 'ITB10-YYY');
    		System.assert(r.Master_Recall_Campaign__c == masters[0].ID);
    	}
    
	    //test Controller_ByVinsInAccount_RepairOrders: getRepairOrders	
    	List<Service_Repair_History__c> claims = [Select Vehicle_Identification_Number__c, Vehicle_ID__c, Dealer_ID__c, Primary_Operation_Code__c From Service_Repair_History__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(claims.size() == 1);
    	for (Service_Repair_History__c c : claims) {
    		System.assert(c.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(c.Dealer_ID__c == testDealer.ID);
    		System.assert(c.Primary_Operation_Code__c == 'OpCode1 OpCode2');
    	}

	    //test Controller_ByVinsInAccount_VSC	
    	List<Vehicle_Service_Contract__c> VSCs = [Select VIN__c, Vehicle_ID__c, Dealer__c, Account_Id__c From Vehicle_Service_Contract__c Where VIN__c in: testVINs];
    	System.assert(VSCs.size() == 1);
    	for (Vehicle_Service_Contract__c v : VSCs) {
    		System.assert(v.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(v.Dealer__c == testDealer.ID);
    		System.assert(v.Account_Id__c == testAccount.ID);
    	}
    	
    	List<Generic_Text__c> comments = [Select VIN__c, Line_Number__c, Comment_Text__c From Generic_Text__c Where VIN__c in: testVehicles];
    	System.assert(comments.size() == 2);
    	System.assert(comments[0].Comment_Text__c == 'CommentText1 In WS');

	    //test Controller_ByVinsInAccount_Warranties	
    	List<Warranty_Information__c> warranties = [Select Vehicle_Identification_Number__c, Vehicle_ID__c From Warranty_Information__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(warranties.size() == 3);
    	for (Warranty_Information__c w : warranties)
    		System.assert(w.Vehicle_ID__c == testVehicles[1].ID);*/
    }
	
    static testMethod void testByVinsInVehicle() {
    	TestData();
    	System.Debug('*** testVehicles ' + testVehicles);
    	Test.startTest();
    	    	
    	Controller_ByVinsInVehicle controller = new Controller_ByVinsInVehicle(new ApexPages.StandardController(testVehicles[1]));
    	controller.doSearch();

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
		create mock response for Controller_ByVinsInAccount_Claims
	*/
	public static Nna360ClaimMasterServiceSoap.VehicleClaim[] mockClaimResponse() {
		Nna360ClaimMasterServiceSoap.VehicleClaim[] response = new Nna360ClaimMasterServiceSoap.VehicleClaim[] {
			new Nna360ClaimMasterServiceSoap.VehicleClaim(),
			new Nna360ClaimMasterServiceSoap.VehicleClaim(),
			new Nna360ClaimMasterServiceSoap.VehicleClaim(),
			new Nna360ClaimMasterServiceSoap.VehicleClaim()
		};
		
		//ClaimData is null
		response[0].Vin = 'VIN01000010000100';
		//extisting claim
		response[1].Vin = 'VIN01000010000101';
		response[1].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
			new Nna360ClaimMasterServiceSoap.Claim()
		};
		response[1].ClaimData[0].Vin = response[1].Vin;
        response[1].ClaimData[0].DealerNumber = DEALER_CODE;
        response[1].ClaimData[0].WorkOrderNumber = 'WO0@@';
        response[1].ClaimData[0].TransactionDate = '2012-12-21 00:00:00.0';
        response[1].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
			new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
		};
        response[1].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
		
		//new claim data
		response[2].Vin = 'VIN01000010000102';
		response[2].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
			new Nna360ClaimMasterServiceSoap.Claim()
		};
		response[2].ClaimData[0].Vin = response[2].Vin;
        response[2].ClaimData[0].DealerNumber = DEALER_CODE;
        response[2].ClaimData[0].WorkOrderNumber = 'WO0@#';
        response[2].ClaimData[0].VehicleRepairCloseDate = '0001-01-01 00:00:00.0';
        response[2].ClaimData[0].VehicleMileageNumber = '10000';
        response[2].ClaimData[0].OwnerIndicator = 'Y';
        response[2].ClaimData[0].WarrantyClaimLineData = new Nna360ClaimMasterServiceSoap.WarrantyClaimLine[] {
			new Nna360ClaimMasterServiceSoap.WarrantyClaimLine(),
			new Nna360ClaimMasterServiceSoap.WarrantyClaimLine()
		};
        response[2].ClaimData[0].WarrantyClaimLineData[0].ClaimLineNumber = '01';
		response[2].ClaimData[0].WarrantyClaimLineData[0].SubmittedAmount = '100.00';
        response[2].ClaimData[0].WarrantyClaimLineData[0].PaidAmount = '100.00';
        response[2].ClaimData[0].WarrantyClaimLineData[1].ClaimLineNumber = '02';
		response[2].ClaimData[0].WarrantyClaimLineData[1].ClaimTypeCode = 'C';
        response[2].ClaimData[0].WarrantyClaimLineData[1].PrimaryFailedPart = 'P';
		
		//ClaimLine is null
		response[3].Vin = 'VIN01000010000103';
		response[3].ClaimData = new Nna360ClaimMasterServiceSoap.Claim[] {
			new Nna360ClaimMasterServiceSoap.Claim()
		};
		
        return response;
    }

	/**
		create mock response for Controller_ByVinsInAccount_Recalls
	*/
	public static Nna360RecallServiceSoap.VehicleRecall[] mockRecallResponse() {
		Nna360RecallServiceSoap.VehicleRecall[] response = new Nna360RecallServiceSoap.VehicleRecall[] {
			new Nna360RecallServiceSoap.VehicleRecall(),
			new Nna360RecallServiceSoap.VehicleRecall(),
			new Nna360RecallServiceSoap.VehicleRecall()
		};
		
		//RecallData is null
		response[0].Vin = 'VIN01000010000100';
		
		//Recall and Master Data already exist.
		response[1].Vin = 'VIN01000010000101';
		response[1].RecallData = new Nna360RecallServiceSoap.Recall[] {
			new Nna360RecallServiceSoap.Recall()
		};
		response[1].RecallData[0].Vin = response[1].Vin;
		response[1].RecallData[0].RecallIdentifier = 'RC0!!';
        response[1].RecallData[0].DealerSubmittedClaimIndicator = DEALER_CODE;
        response[1].RecallData[0].RecallPrimaryDescription = 'ITB10-YYY';
		
		//new Recall and Master Data
		response[2].Vin = 'VIN01000010000102';
		response[2].RecallData = new Nna360RecallServiceSoap.Recall[] {
			new Nna360RecallServiceSoap.Recall()
		};
		response[2].RecallData[0].Vin = response[2].Vin;
    	response[2].RecallData[0].RecallIdentifier = 'XX0X1';
        response[2].RecallData[0].DealerSubmittedClaimIndicator = DEALER_CODE;
        response[2].RecallData[0].RecallPrimaryDescription = 'NTB10-YYY';
        response[2].RecallData[0].ExtendedWarrantyIndicator = '0';
        
        return response;
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
		response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Mileage = '10000';
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].Number_x = 'RO0@@';
        response.Vehicles.Vehicle[1].RepairOrders.RepairOrder[0].DealerCode = DEALER_CODE;
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
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].Number_x = 'RO0@#';
        response.Vehicles.Vehicle[2].RepairOrders.RepairOrder[0].DealerCode = DEALER_CODE;
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
		response[1].VehicleServiceContractsData[0].DealerNumber = DEALER_CODE;
		response[1].VehicleServiceContractsData[0].PolicyNumber = 'PLCY##';
		response[1].VehicleServiceContractCommentsData = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments(),
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContractComments()
		};
        response[1].VehicleServiceContractCommentsData[0].Vin = response[1].Vin;
        response[1].VehicleServiceContractCommentsData[0].LineNumber = '1';
        response[1].VehicleServiceContractCommentsData[0].CommentText = 'CommentText1 In WS';
        response[1].VehicleServiceContractCommentsData[1].Vin = response[1].Vin;
        response[1].VehicleServiceContractCommentsData[1].LineNumber = '2';
        response[1].VehicleServiceContractCommentsData[1].CommentText = 'CommentText2 In WS';
		
		//new Vehicle Service Contracts Data
		response[2].Vin = 'VIN01000010000102';
		response[2].VehicleServiceContractsData = new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts[] {
			new Nna360VehicleServiceContractsServiceSoap.VehicleServiceContracts()
		};
		response[2].VehicleServiceContractsData[0].Vin = response[2].Vin;
		response[2].VehicleServiceContractsData[0].DealerNumber = DEALER_CODE;
		response[2].VehicleServiceContractsData[0].PolicyNumber = 'PLCY#$';
		response[2].VehicleServiceContractsData[0].TransferDate = '2012-12-21 00:00:00.0';
		response[2].VehicleServiceContractsData[0].PaidToDate = '0';
        
        return response;
    }
    
	/**
		create mock response for Controller_ByVinsInAccount_Warranties
	*/
	public static Nna360WarrantyMasterServiceSoap.VehicleCoverage[] mockWarrantyResponse() {
		Nna360WarrantyMasterServiceSoap.VehicleCoverage[] response = new Nna360WarrantyMasterServiceSoap.VehicleCoverage[] {
			new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
			new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
			new Nna360WarrantyMasterServiceSoap.VehicleCoverage(),
			new Nna360WarrantyMasterServiceSoap.VehicleCoverage()
		};
		
		//VehicleCoverageData is null
		response[0].Vin = 'VIN01000010000100';
		
		//new warrranty data
		response[1].Vin = 'VIN01000010000102';
		response[1].WarrantyExclusionsData = new Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] {
			new Nna360WarrantyMasterServiceSoap.WarrantyExclusions()
		};
        response[1].WarrantyExclusionsData[0].WarrantyExclusionCode = 'B';
		response[1].WarrantyExclusionsData[0].WarrantyExclusionDescription = 'BRND DESC';
		
		response[2].Vin = 'VIN01000010000103';
		response[2].BrandedInfoData = new Nna360WarrantyMasterServiceSoap.BrandedInfo[] {
			new Nna360WarrantyMasterServiceSoap.BrandedInfo()
		};
		response[2].BrandedInfoData[0].StateCode = 'CO';
		response[2].BrandedInfoData[0].RecordTypeCode = '#';
		response[2].BrandedInfoData[0].SourceIDCode = '!!';
		
		//existing warranty data
		response[3].Vin = 'VIN01000010000101';
		response[3].ApplicableWarrantyData = new Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] {
			new Nna360WarrantyMasterServiceSoap.ApplicableWarranty()
		};
        response[3].ApplicableWarrantyData[0].WarrantyDescription = 'AW Description';
		
        return response;
    }
}