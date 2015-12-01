/**********************************************************************
Name: Account_Vehicle_Recall_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests the Apex class Account_Vehicle_Recall.

Related Class : VehicleRecallByVINsInAccounts 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 10/11/2011 Created
***********************************************************************/

@isTest
private class Account_Vehicle_Recall_Test {
    private static String personType;
    private static RecordType personTypeRT;
    private static String dealerType;
    private static RecordType dealerTypeRT;

    private static Account acct;
    private static Account dealer;
    private static Vehicle__c vehicle;
    private static Vehicle_Retail_Sale__c vrs;
	
    public static void InitializeData() {
        personType = System.Label.AccRTMaritz;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        dealerType = System.Label.AccRTDealer;
        dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
		
		acct = new Account();
        acct.customer_Id__c = 'testId1';
        acct.FirstName = 'Test';
        acct.LastName = 'User1';
        acct.RecordTypeId = personTypeRT.id;
        insert acct;

		dealer = new Account();
        dealer.Dealer_Code__c = '12345654321';
        dealer.Name = 'Test Dealer';
        dealer.RecordTypeId = dealerTypeRT.id;
        insert dealer;
        
        vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '1N345678901234567';
        insert vehicle;
        
        vrs = new Vehicle_Retail_Sale__c();
        vrs.Vehicle_Identification_Number__c = vehicle.Id;
        vrs.Owner_Id__c = acct.Id;
        vrs.Selling_Dealer_Name__c = dealer.Id;
        insert vrs;
    }
    
    static testMethod void TestRecall_RecallDoesNotExist() {
    	System.debug('***** TestRecall_RecallDoesNotExist *****');
    	
		InitializeData();
		Test.startTest();
			
			// Initialize page and controller
			PageReference objPageRef = Page.VehicleRecallByVINsInAccounts;
			Account_Vehicle_Recall objController;
			Test.setCurrentPage(objPageRef);
			objController = new Account_Vehicle_Recall(new ApexPages.StandardController(acct));

			// Set recallMessage
			objController.doLookupRecalls();
			System.assert(objController.recallMessage == '');

		Test.stopTest();
    }

    static testMethod void TestRecall_RecallExists() {
    	System.debug('***** TestRecall_RecallExists *****');
    	
		InitializeData();
		
		// Set an open recall flag on the vehicle to cause the recall message
		// to display.
		vehicle.Open_Recall__c = true;
		update vehicle;
		
		Test.startTest();
			
			// Initialize page and controller
			PageReference objPageRef = Page.VehicleRecallByVINsInAccounts;
			Account_Vehicle_Recall objController;
			Test.setCurrentPage(objPageRef);
			objController = new Account_Vehicle_Recall(new ApexPages.StandardController(acct));

			// Set recallMessage
			objController.doLookupRecalls();
			System.assert(objController.recallMessage == System.Label.Vehicle_Recall_Message);

		Test.stopTest();
    }
    
    static testMethod void Test_JDPowerMessageTest() {
    	System.debug('***** TestRecall_RecallExists *****');
    	
		InitializeData();		
		vrs.Purchase_Date__c = Date.parse(System.Label.Purchase_Start_Date);	
		vrs.Owner_Id__c = acct.Id;
		update vrs;
			
		Test.startTest();
			
			// Initialize page and controller
			PageReference objPageRef = Page.VehicleRecallByVINsInAccounts;
			Account_Vehicle_Recall objController;
			Test.setCurrentPage(objPageRef);
			objController = new Account_Vehicle_Recall(new ApexPages.StandardController(acct));
			if(Label.Show_JD_Power_Message == 'Yes'){
				System.assert(objController.showPowerCust);
			}else{
				System.assert(!objController.showPowerCust);
			}

		Test.stopTest();
    }
}