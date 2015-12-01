@isTest
public with sharing class Test_NNA_EyeQRecordingSearchProxy  {
  // -------- Constants --------
  private final static String CALLOUT_INVALID_VAD_ID = '11111';
  private final static String CALLOUT_VALID_VAD_ID = '99999';  
  private final static String CALLOUT_VALID_RETURN_VALUE = '999999999.wmv';  
  private final static String CALLOUT_EXCEPTION_RETURN_VALUE = '-99999.wmv';
  private final static String CALLOUT_EXCEPTION_ERROR_CODE = '-99999: Unable to retrieve EyeQ recording id.';
  private final static String CALLOUT_EXCEPTION_ERROR_MSG = 'Unable to ' +
    'retrieve EyeQ recording id.'; 
  
  // -------- Variables --------
  static NNA_EyeQRecordingSearchProxy testClass;
  static Profile testProfile;
  static User testUser;

  public class RecordingServiceMockImpl implements WebServiceMock {
    public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType) {
      NNA_EyeQRecordingServiceWSDL.GetRecordingIdResponse_element respElement = 
        new NNA_EyeQRecordingServiceWSDL.GetRecordingIdResponse_element();      
      respElement.result = new NNA_EyeQRecordingServiceWSDL.tResult();
      respElement.result.errorCode = null;
      respElement.result.errorMsg = null;
      respElement.GetRecordingIdResult = 999999999;
      response.put('response_x', respElement);      
    }
  }
  
  // -------- Shared Methods --------
  // Default test data
  static Void init(Integer profileType) {
    
    if(profileType == 0) {
      testProfile = [SELECT Id, Name FROM Profile WHERE 
        Name = 'Standard User'];
      
      testUser = new User(Alias = 'autoTest', 
        Email = 'fake@fake.com', EmailEncodingKey = 'UTF-8', 
        LastName = 'autoTesting', LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', ProfileId = testProfile.Id, 
        TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'testAgent@testAgent.com',
        cnx__Agent_ID__c = '');
    }
    
    testClass = new NNA_EyeQRecordingSearchProxy();
    
  }
  
  // -------- Test Methods --------
  // Test with no web service callout when no Agent Id.
  static testMethod void setRecordingIdWithNoWSCalloutWhenNoAgentId() {
    init(0);

    testUser.cnx__Agent_ID__c = null;
    System.RunAs(testUser) {
      
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      testClass.useProxy = true;
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c 
                  FROM Task WHERE id = :cr.id];
      System.assertEquals(cr.EyeQ_Error_Code__c, 
        CALLOUT_EXCEPTION_ERROR_CODE);
      //System.assertEquals(cr.EyeQ_Error_Message__c, 
        //CALLOUT_EXCEPTION_ERROR_MSG);
    }
  }
  
  // Test with web service callout when no Agent Id.
  static testMethod void setRecordingIdWithWSCalloutWhenNoAgentId() {
    init(0);
    
    testUser.cnx__Agent_ID__c = null;
    System.RunAs(testUser) {
      
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;      
      
      Test.setMock(WebServiceMock.class, 
        new Test_NNA_EyeQRecordingSearchProxy.RecordingServiceMockImpl());      
      testClass.useProxy = false;
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);
      
      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c 
                  FROM Task WHERE id = :cr.id];
      System.assertEquals(cr.Call_Recording_ID__c, 
        CALLOUT_EXCEPTION_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, 
        CALLOUT_EXCEPTION_ERROR_CODE);
      //System.assertEquals(cr.EyeQ_Error_Message__c, 
        //CALLOUT_EXCEPTION_ERROR_MSG);
    }
  }

  // Test with no web service callout when Error.
  static testMethod void setRecordingIdWithNoWSCalloutWhenError() {
    init(0);
    
    testUser.cnx__Agent_ID__c = CALLOUT_INVALID_VAD_ID;
    System.RunAs(testUser) {
      
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      testClass.useProxy = true;
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c 
                  FROM Task WHERE id = :cr.id];
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_EXCEPTION_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, 
        CALLOUT_EXCEPTION_ERROR_CODE);
      //System.assertEquals(cr.EyeQ_Error_Message__c, 
        //CALLOUT_EXCEPTION_ERROR_MSG);
    }
  }
  
  // Test with no web service callout when no error.
  static testMethod void setRecordingIdWithNoWSCalloutWhenNoError() {
    init(0);
    
    testUser.cnx__Agent_ID__c = CALLOUT_VALID_VAD_ID;
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      testClass.useProxy = true;
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c 
                  FROM Task WHERE id = :cr.id];
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_VALID_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, null);
      //System.assertEquals(cr.EyeQ_Error_Message__c, null);
    }
  }
  
  // Test with web service callout when no error.
  static testMethod void setRecordingIdWithWSCalloutWhenNoError() {
    init(0);
    
    testUser.cnx__Agent_ID__c = CALLOUT_VALID_VAD_ID;
    System.RunAs(testUser) {
      
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      Test.setMock(WebServiceMock.class, 
        new Test_NNA_EyeQRecordingSearchProxy.RecordingServiceMockImpl());      
      testClass.useProxy = false;
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c 
                  FROM Task WHERE id = :cr.id];
            
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_VALID_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, null);
      //System.assertEquals(cr.EyeQ_Error_Message__c, null);
    }
  }
}