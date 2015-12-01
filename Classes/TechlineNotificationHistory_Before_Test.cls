/**********************************************************************
Name: Case_Before_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of 
TechlineNotificationHistory_Before Trigger
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sebastian Rohdenburg     03/26/2014 Created
***********************************************************************/
@isTest
public class TechlineNotificationHistory_Before_Test {
	 static testMethod void TechlineNotificationHistory_Before_Test1() {
	 	Account dealer = new Account();
	    dealer.RecordTypeId = '012A0000000OfI0';
	    dealer.Name = 'TestDealer';
	    dealer.Dealer_Code__c = '1234';
	    insert dealer;
	    
	    Vehicle__c veh = new Vehicle__c();
	    veh.name = 'JN8AZ1FY5CW100145';
	    veh.Model_Year__c = '2014';
	    veh.Model_Line_Name__c = 'Versa';
	    veh.Make_Name__c = 'Nissan';
	    insert veh;
	    
	    Case techlineCase = new Case();
	    techlineCase.Issue_Type__c = 'Full';
	    techLineCase.Dealer__c = dealer.Id;
	    techLineCase.Critical_Status_Flag__c = true;
	    techLineCase.DTS_Notification__c = true;
	    techLineCase.Repair_Attempts__c = '2';
	    techLineCase.Vehicle_Name__c = veh.Id;
	    techLineCase.Current_Mileage__c = 10;
	    insert techLineCase;
    
	 	Techline_Notification_History__c tnh = 
	 		new Techline_Notification_History__c();
	 	
	 	tnh.Case__c = techLineCase.Id;
	 	insert tnh;
	 	
	 	tnh.Status__c = 'UPDATING';
	 	update tnh;  
	 }
}