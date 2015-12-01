/**********************************************************************
Name: Lead_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a Lead is created or updated, check to make
sure the state is a valid 2-letter code if it is
present.
 
Related Class : LeadClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 04/19/2011 Created

***********************************************************************/

trigger Lead_Before on Lead (before insert, before update) {    
    // Get list of states passed to trigger
    List<String> states = new List<String>();
    for (Lead lead : Trigger.new) {
    	states.add(lead.State);
    }
    
    // Look for matches in the State__c to the list of states from the trigger and get a list
    // of the matching state abbreviations.
    List<State__c> matches = [select id, name, name__c from state__c where name in :states];
    Set<String> stateCodes = new Set<String>();
    for (State__c state: matches) {
    	stateCodes.add(state.name);
    }
    
    // Go through the trigger inputs and see if a matching state was found for each. If not,
    // add an error to that row.
    for (Lead lead : Trigger.new) {
		if (lead.State != null && lead.State != '' && 
		    (stateCodes == null || !stateCodes.contains(lead.State))) {
			lead.State.addError(System.Label.State_Invalid_Error);
		}
    }
}