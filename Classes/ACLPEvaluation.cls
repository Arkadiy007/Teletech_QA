/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Code behind for the ACLPEvaluation. This page overrides the Contact 
View of the Nissan SalesForce instance, and is the popped page when CTI queries
the contact record.

Essientially this evaluates and routes to a page for the user under 
the following conditions:
	1) No CampaignMember Record or Task Record found for the user > 
		Redirect PersonAccount
	2) Outbound call type with an active campaign
		Redirect AgentConsole
	3) Outbound call type with an inactive campaign
		Redirect PersonAccount
	4) Inbound call type
		Redirect to AgentConsole_CM_LandingPage

Class:              ACLPEvaluation
Author:				JJ Heldman
Date:               03/14/12
Version:            1
Last Updated:       03/14/12
    * Stubbed, Completed
    * 03/26/2012: JJ - due to minimal deployment of new CTI component, we can
    	only check if the CallType is Inbound - anything else will follow the
    	outbound logic, so changed script to accomidate that
////////////////////////////////////////////////////////////////////////////////
*/

public with sharing class ACLPEvaluation
{
	// -------- Constants --------
	private final string CALLTYPE_INBOUND = 'Inbound';
	private final string USER_ROLE_FAILURE = 'Failed';
	
	// -------- Constructor --------
    public ACLPEvaluation(ApexPages.StandardController controller)
    {
    	string contactID = ((Contact) controller.getRecord()).Id;
    	
    	if(retrieveUserRole() != system.label.ServiceMarketing)
    		IncludePage = system.label.StandardContact + '?id=' + contactID;
    	else
    		determineLandingPage(contactID);
    }

    // -------- Variables --------
	private CampaignMember campaignMember;
	private ValidationUtility validate = new ValidationUtility();
	
	// -------- Properties --------
	public string IncludePage {get; set;}
	
	// -------- Methods --------
	// Assign the redirect page based on criteria
	private void determineLandingPage(string contactID)
	{
		try
    	{	
    		Task ctiCreatedTask = [SELECT Id, CallType, CreatedDate FROM Task 
    			WHERE WhoId =: contactID ORDER BY CreatedDate DESC LIMIT 1];
    		CampaignMember campaignMemberRecord = [SELECT Id, 
    			CampaignMember.Campaign.isActive, 
    			CampaignMember.Campaign.CreatedDate FROM CampaignMember 
    			WHERE CampaignMember.ContactId =: contactId 
    			ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
    		
    		if(!validate.IsStringNullOrEmpty(ctiCreatedTask.CallType) &&
    			ctiCreatedTask.CallType == CALLTYPE_INBOUND)
    		{
    			campaignMember = campaignMemberRecord;
    		}
    		else
    		{
    			if(campaignMemberRecord.Campaign.isActive)
    				IncludePage = system.label.AgentConsole + 
    					'?id=' + contactID;
    			else
    				IncludePage = system.label.StandardContact + 
    					'?id=' + contactID;
    		}
    	}
    	catch(Exception error)
    	{	
    		IncludePage = system.label.StandardContact + '?id=' + contactID;
    	}
	}
	
	// Determine if user is a Service Marketing role
	private string retrieveUserRole()
	{
		string result = USER_ROLE_FAILURE;
		
		User agentRecord = [SELECT Id, UserRoleId FROM User 
			WHERE Id =: UserInfo.getUserId() AND IsActive = TRUE];
		
		if(agentRecord != null)
		{
			if(agentRecord.UserRoleId != null)
			{
				UserRole userRole = [SELECT Id, Name FROM UserRole 
					WHERE Id =: agentRecord.UserRoleId]; 
				result = userRole.Name;
			}
		}
		
		return result;
	}
	
	// Return redirect to new page
	public PageReference Redirect()
	{
		return (IncludePage == null) ? 
			new PageReference('/apex/AgentConsole_CM?id=' + 
				campaignMember.Id) :
			new PageReference('/apex/'  + IncludePage);
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		Profile profile = [SELECT Id FROM Profile WHERE 
			Name='System Administrator'];
		
		UserRole userRole = [SELECT Id FROM UserRole 
			WHERE Name =: system.label.ServiceMarketing LIMIT 1];
		
      	User notDefined = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
      		UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
      	
      	User defined = new User(Alias = 'agentUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_AGENT__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey = 'America/Los_Angeles', 
      		UserName = 'CB_AGENT__TMS_Testing@CB_AGENT__TMS_Testing.com',
      		UserRoleId = userRole.Id);
				
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
		
		Task taskRecordInbound = new Task();
		taskRecordInbound.CallType = 'Inbound';
		taskRecordInbound.WhoId = contactRecord.Id;
		taskRecordInbound.CreatedDate = 
			datetime.newInstance(2012, 03, 14, 00, 00, 00);
		insert taskRecordInbound;
		
		ApexPages.StandardController contactController = 
			new ApexPages.StandardController(contactRecord);
		
		ACLPEvaluation testClass;
		
		//// Test Case 1 - Not a Service Marketing Role user ////
		System.runAs(notDefined)
		{
			testClass = new ACLPEvaluation(contactController);
		}
		
		//// Test Case 2 - No Campaign ////
		System.runAs(defined)
		{
			testClass = new ACLPEvaluation(contactController);
		}
		
		//// Test Case 3 - Inbound Call ////
		RecordType campaignType = [SELECT Id, Name FROM RecordType 
			WHERE SobjectType = 'Campaign' 
			AND Name = 'Nissan English Evening'];
		
		Campaign campaign = new Campaign();
		campaign.RecordTypeId = campaignType.Id;
        campaign.Name = campaignType.Name;
        campaign.StartDate = date.newinstance(1977, 6, 27);
        campaign.EndDate = date.newinstance(1977, 7, 03);
        campaign.IsActive = true;
        insert campaign;
        
		Vehicle__c vehicle = new Vehicle__c();
        vehicle.Latest_Recorded_Mileage_Number__c = 88888;
        vehicle.Latest_Recorded_Mileage_Units__c = '?';
        insert vehicle;
        
		CampaignMember campaignMember = new CampaignMember();
		campaignMember.CampaignId = campaign.Id;
		campaignMember.ContactId = contactRecord.Id;
		campaignMember.Vehicle__c = vehicle.Id;
		campaignMember.Service_Marketing_Call_Type__c = 'TST';
		insert campaignMember;
		
		System.runAs(defined)
		{
			testClass = new ACLPEvaluation(contactController);
			
			testClass.IncludePage = 'Anything else';
			testClass.Redirect();
			testClass.IncludePage = null;
			testClass.Redirect();
		}
		
		//// Test Case 4 - Outbound Call with Active Campaign ////
		Task taskRecordOutbound = new Task();
		taskRecordOutbound.CallType = 'Outbound';
		taskRecordOutbound.WhoId = contactRecord.Id;
		taskRecordOutbound.CreatedDate = 
			datetime.newInstance(2012, 03, 14, 00, 00, 01);
		insert taskRecordOutbound;
		
		System.runAs(defined)
		{
			testClass = new ACLPEvaluation(contactController);
		}
		
		//// Test Case 5 - Outbound Call Inactive Campaign ////
		campaign.IsActive = false;
		upsert campaign;
		
		System.runAs(defined)
		{
			testClass = new ACLPEvaluation(contactController);
		}
	}
}