/**********************************************************************
Name: Opportunity_Agreement_Controller_Test 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Opportunity_Agreement_Controller.
 
======================================================
History:

VERSION    AUTHOR         DATE         DETAIL
1.0 -     Vivek Batham    10/02/2015  Created 
***********************************************************************/
@isTest
private class Opportunity_Agreement_Controller_Test  {
    
    static Account accObj;
    static Opportunity oppObj;
    static List<APXTConga4__Conga_Template__c> congaTemplates;
    static Contact conObj;
    
    static testMethod void loadAgreementTest()
    {
        createTestData();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(oppObj);
        Opportunity_Agreement_Controller opptAgreement = new Opportunity_Agreement_Controller(controller);
        opptAgreement.congaTemplateSO = opptAgreement.salutationSO;
        opptAgreement.salutation = 'Dr.';
        opptAgreement.congaTemplate = congaTemplates[0].Id;        
        opptAgreement.back();
          
    }
    
    
    static void createTestData(){
        
        String busAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();        
        accObj= new Account(Name = 'Test Account', Phone = '9887920399', RecordtypeId = busAcctRTId, Company_Abbr__c = 'TA', Quantity__c='Hundred(100)');
        insert accObj;
        
        conObj = new Contact(LastName = 'LName', Primary_Flag__c = true, AccountId = accObj.Id);
        insert conObj; 
                
        oppObj = new Opportunity(Name = 'Test Opportunity', AccountId=accObj.Id, StageName = 'Negotiation/Review', CloseDate= Date.today().adddays(8));
        insert oppObj; 
        congaTemplates = new List<APXTConga4__Conga_Template__c>();
        congaTemplates.add(new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'NCV Temp1', APXTConga4__Template_Group__c = Label.NCV_Agreement_Templates,
                                    APXTConga4__Template_Type__c = 'Document', APXTConga4__Description__c = 'Template 1 Description'));
                                    
        congaTemplates.add(new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'NCV Temp2', APXTConga4__Template_Group__c = Label.NCV_Agreement_Templates,
                                    APXTConga4__Template_Type__c = 'Document', APXTConga4__Description__c = 'Template 2 Description'));                          
         
        insert congaTemplates;    
    }    
    
    
}