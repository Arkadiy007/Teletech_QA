/**********************************************************************
Name: wwwMaritzComWebservices_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for wwwMaritzComWebservicesr.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 02/07/2011 Created 
***********************************************************************/
@isTest
private global class wwwMaritzComWebservices_Test  {
    
    static  testmethod void testSubmitRecord() {
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        wwwMaritzComWebservices.SubmitSoap obj = new wwwMaritzComWebservices.SubmitSoap();
        obj.SubmitRecord('', '');
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        obj.SubmitPerson('', '', '', '', '');
    }
    
    static  testmethod void testSubmitPerson() {
        wwwMaritzComWebservices.SubmitRecordResponse_element obj1 = new wwwMaritzComWebservices.SubmitRecordResponse_element();
        wwwMaritzComWebservices.SubmitPersonResponse_element obj2 = new wwwMaritzComWebservices.SubmitPersonResponse_element();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        wwwMaritzComWebservices.SubmitSoap obj = new wwwMaritzComWebservices.SubmitSoap();
        obj.SubmitPerson('', '', '', '', '');
    }

	//------Mockups------//
	global class WebServiceMockImpl1 implements WebServiceMock {
	   global void doInvoke(
			   Object stub,
			   Object request,
			   Map<String, Object> response,
			   String endpoint,
			   String soapAction,
			   String requestName,
			   String responseNS,
			   String responseName,
			   String responseType) {
		   wwwMaritzComWebservices.SubmitRecordResponse_element respElement = new wwwMaritzComWebservices.SubmitRecordResponse_element();
		   respElement.SubmitRecordResult = true;
		   response.put('response_x', respElement); 
	   }
	}

	global class WebServiceMockImpl2 implements WebServiceMock {
	   global void doInvoke(
			   Object stub,
			   Object request,
			   Map<String, Object> response,
			   String endpoint,
			   String soapAction,
			   String requestName,
			   String responseNS,
			   String responseName,
			   String responseType) {
		   wwwMaritzComWebservices.SubmitPersonResponse_element respElement = new wwwMaritzComWebservices.SubmitPersonResponse_element();
		   respElement.SubmitPersonResult = true;
		   response.put('response_x', respElement); 
	   }
	}

}