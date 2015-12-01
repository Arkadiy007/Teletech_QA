@isTest
private class Batch_SurveyGizmo_Load_Test {
    //private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
    static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    
    static void testdata() {
        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Customer_ID__c = CUSTOMER_ID;
        insert account;

        lead.lastname = 'leadTest';
        lead.Customer_ID__c = CUSTOMER_ID;
        insert lead;

        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        insert dealer;
   }
    
    
    
    
    static testmethod void testSurveyGizmo_Load() {
        test.startTest();
        
        testData();
         Case thisSurveyCase = new Case();
         
          //thisSurveyCase.DQR_Number__c
          //thisSurveyCase.Maritz_Customer_Id__c;
          thisSurveyCase.Dealer__r = dealer;
          thisSurveyCase.Considered_Vehicle_Make__c = 'NISSAN';
          thisSurveyCase.Account= account;
          //thisSurveyCase.Contact.FirstName;
          //thisSurveyCase.Contact.LastName;
            thisSurveyCase.Surveyable__c = true;
            thisSurveyCase.RecordTypeId = '012F0000000yBMoIAM';
            thisSurveyCase.Date_Sent__c = Date.newInstance(2014,2,1);
        insert thisSurveyCase;
        
        
                 Case thisSurveyCase2 = new Case();
         
          //thisSurveyCase.DQR_Number__c
          //thisSurveyCase.Maritz_Customer_Id__c;
          thisSurveyCase2.Dealer__r = dealer;
          thisSurveyCase2.Considered_Vehicle_Make__c = 'INFINITI';
          thisSurveyCase2.Account= account;
          //thisSurveyCase.Contact.FirstName;
          //thisSurveyCase.Contact.LastName;
            thisSurveyCase2.Surveyable__c = true;
            thisSurveyCase2.RecordTypeId = '012F0000000yBMoIAM';
            thisSurveyCase2.Date_Sent__c = Date.newInstance(2014,2,1);
        insert thisSurveyCase2;
        
        try {
            Batch_SurveyGizmo_Load csd4 = new Batch_SurveyGizmo_Load();
            Database.executeBatch(csd4,10);      
        }
        catch(Exception e) {
          System.debug('error:' + e.getMessage());
          
        }
        test.stopTest();
    }
    
    static testmethod void testTestSurveyGizmo_Load() {
        test.startTest();
        
        testData();
         Case thisSurveyCase = new Case();
         
          //thisSurveyCase.DQR_Number__c
          //thisSurveyCase.Maritz_Customer_Id__c;
          thisSurveyCase.Dealer__r = dealer;
          thisSurveyCase.Considered_Vehicle_Make__c = 'NISSAN';
          thisSurveyCase.Account= account;
          //thisSurveyCase.Contact.FirstName;
          //thisSurveyCase.Contact.LastName;
            thisSurveyCase.Surveyable__c = true;
            thisSurveyCase.RecordTypeId = '012F0000000yBMoIAM';
            thisSurveyCase.Date_Sent__c = Date.newInstance(2014,2,1);
        insert thisSurveyCase;
          Case thisSurveyCase2 = new Case();
         

          thisSurveyCase2.Dealer__r = dealer;
          thisSurveyCase2.Considered_Vehicle_Make__c = 'INFINITI';
          thisSurveyCase2.Account= account;

            thisSurveyCase2.Surveyable__c = true;
            thisSurveyCase2.RecordTypeId = '012F0000000yBMoIAM';
            thisSurveyCase2.Date_Sent__c = Date.newInstance(2014,2,1);
        insert thisSurveyCase2;
        try {
            Testing_Batch_SurveyGizmo_Load csd4 = new Testing_Batch_SurveyGizmo_Load();
            Database.executeBatch(csd4,10);      
        }
        catch(Exception e) {
          System.debug('error:' + e.getMessage());
          
        }
        test.stopTest();
    }
    
}