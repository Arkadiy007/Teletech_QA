/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Code behind for StandardContactpage, redirected to from either 
ACALPEvaluation or ACLPEEvaluation. This simply loads the standard person 
account view in SalesForce from a contact record.

Class:              StandardContactOverride
Author:				JJ Heldman
Date:               03/24/12
Version:            1
Last Updated:       03/24/12
    * Stubbed, Completed
*/

public with sharing class StandardContactOverride
{
	// -------- Constants --------
	// None
	
	// -------- Constructor --------
    public StandardContactOverride(ApexPages.StandardController contact)
    {
    	CMember = (Contact) contact.getRecord();
    }
    
    // -------- Variables --------
    // None
	
	// -------- Properties --------
	// Contact record
	public Contact CMember {get; set;}
	
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
		
		Contact contactRecord = [SELECT Id FROM Contact 
			WHERE AccountId =: customer.Id limit 1];
		
		ApexPages.StandardController contactController = 
				new ApexPages.StandardController(contactRecord);
			
		StandardContactOverride testClass = 
			new StandardContactOverride(contactController);
////////////////////////////////////////////////////////////////////////////////
	}
}