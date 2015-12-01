/**********************************************************************
Name: BulkApiLimits
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules BulkApiLimits job to run.
String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
System.schedule('Schedule_Batch_BulkAPILimitEmail', sch, new Schedule_Batch_BulkAPILimitEmail (UserInfo.getSessionId()));
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina      04/02/2015 Created
***********************************************************************/
global class Schedule_Batch_BulkAPILimitEmail implements Schedulable{
    private static string url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/limits/';
    private static string accessToken;
    private static Api_Usage_Limits__c apiUsageLimits = Api_Usage_Limits__c.getorgDefaults();
    private  String sessionId;

    public static List<ApiLimit> getapiLimits(string sessionId){    
    // Instantiate a new http object
        Http h = new Http();

         // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer ' + sessionId);//'C1VaBofzvcXpn3UUnRT4L6h2u');
        System.debug(userInfo.getSessionId());
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
        string jsonInput = res.getBody();
        System.debug(JSON.deserializeUntyped(jsonInput));
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        List<ApiLimit> apiLimits = new List<ApiLimit>();
        for(String key : m.keySet()){
            ApiLimit apiLimitItem = new ApiLimit();
            apiLimitItem.limitName = key;
            Map<String, Object> dim = (Map<String, Object>)m.get(key);
            apiLimitItem.limitReamain = (String.valueOf(dim.get('Remaining')));
            apiLimitItem.limitMax = (String.valueOf(dim.get('Max')));
            apiLimits.add(apiLimitItem);
        }   
        return apiLimits;
    }

    global Schedule_Batch_BulkAPILimitEmail (String userSessionId){
        this.sessionId = userSessionId;
    }
    
    global void execute(SchedulableContext SC) {
        ExecuteWithCallout(this.sessionId);
    }
    @future (callout=true)
    public static void ExecuteWithCallout(string sessionId) {
        if(apiUsageLimits == null || apiUsageLimits.Emails__c == null){
            apiUsageLimits = Api_Usage_Limits__c.getorgDefaults();
            apiUsageLimits.Emails__c = 'anna.koseykina@softheme.com';
            upsert apiUsageLimits;
        }

        apiUsageLimits = Api_Usage_Limits__c.getorgDefaults();
        String[] toAddresses = apiUsageLimits.Emails__c.split(',');
        List<ApiLimit> limitsUsed = new List<ApiLimit>();
        if(!Test.isRunningTest()){
            limitsUsed = getapiLimits(sessionId);
        }else{
            limitsUsed.add(new ApiLimit());
            limitsUsed[0].limitName = 'test';
            limitsUsed[0].limitReamain = '3';
            limitsUsed[0].limitMax = '5';
        }
        Map<String, ApiUsageLimits_Pairs__c> apiLimitsSetting = ApiUsageLimits_Pairs__c.getAll();
        boolean nearToLimit = false;
        String limitsUsedString = '';
        String exceededLimits = '';
        Integer used = 0;
        for(integer i = 0; i<limitsUsed.size(); i++){           
            limitsUsedString += '' + limitsUsed[i].limitReamain + ' remaining out of ' + limitsUsed[i].limitMax + ' for limit \'' + limitsUsed[i].limitName + '\', \n';
            if(!Test.isRunningTest()){
                if(apiLimitsSetting.get(limitsUsed[i].limitName).Limit_Value__c <= (Integer.valueOf(limitsUsed[i].limitMax) - Integer.valueOf(limitsUsed[i].limitReamain))){
                    nearToLimit = true;
                    exceededLimits += '' + limitsUsed[i].limitMax + ' for \'' + limitsUsed[i].limitName + '\', ';
                }
            }
        }
        limitsUsedString = limitsUsedString.removeEnd(', \n');
        exceededLimits = exceededLimits.removeEnd(', ');
        if(Test.isRunningTest()){
            nearToLimit = true;
        }
        if(nearToLimit){
            update apiUsageLimits;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate templateId = [select id, name, Body, Subject from EmailTemplate where developername = : 'Api_Usage_Limits_Exceeded'];
            User target = [select id from User where email in :toAddresses limit 1];
            mail.setTargetObjectId(target.id);
            mail.setToAddresses(toAddresses);
            for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress where address = 'nissansolutionoperationssupport@teletech.com']) {               
                mail.setOrgWideEmailAddressId(owa.id); 
                mail.setReplyTo(owa.address);                
            }

            mail.setSubject(templateId.subject);
            mail.setSaveAsActivity(false);

            String plainBody = templateId.Body;

            plainBody = plainBody.replace('{other limits}', limitsUsedString);
            plainBody = plainBody.replace('{limits exceeded}', exceededLimits);

            mail.setPlainTextBody(plainBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
          
        }
    }
    @TestVisible
    class ApiLimit{
        public String limitName{get;set;}
        public String limitMax{get;set;}
        public String limitReamain{get;set;}
    }
}