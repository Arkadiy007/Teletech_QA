/**********************************************************************
  Name: BellomyStageObjectsScheduledJobTests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Unit-tests for BellomyStageObjectsScheduledJob scheduled job
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/1/2015 Created
 ***********************************************************************/
@isTest
public class Maritz_DeleteExtractedObjects_JobTests {
	
	@isTest
	static void BatchJob_ShouldDoNothingIfPresentedObjectIsNotExtracted(){
		insert backfeedObjectsFactory(false);

		System.AssertEquals(1, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	
		Test.startTest();
			Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 25);
		Test.stopTest();
		
		System.AssertEquals(1, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	}

	@isTest
	static void BatchJob_ShouldDoDeleteObjectIfPresentedObjectIsExtracted(){
		insert backfeedObjectsFactory(true);

		System.AssertEquals(1, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	
		Test.startTest();
			Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 25);
		Test.stopTest();
		
		System.AssertEquals(0, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	}
	
	@isTest
	static void BatchJob_ShouldDoNothingIfPresentedObjectIsNotExtracted_Bulk(){
		List<Stage_Maritz_Backfeed_Object__c> stageObjects = new List<Stage_Maritz_Backfeed_Object__c>();
		for (Integer i = 0; i < 200; i++){
			stageObjects.add(backfeedObjectsFactory(false));
		}
		
		insert stageObjects;

		System.AssertEquals(200, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	
		Test.startTest();
			Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 300);
		Test.stopTest();
		
		System.AssertEquals(200, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	}

	@isTest
	static void BatchJob_ShouldDoDeleteObjectIfPresentedObjectIsExtracted_Bulk(){
		List<Stage_Maritz_Backfeed_Object__c> stageObjects = new List<Stage_Maritz_Backfeed_Object__c>();
		for (Integer i = 0; i < 200; i++){
			stageObjects.add(backfeedObjectsFactory(true));
		}
		
		insert stageObjects;

		System.AssertEquals(200, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	
		Test.startTest();
			Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 300);
		Test.stopTest();
		
		System.AssertEquals(0, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	}

	@isTest
	static void BatchJob_MixedObjectsDifferentBehavoir_Bulk(){
		List<Stage_Maritz_Backfeed_Object__c> stageObjects = new List<Stage_Maritz_Backfeed_Object__c>();
		for (Integer i = 0; i < 200; i++){
			stageObjects.add(backfeedObjectsFactory(true));
		}

		for (Integer z = 0; z < 200; z++){
			stageObjects.add(backfeedObjectsFactory(false));
		}
		
		insert stageObjects;

		System.AssertEquals(400, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	
		Test.startTest();
			Database.executeBatch(new Maritz_DeleteExtractedObjects_BatchJob(), 500);
		Test.stopTest();
		
		System.AssertEquals(200, [SELECT Count() FROM Stage_Maritz_Backfeed_Object__c]);
	}
		
	@isTest
	static void ScheduledJob_TestSchedulingIsWorking(){
		Test.startTest();
			String CRON_EXP = '0 0 0 15 3 ? 2022';
			String jobId = System.schedule('TestZZZZZZZZ Maritz Delete Extracted Objects Job', CRON_EXP, new Maritz_DeleteExtractedObjects_Job());

			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

         	System.assertEquals(CRON_EXP, ct.CronExpression);
     		System.assertEquals(0, ct.TimesTriggered);
      		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
	
	private static Stage_Maritz_Backfeed_Object__c backfeedObjectsFactory(Boolean isExtracted){
		Stage_Maritz_Backfeed_Object__c maritzBFObject = new Stage_Maritz_Backfeed_Object__c();

		if (isExtracted){
			maritzBFObject.Backfeed_Type__c = 'Standard Activity';
			maritzBFObject.Batch_Status__c = 'Extracted';
		}
		else{
			maritzBFObject.Backfeed_Type__c = 'NMAC Salesmatch';
			maritzBFObject.Batch_Status__c = 'New';
		}

		return maritzBFObject;
	}
 }