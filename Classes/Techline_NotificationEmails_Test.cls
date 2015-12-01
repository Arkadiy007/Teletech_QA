/**********************************************************************
Name: Techline_NotificationEmails_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline_NotificationEmails.cls.
 
======================================================
History: 

VERSION AUTHOR     DATE       DETAIL
1.0 - Vivek Batham 08/03/2015 Created 
***********************************************************************/
@isTest(seeAllData = false)
private class Techline_NotificationEmails_Test {

    // -------- Test --------
    static testMethod void ClassTest()
    {
    
    
        Contact con = new Contact();
        con.FirstName = 'Auto-generated';
        con.LastName = 'Contact';
        con.Email = 'no-reply@organization.com';
        insert con;
            
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
    
        Case techlineCaseFFFS = new Case();
        techlineCaseFFFS.Issue_Type__c = 'Full';
        techlineCaseFFFS.Dealer__c = dealer.Id;
        techlineCaseFFFS.FFFS__c = true;
        techlineCaseFFFS.Safety_Concern__c = true;
        insert techlineCaseFFFS;
    
        techLineCase = [SELECT Id, DealerCode__c, FFFS__c, Brakes__c,
            Supervisor_Review__c, Steering__c, Unintended_Acceleration__c,
            Other_Concern__c, SRS__c, Critical_Status_Flag__c, 
            DTS_Notification__c, Calculated_Days_Down__c, Repair_Attempts__c,
            Make__c, Model_Line__c, Model_Year__c, Current_Mileage__c, 
            Safety_Concern__c
            FROM Case
            WHERE Id = :techLineCase.Id];
      
        techlineCaseFFFS = [SELECT Id, DealerCode__c, FFFS__c, Brakes__c,
            Supervisor_Review__c, Steering__c, Unintended_Acceleration__c,
            Other_Concern__c, SRS__c, Critical_Status_Flag__c, 
            DTS_Notification__c, Calculated_Days_Down__c, Repair_Attempts__c,
            Make__c, Model_Line__c, Model_Year__c, Current_Mileage__c,
            Safety_Concern__c
            FROM Case
            WHERE Id = :techlineCaseFFFS.Id];
      
        Techline_Alert__c alert = new Techline_Alert__c();
        alert.RecordTypeId = 
        Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
            ).get('Dealer/Heads Up Alert').getRecordTypeId();
        alert.Dealer_Code__c = '1234';
        alert.Dealer_Email_1__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_1__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_2__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_2__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_3__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_3__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_4__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_4__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_5__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_5__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_6__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_6__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_7__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_7__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_8__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_8__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_9__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_9__c = 'wrmtyr@gmail.com';
        alert.Dealer_Email_10__c = 'wrmtyr@gmail.com';
        alert.Heads_Up_Email_10__c = 'wrmtyr@gmail.com';
        insert alert;
    
        Techline_Alert__c alertDaysDown = new Techline_Alert__c();
        alertDaysDown.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Days Down/Repair Attempts').getRecordTypeId();
        alertDaysDown.Heads_Up_Email_1__c = 'wrmtyr@gmail.com';
        insert alertDaysDown;
    
        Techline_Alert__c alertVehicle = new Techline_Alert__c();
        alertVehicle.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Vehicle').getRecordTypeId();
        alertVehicle.Make__c = 'Nissan';
        alertVehicle.Model_Line__c = 'Versa';
        alertVehicle.Model_Year__c = 2014;
        alertVehicle.Mileage__c = 500;
        insert alertVehicle;
        
        Techline_Alert__c alertSafetyConcern = new Techline_Alert__c();
        alertSafetyConcern.RecordTypeId = 
            Schema.Sobjecttype.Techline_Alert__c.getRecordTypeInfosByName(
                ).get('Regular Notification').getRecordTypeId();
        alertSafetyConcern.Name = 'Safety Concern';
        alertSafetyConcern.To_Email__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.To_Email_2__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.To_Email_3__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_1__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_2__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_3__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_4__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_5__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_6__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_7__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_8__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_9__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_10__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_11__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_12__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_13__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_14__c = 'wrmtyr@gmail.com';
        alertSafetyConcern.CC_15__c = 'wrmtyr@gmail.com';
        insert alertSafetyConcern;
    
        Techline_NotificationEmails tne = new 
            Techline_NotificationEmails();
        tne.sendTechLineEmails(techLineCase, true,true,true);
        
        Techline_NotificationEmails tneFFFS = new 
            Techline_NotificationEmails();
        tneFFFS.sendTechLineEmails(techlineCaseFFFS, false,false,false);    
    }

}