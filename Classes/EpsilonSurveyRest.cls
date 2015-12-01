@RestResource(urlMapping = '/epsilon/api/v1/survey/*')
global class EpsilonSurveyRest {
    public static Id epsilonRT { get; set; }

    global class ResponseWrapper {
        global String sfdcId { get; set; }
        global Integer code { get; set; }
        global String status { get; set; }
        global String message { get; set; }

        global ResponseWrapper() {
        }


    }

    global class RequestWrapper {
        global String token { get; set; }
        global String brand { get; set; }
        global String surveyStatus { get; set; }
        global String surveyKey { get; set; }
        global Integer dqrDealerRating { get; set; }
        global String dqrDealerContacted { get; set; }
        global String dqrDealerComments { get; set; }
        global String leadId { get; set; }
        global String surveyVersion { get; set; }
        global String surveyLang { get; set; }
        global String surveySendDatetime { get; set; }
        global String surveyResponseDatetime { get; set; }
        global String placeHolder1 { get; set; }
        global String placeHolder2 { get; set; }
        global String placeHolder3 { get; set; }
        global String placeHolder4 { get; set; }
        global String placeHolder5 { get; set; }


        global RequestWrapper() {

        }
    }

    @HttpPost
    global static ResponseWrapper createSurveys(RequestWrapper request) {
        ResponseWrapper response = validateSurvey(request); 
        RestResponse rest_Response = RestContext.response;


        if (rest_Response == null) {
            rest_Response = new RestResponse();
            RestContext.response = rest_Response;
        }

        if (response.status == 'error') {
            rest_Response.statusCode = 400;
            return response;
        }
        
        if (ifTokenWrong(request)){
            response.message = 'Invalid security token';
            response.status = 'error';
            response.code = 403;

            rest_Response.statusCode = 403;
            return response;
        }
        try {
            List<Surveys__c> surveys = new List<Surveys__c> ();
            surveys.add(surveyBuilder(request));

            insert surveys;

            EpsilonSurveyAfterHelper helper = new EpsilonSurveyAfterHelper();
            helper.upsertCasesForEpsilonRT(surveys, true);

            if (surveys.size() > 0) {
                response.code = 200;
                rest_Response.statusCode = 200;
                response.status = 'success';
                response.message = 'OK';
                response.sfdcId = surveys[0].id;

            }
            else {
                response.sfdcId = '';
                response.code = 202;
                response.status = 'success';
                response.message = 'Survey with this leadid already exists';

                rest_Response.statusCode = 202;
            }
        }
        catch(DMLException e) {
            response.code = 500;
            response.status = 'error';
            response.message = 'Internal error on insert: ' + e.getMessage();

            rest_Response.statusCode = 500;
        }
        return response;
    }


    public static Surveys__c surveyBuilder(RequestWrapper request) {
        if (epsilonRT == null) {
            epsilonRT = RecordTypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Epsilon Survey');
        }
        Surveys__c survey = new Surveys__c();
        survey.Brand__c = request.brand;
        survey.SurveyStatus__c = request.surveyStatus;
        survey.EpSurveyKey__c = request.surveyKey;
        survey.DQR_Dealer_Rating__c = request.dqrDealerRating;
        if (request.dqrDealerContacted == '1') {
            survey.DQR_Dealer_Contacted__c = 'Yes';
        } else if (request.dqrDealerContacted == '0') {
            survey.DQR_Dealer_Contacted__c = 'No';
        } else {
            survey.DQR_Dealer_Contacted__c = 'Else';
        }

        survey.DQR_Dealer_Comments__c = request.dqrDealerComments;
        survey.Lead_Id__c = request.leadId;
        survey.EpSurveyVersion__c = request.surveyVersion;
        survey.EpSurveyLang__c = request.surveyLang;
        survey.EpSurveySendDatetime__c = request.surveySendDatetime;
        survey.EpSurveyResponseDatetime__c = request.surveyResponseDatetime;
        survey.EPSurveyPlaceholderField1__c = request.placeHolder1;
        survey.EPSurveyPlaceholderField2__c = request.placeHolder2;
        survey.EPSurveyPlaceholderField3__c = request.placeHolder3;
        survey.EPSurveyPlaceholderField4__c = request.placeHolder4;
        survey.EPSurveyPlaceholderField5__c = request.placeHolder5;
        survey.RecordTypeId = epsilonRT;
        return survey;
    }

    public static ResponseWrapper validateSurvey(RequestWrapper request) {
        ResponseWrapper response = new ResponseWrapper();

        if (String.isEmpty(request.brand) || String.isBlank(request.brand)) {
            response = addRequiredError('brand', response);
        }
        if (String.isEmpty(request.dqrDealerContacted) || String.isBlank(request.dqrDealerContacted)) {
            response = addRequiredError('dqrDealerContacted', response);
        }
        if (String.isNotBlank(request.dqrDealerContacted) && (request.dqrDealerContacted != '1' && request.dqrDealerContacted != '0')) {
            response.code = 400;
            response.status = 'error';
            response.message = 'Field Value Incorrect: dealerContacted. Valid values are: "1" or "0"';
        }
        if (request.dqrDealerRating != null && (request.dqrDealerRating < 0 || request.dqrDealerRating > 10)) {
            response.code = 400;
            response.status = 'error';
            response.message = 'Field Value Incorrect: dqrDealerRating. Valid values are null or from 0 to 10';
        }
        if (String.isEmpty(request.leadId) || String.isBlank(request.leadId)) {
            response = addRequiredError('leadId', response);
        }
        if (String.isEmpty(request.surveySendDatetime) || String.isBlank(request.surveySendDatetime)) {
            response = addRequiredError('surveySendDatetime', response);
        }
        if (String.isEmpty(request.surveyResponseDatetime) || String.isBlank(request.surveyResponseDatetime)) {
            response = addRequiredError('surveyResponseDatetime', response);
        }
        if (String.isBlank(request.surveyStatus)) {
            response = addRequiredError('surveyStatus', response);
        }
        if (String.isBlank(request.token)) {
            response = addRequiredError('token', response);
        }

        if (String.isNotBlank(request.surveyStatus) && (request.surveyStatus != 'complete' && request.surveyStatus != 'auto-complete')) {
            response.code = 400;
            response.status = 'error';
            response.message = 'Field Value Incorrect: surveyStatus. Valid values are: "complete" or "auto-complete"';
        }

        return response;
    }

    public static Boolean ifTokenWrong(RequestWrapper request){
        if(request.token == Label.Epsilon_Integration_Security_Key){
            return false;
        }
        return true;
    } 

    public static ResponseWrapper addRequiredError(String fieldName, ResponseWrapper response) {
        if (String.isNotEmpty(response.message)) {
            response.message += ', ' + fieldName;
        }
        else {
            response.code = 400;
            response.status = 'error';
            response.message = 'Required fields are missing: ' + fieldName;
        }

        return response;
    }
}