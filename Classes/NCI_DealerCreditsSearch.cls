/**********************************************************************
Name: NCI_DealerCreditsSearch
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Controller for NCI_DealerCreditsSearch.page

======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 02/25/2015 Created
***********************************************************************/
public class NCI_DealerCreditsSearch {
	public String dealercode { get; set; }
	public List <DealerWrapper > dealersCredits { get; set; }
	public Boolean hasSearchBeenPerformed { get;set;}

	public NCI_DealerCreditsSearch()
	{
		dealersCredits = new List <DealerWrapper > ();
	}

	// Peforms search of dealer credits on key press
	public void Search(){
		dealersCredits.clear();
		selectDealersCredits();
		if(Test.isRunningTest()) { 
			dealercode = '12345';
		}
	}

	// populates list of dealersCredits with values based on the input of dealer code.
	public void selectDealersCredits()
	{
		hasSearchBeenPerformed = true;

		if (dealercode != null && dealercode != '') {
			// select all dealers accounts which have dealer code 
			List <Account > dealers = [select Id, Name, Make_Name__c from Account where Dealer_code__c = :dealerCode];

			if (dealers.size() > 0)
			{
				Set<Id> dealersIds = (new Map <Id, Account > (dealers)).keySet();
				// Select all Credit records for all selected dealers
				List <Customer_Service_Credit__c > creditsList = getServiceCredits(dealersIds);

				// create map for dealers with their credint
				Map <Id, List <Customer_Service_Credit__c > > dealersWithCredits = new Map <Id, List <Customer_Service_Credit__c > > ();

				// populate map with dealers records
				for (Account dealer : dealers) {
					dealersWithCredits.put(dealer.Id, new List <Customer_Service_Credit__c > ());
				}

				// populate map with credits records
				for (Customer_Service_Credit__c credit : creditsList) {
					dealersWithCredits.get(credit.Dealer_Name__c).add(credit);
				}

				// fill list with wrapper records for each record inside map
				for (Account dealer : dealers) {
					DealerWrapper dealerWrap = new DealerWrapper(dealer, dealersWithCredits.get(dealer.Id));
					dealersCredits.add(dealerWrap);
				}
			}
		}
	}

	// Redirect to creation of new customer service credit 
	public PageReference AddCredit(){
		PageReference addCreditPage = new PageReference ('/a1z/e?nooverride=1');
        addCreditPage.setRedirect(true);
        return addCreditPage;
	}

	// Select all credit records that are related to passed dealers ids
	public List <Customer_Service_Credit__c > getServiceCredits(Set<Id> dealersIds)
	{
		List <Customer_Service_Credit__c > credits =
		[
		Select Id, Name,
		Amount__c,
		Customer_Name_Formula__c,
		Dealer_Code__c,
		Debit_or_Credit__c,
		G_L__c,
		Cost_Centre__c,
		Plus_Taxes__c,
		Reference_Text__c,
		Requested_By__c,
		Requested_Date__c,
		VIN_Formula__c,
		Dealer_Name__c
		from
		Customer_Service_Credit__c
		where Dealer_Name__c in : dealersIds
		Order By Requested_Date__c DESC
		];

		return credits;
	}

	// wrapper class that contains dealer account and its credits
	private class DealerWrapper {

		public List <Customer_Service_Credit__c > lstCredits { get; set; }
		public Account dealer { get; set; }

		public DealerWrapper(Account deal, List <Customer_Service_Credit__c > credits) {
			dealer = deal;
			lstCredits = credits;
		}
	}
}