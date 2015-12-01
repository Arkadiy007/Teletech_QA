@isTest
public class Maritz_Accounts_Backfill_BatchJobTests {
 @isTest static void TestBackfillForAccountWorksWellWhenReqAreMet(){
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
                TriggerSettings.EnabledForCall__c = FALSE;
                TriggerSettings.EnabledForChat__c = FALSE;
                TriggerSettings.EnabledForEmail__c = FALSE;
                TriggerSettings.EnabledForTask__c = FALSE;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;


		Maritz_Account_BackfillSettings__c backfillSettings = new Maritz_Account_BackfillSettings__c();
        backfillSettings.Start_Date__c = System.Now().addYears(-1);
        backfillSettings.End_Date__c = System.Now().addYears(1);
        
        insert backfillSettings;
        
        Test.startTest();
            Task ts = new Task( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'),
                                       CreatedById = uValid.id,
                                       WhatId = testAcc.id,
                                       Type = 'Call');
            insert ts;
			Maritz_Accounts_Backfill_BatchJob.runBackfillProcess();
        Test.StopTest();

        }
	
        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(1, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
      }

	 @isTest static void TestBackfillForAccountWorksWellWhenReqAreMet_Bulk(){
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
                TriggerSettings.EnabledForCall__c = FALSE;
                TriggerSettings.EnabledForChat__c = FALSE;
                TriggerSettings.EnabledForEmail__c = FALSE;
                TriggerSettings.EnabledForTask__c = FALSE;
        insert TriggerSettings;
        
        
        System.runAs(uValid){
    
        Account testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        
        List<Maritz_Backfeed_RT__c> css = new List<Maritz_Backfeed_RT__c>();

		Maritz_Account_BackfillSettings__c backfillSettings = new Maritz_Account_BackfillSettings__c();
        backfillSettings.Start_Date__c = System.Now().addYears(-1);
        backfillSettings.End_Date__c = System.Now().addYears(1);
        
        insert backfillSettings;
        
        Test.startTest();
            List<Task> tasksToInsert = new List<Task>();
            for(Integer j = 0; j < 500; j++){
                Task ts = new Task( RecordTypeId= RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC'),
                                    CreatedById = uValid.id,
                                    WhatId = testAcc.id,
                                    Type = 'Call');
                tasksToInsert.add(ts);
            }
            insert tasksToInsert;
			Maritz_Accounts_Backfill_BatchJob.runBackfillProcess();
        Test.StopTest();

        }
	
        
        List <Stage_Maritz_Backfeed_Object__c > maritzObj = [SELECT Activity_ID__c, Account_Name__c,Preferred_Dealer__c, Contact_ID__c, PersonHomePhone__c FROM Stage_Maritz_Backfeed_Object__c];

        System.assertEquals(500, maritzObj.size());  
        System.assertEquals('TestF2irstName TestLas2tName', maritzObj[0].Account_Name__c);
      }
 }