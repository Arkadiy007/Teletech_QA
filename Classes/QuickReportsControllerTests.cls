@isTest
public class QuickReportsControllerTests{

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

		createCommonSettings();
	}



	@isTest
	static void testSearchAllRecordsReturnValidNumberOfRecordsForMC() {
		insert create(Monetary_Claim__c.sObjectType, true, false, 10);
		createCustomSettings(Monetary_Claim__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'MC';
			qrController.getParamsForSelectedReport();

			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.refresh();
		Test.stopTest();
			System.assertEquals(10, qrController.searchResults[0].setCon.ReportObjectList.size());
	}

	@isTest
	static void testSearchAllRecordsReturnValidNumberOfRecordsForPIR() {
		insert create(Sorting_Report__c.sObjectType, true, false, 10);
		createCustomSettings(Sorting_Report__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'SR';
			qrController.getParamsForSelectedReport();

			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.refresh();
		Test.stopTest();
			System.assertEquals(10, qrController.searchResults[0].setCon.ReportObjectList.size());
	}

	@isTest
	static void testSearchAllRecordsReturnValidNumberOfRecordsForSR() {
		insert create(Part_Incident_Report__c.sObjectType, true, false, 10);
		createCustomSettings(Part_Incident_Report__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'PIR';
			qrController.getParamsForSelectedReport();

			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.refresh();
		Test.stopTest();
			System.assertEquals(10, qrController.searchResults[0].setCon.ReportObjectList.size());
	}


	@isTest
	static void testSearchSomeRecordsReturnValidNumberOfRecordsForMC() {
		insert create(Monetary_Claim__c.sObjectType, true, false, 10);
		createCustomSettings(Monetary_Claim__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'MC';
			qrController.getParamsForSelectedReport();

			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.seletedReportForExport = 'MC';
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.booleanReportFilters.put('Save_And_Send_Flag__c', false);
			qrController.stringReportFilters.put('Name', '4');
			qrController.refresh();

			qrController.redirectToExcel();

		Test.stopTest();
			System.assertEquals(1, qrController.allRecords.size());
	}

	@isTest
	static void testSearchSomeRecordsReturnValidNumberOfRecordsForPIR() {
		insert create(Part_Incident_Report__c.sObjectType, true, false, 10);
		createCustomSettings(Part_Incident_Report__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'PIR';
			qrController.getParamsForSelectedReport();

			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.seletedReportForExport = 'PIR';
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.booleanReportFilters.put('Save_And_Send_Flag__c', false);
			qrController.stringReportFilters.put('Name', 'Test 4');
			qrController.refresh();

			qrController.redirectToExcel();

		Test.stopTest();
			System.assertEquals(1, qrController.allRecords.size());
	}

	@isTest
	static void testSearchSomeRecordsReturnValidNumberOfRecordsForSR() {
		insert create(Sorting_Report__c.sObjectType, true, false, 10);
		createCustomSettings(Sorting_Report__c.sObjectType);
		Test.startTest();
			QuickReportsController qrController = new QuickReportsController();
			qrController.reportName = 'SR';
			qrController.getParamsForSelectedReport();
			qrController.seletedReportForExport = 'SR';
			qrController.startTimeFilter = Date.today().addMonths(-1);
			qrController.endTimeFilter = Date.today().addMonths(1);
			qrController.selectedDateFieldAPIName = 'LastModifiedDate';
			qrController.booleanReportFilters.put('Save_And_Send_Flag__c', false);
			qrController.stringReportFilters.put('Name', '4');
			qrController.refresh();

			qrController.redirectToExcel();

		Test.stopTest();
			System.assertEquals(1, qrController.allRecords.size());
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

	private static void createCustomSettings(SObjectType type){
		List<EQA_Quick_Reports_Fields__c> fieldsForReport = new List<EQA_Quick_Reports_Fields__c>();
		List<EQA_Quick_Reports_Filters__c> filtersForReport = new List<EQA_Quick_Reports_Filters__c>();

		if(type == Part_Incident_Report__c.sObjectType){
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0001', Field_API_Name__c='Id', Field_Label__c='Id', Report_Name__c='PIR', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0002', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='PIR', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0004', Field_API_Name__c='Closed_Date__c', Field_Label__c='Closed Date', Report_Name__c='PIR', isDisplayable__c=true, isReportable__c=true));
		
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0001', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='PIR', Type__c='String'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0002', Field_API_Name__c='LastModifiedDate', Field_Label__c='LastModifiedDate', Report_Name__c='PIR', Type__c='Datetime'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0003', Field_API_Name__c='Save_And_Send_Flag__c', Field_Label__c='Save_And_Send_Flag__c', Report_Name__c='PIR', Type__c='Boolean'));
		}
		else if(type == Sorting_Report__c.sObjectType){
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0001', Field_API_Name__c='Id', Field_Label__c='Id', Report_Name__c='SR', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0002', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='SR', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0004', Field_API_Name__c='Closed_Date__c', Field_Label__c='Closed Date', Report_Name__c='SR', isDisplayable__c=true, isReportable__c=true));

	
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0001', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='SR', Type__c='String'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0002', Field_API_Name__c='LastModifiedDate', Field_Label__c='LastModifiedDate', Report_Name__c='SR', Type__c='Datetime'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0003', Field_API_Name__c='Save_And_Send_Flag__c', Field_Label__c='Save_And_Send_Flag__c', Report_Name__c='SR', Type__c='Boolean'));
		}
		else if(type == Monetary_Claim__c.sObjectType){
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0001', Field_API_Name__c='Id', Field_Label__c='Id', Report_Name__c='MC', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0002', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='MC', isDisplayable__c=true, isReportable__c=true));
			fieldsForReport.add(new EQA_Quick_Reports_Fields__c(Name= '0004', Field_API_Name__c='Closed_Date__c', Field_Label__c='Closed Date', Report_Name__c='MC', isDisplayable__c=true, isReportable__c=true));


			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0001', Field_API_Name__c='Name', Field_Label__c='Name', Report_Name__c='MC', Type__c='String'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0002', Field_API_Name__c='LastModifiedDate', Field_Label__c='LastModifiedDate', Report_Name__c='MC', Type__c='Datetime'));
			filtersForReport.add(new EQA_Quick_Reports_Filters__c(Name= '0003', Field_API_Name__c='Save_And_Send_Flag__c', Field_Label__c='Save_And_Send_Flag__c', Report_Name__c='MC', Type__c='Boolean'));
		}
		
		insert fieldsForReport;
		insert filtersForReport;
	}

	private static void createCommonSettings(){
		List<EQA_Quick_Reports_API_Names__c> apiNames = new List<EQA_Quick_Reports_API_Names__c>();
		apiNames.add(new EQA_Quick_Reports_API_Names__c(Name='01', Report_Name__c='PIR', Object_API_Name__c='Part_Incident_Report__c'));
		apiNames.add(new EQA_Quick_Reports_API_Names__c(Name='10', Report_Name__c='SR', Object_API_Name__c='Sorting_Report__c'));
		apiNames.add(new EQA_Quick_Reports_API_Names__c(Name='11', Report_Name__c='MC', Object_API_Name__c='Monetary_Claim__c'));
		

		insert apiNames;
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