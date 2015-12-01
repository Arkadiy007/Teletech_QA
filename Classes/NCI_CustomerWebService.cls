/*
  Page Title: NCI_CustomerWebService
  Author: Aaron Bessey
  Create Date: 3/15/2015
  Last Update: 3/15/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

public class NCI_CustomerWebService {
    public String selectedAccId { get; set; }
    public String selectedAccCustomerId { get; set; }
    public Account acc { get; set; }
    public Boolean requiresRedirect { get; set; }
    public String responseJSON { get; set; }
    public Boolean isAdmin { get; set; }
    private static Datetime lastCalloutTime = System.now().addHours(- 1);
     
    public NCI_CustomerWebService(ApexPages.StandardController stdController) {
        selectedAccId = ApexPages.currentPage().getParameters().get('id');
        selectedAccCustomerId = ApexPages.currentPage().getParameters().get('customerid');
 
        requiresRedirect = true;

        checkThatUserHasAdministratorProfile();
    }

    private void checkThatUserHasAdministratorProfile() {
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where id = :profileId].Name;

        if (profileName == 'System Administrator') {
            isAdmin = true;
        }
        else {
            isAdmin = false;
        }
    }

   

    private Boolean IsNullOrEmptyString(String value) {
        if (value != null && value != '') {
            return false;
        }

        return true;
    }


    // Api call for getting list of Cusomer records associated with search params
    public static String getCustomerList(Map <String, String > params) {
        String resp = '';

        NCIWebServiceSettings__c wsSettings;
        Map <String, String > params2 = new Map<String,String>(params);
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        
        wsSettings = NCIWebServiceSettings__c.getOrgDefaults();
        req.setTimeout(Integer.valueOf(wsSettings.TimeoutSeconds__c)*1000);
        
        //https://cs7.salesforce.com/services/apexrest/casl/api/v1/customer
        String parametersString = '';
        Boolean onlyPhoneEmail = false;
        
        for (String key : params.keySet()) {
            String value = params.get(key);
            if ((key.tolowercase() == 'phone'  || key.tolowercase() == 'personemail') && value != '') {
                onlyPhoneEmail = true;
            }
        }
        for (String key : params.keySet()) {
            if (onlyPhoneEmail && key != 'phone' && key != 'personemail') {
                params2.remove(key);
            }
        }
        
        
        Boolean hasVin = false; String vin;
        for (String key : params2.keySet()) {
            
            String value = params.get(key);
            value=value.trim();
            if (key.tolowercase() == 'firstname') { key='firstName';}
            if (key.tolowercase() == 'lastname') { key='lastName';}      
            if (key.tolowercase() == 'personmailingpostalcode') { key='postalCode';}  
            if (key.tolowercase() == 'personemail') { key='email';}  
            if (key.tolowercase() == 'phone') { key='phone';}  
            if (key.tolowercase() == 'vin') { hasVin = true; key='vinCode'; vin = value;}  
            
            if (key == 'phone') { value = value.replaceAll('[^0-9]',''); }
            
            if (key == 'postalCode') { value = value.replaceAll('(\\s+)',''); } 
            if (value != null && value != '') {
                parametersString += String.format('{0}={1}&', new String[] { key, value });  // removed lowercasing on key string WT
            }
        }

        if (hasVin) {
            parametersString = 'vinCode='+vin;
        }
        
        Blob headerValue;
        if (wsSettings.useProductionURLs__c) {
        req.setEndpoint(Label.NCI_Customer_List_Endpoint_PRD + '&' +  parametersString.replace(' ','%20'));
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserPrd__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDPRD);
        } else {
        req.setEndpoint(Label.NCI_Customer_List_Endpoint + '&' + parametersString.replace(' ','%20'));
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserQA__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        }
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        req.setMethod('GET');
        System.DEBUG(req);
        // Send the request, and return a response
        if (Test.isRunningTest()) {
             resp = '{"type":"Response","status":"success","result":{"message":"test message","code":200},"requestId":1234567890,"customerVehicles":[{"vinCode":"5N1AL0MM5EC537943","transferFromCustomerNumber":null,"serviceDealerCode":"44221","seriesCode":"Y","secondServiceSurveyDate":"2015-09-23","retailProcessDate":"2014-11-14","retailDealerCode":"12011","ownerTypeCode":"1","originalRetailTypeCode":"L","optionGroupCode":"BK00","modelYear":2014,"modelCode":"Y6SG18","inServiceDate":"2014-11-14","firstServiceSurveyDate":"2015-06-23","customerVehicleStartDate":"2014-11-14","customerVehicleEndDate":null,"customerNumber":5468479,"currentDriverIndicator":"Y"}]}';
        } else {
            HttpResponse res = h.send(req);
            resp = res.getBody();
        }
        //System.debug(res.getBody());
        return resp;
    }

    // Api call for getting particular customer record data, by customer number and tracking number
    public static String getCustomerDetails(String customerNumber, String trackingNumber) {
        String resp = '';
        NCIWebServiceSettings__c wsSettings;
   
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        wsSettings = NCIWebServiceSettings__c.getOrgDefaults();
        req.setTimeout(Integer.valueOf(wsSettings.TimeoutSeconds__c)*1000);
        
        
        
        
        Blob headerValue;
        if (wsSettings.useProductionURLs__c) {
        req.setEndpoint(Label.NCI_Customer_Detail_End_Point_PRD + '&customerNumber=' + customerNumber);  // these two fields break it:   + '&trackingNumber=' + trackingNumber + '&consentType=Nissan   WT
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserPrd__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDPRD);
        } else {
        req.setEndpoint(Label.NCI_Customer_Detail_End_Point + '&customerNumber=' + customerNumber);  // these two fields break it:   + '&trackingNumber=' + trackingNumber + '&consentType=Nissan   WT
        
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserQA__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        }
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');

        // Send the request, and return a response
        if (Test.isRunningTest()) {
            if (trackingNumber != '') {
                resp = '{ "type" : "Response", "status" : "success", "result" : { "message" : "test message", "code" : 200 }, "requestId" : 1234567890, "customer" : { "trackingInfo" : [ { "trackingNumber" : "' + trackingNumber + '", "source" : "SFDC", "activeIndicator" : true } ], "personalInfoUpdatedTimestamp" : "2014-05-05T18:15:11.000Z", "lastname" : "JIMENEZ", "firstname" : "ALEGRIA", "customerTypeCode" : "0", "customerNumber" : 15060859, "contactInfo" : { "updatedTimeStamp" : "2014-05-05T18:15:11.000Z", "preferredContactMethodCode" : 1, "phone" : [ { "type" : "MOBILE", "phoneNumber" : 8184687860, "extension" : null } ], "emailAddress" : [ { "primary" : true, "email" : "nannerz01@hotmail.com.qa" } ] }, "consentInfo" : [ { "contactMethod" : "MAIL", "consentType" : "NISSAN", "consentFlag" : true, "collectedTimestamp" : "2014-05-05T18:15:11.000Z", "collectedBy" : "SDIG" } ,{ "contactMethod" : "MAIL", "consentType" : "INFINITI", "consentFlag" : true, "collectedTimestamp" : "2014-05-05T18:15:11.000Z", "collectedBy" : "SDIG" },{ "contactMethod" : "MAIL", "consentType" : "DEALER", "consentFlag" : true, "collectedTimestamp" : "2014-05-05T18:15:11.000Z", "collectedBy" : "SDIG" }], "addressInfo" : { "validAddressIndicator" : true, "updatedTimestamp" : "2014-05-05T18:15:11.000Z", "freeformAddress" : { "address3" : "BURBANK US 91505 4905", "address2" : "N HOLLYWOOD WAY APT 3", "address1" : "400" }, "addressOverride" : false, "address" : { "zipCode" : "91505 4905", "streetType" : "3", "streetNumberSuffix" : null, "streetNumber" : "400", "streetName" : "N HOLLYWOOD WAY APT", "streetDirection" : null, "routeNumber" : null, "province" : "", "postalCode" : null, "deliveryQualifier" : null, "deliveryMode" : null, "country" : "US", "city" : "BURBANK", "boxNumber" : null, "apartmentNumber" : null } } } }';
            }
            else {
                resp = '{ "type" : "Response", "status" : "success", "result" : { "message" : "test message", "code" : 200 }, "requestId" : 1234567890, "customer" : { "trackingInfo" : [ { "trackingNumber" : "", "source" : "SFDC", "activeIndicator" : true } ], "personalInfoUpdatedTimestamp" : "2014-05-05T18:15:11.000Z", "lastname" : "JIMENEZ", "firstname" : "ALEGRIA", "customerTypeCode" : "0", "customerNumber" : 15060859, "contactInfo" : { "updatedTimeStamp" : "2014-05-05T18:15:11.000Z", "preferredContactMethodCode" : 1, "phone" : [ { "type" : "MOBILE", "phoneNumber" : 8184687860, "extension" : null } ], "emailAddress" : [ { "primary" : true, "email" : "nannerz01@hotmail.com.qa" } ] }, "consentInfo" : [ { "contactMethod" : "PHONE", "consentType" : "DEALER", "consentFlag" : true, "collectedTimestamp" : "2014-05-05T18:15:11.000Z", "collectedBy" : "SDIG" } ], "addressInfo" : { "validAddressIndicator" : true, "updatedTimestamp" : "2014-05-05T18:15:11.000Z", "freeformAddress" : { "address3" : "BURBANK US 91505 4905", "address2" : "N HOLLYWOOD WAY APT 3", "address1" : "400" }, "addressOverride" : false, "address" : { "zipCode" : "91505 4905", "streetType" : "3", "streetNumberSuffix" : null, "streetNumber" : "400", "streetName" : "N HOLLYWOOD WAY APT", "streetDirection" : null, "routeNumber" : null, "province" : "", "postalCode" : null, "deliveryQualifier" : null, "deliveryMode" : null, "country" : "US", "city" : "BURBANK", "boxNumber" : null, "apartmentNumber" : null } } } }';
            }
        } else {
            HttpResponse res = h.send(req);
            resp = res.getBody();
            System.debug(res.getBody());
        }
        return resp;
    }

    public static String getVehicles(String customerNumber) {
        
String resp = '';
        
        NCIWebServiceSettings__c wsSettings;
   
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        wsSettings = NCIWebServiceSettings__c.getOrgDefaults();
        req.setTimeout(Integer.valueOf(wsSettings.TimeoutSeconds__c)*1000);
        
        //https://cs7.salesforce.com/services/apexrest/casl/api/v1/customervehicles?customerNumber=[number]

        Blob headerValue;
        if (wsSettings.useProductionURLs__c) {
        req.setEndpoint(Label.NCI_Vehicle_Ownership_Endpoint_PRD + '&customerNumber=' + customerNumber);
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserPrd__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDPRD);
        } else {
        req.setEndpoint(Label.NCI_Vehicle_Ownership_Endpoint + '&customerNumber=' + customerNumber);
        headerValue = Blob.valueOf( wsSettings.NCIWSClientUserQA__c);
        req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        }
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');

        // Send the request, and return a response
         if (Test.isRunningTest()) {
            resp = '{ "type" : "Response", "status" : "success", "result" : { "message" : "test message", "code" : 200 }, "requestId" : 1234567890, "customerVehicles" : [{"customerNumber": 702111,"vinCode": "3N1EB32S2RL001881","ownerTypeCode": "4","currentDriverIndicator": "N","modelYear": 0,"seriesCode": "B","modelCode": "B2LG54","optionGroupCode": "","customerVehicleStartDate": "","customerVehicleEndDate": "9999-12-31","retailDealerCode": "46249","serviceDealerCode": "46249","originalRetailTypeCode": "O","firstServiceSurveyDate": "","secondServiceSurveyDate": "","transferFromCustomerNumber": 0,"inServiceDate": "1995-01-03","retailProcessDate": ""}] }';
         } else {
            HttpResponse res = h.send(req);
             resp = res.getBody();
        }
             return resp;
    }
}