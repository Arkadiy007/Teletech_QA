/**********************************************************************
  Name: OnetimeTreadMigrationFlags_Tests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for OnetimeTreadMigration_Flags trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Anna Koseikina 02/26/2015 Created
  ***********************************************************************/
  @isTest
public class OnetimeTreadMigrationFlags_Tests { 
	private static Case testCase = new Case(Status = 'New', 
											Origin = 'Phone', 
											Description = 'Initial Description', 
											Fire_Indicator__c = true,
											Rollover_Indicator__c = true,
											Injury_Indicator__c = false,
											Sent_to_Legal_Indicator__c = true,
											Property_Damage_Indicator__c = true,
											Goodwill_Offered__c = true,
                                            Incident_Date__c = date.today());

	
	private static void init(){
		insert testCase;
	}

	static testmethod void testAllCorrect(){
		Test.startTest();		
        init();
		OnetimeTreadMigration_Flags__c onetimeMigration = new OnetimeTreadMigration_Flags__c(Salesforce_Case_Id__c = String.valueOf(testCase.Id).substring(0,15), 
																							 Death_Injury_Flag__c = 'N',
																							 Fire_Flag__c = 'N',
																							 Goodwill_Flag__c = 'N',
																							 Property_Damage_Flag__c = 'Y',
																							 Property_Damage_Date__c = Date.today(),
																							 Rollover_Flag__c = 'Y',
																							 Rollover_Date__c = Date.newInstance(2014,5,6),
																							 Sent_to_Legal_Flag__c = 'N');
		insert onetimeMigration;
		onetimeMigration = [SELECT Id, Error_Description__c from OnetimeTreadMigration_Flags__c where id=:onetimeMigration.id limit 1];

		testCase = [SELECT Id, Fire_Indicator__c, Rollover_Date__c, Sent_to_Legal_Indicator__c, Property_Damage_Date__c, Goodwill_Offered__c, Injury_Indicator__c FROM Case WHERE Id=:testCase.Id LIMIT 1];
        System.assertEquals(testCase.Fire_Indicator__c, false);
        System.assertEquals(testCase.Rollover_Date__c, Date.newInstance(2014,5,6));
        System.assertEquals(testCase.Sent_to_Legal_Indicator__c, false);
        System.assertEquals(testCase.Property_Damage_Date__c, Date.today());
        System.assertEquals(testCase.Goodwill_Offered__c, false);
        System.assertEquals(testCase.Injury_Indicator__c, false);
        test.stopTest();
	}

	static testmethod void testNoCase(){
		Test.startTest();
		init();
        OnetimeTreadMigration_Flags__c onetimeMigration = new OnetimeTreadMigration_Flags__c(Salesforce_Case_Id__c = 'test',
																							 Death_Injury_Flag__c = 'Y',
																							 Death_Injury_Date__c = Date.today(),
																							 Fire_Flag__c = 'N',
																							 Goodwill_Flag__c = 'N',
																							 Property_Damage_Flag__c = 'Y',
																							 Property_Damage_Date__c = Date.today(),
																							 Rollover_Flag__c = 'Y',
																							 Rollover_Date__c = Date.newInstance(2014,5,6),
																							 Sent_to_Legal_Flag__c = 'N');
		insert onetimeMigration;
		onetimeMigration = [SELECT Id, Successful__c from OnetimeTreadMigration_Flags__c where id=:onetimeMigration.id limit 1];
		testCase = [SELECT Id, Fire_Indicator__c, Rollover_Date__c, Sent_to_Legal_Indicator__c, Property_Damage_Date__c, Goodwill_Offered__c, Injury_Indicator__c FROM Case WHERE Id=:testCase.Id LIMIT 1];
		System.assertEquals(onetimeMigration.Successful__c, false );
        test.stopTest();
	}
}