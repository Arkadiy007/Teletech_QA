/**********************************************************************
Name: Schedule_Batch_SurveyGizmo_Load_Tests 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for Schedule_Batch_SurveyGizmo_Load Apex Class 

Related to:Schedule_Batch_SurveyGizmo_Load
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Koseikina Anna 06/18/2015 created 
***********************************************************************/
@istest
public class Schedule_Batch_SurveyGizmo_Load_tests { 
// CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
		        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        Account account = new Account();
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Customer_ID__c = '987654321';
        insert account;
		Lead lead = new Lead();
        lead.lastname = 'leadTest';
        lead.Customer_ID__c = '987654321';
        insert lead;
		Account dealer = new Account();
        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = '123456789';
        dealer.Dealer_External_Id__c = '123456789' + System.label.Dealer_USA;
        insert dealer;
		Case thisSurveyCase = new Case();
         
          //thisSurveyCase.DQR_Number__c
          //thisSurveyCase.Maritz_Customer_Id__c;
          thisSurveyCase.Dealer__r = dealer;
          thisSurveyCase.Considered_Vehicle_Make__c = 'NISSAN';
          thisSurveyCase.Account= account;
          //thisSurveyCase.Contact.FirstName;
          //thisSurveyCase.Contact.LastName;
            thisSurveyCase.Surveyable__c = true;
            thisSurveyCase.RecordTypeId = '012F0000000yBMoIAM';
            thisSurveyCase.Date_Sent__c = Date.newInstance(2014,2,1);
        insert thisSurveyCase;
		Test.startTest();
      // Schedule the test job
	  DateTime nextSchedule = DateTime.now().addSeconds(5);
	try{
		  String jobId = System.schedule('Schedule_Batch_SurveyGizmo_Load_tests', nextSchedule.format('ss mm HH dd MM ? yyyy'), new Schedule_Batch_SurveyGizmo_Load ());
        
		  // Get the information from the CronTrigger API object
		  CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
			 NextFireTime
			 FROM CronTrigger WHERE id = :jobId];


		  // Verify the job has not run
		  System.assertEquals(0, ct.TimesTriggered);
      }
	  catch(Exception e){} 
      Test.stopTest();


   }
   	public class MockHttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
	 
		public HTTPResponse respond(HTTPRequest req) {
		String endpointUrl =  System.URL.getSalesforceBaseUrl().toExternalForm() +'https://restapi.surveygizmo.com/v4/survey/';
		string url = System.URL.getSalesforceBaseUrl().toExternalForm() + 'https://restapi.surveygizmo.com/v4/survey/';
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals(url, req.getEndpoint());
			System.assertEquals('PUT', req.getMethod());
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"ConcurrentAsyncGetReportInstances":{"Max":200,"Remaining":200},"ConcurrentSyncReportRuns":{"Max":20,"Remaining":20}}');
			res.setStatusCode(200);
			return res;
		}
	}
}