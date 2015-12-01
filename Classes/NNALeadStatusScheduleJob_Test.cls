@isTest
private class NNALeadStatusScheduleJob_Test {

	static testMethod void testSheduleJobUpdateCase() {
		insertTestCase();
		NNALeadServicesHandler.LeadApprovalResponse nls;
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new NNALeadStatusScheduleJob_Test.MockHttpResponseGenerator());
		String GUIdSoap = '1111112';
		nls = NNALeadServicesHandler.callLeadSoapService(GUIdSoap);
		Database.executeBatch(new NNALeadStatusScheduleJob(), 50);
		test.stopTest();
		Case test_casee = [SELECT Case_Dealer_Disposition__c FROM Case WHERE SuppliedEmail = 'test1@test.com'];
		String ccd = test_casee.Case_Dealer_Disposition__c;
		System.assertEquals('302', ccd);
	}
	static testMethod void testSizeSheduleJob() {
		CronTrigger[] jobs1;
		CronTrigger[] jobs2;
		CronTrigger[] jobs3;
		Test.startTest();  
		jobs1 = [SELECT Id, CronJobDetail.Name, State, NextFireTime
													FROM CronTrigger WHERE CronJobDetail.Name = 'Dealer to lead Case status update.']; 
		NNALeadStatusScheduleJob.RunScheduleJob();
		jobs2 = [SELECT Id, CronJobDetail.Name, State, NextFireTime
													FROM CronTrigger WHERE CronJobDetail.Name = 'Dealer to lead Case status update.']; 
		NNALeadStatusScheduleJob.RunScheduleJob();
		jobs3 = [SELECT Id, CronJobDetail.Name, State, NextFireTime
													FROM CronTrigger WHERE CronJobDetail.Name = 'Dealer to lead Case status update.']; 
		Test.stopTest();
		
		System.assert(jobs1.size() == 0); 
		System.assert(jobs2.size() > 0); 
		System.assert(jobs3.size() == 1); 
	} 

	public static void insertTestCase() {

		Account test_acc = new Account(Name = 'Test Acc2',
		                               Preferred_Dealer_Code__c = '987456321',
		                               RecordTypeId = '012A0000000OfI0IAK',
		                               Internet_Certified__c = true);
		insert test_acc;

		Account test_acc_d = new Account(Name = 'Test Acc3',
		                                 Preferred_Dealer_Code__c = '987456123',
		                                 RecordTypeId = '012A0000000OfI0IAK',
		                                 Dealer_Code__c = '123321123',
		                                 Internet_Certified__c = true);
		insert test_acc_d;
		Case test_case = new Case(Preferred_Dealer__c = test_acc_d.id,
		                          RecordTypeId = '012F0000000yBMoIAM',
		                          SuppliedEmail = 'test1@test.com',
		                          Alternate_Email__c = 'test1@test.com',
		                          Work_Phone__c = '222222',
		                          AccountId = test_acc.id,
		                          Mailing_Zip_Code__c = '2222',
		                          Considered_Vehicle_Make__c = 'Nissan',
		                          Considered_Vehicle_Model__c = 'Considered Vehicle Model',
		                          Lead_Provider__c = 'Lead Provider',
		                          Lead_Provider_Detail__c = 'Lead Provider Detail',
		                          Case_Dealer_Disposition__c = 'RECEIVED',
		                          Case_GUID__c = '5822ae01-fb6a-4812-8758-bbb1b2b4db28',
		                          //Last_Call_to_USWS__c = System.now().addMinutes(- 40),
		                          Lead_Provider_Name__c = 'Lead Provider Name');
		insert test_case;
	}
	public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			res.setBody('<LeadGUId>1111112</LeadGUId><ResponseTime>12</ResponseTime><ResponseCode>302</ResponseCode><ResponseDetails>test2</ResponseDetails>');
			return res;
		}
	public class MockHttpResponseGenerator implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			res.setBody('<LeadGUId>1111112</LeadGUId><ResponseTime>12</ResponseTime><ResponseCode>302</ResponseCode><ResponseDetails>test2</ResponseDetails>');
			res.setStatus('OK');
			res.setStatusCode(200);
			return res;
		}
	}
}