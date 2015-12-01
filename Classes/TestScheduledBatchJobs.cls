@isTest                                
private class TestScheduledBatchJobs {

static testmethod void Test_Techline_New_CmtStg_DataLoad() {
    Code__c lastRunTimeCode2 = new Code__c(Type__c='Last_Run_Time',Code__c='Techline_Comment_Backfeed',Description__c=String.valueOfGmt(DateTime.now()));
    insert lastRunTimeCode2;

    Test.startTest();
    Schedule_Techline_New_CmtStg_DataLoad sh1 = new Schedule_Techline_New_CmtStg_DataLoad();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();

}
static testmethod void Test_Batch_Techline_New_CaseStaging_DataLoad() {

    Code__c lastRunTimeCode = new Code__c(Type__c='Last_Run_Time',Code__c='Techline_Case_Backfeed',Description__c=String.valueOfGmt(DateTime.now()));
    insert lastRunTimeCode;
    Test.startTest();
    Schedule_Techline_New_CaseStgng_DataLoad sh1 = new Schedule_Techline_New_CaseStgng_DataLoad();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();

}

static testmethod void Test_Schedule_CA_Update_Sharing() {

    Test.startTest();
    Schedule_CA_Update_Sharing sh1 = new Schedule_CA_Update_Sharing();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

static testmethod void Test_Schedule_VCSCaseStaging_DataLoad() {

    Test.startTest();
    Schedule_VCSCaseStaging_DataLoad sh1 = new Schedule_VCSCaseStaging_DataLoad();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

static testmethod void Test_Schedule_VCS_Alert_Case_DataLoad() {

    Test.startTest();
    Schedule_VCS_Alert_Case_DataLoad sh1 = new Schedule_VCS_Alert_Case_DataLoad();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

static testmethod void Test_Schedule_VCS_Alert_Email() {

    Test.startTest();
    Schedule_VCS_Alert_Email sh1 = new Schedule_VCS_Alert_Email();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

static testmethod void Test_Schedule_VCS_Alert_Update_Sharing() {

    Test.startTest();
    Schedule_VCS_Alert_Update_Sharing sh1 = new Schedule_VCS_Alert_Update_Sharing();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

static testmethod void Schedule_VCS_Alert_Close() {

    Test.startTest();
    Schedule_VCS_Alert_Close sh1 = new Schedule_VCS_Alert_Close();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}
static testmethod void Schedule_SurveyGizmo_CampaignDelete() {
    SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, fakeResponse);

    Schedule_SurveyGizmo_CampaignDelete sh1 = new Schedule_SurveyGizmo_CampaignDelete();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}
static testmethod void DispositionUpdateScheduledJob() {

    Test.startTest();
    DispositionUpdateScheduledJob sh1 = new DispositionUpdateScheduledJob();
    String sch = '0 30 20 * * ?';
    system.schedule('test cmt stg', sch,sh1);
    Test.stopTest();
}

//Mockup class for http collout
public class SingleRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}

}