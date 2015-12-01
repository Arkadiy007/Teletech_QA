/**********************************************************************
Name: SurveyBuilderController_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Test Class for SurveyBuilderController
======================================================
History:

VERSION AUTHOR DATE DETAIL
    1.0 - William Taylor      10/16/2015 Created
                         
***********************************************************************/
@isTest
private class SurveyBuilderController_Test {


    
     static testMethod void testSurveyBuilder() {
    SurveyBuilder__c sbq1 = new SurveyBuilder__c(question_number__c = 1,question__c = 'test 1',question_type__c='Checkbox',language__c='En',MapsTo__c='SurveyGizmoExpireDateTime__c',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq2 = new SurveyBuilder__c(question_number__c = 2,question__c = 'test 1',question_type__c='Radio,1,2,3',language__c='En',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq3 = new SurveyBuilder__c(question_number__c = 3,question__c = 'test 1',question_type__c='Choice,1,2',language__c='En',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq4 = new SurveyBuilder__c(question_number__c = 4,question__c = 'test 1',question_type__c='YesNo',language__c='En',MapsTo__c='DQR_Dealer_Rating__c',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq5 = new SurveyBuilder__c(question_number__c = 5,question__c = 'test 1',question_type__c='Text',language__c='En',MapsTo__c='Customer_ID__c',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq6 = new SurveyBuilder__c(question_number__c = 6,question__c = 'test 1',question_type__c='TextArea',language__c='En',MapsTo__c='Event_Date__c',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq7 = new SurveyBuilder__c(question_number__c = 7,question__c = 'test 1',question_type__c='Slider',language__c='En',mapsto__c='Survey_Record__c',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq8 = new SurveyBuilder__c(question_number__c = 8,question__c = 'test 1',question_type__c='Information',language__c='En',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq9 = new SurveyBuilder__c(question_number__c = 9,question__c = 'test 1',question_type__c='Finish',language__c='En',recordtypename__c='NCISurvey');
    SurveyBuilder__c sbq10 = new SurveyBuilder__c(question_number__c = 10,question__c = 'test 1',question_type__c='Finish',language__c='En',MapsTo__c='Hot_Alert_Created__c',recordtypename__c='NCISurvey');
    
    
    insert sbq1;insert sbq2;insert sbq3;insert sbq4;insert sbq5;insert sbq6;insert sbq7;insert sbq8;insert sbq9;insert sbq10;
    
    
    RecordType ncisurvey = [select id from recordtype where name = 'NCISurvey' and sobjecttype = 'Surveys__c'];
    Surveys__c s2 = new Surveys__c(); 
    Surveys__c s3 = new Surveys__c(); 
    
    s2.recordtypeid=ncisurvey.id;   // NCI survey, (no language, en used, nissan) 
    s2.Brand__c ='Nissan'; 
    insert s2;
    
    s3.recordtypeid=ncisurvey.id;   // NCI survey, (no language, en used, nissan) 
    s3.Brand__c ='Infiniti'; 
    insert s3;
    
        test.startTest();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(s2);
        ApexPages.currentPage().getParameters().put('sid',s2.id);
        SurveyBuilderController ec = new SurveyBuilderController();
        ec.save();
        
        
        ApexPages.currentPage().getParameters().put('sid',s3.id);
        SurveyBuilderController ec2 = new SurveyBuilderController();
        ec2.save();
         
         
        ApexPages.currentPage().getParameters().put('sid','asdfsa');
        SurveyBuilderController ec3 = new SurveyBuilderController();
        
         
         
         
         test.stopTest();
        
        
        //system.assert(scon.IncludeString == system.label.StandardContact);
    }



}