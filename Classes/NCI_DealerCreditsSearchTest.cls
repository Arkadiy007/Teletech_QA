/**********************************************************************
  Name: NCI_DealerCreditsSearchTest
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Test class for NCI_DealerCreditsSearch class

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 02/25/2015 Created
  ***********************************************************************/
@isTest
public class NCI_DealerCreditsSearchTest {

	private static testmethod void testDealerCredits()
	{
		User u = Test_Utilities.createUser(null);
		System.runAs(u)
		{
			Account d = Test_Utilities.createDealer();
			d.Dealer_Code__c = '12345';
			d.Dealer_Access_Code__c = 54321;
			d.Make_Name__c = 'INFINITI';
			update d;
			Account customer = Test_Utilities.createCustomer(null, 'Aaron', 'Bessey');
			Vehicle__c vehicle = Test_Utilities.createVehicle(null);
			Test.startTest();
			NCI_DealerCreditsSearch DCS = new NCI_DealerCreditsSearch();
			System.assertEquals(0, DCS.dealersCredits.size());

			Customer_Service_Credit__c csc = Test_Utilities.createCustomerServiceCredit(d.Id, customer.Id, vehicle.Id);
			DCS.dealercode = '12345';
			DCS.selectDealersCredits();
			System.assertEquals(1, DCS.dealersCredits.size());

		}
		Test.stopTest();
	}

	private static testmethod void testAddCredit()
	{
		User u = Test_Utilities.createUser(null);
		System.runAs(u)
		{
			Test.startTest();
			NCI_DealerCreditsSearch DCS = new NCI_DealerCreditsSearch();
			PageReference pr = DCS.AddCredit();
			system.assertEquals('/a1z/e?nooverride=1', pr.getURL());
		}
		Test.stopTest();
	}
}