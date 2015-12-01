@isTest
public class Batch_LinkSurveysToCases_Test {
	static testMethod void testCaseCreation() {
		Id epsilonRT = RecordTypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Epsilon Survey');
		Surveys__c survey = new Surveys__c(Lead_Id__c = '777', EpErrors__c = 'Case with such leadId cannot be found', recordtypeId = epsilonRT, DQR_Dealer_Contacted__c = 'Yes');
		RecordType caseDIPCRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
		insert survey;
		Case c = new Case(DQR_Number__c = '777', RecordTypeId = caseDIPCRT.ID);
		insert c;
		Test.startTest();
		Batch_LinkSurveysToCases batchJob = new Batch_LinkSurveysToCases();
		Database.executeBatch(batchJob);
		Test.stopTest();
		List<Surveys__c> surveyItem = [select ID, EpErrors__c from Surveys__c];
		System.assertEquals(surveyItem[0].EpErrors__c, null);
		System.assertEquals(surveyItem.size(), 1);

	}
	static testmethod void testSchedule() {
		// Schedule the test job
		Test.startTest();
		DateTime nextSchedule = DateTime.now().addSeconds(5);

		String jobId = System.schedule('ScheduleBatch', nextSchedule.format('ss mm HH dd MM ? yyyy'), new Batch_LinkSurveysToCases());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
		                  NextFireTime
		                  FROM CronTrigger WHERE id = :jobId];


		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		Test.stopTest();
	}
}