@isTest
public class DeleteOldRecordsJob_Test { 
  //-------------------------------------------------
  // Tests
  @isTest(SeeAllData = false) 
  static void testSearchUsersLogic() {
    System.runAs(adminUser) {
      Test.startTest();
        DeleteOldRecordsJob.Run('TEST Delete old PIRs', Part_Incident_Report__c.SObjectType);
        DeleteOldRecordsJob.Run('TEST Delete old Sorting Reports', Sorting_Report__c.SObjectType);
        DeleteOldRecordsJob.Run('TEST Delete old Monetary Claims', Monetary_Claim__c.SObjectType);

        // check that 3 jobs was runned
        CronTrigger[] jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                FROM CronTrigger 
                               WHERE CronJobDetail.Name IN (
                                      'TEST Delete old PIRs', 
                                      'TEST Delete old Sorting Reports',
                                      'TEST Delete old Monetary Claims')];
        System.assertEquals(3, jobs.size());
      Test.stopTest();
    }
  }

  //-------------------------------------------------
  // Helpers

  /** Create default user for run test */
  private static User adminUser {
    get {
      if (null == adminUser) {
        UserRole[] roles = [SELECT Id FROM UserRole WHERE DeveloperName = 'System_Administrator'];
        if (roles.isEmpty()) {
          roles.add(new UserRole(DeveloperName = 'System_Administrator', Name = 'r0'));
          insert roles;
        }

        adminUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'user@Nissan.com',
            Username = 'admin@Nissan.com' + System.currentTimeMillis(),
            CompanyName = 'Nissan',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = roles[0].Id
        );

        insert adminUser;
      }

      return adminUser;
    }

    private set;
  }
}