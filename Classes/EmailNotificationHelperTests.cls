@isTest
public class EmailNotificationHelperTests {
	
  static final String SUPPLIER_PROFILE = 'EQA-Supplier Partner User';
  static final String CUSTOMER_PROFILE = 'EQA-Customer Partner User';
  static final Integer BULK_SIZE = 200;

	private static Account globalSupplier {get; set;}
	private static Account globalCustomer {get; set;}
	private static List<Contact> customerUsers {get; set;}
	private static List<Contact> supplierUsers {get; set;}	
	private static Part__c part {get; set;}	

	static {
		globalSupplier = sObjectFactory.createSupplierAccount();
		insert globalSupplier;

		globalCustomer = sObjectFactory.createPlantAccount();
		globalCustomer.Available_Customer_Numbers__c = '75;120;';
		insert globalCustomer;

		part = sObjectFactory.createPart();
		part.Supplier__c = globalSupplier.id;
		part.Customer_Number__c = '75';
		insert part;

		customerUsers = new List<Contact>();
		supplierUsers = new List<Contact>();

		for (Integer i = 0; i < 15; i++){
			Contact customer = sObjectFactory.createContact(globalCustomer.id);
			Contact supplier = sObjectFactory.createContact(globalSupplier.id);

			if (i == 10){
				ManageEqaPortalUsersController eqaUserCreator = new ManageEqaPortalUsersController();
				eqaUserCreator.selectedProfile = ManageEqaPortalUsersController.eqaProfileOptions[0].getValue();
				eqaUserCreator.newUser = new User(isActive = true);

				customer.Send_EQA_Notifications__c = true;
				customer.EQA_Records_Owner__c = true;
				eqaUserCreator.newContact = customer;
				eqaUserCreator.createUser();
				
				eqaUserCreator.newUser = new User(isActive = true);
				supplier.Send_EQA_Notifications__c = true;
				supplier.EQA_Records_Owner__c = true;
				eqaUserCreator.newContact = supplier;
				eqaUserCreator.createUser();

			}

			customerUsers.add(customer);
			supplierUsers.add(supplier);
		}

		insert customerUsers;
		insert supplierUsers;

	}
  
	@isTest
	static void testPopulateLastModifiedTestOnCustomerForPIR(){
		Test.startTest();
			Part_Incident_Report__c pir = sObjectFactory.createPIR('TEST PIR', part);
			pir.Customer__c = globalCustomer.Id;
			pir.Plant__c = 'St. Petersburg';
			
			insert pir;


			Part_Incident_Report__c pirAfterSaveAndSend = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, pirAfterSaveAndSend.Last_Modified_By_Customer__c);

			pirAfterSaveAndSend.Supplier_Response__c = 'Accept';
			pirAfterSaveAndSend.Save_And_Send_Flag__c = true;
			pirAfterSaveAndSend.Name_of_Responder__c = 'George';

			update pirAfterSaveAndSend;

			Part_Incident_Report__c pirAfterSaveAndSend2 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
		

			pirAfterSaveAndSend2.Issue_Type__c = 'Manufacturing';
			pirAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			update pirAfterSaveAndSend2;

			Part_Incident_Report__c pirAfterSaveAndSend3 = [SELECT Id, Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, pirAfterSaveAndSend3.Last_Modified_By_Customer__c);
			System.assert(pirAfterSaveAndSend3.Last_Modified_By_Customer__c >= pirAfterSaveAndSend3.Last_Modified_By_Supplier__c);


		Test.stopTest();
	}

	@isTest
	static void testPopulateLastModifiedTestOnCustomerForSR(){
		Test.startTest();
			Sorting_Report__c sr = sObjectFactory.createSR(part);
			sr.Customer__c = globalCustomer.Id;
			sr.Sorting_Report_Number__c = 'TEST PIR';

			insert sr;


			Sorting_Report__c srAfterSaveAndSend = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			
			srAfterSaveAndSend.Supplier_Response__c = 'Accept';
			srAfterSaveAndSend.Name_of_Responder__c = 'George';			
			srAfterSaveAndSend.Save_And_Send_Flag__c = true;
			update srAfterSaveAndSend;

			Sorting_Report__c srAfterSaveAndSend2 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, srAfterSaveAndSend2.Last_Modified_By_Supplier__c);
			System.assert(srAfterSaveAndSend2.Last_Modified_By_Customer__c <= srAfterSaveAndSend2.Last_Modified_By_Supplier__c);


			srAfterSaveAndSend2.Status__c = 'Closed';
			srAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			update srAfterSaveAndSend2;

			Sorting_Report__c srAfterSaveAndSend3 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, srAfterSaveAndSend3.Last_Modified_By_Customer__c);
			System.assert(srAfterSaveAndSend3.Last_Modified_By_Customer__c >= srAfterSaveAndSend3.Last_Modified_By_Supplier__c);

		Test.stopTest();
	}

	@isTest
	static void testPopulateLastModifiedTestOnCustomerForMC(){
		Test.startTest();
			Part_Incident_Report__c parentPIR = sObjectFactory.createPIR('Test PPPPR', part);
			parentPIR.Supplier_Response__c = 'Accept';
			insert parentPIR;
			Monetary_Claim__c mc = sObjectFactory.createMC(null, parentPIR);
			mc.Customer__c = globalCustomer.Id;
			mc.Monetary_Claim_Number__c = 'TEST PIR';

			insert mc;

			Monetary_Claim__c mcAfterSaveAndSend = [SELECT Id, Name, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c, Last_Modified_By_Customer__c FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, mcAfterSaveAndSend.Last_Modified_By_Customer__c);


			mcAfterSaveAndSend.Supplier_Response__c = 'Accept';
			mcAfterSaveAndSend.Name_of_Responder__c = 'George';			

			update mcAfterSaveAndSend;

			Monetary_Claim__c mcAfterSaveAndSend2 = [SELECT Id, Name, Last_Modified_By_Customer__c, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c , Last_Modified_By_Supplier__c FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
		

			mcAfterSaveAndSend2.Plant__c = 'PST-888';
			mcAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			update mcAfterSaveAndSend2;

			Monetary_Claim__c mcAfterSaveAndSend3 = [SELECT Id, Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c  FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
			System.assertNotEquals(null, mcAfterSaveAndSend3.Last_Modified_By_Customer__c);
			System.assert(mcAfterSaveAndSend3.Last_Modified_By_Customer__c >= mcAfterSaveAndSend3.Last_Modified_By_Supplier__c);

		Test.stopTest();
	}

  // run tests as EQA Potal Customer User
	@isTest
	static void testPopulateLastModifiedTestOnCustomerForPIR_PortalCustomerProfile(){
    Account plantAccount = createPlantAccount('Plan Account', true);
    Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
    User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);

    Part__Share partShare = new Part__Share();
    partShare.ParentId = part.Id;
    partShare.AccessLevel = 'Read';
    partShare.UserOrGroupId = customerPortalUser.Id;
    insert partShare;

    System.runAs(customerPortalUser) {
		  Test.startTest();
		    Part_Incident_Report__c pir = sObjectFactory.createPIR('TEST PIR', part);
		    pir.Customer__c = plantAccount.Id;
		    pir.Plant__c = 'St. Petersburg';
		    insert pir;

			  Part_Incident_Report__c pirAfterSaveAndSend = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, pirAfterSaveAndSend.Last_Modified_By_Customer__c);

			  pirAfterSaveAndSend.Supplier_Response__c = 'Accept';
			  pirAfterSaveAndSend.Save_And_Send_Flag__c = true;
			  pirAfterSaveAndSend.Name_of_Responder__c = 'George';

			  update pirAfterSaveAndSend;

			  Part_Incident_Report__c pirAfterSaveAndSend2 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
		

			  pirAfterSaveAndSend2.Issue_Type__c = 'Manufacturing';
			  pirAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			  update pirAfterSaveAndSend2;

			  Part_Incident_Report__c pirAfterSaveAndSend3 = [SELECT Id, Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Part_Incident_Report__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, pirAfterSaveAndSend3.Last_Modified_By_Customer__c);
			  System.assert(pirAfterSaveAndSend3.Last_Modified_By_Customer__c >= pirAfterSaveAndSend3.Last_Modified_By_Supplier__c);


		  Test.stopTest();
    }
	}

	@isTest
	static void testPopulateLastModifiedTestOnCustomerForSR_PortalCustomerProfile(){
    Account plantAccount = createPlantAccount('Plan Account', true);
    Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
    User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);

    Part__Share partShare = new Part__Share();
    partShare.ParentId = part.Id;
    partShare.AccessLevel = 'Read';
    partShare.UserOrGroupId = customerPortalUser.Id;
    insert partShare;

    System.runAs(customerPortalUser) {
		  Test.startTest();
			  Sorting_Report__c sr = sObjectFactory.createSR(part);
			  sr.Customer__c = plantAccount.Id;
			  sr.Sorting_Report_Number__c = 'TEST PIR';
			  insert sr;


			  Sorting_Report__c srAfterSaveAndSend = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			
			  srAfterSaveAndSend.Supplier_Response__c = 'Accept';
			  srAfterSaveAndSend.Name_of_Responder__c = 'George';			
			  srAfterSaveAndSend.Save_And_Send_Flag__c = true;
			  update srAfterSaveAndSend;

			  Sorting_Report__c srAfterSaveAndSend2 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, srAfterSaveAndSend2.Last_Modified_By_Supplier__c);
			  System.assert(srAfterSaveAndSend2.Last_Modified_By_Customer__c <= srAfterSaveAndSend2.Last_Modified_By_Supplier__c);


			  srAfterSaveAndSend2.Status__c = 'Closed';
			  srAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			  update srAfterSaveAndSend2;

			  Sorting_Report__c srAfterSaveAndSend3 = [SELECT Id, Name, Customer__c, Part__c, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c FROM Sorting_Report__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, srAfterSaveAndSend3.Last_Modified_By_Customer__c);
			  System.assert(srAfterSaveAndSend3.Last_Modified_By_Customer__c >= srAfterSaveAndSend3.Last_Modified_By_Supplier__c);

		  Test.stopTest();
    }
	}

	@isTest
	static void testPopulateLastModifiedTestOnCustomerForMC_PortalCustomerProfile(){
    Account plantAccount = createPlantAccount('Plan Account', true);
    Contact c = createPortalContact('FirstName', 'LastName', plantAccount.Id, true);
    User customerPortalUser = createPortalUser('PortalUser@nissan.com', CUSTOMER_PROFILE, c.Id, true);

    Part__Share partShare = new Part__Share();
    partShare.ParentId = part.Id;
    partShare.AccessLevel = 'Read';
    partShare.UserOrGroupId = customerPortalUser.Id;
    insert partShare;


    System.runAs(customerPortalUser) {
		  Test.startTest();
			  Part_Incident_Report__c parentPIR = sObjectFactory.createPIR('Test PPPPR', part);
			  parentPIR.Supplier_Response__c = 'Accept';
			  insert parentPIR;
			  Monetary_Claim__c mc = sObjectFactory.createMC(null, parentPIR);
			  mc.Customer__c = plantAccount.Id;
			  mc.Monetary_Claim_Number__c = 'TEST PIR';
			  insert mc;

			  Monetary_Claim__c mcAfterSaveAndSend = [SELECT Id, Name, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c, Last_Modified_By_Customer__c FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, mcAfterSaveAndSend.Last_Modified_By_Customer__c);


			  mcAfterSaveAndSend.Supplier_Response__c = 'Accept';
			  mcAfterSaveAndSend.Name_of_Responder__c = 'George';			

			  update mcAfterSaveAndSend;

			  Monetary_Claim__c mcAfterSaveAndSend2 = [SELECT Id, Name, Last_Modified_By_Customer__c, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c , Last_Modified_By_Supplier__c FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
		

			  mcAfterSaveAndSend2.Plant__c = 'PST-888';
			  mcAfterSaveAndSend2.Save_And_Send_Flag__c = true;
			  update mcAfterSaveAndSend2;

			  Monetary_Claim__c mcAfterSaveAndSend3 = [SELECT Id, Name, Last_Modified_By_Customer__c, Last_Modified_By_Supplier__c, RecordTypeId, Customer__c, Sorting_Report__c, Part_Incident_Report__c  FROM Monetary_Claim__c WHERE Name = 'TEST PIR'][0];
			  System.assertNotEquals(null, mcAfterSaveAndSend3.Last_Modified_By_Customer__c);
			  System.assert(mcAfterSaveAndSend3.Last_Modified_By_Customer__c >= mcAfterSaveAndSend3.Last_Modified_By_Supplier__c);

        EmailNotificationHelper.getEQAContacts();
		  Test.stopTest();
    }
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
}