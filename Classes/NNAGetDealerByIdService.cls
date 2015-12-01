/**********************************************************************
  Name: NNAGetDealerByIdService
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Webservice, that makes callouts to DealerById Nissan Service to get Dealer Info

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 06/12/2015 Created
 ***********************************************************************/
global class NNAGetDealerByIdService { 
	global static String getDealerInfoById(String params) {
		if(Test.isRunningTest()){
			if(params.contains('01')){
				return 'Test <isDealerContactable>true</isDealerContactable> DealerInternetCertified <isDealerActive>true</isDealerActive>'; 
			}
			else{
				return 'Test';
			}
		}
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		
		req.setEndpoint(Label.DealerByIdService + '?' + params);
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		req.setMethod('GET');

		// Send the request, and return a response
		HttpResponse res = h.send(req);
		return res.getBody();
	}

	global static Boolean isDealerContactable(String dealerId){
		String params = 'dealerId=' + dealerId + '&format=xml';
		String result = getDealerInfoById(params);
		if(result.contains('<isDealerContactable>true</isDealerContactable>')){
			if(result.contains('<isDealerActive>true</isDealerActive>')){
				return true;
			}
			else{ 
				return false;
			}		
		}
		else{
			return false;
		}
	}
}