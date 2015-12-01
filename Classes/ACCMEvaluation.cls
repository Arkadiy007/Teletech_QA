/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Code behind for AgentConsole_CM_LandingPage page. This page is set to override 
the standard campaign member view in the SF envionrment. This code behind 
evaluates which page to send the user too when the campaign member is viewed.

Code behind for StandardCampaignMember page. This page simply loads the normal
campaignmember view with the apex:detail tag, using the id from this controller
upon its original selection.

Business situation is to handle call backs - agent calls customer day one,
customer calls back same day (standard process happens) :: customer calls back
next day, agent looks up customer, selects campaign member record, this class
intervenes and determines the agent needs to see an agent console replica so 
basically they can do the excate same thing they would have done if the 
customer answered the first time, but use different services for TMS.

ACCMEvaluation stands for Agent Console CampaignMember Evaluation to avoid
a 39 character class name.

Class:              ACCMEvaluation
Author:				JJ Heldman
Date:               02/22/12
Version:            1
Last Updated:       02/24/12
    * Started
    * Completed


*/

public with sharing class ACCMEvaluation
{
	// -------- Constants --------
	private final string SM_AGENT = system.label.ServiceMarketing;
	private final string STANDARD_CAMPAIGNMEMBER = 'StandardCampaignMember';
	private final string INBOUND_CALLBACK_CONSOLE = 'AgentConsole_CM';
	
	// -------- Constructor --------
	// Retrieve CampaignMember record and user role, then set the page to
	// display
    public ACCMEvaluation(ApexPages.StandardController campaignMemeber)
    {
    	CMember = (CampaignMember) campaignMemeber.getRecord();
    	
    	RetrieveUserRole();
    	AssignPageDisplay();
    }

    // -------- Variables --------
    // Hold users role
	private string userRole;
	
	// -------- Properties --------
	// CampaignMember selected record
	public CampaignMember CMember {get; set;}  
	
	// Which page to display
	public string PageDisplay {get; set;}
	
	// -------- Methods --------
	// Get the user role, which helps determine which page to show
	private void RetrieveUserRole()
	{
		User currentUser = [SELECT UserRoleId FROM User WHERE Id =: 
			UserInfo.getUserId() AND IsActive = true LIMIT 1];
		
		if(currentUser.UserRoleId != null)
		{
			UserRole userRole = [SELECT Name FROM UserRole WHERE Id = 
				:currentUser.UserRoleId LIMIT 1]; 
			
			this.userRole = userRole.Name;
		}
	}
	
	// Assign the page display to load
	private void AssignPageDisplay()
	{
		if(userRole != SM_AGENT)
			PageDisplay = STANDARD_CAMPAIGNMEMBER;
		else
			PageDisplay = INBOUND_CALLBACK_CONSOLE;
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		Contact contact = new Contact();
		contact.LastName = 'Inbound Callback Test';
		insert contact;
		
		Campaign campaign = new Campaign();
        campaign.Name = 'InboundCallBack Test';
        campaign.StartDate = date.newinstance(1977, 6, 27);
        campaign.EndDate = date.newinstance(1977, 7, 03);
        campaign.IsActive = true;
		insert campaign;
		
		CampaignMember campaignMember = new CampaignMember();
		campaignMember.CampaignId = campaign.Id;
		campaignMember.ContactId = contact.Id;
		insert campaignMember;
		
		Profile profile = [SELECT Id FROM Profile WHERE 
			Name='System Administrator'];
		
		UserRole userRole = [SELECT Id FROM UserRole 
			WHERE Name =: system.label.ServiceMarketing LIMIT 1];
		
      	User adminUserTest = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
      		UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
      	
      	User agentUserTest = new User(Alias = 'agentUT', Email = 'fake@fake.com', 
      		EmailEncodingKey = 'UTF-8', LastName = 'CB_AGENT__TMS_Testing', 
      		LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
      		ProfileId = profile.Id, TimeZoneSidKey = 'America/Los_Angeles', 
      		UserName = 'CB_AGENT__TMS_Testing@CB_AGENT__TMS_Testing.com', 
      		UserRoleId = userRole.Id);
		
		ApexPages.StandardController campaignMemberController = 
			new ApexPages.StandardController(campaignMember);
		
		System.runAs(adminUserTest)
		{
			ACCMEvaluation testClass = 
				new ACCMEvaluation(campaignMemberController);
		}
		
		System.runAs(agentUserTest)
		{
			ACCMEvaluation testClass = 
				new ACCMEvaluation(campaignMemberController);
		}
	}
}