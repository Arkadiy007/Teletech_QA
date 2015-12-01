/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Code behind for StandardAccount page, redirected to from ACALPEvaluation page.
This simply loads the standard person account view in SalesForce. This
controller and page can be removed in the future if CTI component pops to 
Contact record.

Class:              StandardAccountOverride
Author:				JJ Heldman
Date:               03/24/12
Version:            1
Last Updated:       03/24/12
    * Stubbed, Completed
*/

public with sharing class StandardAccountOverride
{
	// -------- Constants --------
	// None
	
	// -------- Constructor --------
    public StandardAccountOverride(ApexPages.StandardController account)
    {
    	AMember = (Account) account.getRecord();
    }
    
    // -------- Variables --------
    // None
	
	// -------- Properties --------
	// Account record
	public Account AMember {get; set;} 
	
	// -------- Methods --------
	// None
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		RecordType person = [SELECT Id FROM RecordType WHERE Name=: 
			system.label.TMS AND SobjectType = 'Account' LIMIT 1];
		
		Account customer = new Account();
		customer.FirstName = 'Test';
        customer.MiddleName__c = 'Test';
        customer.LastName ='Test';
		customer.RecordTypeId = person.Id;
		insert customer;
		
		ApexPages.StandardController accountController = 
				new ApexPages.StandardController(customer);
			
		StandardAccountOverride testClass = 
			new StandardAccountOverride(accountController);
////////////////////////////////////////////////////////////////////////////////
	}
}