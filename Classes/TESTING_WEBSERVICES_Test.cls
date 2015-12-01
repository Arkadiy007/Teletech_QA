@isTest                                
global class TESTING_WEBSERVICES_Test {

     //------TESTS-----//
     static testmethod void testfunctions() {
         TESTING_WEBSERVICES obj = new TESTING_WEBSERVICES();
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
             obj.RunGetassociated_dcno_id();
         }
         catch(Exception e){}
         //1
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
             obj.RunSearchCustomer();
         }
         catch(Exception e){}
         //2
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
             obj.RunGetVersion();
         }
         catch(Exception e){}
         //3
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl4());
             obj.RunSearchDealer();
         }
         catch(Exception e){}
         //4
         
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl5());
             obj.RunGetAssociatedCustomers();
         }
         catch(Exception e){}
         //5
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl6());
             obj.RunGetSecurityToken();
         }
         catch(Exception e){}
         //6
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl7());
             obj.RunGetCommunicationHistory();
         }
         catch(Exception e){}
         //7
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl8());
             obj.RunGetServiceHistory();
         }
         catch(Exception e){}
         //8
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl9());
             obj.RunCallResolution();
         }
         catch(Exception e){}
         //9
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl10());
             obj.RunCheckAppointment();
         }
         catch(Exception e){}
         //10
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl11());
             obj.RunPing();
         }
         catch(Exception e){}
         //11
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl12());
             obj.RunGetPrimaryContactInfo();
         }
         catch(Exception e){}
         //12
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl13());
             obj.RunGetServicesDue();
         }
         catch(Exception e){}
         //13
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl14());
             obj.RunGetAppointmentSubscribeURL();
         }
         catch(Exception e){}
         //14
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl15());
             obj.RunGetLog();
         }
         catch(Exception e){}
         //15
          try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl16());
             obj.RunCheckAppointmentTime();
         }
         catch(Exception e){}
         //16
         try {
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl17());
             obj.RunGetDealerInfo();
         }
         catch(Exception e){}
         //17
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl6());
         Account a = new Account();
         ApexPages.StandardController sc = new ApexPages.StandardController(a);
         obj = new TESTING_WEBSERVICES(sc);
     }

     //------Mockups-----//
     global class WebServiceMockImpl1 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.Getassociated_dcno_idResponse_element respElement = new nissanoneToOneNnanetComCallcentre.Getassociated_dcno_idResponse_element();
           respElement.Getassociated_dcno_idResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl2 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.SearchCustomerResponse_element respElement = new nissanoneToOneNnanetComCallcentre.SearchCustomerResponse_element();
           respElement.SearchCustomerResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl3 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetVersionResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetVersionResponse_element();
           respElement.GetVersionResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl4 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.SearchDealerResponse_element respElement = new nissanoneToOneNnanetComCallcentre.SearchDealerResponse_element();
           respElement.SearchDealerResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl5 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetAssociatedCustomersResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetAssociatedCustomersResponse_element();
           respElement.GetAssociatedCustomersResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl6 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetSecurityTokenResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetSecurityTokenResponse_element();
           respElement.GetSecurityTokenResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl7 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetCommunicationHistoryResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetCommunicationHistoryResponse_element();
           respElement.GetCommunicationHistoryResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl8 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetServiceHistoryResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetServiceHistoryResponse_element();
           respElement.GetServiceHistoryResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl9 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.CallResolutionResponse_element respElement = new nissanoneToOneNnanetComCallcentre.CallResolutionResponse_element();
           respElement.CallResolutionResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl10 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.CheckAppointmentResponse_element respElement = new nissanoneToOneNnanetComCallcentre.CheckAppointmentResponse_element();
           respElement.CheckAppointmentResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl11 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfoResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfoResponse_element();
           respElement.GetPrimaryContactInfoResult = '';
           response.put('response_x', respElement); 
       }
    }
    global class WebServiceMockImpl12 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetServicesDueResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetServicesDueResponse_element();
           respElement.GetServicesDueResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl13 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element();
           respElement.GetAppointmentSubscribeURLResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl14 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element();
           respElement.GetAppointmentSubscribeURLResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl15 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetLogResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetLogResponse_element();
           respElement.GetLogResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl16 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.CheckAppointmentTimeResponse_element respElement = new nissanoneToOneNnanetComCallcentre.CheckAppointmentTimeResponse_element();
           respElement.CheckAppointmentTimeResult = '';
           response.put('response_x', respElement); 
       }
    }

    global class WebServiceMockImpl17 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           nissanoneToOneNnanetComCallcentre.GetDealerInfoResponse_element respElement = new nissanoneToOneNnanetComCallcentre.GetDealerInfoResponse_element();
           respElement.GetDealerInfoResult = '';
           response.put('response_x', respElement); 
       }
    }

}