@isTest
private class Maritz_Backfeed_Backfill_BatchTest {     
    
      @isTest static void maritzBackfeedBackfillJob_ShouldCreateValidObjectsForCaseWithCalls() {
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

            Maritz_Backfeed_BackfillSettings__c backfillSettings = new Maritz_Backfeed_BackfillSettings__c();
        backfillSettings.Start_Date__c = System.Now().addYears(-1);
        backfillSettings.End_Date__c = System.Now().addYears(1);
        backfillSettings.RecordTypeNames__c = 'Customer Connection Follow Up,CCC';

        insert backfillSettings;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
            TriggerSettings.EnabledForCall__c = false;
            TriggerSettings.EnabledForChat__c = false;
            TriggerSettings.EnabledForEmail__c = false;
            TriggerSettings.EnabledForTask__c = false;

        insert TriggerSettings; 
            List<Call__c> tasksToInsert = new List<Call__c>();
            for(Integer j = 0; j < 100; j++){
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

        Maritz_Backfeed_Backfill_BatchJob.runBackfillProcess();
        Test.StopTest();

        }
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];
        System.assertEquals(100, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
      }      
    
      @isTest static void maritzBackfeedBackfillJob_ShouldCreateValidObjectsForCaseWithEmails() {
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

        Maritz_Backfeed_BackfillSettings__c backfillSettings = new Maritz_Backfeed_BackfillSettings__c();
        backfillSettings.Start_Date__c = System.Now().addYears(-1);
        backfillSettings.End_Date__c = System.Now().addYears(1);
        backfillSettings.RecordTypeNames__c = 'Customer Connection Follow Up,CCC';

        insert backfillSettings;

        Maritz_Backfeed_Trigger_Enabled__c TriggerSettings = new Maritz_Backfeed_Trigger_Enabled__c();
            TriggerSettings.EnabledForCall__c = false;
            TriggerSettings.EnabledForChat__c = false;
            TriggerSettings.EnabledForEmail__c = false;
            TriggerSettings.EnabledForTask__c = false;

        insert TriggerSettings; 
            List<EmailMessage> emailsToInsert = new List<EmailMessage>();
            for(Integer j = 0; j < 100; j++){
                EmailMessage em = new EmailMessage(ParentId = testCase.id, Subject = 'Test', TextBody= 'Test',  FromAddress='test2@test.com', FromName='test', ToAddress='test32@test.com');
                emailsToInsert.add(em);
            }
            insert emailsToInsert;

        Maritz_Backfeed_Backfill_BatchJob.runBackfillProcess();
        Test.StopTest();

        }
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];
        System.assertEquals(100, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
        System.assertEquals([SELECT Home_Phone__c FROM Case Limit 1][0].Home_Phone__c, maritzObj[0].PersonHomePhone__c);                                                     
      }      
    
    
}