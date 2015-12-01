@isTest
public class XtimeButtonOnCaseController_Tests {
	private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
	static testmethod void testXtimeController(){		
		String Techlinert = '012F0000000yFmQ';
        String CArt = '012F0000000y9y7';
        RecordType vehicleNissanRT = [select id, name from recordtype where name = 'Nissan' and sobjecttype = 'Vehicle__c' limit 1];
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        RecordType maritz = [select id, name from recordtype where name = 'Dealer' and sobjecttype = 'Account' limit 1];
        Vehicle__c v = new Vehicle__c(RecordTypeId = vehicleNissanRT.Id, 
                                            Name = 'VIN1NJ2T345678901', 
                                            Latest_Recorded_Mileage_Units__c = 'M', 
                                            Latest_Recorded_Mileage_Number__c = 10000,
                                            Make_Name__c = 'Infiniti');
        insert v;

        Account acc = new Account();
        acc.FirstName='Test';
        acc.LastName='Account';        
        insert acc;   
		acc = [select id from account where lastname = 'Account' limit 1];

        Account c = new Account();
        c.RecordTypeId = maritz.Id;
        c.Name='Test Dealer';       
		c.Dealer_Attributes_Text__c = 'EIX';
		c.Dealer_Code__c = '3638';
		c.TMS_Customer_ID__c = '11';
        insert c;        
		 
        List<Case> testCases = new List<Case>();
        Case usCase = new Case(AccountId = acc.id, RecordTypeId = caseCART.Id, Status = 'New', Servicing_Dealer__c = c.ID, Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department', Vehicle_Name__c = v.id);
        testCases.add(USCase);

        insert testCases;

        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = 'http://';
		Xtimesettings__c settings = new Xtimesettings__c(ci__c = '2406', 
															d_url_parameter__c = 'Confirmed_Appointment_Date__c', 
															ln_url_parameter__c = 'Account.lastname', 
															fn_url_parameter__c = 'Account.firstname', 
															pn_url_parameter__c = 'Account.PersonHomePhone',
															cc_url_parameter__c = 'Servicing_Dealer__r.Dealer_Code__c',
															vin_url_parameter__c = 'Vehicle_Name__r.Vehicle_identification_Number__c',
															mi_url_parameter__c = 'Vehicle_Name__r.Latest_Recorded_Mileage_Number__c');
		insert settings;
        test.startTest();
		PageReference pageref = new PageReference('https://c.cs16.visual.force.com/apex/apex/XtimeButtonOnCase?servDealer=' + c.id +'&account='+ acc.id +'&vehicle='+v.id);
        Test.setCurrentPage(pageRef);
		XtimeButtonOnCase_Controller controller = new XtimeButtonOnCase_Controller();
        
		System.debug('****controller.xtimeLink ' + controller.xtimeLink);
		PageReference pageref2 = new PageReference(controller.xtimeLink);
		PageReference pageref3 = controller.ifSuccess();
		System.debug(pageref2);
		System.debug(pageref3);
		System.assertEquals(pageref2.getUrl(), pageref3.getUrl());
		test.stopTest();
	}
}