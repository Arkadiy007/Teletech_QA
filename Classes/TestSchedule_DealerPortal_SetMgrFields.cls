/**********************************************************************
Name: TestSchedule_DealerPortal_SetMgrFields 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Schedule_DealerPortal_SetManagerFields.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestSchedule_DealerPortal_SetMgrFields {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void Schedule_DealerPortal_SetManagerFields_Test() {
        
        Profile profile = [SELECT Id FROM Profile WHERE 
            Name='System Administrator'];
        UserRole userRole = [SELECT Id FROM UserRole 
            WHERE Name =: system.label.ServiceMarketing LIMIT 1];
        
        User usr= new User(Alias = 'agentUT', Email = 'fake@fake.com', 
                    EmailEncodingKey = 'UTF-8', LastName = 'CB_AGENT__TMS_Testing', 
                    LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                    ProfileId = profile.Id, TimeZoneSidKey = 'America/Los_Angeles', 
                    UserName = 'CB_AGENT__TMS_Testing@CB_AGENT__TMS_Testing.com',
                    UserRoleId = userRole.Id);     
            
        RecordType dealer = [SELECT Id FROM RecordType WHERE Name=: 
            system.label.dealer AND SobjectType = 'Account' LIMIT 1];
            
        // Schedule a test job at midnight on Jan 1, 2020.
        String cronExpression = '0 0 0 1 1 ? 2020';
        Account dealerAccount = new Account();
        dealerAccount.name = 'testDealerAccount';
        dealerAccount.RecordTypeId = dealer.id;
        dealerAccount.Dealer_Attributes_Text__c = 'EIX';
        dealerAccount.Dealer_Code__c = '88888';
        insert dealerAccount;
        
      
        Test.startTest();

        // Schedule a test job
        String testJobId = System.schedule('testSchedule_DealerPortal_SetManagerFields', cronExpression, new Schedule_DealerPortal_SetManagerFields());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :testJobId];
        
        // Verify the job is as expected
        System.assertEquals(cronExpression,ct.CronExpression);
        System.assertEquals(ct.TimesTriggered, 0);
        System.assertEquals('2020-01-01 00:00:00', String.valueOf(ct.NextFireTime));
    }
   
 }