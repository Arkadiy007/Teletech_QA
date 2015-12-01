/**********************************************************************
Name: HerokuApi
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Heroku application api helper class used to call archive-db application hosted on Heroku.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
public class HerokuApi {

	/*
	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String GetRecords(){
		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');

		req.setEndpoint('https://archive-db.herokuapp.com/getprevioussolutions');

		HTTPResponse res = http.send(req);
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}
	*/

	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String GetCaseRecords(Map<String, Object> params){
		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');


		String body = JSON.serialize(params);
		req.setBody(body);
		req.setEndpoint('https://archive-db.herokuapp.com/getprevioussolutions');

		HTTPResponse res = http.send(req);
		System.debug(res);
		System.debug(res.getBody());
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}

	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String CreateRecords(Map<String, Object> params){
		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');


		String body = JSON.serialize(params);
		req.setBody(body);
		req.setEndpoint('https://archive-db.herokuapp.com/createcase');

		HTTPResponse res = http.send(req);
		System.debug(res);
		System.debug(res.getBody());
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}

	// Helper method for string base64 encoding
	private static String Base64Encode(String valueToBeEncrypted){
		Blob encodedBlob = Blob.valueOf(valueToBeEncrypted);
		return EncodingUtil.base64Encode(encodedBlob);
	}
}