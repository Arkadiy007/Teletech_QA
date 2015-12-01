@isTest
private global class nissanoneToOneNnanetComCallcentre_Test {
    
private static nissanoneToOneNnanetComCallcentre obj = new nissanoneToOneNnanetComCallcentre();
private static nissanoneToOneNnanetComCallcentre.GetVersion_element obj1 = new nissanoneToOneNnanetComCallcentre.GetVersion_element();
private static nissanoneToOneNnanetComCallcentre.SearchCustomer_element obj2 = new nissanoneToOneNnanetComCallcentre.SearchCustomer_element();
private static nissanoneToOneNnanetComCallcentre.CallResolution_element  obj3 = new nissanoneToOneNnanetComCallcentre.CallResolution_element();
private static nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURL_element  obj4 = new nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURL_element ();
private static nissanoneToOneNnanetComCallcentre.GetServicesDueResponse_element  obj5 = new nissanoneToOneNnanetComCallcentre.GetServicesDueResponse_element ();
private static nissanoneToOneNnanetComCallcentre.CheckAppointmentTime_element obj6 = new nissanoneToOneNnanetComCallcentre.CheckAppointmentTime_element();
private static nissanoneToOneNnanetComCallcentre.CallCentreSoap  obj7 = new nissanoneToOneNnanetComCallcentre.CallCentreSoap(); 
private static nissanoneToOneNnanetComCallcentre.CheckAppointmentResponse_element  obj8 = new nissanoneToOneNnanetComCallcentre.CheckAppointmentResponse_element();
private static nissanoneToOneNnanetComCallcentre.Ping_element  obj9 = new nissanoneToOneNnanetComCallcentre.Ping_element();
private static nissanoneToOneNnanetComCallcentre.CheckAppointmentTimeResponse_element   obj10 = new nissanoneToOneNnanetComCallcentre.CheckAppointmentTimeResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfo_element   obj11 = new nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfo_element();
private static nissanoneToOneNnanetComCallcentre.CheckAppointment_element   obj12 = new nissanoneToOneNnanetComCallcentre.CheckAppointment_element();
private static nissanoneToOneNnanetComCallcentre.GetAssociatedCustomers_element  obj13 = new nissanoneToOneNnanetComCallcentre.GetAssociatedCustomers_element();
private static nissanoneToOneNnanetComCallcentre.GetSecurityToken_element  obj14 = new nissanoneToOneNnanetComCallcentre.GetSecurityToken_element();
private static nissanoneToOneNnanetComCallcentre.GetCommunicationHistory_element  obj15 = new nissanoneToOneNnanetComCallcentre.GetCommunicationHistory_element();
private static nissanoneToOneNnanetComCallcentre.SearchCustomerResponse_element  obj16 = new nissanoneToOneNnanetComCallcentre.SearchCustomerResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetLog_element  obj17 = new nissanoneToOneNnanetComCallcentre.GetLog_element();
private static nissanoneToOneNnanetComCallcentre.GetAssociatedCustomersResponse_element  obj18 = new nissanoneToOneNnanetComCallcentre.GetAssociatedCustomersResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetLogResponse_element  obj19 = new nissanoneToOneNnanetComCallcentre.GetLogResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfoResponse_element   obj20 = new nissanoneToOneNnanetComCallcentre.GetPrimaryContactInfoResponse_element();
private static nissanoneToOneNnanetComCallcentre.Getassociated_dcno_id_element  obj21 = new nissanoneToOneNnanetComCallcentre.Getassociated_dcno_id_element();
private static nissanoneToOneNnanetComCallcentre.GetServiceHistory_element  obj22 = new nissanoneToOneNnanetComCallcentre.GetServiceHistory_element();
private static nissanoneToOneNnanetComCallcentre.GetSecurityTokenResponse_element   obj23 = new nissanoneToOneNnanetComCallcentre.GetSecurityTokenResponse_element();
private static nissanoneToOneNnanetComCallcentre.PingResponse_element  obj24 = new nissanoneToOneNnanetComCallcentre.PingResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element  obj25 = new nissanoneToOneNnanetComCallcentre.GetAppointmentSubscribeURLResponse_element();
private static nissanoneToOneNnanetComCallcentre.Getassociated_dcno_idResponse_element  obj26 = new nissanoneToOneNnanetComCallcentre.Getassociated_dcno_idResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetServiceHistoryResponse_element   obj27 = new nissanoneToOneNnanetComCallcentre.GetServiceHistoryResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetCommunicationHistoryResponse_element   obj28 = new nissanoneToOneNnanetComCallcentre.GetCommunicationHistoryResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetDealerInfoResponse_element   obj29 = new nissanoneToOneNnanetComCallcentre.GetDealerInfoResponse_element();
private static nissanoneToOneNnanetComCallcentre.SearchDealerResponse_element   obj30 = new nissanoneToOneNnanetComCallcentre.SearchDealerResponse_element();
private static nissanoneToOneNnanetComCallcentre.CallResolutionResponse_element   obj31 = new nissanoneToOneNnanetComCallcentre.CallResolutionResponse_element();
private static nissanoneToOneNnanetComCallcentre.GetVersionResponse_element   obj32 = new nissanoneToOneNnanetComCallcentre.GetVersionResponse_element();

    static testmethod void testMethod1() {
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl17());
    obj7.GetDealerInfo('234','adagag');
    }
    static testmethod void Method2(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl16());
    obj7.CheckAppointmentTime ('hadaf','adagagdd');
    }
    static testmethod void Method3(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl15());
    obj7.GetLog('adagagdd');
    }
	//
    static testmethod void Method4(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl12());
    obj7.GetServicesDue ('12552','adagagdd');
    }
	//
    static testmethod void Method5(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl11());
    obj7.GetPrimaryContactInfo (464661,'adagagdd');
    }
	//
    static testmethod void Method6(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl0());
    obj7.Ping();
    }
	//
    static testmethod void Method7(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl01());
    obj7.CheckAppointment('hadafaf','adagagddww');
    }
	//
    static testmethod void Method8(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl9());
    obj7.CallResolution('hadafafaa','adagagddwwee');
    }
	//
    static testmethod void Method9(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl8());
    obj7.GetServiceHistory(4546,'adagagdd');
    }
	//
    static testmethod void Method10(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl7());
    obj7.GetCommunicationHistory(125516512,'adagagdde');
    }
	//
    static testmethod void Method11(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl5());
    obj7.GetAssociatedCustomers(12455,'hi123');
    }
	//
    static testmethod void Method12(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl4());
    obj7.SearchDealer('hadafafaa@Wassdf','ahjahkda');
    }
	//
    static testmethod void Method13(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
    obj7.GetVersion();
    }
	//
    static testmethod void Method14(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
    obj7.SearchCustomer('hadafafaaasaWass','jlkajlaf');
    }
	//
    static testmethod void Method15(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
    obj7.Getassociated_dcno_id(134662,'jlkajlaf');
    }
	//
    static testmethod void Method16(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl14());
    obj7.GetAppointmentSubscribeURL('134662',12455,54661,'hihiianinaif');
    }
	//
    static testmethod void Method17(){
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl6());
    obj7.GetSecurityToken('a@zen','12afa');
    }
    
	//-----Mockups-------//
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

	global class WebServiceMockImpl0 implements WebServiceMock {
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
		   nissanoneToOneNnanetComCallcentre.PingResponse_element respElement = new nissanoneToOneNnanetComCallcentre.PingResponse_element();
		   respElement.PingResult = true;
		   response.put('response_x', respElement); 
	   }
	}

	global class WebServiceMockImpl01 implements WebServiceMock {
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
}