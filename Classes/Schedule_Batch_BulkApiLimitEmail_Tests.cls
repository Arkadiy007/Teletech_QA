/**********************************************************************
Name: DailyApiLimits_Controller_Tests
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests the Apex class Schedule_Batch_BulkAPILimitEmail.

Related Class : Schedule_Batch_BulkAPILimitEmail
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina 6/16/15 Created
***********************************************************************/

@isTest
public class Schedule_Batch_BulkApiLimitEmail_Tests { 
public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testMethod void TestApiLimits() {
        

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.startTest();
        List<Schedule_Batch_BulkAPILimitEmail.ApiLimit> apiLimits = Schedule_Batch_BulkAPILimitEmail.getapiLimits(userInfo.getSessionId());
        String jobId = System.schedule('Schedule_Batch_BulkAPILimitEmail',

                        CRON_EXP,

                        new Schedule_Batch_BulkAPILimitEmail(userInfo.getSessionId()));
        System.assert(null != jobId);
        System.assert(null != apiLimits);
        //test.stoptest();
    }
    static testMethod void Testexecute() {
        
        Api_Usage_Limits__c api = new Api_Usage_Limits__c(Emails__c = Userinfo.getUserEmail(), Number_of_batches__c = 300);
        insert api;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        //test.startTest();
        Schedule_Batch_BulkAPILimitEmail.ExecuteWithCallout(userInfo.getSessionId());
        //test.stoptest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
     
        public HTTPResponse respond(HTTPRequest req) {
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/limits/';
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals(url, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
        
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ConcurrentAsyncGetReportInstances":{"Max":200,"Remaining":200},"ConcurrentSyncReportRuns":{"Max":20,"Remaining":20}}');
            res.setStatusCode(200);
            return res;
        }
    }
}