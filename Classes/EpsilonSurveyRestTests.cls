@isTest
private class EpsilonSurveyRestTests {

    static{
        insertCustomSettings();
    }
    
    @isTest static void validResponseWillInsertOneSurvey() {
        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        Test.startTest();
            EpsilonSurveyRest.ResponseWrapper response = EpsilonSurveyRest.createSurveys(formJSONMessage(TRUE));
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Surveys__c]);
        System.assertEquals('lead id', [SELECT Lead_Id__c FROM Surveys__c LIMIT 1][0].Lead_Id__c);
        System.assertEquals(200, response.code);
        System.assertEquals('success', response.status);
    }

    @isTest static void validJSONMsgWillInsertOneSurvey() {
        EpsilonSurveyRest.RequestWrapper request = formJSONMessage(TRUE);
        String jsonMsg = JSON.serialize(request);

         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         
        req.requestURI = '/services/apexrest/epsilon/api/v1/survey';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        Test.startTest();
            EpsilonSurveyRest.ResponseWrapper response = EpsilonSurveyRest.createSurveys(request);
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Surveys__c]);
        System.assertEquals('lead id', [SELECT Lead_Id__c FROM Surveys__c LIMIT 1][0].Lead_Id__c);
        System.assertEquals(200, response.code);
        System.assertEquals('success', response.status);
    }
    
    
    @isTest static void invalidJSONMsgWillInsertNothing() {
        EpsilonSurveyRest.RequestWrapper request = formJSONMessage(false);
        String jsonMsg = JSON.serialize(request);

         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         
        req.requestURI = '/services/apexrest/epsilon/api/v1/survey';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        Test.startTest();
            EpsilonSurveyRest.ResponseWrapper response = EpsilonSurveyRest.createSurveys(request);
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        System.assertEquals(400, response.code);
        System.assertEquals('error', response.status);
    }

    @isTest static void validResponseWillInsertMultipleSurvey() {
        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        Test.startTest();
            List<EpsilonSurveyRest.ResponseWrapper> responses = EpsilonSurveysRest.createSurveys(formJSONArrayMessage(TRUE));
        Test.stopTest();

        System.assertEquals(20, [SELECT Count() FROM Surveys__c]);
        System.assertEquals('lead id0', [SELECT Lead_Id__c FROM Surveys__c LIMIT 1][0].Lead_Id__c);
        
        for(EpsilonSurveyRest.ResponseWrapper response : responses){
            System.assertEquals(200, response.code);
            System.assertEquals('success', response.status);
        }
    }

    @isTest static void validJSONMsgWillInsertMultipleSurvey() {
        List<EpsilonSurveyRest.RequestWrapper> request = formJSONArrayMessage(TRUE);
        String jsonMsg = JSON.serialize(request);

         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         
        req.requestURI = '/services/apexrest/epsilon/api/v1/surveys';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        System.assertEquals(0, [SELECT Count() FROM Case]);
        Test.startTest();
            List<EpsilonSurveyRest.ResponseWrapper> responses = EpsilonSurveysRest.createSurveys(request);
        Test.stopTest();

        System.assertEquals(20, [SELECT Count() FROM Surveys__c]);
        System.assertEquals('lead id0', [SELECT Lead_Id__c FROM Surveys__c LIMIT 1][0].Lead_Id__c);
        
        for(EpsilonSurveyRest.ResponseWrapper response : responses){
            System.assertEquals(200, response.code);
            System.assertEquals('success', response.status);
        }
    }
    
    
    @isTest static void invalidJSONMsgArrayWillInsertOnlyValidSurveys() {
        List<EpsilonSurveyRest.RequestWrapper> request = formJSONArrayMessage(FALSE);
        String jsonMsg = JSON.serialize(request);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         
        req.requestURI = '/services/apexrest/epsilon/api/v1/surveys';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.assertEquals(0, [SELECT Count() FROM Case]);
        System.assertEquals(0, [SELECT Count() FROM Surveys__c]);
        Test.startTest();
            List<EpsilonSurveyRest.ResponseWrapper> responses = EpsilonSurveysRest.createSurveys(request);
        Test.stopTest();
        System.assertEquals(20, [SELECT Count() FROM Surveys__c]);
        
        Boolean isErrorCodeFound = false;
        Boolean isErrorStatus = false;

        for(EpsilonSurveyRest.ResponseWrapper response : responses){
            if(response.status == 'error' && response.code == 400){
                isErrorCodeFound = true;
                isErrorStatus = true;
            }
        }

        System.assert(isErrorCodeFound);
        System.assert(isErrorStatus);
    }

    private static EpsilonSurveyRest.RequestWrapper formJSONMessage(Boolean isValid){
        EpsilonSurveyRest.RequestWrapper request = new EpsilonSurveyRest.RequestWrapper();
		request.token = Label.Epsilon_Integration_Security_Key;
        
		if(isValid){
            request.leadId = 'lead id';
            request.surveyKey = 'sk';
            request.surveyStatus = 'complete';
            request.dqrDealerRating = 2;
            request.dqrDealerContacted = '0';
            request.dqrDealerComments = 'commmmmmmmnets';
            request.surveyVersion = 'ver';
            request.surveyLang = 'lang';
            request.surveySendDatetime = 'vchira';
            request.surveyResponseDatetime = 'sigodnya))))))';
            request.brand = 'ss id';
        }

        return request;
    }
    
    private static List<EpsilonSurveyRest.RequestWrapper> formJSONArrayMessage(Boolean isValid){
        List<EpsilonSurveyRest.RequestWrapper> requests = new List<EpsilonSurveyRest.RequestWrapper>();
        for(Integer i = 0; i < 20; i++){
            EpsilonSurveyRest.RequestWrapper request = formJSONMessage(true);
            request.leadId += String.valueOf(i);
            requests.add(request);
        }

        if(!isValid){
            requests.add(formJSONMessage(false));
        }


        return requests;
    }

    private static void insertCustomSettings(){
        List<Epsilon_Surveys_Business_Rules__c> surveysSettings = new List<Epsilon_Surveys_Business_Rules__c>();

        surveysSettings.add(new Epsilon_Surveys_Business_Rules__c(Name = '0000001', Dealer_Contacted__c = false, Field_API_Name__c = 'Status', Field_Value__c = 'Open'));
        surveysSettings.add(new Epsilon_Surveys_Business_Rules__c(Name = '0000002', Dealer_Contacted__c = false, Field_API_Name__c = 'Description', Field_Value__c = 'Something'));
        surveysSettings.add(new Epsilon_Surveys_Business_Rules__c(Name = '0000003', Dealer_Contacted__c = false, Field_API_Name__c = 'Priority', Field_Value__c = 'High'));
        surveysSettings.add(new Epsilon_Surveys_Business_Rules__c(Name = '0000004', Dealer_Contacted__c = false, Field_API_Name__c = 'Subject', Field_Value__c = 'High priority'));
        surveysSettings.add(new Epsilon_Surveys_Business_Rules__c(Name = '0000005', Dealer_Contacted__c = false, Field_API_Name__c = 'OwnerId', Field_Value__c = '005F0000004BZL3'));

        insert surveysSettings;
    }
}