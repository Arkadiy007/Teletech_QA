/**
* This class contains unit tests for SurveyAndQuestionController
* Author: Aaron Bessey
* Date 10/09/2014
*/
@isTest
private class Test_SurveyAndQuestionController {
    private static testmethod void main() {
        RecordType caseDIPCRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
        
        Test.startTest();
        
        List<Case> cases = new List<Case>{};
        Case caseRec = new Case();
        caseRec.Status = 'New';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = caseDIPCRT.ID;
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        cases.add(caseRec);
        insert cases;
        
        Survey__c survey = new Survey__c();
        survey.Name = 'test survey';
        survey.Submit_Response__c='empty';
        survey.Survey_Header__c = '';
        survey.thankYouLink__c='http://google.com';
        survey.thankYouText__c='Thx';
        survey.URL__c='http://google.com';
        insert survey;
        
        String caseId = cases[0].id;
        
        PageReference pageRef = Page.SurveyPage;
        pageRef.getParameters().put('id', String.valueOf(survey.Id));
        pageRef.getParameters().put('caId', String.valueOf(caseRec.Id));
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(survey);
        SurveyAndQuestionController SAQC = new SurveyAndQuestionController(sc);  
        
        SAQC.updateUrl();
        
        SAQC.surveyName = null;
        PageReference testRef = SAQC.updateSurveyName();
        SAQC.surveyName = 'test2';
        testRef = SAQC.updateSurveyName();
        
        SAQC.surveyThankYouText = 'blah';
    SAQC.surveyThankYouURL='test.com';
        testRef = SAQC.updateSurveyThankYouAndLink();
        
        testRef = SAQC.refreshQuestionList();
        testRef = SAQC.resultPage();
        testRef = SAQC.thankYouPage();
        testRef = SAQC.deleteRefresh();
        
        List<String> testStrs = SAQC.getResponses();
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        Survey_Question__c sq = new Survey_Question__c();
        sq.Name='sq 1';
        sq.Survey__c = survey.Id;
        sq.OrderNumber__c=1;
        sq.Question__c = 'test question 1';
        surveyQuestions.add(sq);
        
        sq = new Survey_Question__c();
        sq.Name='sq 2';
        sq.Type__c='Single Select--Vertical';
        sq.Choices__c = 'Choice 1\nChoice2';
        sq.Survey__c = survey.Id;
        sq.OrderNumber__c=2;
        sq.Question__c = 'test question 2';
        surveyQuestions.add(sq);
                
        sq = new Survey_Question__c();
        sq.Name='sq 3';
        sq.Type__c='Multi-Select--Vertical';
        sq.Choices__c = 'Choice 1\nChoice2';
        sq.Survey__c = survey.Id;
        sq.OrderNumber__c=3;
        sq.Question__c = 'test question 3';
        surveyQuestions.add(sq);
        
        sq = new Survey_Question__c();
        sq.Name='sq 4';
        sq.Type__c='Single Select--Horizontal';
        sq.Choices__c = 'Choice 1\nChoice2';
        sq.Survey__c = survey.Id;
        sq.OrderNumber__c=4;
        sq.Question__c = 'test question 4';
        surveyQuestions.add(sq);
        
        sq = new Survey_Question__c();
        sq.Name='sq 5';
        sq.Type__c='Free Text';
        sq.Choices__c = 'Choice 1\nChoice2';
        sq.Survey__c = survey.Id;
        sq.OrderNumber__c=5;
        sq.Question__c = 'test question 5';
        surveyQuestions.add(sq);
        
        insert surveyQuestions;
        sq = surveyQuestions[0];
        SurveyAndQuestionController.question oQuestion = new SurveyAndQuestionController.question(surveyQuestions[0]);
        oQuestion = new SurveyAndQuestionController.question(surveyQuestions[1]);
        oQuestion = new SurveyAndQuestionController.question(surveyQuestions[2]);
        oQuestion = new SurveyAndQuestionController.question(surveyQuestions[3]);
        oQuestion = new SurveyAndQuestionController.question(surveyQuestions[4]);
        List<String> qIds = new List<String>();
        qIds.add(String.valueOf(surveyQuestions[4].Id));
        qIds.add(String.valueOf(surveyQuestions[1].Id));
        qIds.add(String.valueOf(surveyQuestions[2].Id));
        qIds.add(String.valueOf(surveyQuestions[3].Id));
        qIds.add(String.valueOf(surveyQuestions[0].Id));
        String testStr = SurveyAndQuestionController.updateQuestionOrder(qIds);
        
        testRef = SAQC.editQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[0].id);
        testRef = SAQC.editQuestion();
        testRef = SAQC.previewQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[1].id);
        testRef = SAQC.editQuestion();
        testRef = SAQC.previewQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[2].id);
        testRef = SAQC.editQuestion();
        testRef = SAQC.previewQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[3].id);
        testRef = SAQC.editQuestion();
        testRef = SAQC.previewQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[4].id);
        testRef = SAQC.editQuestion();
        testRef = SAQC.previewQuestion();
        testRef = SAQC.saveAndNewQuestion();
        
        testRef = SAQC.makeNewQuestionLink();
        testRef = SAQC.addQuestion();
        testRef = SAQC.setupQuestionFields();
        SAQC.questionReference = null;
        testRef = SAQC.saveAndNewQuestion();
        
        testRef = SAQC.controllerSavQuestion();
        SAQC.questionReference = String.valueOf(surveyQuestions[0].id);
        testRef = SAQC.controllerSavQuestion();
        
        testRef = SAQC.previewQuestion();
        
        
        String sOut = SurveyAndQuestionController.deleteQuestion(qIds[0]);
        
        pageRef = Page.SurveyPage;
        pageRef.getParameters().put('id', String.valueOf(survey.Id));
        pageRef.getParameters().put('caId', '123');
        
        Test.setCurrentPage(pageRef);
        
        sc = new ApexPages.StandardController(survey);
        SAQC = new SurveyAndQuestionController(sc);  
        Test.stopTest();
    }
    
}