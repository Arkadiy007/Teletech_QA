@RestResource(urlMapping = '/epsilon/api/v1/surveys/*')
global class EpsilonSurveysRest {
    
    @HttpPost
    global static EpsilonSurveyRest.ResponseWrapper[] createSurveys(EpsilonSurveyRest.RequestWrapper[] requests){
        List<Surveys__c> surveysToInsert = new List<Surveys__c>();
        List<EpsilonSurveyRest.ResponseWrapper> responses = new List<EpsilonSurveyRest.ResponseWrapper>();

        Set<EpsilonSurveyRest.RequestWrapper> badRequests = new Set<EpsilonSurveyRest.RequestWrapper>();
        List<EpsilonSurveyRest.ResponseWrapper> badResponses = new List<EpsilonSurveyRest.ResponseWrapper>();

        for(EpsilonSurveyRest.RequestWrapper request : requests){
            EpsilonSurveyRest.ResponseWrapper response = EpsilonSurveyRest.validateSurvey(request);
            if(response.code == 400){
                badRequests.add(request);
                badResponses.add(response);
            }
            else{
                responses.add(EpsilonSurveyRest.validateSurvey(request));
            }
        }


        for(EpsilonSurveyRest.RequestWrapper request : requests){
            if(!badRequests.contains(request)){
                surveysToInsert.add(EpsilonSurveyRest.surveyBuilder(request));
            }
        }

        try{            
            insert surveysToInsert;


            EpsilonSurveyAfterHelper helper = new EpsilonSurveyAfterHelper();
            helper.upsertCasesForEpsilonRT(surveysToInsert, true);

            for(Integer i = 0; i < surveysToInsert.size(); i++){
                responses[i].sfdcId = surveysToInsert[i].id;
                responses[i].code = 200;
                responses[i].status = 'success';
                responses[i].message = 'OK';
            }
        }
        catch(DMLException e){
            for(EpsilonSurveyRest.ResponseWrapper rw : responses){
                rw.code = 500;
                rw.status = 'error';
                rw.message = 'Internal error on insert: ' + e.getMessage();
            }
            System.debug(e);
        }
        responses.addAll(badResponses); 
        return responses;
    }
    

}