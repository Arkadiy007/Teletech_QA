@isTest
public with sharing class Test_EQ_RecordingSearch {
  
  // -------- Constants --------  
  private final static String CALLOUT_INVALID_AGENT_ID = '11111';
  private final static String CALLOUT_VALID_AGENT_ID = '99999';  
  private final static String CALLOUT_VALID_RETURN_VALUE = '999999999.wmv';  
  private final static String CALLOUT_EXCEPTION_RETURN_VALUE = '-99999.wmv';
  private final static String CALLOUT_EXCEPTION_ERROR_CODE = '-99999: Unable to retrieve EyeQ recording id.';
  private final static String CALLOUT_EXCEPTION_ERROR_MSG = 'Unable to ' + 
    'retrieve EyeQ recording id.'; 

  // -------- Variables --------
  static NNA_EyeQRecordingSearch testClass;
  static Profile testProfile;
  static User testUser;
  
  // -------- Shared Methods --------
  // Default data
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
    
    testClass = new NNA_EyeQRecordingSearch();
  }
  
  //Mock Webservice callout  
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
  
  // -------- Test Methods --------
  // Test for empty Agent Id running as test user 
  static testMethod void setRecordingIdWhenNoAgentId() {
    init(0);
    testUser.cnx__Agent_ID__c = null;
    
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      insert cr;
      
      Test.setMock(WebServiceMock.class, 
        new Test_EQ_RecordingSearch.RecordingServiceMockImpl());
      
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c  
                  FROM Task WHERE Agent_ID__c = :testUser.cnx__Agent_ID__c AND
                  Status <> 'Complete' ORDER BY CreatedDate 
                  DESC LIMIT 1];
            
      system.debug('setRecordingIdWhenNoAgentId ID: ' + cr.Call_Recording_ID__c);
      system.debug('setRecordingIdWhenNoAgentId Error: ' + cr.EyeQ_Error_Code__c);
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_EXCEPTION_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, CALLOUT_EXCEPTION_ERROR_CODE);
      
  
      Test.stopTest();
    }
  }
  
  // Test for Agent Id that has no recording id as test user
  static testMethod void setRecordingIdWhenNoResultFound() {
    init(0);
    testUser.cnx__Agent_ID__c = CALLOUT_INVALID_AGENT_ID;
    
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
        
      Test.setMock(WebServiceMock.class, new Test_EQ_RecordingSearch.RecordingServiceMockImpl());
      
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c  
                  FROM Task WHERE id = :cr.id];
      system.debug('setRecordingIdWhenNoResultFound ID: ' + cr.Call_Recording_ID__c);
      system.debug('setRecordingIdWhenNoResultFound Error: ' + cr.EyeQ_Error_Code__c);
    }
  }

  // Test for valid recording id.
  static testMethod void setRecordingIdWhenResultFound() {
    init(0);
    testUser.cnx__Agent_ID__c = CALLOUT_VALID_AGENT_ID;
    
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      Test.setMock(WebServiceMock.class, 
        new Test_EQ_RecordingSearch.RecordingServiceMockImpl());
      
      testClass.setRecordingId(cr.id, testUser.cnx__Agent_ID__c);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c  
                  FROM Task WHERE id = :cr.id];
      
      system.debug('setRecordingIdWhenResultFound ID: ' + cr.Call_Recording_ID__c);
      system.debug('setRecordingIdWhenResultFound Error: ' + cr.EyeQ_Error_Code__c);
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_VALID_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, null);
    }
  }
    
  // Test remote action method for valid recording id.
  static testMethod void setRecordingIdWithRemoteAction() {
    init(0);
    testUser.cnx__Agent_ID__c = CALLOUT_VALID_AGENT_ID;
    
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
      
      Test.setMock(WebServiceMock.class, 
        new Test_EQ_RecordingSearch.RecordingServiceMockImpl());
      
      NNA_EyeQRecordingSearch.remoteRecordingId(cr.id);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c  
                  FROM Task WHERE id = :cr.id];
      
      system.debug('setRecordingIdWhenResultFound ID: ' + cr.Call_Recording_ID__c);
      system.debug('setRecordingIdWhenResultFound Error: ' + cr.EyeQ_Error_Code__c);
      System.assertEquals(cr.Call_Recording_ID__c, CALLOUT_VALID_RETURN_VALUE);
      System.assertEquals(cr.EyeQ_Error_Code__c, null);
    }
  }
    
  
  // Test remote action method for invalid recording id.
  static testMethod void setRecordingIdWithRemoteActionInvalidReturn() {
    init(0);
    testUser.cnx__Agent_ID__c = null;
    
    System.RunAs(testUser) {
      Test.startTest();
      
      Task cr = new Task();
      cr.Agent_ID__c = testUser.cnx__Agent_ID__c;
      insert cr;
        
      Test.setMock(WebServiceMock.class, new Test_EQ_RecordingSearch.RecordingServiceMockImpl());
      
      NNA_EyeQRecordingSearch.remoteRecordingId(cr.id);

      Test.stopTest();
      
            cr = [SELECT Id, Call_Recording_ID__c, EyeQ_Error_Code__c  
                  FROM Task WHERE id = :cr.id];
      system.debug('setRecordingIdWhenNoResultFound ID: ' + cr.Call_Recording_ID__c);
      system.debug('setRecordingIdWhenNoResultFound Error: ' + cr.EyeQ_Error_Code__c);
    }
  }
}