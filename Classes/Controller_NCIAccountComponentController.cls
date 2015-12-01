public class Controller_NCIAccountComponentController {
  public Account acc {get; set;}
  public List<Vehicle_Ownership_History__c> tvohs {get; set;}
  public string Customer_Id { get; set; }
  public string accId { get; set; }
  public Boolean editMode {get; set;}
  public NCICustomerDetailRest.CustomerHandler thisCustomer {get; set;}
  public Boolean hasRecalls {get; set;}
  public List<String> vehicleRecalls {get; set;}
  public Boolean partialVehicleReturned {get; set;}
  
  public static Map<String,List<String>> vehicleRecalls(Set<String> vinSet) {
  
      Set<String> rids = new Set<String>();
      Map<String,List<String>> retMap = new Map<String,List<String>>();
      
      
      if (vinSet.size() > 0) {
          
          List<NCIVehicleRecallStagingData__c> stagingRecallData = [select id,vin__c,recallid__c from NCIVehicleRecallStagingData__c where Vin__c=:vinSet];
          
          if (stagingRecallData.size() > 0) {
              // parse results with map of recall descr. data
              System.debug('found recall data.. ');
              
              System.debug(stagingRecallData.size());
              
              for (NCIVehicleRecallStagingData__c sd : stagingRecallData) {
                  rids.add(sd.recallid__c);
              }
              
              Map<String,String> recallData = new Map<String,String>();
              
              List<NCIVehicleRecallStagingMaster__c> vehicleRecallStagingMasters = [select id ,recallid__c,type__c,issue_date__c,  English_Description__c,French_Description__c from NCIVehicleRecallStagingMaster__c where recallid__c=:rids];
              if (vehicleRecallStagingMasters.size() > 0) {
              for (NCIVehicleRecallStagingMaster__c sm : vehicleRecallStagingMasters) {
                  
                  recallData.put(sm.recallid__c,String.valueOf(sm.issue_date__c).left(10) + ', ' +sm.type__c+': '+ sm.english_description__c);
              }
              }
              
              
              System.debug('found masters...');
              System.debug(vehicleRecallStagingMasters.size());
              
              for (String v : vinSet) {
                  // for each vin, build and return list of recalls as a list
                  List<String> theseRecalls = new List<String>();
                  
                  for (NCIVehicleRecallStagingData__c thisRecall: stagingRecallData) {
                      if (thisRecall.VIN__C == v) {
                          theseRecalls.add(recallData.get(thisRecall.recallid__c));
                      }
                  }

                  retMap.put(v,theseRecalls);

              }
         }
      }
      return retMap;
      
  }
  
  
  Public Controller_NCIAccountComponentController(ApexPages.StandardController stdController) 
    {
        acc = [Select Id,Alternate_Email__c ,personcontactid, Name,Language_Preference__c, FirstName, LastName,Retail_Dealer__r.Name,Vehicles_Owned__c,Servicing_Dealer__r.Name, Infiniti_Mail__c,Dealer_Mail__c,  Nissan_Mail__c,Infiniti_Email__c,Nissan_Email__c,Dealer_Email__c,Infiniti_Text_Message__c,Nissan_Text_Message__c,Dealer_Text_Message__c,Infiniti_Call_Home_Phone__c,Nissan_Call_Home_Phone__c,Dealer_Call_Home_Phone__c,Nissan_Call_Work_Phone__c,Infiniti_Call_Work_Phone__c,Dealer_Call_Work_Phone__c,Nissan_Call_Mobile_Phone__c,Infiniti_Call_Mobile_Phone__c,Dealer_Call_Mobile_Phone__c,Undeliverable_Address_Indicator__c,Goodwill_Approved__c,Household_ID__c,Preferred_Contact_Method__c,Do_Not_Mail_Indicator__c,Preferred_Dealer_Code__c,Nickname__c,Previous_Mailing_Street__c, Previous_Mailing_City__c,Previous_Mailing_State__c,Previous_Mailing_Postal_Code__c,isPersonAccount , NCI_Customer_ID__c, Phone, PersonMobilePhone, Work_Phone__c, PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode,Preferred_Dealer_Id__r.Name, PersonMailingState, PersonMailingCountry, PersonEmail From Account where ispersonaccount=true and Id =: ((Account)stdController.getRecord()).Id];
        editMode = false;
        Customer_Id = acc.NCI_Customer_Id__c;
        accId = acc.Id;
        tvohs = new List<Vehicle_Ownership_History__c>();
         hasRecalls = false;
         vehicleRecalls = new List<String>();
         partialVehicleReturned = false;
         
    }
    public PageReference changeedit() {
        editMode = true;
        return null;
    }
    
    public PageReference confirmedit() {

         NCICustomerDetailUpdateRest.CustomerDetailHandler upCx = new NCICustomerDetailUpdateRest.CustomerDetailHandler();
         upCx.customer.customerNumber = Integer.valueOf(acc.NCI_Customer_Id__c);
       
       
       // upCx.requestId
         upCx.supplier = 'SFDC';
         upCx.clientId = System.Label.NCI_Client_IDQA;
         
         upCx.requestId = 9999999;
         
         upCx.updatedTimestamp = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
         upCx.customer.preferredLanguage = acc.Language_Preference__c;
         upCx.customer.trackingNumber = acc.Id;
         upCx.customer.firstname = acc.firstName;
         upCx.customer.lastname = acc.lastName;
         upCx.customer.companyName = acc.firstName + ' ' + acc.lastName;
         upCx.customer.contactInfo.preferredContactMethodCode = '';
         
         
         NCICustomerDetailUpdateRest.PhoneHandler homePhone = new NCICustomerDetailUpdateRest.PhoneHandler();
         NCICustomerDetailUpdateRest.PhoneHandler mobilePhone = new NCICustomerDetailUpdateRest.PhoneHandler();
         NCICustomerDetailUpdateRest.PhoneHandler workPhone  = new NCICustomerDetailUpdateRest.PhoneHandler();
         
         NCICustomerDetailUpdateRest.EmailAddressHandler email1 = new NCICustomerDetailUpdateRest.EmailAddressHandler();
         NCICustomerDetailUpdateRest.EmailAddressHandler email2 = new NCICustomerDetailUpdateRest.EmailAddressHandler();
         
         email1.primary = true;
         email2.primary = false;
         
         email1.email = acc.PersonEmail == null ? '' : acc.PersonEmail;
         email2.email = acc.Alternate_Email__c == null ? '' : acc.Alternate_Email__c;
         
         
         homePhone.type = 'HOME';
         workPhone.type = 'WORK';
         mobilePhone.type = 'MOBILE';
         
         homePhone.phoneNumber = Long.valueOf(acc.Phone.replaceAll('\\D',''));
         workPhone.phoneNumber = Long.valueOf(acc.work_phone__c.replaceAll('\\D',''));
         mobilePhone.phoneNumber = Long.valueOf(acc.PersonMobilePhone.replaceAll('\\D',''));
         homePhone.extension = '';
         workPhone.extension = '';
         mobilePhone.extension = '';
         
         upCx.customer.contactInfo.emailAddress.add(email1);
         upCx.customer.contactInfo.emailAddress.add(email2);
         
         
         upCx.customer.contactInfo.phone.add(workPhone);
         upCx.customer.contactInfo.phone.add(homePhone);
         upCx.customer.contactInfo.phone.add(mobilePhone);
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch1;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch2;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch3;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch4;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch5;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch6;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch7;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch8;
         NCICustomerDetailUpdateRest.ConsentInfoHandler  ch9;
         List<String> ctypes = new List<String>();
         ctypes.add('NISSAN');
         ctypes.add('INFINITI');
         ctypes.add('DEALER');
         
         for (String ctype: ctypes) {
             ch1 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
            
             ch1.contactMethod = 'MAIL'; ch1.consentType = ctype; ch1.consentFlag = (Boolean) acc.get(ctype+'_Mail__c');ch1.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch2 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch2.contactMethod = 'EMAIL';ch2.consentType = ctype; ch2.consentFlag = (Boolean) acc.get(ctype+'_Email__c');ch2.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch3 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch3.contactMethod = 'TXTMSG';ch3.consentType = ctype; ch3.consentFlag = (Boolean) acc.get(ctype+'_Text_Message__c');ch3.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch4 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch4.contactMethod = 'PHONE';ch4.consentType = ctype; ch4.consentFlag = (Boolean) acc.get(ctype+'_Call_Home_Phone__c');ch4.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch5 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch5.contactMethod = 'ADPHONE';ch5.consentType = ctype; ch5.consentFlag =(Boolean)  acc.get(ctype+'_Auto_Dial_Home_Phone__c');ch5.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch6 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch6.contactMethod = 'WPHONE';ch6.consentType = ctype; ch6.consentFlag = (Boolean) acc.get(ctype+'_Call_Work_Phone__c');ch6.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch7 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch7.contactMethod = 'ADWPHONE';ch7.consentType = ctype; ch7.consentFlag =(Boolean)  acc.get(ctype+'_Auto_Dial_Work_Phone__c');ch7.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch8 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch8.contactMethod = 'MPHONE';ch8.consentType = ctype; ch8.consentFlag =(Boolean)  acc.get(ctype+'_Call_Mobile_Phone__c');ch8.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
             ch9 = new NCICustomerDetailUpdateRest.ConsentInfoHandler();
             ch9.contactMethod = 'ADMPHONE';ch9.consentType = ctype; ch9.consentFlag =(Boolean)  acc.get(ctype+'_Auto_Dial_Mobile_Phone__c');ch9.collectedTimestamp=System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
              ch1.collectedBy = '';  ch2.collectedBy = ''; ch3.collectedBy = ''; ch4.collectedBy = ''; ch5.collectedBy = ''; ch6.collectedBy = '';
               ch7.collectedBy = ''; ch8.collectedBy = ''; ch9.collectedBy = '';
             upCx.customer.consentInfo.add(ch1); upCx.customer.consentInfo.add(ch2); upCx.customer.consentInfo.add(ch3);
             upCx.customer.consentInfo.add(ch4); upCx.customer.consentInfo.add(ch5); upCx.customer.consentInfo.add(ch6);
             upCx.customer.consentInfo.add(ch7); upCx.customer.consentInfo.add(ch8); upCx.customer.consentInfo.add(ch9);
         
         }
         
         
         
          
         
         
         
         
         upCx.customer.contactInfo.updatedTimestamp = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
         
         upCx.customer.personalInfoUpdatedTimestamp = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
         upCx.customer.addressInfo.freeFormAddress.addressLine1 = thisCustomer.addressInfo.freeFormAddress.addressLine1;
         upCx.customer.addressInfo.freeFormAddress.addressLine2 = thisCustomer.addressInfo.freeFormAddress.addressLine2;
         upCx.customer.addressInfo.freeFormAddress.addressLine3 = thisCustomer.addressInfo.freeFormAddress.addressLine3;
         upCx.customer.addressInfo.updatedTimestamp = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'');
         
        upCx.customer.addressInfo.address.apartmentNumber = thisCustomer.addressInfo.address.apartmentNumber;
       upCx.customer.addressInfo.address.streetNumber = thisCustomer.addressInfo.address.streetNumber;
       upCx.customer.addressInfo.address.streetNumberSuffix = thisCustomer.addressInfo.address.streetNumberSuffix;
       upCx.customer.addressInfo.address.streetName = thisCustomer.addressInfo.address.streetName;
       upCx.customer.addressInfo.address.streetType = thisCustomer.addressInfo.address.streetType;
       upCx.customer.addressInfo.address.streetDirection = thisCustomer.addressInfo.address.streetDirection;
       upCx.customer.addressInfo.address.deliveryMode = thisCustomer.addressInfo.address.deliveryMode;
       upCx.customer.addressInfo.address.routeNumber = thisCustomer.addressInfo.address.routeNumber;
       upCx.customer.addressInfo.address.boxNumber = thisCustomer.addressInfo.address.boxNumber;
       upCx.customer.addressInfo.address.deliveryQualifier = thisCustomer.addressInfo.address.deliveryQualifier;
       upCx.customer.addressInfo.address.city = thisCustomer.addressInfo.address.city;
       upCx.customer.addressInfo.address.province = thisCustomer.addressInfo.address.province;
       upCx.customer.addressInfo.address.country = thisCustomer.addressInfo.address.country;
       upCx.customer.addressInfo.address.postalCode = thisCustomer.addressInfo.address.postalCode;
       upCx.customer.addressInfo.address.zipCode = thisCustomer.addressInfo.address.zipCode;
       
      // upCx.customer.contactInfo {get;set;}   // contact info
     //  upCx.customer.consentInfo {get;set;} 
     /*   String add1 = '';
        String add2 = '';
        if (acc.PersonMailingStreet.contains('\n')) {
            acc.PersonMailingStreet = acc.PersonMailingStreet.replace('\r','');
            System.debug('contains it...');
              String[] addTest = acc.PersonMailingStreet.split('\n');
              if (addTest.size() == 2) {
              add1 = addTest[0];
              add2 = addTest[1];
              }
        }
        upCx.customer.addressInfo.freeformAddress.addressLine1 = add1;
        upCx.customer.addressInfo.freeformAddress.addressLine2 = add2;
        upCx.customer.addressInfo.freeformAddress.addressLine3 = acc.PersonMailingCity + ' ' + acc.PersonMailingState + ' ' + acc.PersonMailingPostalCode;
       */
       

     
        String cxSerialized = JSON.serialize(upCx);
        System.debug('cereal ized: ' + cxSerialized);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://b2bws.dev.na.nissan.biz/ServiceProxy/service?spx_serviceid=NNA-WS-CIS-CustomerUpdateService');
        req.setHeader('clientId',System.Label.NCI_Client_IDQA);
        Blob headerValue = Blob.valueOf('X985262:Nissan123');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(cxSerialized);
        HttpResponse res = h.send(req);
        System.debug(cxSerialized);
        System.debug('response...');
        System.debug(res.getBody());


        editMode = false;
        return null;
        
    }
    
   public void getaccountinfo() {
          
          Boolean wsVehCheck = true;
          Boolean wsCxCheck = true;
          String respVehicle = '';
          String responseJSON = '';
          List<Error_Log__c> errors = new List<Error_Log__c>();
          try {
              respVehicle = NCI_CustomerWebService.getVehicles(Customer_Id);
          } catch(Exception ex) {
              wsVehCheck = false;
              System.debug(ex);  errors.add(new Error_Log__c(Record_ID__c = Customer_Id, Record_Type__c = 'NCI Account', Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                                    TimeStamp__c = System.now(), Operation_Name__c = 'NCIAccountController Vehicle Ownership System Error', 
                                    Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There was an error processing your request for vehicle ownership. Please refresh your browser.'));
          }
          try {
              responseJSON = NCI_CustomerWebService.getCustomerDetails(Customer_Id, accid);
          } catch(Exception ex) {
              wsCxCheck = false;
            System.debug(ex);  errors.add(new Error_Log__c(Record_ID__c = Customer_Id, Record_Type__c = 'NCI Account', Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                                    TimeStamp__c = System.now(), Operation_Name__c = 'NCIAccountController Webservice System Error', 
                                    Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There was an error processing your request for customer details. Please refresh your browser.'));
          }
          System.debug('Vehicle Response:');
          System.debug(respVehicle);
          System.debug('CX Response:');
          System.debug(responseJSON);
               
               if (responseJSON.length() > 0) {
                   if (responseJSON.indexOf('\"status\":\"error\",\"type\":\"error\",') != -1) {
                          wsCxCheck = false;    //fails ws check
                          System.debug('found that this is an error... will not try to parse out. gonna error diff.');
                          NCICustomerDetailRest.CustomerDetailErrorHandler cde = (NCICustomerDetailRest.CustomerDetailErrorHandler) Json.deserialize(responseJSON, NCICustomerDetailRest.CustomerDetailErrorHandler.Class);
                          String msg;
                          if (cde.result != null && cde.result.code != null) {
                            msg = returnErrorMessage(String.valueOf(cde.result.code));
                              errors.add(new Error_Log__c(Record_ID__c = Customer_Id,
                                        Record_Type__c = 'NCI Account', 
                                        Error_Message__c = msg, 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'NCIAccountController Customer Webservice', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
                          }
                          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,msg));
                   }
                   
               }
                 if (respVehicle.length() > 0) {
                   if (respVehicle.indexOf('\"status\":\"error\",\"type\":\"error\",') != -1) {
                          wsVehCheck = false;    //fails ws check
                          System.debug('found that this is an error... will not try to parse out. gonna error diff.');
                          NCICustomerDetailRest.CustomerDetailErrorHandler cde = (NCICustomerDetailRest.CustomerDetailErrorHandler) Json.deserialize(respVehicle, NCICustomerDetailRest.CustomerDetailErrorHandler.Class);
                          String msg;
                          if (cde.result != null && cde.result.code != null) {
                            msg = returnErrorMessage(String.valueOf(cde.result.code));
                             errors.add(new Error_Log__c(Record_ID__c = Customer_Id,
                                        Record_Type__c = 'NCI Account', 
                                        Error_Message__c = msg, 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'NCIAccountController CustomerVehicle Webservice', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
                          }
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,msg));
                   }
                   
               }
 
               
               if (wsCxCheck) {
                   NCICustomerDetailRest.CustomerDetailHandler cdh = (NCICustomerDetailRest.CustomerDetailHandler) Json.deserialize(responseJSON, NCICustomerDetailRest.CustomerDetailHandler.Class);
                   NCICustomerDetailRest.CustomerHandler ch = cdh.customer;
                   thisCustomer = cdh.customer;
                   acc = UpdateCustomerAccount(ch);
               }
               if (wsVehCheck) {
                   UpsertVehicleOwnership(respVehicle,acc);                         
               }
               if (!errors.isEmpty()) {
                    // Insert error rows
                    Database.SaveResult[] dbResults = Database.insert(errors, false);
               }
          
        
           if (!errors.isEmpty()) {
            // Insert rows
                    Database.SaveResult[] dbResults = Database.insert(errors, false);
              }   
return;
    }
    
      private Account UpdateCustomerAccount(NCICustomerDetailRest.CustomerHandler ch) {
     String thiscx = String.valueOf(ch.customerNumber);
                    RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND Name='NCI' and IsPersonType = True limit 1];
               Id personId = personalAccRecordType.Id;
        Account customer = [select id,personcontactid, NCI_Customer_ID__c, Phone, PersonMobilePhone, Work_Phone__c, firstName, lastName, PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, PersonEmail from Account where recordtypeid=:personId and NCI_Customer_ID__c= :thiscx limit 1];

        if (!IsNullOrEmptyString(ch.lastname)) {
            customer.Language_Preference__c = ch.preferredLanguage;
            
            customer.firstName = ch.firstName;
            customer.lastName = ch.lastName;
            //customer.Customer_ID__c = String.valueOf(ch.customerNumber);
            customer.PersonMailingStreet = ch.addressInfo.freeformAddress.addressLine1 + '\n' + ch.addressInfo.freeformAddress.addressLine2; //BuildPersonalMailingStreetValue(ch);
            customer.PersonMailingCity = ch.addressInfo.address.city;
            customer.PersonMailingPostalCode = ch.addressInfo.address.postalcode;// this causes Address verification to begin recurrsion for address update.
            customer.PersonMailingState = ch.addressInfo.address.province;
            customer.PersonMailingCountry = ch.addressInfo.address.country;
            if (ch.contactInfo.emailAddress.size() > 0) {
                customer.PersonEmail = ch.contactInfo.emailAddress.get(0).email;
            }
           if (ch.contactInfo.emailAddress.size() > 1) {
                customer.Alternate_Email__c = ch.contactInfo.emailAddress.get(1).email;
            }

            for (NCICustomerDetailRest.PhoneHandler ph : ch.contactInfo.phone) {
                if (ph.type == 'HOME') {
                    customer.Phone = String.valueOf(ph.phonenumber);
                }
                else if (ph.type == 'MOBILE') {
                    customer.PersonMobilePhone = String.valueOf(ph.phonenumber);
                }
                else if (ph.type == 'WORK') {
                    customer.Work_Phone__c = String.valueOf(ph.phonenumber);
                }
            }
            for (NCICustomerDetailRest.ConsentInfoHandler ci : ch.consentInfo) {
                    if (ci.consentType == 'NISSAN') {
                        if (ci.contactMethod == 'MAIL') { customer.Nissan_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Nissan_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Nissan_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Nissan_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Nissan_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Nissan_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Nissan_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Nissan_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Nissan_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                    if (ci.consentType == 'INFINITI') {
                        if (ci.contactMethod == 'MAIL') { customer.Infiniti_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Infiniti_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Infiniti_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Infiniti_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Infiniti_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Infiniti_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Infiniti_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Infiniti_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Infiniti_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                    if (ci.consentType == 'DEALER') {
                        if (ci.contactMethod == 'MAIL') { customer.Dealer_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Dealer_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Dealer_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Dealer_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Dealer_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Dealer_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Dealer_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Dealer_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Dealer_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                }
                
            update customer;
            customer.name = ch.firstName + ' ' +  ch.lastName;
        }

        return customer;
    }
    
public string returnErrorMessage(string code) {
      Map<string, string> internal_storage = new Map<String, String>();
      Map<string, NCIWebServiceErrors__c> allRecords = NCIWebServiceErrors__c.getAll();
         for(NCIWebServiceErrors__c tcs:allRecords.values()){
                     if(! internal_storage.containsKey(tcs.ErrorNumber__c)){
                             internal_storage.put(tcs.ErrorNumber__c,tcs.ErrorMessage__c);
                       }
         }
         
      if (internal_storage.get(code) != null) {
          
      return internal_storage.get(code);
      
      } else {
      return 'An error has occured.';
      
      }
}
     
        private String BuildPersonalMailingStreetValue(NCICustomerDetailRest.CustomerHandler ch) {
        String street = '';

        street += (ch.addressInfo.address.apartmentNumber != null && ch.addressInfo.address.apartmentNumber != '') ? ch.addressInfo.address.apartmentNumber : '';
        street += (ch.addressInfo.address.streetNumber != null && ch.addressInfo.address.streetNumber != '') ?
        (street != '' ? '-' + ch.addressInfo.address.streetNumber : ch.addressInfo.address.streetNumber) : '';
        street += (ch.addressInfo.address.streetNumberSuffix != null && ch.addressInfo.address.streetNumberSuffix != '') ? ' ' + ch.addressInfo.address.streetNumberSuffix : '';
        street += (ch.addressInfo.address.streetName != null && ch.addressInfo.address.streetName != '') ? ' ' + ch.addressInfo.address.streetName : '';
        street += (ch.addressInfo.address.streetType != null && ch.addressInfo.address.streetType != '') ? ' ' + ch.addressInfo.address.streetType : '';
        street += (ch.addressInfo.address.streetDirection != null && ch.addressInfo.address.streetDirection != '') ? ' ' + ch.addressInfo.address.streetDirection : '';

        return street;
    }
  private Boolean IsNullOrEmptyString(String value) {
        if (value != null && value != '') {
            return false;
        }

        return true;
    }
    private void UpsertVehicleOwnership(String resp,Account acc) {
        NCICustomerVehiclesRest.CustomerVehicleHandler cvh = (NCICustomerVehiclesRest.CustomerVehicleHandler) Json.deserialize(resp, NCICustomerVehiclesRest.CustomerVehicleHandler.class);
        List <NCICustomerVehiclesRest.CustomerVehicle > cv = null;
        if (cvh != null) {
            cv = cvh.customerVehicles;
        }
        
        
        System.debug('Inside vehicle ownership');
        
  
        if (cv != null) {
            Account customer = [SELECT id, Customer_ID__c from Account where id = :acc.id limit 1];
            Map <String, Vehicle__c > vehicles = new Map <String, Vehicle__c > ();
             Map <String, Vehicle__c > allvehicles = new Map <String, Vehicle__c > ();
             Map <String, Vehicle__c > realvehicles = new Map <String, Vehicle__c > ();
            
            Vehicle__c vec;
            // LIMIT to 20 vehicles from web service, indicate to user that more vehicles are
            //returned
            Integer vCount = 0;
            
            
            for (NCICustomerVehiclesRest.CustomerVehicle cVeh : cv) {
                if (vCount >= 20) {
                    partialVehicleReturned = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'More than 20 vehicles returned, please search by exact VIN for vehicle queries.'));
                    break; 
                }    
                
                
                if (cVeh.vinCode != null) {
                    vCount++;
                    vec = new Vehicle__c(Make_Name__c = cVeh.make,Model_Name__c= cVeh.modelDesc,
                                         Name = cVeh.vinCode,
                                         Model_Year__c = String.valueOf(cVeh.modelYear),
                                         Vehicle_identification_Number__c = cVeh.vinCode,
                                         Model_Series__c = cVeh.seriesCode,
                                         In_Service_Date__c = cVeh.inServiceDate == null ? null : Date.valueOf(cVeh.inServiceDate)
                    );
                }
                vehicles.put(cVeh.vinCode, vec);
                allvehicles.put(cVeh.vinCode,vec);
            }

            List <Vehicle__c > existingVehicles = [SELECT Id, Name,Make_Name__c,Model_Name__c, Model_Series__c, In_Service_Date__c, Model_Year__c, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :vehicles.keySet()];
            List <Vehicle__c > updateVehicleTemp = new List<Vehicle__c>();
            Vehicle__c tempVehicle;
            
            for (Vehicle__c v : existingVehicles) {
                System.debug(v.Name);
                if (vehicles.containsKey(v.Vehicle_identification_Number__c)) {
                    System.debug('attempting to remove vheicle named: ' + v.Name);
                    vehicles.remove(v.Vehicle_identification_Number__c);
                    updateVehicleTemp.add(v);
                }
            } 

            for (Vehicle__c v : updateVehicleTemp) {
                for (NCICustomerVehiclesRest.CustomerVehicle cVeh : cv) {
                    if (cVeh.vinCode == v.Vehicle_Identification_Number__c) {
                           
                           v.Make_Name__c=cVeh.make;
                           v.Model_Name__c = cVeh.modelDesc;
                           v.Name = cVeh.vinCode;
                           v.Model_Year__c = String.valueOf(cVeh.modelYear);
                           v.Model_Series__c = cVeh.seriesCode;
                           v.In_Service_Date__c = cVeh.inServiceDate == null ? null : Date.valueOf(cVeh.inServiceDate);
                    }
                 }
            }
            
            
            upsert updateVehicleTemp;
            upsert vehicles.values();
            
            List <Vehicle__c > afterworkVehicles = [SELECT Id, Name,Make_Name__c,Model_Name__c, Model_Series__c, In_Service_Date__c, Model_Year__c, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :allvehicles.keySet()];
            

            for (Vehicle__c v : afterworkVehicles) {
                  realvehicles.put(v.Vehicle_Identification_Number__c,v);
                  
            } 
           
           
            Map <String, Vehicle_Ownership_History__c > vohs = new Map <String, Vehicle_Ownership_History__c > ();
            Vehicle_Ownership_History__c tempVOH;
            tvohs.clear();
            
            System.debug('Size of the cv: ' + cv.size());
            
            Set<String> dealersused = new Set<String>();
            for (NCICustomerVehiclesRest.CustomerVehicle cusVeh : cv) {
                if (!dealersused.contains(cusVeh.retailDealerCode)) {
                    dealersused.add(cusVeh.retailDealerCode);
                }
                if (!dealersused.contains(cusVeh.serviceDealerCode)) {
                    dealersused.add(cusVeh.retailDealerCode);
                }
            
            }
            
             Map<String, ID> dealerMap = new Map<String, ID>();
            if (dealersused.size() > 0) {
                for (Account dealer : [Select Id, Dealer_Code__c From Account WHERE RecordType.Name IN ('Dealer','NCI - Dealer') and Dealer_Code__c in: dealersused]) {
                    if (!dealerMap.containsKey(dealer.Dealer_Code__c)) {
                        dealerMap.put(dealer.Dealer_Code__c, dealer.ID);
                    }
                }
                
             }

            for (NCICustomerVehiclesRest.CustomerVehicle cusVeh : cv) {
           
                if (realvehicles.get(cusVeh.vinCode) != null) {
                    tempVOH = new Vehicle_Ownership_History__c(Owner__c = customer.id, Vehicle__c = realvehicles.get(cusVeh.vinCode).id);
                    tempVOH.Begin_Date__c = cusVeh.customerVehicleStartDate == '' ? null : Date.valueOf(cusVeh.customerVehicleStartDate);
                    tempVOH.End_Date__c = cusVeh.customerVehicleEndDate == '' ? null : Date.valueOf(cusVeh.customerVehicleEndDate);
                    
                    if ( cusVeh.customerVehicleEndDate == '9999-12-31') {
                        tempVOH.End_Date__c = null;
                    }
                    
                    //tempVOH.Current_Owner_Indicator__c = cusVeh.currentDriverIndicator == 'Y' ? true : false;
                    tempVOH.Current_Driver_Indicator__c = cusVeh.currentDriverIndicator;
                    tempVOH.Original_Retail_Type_Code__c = cusVeh.originalRetailTypeCode;
                    tempVOH.Original_Retail_Type_Desc__c = cusVeh.originalRetailTypeDesc;
                    tempVOH.Owner_Type_Code__c = cusVeh.ownerTypeCode;
                    tempVOH.Retail_Dealer__c = dealerMap.get(cusVeh.retailDealerCode) != null ? dealerMap.get(cusVeh.retailDealerCode) : null;
                    tempVOH.Servicing_Dealer__c = dealerMap.get(cusVeh.serviceDealerCode) != null ? dealerMap.get(cusVeh.serviceDealerCode) : null;
            
                    tvohs.add(tempVOH);
                    vohs.put(cusVeh.vinCode, tempVOH);
                    
                }
            }
            
            System.debug(vohs.size());
            
             List<Vehicle_Ownership_History__c> tvos = [select Id, VIN__c, Begin_Date__c,name,
                 End_Date__c, Current_Owner_Indicator__c,
                 Primary_Owner_Indicator__c,
                 Vehicle__c,Open_New_Case__c,
                 Vehicle__r.Model_Year__c,Vehicle__r.Name,Vehicle_Make__c,
                 Vehicle__r.Make_Name__c,Vehicle__r.Latest_recorded_mileage_number__c,
                 Vehicle__r.Model_Line_Name__c,
                 Vehicle__r.Vehicle_identification_Number__c
                 from Vehicle_Ownership_History__c
                 where Owner__c = :customer.id];               
            
            Database.delete(tvos);
                 
   
            /*for (Vehicle_Ownership_History__c v : tvos) {
                if (vohs.containsKey(v.Vehicle__r.Vehicle_identification_Number__c)) {
                    vohs.remove(v.Vehicle__r.Vehicle_identification_Number__c);
                }
            }*/
           //  upsert vohs.values();
             upsert tvohs;
             Set<Id> stv = new Set<Id>();
             
             for (Vehicle_Ownership_History__c v: tvohs) {
                 stv.add(v.id);
             }
             
           // tvohs = //vohs.clone();
            List<Vehicle_Ownership_History__c> tvos2 = [select Id, VIN__c, Begin_Date__c,name,
                 End_Date__c, Current_Owner_Indicator__c,
                 Primary_Owner_Indicator__c,Current_Driver_Indicator__c, Owner_Type_Decoded__c,Original_Retail_Type_Desc__c,
                 Vehicle__c,Open_New_Case__c,Servicing_Dealer__r.Name,Retail_Dealer__r.Name,
                 Vehicle__r.Model_Year__c,Vehicle__r.Name,Vehicle_Make__c,
                 Vehicle__r.Make_Name__c,Vehicle__r.Latest_recorded_mileage_number__c,
                 Vehicle__r.Model_Line_Name__c,Vehicle__r.Model_Line_Series__c,Retail_Dealer__r.Dealer_Code__c,Servicing_Dealer__r.Dealer_Code__c,
                 Vehicle__r.Vehicle_identification_Number__c
                 from Vehicle_Ownership_History__c
                 where id in :stv ORDER BY Vehicle__r.Vehicle_identification_Number__c];       
            tvohs = tvos2.clone();
            
            Set<String> vins = new Set<String>();
            Map<String,String> vinModel = new Map<String,String>();
            
            for (Vehicle_Ownership_History__c v : tvohs) {
                vins.add(v.VIN__C);
            }
            for (Vehicle_Ownership_History__c v : tvohs) {
                vinModel.put(v.VIN__C,v.Vehicle__r.Model_Year__c + ' ' + v.Vehicle__r.Make_Name__c + ' ' + v.Vehicle__r.Model_Line_Series__c);
            }
            Map<String,List<String>> returnMap = vehicleRecalls(vins);
            
            if(returnMap.size() > 0) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Recalls on one or more vehicles:'));
                hasRecalls = true;
                
                for (String vin : returnMap.keySet()){
        
                     List<String> s = returnMap.get(vin);
                     for (String thisRecall: s) {
                         vehicleRecalls.add(vin + ' ' + vinModel.get(vin) + '  ' +  thisRecall);
                     }
                     
                                          
                }
                
            }    
                
            
            
            System.debug(returnMap);
            
            
        }
    }
    
    public Id newCaseAccountId {get; set;}
    public Id newCaseVehicleId {get; set;}
    public Id newCaseServicingDealerId {get; set;}
    public String newCaseVehicleMake {get; set;}
    public Integer newCaseVehiclesOwned {get; set;}
    public String newCaseOwnerType {get; set;}
    public Id newCasePersonContactId {get; set;}
/*
    cas8=N/A&00Nf00000015KdD={!vohs.Owner_Type_Decoded__c}&
    CF00NA00000070W35_lkid={!vohs.Vehicle__r.Id}&
    CF00NF0000008ODHT={!acc.Servicing_Dealer__r.Name}&
    CF00NF0000008ODHT_lkid={!acc.Servicing_Dealer__r.Id}&
    00NF0000008NeI5={!vohs.Vehicle_Make__c}&
    00NF0000008NeKU={!acc.Vehicles_Owned__c}','','New Case')"
    
    */
    
    public PageReference newCase() {
        Case c = new Case();
        c.recordtypeid = System.Label.NCI_Case_RecordType;
        c.accountid = newCaseAccountId == null ? null : newCaseAccountId;
        c.Servicing_Dealer__c = newCaseServicingDealerId == null ? null : newCaseServicingDealerId;
        c.Vehicle_Name__c = newCaseVehicleId == null ? null : newCaseVehicleId;
        c.Vehicle_Make__c = newCaseVehicleMake == null ? null : newCaseVehicleMake;
        c.Vehicles_Owned__c = newCaseVehiclesOwned  == null ? null : newCaseVehiclesOwned;
        c.Vehicle_Owner_Type_Code__c = newCaseOwnerType == null ? null : newCaseOwnerType;
        c.contactid = newCasePersonContactId == null ? null : newCasePersonContactId ;
        insert c;
        
       PageReference pg = new PageReference('/' + c.Id + '/e?isdtp=nv&retURL=/apex/NCIAccountWS?id=' + acc.Id);
       return pg;
       
    }
    
    
    
}