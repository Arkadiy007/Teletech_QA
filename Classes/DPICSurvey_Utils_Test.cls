@isTest(SeeAllData=true)
private class DPICSurvey_Utils_Test {
    //private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    

    static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    static testmethod void testCallsToSG1() {
        Case thisSurveyCase = new Case();
        RecordType dpicRT = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];
         thisSurveyCase.recordtypeid = dpicRT.id;
         thisSurveyCase.Origin = 'Email to Case';
 
         insert thisSurveyCase;
         test.startTest();
thisSurveyCase.Resolution_Notes__c = 'notes';
         thisSurveyCase.Status = 'Closed';
         
         update thisSurveyCase;
         test.stopTest();
         
    }
    static testmethod void testCallsToSG2() {
        test.startTest();
        RecordType dpicRT = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];


         Case thisSurveyCase = new Case();
         thisSurveyCase.recordtypeid = dpicRT.id;
         thisSurveyCase.Origin = 'Email to Case';

         insert thisSurveyCase;
         

        try {
        
         DPICSUrvey_Utils.createDPICContact(thisSurveyCase.id, '500xxxxxxxxxx', 'wrmtyr@gmail.com', 'Infiniti','test contact name', 'test agent name','');
         DPICSurvey_UTILS.cloneCampaignDPIC('1797220','2027178','test method campaign');
         
        }
        catch(Exception e) {
          System.debug('error:' + e.getMessage());
          
        }
        test.stopTest();
    }
    
    
    
      static testmethod void testCallsToSG3() {
        test.startTest();
        RecordType dpicRT = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];

        Contact con = new Contact();
        con.FirstName = 'Auto-generated';
        con.LastName = 'Contact';
        con.Email = 'no-reply@organization.com';
        insert con;
        
          
        
         Case thisSurveyCase = new Case();
         thisSurveyCase.recordtypeid = dpicRT.id;
         thisSurveyCase.Origin = 'Email to Case';
         thisSurveyCase.ContactId = con.id;
         
         insert thisSurveyCase;
        DateTime dt = DateTime.newInstance(1997,1,31,7,8,6);
        DPICSurvey__c dpic = new DPICSurvey__c();
        dpic.Email__c = 'testemail1@email.com';
        dpic.Brand__c = thisSurveyCase.channel__c;
        dpic.ContactName__c= thisSurveyCase.contact.name;
        dpic.AgentName__c= thisSurveyCase.owner.name;
        dpic.SFDC_Case_Id__c=thisSurveyCase.id;
        
         DPICSurvey__c dpic2 = new DPICSurvey__c();
        dpic2.Email__c = 'testemail2@email.com';
        dpic2.Brand__c = thisSurveyCase.channel__c;
        dpic2.ContactName__c= thisSurveyCase.contact.name;
        dpic2.AgentName__c= thisSurveyCase.owner.name;
        dpic2.SFDC_Case_Id__c=thisSurveyCase.id;
        dpic2.SurveyResponseDateTime__c = dt;
        
        
        insert dpic;
        insert dpic2;
        
        dpic.Indicated_issues_resolved__c = '1';
        dpic2.Indicated_issues_resolved__c = '0';
        update dpic;
        update dpic2;
        
        
        DPICSurvey__c dpica = [select id,SurveyResponseDateTime__c from DPICSurvey__c where Email__c = 'testemail1@email.com'];
        DPICSurvey__c dpicb = [select id, SurveyResponseDateTime__c from DPICSurvey__c where Email__c = 'testemail2@email.com'];
        System.debug('DPIC a is ' + dpica.SurveyResponseDateTime__c);
        System.debug('DPIC b is ' + dpicb.SurveyResponseDateTime__c);
        
        System.assert(dpica.SurveyResponseDateTime__c != null);
        System.assert(dpicb.SurveyResponseDateTime__c == dt);



        test.stopTest();
    }
    
    
}