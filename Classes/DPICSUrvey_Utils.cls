public class DPICSUrvey_Utils {

@future(callout=true)
 public static void createDPICContact(Id dpicSurveyId, String SFDCCaseId, String  emailAddress, String brandName,String contactName, String agentName, String partNumber) { 
                                           
        Http http = new Http();                                     
        List<Error_Log__c> errors = new List<Error_Log__c>();                      
        String retval = '';    
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        
        SurveyGizmo_DPIC_Settings__c sgdpic = SurveyGizmo_DPIC_Settings__c.getOrgDefaults();
        
        if (sgdpic.contactCounter__c >= sgdpic.contactsPerCampaign__c) {
            // clone camp
            String newCampNum = DPICSUrvey_Utils.cloneCampaignDPIC(sgdpic.surveyNumber__c,sgdpic.campaignNumber__c,'QA Camp' + System.now().format('MM/dd/yyyy HH:mm:ss'));
            sgdpic.contactCounter__c = 0;
            if (newCampNum.isNumeric()) {                    // ensure only numeric response here.
                sgdpic.campaignNumber__c = newCampNum;
            }
        }
        sgdpic.contactCounter__c = sgdpic.contactCounter__c != null ? sgdpic.contactCounter__c + 1 : 1;

        try {
            req.setMethod('PUT');
            
            String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' +sgdpic.surveyNumber__c+ '/surveycampaign/' + sgdpic.campaignNumber__c + '/contact/?user:pass=' + sgdpic.SurveyGizmo_UserName__c + ':'+ sgdpic.SurveyGizmo_Password__c + '&_method=PUT';
             
             if (emailAddress != null) {
               endpointUrl = endPointUrl + '&semailaddress=' + EncodingUtil.urlEncode(emailAddress,'UTF-8');
             }
             
             if (brandName != null) {
                 endPointUrl = endPointUrl + '&sdivision=' + EncodingUtil.urlEncode(brandName,'UTF-8');
             }
             if (agentName != null) {
                 endPointUrl = endPointUrl + '&scustomfield1=' + EncodingUtil.urlEncode(agentName,'UTF-8');
             }
             if (contactName != null) {
                 endPointUrl = endPointUrl + '&scustomfield2=' + EncodingUtil.urlEncode(contactName,'UTF-8');
             }
             if (SFDCCaseId!= null) {
                 endPointUrl = endPointUrl + '&scustomfield3=' + EncodingUtil.urlEncode(SFDCCaseId,'UTF-8');
             }
             if (dpicSurveyId!= null) {
                 endPointUrl = endPointUrl + '&scustomfield4=' + EncodingUtil.urlEncode(dpicSurveyId,'UTF-8');
             } 

             endPointUrl = partNumber != null ? endPointUrl + '&scustomfield6=' + EncodingUtil.urlEncode(partNumber,'UTF-8') : endPointUrl;
             
             endPointUrl = endPointUrl + '&scustomfield5=' + EncodingUtil.urlEncode(System.now().format('MM/dd/yyyy'),'UTF-8');
             
            
            
            /* if (dpicSurvey.Last_Name__c != null) {
                 endPointUrl = endPointUrl + '&slastname=' + EncodingUtil.urlEncode(dpicSurvey.Last_Name__c,'UTF-8');
             } */
             
             
             
            req.setEndpoint( endpointUrl);
            req.setBody('body'); 
            
        } catch (Exception ex) {
       
        
        }
        HTTPResponse res;
        try {  
         if (!Test.IsRunningTest()) { res = http.send(req); }
         } catch(Exception e) {
            retval = e.getMessage(); 
             errors.add(new Error_Log__c(
            Error_Message__c = e.getMessage() + e.getLineNumber(), 
            TimeStamp__c = System.now(), 
            Operation_Name__c = 'DPICSurvey_Load Error', 
            Source__c='Salesforce', 
            Log_Type__c = 'Error', 
            Log_Level__c = 1));

         }     
         JSONParser parser; 
            if (Test.IsRunningTest()) {
            parser = JSON.createParser('{"result_ok":true,"id":"123123123"}');
            } else {
            retval = 'STATUS_CODE:' + res.getStatusCode();   // default return value,
            parser = JSON.createParser(res.getBody());
            }
            // need to try to return the id
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    // Get the value.
                    parser.nextToken();
                    // Compute the grand total price for all invoices.
                    retval = parser.getText();
                }
            }
         
        update sgdpic;
        // return retval;
    }


 public static String cloneCampaignDPIC(String thisSurveyNumber, String thisCampaignNumber, String newName) {
        // clones the given Campaign and returns the ID to the caller.
        String retval = '';    
        HttpRequest req = new HttpRequest();

        SurveyGizmo_DPIC_Settings__c sgdpic = SurveyGizmo_DPIC_Settings__c.getOrgDefaults();
        
        req.setMethod('POST');
        // need to modify to change survey and campaign numbers based on brand
        String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' + thisSurveyNumber + 
                             '/surveycampaign/' + thisCampaignNumber + 
                             '/?user:pass=' + sgdpic.SurveyGizmo_UserName__c + ':'+ sgdpic.SurveyGizmo_Password__c +
                             '&_method=POST&copy=true&name=' + EncodingUtil.urlEncode(newName,'UTF-8');
        req.setEndpoint(endpointUrl);
        req.setBody('body'); 
        req.setTimeout(120000);
       
        Http http = new Http();
        HTTPResponse res;
        try {  
         if (!Test.IsRunningTest()) { res = http.send(req); } 
              
        } catch(System.CalloutException e) {
              //retval = e.getMessage(); 
              retval = thisCampaignNumber;   // clone didn't work use last campaign
        }  
        
        JSONParser parser; 
        if (Test.IsRunningTest()) {
            parser = JSON.createParser('{"result_ok":true,"id":"123123","message":"error message"}');
        } else {
            parser = JSON.createParser(res.getBody());
        }
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    // Get the value.
                    parser.nextToken();
                    retval = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) {
                    // Get the value.
                    parser.nextToken();
                    //retval = 'Error' + parser.getText();
                    retval = thisCampaignNumber;   // clone didn't work return last campaign
                }
            }

              
         
         return retval;

    }












}