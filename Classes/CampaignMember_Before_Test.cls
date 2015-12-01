/**********************************************************************
Name: Campaign_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "CampaignMember_Before" Trigger.

Related Class : CampaignMemberClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Viajya D. 02/02/2011 Created
1.1 - Sonali Bhardwaj 02/16/2011 Added negative test case.
***********************************************************************/

@isTest
private class CampaignMember_Before_Test  {
    
    static Account account = new Account();
    static Contact contact = new Contact();
    static Campaign camp = new Campaign();
    static Vehicle__c vehicle = new Vehicle__c(); 
    
    static void testdata() {
    
    	String personType = System.Label.AccRTMaritz;
     	RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Dealer_Code__c = 'Test1';
        account.TMS_Customer_ID__c = '22233';
        account.Overdue_Service_Call_Count__c = null ;
        account.Service_Followup_Call_Count__c = null ;
        account.Welcome_Call_Count__c = null ;
        insert account;
                              
        camp.Name = 'testCampaign';        
        camp.StartDate = date.newinstance(1960, 2, 17);        
        camp.EndDate = date.newinstance(1960, 5, 20); 
        camp.IsActive = true; 
        insert camp;
           
        vehicle.Vehicle_Identification_Number__c  = '25';    
        insert vehicle;
    
   }
    
   static  testmethod void testTriggerCampaignMember_BeforeNSC() {
       
        testdata();  
                  
        CampaignMember campmem = new CampaignMember();
        campmem.ContactId = account.PersonContactId ;
        campmem.CampaignId = camp.id;
        campmem.Vehicle_Identification_Number__c = '25';
        campmem.Dealer_Code__c = 'Test1';
        campmem.Customer_ID__c = '22233';
        campmem.Service_Marketing_Call_Type__c = System.Label.NSC ;
        
        
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */        

        Test.startTest();
        
        /*
         Insert the Campaign Member records that cause the trigger to execute.
        */ 
        
        insert campmem;
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */
        
        Test.stopTest();
        
        /*
          Assert that the Dealer Code,Customer Id and Vehicle Identification Number fields contains the proper value now.
        */
       
        System.assert(campmem.Dealer_Code__c != null);
        System.assert(campmem.Customer_ID__c != null);
        System.assert(campmem.Vehicle_Identification_Number__c != null);  
      }   
      
      
      static  testmethod void testTriggerCampaignMember_BeforeSFC() {
       
        testdata();  
                  
        CampaignMember campmem = new CampaignMember();
        campmem.ContactId = account.PersonContactId ;
        campmem.CampaignId = camp.id;
        campmem.Vehicle_Identification_Number__c = '25';
        campmem.Dealer_Code__c = 'Test1';
        campmem.Customer_ID__c = '22233';
        campmem.Service_Marketing_Call_Type__c = System.Label.SFC ;
        
        
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */        

        Test.startTest();
        
        /*
         Insert the Campaign Member records that cause the trigger to execute.
        */ 
        
        insert campmem;
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */
        
        Test.stopTest();
        
        /*
          Assert that the Dealer Code,Customer Id and Vehicle Identification Number fields contains the proper value now.
        */
       
        System.assert(campmem.Dealer_Code__c != null);
        System.assert(campmem.Customer_ID__c != null);
        System.assert(campmem.Vehicle_Identification_Number__c != null);  
      }
      
      static  testmethod void testTriggerCampaignMember_BeforeWLC() {
       
        testdata();  
                  
        CampaignMember campmem = new CampaignMember();
        campmem.ContactId = account.PersonContactId ;
        campmem.CampaignId = camp.id;
        campmem.Vehicle_Identification_Number__c = '25';
        campmem.Dealer_Code__c = 'Test1';
        campmem.Customer_ID__c = '22233';
        campmem.Service_Marketing_Call_Type__c = System.Label.WLC ;
        
        
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */        

        Test.startTest();
        
        /*
         Insert the Campaign Member records that cause the trigger to execute.
        */ 
        
        insert campmem;
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */
        
        Test.stopTest();
        
        /*
          Assert that the Dealer Code,Customer Id and Vehicle Identification Number fields contains the proper value now.
        */
       
        System.assert(campmem.Dealer_Code__c != null);
        System.assert(campmem.Customer_ID__c != null);
        System.assert(campmem.Vehicle_Identification_Number__c != null);  
      }
      
      static  testmethod void testTriggerCampaignMember_Before_Negative() {
                  
        Contact contact1 = new Contact(LastName='test');
        insert contact1;
        
        camp.Name = 'testCampaign';        
        camp.StartDate = date.newinstance(1960, 2, 17);        
        camp.EndDate = date.newinstance(1960, 5, 20); 
        camp.IsActive = true; 
        insert camp;
        
        CampaignMember campmem = new CampaignMember();
        campmem.ContactId = contact1.id;
        campmem.CampaignId = camp.id;
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */        

        Test.startTest();
        
        /*
         Insert the Campaign Member records that cause the trigger to execute.
        */ 
        
        insert campmem;
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */
        
        Test.stopTest();
        
        /*
          Assert that the Dealer Code,Customer Id and Vehicle Identification Number fields contains the proper value now.
        */
       
        System.assert(campmem.Dealer_Code__c == null);
        System.assert(campmem.Customer_ID__c == null);
        System.assert(campmem.Vehicle_Identification_Number__c == null);
        
      } 
}