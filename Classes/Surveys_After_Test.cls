@isTest (seealldata = true)
public class Surveys_After_Test{
    static testMethod void Test1() {
      
      List<Case> insertcases = new List<Case>();
       
      String AcctTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'); 
      String CaseTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Lead Survey'); 
        
        Account a = New Account(
            Name = 'test acct',
            RecordTypeId = AcctTypeId,
            Dealer_Code__c = '1234',
            Make_Name__c = 'Nissan',
            Dealer_External_Id__c = '1234_USA');
        insert a;
        
        Case c = New Case();
            c.Subject = 'Dealer Quote follow up';
            c.Channel_Designation_Code__c = 'Nissan';
            c.Dealer__c = a.Id;
            c.Preferred_Dealer__c = a.Id;
            c.OwnerID = system.label.Batch_Record_Owner;
            c.Mailing_City__c = 'Test';
            c.Mailing_State__c = 'CO';
            c.Mailing_Street__c = '123 Test Street';
            c.Mailing_Zip_Code__c = '80221';
            c.Email2__c = 'test@test.com';
            c.Dealer_Number__c = '1234';
            c.Considered_Vehicle_Make__c = 'Nissan';
            c.Considered_Vehicle_Model__c = '350z';
            c.Vehicle_Year__c = '2010';
            c.Spanish_Speaking_customer__c = false;
            c.lead_date__c = string.valueOf(system.today());
            
        insertcases.add(c);
        
         Case c2 = New Case();
            c2.Subject = 'Dealer Quote follow up';
            c2.Channel_Designation_Code__c = 'Nissan';
            c2.Dealer__c = a.Id;
            c2.Preferred_Dealer__c = a.Id;
            c2.OwnerID = system.label.Batch_Record_Owner;
            c2.Mailing_City__c = 'Test';
            c2.Mailing_State__c = 'CO';
            c2.Mailing_Street__c = '123 Test Street';
            c2.Mailing_Zip_Code__c = '80221';
            c2.Email2__c = 'test@test.com';
            c2.Dealer_Number__c = '1234';
            c2.Considered_Vehicle_Make__c = 'Nissan';
            c2.Considered_Vehicle_Model__c = '350z';
            c2.Vehicle_Year__c = '2010';
            c2.Spanish_Speaking_customer__c = false;
            c2.lead_date__c = string.valueOf(system.today());
            
        insertcases.add(c2);
        
         Case c3 = New Case();
            c3.Subject = 'Dealer Quote follow up';
            c3.Channel_Designation_Code__c = 'Nissan';
            c3.Dealer__c = a.Id;
            c3.Preferred_Dealer__c = a.Id;
            c3.OwnerID = system.label.Batch_Record_Owner;
            c3.Mailing_City__c = 'Test';
            c3.Mailing_State__c = 'CO';
            c3.Mailing_Street__c = '123 Test Street';
            c3.Mailing_Zip_Code__c = '80221';
            c3.Email2__c = 'test@test.com';
            c3.Dealer_Number__c = '1234';
            c3.Considered_Vehicle_Make__c = 'Nissan';
            c3.Considered_Vehicle_Model__c = '350z';
            c3.Vehicle_Year__c = '2010';
            c3.Spanish_Speaking_customer__c = false;
            c3.lead_date__c = string.valueOf(system.today());
            
        insertcases.add(c3);
        
        insert insertcases;
        
		test.startTest();
		        
        String SurveyTypeId = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'SurveyGizmoSurvey');
        
        List<Surveys__c> newsurveys = new list<Surveys__c>();
        
        Surveys__c s = New Surveys__c();
            s.RecordtypeId = SurveyTypeId;
            s.SurveyGizmoCase__c = c.Id;
            s.DQR_Dealer_Contacted__c = 'no';
        //insert s;
        newsurveys.add(s);
        
        Surveys__c s2 = New Surveys__c();
            s2.RecordtypeId = SurveyTypeId;
            s2.DQR_Dealer_Rating__c = 3;
            s2.SurveyGizmoCase__c = c2.Id;
            s2.DQR_Dealer_Contacted__c = 'yes';
        
        //insert s2;
        newsurveys.add(s2);
        
        
        
        Surveys__c s3 = New Surveys__c();
            s3.RecordtypeId = SurveyTypeId;
            s3.DQR_Dealer_Rating__c = 8;
            s3.SurveyGizmoCase__c = c3.Id;
            s3.DQR_Dealer_Contacted__c = 'yes';
        
        newsurveys.add(s3);
        
        insert newsurveys;
        
        s3.CastIron_FF_Status__c = true;
        
        update s3;
        
        
        test.stopTest();
        
      
        
    }
}