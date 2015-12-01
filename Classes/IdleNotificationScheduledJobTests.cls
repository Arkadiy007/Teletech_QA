@isTest
public class IdleNotificationScheduledJobTests {

	private static Account globalSupplier { get; set; }
	private static Account globalCustomer { get; set; }
	private static List<Contact> customerUsers { get; set; }
	private static List<Contact> supplierUsers { get; set; }
	private static Part__c part { get; set; }

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

		customerUsers = new List<Contact> ();
		supplierUsers = new List<Contact> ();

		for (Integer i = 0; i < 2; i++) {
			Contact customer = sObjectFactory.createContact(globalCustomer.id);
			Contact supplier = sObjectFactory.createContact(globalSupplier.id);

			if (i == 0) {
				customer.Send_EQA_Notifications__c = true;
				customer.EQA_Records_Owner__c = true;


				supplier.Send_EQA_Notifications__c = true;
				supplier.EQA_Records_Owner__c = true;

			}

			customerUsers.add(customer);
			supplierUsers.add(supplier);
		}

		insert customerUsers;
		insert supplierUsers;

		createPortalUser('Vasiliy', 'EQA-Customer Partner User', customerUsers[0].id, true);
		createPortalUser('Petro', 'EQA-Supplier Partner User', supplierUsers[0].id, true);
	}



	@isTest
	static void testSchedulingIsWorking() {
		Test.startTest();
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		String jobId = System.schedule('Idle_Notifications EQA', CRON_EXP, new IdleNotificationScheduledJob());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}


	@isTest
	static void testOnPIRBatchJobSendNotificationsToSupplier() {
		insert create(Part_Incident_Report__c.sObjectType, true, false, 10);

		Test.startTest();
			IdlePIRNotificationBatchJob batchJob = new IdlePIRNotificationBatchJob();
		
			Database.executeBatch(batchJob, 10);

			System.assert(batchJob.timeLimit.hour() == System.now().addHours(-48).hour());
		Test.stopTest();
	}

	@isTest
	static void testOnPIRBatchJobSendNotificationsToCustomer() {
		insert create(Part_Incident_Report__c.sObjectType, false, true, 10);

		Test.startTest();
			IdlePIRNotificationBatchJob batchJob = new IdlePIRNotificationBatchJob();
		
			Database.executeBatch(batchJob, 10);

			System.assert(batchJob.timeLimit.hour() == System.now().addHours(-48).hour());
		Test.stopTest();
	}

	@isTest
	static void testOnSRBatchJobSendNotificationsToSupplier() {
		insert create(Sorting_Report__c.sObjectType, true, false, 10);

		Test.startTest();
			IdleSRNotificationBatchJob batchJob = new IdleSRNotificationBatchJob();
		
			Database.executeBatch(batchJob, 10);

			System.assert(batchJob.timeLimit.hour() == System.now().addHours(-48).hour());
		Test.stopTest();
	}

	@isTest
	static void testOnSRBatchJobSendNotificationsToCustomer() {
		insert create(Sorting_Report__c.sObjectType, false, true, 10);

		Test.startTest();
			IdleSRNotificationBatchJob batchJob = new IdleSRNotificationBatchJob();
		
			Database.executeBatch(batchJob, 10);

			System.assert(batchJob.timeLimit.hour() == System.now().addHours(-48).hour());
		Test.stopTest();
	}


	@isTest
	static void testOnMCBatchJobSendNotificationsToCustomer() {
		insert create(Monetary_Claim__c.sObjectType, true, false, 10);

		Test.startTest();
			IdleMCNotificationBatchJob batchJob = new IdleMCNotificationBatchJob();
		
			Database.executeBatch(batchJob, 10);

			System.assert(batchJob.timeLimit.hour() == System.now().addHours(-48).hour());
		Test.stopTest();
	}


	private static List<sObject> create(SObjectType type, Boolean sendNotificationToCustomer, Boolean sendNotificationToSupplier, Integer size) {
		List<sObject> objects = new List<sObject> ();

		if (type == Monetary_Claim__c.sObjectType) {
			for(Integer i = 0; i < size; i++){
				Monetary_Claim__c tempMCHolder = sObjectFactory.createMC(null, null);
				tempMCHolder.Monetary_Claim_Number__c = String.valueOf(i);
				tempMCHolder.Customer__c = globalCustomer.id;
				
				if(sendNotificationToCustomer){
					tempMCHolder.Last_Modified_By_Customer__c = System.now().addMonths(-1);
					tempMCHolder.Last_Modified_By_Supplier__c = System.now();
				}
				objects.add(tempMCHolder);
			}
		}

		else if (type == Sorting_Report__c.sObjectType) {
			for(Integer i = 0; i < size; i++){
				Sorting_Report__c tempMCHolder = sObjectFactory.createSR(part);
				tempMCHolder.Sorting_Report_Number__c = String.valueOf(i);
				tempMCHolder.Customer__c = globalCustomer.id;
				
				if(sendNotificationToCustomer){
					tempMCHolder.Last_Modified_By_Customer__c = System.now().addMonths(-1);
					tempMCHolder.Last_Modified_By_Supplier__c = System.now();
				}
				else if(sendNotificationToSupplier){
					tempMCHolder.Last_Modified_By_Supplier__c = System.now().addMonths(-1);
					tempMCHolder.Last_Modified_By_Customer__c = System.now();
				}
				objects.add(tempMCHolder);
			}
		}

		else if (type == Part_Incident_Report__c.sObjectType) {
			for(Integer i = 0; i < size; i++){
				Part_Incident_Report__c tempMCHolder = sObjectFactory.createPIR('Test ' + String.valueOf(i), part);
				tempMCHolder.Customer__c = globalCustomer.id;
				
				if(sendNotificationToCustomer){
					tempMCHolder.Last_Modified_By_Customer__c = System.now().addMonths(-1);
					tempMCHolder.Last_Modified_By_Supplier__c = System.now();
				}
				else if(sendNotificationToSupplier){
					tempMCHolder.Last_Modified_By_Supplier__c = System.now().addMonths(-1);
					tempMCHolder.Last_Modified_By_Customer__c = System.now();
				}
				objects.add(tempMCHolder);
			}
		}

		return objects;
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
		                           Username = userName + System.currentTimeMillis() + '@test.com',
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