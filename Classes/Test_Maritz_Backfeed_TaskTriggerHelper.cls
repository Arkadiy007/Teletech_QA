@isTest
private class Test_Maritz_Backfeed_TaskTriggerHelper {

      @isTest static void TestEmailMessageCreateMaritzStorageNotWorkingDueToRequirementsNotMet(){
        Test.startTest();
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;

        System.runAs(uValid){
                Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');
                                    testCase.Contact_ID__c = 'Contact Id C';
    

        insert testCase;

        
        Task taskNotValidRT = new Task( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'),
                                        CreatedById = uValid.id,
                                       WhatId = testCase.id,
                                       Type = 'Call');
        insert taskNotValidRT;

        
        EmailMessage em = new EmailMessage(ParentId = testCase.id, ActivityId = taskNotValidRT.id, Subject = 'Test', TextBody= 'Test',  FromAddress='test2@test.com', FromName='test', ToAddress='test32@test.com');
        insert em;
        }

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 





        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;         
        List<EmailMessage> tasksList = [SELECT Id, ParentId, CreatedDate, ActivityId, FromAddress, FromName, ToAddress, CreatedById FROM EmailMessage]; 

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c FROM Stage_Maritz_Backfeed_Object__c
                                                             WHERE Activity_ID__c= :tasksList[0].id];

                                                             System.assertEquals(0, maritzObj.size());
                                                                 
        Test.StopTest();
      } 
      
      @isTest static void TestEmailMessageCreateMaritzStorageWorkWellWhenReqAreMet(){
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;

        System.runAs(uValid){
                Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');
        testCase.Contact_ID__c = 'Contact Id C';
    

        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 



        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;
                
        Test.startTest();
                EmailMessage em = new EmailMessage(ParentId = testCase.id, Subject = 'Test', TextBody= 'Test',  FromAddress='test2@test.com', FromName='test', ToAddress='test32@test.com');
                insert em;
            
        Test.StopTest();


        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Id, Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c, Account_Name__c FROM Stage_Maritz_Backfeed_Object__c ];

        System.assertEquals(1, maritzObj.size());
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                                                                             
    
      }                                         
      }

      @isTest static void TestEmailMessageCreateMaritzStorageWorkWellWhenReqAreMetForBulk(){
        
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        System.runAs(uValid){
                Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');
        testCase.Contact_ID__c = 'Contact Id C';
    

        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 



        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;
                
        Test.startTest();
            List<EmailMessage> emailsToInsert = new List<EmailMessage>();
            for(Integer j = 0; j < 500; j++){
                EmailMessage em = new EmailMessage(ParentId = testCase.id, Subject = 'Test', TextBody= 'Test',  FromAddress='test2@test.com', FromName='test', ToAddress='test32@test.com');
                emailsToInsert.add(em);
            }
            insert emailsToInsert;
        Test.StopTest();


        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Id, Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c, Account_Name__c FROM Stage_Maritz_Backfeed_Object__c ];

        System.assertEquals(500, maritzObj.size());
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                                                                             
    
      }
      }
      
      
      @isTest static void TestTaskCreateMaritzStorageWorkWellWhenReqAreMet(){
            Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 

        
        Test.startTest();
            Task ts = new Task( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'),
                                        CreatedById = uValid.id,
                                       WhatId = testCase.id,
                                       Type = 'Call');
            insert ts;
        Test.StopTest();

        }
        List <Task > tasksList = [SELECT Id, WhatId, Description, CreatedDate, Type, ActivityDate, RecordTypeId, CreatedById FROM Task];

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(1, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
     
      }
      
      @isTest static void TestTaskCreateMaritzStorageWorkWellWhenReqAreMetForBulk(){
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 


        Test.startTest();
            List<Task> tasksToInsert = new List<Task>();
            for(Integer j = 0; j < 500; j++){
                Task ts = new Task( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'),
                                        CreatedById = uValid.id,
                                       WhatId = testCase.id,
                                       Type = 'Call');
                tasksToInsert.add(ts);
            }
            insert tasksToInsert;
        Test.StopTest();

        }
        List <Task > tasksList = [SELECT Id, WhatId, Description, CreatedDate, Type, ActivityDate, RecordTypeId, CreatedById FROM Task];

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(500, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
      } 
       

      @isTest static void TestCallCreateMaritzStorageWorkWellWhenReqAreMet(){
            Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 


        
        Test.startTest();
            Call__c ts = new Call__c( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'),
                                          CreatedById = uValid.id,
                                          Case__c = testCase.id,
                                          Reason_Not_Interested__c = 'Test',
                                          Outcome__c = 'Test',
                                          Result__c = 'test'
                                          );
            insert ts;
        Test.StopTest();

        
        List <Call__c > tasksList = [SELECT Id, Case__c, Reason_Not_Interested__c, Outcome__c, Result__c, RecordTypeId, CreatedById FROM Call__c];


        }
        List <Task > tasksList = [SELECT Id, WhatId, Description, CreatedDate, Type, ActivityDate, RecordTypeId, CreatedById FROM Task];

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(1, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
     
      }
     
      @isTest static void TestCallCreateMaritzStorageWorkWellWhenReqAreMetForBulk(){
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 


        Test.startTest();
            List<Call__c> tasksToInsert = new List<Call__c>();
            for(Integer j = 0; j < 500; j++){
                Call__c ts = new Call__c( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'),
                                          CreatedById = uValid.id,
                                          Case__c = testCase.id,
                                          Reason_Not_Interested__c = 'Test',
                                          Outcome__c = 'Test',
                                          Result__c = 'test'
                                          );
                tasksToInsert.add(ts);
            }
            insert tasksToInsert;
        Test.StopTest();

        }
        List <Call__c > tasksList = [SELECT Id, Case__c, Reason_Not_Interested__c, Outcome__c, Result__c, RecordTypeId, CreatedById FROM Call__c];

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(500, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
      } 
 
    @isTest static void TestChatCreateMaritzStorageWorkWellWhenReqAreMet(){
            Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        
        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 


        
        Test.startTest();
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;

            LiveChatTranscript ts = new LiveChatTranscript(
                                          CreatedById = uValid.id,
                                          CaseId = testCase.id,
                                          LiveChatVisitorID = visitor.id
                                          );
            insert ts;
            List<LiveChatTranscript> tsklist = new List<LiveChatTranscript>();
            tsklist.add(ts);
            
        Test.StopTest();

        }

        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(1, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
     
      }
     
      @isTest static void TestChatCreateMaritzStorageWorkWellWhenReqAreMetForBulk(){
        Profile[] p = [SELECT Id, Name FROM Profile WHERE Name = 'Agent' OR Name = 'System Viewer' ORDER BY Name];
        
        Maritz_Backfeed_Profiles__c cs = new Maritz_Backfeed_Profiles__c(Profile_Id__c = p[0].id, Profile_Name__c = p[0].name, Name = '0001001');
        insert cs;


        User uValid = new User(Alias = 'atata521',
                               Email = 'Agedasdasnt1@testorg.com',
                               EmailEncodingKey = 'UTF-8',
                               LastName = 'Testing',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',
                               ProfileId = p[0].Id,
                               TimeZoneSidKey = 'America/Los_Angeles',
                               UserName = 'AgAgedasdasnt1ent1@testorg.com');
        insert uValid;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
                TriggerSettings.EnabledForCall__c = true;
                TriggerSettings.EnabledForChat__c = true;
                TriggerSettings.EnabledForEmail__c = true;
                TriggerSettings.EnabledForTask__c = true;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        Account testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

        testCase.Contact_ID__c = 'Contact Id C';
        insert testCase;

        

        String[] BR = new String[]{'Customer Connection Follow Up',
        'Lead Survey',
        'Sales and Service Record Type',
        'Retail Loyalty',
        'Lease Loyalty',
        'IB Cases',
        'NCAR',
        'NOTOR',
        'CCC Record type', 
        'Social Support',
        'CA',
        'CA Closed Case',
        'CA Email Infiniti',
        'CA Email Nissan',
        'CA Sales & Service',
        'Connected Services Alert',
        'DTU',
        'Enrollment Alert',
        'LEAF',
        'LEAF Console',
        'NCV/Fleet',
        'Pre-Sell',
        'Roadside Assistance',
        'Support',
        'T5',
        'VCS Support',
        'VPP',
        'Warranty'};

        List<RecordType> prl = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Case' and name in :br];
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

        for(RecordType pt : prl){
            css.add(new Maritz_Backfeed_RT__c(RecordTypeId__c = pt.id, RecordTypeName__c = pt.name, Object_Name__c = 'Case'));
        }

        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA'), RecordTypeName__c = 'CA'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CA Correspondence'), RecordTypeName__c = 'CA Correspondence'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'), RecordTypeName__c = 'CCC'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CTI'), RecordTypeName__c = 'CTI'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'Service Marketing'), RecordTypeName__c = 'Service Marketing'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Task', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'VCS Support'), RecordTypeName__c = 'VCS Support'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Account', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'), RecordTypeName__c = 'Maritz'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Customer Connection Follow Up'), RecordTypeName__c = 'Customer Connection Follow Up'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Lease Loyalty'), RecordTypeName__c = 'Lease Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Retail Loyalty'), RecordTypeName__c = 'Retail Loyalty'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Sales & Service'), RecordTypeName__c = 'Sales & Service'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF'), RecordTypeName__c = 'LEAF'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'LEAF Console'), RecordTypeName__c = 'LEAF Console'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'NMAC LL'), RecordTypeName__c = 'NMAC LL'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'Pre-Sell'), RecordTypeName__c = 'Pre-Sell'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VPP'), RecordTypeName__c = 'VPP'));
        css.add(new Maritz_Backfeed_RT__c(Object_Name__c = 'Call__c', RecordTypeId__c = RecordtypeUtil.getObjectRecordTypeId(Call__c.SObjectType, 'VCS'), RecordTypeName__c = 'VCS'));  

        Integer z = 100000;
            for(Maritz_Backfeed_RT__c cr : css){
                cr.Name = String.valueOf(z);
                z += 10;
        }           
           
        insert css; 


    

        Test.startTest();
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;

            List<LiveChatTranscript> tasksToInsert = new List<LiveChatTranscript>();
            for(Integer j = 0; j < 40; j++){
                LiveChatTranscript ts = new LiveChatTranscript(
                                          CreatedById = uValid.id,
                                          CaseId = testCase.id,
                                          LiveChatVisitorID = visitor.id
                                          );
                tasksToInsert.add(ts);
            }
            insert tasksToInsert;
        Test.StopTest();

        }
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(40, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
      }                                                                                 
}