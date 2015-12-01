/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

For the Nissan Outbound / Inbound calls, this class is used to retrieve the 
CallCentreID of a user, which will effect web service call end points. 
Presently 6 or 7 is NNA agents, while 4 is NCI agents.

Initialized in Controller_AgentConsole_CM

Class:              CallCentreID
Author:				JJ Heldman
Date:               02/28/12
Version:            1
Last Updated:       02/28/12
    * Stubbed
    * Completed
*/

public with sharing class CallCentreID
{
	// -------- Constants --------
	// None
	
	// -------- Constructor --------
	// Retrieve the user this data applies too
    public CallCentreID()
    {
    	userRecord = [Select Call_Centre_Id__c From User 
    		Where Id =: UserInfo.getUserId()];
    }

    // -------- Variables --------
	// Record id
   	private integer callCenterID;
   	
   	// The user record to retrieve the value from
   	private User userRecord;
	
	// -------- Properties --------
	// None
	
	// -------- Methods --------
	// Get the id, which will default to 6 if any problems in retrieving the 
	// user record occured (which shouldn't be possible) or in the event the
	// user's call centre is not defined
	public integer CallCentreID()
	{
		if(callCenterID == null)
   		{
   			if(userRecord == null || userRecord.Call_Centre_Id__c == null)
   				callCenterID = 6;
   			else
   				callCenterID = integer.valueOf(userRecord.Call_Centre_Id__c);
   		}
   		
   		return callCenterID;
	}
	
	// -------- Test --------
	// Run as a call center 4 user and a call center not defined user
	static testMethod void ClassTest()
	{
		Profile profile = [SELECT Id FROM Profile WHERE 
			Name='System Administrator'];
		
      	User notDefined = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
      		UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com', 
      		Call_Centre_Id__c = null);
      	
      	User defined = new User(Alias = 'agentUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_AGENT__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey = 'America/Los_Angeles', 
      		UserName = 'CB_AGENT__TMS_Testing@CB_AGENT__TMS_Testing.com',
      		Call_Centre_Id__c = '4');
		
		System.runAs(notDefined)
		{
			CallCentreID testClass = new CallCentreID();
			Integer callCentreID = testClass.CallCentreID();
		}
		
		System.runAs(defined)
		{
			CallCentreID testClass = new CallCentreID();
			Integer callCentreID = testClass.CallCentreID();
		}
	}
}