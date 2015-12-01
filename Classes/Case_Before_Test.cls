/**********************************************************************
Name: Case_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:

Case_Before Trigger for v2.0
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr     03/07/2014 Created
1.01 - Anna Koseykina 12/19/2014 Add test for testing Date fields
1.2 - Aaron Bessey 	03/06/2015 Added new test class for Subject Update
***********************************************************************/
@isTest
public class Case_Before_Test{
    static testMethod void Case_Before_Test1() {
        
        Case c = new Case(
            Status = 'Open',
            Origin = 'Email',
            OwnerId = '00GF0000002JDZk'); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
        Case testc = [select Id, OwnerId from Case where Id = :c.Id];
        system.assert(testc.OwnerId == '005A0000001Y7Ek');
    }
    
    
    static testMethod void Case_Before_Test2() {
        
        Case c = new Case(
            Status = 'Open',
            Origin = 'Email to Case',
            OwnerId = '00GF0000002JDZk'); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    
    /*  static testMethod void Case_Before_Test3() {

Case c = new Case(
Status = 'Open',
RecordTypeId = '012c00000004ilY',
Origin = 'Email to Case',
OwnerId = '00GF0000002JDZk'); 

insert c;

c.Home_Phone__c = '3035555555';

update c;

}*/
    
    
    
    static testMethod void Case_Before_Test4() {
        
        String CArt = '012F0000000y9y7';
        
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = CArt,
            Origin = 'Phone'); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    static testMethod void Case_Before_Test5() {
        
        String Techlinert = '012F0000000yFmQ';
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = Techlinert,
            Origin = 'Email to Case',
            AssignmentLevel__c =  '1|',
            Critical_Status_Flag__c = true,
            Issue_Type__c = 'MINI'); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
        
        
        
    }
    static testMethod void Case_Before_Test53() {
        
        String Techlinert = '012F0000000yFmQ';
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = Techlinert,
            Origin = 'Email to Case',
            AssignmentLevel__c =  '1|',
            Critical_Status_Flag__c = true,
            Issue_Type__c = 'FULL'
        ); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
        
        
        
    }
    
    
    static testMethod void Case_Before_Test51() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Name = 'VIN01000010000101', Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
        String Techlinert = '012F0000000yFmQ';
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = Techlinert,
            Origin = 'Phone',
            AssignmentLevel__c =  ' |',
            Component_Code_Issue__c = '123',
            VIN__c = 'VIN01000010000101',
            OwnerId = '00GF0000002JDZk'); 
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    static testMethod void Case_Before_Test511() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Name = 'VIN01000010000101', Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        testVehicles.add(new Vehicle__c(Name = 'VIN01000010000102', Vehicle_identification_Number__c = 'VIN01000010000102', Model_Year__c = '2005'));
        
        insert testVehicles;
        String Techlinert = '012F0000000yFmQ';
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = Techlinert,
            Origin = 'Phone',
            AssignmentLevel__c =  ' |',
            Component_Code_Issue__c = '123',
            VIN__c = 'VIN01000010000101',
            OwnerId = '00GF0000002JDZk'); 
        
        insert c;
        
        c.VIN__c = 'VIN01000010000102';
        
        update c;
        
    }
    
    static testMethod void Case_Before_Test6() {
        
        Case c = new Case(
            Status = 'Open',
            Origin = 'Email to Case',
            RecordTypeId = '012F0000000yFNi',
            IC_Subscription_Status__c = true,
            IPA_Subscription_Status__c = true,
            TCU_Activation_Status__c = true);
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    static testMethod void Case_Before_Test7() {
        
        Case c = new Case(
            Status = 'Open',
            Origin = 'Email to Case',
            RecordTypeId = '012F0000000yFNi',
            IC_Subscription_Status__c = true,
            IPA_Subscription_Status__c = true,
            TCU_Activation_Status__c = true);
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    static Account dealer = new Account();
    static final String DEALER_ID = '12345';
    
    static testMethod void Case_Before_Test8() {
        
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Name = 'VIN01000010000101', Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
        String dealerType = System.Label.AccRTDealer;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        
        
        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        insert dealer;
        
        Case c = new Case(
            VIN__c = 'VIN01000010000100',
            Status = 'Open',
            Origin = 'Email to Case',
            RecordTypeId = '012F0000000yCgM',
            Dealer_Number__c = DEALER_ID
        );
        
        
        insert c;
        
        c.Home_Phone__c = '3035555555';
        
        update c;
        
    }
    
    
    static testMethod void testDateFields() {
        
        /*
create a case to test the functionality
*/
        Test.startTest();
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        Case testCase = new Case(Status = 'New', Origin = 'Phone', Description = 'Initial Description', RecordTypeId = caseCART.Id);
        testCase.Fire_Indicator__c = false;
        testCase.Rollover_Indicator__c = false;
        testCase.Injury_Indicator__c = false;
        testCase.Sent_to_Legal_Indicator__c = false;
        testCase.Property_Damage_Indicator__c = false;
        testCase.Goodwill_Offered__c = false;
        insert testCase;
        
        testCase.Fire_Indicator__c = true;
        testCase.Rollover_Indicator__c = true;
        testCase.Injury_Indicator__c = true;
        testCase.Sent_to_Legal_Indicator__c = true;
        testCase.Property_Damage_Indicator__c = true;
        testCase.Goodwill_Offered__c = true;
        testCase.Number_Injured__c = 1;
        testCase.Incident_Date__c = Date.today();
        update testCase;
        testCase = [SELECT Id, Fire_Date__c, Rollover_Date__c, Injury_Date__c, Sent_to_Legal_Date__c, Property_Damage_Date__c, Goodwill_Offered_Date__c FROM Case WHERE Id=:testCase.Id LIMIT 1];
        System.assertEquals(testCase.Fire_Date__c, Date.today());
        System.assertEquals(testCase.Rollover_Date__c, Date.today());
        System.assertEquals(testCase.Sent_to_Legal_Date__c, Date.today());
        System.assertEquals(testCase.Property_Damage_Date__c, Date.today());
        System.assertEquals(testCase.Goodwill_Offered_Date__c, Date.today());
        System.assertEquals(testCase.Injury_Date__c, Date.today());
        test.stopTest();
    }
    
    static testMethod void CaseSubjectTest() 
    {
        
        String ContactFirstName ='Will';
        String ContactLastName ='Taylor';
        String ContactPhone ='5556667777';
        String VIN = 'VIN01000010000101';
        
        
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        RecordType maritz = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
        RecordType techline = [Select id, name from recordtype where name='TECH LINE' and sobjecttype='Case' limit 1];
        Account cust = new Account();
        cust.RecordTypeId = maritz.Id;
        cust.FirstName=ContactFirstName;
        cust.LastName=ContactLastName; 
        cust.PersonHomePhone = ContactPhone;
        insert cust;  
        
        cust = [select Id, PersonContactId from Account where Id = :cust.Id limit 1];        
        
        testVehicles.add(new Vehicle__c(Name = VIN, Vehicle_identification_Number__c = VIN, Model_Year__c = '2005'));
        insert testVehicles;
        String Techlinert = techline.Id;
        Test.startTest();
        Case c = new Case(
            Status = 'Open',
            RecordTypeId = Techlinert,
            Origin = 'Phone',
            AssignmentLevel__c =  ' |2',
            Component_Code_Issue__c = '123',
            VIN__c = 'VIN01000010000101',
            OwnerId = '00GF0000002JDZk'); 
        c.ContactId = cust.PersonContactId;
        insert c;
        
        c = [Select Id, Subject from Case where Id=:c.id limit 1];
        String subject = 'CUSTOMER: ' + ContactFirstName + ' ' + ContactLastName + ' PHONE: ' + ContactPhone + ' VIN: ' + VIN;
        System.assertEquals(subject, c.Subject);
        
        c.Subject = 'test';
        c.Description = 'Quality Connection Hot Alert';
        update c;
        
        System.assertEquals('test', c.Subject);
        
        Test.stopTest();
        
    }
    
    
}