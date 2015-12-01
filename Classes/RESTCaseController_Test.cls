@IsTest
class RESTCaseController_Test { 
  //--------------------------------------------------------------------------
  // Tests
  static testMethod void testServiceLogic_SuccessUpdateCase() {
    User adminUser = createAdminUser('admin@nissan.com');
    System.runAs(adminUser) {
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      
      // pass the req and resp objects to the method     
      req.requestURI = 'https://instance.salesforce.com/Case/UpdateCaseStatus';  
      req.httpMethod = 'POST';

      RestContext.request = req;
      RestContext.response = res;


      String guid = '8eb8d592-9f7b-490b-a426-674efdab947c';
      String dispositionStatus = 'REJECTED';
      String dispositionInformation = 'The lead has been rejected.';

      // create existing case record
      Case c = createCase(guid);

      start();
        RESTCaseController.UpdateCaseStatus(guid, dispositionStatus, dispositionInformation);
      stop();

      // check response
      System.assertEquals(200, res.statuscode);
      System.assertEquals('{"response": {"status": "Success", "message": ""}}', res.responseBody.toString());
      
      // check that case was updated
      Case[] cases = [SELECT Id, Case_GUID__c, Case_Dealer_Disposition__c, Case_Dealer_Disposition_Information__c
                        FROM Case
                       WHERE Id = :c.Id];
      System.assertEquals(1, cases.size());
      System.assertEquals(guid, cases[0].Case_GUID__c);
      System.assertEquals(dispositionStatus, cases[0].Case_Dealer_Disposition__c);
      System.assertEquals(dispositionInformation, cases[0].Case_Dealer_Disposition_Information__c);
    }
  }
  
  static testMethod void testServiceLogic_NotExistingCase() {
    User adminUser = createAdminUser('admin@nissan.com');
    System.runAs(adminUser) {
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();

      // pass the req and resp objects to the method     
      req.requestURI = 'https://instance.salesforce.com/Case/UpdateCaseStatus';  
      req.httpMethod = 'POST';

      RestContext.request = req;
      RestContext.response = res;

      String guid = '8eb8d592-9f7b-490b-a426-674efdab947c';
      String dispositionStatus = 'REJECTED';
      String dispositionInformation = 'The lead has been rejected.';

      start();
        RESTCaseController.UpdateCaseStatus(guid, dispositionStatus, dispositionInformation);
      stop();

      // check response
      System.assertEquals(400, res.statuscode);
      System.assertEquals(
        '{"response": {"status": "Failure", "message": "Unable to find case maching guid: ' + guid + '"}}', 
        res.responseBody.toString()
      );
    }
  }
  
  static testMethod void testServiceLogic_FailUpdateCase() {
    User adminUser = createAdminUser('admin@nissan.com');
    System.runAs(adminUser) {
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();

      // pass the req and resp objects to the method     
      req.requestURI = 'https://instance.salesforce.com/Case/UpdateCaseStatus';  
      req.httpMethod = 'POST';

      RestContext.request = req;
      RestContext.response = res;

      String guid = '8eb8d592-9f7b-490b-a426-674efdab947c';
      String dispositionStatus = 'REJECTED';
      String dispositionInformation = 'The lead has been rejected.';

      // for throw exception we need to exceed length of field limits
      // custom picklist: Up to 255 characters per entry
      String dispositionStatusLong = dispositionInformation.repeat(100);

      // create existing case record
      Case c = createCase(guid);

      start();
        RESTCaseController.UpdateCaseStatus(guid, dispositionStatusLong, dispositionInformation);
      stop();

      // check response
      System.assertEquals(500, res.statuscode);
      System.assertEquals(
        true, 
        res.responseBody.toString().startsWith('{"response": {"status": "Failure", "message": "System.DmlException: Update failed.'),
        res.responseBody.toString()
      );
    }
  }
  

  //--------------------------------------------------------------------------
  // Helpers

  private static Case createCase(String guid) {
    Case c = new Case(
      Case_GUID__c = guid
    );

    insert c;
    return c;
  }

  /** a default user to use in System.runAs() */
  private static User createAdminUser(String name) {
    User adminUser = new User();

    // all test code should execute under a user we can control so as to avoid
    // surprises when deploying to different environments.
    UserRole[] roles = [SELECT Id FROM UserRole WHERE DeveloperName = 'System_Administrator'];
    if (roles.isEmpty()) {
      roles.add(new UserRole(DeveloperName = 'System_Administrator', Name = 'r0'));
      insert roles;
    }
        
    adminUser = newUser(name);
    adminUser.UserRoleId = roles[0].Id;
    insert adminUser;

    return adminUser;
  }

  private static User newUser(String username) {
    final Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    return newUser(username, profileId);
  }

  private static User newUser(String username, Id profileId) {
    return new User(
      ProfileId = [SELECT Id FROM Profile WHERE Id = :profileId LIMIT 1].Id,
      LastName = 'last',
      Email = 'user@nissan.com',
      Username = username + System.currentTimeMillis(),
      CompanyName = 'Nissan',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Chicago',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
  }

  /** use this instead of Test.startTest() to provide extra functionality */
  public static void start() {
    Test.startTest();
  }
  
  /** use this instead of Test.stopTest() to provide extra functionality */
  public static void stop() {
    Test.stopTest();
  }
}