@isTest
private class Customer_Loyalty_Components_Test{
	
	private static Account account;
	private static Vehicle_Service_Contract__c vsc;
	private static Vehicle__c vehicle;
	private static Service_Repair_History__c srh;
	private static Vehicle_Ownership_History__c voh;
	private static Warranty_case__c wc;

	/*
	*	Test for account without any vehicles and additional objects;
	*	@should return false on CustomerPay, NESNA Customer, Defect, VPPCustomer and PreOwnedCustomer
	*/
	@isTest
	static void accountWithoutVehicles_ShouldReturnFalseOnNMACCustomer(){
		

		Test.startTest();
		getAccount();
		ApexPages.StandardController sc = new ApexPages.StandardController(account);
		Customer_Loyalty_Component accController = new Customer_Loyalty_Component(sc);

		System.assert(!accController.getCustomerPay());
		System.assert(!accController.getNESNACustomer());
		System.assert(!accController.Defect);
		System.assert(!accController.PreOwnedCustomer);
		
		Test.stopTest();

	}

	/*
	*	Test for account with vehicle and additional objects, like VOHs, VSC and other
	*	@should return true on CustomerPay, NESNA Customer, And return false on Defect, and PreOwnedCustomer
	*/
	@isTest
	static void accountWithoutVehicles_ShouldReturnTrueOnNMACCustomer(){
		Test.startTest();
			
			getAccount();
			getVehicle();
			getVSC();
			getVOH();
			getSRH();
			getWC();
		
			ApexPages.StandardController sc = new ApexPages.StandardController(account);
			Customer_Loyalty_Component accController = new Customer_Loyalty_Component(sc);

			System.assert(accController.getCustomerPay());
			System.assert(accController.getNESNACustomer());
			System.assert(accController.getWarrantyCustomer()); 
			System.assert(accController.getNMACCustomer());
			System.assert(!accController.Defect);
		
		Test.stopTest();

	}





	private static void getAccount() {
		if(account == null){
		RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];
		account = new Account();
		account.Recordtypeid = personalAccRecordType.Id;
		account.firstName = 'Test1';
		account.lastName = 'test2';
		insert account;
		}
	}

	private static void getVehicle(){
		if(vehicle == null){
		RecordType vecRecordType = [select id from RecordType where SobjectType = 'Vehicle__c' limit 1];
		vehicle = new Vehicle__c();
		vehicle.Recordtypeid = vecRecordType.Id;
		vehicle.Vehicle_identification_Number__c = '67412312343256712';
		vehicle.Model_Year__c = '2015';

		insert vehicle;
		}
	}
	
	private static void getVSC(){
		if(vsc == null){
		vsc = new Vehicle_Service_Contract__c();

		vsc.vin__c = '1Nb432s';
		vsc.Policy_Number__c = 'PLNL90260357';
		vsc.Action_Code__c = 'X';
		vsc.Account_Id__c = account.id;
		vsc.Vehicle_Id__c = vehicle.id;

		insert vsc;
		}
	}

	private static void getSRH(){
		if(srh == null){
		srh = new Service_Repair_History__c();
		srh.Customer__c = account.id;
		srh.Vehicle_ID__c =vehicle.id;
		srh.Pay_Type__c = 'C';
		insert srh;
		}
	}

	private static void getVOH(){
		if(voh == null){
		voh = new Vehicle_Ownership_History__c(
			Vehicle__c = vehicle.id,
			NMAC_Lease_Loan_Indicator__c = true,
			Owner__c = account.id
			);
		insert voh;
		}
	}

	private static void getWC(){
		if(wc == null){
		wc = new Warranty_case__c();
		wc.Vehicle__c = vehicle.id;

		insert wc;
		}
	}


}