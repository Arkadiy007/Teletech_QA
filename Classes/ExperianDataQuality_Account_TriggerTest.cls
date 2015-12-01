@isTest
public with sharing class ExperianDataQuality_Account_TriggerTest {
	public static testmethod void InsertAccountTest() {
		Account account = new Account(Name='John Smith',BillingStreet='445 Hamilton Ave', ShippingStreet='445 Hailton');
        insert account;        
    }
}