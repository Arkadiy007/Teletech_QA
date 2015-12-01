/**********************************************************************
  Name: DispositionUpdateBatchTests
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose
  Test for DispositionUpdateBatch job
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 03/12/2015 Created
 ***********************************************************************/
@isTest
private class DispositionUpdateBatchTest
{
	/**
	 *	Test method, to assure, that batch job work correctly by updating corresponding tasks
	 */
	@isTest
	static void isBatchJobWorkedCorrectly()
	{
		User_Role_Check_Enabled__c userRoleCusomSetting = new User_Role_Check_Enabled__c();
		userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
		insert userRoleCusomSetting;

		RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Service marketing'] [0];
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'Zstandarduser@testorg.com', Call_Centre_Id__c = '11'
		);

		insert u;
		// Create some test task items to be update
		// by the batch job.
		Task[] ml = new List <Task > ();
		for (Integer i = 0; i <10; i++) {
			Task m = new Task(
			                  RecordTypeId = rt.id,
			                  CreatedDate = Date.today(),
			                  OwnerId = u.id
			);
			ml.add(m);
		}
		insert ml;

		Test.startTest();
		DispositionUpdateBatch batch = new DispositionUpdateBatch();
		Database.executeBatch(batch);

		Test.stopTest();

		System.assertEquals([SELECT Count() FROM Task WHERE TMS_Disposition__c = '10'], 10);

	}
}