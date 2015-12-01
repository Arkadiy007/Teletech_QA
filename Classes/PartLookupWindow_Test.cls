@isTest
public class PartLookupWindow_Test { 
  //-------------------------------------------------
  // Properties
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';

  //-------------------------------------------------
  // Tests
  @isTest(SeeAllData = false) 
  static void testLookup() {
    Account acc = createAccount('Test Account', '1;2', true);
    Contact customer = createPortalContact('FirstName', 'LastName', acc.Id, true);
    User portalUser = createPortalUser('customer@nissan.com', CUSTOMER_PROFILE, customer.Id, true);

    System.runAs(portalUser) {
      Part__c p1 = createPart('Test 1', '1', true);
      Part__c p2 = createPart('Test 2', '2', true);
      Part__c p3 = createPart('Test 3', '3', true);

      PartLookupWindow controller = new PartLookupWindow();

      Test.startTest();
        ApexPages.currentPage().getParameters().put('lksrch', 'Test');
        PartLookupWindow wind = new PartLookupWindow();

        System.assertNotEquals(null, wind.results);
        System.assertEquals(2, wind.results.size());
        
        wind.searchString = 'Test 1';
        wind.search();
        System.assertNotEquals(null, wind.results);
        System.assertEquals(1, wind.results.size());

        System.assertEquals(null, wind.getFormTag());
        System.assertEquals(null, wind.getTextBox());
      Test.stopTest();
    }
  }

  //-------------------------------------------------
  // Helpers
  private static Part__c createPart(String name, String customerNumber, Boolean isNeedInsert) {
    Part__c part = new Part__c(
      Name = name,
      Customer_Number__c = customerNumber
    );

    if (isNeedInsert) {
      insert part;
    }

    return part;
  }

  private static Account createAccount(String name, String customerNumbers, Boolean isNeedInsert) {
    Account acc = new Account(
      Name = name,
      Available_Customer_Numbers__c = customerNumbers,
      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Plant')
    );

    if (isNeedInsert) {
      insert acc;
    }

    return acc;
  }

  private static Contact createPortalContact(String firstName, String lastName, Id accountId, Boolean needInsert) {
    // Create contact for the account, which will enable partner portal for account
    Contact portalContact = new Contact(
      FirstName = firstName,
      Lastname = lastName,
      AccountId = accountId,
      Email = lastName + '@nissan.com',
      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Contact.SObjectType, 'Contact')
    );

    if (needInsert) {
      insert portalContact;
    }

    return portalContact;
  }

  private static User createPortalUser(String userName, String profileName, Id contactId, Boolean needInsert) {
    // Create user for the contact
    Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
    User portalUser = new User(
        Username = userName + System.currentTimeMillis(),
        ContactId = contactId,
        ProfileId = portalProfile.Id,
        Alias = 'Nissan',
        Email = 'Nissan@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Kumar',
        CommunityNickname = 'nissan' + System.currentTimeMillis(),
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US'
    );

    if (needInsert) {
      insert portalUser;
    }

    return portalUser;
  }

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