@isTest
public class ShareHelper_Test { 
  //-------------------------------------------------
  // Properties
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';
  static final Integer BULK_SIZE = 200;

  //-------------------------------------------------
  // Tests
  @isTest static void testSharePartIncidentReportRecords_ShareWithSupplier() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, false);
        insert pi;
ShareHelper.share(pi);
      Test.stopTest();

      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(1, partShares.size());
      System.assertEquals(pi.Id, partShares[0].ParentId);
      System.assertEquals('Edit', partShares[0].AccessLevel);
    }
  }

  @isTest static void testSharePartIncidentReportRecords_ShareWithCustomer() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
      User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, false);
        insert pi;
		ShareHelper.share(pi);
      Test.stopTest();

      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :customerPortalUser.Id];
      
      System.assertEquals(1, partShares.size());
      System.assertEquals(pi.Id, partShares[0].ParentId);
      System.assertEquals('Edit', partShares[0].AccessLevel);
    }
  }

  @isTest static void testSharePartIncidentReportRecords_ShareWithCustomerAndSupplier() {
    System.runAs(adminUser) {
      // create supplier user
      Account supplierAccount = createPortalAccount('Test', true);
      Contact supplier = createPortalContact('FirstName', 'LastName', supplierAccount.Id, true);
      User portalUser = createPortalUser('supplier@nissan.com', SUPPLIER_PROFILE, supplier.Id, true);

      // create customer user
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact customer = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
      User customerPortalUser = createPortalUser('customer@nissan.com', CUSTOMER_PROFILE, customer.Id, true);

      Part__c part = createPart(supplierAccount.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, false);
        insert pi;
		ShareHelper.share(pi);
      Test.stopTest();

      // check supplier share records
      Part_Incident_Report__Share[] supplierPartShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(1, supplierPartShares.size());
      System.assertEquals(pi.Id, supplierPartShares[0].ParentId);
      System.assertEquals('Edit', supplierPartShares[0].AccessLevel);

      // check customer share records
      Part_Incident_Report__Share[] customerPartShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :customerPortalUser.Id];
      
      System.assertEquals(1, customerPartShares.size());
      System.assertEquals(pi.Id, customerPartShares[0].ParentId);
      System.assertEquals('Edit', customerPartShares[0].AccessLevel);
    }
  }

  @isTest static void testSharePartIncidentReportRecords_Bulk() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Part_Incident_Report__c[] items = new Part_Incident_Report__c[] {};
        for (Integer i=0; i<BULK_SIZE; i++) {
          Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, false);
          pi.PIR_Number__c = '' + i;
          items.add(pi);
        }

        insert items;
		ShareHelper.share(items);
      Test.stopTest();

      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(BULK_SIZE, partShares.size());
    }
  }

  @isTest static void testShareSortingtReportRecords() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, false);
        insert sr;
		ShareHelper.share(sr);
      Test.stopTest();

      Sorting_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Sorting_Report__Share
                                             WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(1, partShares.size());
      System.assertEquals(sr.Id, partShares[0].ParentId);
      System.assertEquals('Edit', partShares[0].AccessLevel);
    }
  }

  @isTest static void testShareSortingtReportRecords_ShareWithCustomer() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
      User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, false);
        insert sr;
		ShareHelper.share(sr);
      Test.stopTest();

      Sorting_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Sorting_Report__Share
                                             WHERE UserOrGroupId = :customerPortalUser.Id];
      
      System.assertEquals(1, partShares.size());
      System.assertEquals(sr.Id, partShares[0].ParentId);
      System.assertEquals('Edit', partShares[0].AccessLevel);
    }
  }

  @isTest static void testShareMonetaryClaimRecords_IncidentClaim() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, true);

      Test.startTest();
        Monetary_Claim__c mc = createIncidentMonetaryClaim(pi.Id, 'Incident Claim', false);
        insert mc;
		ShareHelper.share(mc);
      Test.stopTest();

      Monetary_Claim__Share[] monetaryShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                  FROM Monetary_Claim__Share
                                                 WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(1, monetaryShares.size());
      System.assertEquals(mc.Id, monetaryShares[0].ParentId);
      System.assertEquals('Edit', monetaryShares[0].AccessLevel);
    }
  }

  @isTest static void testShareMonetaryClaimRecords_SortingReport() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, true);

      Test.startTest();
        Monetary_Claim__c mc = createIncidentMonetaryClaim(sr.Id, 'Sorting Report', false);
        insert mc;
		ShareHelper.share(mc);
      Test.stopTest();

      Monetary_Claim__Share[] monetaryShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                  FROM Monetary_Claim__Share
                                                 WHERE UserOrGroupId = :portalUser.Id];
      
      System.assertEquals(1, monetaryShares.size());
      System.assertEquals(mc.Id, monetaryShares[0].ParentId);
      System.assertEquals('Edit', monetaryShares[0].AccessLevel);
    }
  }
  
  @isTest static void testShareMonetaryClaimRecords_ShareWithCustomer() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
      User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, true);

      Test.startTest();
        Monetary_Claim__c mc = createIncidentMonetaryClaim(sr.Id, 'Sorting Report', false);
        mc.Customer__c = plantAccount.Id;
        insert mc;
		ShareHelper.share(mc);
      Test.stopTest();

      Monetary_Claim__Share[] monetaryShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                  FROM Monetary_Claim__Share
                                                 WHERE UserOrGroupId = :customerPortalUser.Id];
      
      System.assertEquals(1, monetaryShares.size());
      System.assertEquals(mc.Id, monetaryShares[0].ParentId);
      System.assertEquals('Edit', monetaryShares[0].AccessLevel);
    }
  }
  
  @isTest static void testSharePartIncidentReportRecords_WithoutUser() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, false);
        insert pi;

        delete [SELECT Id FROM Part_Incident_Report__Share WHERE UserOrGroupId != :adminUser.Id];
        ShareHelper.share(pi);
      Test.stopTest();

      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId != :adminUser.Id];
      
      System.assertEquals(0, partShares.size());
    }
  }

  @isTest static void testShareExistingRecordsWithSupplier() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, true);
      Part__c part = createPart(acc.Id, true);

      // create PIR record
      Part_Incident_Report__c pir = createPartIncident(plantAccount.Id, part.Id, true);

      // create Sorting Report record
      Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, true);

      // create Monetary Claim 
      Monetary_Claim__c mc = createIncidentMonetaryClaim(sr.Id, 'Sorting Report', true);

      Test.startTest();
        User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
        System.enqueueJob(new ShareHelper.AsyncShareRecords(portalUser.Id));
      Test.stopTest();

      // check that user have access for all existing records
      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :portalUser.Id AND ParentId = :pir.Id];
      System.assertEquals(1, partShares.size());
      System.assertEquals('Edit', partShares[0].AccessLevel);

      Sorting_Report__Share[] sortShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Sorting_Report__Share
                                             WHERE UserOrGroupId = :portalUser.Id AND ParentId = :sr.Id];
      System.assertEquals(1, sortShares.size());
      System.assertEquals('Edit', sortShares[0].AccessLevel);

      Monetary_Claim__Share[] mclaimShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Monetary_Claim__Share
                                             WHERE UserOrGroupId = :portalUser.Id AND ParentId = :mc.Id];
      System.assertEquals(1, mclaimShares.size());
      System.assertEquals('Edit', mclaimShares[0].AccessLevel);
    }
  }

  @isTest static void testShareExistingRecordsWithCustomer() {
    System.runAs(adminUser) {
      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
      Part__c part = createPart(acc.Id, true);

      // create PIR record
      Part_Incident_Report__c pir = createPartIncident(plantAccount.Id, part.Id, true);

      // create Sorting Report record
      Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, true);

      // create Monetary Claim 
      Monetary_Claim__c mc = createIncidentMonetaryClaim(pir.Id, 'Incident Claim', false);
      mc.Customer__c = plantAccount.Id;
      insert mc;

      Test.startTest();
        User portalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);
        System.enqueueJob(new ShareHelper.AsyncShareRecords(portalUser.Id));
      Test.stopTest();

      // check that user have access for all existing records
      Part_Incident_Report__Share[] partShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                                    FROM Part_Incident_Report__Share
                                                   WHERE UserOrGroupId = :portalUser.Id AND ParentId = :pir.Id];
      System.assertEquals(1, partShares.size());
      System.assertEquals('Edit', partShares[0].AccessLevel);

      Sorting_Report__Share[] sortShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Sorting_Report__Share
                                             WHERE UserOrGroupId = :portalUser.Id AND ParentId = :sr.Id];
      System.assertEquals(1, sortShares.size());
      System.assertEquals('Edit', sortShares[0].AccessLevel);

      Monetary_Claim__Share[] mclaimShares = [SELECT Id, ParentId, AccessLevel, UserOrGroupId 
                                              FROM Monetary_Claim__Share
                                             WHERE UserOrGroupId = :portalUser.Id AND ParentId = :mc.Id];
      System.assertEquals(1, mclaimShares.size());
      System.assertEquals('Edit', mclaimShares[0].AccessLevel);
    }
  }

  //-------------------------------------------------
  // Helpers
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

  private static Monetary_Claim__c createIncidentMonetaryClaim(Id piId, String recordTypeName, Boolean needInsert) {
    Monetary_Claim__c mc = new Monetary_Claim__c(
      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Monetary_Claim__c.SObjectType, recordTypeName)
    );

    if ('Incident Claim' == recordTypeName) {
      mc.Part_Incident_Report__c = piId;
    } else {
      mc.Sorting_Report__c = piId;
    }

    if (needInsert) {
      insert mc;
    }

    return mc;
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