@RestResource(urlMapping='/Case/*')
global class RESTCaseController { 
  
  /**
   * REST POST
   * guid should not be empty, method to update Case disposition information
   * https://instance.salesforce.com/services/apexrest/Case/UpdateCaseStatus
   */
  @HttpPost  
  global static void UpdateCaseStatus(String guid, String dispositionStatus, String dispositionInformation) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');

    // select Case from the SF object using GUID
    Case[] cases = [SELECT Id, Case_Dealer_Disposition__c, Case_GUID__c, 
                           Case_Dealer_Disposition_Information__c
                      FROM Case
                     WHERE Case_GUID__c = :guid AND CreatedDate >= LAST_N_DAYS:5];

    String jsonResponse = '';
    if (!cases.isEmpty()) {
      try {
        cases[0].Case_Dealer_Disposition__c = dispositionStatus;
        cases[0].Case_Dealer_Disposition_Information__c = dispositionInformation;
        update cases[0];

        res.statusCode = 200;
        jsonResponse = '{"response": {"status": "Success", "message": ""}}';
      } catch (Exception ex) {
        res.statusCode = 500;
        jsonResponse = '{"response": {"status": "Failure", "message": "' + ex + '"}}';
      }
    } else {
      res.statusCode = 400;
      jsonResponse = '{"response": {"status": "Failure", "message": "Unable to find case maching guid: ' + guid + '"}}';
    }

    res.responseBody = Blob.valueOf(jsonResponse);
  }

}