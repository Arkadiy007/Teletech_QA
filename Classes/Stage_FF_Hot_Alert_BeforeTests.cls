/**********************************************************************
  Name: Stage_FF_Hot_Alert_BeforeTests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for Stage_FF_Hot_Alert_Before trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 01/12/2015 Created
  ***********************************************************************/
@isTest
public class Stage_FF_Hot_Alert_BeforeTests {
    private static Group t5Group;
    private static Group cccGroup;
    private static Group dtuGroup;
	private static Group mccLeadHotAlertGroup;

    final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];

    static testMethod void testTriggerCreatesCase_ShouldnotCreateCase_WhenTHereIsNoCustomerAccount() {
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Quality Connection', 'QFS75D');

        test.starttest();

        insert alert;

        test.stoptest();

        List<Case> c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where Contact_ID__c = :alert.ContactId__c];
        system.assertEquals(0, c.size());
    }

    static testMethod void testTriggerCreatesCase_ForQualityConnectionSurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        User user = CreateUser();
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Quality Connection', 'QFS75D');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
        system.assertEquals(user.Id, c.OwnerId);
    }

    static testMethod void testTriggerCreatesCase_ForInfinitySurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Sales', 'Infiniti Sales');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
    }

    static testMethod void testTriggerCreatesCase_ForNissanSurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Service','OFS Service');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
    }

    static testMethod void testTriggerCreatesCase_ForDefectionSurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Former Owner Follow-up', 'Former Owner Follow-up');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
    }

    static testMethod void testTriggerCreatesCase_ForDTUSurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Quality Connection – Main', 'Quality Connection – Main');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
    }

    static testMethod void testTriggerCreatesCase_ForCAT5Survey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Service', 'Nissan Service');

        test.starttest();

        insert alert;

        test.stoptest();

        Case c = [Select Id, VIN__c, OwnerId, Servicing_Dealer__c, Dealer__c, Vehicle_Name__c, AccountId FROM Case Where AccountId = :customer.Id];
        system.assertEquals(dealer.Id, c.Servicing_Dealer__c);
        system.assertEquals(dealer.Id, c.Dealer__c);
        system.assertEquals(vehicle.Id ,c.Vehicle_Name__c); 
    }

	static testMethod void testTriggerCreatesCase_ForEpsilonSurvey() {
        CreateGroups();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            CreateQueues();
        }   
        Vehicle__c vehicle = CreateVehicle();
        Account customer = CreateCustomerAccount();
        Account dealer = CreateDealerAccount();
		Case c = new Case(DQR_number__c = 'testEpsilon', Reason = 'Offer Owned Incentive');
		insert c;
        Stage_FF_Hot_Alerts__c alert = TestData_Utils.CreateAlertInstance('Pre-Sales', 'Lead VHA');
		alert.HotAlertType__c = 'Lead';
		alert.Text_Field_1__c = 'testEpsilon';
        test.starttest();

        insert alert;

        test.stoptest();
		
        c = [Select Id, Description, Priority, Status FROM Case ];
	
        system.assertEquals('Follow up on Lead Survey Hot Alert', c.Description);
        system.assertEquals('Low', c.Priority);
        system.assertEquals('Item Created' ,c.Status); 
    }

    private static void CreateQueues(){

        QueueSobject t5GroupQueue = new QueueSobject(QueueId = t5Group.Id, SobjectType = 'Case');
        insert t5GroupQueue;


        QueueSobject cccQueue = new QueueSobject(QueueId = cccGroup.Id, SobjectType = 'Case');
        insert cccQueue;

        QueueSobject dtuQueue = new QueueSobject(QueueId = dtuGroup.Id, SobjectType = 'Case');
        insert dtuQueue;

		QueueSobject mccQueue = new QueueSobject(QueueId = mccLeadHotAlertGroup.Id, SobjectType = 'Case');
        insert mccQueue;
    }

    private static void CreateGroups(){
        t5Group = new Group(Name='T5 Case Queue', Type='Queue');
        insert t5Group;


        cccGroup = new Group(Name='CCC Campaign Queue', Type='Queue');
        insert cccGroup;

        dtuGroup = new Group(Name='DTU Queue', Type='Queue');
        insert dtuGroup;

		mccLeadHotAlertGroup =new Group (Name='MCC Lead Hot Alert', Type = 'Queue');
		insert mccLeadHotAlertGroup;
    }

    private static User CreateUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'TCS-MW', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = p.Id, 
              TimeZoneSidKey='America/Los_Angeles', UserName='tst@testorg.com');
        insert user;

        return user;
    }

    
    private static Vehicle__c CreateVehicle() {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_identification_Number__c = '3N1CE2CP1EL407518';
        vehicle.Make_Name__c = 'Nissan';
        insert vehicle;

        return vehicle;
    }

    private static Account CreateCustomerAccount() {
        RecordType myRecordType = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1];
        
        Account account = new Account();
        account.lastName = 'Account';
        account.FirstName = 'firstname';
        account.Customer_ID__c = '143770668';
        account.Recordtypeid = myRecordType.Id;
        insert account;

        return account;
    }

    private static Account CreateDealerAccount() {
        Account preferredAccount = new Account();
        preferredAccount.name = 'Account';
        preferredAccount.RecordTypeId = dealerType.id;
        preferredAccount.Dealer_Code__c = 'Test';
        preferredAccount.Dealer_External_Id__c = 'Test_USA';
        preferredAccount.Dealer_Code__c = '9080';
        insert preferredAccount; 

        return preferredAccount;
    }
}