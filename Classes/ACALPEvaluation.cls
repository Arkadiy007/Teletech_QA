/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

ACALPEvaluation, evaluates user, customer and task information when the page
is visited to determine where the user should be redirected to. The code
behind for the ACALPEvaluation page, which overrides the standard account page.

This was built since CTI is poping accounts on inbound calls. When CTI pops
contacts on inbound calls, excatly like outbound calls, we do not need this.

THIS IS POTENTIAL ISSUE, as we have no way of assuring that the last task
created actually belongs to the customer call that the agent is on, this is as
close as we can get essientially. Sooooo, after speaking with Ray while this
is being forward as a short term solution, we must have more data populated on
the task from CTI (WhoId, WhatId, or ANI__c) prior to hitting this page
for us to get more accurate - although hopefully CTI changes in the future will
simply move to the contact screen correctly, and not the account screen,
and then we don't need this entire file.

If a WhoId is at least already assigned on a task, we know it isn't the task
associated with this customer call so default out. When CTI changes this, we 
can add the whoid or whatid to the original query and and know its tied to 
that customer, or simply have CTI pop contact.

Class:              ACALPEvaluation
Author:				JJ Heldman
Date:               03/24/12
Version:            1
Last Updated:       03/24/12
    * Stubbed
    * Completed
    * 04/02/12	JJ	Bug fix, DPIC and CCC needs directed to standard accounts
    	when available, not contacts, changed constructor logic; Also changed
    	the way in which the page redirects as it was causing link selection
    	issues for DPIC
    
//////// TODO ////////
Encapsulate retrieveUserRole with CallCentreId file, change CallCentreId to
	ServiceMarketingUserDetails
	
In the long run this file and logic should not exist, but the change above
will be useful for other future details as well
*/

public with sharing class ACALPEvaluation
{
	// -------- Constants --------
	private final string CALLTYPE_INBOUND = 'Inbound';
	private final string USER_ROLE_FAILURE = 'Failed';
	
	// -------- Constructor --------
    public ACALPEvaluation(ApexPages.StandardController controller)
    {
    	string accountID = ((Account) controller.getRecord()).Id;
    	RetrieveContact(accountID);
    	
    	if(contact == null || 
    		RetrieveUserRole() != system.label.ServiceMarketing)
    		BuildAccountRedirect(accountID);
    	else
    		DetermineLandingPage(contact.Id);
    }
    
    // -------- Variables --------
    private CampaignMember campaignMember;
	private ValidationUtility validate = new ValidationUtility();
	
	// -------- Properties --------
	private Contact contact {get; set;}
	public PageReference IncludePage {get; set;}
	
	// -------- Methods --------
	// Assign the redirect page based on criteria
	private void DetermineLandingPage(string contactId)
	{
		try
    	{
            Datetime lastHour = Datetime.Now().addHours(-1);

    		Task ctiCreatedTask = [SELECT Id, CallType, ANI__c, CreatedDate, 
    			WhoId, Subject FROM Task WHERE Subject like 'Inbound%' 
    			AND CreatedById =: UserInfo.getUserId()
    			AND CallDisposition__c =: null
    			AND CreatedDate >= :lastHour
    			ORDER BY CreatedDate DESC LIMIT 1];
    		
    		if(!validate.IsStringNullOrEmpty(ctiCreatedTask.WhoId))
    		{
    			BuildContactRedirect(contactId);
    		}
    		else
    		{
				if(!validate.IsStringNullOrEmpty(ctiCreatedTask.CallType) &&
    				ctiCreatedTask.CallType == CALLTYPE_INBOUND)
    			{
    				CampaignMember campaignMemberRecord = [SELECT Id, 
						CampaignMember.Campaign.isActive, 
						CampaignMember.Campaign.CreatedDate FROM CampaignMember 
						WHERE CampaignMember.ContactId =: contactId 
						ORDER BY CampaignMember.Campaign.CreatedDate 
						DESC LIMIT 1];
									
    				campaignMember = campaignMemberRecord;
    			}
    			else
    			{
    				BuildContactRedirect(contactId);
    			}
    		}
    	}
    	catch(Exception error)
    	{	
    		BuildContactRedirect(contactId);
    	}
	}
	
	// Use the AccountId to fetch the Contact Id for existing functionality
	private void RetrieveContact(string accountID)
	{
		try
		{
			contact = [SELECT Id, MobilePhone, HomePhone, OtherPhone 
				FROM Contact WHERE AccountId =: accountID LIMIT 1];
		}
		catch(Exception e)
		{
			contact = null;
		}
	}
	
	// Determine if user is a Service Marketing role
	private string RetrieveUserRole()
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
		if(IncludePage == null)
		{
			IncludePage = new PageReference('/apex/AgentConsole_CM?id=' + 
				campaignMember.Id);
		}
		
		return IncludePage.setRedirect(true);
	}
	
	// Build page redirects to standard, non-overridden views
	private void BuildAccountRedirect(string accountID)
	{
		IncludePage = new PageReference('/' + accountID);
		IncludePage.getParameters().put('nooverride', '1');
	}
	
	private void BuildContactRedirect(string contactID)
	{
		IncludePage = new PageReference('/' + contactID);
		IncludePage.getParameters().put('nooverride', '1');
	}

	// -------- Test --------
	@isTest static void ClassTest()
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
		
		RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
			system.label.dealer AND SobjectType = 'Account' LIMIT 1];
		
		RecordType person = [SELECT Id FROM RecordType WHERE Name=: 
			system.label.TMS AND SobjectType = 'Account' LIMIT 1];
		

		
		ACALPEvaluation testClass;

		//// Test Case 1 - No Contact Record ////
		System.runAs(defined)
		{
		Account dealerAccount = new Account();
        dealerAccount.name = 'testDealerAccount';
        dealerAccount.RecordTypeId = dealer.id;
        dealerAccount.Dealer_Attributes_Text__c = 'EIX';
        dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
		
		Account secondCustomer = new Account();
		secondCustomer.FirstName = 'OtherTest';
        secondCustomer.MiddleName__c = 'OtherTest';
        secondCustomer.LastName ='OtherTest';
		secondCustomer.RecordTypeId = person.Id;
		insert secondCustomer;
		
		Task taskRecordInbound = new Task();
		taskRecordInbound.CallType = 'Inbound';
		taskRecordInbound.Subject = 'InboundCallExample';
		taskRecordInbound.CreatedDate = datetime.now();

			ApexPages.StandardController dealerController = 
				new ApexPages.StandardController(dealerAccount);
			
			testClass = new ACALPEvaluation(dealerController);
		}

		//// Test Case 2 - Not a Service Marketing Role user ////
		System.runAs(notDefined)
		{
		Account customer = new Account();
		customer.FirstName = 'Test';
        customer.MiddleName__c = 'Test';
        customer.LastName ='Test';
		customer.RecordTypeId = person.Id;
		insert customer;

			ApexPages.StandardController customerController = 
				new ApexPages.StandardController(customer);
			
			testClass = new ACALPEvaluation(customerController);
		}

		//// Test Case 3 - Inbound Call Active Campaign ////		
		System.runAs(defined)
		{
		Account customer = new Account();
		customer.FirstName = 'Test';
        customer.MiddleName__c = 'Test';
        customer.LastName ='Test';
		customer.RecordTypeId = person.Id;
		insert customer;

		Contact contactRecord = [SELECT Id FROM Contact 
			WHERE AccountId =: customer.Id limit 1];
		
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

			ApexPages.StandardController customerController = 
				new ApexPages.StandardController(customer);

		Task taskRecordInbound = new Task();
		taskRecordInbound.CallType = 'Inbound';
		taskRecordInbound.Subject = 'InboundCallExample';
		taskRecordInbound.CreatedDate = datetime.now();

			insert taskRecordInbound;
			testClass = new ACALPEvaluation(customerController);
			testClass.IncludePage = null;
			testClass.Redirect();
		}

		//// Test Case 4 - Inbound Failures, wrong task, outbound call ////
		System.runAs(defined)
		{
		Account customer = new Account();
		customer.FirstName = 'Test';
        customer.MiddleName__c = 'Test';
        customer.LastName ='Test';
		customer.RecordTypeId = person.Id;
		insert customer;

		Account secondCustomer = new Account();
		secondCustomer.FirstName = 'OtherTest';
        secondCustomer.MiddleName__c = 'OtherTest';
        secondCustomer.LastName ='OtherTest';
		secondCustomer.RecordTypeId = person.Id;
		insert secondCustomer;

		Contact secondContactRecord = [SELECT Id FROM Contact 
			WHERE AccountId =: secondCustomer.Id limit 1];

		Task taskRecordInbound = new Task();
		taskRecordInbound.CallType = 'Inbound';
		taskRecordInbound.Subject = 'InboundCallExample';
		taskRecordInbound.CreatedDate = datetime.now();

			insert taskRecordInbound;
			ApexPages.StandardController customerController = 
				new ApexPages.StandardController(customer);
			
			taskRecordInbound.CallType = 'Outbound';
			update taskRecordInbound;
			testClass = new ACALPEvaluation(customerController);
			
			taskRecordInbound.WhoId = secondContactRecord.Id;
			update taskRecordInbound;
			testClass = new ACALPEvaluation(customerController);
			
			delete taskRecordInbound;
			testClass = new ACALPEvaluation(customerController);
		}
	}
}