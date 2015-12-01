/*
1.1	- JJ	02/08/2012	Modified to include call centre check for creating new contact,
						defaulted to 6 based on feedback from non-agent account access
*/

public with sharing class Controller_CreateNewContact {
    public string callId{get;set;} 
    public string campId{get;set;} 
    public string cid{get;set;}
    public CampaignMember campMemb = new CampaignMember();
    public Account origAccount = new Account(); 

    public Task call = new Task();
    public Account newAccount{get;set;} 
    public Map<String,Account> associatedAccounts = new Map<String,Account>();
    public List<Account> associatedAccountList {get;set;}
    
    public Controller_CreateNewContact(){
        // Get CampaignMember from input callId and campId
        callId = ApexPages.currentPage().getParameters().get(system.label.callId);
        campId = ApexPages.currentPage().getParameters().get(system.label.campId);
        cid = ApexPages.currentPage().getParameters().get(system.label.cId);
        system.debug('callId: ' + callId);
        system.debug('campId: ' + campId);
        system.debug('campId: ' + cid);
    	
        User userRecord = [Select Call_Centre_Id__c From User Where Id =: UserInfo.getUserId()];
   		if(userRecord == null || userRecord.Call_Centre_Id__c == null)
   		{
   			assignServiceAccess(6);
   		}
   		else
   		{
   			assignServiceAccess(integer.valueOf(userRecord.Call_Centre_Id__c));
   		}
        
        try {
            //this.call = [select id, Task.WhoId FROM Task WHERE Id =:callId];
//callId is not passed in the URL, so:
this.call = [select id,Temp_Away_Start_Date__c ,Temp_Away_End_Date__c, Mail_Stop_Start_Date__c, Mail_Stop_End_Date__c, AccountId, Preferred_Dealer_Change_Reason__c, Service_Description__c, Request_Date__c,
         Request_Time__c, Action_Type__c, WhatId, Call_End_Time__c, CallDisposition__c, Send_Email_Request_Indicator__c, Deceased__c, Agent_ID__c,
         Owner.Name, Call_Back_Time__c, Call_Start_Time__c, CreatedDate,CallObject, Description
         FROM Task WHERE Task.WhoId = :cid 
         ORDER BY CreatedDate DESC LIMIT 1];

this.origAccount = [select a.Preferred_Dealer_Id__c 
               from Account a where a.PersonContactId = :cid
               limit 1];

        } catch (QueryException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.No_Service_Marketing_Call_Id_Error_Message));
        }
        this.campMemb = [select Appointment_Day_Of_Week_End__c, Appointment_Day_Of_Week_Start__c, Call_List_File_Name__c, 
            CampaignId, Customer_ID__c, Dealer__c, Dealer_Close_Time__c, Dealer_Code__c, Dealer_Open_Time__c, Event_Date__c, 
            Incentive_Offer__c, Language__c, List_Type__c, Next_Expected_Date__c, NSC_Service__c, RecordTypeId, Service_Marketing_Call_ID__c, 
            Service_Marketing_Call_Type__c, Status, Vehicle__c, Vehicle_Identification_Number__c, Vehicle_Make__c, Vehicle_Year__c,
            VehicleModel__c FROM CampaignMember WHERE Id =: campId];

        // Get Associated Customers from a Web Service call
        List<List<TMS_Webservices_Utility.Record>> associatedCustomers;
        try {
            string CustomerId = string.valueof(campMemb.Service_Marketing_Call_ID__c);
            associatedCustomers = TMS_Webservices_Utility.RunGetAssociatedCustomers(CustomerId);
        }
        catch (Exception e) {
            // Do Nothing, if associated customers cannot be loaded, the Agent can still enter new
            // Contact information manually.
        }
        
        // Convert from Name/Value pairs into Account object for screen display and easier use.
        Account associatedAccount;
        String key;
        if (associatedCustomers != null) {
            for (List<TMS_Webservices_Utility.Record> customer : associatedCustomers) {
                if (customer != null) {
                    associatedAccount = getCustomerAccount(customer);
                    key = associatedAccount.FirstName + ' ' + associatedAccount.LastName;
                    associatedAccounts.put(key,associatedAccount);
                }
            }
            
            // Generate List of values for use on the page
            associatedAccountList = new List<Account>(associatedAccounts.values());
        }
    }
    
    /* 
      Convert a list of Name/Value pairs into an Account object with those values filled.
    */
    public Account getCustomerAccount(List<TMS_Webservices_Utility.Record> customer) {
        Account acct;
        List<Account> acctList;
        String address1;
        String address2;
        String customerId;
        
        // Get TMSW Customer ID
        for (TMS_Webservices_Utility.Record rec : customer) {
            if(rec != null)
                  if(rec.param == system.label.TMSW_Customer_ID)
                    customerId = rec.value;
        }
        
        // Check for existing customer record matching the TMSW Customer ID
        if (customerId != null) {
            acctList = [select FirstName,LastName,PersonOtherPhone,Phone,PersonHomePhone,PersonEmail,PersonMailingCity,
                               PersonMailingPostalCode,PersonMailingState,PersonMailingStreet,PersonMailingCountry,
                               TMS_Customer_ID__c, Preferred_Dealer_Id__c
                        from Account
                        where TMS_Customer_ID__c = :customerId];
                        
            if (acctList != null && acctList.size() > 0){
                acct = acctList.get(0);
            }
        }
                       
        // If no existing customer record was found, populate from info fields
        if (acct == null) {
            acct = new Account();
            for (TMS_Webservices_Utility.Record rec : customer) {
                if (rec != null) {
                   if(rec.param == system.label.First_Name)
                        acct.FirstName = rec.Value;
                   if(rec.param == system.label.Last_Name)
                        acct.LastName = rec.Value;
                   if(rec.param == system.label.Work_Phone_Number)
                        acct.PersonOtherPhone = rec.Value;
                   if(rec.param == system.label.Home_Phone_Number)
                        acct.PersonHomePhone = rec.Value;
                   if(rec.param == system.label.Email)
                        acct.PersonEmail = rec.Value;
                   if(rec.param == system.label.City)
                        acct.PersonMailingCity = rec.Value;
                   if(rec.param == system.label.Postal_Zip)
                        acct.PersonMailingPostalCode = rec.Value;
                   if(rec.param == system.label.Province_Code)
                        acct.PersonMailingState = rec.Value;
                   if(rec.param == system.label.Address1)
                        address1 = rec.Value;
                   if(rec.param == system.label.Address2)
                        address2 = rec.Value;
                }
            }
            if (address1 != null) {
                acct.PersonMailingStreet = address1 + '\n' + address2;
            }
        }
        
        return acct;
    }
    
    public void fillContactInfo() {
        String key = ApexPages.currentPage().getParameters().get(system.label.associatedCustomer);
        Account associatedCustomer = associatedAccounts.get(key);
        
        account = associatedCustomer;
    }
    
    // the contact record you are adding values to
    public Account account {
      get{
        if (account == null)
           account = new Account(RecordTypeId = system.label.TMS_Record_Type);
        return account;
      }
      set;
    }
 

 
  // save button is clicked
  public PageReference save() {
    Account theNewAccount = new Account();
    try {
system.debug('### Record Type Id = '+account.RecordTypeId);
theNewAccount = account;
theNewAccount.Preferred_Dealer_Id__c = this.origAccount.Preferred_Dealer_Id__c;

      if (account.TMS_Customer_ID__c == null)
        insert account; // inserts the new record into the database
      else
         update account;


      theNewAccount = [select id, PersonContactId, TMS_Customer_ID__c, 
                    FirstName,
                    LastName,
                    PersonMailingStreet,
                    PersonMailingCity,
                    PersonMailingState,
                    PersonMailingPostalCode,
                    PersonMailingCountry,
                    PersonHomePhone,
                    Home_Phone_Extension__c,
                    PersonOtherPhone,
                    Other_Phone_Extension__c
                    FROM Account where id =: account.id];

      System.debug('theNewaccount : '  + theNewAccount);
      //call.WhoId = theNewAccount.PersonContactId;
      
      call.Contact_Changed__c = true;
      call.New_Contact_First_Name__c = theNewAccount.FirstName;
      call.New_Contact_Last_Name__c = theNewAccount.LastName;
      call.New_Contact_Address__c = theNewAccount.PersonMailingStreet;
      //call.New_Contact_Address_Line_2__c
      call.New_Contact_City__c = theNewAccount.PersonMailingCity;
      call.New_Contact_State__c = theNewAccount.PersonMailingState;
      call.New_Contact_Zip__c = theNewAccount.PersonMailingPostalCode;
      call.New_Contact_Country__c = theNewAccount.PersonMailingCountry;
      call.New_Contact_Home_Phone__c = theNewAccount.PersonHomePhone;
      call.New_Contact_Home_Ext__c = theNewAccount.Home_Phone_Extension__c;
      call.New_Contact_Work_Phone__c = theNewAccount.PersonOtherPhone;
      call.New_Contact_Work_Ext__c = theNewAccount.Other_Phone_Extension__c;

      System.debug('call: ' + call);
      System.debug('call: ' + this.call);
      update call;
/* 
      CampaignMember newCampMemb = new CampaignMember(  Appointment_Day_Of_Week_End__c =campMemb.Appointment_Day_Of_Week_End__c,
                                                        Appointment_Day_Of_Week_Start__c  =campMemb.Appointment_Day_Of_Week_Start__c ,
                                                        Call_List_File_Name__c  =campMemb.Call_List_File_Name__c ,
                                                        CampaignId =campMemb.CampaignId,
                                                        ContactId = theNewAccount.PersonContactId,
                                                        Customer_ID__C = theNewAccount.Customer_ID__c,
                                                        Dealer__c =campMemb.Dealer__c,
                                                        Dealer_Close_Time__c =campMemb.Dealer_Close_Time__c,
                                                        Dealer_Code__c =campMemb.Dealer_Code__c,
                                                        Dealer_Open_Time__c =campMemb.Dealer_Open_Time__c,
                                                        Event_Date__c  =campMemb.Event_Date__c ,
                                                        Incentive_Offer__c =campMemb.Incentive_Offer__c,
                                                        Language__c  =campMemb.Language__c ,
                                                        List_Type__c =campMemb.List_Type__c,
                                                        Next_Expected_Date__c =campMemb.Next_Expected_Date__c,
                                                        NSC_Service__c =campMemb.NSC_Service__c,
                                                        Service_Marketing_Call_ID__c  =campMemb.Service_Marketing_Call_ID__c ,
                                                        Service_Marketing_Call_Type__c =campMemb.Service_Marketing_Call_Type__c,
                                                        Status =campMemb.Status,
                                                        Vehicle__c =campMemb.Vehicle__c,
                                                        Vehicle_Identification_Number__c =campMemb.Vehicle_Identification_Number__c,
                                                        Vehicle_Make__c =campMemb.Vehicle_Make__c,
                                                        Vehicle_Year__c  =campMemb.Vehicle_Year__c ,
                                                        VehicleModel__c =campMemb.VehicleModel__c);

        
    System.debug('newCampMemb: '  + newCampMemb);
    insert newCampMemb; 
    
*/    
      
  
      
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.Error_creating_new_Account));
      return null;
    }
 
    // if successfully inserted new contact, then displays the thank you page.
    //System.debug('theNewAccount.PersonContactId :  ' + theNewAccount.PersonContactId + account.PersonContactId);
    //Never created theNewAccount, so returning to last page
    //String pagestring = '/apex/AgentConsoleLandingPage?id=' + theNewAccount.PersonContactId;
    String pagestring = '/apex/AgentConsoleLandingPage?'+'&'+system.label.id+'=' + cId;
    
    System.debug('pagestring:  '   + pagestring);
    PageReference pageRef = new PageReference(pagestring);
    return pageRef;
    
  }
	
	private void assignServiceAccess(integer callCenterID)
	{
		if(callCenterID != 4)
    	{
    		TMS_Webservices_Utility.setServiceAccess(System.label.TMS_Endpoint, System.label.username, System.label.password);
    	}
    	else if(callCenterID == 4)
    	{
    		TMS_Webservices_Utility.setServiceAccess(System.label.TMS_NCI_Endpoint, System.label.usernameNCI, System.label.passwordNCI);
    	}
	}
}