/**********************************************************************
Name: Lead_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Lead_Before Trigger.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry	04/19/2011	Created 
***********************************************************************/
@isTest
private class Lead_Before_Test  {
    static testmethod void testTriggerLeadBefore() {
    	Lead insertedLead;

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Lead lead = new Lead();
        lead.lastName = 'Lead';
        lead.FirstName = 'firstname';
        lead.PostalCode = '21204';
        lead.State = 'CO';
                
        Test.startTest();
        insert lead;
        Test.stopTest();

        /* Get the Dealer Quotes Request object with fields filled in after trigger executes. */
        insertedLead = [select id, State 
	                    from Lead
	                    where LastName = 'Lead' 
	                    and FirstName = 'firstname'];
	    
	    // Assert that the Lead was inserted and has the desired state.
	    System.assert(insertedLead.State == 'CO');
    }
    
    static testmethod void testTriggerAccountBeforeInvalidState() {
        List<Lead> insertedLead;
        Exception dmle;

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Lead lead = new Lead();
        lead.lastName = 'Lead';
        lead.FirstName = 'firstname';
        lead.PostalCode = '21204';
        lead.State = 'Co';
        
        try {
	        Test.startTest();
	        insert lead;
	        Test.stopTest();
        } catch (DmlException e) {
        	dmle = e;
        }
        
        /* Get the Dealer Quotes Request object with fields filled in after trigger executes. */
        insertedLead = [select id 
	                    from Lead
	                    where LastName = 'Lead' 
	                    and FirstName = 'firstname'];
        
        /* Assert that the row was not inserted and an exception was caught. */
		System.assert(insertedLead.isEmpty());
		System.assert(dmle != null);
    }
}