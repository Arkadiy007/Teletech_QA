/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This is the parent class for Controller_AgentConsole_CM, which shares 
functionality with Controller_AgentConsole. It contains methods used by both
classes.

Class:              Controller_Base
Author:				JJ Heldman
Date:               03/15/2012
Version:            1
Last Updated:       03/15/2012
    * Stubbed, Complete
*/

public virtual with sharing class Controller_Base
{
	// -------- Constants --------
	// None
	
	// -------- Constructor --------
    public Controller_Base(){}

    // -------- Variables --------
    // Validation class
	private ValidationUtility confirm = new ValidationUtility();
	
	// Used when sending data to the new pages launched by the webservices
   	private Contact transferContact;
   	private Account transferAccount;
	
	// -------- Properties --------
	public CampaignMember campaignMember {get; set;}
	public Account campaignMemberAccount {get; set;}
	public Contact campaignMemberContact {get; set;}
	public Account campaignMemberDealer {get; set;}
	public Task agentConsoleData {get; set;}
	public Vehicle__c vehicle {get; set;}
	
	// For web service calls
	public string APIName {get; set;}
	
	// Picklists built from the custom fields added to objects
	public List<SelectOption> CommentAudience {get; set;}
	public List<SelectOption> ConsentValues {get; set;}
	public List<SelectOption> PhoneSequences {get; set;}
	public List<SelectOption> WorkPhoneSequences {get; set;}
	public List<SelectOption> MobilePhoneSequences {get; set;}
	public List<SelectOption> EmailTypeValues {get; set;}
	
	// Used to display a call history list of sorts
	public List<Task> CallHistoryList {get; set;}
	
	// -------- Methods --------
	// Build the picklists based the custom fields added to objects
	protected void BuildPicklists()
	{
		List<Schema.PicklistEntry> buildFromList;
		
		Schema.Describefieldresult commentAudienceData = 
			Schema.Sobjecttype.Task.fields.Comment_Audience__c;
		buildFromList = commentAudienceData.getPicklistValues();
		CommentAudience = CreateListFromObject(buildFromList);
		
		Schema.DescribeFieldResult homePhoneConsent = 
			Schema.sObjectType.Account.fields.Home_Phone_Do_Not_Call__c;
		buildFromList = homePhoneConsent.getPicklistValues();
		ConsentValues = CreateListFromObject(buildFromList);
		
		Schema.DescribeFieldResult homePhoneSequence = 
			Schema.sObjectType.Account.fields.Home_Phone_Sequence__c;
		buildFromList = homePhoneSequence.getPicklistValues();
		PhoneSequences = CreateListFromObject(buildFromList);
		
		Schema.DescribeFieldResult workPhoneSequence = 
			Schema.sObjectType.Account.fields.Other_Phone_Sequence__c;
		buildFromList = workPhoneSequence.getPicklistValues();
		WorkPhoneSequences = CreateListFromObject(buildFromList);
		
		Schema.DescribeFieldResult mobilePhoneSequence = 
			Schema.sObjectType.Account.fields.Mobile_Phone_Sequence__c;
		buildFromList = mobilePhoneSequence.getPicklistValues();
		MobilePhoneSequences = CreateListFromObject(buildFromList);
		
		Schema.DescribeFieldResult emailType1 = 
			Schema.sObjectType.Account.fields.Email_Type_1__c;
		buildFromList = emailType1.getPicklistValues();
		EmailTypeValues = CreateListFromObject(buildFromList);
	}
	
	// Helper method for BuildPicklists, one cycle set of script
	private List<SelectOption> CreateListFromObject(
		List<Schema.PicklistEntry> buildFromList)
	{
		List<SelectOption> buildList = new List<SelectOption>();
		
		for(Schema.Picklistentry value : buildFromList)
		{
			buildList.add(new SelectOption(value.getLabel(), 
				value.getValue()));
		}
		
		return buildList;
	}
	
	// This is passed an object to evaluate and return what the header display
	// should be for the page
	protected string Header()
	{
        string header = 'Call Back: ';
        string nonSolicit = '';
        
        if(campaignMember.Non_Solicit__c)
        	nonSolicit = system.label.Non_Solicit;
        
        if(campaignMember.Service_Marketing_Call_Type__c == system.label.NSC)
       		header += system.label.Overdue_Service_Call + nonSolicit;
        else if(campaignMember.Service_Marketing_Call_Type__c == 
        	system.label.WLC)
        	header += system.label.Welcome_Call + nonSolicit;
       	else if(campaignMember.Service_Marketing_Call_Type__c == 
       		system.label.SFC)
       		header += system.label.Service_Follow_up_Call + nonSolicit;
       	else if(campaignMember.Service_Marketing_Call_Type__c == 
       		system.label.WFC)
       		header += system.label.Warranty_Followup_Call + nonSolicit;
       	
        return header;
    }
    
    // The following are passed an object to evaluate if the dealer is
    // of a particular type
    protected boolean IsXTimeDealer()
   	{
    	return (!IsStringNullOrEmpty(
    		campaignMemberDealer.Dealer_Attributes_Text__c) 
    		&& campaignMemberDealer.Dealer_Attributes_Text__c.contains(
    		system.label.XTime)) ? true : false;
    }
    
    protected string IsExpressDealer()
    {
        return (!IsStringNullOrEmpty(
        	campaignMemberDealer.Dealer_Attributes_Text__c) 
    		&& campaignMemberDealer.Dealer_Attributes_Text__c.contains(
    		system.label.Express)) ? system.label.YES : system.label.NO;
    }
    
    // Do we need to show a send email option for this customer
    protected boolean DisplaySendEmailCheckbox()
    {
        boolean displaySendEmailCustomField;
        
        if(!IsStringNullOrEmpty(
        	campaignMemberDealer.Dealer_Attributes_Text__c) &&
        	!IsStringNullOrEmpty(campaignMember.Incentive_Offer__c))
        {
            if(campaignMemberDealer.Dealer_Attributes_Text__c.contains(
            	system.label.Incentives))
                displaySendEmailCustomField = true;
            else
                displaySendEmailCustomField = false;
        }
        else
        {
            displaySendEmailCustomField = false;
        }
        
        return displaySendEmailCustomField;
    }
    
    // The following send the agent to a new page for data from the TMS or
   	// TMS_NCI webservices
   	protected PageReference ContactServicePage()
   	{
        return new PageReference('/apex/contact_Webservices?&' + 
        	system.label.api + '=' + APIName + '&' + system.label.id +
        	'=' + GetTransferAccount().Id + '&' + system.label.contactID +
        	'=' + GetTransferContact().Id); 
    }
   	
   	protected PageReference DateTimePage()
   	{
        return new PageReference('/apex/CheckDateTime?&' + system.label.api + 
        	'=' + APIName + '&' + system.label.id + '=' + 
        	GetTransferAccount().Id + '&' + system.label.contactID + '=' + 
        	GetTransferContact().Id + '&' + system.label.Type + '=contact');
    }
    
	protected PageReference DatePage()
	{
        return new PageReference('/apex/CheckDate?&' + system.label.api + '=' + 
        	APIName + '&' + system.label.id + '=' + GetTransferAccount().Id +
        	'&' + system.label.contactID + '=' + GetTransferContact().Id + 
        	'&' + system.label.Type+'=contact');
    }
    
   	// Helper methods for the page launchers
   	private Contact GetTransferContact()
   	{
   		if(transferContact == null)
   			transferContact = [SELECT Id, AccountId FROM Contact 
   				WHERE Id = :campaignMemberContact.id];
   		
   		return transferContact;
   	}
   	
   	private Account GetTransferAccount()
   	{
   		if(transferAccount == null)
   			transferAccount = [SELECT Name, Id FROM Account 
        	WHERE Id = :campaignMemberContact.AccountId];
        
        return transferAccount;
   	}
   	
   	// Validate agent entries
   	protected void ValidateTaskFields()
   	{
   		pattern nonNumber = Pattern.compile('\\D');
   		
   		if(!IsStringNullOrEmpty(agentConsoleData.Call_Back_Phone__c))
   			nonNumber.matcher(
   			agentConsoleData.Call_Back_Phone__c).replaceAll('');
   		
   		if(!IsStringNullOrEmpty(agentConsoleData.CallDisposition__c) && 
   			agentConsoleData.CallDisposition__c.contains(
   			system.label.Callback))
   		{
   			if(IsDateTimeNull(agentConsoleData.Call_Back_Time__c) || 
   				IsStringNullOrEmpty(agentConsoleData.Call_Back_Phone__c))
   				AddErrorMessage(
   					system.label.Error_Message_on_Call_Disposition);
   			
   			if(!IsDateTimeNull(agentConsoleData.Call_Back_Time__c) || 
   				agentConsoleData.Call_Back_Daytime_Indicator__c)
   				AddErrorMessage(
   					system.label.Call_Back_Time_Not_On_Callback);
   			
   			if(agentConsoleData.Call_Back_Time__c <= system.now())
   				AddErrorMessage(
   					system.label.Call_Back_Time_Must_Be_Future);
   		}
   		
   		if(IsStringNullOrEmpty(agentConsoleData.Service_Description__c))
   		{
   			if(agentConsoleData.CallDisposition__c == 
   				system.label.Appointment_Lead ||
   				agentConsoleData.CallDisposition__c == 
   				system.label.Appointment_Requested)
   				AddErrorMessage(system.label.Service_Description_is_Required);
   		}
   		
   		if(agentConsoleData.CallDisposition__c == 
   			system.label.Appointment_Requested)
   		{
   			if(IsDateTimeNull(agentConsoleData.Request_Date__c) ||
   				agentConsoleData.Request_Time__c == null)
   				AddErrorMessage(
   				system.label.Request_Date_and_Time_are_Required);
   		}
   		
   		if(!IsDateTimeNull(agentConsoleData.Request_Date__c) &&
   			IsStringNullOrEmpty(agentConsoleData.Action_Type__c))
   			AddErrorMessage(
   			system.label.Action_Type_is_required_if_Request_Date_is_selected);
   		
   		if(IsStringNullOrEmpty(agentConsoleData.Customer_Experience__c))
   			AddErrorMessage(system.label.Customer_Experience_is_Required);
   		
   		if(IsDateTimeNull(agentConsoleData.Mail_Stop_Start_Date__c) && 
   			!IsDateTimeNull(agentConsoleData.Mail_Stop_End_Date__c) ||
   			IsDateTimeNull(agentConsoleData.Mail_Stop_End_Date__c) && 
   			!IsDateTimeNull(agentConsoleData.Mail_Stop_Start_Date__c))
   			AddErrorMessage(system.label.Mail_Stop_Date_Error);
   		
   		if(IsDateTimeNull(agentConsoleData.Temp_Away_Start_Date__c) && 
   			!IsDateTimeNull(agentConsoleData.Temp_Away_End_Date__c) ||
   			IsDateTimeNull(agentConsoleData.Temp_Away_End_Date__c) && 
   			!IsDateTimeNull(agentConsoleData.Temp_Away_Start_Date__c))
   			AddErrorMessage(system.label.Temp_Away_Date_Error);
   	}
   	
   	// Validate the account fields for the customer as required
   	protected void ValidateCustomerAccountFields()
   	{
   		if(IsStringNullOrEmpty(campaignMemberAccount.FirstName))
   			AddErrorMessage(system.label.First_name_is_a_required_field);
   		
   		if(IsStringNullOrEmpty(campaignMemberAccount.PersonMailingCity))
   			AddErrorMessage(system.label.Please_provide_Mailing_City);
   		
   		if(IsStringNullOrEmpty(campaignMemberAccount.PersonMailingCountry))
   			AddErrorMessage(system.label.Please_provide_Mailing_Country);
   		
   		if(IsStringNullOrEmpty(campaignMemberAccount.PersonMailingPostalCode))
   			AddErrorMessage(system.label.Please_provide_Mailing_Postal_Code);
   		
   		if(IsStringNullOrEmpty(campaignMemberAccount.PersonMailingState) &&
   			!IsTest)
   			AddErrorMessage(system.label.Please_provide_Mailing_State);
   		
   		if(IsStringNullOrEmpty(campaignMemberAccount.PersonMailingStreet))
   			AddErrorMessage(system.label.Address_Is_Required);
   		
   		if(campaignMemberAccount.Home_Phone_Sequence__c == system.label.None)
   		{
   			if(!IsStringNullOrEmpty(campaignMemberAccount.PersonHomePhone))
   				AddErrorMessage(
   				system.label.If_phone_is_populated_you_must_selected_a_phone_sequence);
   		}
   		else
   		{
   			if(campaignMemberAccount.Home_Phone_Sequence__c == 
   				campaignMemberAccount.Other_Phone_Sequence__c)
   				AddErrorMessage(
   				system.label.Home_Phone_Sequence_cannot_equal_Work_Phone_sequence);
   		}
   		
   		if(campaignMemberAccount.Other_Phone_Sequence__c == system.label.None)
   		{
   			if(!IsStringNullOrEmpty(campaignMemberAccount.PersonOtherPhone))
   				AddErrorMessage(
   				system.label.If_phone_is_populated_you_must_selected_a_phone_sequence);
   		}
   		else
   		{
   			if(campaignMemberAccount.Other_Phone_Sequence__c == 
   				campaignMemberAccount.Mobile_Phone_Sequence__c)
   				AddErrorMessage(
   				system.label.Other_phone_Sequence_cannot_equal_Mobile_Phone_sequence);
   		}
   		
   		if(campaignMemberAccount.Mobile_Phone_Sequence__c == system.label.None)
   		{
   			if(!IsStringNullOrEmpty(campaignMemberAccount.PersonMobilePhone))
   				AddErrorMessage(
   				system.label.If_phone_is_populated_you_must_selected_a_phone_sequence);
   		}
   		else
   		{
   			if(campaignMemberAccount.Mobile_Phone_Sequence__c == 
   				campaignMemberAccount.Home_Phone_Sequence__c)
   				AddErrorMessage(
   				system.label.Home_Phone_Sequence_cannot_equal_Mobile_Phone_sequence);
   		}
   	}
    
    // Wrapper for adding error messages to a page
    protected void AddErrorMessage(string errorMessage)
   	{
   		ApexPages.addMessage(new ApexPages.message(
   			ApexPages.severity.warning, errorMessage));
   	}
   	
    // Wrappers for connecting to the ValiadtionUtility
    public boolean IsStringNullOrEmpty(string value)
   	{
   		return confirm.IsStringNullOrEmpty(value);
   	}
   	
   	public boolean IsDateTimeNull(datetime value)
   	{
   		return confirm.IsDateTimeNull(value);
   	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		string resultS;
		boolean resultB;
		Controller_Base testClass = new Controller_Base();
		CampaignMember testMember = new CampaignMember();
		Account testDealer = new Account();
		Contact testContact = new Contact();
		
		//// Test Case 1 - Header values ////
		testMember.Non_Solicit__c = false;
		testMember.Service_Marketing_Call_Type__c = system.label.NSC;
		testClass.campaignMember = testMember;
		resultS = testClass.Header();
		
		testMember.Non_Solicit__c = true;
		testMember.Service_Marketing_Call_Type__c = system.label.WLC;
		testClass.campaignMember = testMember;
		resultS = testClass.Header();
		
		testMember.Service_Marketing_Call_Type__c = system.label.SFC;
		testClass.campaignMember = testMember;
		resultS = testClass.Header();
		
		testMember.Service_Marketing_Call_Type__c = system.label.WFC;
		testClass.campaignMember = testMember;
		resultS = testClass.Header();
		
		//// Test Case 2 - XTime ////
		testClass.campaignMemberDealer = testDealer;
		resultB = testClass.IsXTimeDealer();
		testDealer.Dealer_Attributes_Text__c = 'EIX';
		testClass.campaignMemberDealer = testDealer;
		resultB = testClass.IsXTimeDealer();
		
		//// Test Case 3 - Express Dealer ////
		testClass.campaignMemberDealer = testDealer;
		resultS = testClass.IsExpressDealer();
		testDealer.Dealer_Attributes_Text__c = 'IX';
		testClass.campaignMemberDealer = testDealer;
		resultS = testClass.IsExpressDealer();
		
		//// Test Case 4 - Show Send Email Option ////
		resultB = testClass.DisplaySendEmailCheckbox();
		testMember.Incentive_Offer__c = 'Yes';
		testClass.campaignMember = testMember;
		resultB = testClass.DisplaySendEmailCheckbox();
		testDealer.Dealer_Attributes_Text__c = 'EX';
		testClass.campaignMemberDealer = testDealer;
		resultB = testClass.DisplaySendEmailCheckbox();
		
		//// Test Case 5 - Datetime check ////
		resultB = testClass.IsDateTimeNull(null);
		
		//// Test Case 6 - Page returns ////
		RecordType person = [SELECT Id FROM RecordType WHERE Name=: 
			system.label.TMS AND SobjectType = 'Account' LIMIT 1];
		
		Account testCustomer = new Account();
		testCustomer.FirstName = 'Test';
        testCustomer.MiddleName__c = 'Test';
        testCustomer.LastName ='Test';
        testCustomer.RecordTypeId = person.Id;
        insert testCustomer;
        
        testContact = [SELECT Id, AccountId FROM Contact 
			WHERE AccountId =: testCustomer.Id limit 1];
		
		testClass.campaignMemberContact = testContact;
		
		testClass.APIName = 'TestThis';
		PageReference lcsp = testClass.ContactServicePage();
		PageReference ldtp = testClass.DateTimePage();
		PageReference ldp = testClass.DatePage();
		
		//// Test Case 7 - Task Validations ////
		RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
			system.label.dealer AND SobjectType = 'Account' LIMIT 1];
		
        Account dealerAccount = new Account();
        dealerAccount.name = 'testDealerAccount';
        dealerAccount.RecordTypeId = dealer.id;
        dealerAccount.Dealer_Attributes_Text__c = 'EIX';
        dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
        
		testClass.agentConsoleData = new Task
		(
			Temp_Away_Start_Date__c = date.Today(),
			Temp_Away_End_Date__c = date.Today(),
			Mail_Stop_Start_Date__c = date.Today(),
			Mail_Stop_End_Date__c = date.Today(),
			Preferred_Dealer_Change_Reason__c = 'test PDCR',
			Service_Description__c = 'test SeDe',
			Request_Date__c = date.Today(),
			Request_Time__c = 'test Time why is this string?',
			Action_Type__c = 'test Action Type',
			Preferred_Dealer_Change__c = 'test PreDealerChange',
			CallDisposition__c = system.label.Appointment_Lead,
			Send_Email_Request_Indicator__c = true,
			Deceased__c = false,
			Agent_ID__c = '88',
			Call_Back_Phone__c = '555 555 5555',
			Call_Back_Time__c = date.Today(),
			Call_Back_Daytime_Indicator__c = true,
			CallObject = 'This is a string',
			Description = 'This is a test description',
			Question_1__c = true,
			Question_2__c = true,
			Satisfaction__c = 'test satisfaction',
			Comment_Audience__c = 'test comment audience',
			Customer_Experience__c = 'test customer experience'
		);
		
		testClass.isTest = true;
		testClass.ValidateTaskFields();
		testClass.isTest = false;
		
		testCustomer.FirstName = '';
        testCustomer.MiddleName__c = 'Test';
        testCustomer.LastName ='Call';
        testCustomer.RecordTypeId = person.Id;
        testCustomer.Preferred_Dealer_Id__c = dealerAccount.Id;
        testCustomer.Home_Phone_Sequence__c = system.label.None;
        testCustomer.Other_Phone_Sequence__c = system.label.None;
        testCustomer.Mobile_Phone_Sequence__c = system.label.None;
        testCustomer.PersonHomePhone = '8888888888';
        testCustomer.PersonOtherPhone = '8888888888';
        testCustomer.PersonMobilePhone = '8888888888';
        testCustomer.PersonMailingCity = '';
        testCustomer.PersonMailingCountry = '';
        testCustomer.PersonMailingPostalCode = '';
        testCustomer.PersonMailingStreet = '';
        testCustomer.Alternate_Email__c = '';
        update testCustomer;
        testClass.campaignMemberAccount = testCustomer;
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = 'Callback',
			Mail_Stop_Start_Date__c = date.Today(),
			Temp_Away_Start_Date__c = date.Today()
		);
		
		testClass.ValidateTaskFields();
		testClass.ValidateCustomerAccountFields();
		
        testCustomer.Home_Phone_Sequence__c = 'same';
        testCustomer.Other_Phone_Sequence__c = 'same';
        testCustomer.Mobile_Phone_Sequence__c = 'same';
        update testCustomer;
        testClass.campaignMemberAccount = testCustomer;
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = 'Callback',
			Call_Back_Time__c = date.Today(),
			Mail_Stop_End_Date__c = date.Today(),
			Temp_Away_End_Date__c = date.Today()
		);
		
		testClass.ValidateTaskFields();
		testClass.ValidateCustomerAccountFields();
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = 'Callback',
			Call_Back_Time__c = date.Today(),
			Call_Back_Daytime_Indicator__c = true
		);
		
		testClass.ValidateTaskFields();
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = 'Callback',
			Call_Back_Time__c = date.newinstance(1977, 6, 27),
			Call_Back_Daytime_Indicator__c = false
		);
		
		testClass.ValidateTaskFields();
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = system.label.Appointment_Lead		
		);
		
		testClass.ValidateTaskFields();
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = system.label.Appointment_Requested		
		);
		
		testClass.ValidateTaskFields();
		
		testClass.agentConsoleData = new Task
		(
			CallDisposition__c = system.label.Appointment_Requested,
			Request_Date__c = date.Today()	
		);
		
		testClass.ValidateTaskFields();
		
		//// Test Case 8 - Picklist Building ////
		testClass.BuildPicklists();
	}
	
	// Test helpers, due to various situations, such as not being allowed to
	// set the state programatically when the environment is not previously
	// assigned corrently
	public boolean IsTest {get; set;}
}