/**********************************************************************
Name: DealerQuotesRequest_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "DealerQuotesRequest_Before" Trigger.

Related Class : DealerQuotesRequestClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry     08/16/2011 Created
***********************************************************************/

@isTest
private class Service_Marketing_Reporting_Test {
    static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    
   static testmethod void testTriggerServiceMarketingDispositionReporting_Before() {
        /* 
            Create a Contact,Campaign,CampaignMember & Task to test the functionality
        */
        
        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;
     
        Campaign camp = new Campaign();
        camp.Name = 'Test';
        camp.IsActive = true;
        insert camp;
     
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = camp.Id;
        campMember.ContactId = con.Id;
        campMember.Service_Marketing_Call_ID__c = Integer.valueOf('122');
        campMember.Phone_1__c ='1233';
        campMember.Preferred_Phone_Type__c = 'TestType';
        campMember.Preferred_Mail_Type__c = 'Test';
        campMember.Preferred_Call_Time__c = '123';
        insert campMember;
         
        Task TaskRec = new Task();
        TaskRec.Description = 'Initial Description';
        TaskRec.WhoId = con.Id;
        insert TaskRec;
        
        TaskRec.Call_End_Time__c = System.now();
        TaskRec.CallDisposition__c  = 'test';
        TaskRec.WhoId = con.Id;
        TaskRec.Language__c = campMember.Language__c;
        update TaskRec;

		Call_Resolution__c callRes = new Call_Resolution__c();
		callRes.ResolutionId__c = '122';
		insert callRes;
        
        Service_Marketing_Disposition_Reporting__c rep = new Service_Marketing_Disposition_Reporting__c();
        rep.Campaign_Member_Id__c = campMember.Id;
        rep.Task_Id__c = taskRec.Id;
        rep.Contact__c = con.Id;
        rep.Resolution_Id__c = '122';
        rep.Call_Resolution__c = callRes.Id;
        
        Test.startTest();
        
        insert rep;
        
        Test.StopTest();
      }    
}