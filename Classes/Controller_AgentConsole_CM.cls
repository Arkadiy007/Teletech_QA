/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Code behind for the Controller_AgentConsole_CM page. This page is for inbound
call backs of any nature.

Class:              Controller_AgentConsole_CM
Date:               02/22/12
Version:            1
Last Updated:       02/22/12
    * Started
    * 02/27, JJ, Completed
    * 02/28, JJ, Built ForceFlowScriptURL & CallCentreID, implemented here
    * 03/14, JJ, Built Controller_Base and implemented here
    * 03/26, JJ, Due to missing WhoId from CTI, we must assign it on save if
    	it is null for the Task triggers to pull correct contact data
    * 04/02/12	JJ	Bug fix, the campaign member id was not properly passed
    	to the ForceFlowScriptURL class
    * 06/10/13, Bryan, Added date check to speed up Task query

//////// TODO ////////
Wrap some try / catches in QueryCallObjects - live apparently this cannot fail,
    although I haven't personally proven this
Not sure Change Contact actually works? Need to evaluate the need for this
Make the Mailing State/Province an object list to follow the format of
    everything else
Other_phone_Sequence_cannot_equal_Mobile_Phone_sequence --- needs renamed
If_phone_is_populated_you_must_selected_a_phone_sequence ---- needs renamed
Email_or_Alternate_Email_is_required_if_Preferred_mail_is_email -- needs renamed
*/

public with sharing class Controller_AgentConsole_CM extends Controller_Base
{
    // -------- Constants --------
    // None
    
    // -------- Constructor --------
    // Retrieve the CampaignMember id, then query the objects we need
    public Controller_AgentConsole_CM(ApexPages.StandardController 
        campaignMember)
    {
        IsTest = false;
        
        campaignMemberID = ((CampaignMember) campaignMember.getRecord()).Id;
        
        QueryCallObjects();
        BuildPicklists();
    }
    
    // -------- Variables --------
    // Query values
    private string campaignMemberID;
        
    // Init class to retrieve the ForceFlow url link
    private ForceFlowScriptURL forceFlowLink = new ForceFlowScriptURL();
    
    // Init class to retrieve the call center id
    private CallCentreID agentCallCenter = new CallCentreID();
    
    // -------- Properties --------
    // None, in parent
    
    // -------- Methods --------
    // Query all objects used by the controller
    private void QueryCallObjects()
    {
        campaignMember = [SELECT ContactId, Phone_1__c, Non_Solicit__c, 
            Service_Marketing_Call_Type__c, Call_Attempt_Number__c, 
            Language__c, Preferred_Call_Time__c, RecordType.Name, 
            Preferred_Mail_Type__c, Incentive_Offer__c, Vehicle__c, 
            Vehicle_Make__c, Vehicle_Identification_Number__c, 
            Vehicle_Year__c, VehicleModel__c, Customer_ID__c
            FROM CampaignMember WHERE Id =: campaignMemberID
            ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
        
        campaignMemberContact = [SELECT FirstName, LastName, Accountid
            FROM Contact WHERE Id =: campaignMember.ContactId LIMIT 1];
        
        campaignMemberAccount = [SELECT IsPersonAccount, Salutation, FirstName, 
            MiddleName__c, LastName, PersonHomePhone, Home_Phone_Do_Not_Call__c,
            Home_Phone_Sequence__c, PersonOtherPhone, Other_Phone_Extension__c,
            Other_Phone_Do_Not_Call_In__c, Other_Phone_Sequence__c,
            PersonMobilePhone, Mobile_Phone_Do_Not_Call_Indicator__c,
            Mobile_Phone_Sequence__c, PersonEmail, Email_Type_1__c, 
            PersonHasOptedOutOfEmail, Alternate_Email__c, Email_Type_2__c,
            PersonMailingStreet, PersonMailingCity, PersonMailingCountry,
            PersonMailingPostalCode, PersonMailingState, Preferred_Dealer_Id__c,
            PersonContactId FROM Account WHERE Id =: campaignMemberContact.Accountid 
            AND IsPersonAccount = true LIMIT 1];
        
        vehicle = [SELECT Id, Latest_Recorded_Mileage_Number__c, 
            Latest_Recorded_Mileage_Units__c, PMG_Type__c FROM Vehicle__c 
            WHERE Id =: campaignMember.Vehicle__c LIMIT 1];
        
        CallHistoryList = [SELECT Call_Start_Time__c, Call_End_Time__c, 
            Call_Back_Time__c, CallDisposition__c, Description FROM Task 
            WHERE Task.WhoId =: campaignMemberContact.Id 
            ORDER BY CreatedDate DESC LIMIT 10];
        
        if(campaignMemberAccount.Preferred_Dealer_Id__c != null)
            campaignMemberDealer = [SELECT Id, Name, Dealer_Attributes_Text__c, 
                Dealer_Code__c FROM Account WHERE id =: 
                campaignMemberAccount.Preferred_Dealer_Id__c LIMIT 1];
        else
            campaignMemberDealer = new Account(name = system.label.No_Selection, 
                Dealer_Code__c = '', Dealer_Attributes_Text__c = '');
        
        agentConsoleData = new Task(CallDisposition__c = '', Description = '', 
            Call_Back_Phone__c = campaignMember.Phone_1__c);
    }
    
    // Return the page header based on CampaignMember record values
    public string GetHeader()
    {
        return Header();
    }
    
    // Return the Flow based on CampaignMember data
    public string GetScriptURL()
    {
    	forceFlowLink.CampaignMemberID = campaignMember.Id;
        forceFlowLink.CampaignName = campaignMember.RecordType.Name;
        return forceFlowLink.ScriptURL();
    }
    
    // Retrieve call centre id of user
    public integer GetCallCentreID()
    {
        return agentCallCenter.CallCentreID();
    }
    
    // Get if the dealer is an XTime dealer subscriber
    public boolean GetIsXTimeDealer()
    {
        return IsXTimeDealer();
    }
    
    // Get if the dealer is an express dealer
    public string GetIsExpressDealer()
    {
        return IsExpressDealer();
    }
    
    // Do we need to show the email checkbox
    public boolean GetDisplaySendEmailCheckbox()
    {
        return DisplaySendEmailCheckbox();      
    }
    
    // The following send the agent to a new page for data from the TMS or
    // TMS_NCI webservices
    public PageReference LaunchContactServicePage()
    {
        return ContactServicePage();
    }
    
    public PageReference LaunchDateTimePage()
    {
        return DateTimePage();
    }
    
    public PageReference LaunchDatePage()
    {
        return DatePage();
    }
    
    // Save the record, upon the user selecting the save button, calling
    // validation helper methods throughout the process. The save queries
    // for a task created by the CTI component to update, and if one is not
    // found a new one is created to update; Values are confirmed first,
    // then queried and saved.
    public PageReference CustomSave()
    {
        ValidateTaskFields();
        ValidateCustomerAccountFields();
        
        if(campaignMember.Preferred_Mail_Type__c == system.label.Email)
        {
            if(IsStringNullOrEmpty(campaignMemberAccount.Alternate_Email__c) &&
                IsStringNullOrEmpty(campaignMemberAccount.PersonEmail))
                AddErrorMessage(
                system.label.Email_or_Alternate_Email_is_required_if_Preferred_mail_is_email);
        }
        
        if(ApexPages.hasMessages())
        {
            return null;
        }
        else
        {
            try
            {
                Task taskToUpdate;
                Task newTask;
                Task referenceTask;
                Boolean isUpdate = false;
                
                try
                {
                    /*
                    taskToUpdate = [SELECT Id, Temp_Away_Start_Date__c, 
                        Temp_Away_End_Date__c, Mail_Stop_Start_Date__c,
                        Mail_Stop_End_Date__c, WhatId, 
                        Preferred_Dealer_Change_Reason__c, 
                        Service_Description__c, Request_Date__c, Request_Time__c,
                        Action_Type__c, Preferred_Dealer_Change__c, 
                        CallDisposition__c, Send_Email_Request_Indicator__c,
                        Deceased__c, Agent_ID__c, Call_Back_Phone__c, 
                        Call_Back_Time__c, Call_Back_Daytime_Indicator__c,
                        CallObject, Description, Question_1__c, Question_2__c,
                        Satisfaction__c, Comment_Audience__c, 
                        Customer_Experience__c, CustomerID__c, CallType, 
                        Service_Marketing_Call_Type__c, Call_End_Time__c
                        FROM Task WHERE
                        Task.WhoId =: campaignMemberAccount.PersonContactId 
                        AND Task.Subject like 'Inbound%' 
                        AND Task.CreatedById =: UserInfo.getUserId() 
                        AND Task.CallDisposition__c =: null LIMIT 1];
                    */

                    Datetime lastHour = Datetime.Now().addHours(-1);                    

                    taskToUpdate = [SELECT Id, Temp_Away_Start_Date__c, 
                        Temp_Away_End_Date__c, Mail_Stop_Start_Date__c,
                        Mail_Stop_End_Date__c, WhatId, 
                        Preferred_Dealer_Change_Reason__c, 
                        Service_Description__c, Request_Date__c, Request_Time__c,
                        Action_Type__c, Preferred_Dealer_Change__c, 
                        CallDisposition__c, Send_Email_Request_Indicator__c,
                        Deceased__c, Agent_ID__c, Call_Back_Phone__c, 
                        Call_Back_Time__c, Call_Back_Daytime_Indicator__c,
                        CallObject, Description, Question_1__c, Question_2__c,
                        Satisfaction__c, Comment_Audience__c, 
                        Customer_Experience__c, CustomerID__c, CallType, 
                        Service_Marketing_Call_Type__c, Call_End_Time__c
                        FROM Task WHERE
                        Subject like 'Inbound%' 
                        AND CreatedById =: UserInfo.getUserId() 
                        AND CallDisposition__c =: null
                        AND CreatedDate >= :lastHour
                        ORDER BY CreatedDate DESC LIMIT 1];
                    
                    isUpdate = true;
                }
                catch(Exception e)
                {
                    newTask = new Task();
                }
            
                if(newTask != null)
                    referenceTask = newTask;
                else
                    referenceTask = taskToUpdate;
                
                referenceTask.Temp_Away_Start_Date__c = 
                    agentConsoleData.Temp_Away_Start_Date__c;
                referenceTask.Temp_Away_End_Date__c = 
                    agentConsoleData.Temp_Away_End_Date__c;
                referenceTask.Mail_Stop_Start_Date__c = 
                    agentConsoleData.Mail_Stop_Start_Date__c;
                referenceTask.Mail_Stop_End_Date__c = 
                    agentConsoleData.Mail_Stop_End_Date__c;
                referenceTask.WhatId = agentConsoleData.WhatId;
                referenceTask.Preferred_Dealer_Change_Reason__c = 
                    agentConsoleData.Preferred_Dealer_Change_Reason__c;
                referenceTask.Service_Description__c = 
                    agentConsoleData.Service_Description__c;
                referenceTask.Request_Date__c = 
                    agentConsoleData.Request_Date__c;
                referenceTask.Request_Time__c = 
                    agentConsoleData.Request_Time__c;
                referenceTask.Action_Type__c = agentConsoleData.Action_Type__c;
                referenceTask.Preferred_Dealer_Change__c = 
                    agentConsoleData.Preferred_Dealer_Change__c;
                referenceTask.CallDisposition__c = 
                    agentConsoleData.CallDisposition__c ;
                referenceTask.Send_Email_Request_Indicator__c = 
                    agentConsoleData.Send_Email_Request_Indicator__c;
                referenceTask.Deceased__c = agentConsoleData.Deceased__c;
                referenceTask.Agent_ID__c = agentConsoleData.Agent_ID__c;
                referenceTask.Call_Back_Phone__c = 
                    agentConsoleData.Call_Back_Phone__c;
                referenceTask.Call_Back_Time__c = 
                    agentConsoleData.Call_Back_Time__c;
                referenceTask.Call_Back_Daytime_Indicator__c = 
                    agentConsoleData.Call_Back_Daytime_Indicator__c;
                referenceTask.CallObject = agentConsoleData.CallObject;
                referenceTask.Description = agentConsoleData.Description;
                referenceTask.Question_1__c = agentConsoleData.Question_1__c;
                referenceTask.Question_2__c = agentConsoleData.Question_2__c;
                referenceTask.Satisfaction__c = 
                    agentConsoleData.Satisfaction__c;
                referenceTask.Comment_Audience__c = 
                    agentConsoleData.Comment_Audience__c;
                referenceTask.Customer_Experience__c = 
                    agentConsoleData.Customer_Experience__c;
                referenceTask.CustomerID__c = campaignMember.Customer_ID__c;
                
                if(IsStringNullOrEmpty(
                    referenceTask.Service_Marketing_Call_Type__c))
                    referenceTask.Service_Marketing_Call_Type__c = 
                        campaignMember.Service_Marketing_Call_Type__c;
                
                if(IsStringNullOrEmpty(referenceTask.CallType))
                    referenceTask.CallType = 'Inbound';
                   
                if(IsStringNullOrEmpty(referenceTask.WhoId))
                	referenceTask.WhoId = campaignMemberContact.Id;
                
                update campaignMember;
                update campaignMemberAccount;
                update vehicle;
                
                if(!(campaignMemberDealer.Name == system.label.no_selection))
                    update campaignMemberDealer;
                
                if(isUpdate)
                {
                    update referenceTask;
                }
                else
                {
                    referenceTask.Call_End_Time__c = datetime.now(); 
                    insert referenceTask;
                }
                
                if (referenceTask.CallDisposition__c != null)
                    return new PageReference('/apex/NNA_closeAgentConsoleTab');
                else             
                    return null;
                
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    system.label.Your_record_did_not_save_properly_Error + e));
            }
        
            return null;
        }
    }
    
    // -------- Test --------
    static testMethod void ClassTest()
    {
        // Create and insert the test objects needed
        RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
            system.label.dealer AND SobjectType = 'Account' LIMIT 1];
        
        Account dealerAccount = new Account();
        dealerAccount.name = 'testDealerAccount';
        dealerAccount.RecordTypeId = dealer.id;
        dealerAccount.Dealer_Attributes_Text__c = 'EIX';
        dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
        
        RecordType person = [SELECT Id FROM RecordType WHERE Name=: 
            system.label.TMS AND SobjectType = 'Account' 
            AND IsPersonType = true LIMIT 1];
        
        Account customer = new Account();
        customer.FirstName = 'Inbound Test';
        customer.MiddleName__c = 'Test';
        customer.LastName ='Call';
        customer.RecordTypeId = person.Id;
        customer.Preferred_Dealer_Id__c = dealerAccount.Id;
        customer.Home_Phone_Sequence__c = system.label.None;
        customer.Other_Phone_Sequence__c = system.label.None;
        customer.Mobile_Phone_Sequence__c = system.label.None;
        customer.PersonMailingCity = 'test';
        customer.PersonMailingCountry = 'USA';
        customer.PersonMailingPostalCode = '88888';
        customer.PersonMailingStreet = '88888 test st';
        customer.Alternate_Email__c = 'test@test.com';
        insert customer;
        
        customer = [SELECT IsPersonAccount, Salutation, FirstName, 
            MiddleName__c, LastName, PersonHomePhone, Home_Phone_Do_Not_Call__c,
            Home_Phone_Sequence__c, PersonOtherPhone, Other_Phone_Extension__c,
            Other_Phone_Do_Not_Call_In__c, Other_Phone_Sequence__c,
            PersonMobilePhone, Mobile_Phone_Do_Not_Call_Indicator__c,
            Mobile_Phone_Sequence__c, PersonEmail, Email_Type_1__c, 
            PersonHasOptedOutOfEmail, Alternate_Email__c, Email_Type_2__c,
            PersonMailingStreet, PersonMailingCity, PersonMailingCountry,
            PersonMailingPostalCode, PersonMailingState, Preferred_Dealer_Id__c,
            PersonContactId FROM Account WHERE Id =: customer.Id 
            LIMIT 1];
        
        update customer;
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Latest_Recorded_Mileage_Number__c = 88888;
        vehicle.Latest_Recorded_Mileage_Units__c = '?';
        insert vehicle;
        
        RecordType campaignType = [SELECT Id, Name FROM RecordType 
            WHERE SobjectType = 'Campaign' 
            AND Name = 'Infiniti English Evening'];
        
        Campaign campaign = new Campaign();
        campaign.RecordTypeId = campaignType.Id;
        campaign.Name = campaignType.Name;
        campaign.StartDate = date.newinstance(1977, 6, 27);
        campaign.EndDate = date.newinstance(1977, 7, 03);
        campaign.IsActive = true;
        insert campaign;
        
        List<Contact> contactRecord = [SELECT Id FROM Contact 
            WHERE AccountId =: customer.Id limit 1];
        
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaign.Id;
        campaignMember.ContactId = contactRecord[0].Id;
        campaignMember.Vehicle__c = vehicle.Id;
        campaignMember.Service_Marketing_Call_Type__c = System.label.NSC;
        campaignMember.Non_Solicit__c = true;
        campaignMember.Incentive_Offer__c = 'Yes';
        campaignMember.Preferred_Mail_Type__c = system.label.Email;
        insert campaignMember;
        
        //// Class Init ////
        ApexPages.StandardController campaignMemberController = 
            new ApexPages.StandardController(campaignMember);
        Controller_AgentConsole_CM testClass = 
                new Controller_AgentConsole_CM(campaignMemberController);
        
        //// Test Case 1 - Various Base Properties ////
        string header = testClass.GetHeader();
        string scriptURL = testClass.GetScriptURL();
        boolean isXTime = testClass.GetIsXTimeDealer();
        string isExpress = testClass.GetIsExpressDealer();
        boolean sendEmail = testClass.GetDisplaySendEmailCheckbox();
        testClass.APIName = 'TestThis';
        PageReference lcsp = testClass.LaunchContactServicePage();
        PageReference ldtp = testClass.LaunchDateTimePage();
        PageReference ldp = testClass.LaunchDatePage();
        integer userCallCenterID = testClass.GetCallCentreID();
        
        //// Test Case 2 - Task Existing Pass Validations ////
        Account personContactId = [SELECT PersonContactId 
            FROM Account WHERE Id =: customer.Id 
            AND IsPersonAccount = true LIMIT 1];
                
        Task testCTITask = new Task();
        testCTITask.WhoId = personContactId.PersonContactId;
        testCTITask.CreatedById = UserInfo.getUserId();
        testCTITask.Subject = 'InboundCall';
        insert testCTITask;
        
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
        
        testClass.IsTest = true;
        testClass.CustomSave();
        testClass.IsTest = false;
        
        //// Test Case 3 - Task New Passing Validations ////
        testClass.IsTest = true;
        testClass.CustomSave();
        testClass.IsTest = false;
        
        //// Test Case 4 - Task New Failing Validations ////
        customer.Alternate_Email__c = '';
        customer.Preferred_Dealer_Id__c = null;
        testClass.campaignMemberAccount = customer;
        testClass.CustomSave();
    }
}