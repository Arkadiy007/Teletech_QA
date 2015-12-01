@isTest
public class ManageEqaPortalUsersController_Test { 
  //-------------------------------------------------
  // Properties
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';
  static final String EQA_INTERNAL_PROFILE = 'EQAInternalPortal User';
  static final Integer BULK_SIZE = 200;
  
  //-------------------------------------------------
  // Tests
  @testSetup static void setup() {
    Account acc = createPortalAccount('Test', true);
    Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
    User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
  }

  @isTest(SeeAllData = false) 
  static void testSearchUsersLogic() {
    System.runAs(adminUser) {
      ManageEqaPortalUsersController c = new ManageEqaPortalUsersController();
 
      Test.startTest();
        c.searchUsers(); // by default no one profile are selected
        System.assertEquals(0, c.usersList.size());

        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :SUPPLIER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Supplier Partner User"');

        c.selectedProfile = profiles[0].Id;
        c.searchUsers();
        System.assertNotEquals(0, c.usersList.size());

        System.assertEquals(true, c.isShowCreateButton);
      Test.stopTest();
    }
  }

  @isTest(SeeAllData = false) 
  static void testUserPopup() {
    System.runAs(adminUser) {
      ManageEqaPortalUsersController c = new ManageEqaPortalUsersController();

      Test.startTest();
        System.assertEquals(false, c.dispalyNewUserPopup);
        
        c.showNewUserPopup(); 
        System.assertEquals(true, c.dispalyNewUserPopup);

        c.closeNewUserPopup();
        System.assertEquals(false, c.dispalyNewUserPopup);
      Test.stopTest();
    }
  }

  @isTest(SeeAllData = false) 
  static void testEnableDisableUser() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('Test10002220@nissan.com', SUPPLIER_PROFILE, c.Id, true);

      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();

      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :SUPPLIER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Supplier Partner User"');

        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();

        cntr.selectedUserId = portalUser.Id;
        cntr.enableDisableUser();

        User u = [SELECT ID, isActive FROM User WHERE Id = :portalUser.Id];
        System.assertEquals(false, u.isActive);
      Test.stopTest();
    }
  }

  @isTest(SeeAllData = false) 
  static void testCreateNewUser_Internal() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();
      cntr.dispalyNewUserPopup = true;
      
      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :EQA_INTERNAL_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQAInternalPortal User"');
        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();
        cntr.showNewUserPopup();

        cntr.newContact.AccountId = acc.Id;
        cntr.newContact.FirstName = 'FirstName';
        cntr.newContact.LastName = 'LastName';

        cntr.newUser.Alias = 'asdfg';
        String userName = 'test@test.com' + System.currentTimeMillis();
        cntr.newUser.Username = userName;
        cntr.newUser.CommunityNickname = 'test' + System.currentTimeMillis();
        cntr.newUser.Email = 'test@test.com';
        cntr.newUser.IsActive = true;
        cntr.createUser();
      Test.stopTest();

      // check that user was created
      User[] users = [SELECT Id FROM User WHERE Username = :userName];
      System.assertEquals(1, users.size());

      // check that group member also created too
      GroupMember[] gm = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :users[0].Id];
      System.assertEquals(1, gm.size());
    }
  }

  @isTest(SeeAllData = false) 
  static void testCreateNewUser_Supplier() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();
      cntr.dispalyNewUserPopup = true;
    
      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :SUPPLIER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Supplier Partner User"');
        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();
        cntr.showNewUserPopup();

        cntr.newContact.AccountId = acc.Id;
        cntr.newContact.FirstName = 'FirstName';
        cntr.newContact.LastName = 'LastName';

        cntr.newUser.Alias = 'asdfg';
        String userName = 'test@test.com' + System.currentTimeMillis();
        cntr.newUser.Username = userName;
        cntr.newUser.CommunityNickname = 'test' + System.currentTimeMillis();
        cntr.newUser.Email = 'test@test.com';
        cntr.newUser.IsActive = true;
        cntr.createUser();
      Test.stopTest();

      System.assertEquals(false, cntr.dispalyNewUserPopup);

      // check that user was created
      User[] users = [SELECT Id FROM User WHERE Username = :userName];
      System.assertEquals(1, users.size());

      // check that group member also created too
      GroupMember[] gm = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :users[0].Id];
      System.assertEquals(0, gm.size());
    }
  }
  
  @isTest(SeeAllData = false) 
  static void testCreateNewUser_Customer() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();
      cntr.dispalyNewUserPopup = true;
    
      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :CUSTOMER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Customer Partner User"');
        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();
        cntr.showNewUserPopup();

        cntr.newContact.AccountId = acc.Id;
        cntr.newContact.FirstName = 'FirstName';
        cntr.newContact.LastName = 'LastName';

        cntr.newUser.Alias = 'asdfg';
        String userName = 'test@test.com' + System.currentTimeMillis();
        cntr.newUser.Username = userName;
        cntr.newUser.CommunityNickname = 'test' + System.currentTimeMillis();
        cntr.newUser.Email = 'test@test.com';
        cntr.newUser.IsActive = true;
        cntr.createUser();
      Test.stopTest();

      System.assertEquals(false, cntr.dispalyNewUserPopup);

      // check that user was created
      User[] users = [SELECT Id FROM User WHERE Username = :userName];
      System.assertEquals(1, users.size());

      // check that group member also created too
      GroupMember[] gm = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :users[0].Id];
      System.assertEquals(0, gm.size());
    }
  }

  @isTest(SeeAllData = false) 
  static void testCreateNewUser_NotActiveSupplier() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();
      cntr.dispalyNewUserPopup = true;  

      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :SUPPLIER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Supplier Partner User"');
        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();
        cntr.showNewUserPopup();

        cntr.newContact.AccountId = acc.Id;
        cntr.newContact.FirstName = 'FirstName';
        cntr.newContact.LastName = 'LastName';

        cntr.newUser.Alias = 'asdfg';
        String userName = 'test@test.com' + System.currentTimeMillis();
        cntr.newUser.Username = userName;
        cntr.newUser.CommunityNickname = 'test' + System.currentTimeMillis();
        cntr.newUser.Email = 'test@test.com';
        cntr.newUser.IsActive = false;
        cntr.createUser();
      Test.stopTest();
        
      System.assertEquals(false, cntr.dispalyNewUserPopup);  
        
      // check that user was created
      User[] users = [SELECT Id, IsActive  FROM User WHERE Username = :userName];
      System.assertEquals(1, users.size());
      System.assertEquals(false, users[0].isActive);
    }
  }

  @isTest(SeeAllData = false) 
  static void testCreateNewUser_NotPopulateRequiredFields() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      ManageEqaPortalUsersController cntr = new ManageEqaPortalUsersController();
      cntr.dispalyNewUserPopup = true;  

      Test.startTest();
        Profile[] profiles = [SELECT Id, Name FROM Profile WHERE Name = :SUPPLIER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Should exist profile with name "EQA-Supplier Partner User"');
        cntr.selectedProfile = profiles[0].Id;
        cntr.searchUsers();
        cntr.showNewUserPopup();

        cntr.newContact.AccountId = acc.Id;
        cntr.newContact.LastName = null;

        cntr.newUser.Alias = 'asdfg';
        String userName = 'test@test.com' + System.currentTimeMillis();
        cntr.newUser.Username = userName;
        cntr.newUser.CommunityNickname = 'test' + System.currentTimeMillis();
        cntr.newUser.Email = 'test@test.com';
        cntr.createUser();
      Test.stopTest();

      System.assertEquals(null, cntr.newUser.Id);
      System.assertEquals(true, cntr.dispalyNewUserPopup);
    }
  }

  //-------------------------------------------------
  // Helpers
  private static Account createPlantAccount(String name, Boolean needInsert) {
    // Create account
    Account a = new Account(
      Name = name,
      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Plant')
    );

    if (needInsert) {
      insert a;
    }

    return a;
  }

  private static Account createPortalAccount(String name, Boolean needInsert) {
    // Create account
    Account portalAccount = new Account(
      Name = name,
      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Supplier')
    );

    if (needInsert) {
      insert portalAccount;
    }

    return portalAccount;
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