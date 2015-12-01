@isTest
public class SREscalateExtension_Test {
  //-------------------------------------------------
  // Properties
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';
  static final String EQA_INTERNAL_PROFILE = 'EQAInternalPortal User';
  static final Integer BULK_SIZE = 200;
  
  //-------------------------------------------------
  // Tests
  @testSetup static void setup() {
    System.runAs(adminUser) {
        Account acc = createPortalAccount('Test', true);
        Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
        c.EQA_Records_Owner__c = true;
        insert c;
        
        User portalUser = createPortalUser('User@nissan.com', SUPPLIER_PROFILE, c.Id, true);
        
        EQA_Escalation_Settings__c settings = EQA_Escalation_Settings__c.getOrgDefaults();
        settings.Portal_Account_ID__c = acc.Id;
        upsert settings;
     }
  }
  
  @isTest(SeeAllData = false) 
  static void testEscalate() {
    Sorting_Report__c sr;
    User portalUser;
    Id onwerId;
    
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      sr = createSortingReport(plantAccount.Id, part.Id, true);
      
      // query owner user
      onwerId = getOnwerId();
      System.assertNotEquals(null, onwerId);
    }
    
    System.runAs(portalUser) { 
      ApexPages.StandardController sc = new ApexPages.StandardController(sr);
      SREscalateExtension ex = new SREscalateExtension(sc);     
      
      Test.startTest();
          PageReference pRef = ex.escalate();
          System.assertEquals(null, ex.errorMessage);
          System.assertNotEquals(null, pRef);
          System.assertEquals('/' + sr.Id, pRef.getUrl());
      Test.stoptest();
      
      Sorting_Report__c  srUpdated = [SELECT ID, OwnerID, Current_Owner__c FROM Sorting_Report__c WHERE Id = :sr.Id];
      System.assertEquals(onwerId, srUpdated.OwnerId);
      System.assertEquals('EQA', srUpdated.Current_Owner__c);
    }
  }
  
  @isTest(SeeAllData = false) 
  static void testBack() {
    Sorting_Report__c sr;
    User portalUser;
    Id onwerId;
    
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      sr = createSortingReport(plantAccount.Id, part.Id, true);
      
      // query owner user
      onwerId = getOnwerId();
      System.assertNotEquals(null, onwerId);
    }
    
    System.runAs(portalUser) { 
      ApexPages.StandardController sc = new ApexPages.StandardController(sr);
      SREscalateExtension  ex = new SREscalateExtension(sc);     
      
      Test.startTest();
          PageReference pRef = ex.back();
          System.assertEquals(null, ex.errorMessage);
          System.assertNotEquals(null, pRef);
          System.assertEquals('/' + sr.Id, pRef.getUrl());
      Test.stoptest();
    }
  }
  
  @isTest(SeeAllData = false) 
  static void testError_NotSpecifiedAccountId() {
    Sorting_Report__c sr;
    User portalUser;
    
    System.runAs(adminUser) {
      EQA_Escalation_Settings__c settings = EQA_Escalation_Settings__c.getOrgDefaults();
      settings.Portal_Account_ID__c = null;
      upsert settings;
    
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      sr = createSortingReport(plantAccount.Id, part.Id, true);
    }
    
    System.runAs(portalUser) { 
      ApexPages.StandardController sc = new ApexPages.StandardController(sr);
      SREscalateExtension ex = new SREscalateExtension(sc);    
      
      Test.startTest();
          PageReference pRef = ex.escalate();
          System.assertNotEquals(null, ex.errorMessage);
          System.assertEquals(null, pRef);
      Test.stoptest();
    }
  }
  
  //-------------------------------------------------
  // Helpers
  private static Id getOnwerId() {
      EQA_Escalation_Settings__c settings = EQA_Escalation_Settings__c.getOrgDefaults();
      Contact[] contactsList = [SELECT Id, EQA_Records_Owner__c, Name FROM Contact 
                                 WHERE AccountId = :settings.Portal_Account_ID__c AND EQA_Records_Owner__c = true];
      
      if (!contactsList.isEmpty()) {
          User[] usersList = [SELECT Id FROM User WHERE ContactId = :contactsList[0].Id];
          if (!usersList.isEmpty()) {
              return usersList[0].Id;
          }
      }
      
      return null;
  }
  
  private static Part__c createPart(Id accountId, Boolean needInsert) {
    Part__c part = new Part__c(
      Name = 'test',
      Supplier__c = accountId
    );

    if (needInsert) {
      insert part;
    }

    return part;
  }

  private static Part_Incident_Report__c createPartIncident(Id customerId, Id partId, Boolean needInsert) {
    Part_Incident_Report__c p = new Part_Incident_Report__c(
      Customer__c = customerId,
      PIR_Number__c = '123',
      Part__c = partId,
      Issue_Type__c = 'Logistics',
      PIR_Status__c = 'Open',
      Supplier_Response__c = 'Accept'
    );

    if (needInsert) {
      insert p;
    }

    return p;
  }

  private static Sorting_Report__c createSortingReport(Id customerId, Id partId, Boolean needInsert) {
    Sorting_Report__c s = new Sorting_Report__c(
      Customer__c = customerId,
      Part__c = partId,
      Supplier_Response__c = 'Accept'
    );

    if (needInsert) {
      insert s;
    }

    return s;
  }

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