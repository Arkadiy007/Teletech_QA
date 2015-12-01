@isTest
public class EQATransferControllerTest { 
  //-------------------------------------------------
  // Properties
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';
  static final Integer BULK_SIZE = 200;
  
  //-------------------------------------------------
  // Tests
  @isTest static void testTransfer_Error() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Test.startTest();
        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(false, controller.isSuccess);
    }
  }

  @isTest static void testPartIncidentReport_TransferSupplier() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;

      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, true);
        ApexPages.currentPage().getParameters().put('id', pi.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Supplier');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + pi.Id, controller.redirectString);

      // check that owner is changed
      Part_Incident_Report__c[] pir = [SELECT Id, OwnerId, Current_Owner__c 
                                         FROM Part_Incident_Report__c 
                                        WHERE ID = :pi.Id];
      System.assertEquals(1, pir.size());
      System.assertEquals(portalUser.Id, pir[0].OwnerId);
      System.assertEquals('Supplier', pir[0].Current_Owner__c);
    }
  }

  @isTest static void testPartIncidentReport_TransferCustomer() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account portalAcc = createPortalAccount('Test', true);
      Account acc = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;

      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(portalAcc.Id, true);

      Test.startTest();
        Part_Incident_Report__c pi = createPartIncident(acc.Id, part.Id, true);
        ApexPages.currentPage().getParameters().put('id', pi.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Customer');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + pi.Id, controller.redirectString);

      // check that owner is changed
      Part_Incident_Report__c[] pir = [SELECT Id, OwnerId, Current_Owner__c 
                                         FROM Part_Incident_Report__c 
                                        WHERE ID = :pi.Id];
      System.assertEquals(1, pir.size());
      System.assertEquals(portalUser.Id, pir[0].OwnerId);
      System.assertEquals('Customer', pir[0].Current_Owner__c);
    }
  }
  
  @isTest static void testSortingReport_TransferSupplier() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;

      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);

      Test.startTest();
        Sorting_Report__c sr = createSortingReport(plantAccount.Id, part.Id, true);
        ApexPages.currentPage().getParameters().put('id', sr.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Supplier');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + sr.Id, controller.redirectString);

      // check that owner is changed
      Sorting_Report__c[] srList = [SELECT Id, OwnerId, Current_Owner__c 
                                      FROM Sorting_Report__c 
                                     WHERE ID = :sr.Id];
      System.assertEquals(1, srList.size());
      System.assertEquals(portalUser.Id, srList[0].OwnerId);
      System.assertEquals('Supplier', srList[0].Current_Owner__c);
    }
  }

  @isTest static void testSortingReport_TransferCustomer() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account portalAcc = createPortalAccount('Test', true);
      Account acc = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;

      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(portalAcc.Id, true);

      Test.startTest();
        Sorting_Report__c sr = createSortingReport(acc.Id, part.Id, true);
        ApexPages.currentPage().getParameters().put('id', sr.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Customer');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + sr.Id, controller.redirectString);

      // check that owner is changed
      Sorting_Report__c[] srList = [SELECT Id, OwnerId, Current_Owner__c 
                                      FROM Sorting_Report__c 
                                     WHERE ID = :sr.Id];
      System.assertEquals(1, srList.size());
      System.assertEquals(portalUser.Id, srList[0].OwnerId);
      System.assertEquals('Customer', srList[0].Current_Owner__c);
    }
  }

  @isTest static void testMonetaryClaim_TransferSupplier() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', acc.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, true);

      Test.startTest();
        Monetary_Claim__c mc = createIncidentMonetaryClaim(pi.Id, 'Incident Claim', true);
        ApexPages.currentPage().getParameters().put('id', mc.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Supplier');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + mc.Id, controller.redirectString);

      // check that owner is changed
      Monetary_Claim__c[] mcList = [SELECT Id, OwnerId, Current_Owner__c 
                                      FROM Monetary_Claim__c 
                                     WHERE ID = :mc.Id];
      System.assertEquals(1, mcList.size());
      System.assertEquals(portalUser.Id, mcList[0].OwnerId);
      System.assertEquals('Supplier', mcList[0].Current_Owner__c);
    }
  }

  @isTest static void testMonetaryClaim_TransferCustomer() {
    System.runAs(adminUser) {
      PageReference eqaTransfer = Page.EQATransfer;
      Test.setCurrentPage(eqaTransfer);

      Account acc = createPortalAccount('Test', true);
      Account plantAccount = createPlantAccount('Plan Account', true);
      Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, false);
      c.EQA_Records_Owner__c = true;
      insert c;
      User portalUser = createPortalUser('PortalUser@nissan.com', SUPPLIER_PROFILE, c.Id, true);
      Part__c part = createPart(acc.Id, true);
      Part_Incident_Report__c pi = createPartIncident(plantAccount.Id, part.Id, true);

      Test.startTest();
        Monetary_Claim__c mc = createIncidentMonetaryClaim(pi.Id, 'Incident Claim', false);
        mc.Customer__c = plantAccount.Id;
        insert mc;

        ApexPages.currentPage().getParameters().put('id', mc.Id);
        ApexPages.currentPage().getParameters().put('owner', 'Customer');

        EQATransferController controller = new EQATransferController();
        controller.changeOwner();
      Test.stopTest();

      System.assertEquals(true, controller.isSuccess);
      System.assertEquals('/' + mc.Id, controller.redirectString);

      // check that owner is changed
      Monetary_Claim__c[] mcList = [SELECT Id, OwnerId, Current_Owner__c 
                                      FROM Monetary_Claim__c 
                                     WHERE ID = :mc.Id];
      System.assertEquals(1, mcList.size());
      System.assertEquals(portalUser.Id, mcList[0].OwnerId);
      System.assertEquals('Customer', mcList[0].Current_Owner__c);
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