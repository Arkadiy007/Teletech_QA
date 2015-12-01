/**********************************************************************
Name: BrochureRequest_Webservices
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Execute Maritz Web Service Calls for Brochure Requests.

Related Page : BrochureRequest_Webservices
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Biswa Ray 01/05/2011 Created
1.1 - Bryan Fry 02/28/2011 Changed to work with real data from a brochure request and
                           added logic/validation.
1.2 - Bryan Fry 04/15/2011 Added error handling and email when web service fails.
1.3 - Yuli Fintescu 05/05/2011 Catch error in Error Log object when web service fails.
***********************************************************************/
public with sharing class BrochureRequest_Webservices {
    public static wwwMaritzComWebservices.SubmitSoap  ss = new wwwMaritzComWebservices.SubmitSoap();
    public boolean isError {get; set;} 
    public string error {get; set;}
    public static Map<String, String> nissanCodes = getNissanCodes();
    public static Map<String, String> infinitiCodes = getInfinitiCodes();
    public static Boolean triggerUpdate = false;
    
    public static final String NISSAN_CAMPAIGN_ID = 			'3327AD61-A560-4918-B148-F9B0E5AA6BBB';
    public static final String NISSAN_RESEND_CAMPAIGN_ID = 		'05B21732-9F34-46F0-A33A-FDAB69C2FAF5';
    public static final String INFINITI_CAMPAIGN_ID = 			'3AC04160-DA86-46A6-AA63-90620E63C6A4';
    public static final String INFINITI_RESEND_CAMPAIGN_ID =	'AD0CA33E-72C0-4F91-9583-0B45E36DDC93';
    public static final String INFINITI_TOE_CAMPAIGN_ID =		'74FBF54E-3904-4C86-B9DE-8AE980B52C9C';
           
    public BrochureRequest_Webservices(ApexPages.StandardController controller){
    }
     
    @future(callout=true)
    public static void callSubmitRecord(Id id) {
		Boolean nissanResult;
		Boolean infinitiResult;
		Boolean infinitiTOEResult;
		String nissanXml;
		String infinitiXml;
		String infinitiTOEXml;
		Boolean error = false;
		String nissanError = '';
		String infinitiError = '';
		String infinitiTOEError = '';
		
		BrochureRequest_Webservices.triggerUpdate = true;

		BrochureRequestData data = new BrochureRequestData(id);    	

		try {
			// Generate and send Nissan Brochure Request XML	
			nissanXml = data.getNissanRequest();
		    System.debug('nissan xml = ' + nissanXml);
			if (nissanXml != '') {
				System.debug('sending nissan xml');
				nissanResult = ss.SubmitRecord(nissanXml, 'genericactivity.xsd');
			}
		} catch (Exception e) {
			nissanResult = false;
			nissanError = e.getMessage();
		}
			
		try {
			// Generate and send Infiniti Brochure Request XML
			infinitiXml = data.getInfinitiRequest();
			System.debug('infiniti xml = ' + infinitiXml);
			if (infinitiXml != '') {
				System.debug('sending infiniti xml');
				infinitiResult = ss.SubmitRecord(infinitiXml, 'genericactivity.xsd');
			}
		} catch (Exception e) {
			infinitiResult = false;
			infinitiError = e.getMessage();
		}
	
		try {
			// Generate and send Infiniti TOE Brochure Request XML
			infinitiTOEXml = data.getInfinitiTOERequest();
			System.debug('infiniti TOE xml = ' + infinitiTOEXml);
			if (infinitiTOEXml != '') {
				System.debug('sending infiniti TOE xml');
				infinitiTOEResult = ss.SubmitRecord(infinitiTOEXml, 'genericactivity.xsd');
			}
		} catch (Exception e) {
			infinitiTOEResult = false;
			infinitiTOEError = e.getMessage();
		}
		
		Brochure_Request__c request = [select id, Processed_Successfully__c from Brochure_Request__c where id = :id];

		// If any of the web service calls failed, send an email with the error encountered.
		if (nissanResult == false || infinitiResult == false || infinitiTOEResult == false) {
			String errXml = buildErrorXml(nissanXml, infinitiXml, infinitiTOEXml, nissanResult, infinitiResult, infinitiTOEResult);
			String errMessage = buildErrorMessage(id, nissanXml, infinitiXml, infinitiTOEXml, nissanResult, infinitiResult, infinitiTOEResult,
			               nissanError, infinitiError, infinitiTOEError, errXml);

			Error_Log__c l = new Error_Log__c(Record_ID__c = id, 
												Record_Type__c = 'Brochure_Request__c', 
												Error_Message__c = errMessage, 
												TimeStamp__c = System.now(), 
												Operation_Name__c = 'Brochure Request Webservices', 
												Source__c='Salesforce', 
												Log_Type__c = 'Error', 
												Log_Level__c = 3,
												XML_Data__c = errXML);
			insert l;
			
			sendErrorEmail(errMessage);
			
			// Set flag to indicate that this Brochure Request was not processed successfully.
			// This will allow an update to the record to attempt to resend the request.
			request.Processed_Successfully__c = false;
		} else {
			// Set flag to indicate that this Brochure Request was processed successfully.
			// This will prevent an update to the record from attempting to resend the request.
			request.Processed_Successfully__c = true;
		}
		
		update request;
     }
     
     private static String buildErrorXml(String nissanXml, String infinitiXml, String infinitiTOEXml,
                                       Boolean nissanResult, Boolean infinitiResult, Boolean infinitiTOEResult) {
		String errXML = (nissanResult != false ? '' : ('Failed Nissan XML = ' + nissanXml));
		errXML = errXML + '\n\n' + (infinitiResult != false ? '' : ('Failed Infiniti XML = ' + infinitiXml));
		errXML = errXML + '\n\n' + (infinitiTOEResult != false ? '' : ('Failed Infiniti TOE XML = ' + infinitiTOEXml));
		return errXML;
     }
     
	// Construct email body and send email
     private static String buildErrorMessage(Id id, String nissanXml, String infinitiXml, String infinitiTOEXml,
                                       Boolean nissanResult, Boolean infinitiResult, Boolean infinitiTOEResult,
                                       String nissanError, String infinitiError, String infinitiTOEError, String errXml) {
		String emailBody = 'An error was encountered in processing a Brochure Request at ' + System.now();
		emailBody = emailBody + ' for id = ' + id + '.\n\nBrochure Request Web Service Calls Made:\nNissan: ';
		emailBody = emailBody + (nissanXml != '' ? (nissanResult == true ? 'Succeeded' : 'Failed') : 'Not Requested') + '\nInfiniti: ';
		emailBody = emailBody + (infinitiXml != '' ? (infinitiResult == true ? 'Succeeded' : 'Failed') : 'Not Requested') + '\nInfiniti TOE: ';
		emailBody = emailBody + (infinitiTOEXml != '' ? (infinitiTOEResult == true ? 'Succeeded\n\n' : 'Failed\n\n') : 'Not Requested\n\n');
		emailBody = emailBody + (nissanError != '' ? ('Nissan Error Message: ' + nissanError + '\n\n') : '');
		emailBody = emailBody + (infinitiError != '' ? ('Infiniti Error Message: ' + infinitiError + '\n\n') : '');
		emailBody = emailBody + (infinitiTOEError != '' ? ('Infiniti TOE Error Message: ' + infinitiTOEError + '\n\n') : '');
		emailBody = emailBody + '\n' + errXml;
		return emailBody;
     }
     
     public static void sendErrorEmail(String errMessage) {
		// Setup email options for email to send
		Messaging.reserveSingleEmailCapacity(1);    
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {System.label.Brochure_Request_Error_Email}; 
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(System.label.Brochure_Request_Error_Email);
		mail.setSenderDisplayName('Salesforce Brochure Request');
		mail.setSubject('Salesforce Brochure Request Error');
		mail.setPlainTextBody(errMessage);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
     
     public static Map<String,String> getNissanCodes() {
     	Map<String,String> codeMap = new Map<String,String>();
     	List<Code__c> codeList = [select description__c, code__c from Code__c where type__c = 'nissan_brochure'];

     	for (Code__c code: codeList) {
     		codeMap.put(code.description__c, code.code__c);
     	}
		
		return codeMap;
     }

     public static Map<String,String> getInfinitiCodes() {
     	Map<String,String> codeMap = new Map<String,String>();
     	List<Code__c> codeList = [select description__c, code__c from Code__c where type__c = 'infiniti_brochure'];

     	for (Code__c code: codeList) {
     		codeMap.put(code.description__c, code.code__c);
     	}
		
		return codeMap;
     }
     
     public static String getNissanCode(String model) {
		return nissanCodes.get(model) == null ? '' : nissanCodes.get(model);
     }

     public static String getInfinitiCode(String model) {
		return infinitiCodes.get(model) == null ? '' : infinitiCodes.get(model);
     }
 
 	public class BrochureRequestData {
		private Boolean resendRequestIndicator {get; set;}
		private String nissanCode1 {get; set;}
		private String nissanCode2 {get; set;}
		private String infinitiCode1 {get; set;}
		private String infinitiCode2 {get; set;}
		private String requestDate {get; set;}
		private String nissanUpdates {get; set;}
		private String nissanEmail {get; set;}
		private String infinitiUpdates {get; set;}
		private String infinitiEmail {get; set;}
		private String salutation {get; set;}
		private String firstName {get; set;}
		private String middleInitial {get; set;}
		private String lastName {get; set;}
		private String street {get; set;}
		private String city {get; set;}
		private String state {get; set;}
		private String zip5 {get; set;}
		private String country {get; set;}
		private String email {get; set;}
		private String homePhone {get; set;}
		private String otherPhone {get; set;}
		private String otherPhoneExtension {get; set;}
		private String mobilePhone {get; set;}
		private String customerId {get; set;}
		private String vin {get; set;}
		private String preferredDealerCode {get; set;}
		private String originatingPhone {get; set;}
		private String brName {get; set;}
		
		public BrochureRequestData(Id id) {
	    	Brochure_Request__c request = [Select id, Account_Name__c, Lead_Name__c, Keep_me_informed_Nissan_Indicator__c,
	     										  Keep_me_informed_Infiniti_Indicator__c, Send_Nissan_Email_Indicator__c,
	     										  Send_Infiniti_Email_Indicator__c, Vehicle_Identification_Number__c,
	     								          Resend_Request_Indicator__c, Vehicle_Product_Name__c, Nissan_Model_1__c,
	     								          Nissan_Model_2__c, Infiniti_Model_1__c, Infiniti_Model_2__c,
	     								          RecordType.Name, Name
	     							   from Brochure_Request__c
	     							   where id =:id limit 1];
       	
			if (request.Account_Name__c != null) {
				fillDataForCustomer(request);
			} else if (request.Lead_Name__c != null){
				fillDataForLead(request);
			}
		}

		public void fillDataForCustomer(Brochure_Request__c request) {
			Account account = [Select a.Preferred_Dealer_Id__c, a.PersonHomePhone, a.PersonOtherPhone, a.PersonMobilePhone, 
			                          a.PersonMailingStreet, a.PersonMailingCity, a.PersonMailingState, a.PersonMailingPostalCode,
			                          a.PersonMailingCountry, a.MiddleName__c, a.PersonEmail, a.Salutation, a.FirstName,
			                          a.LastName, Other_Phone_Extension__c, a.Customer_ID__c
			                   From Account a
			                   where a.Id = :request.Account_Name__c limit 1];
			                   
			preferredDealerCode = '';
			if (account.Preferred_Dealer_Id__c != null) {
				Account preferredDealerAccount = [Select Dealer_Code__c from Account where id=:account.Preferred_Dealer_Id__c];
				preferredDealerCode = preferredDealerAccount.Dealer_Code__c == null ? '' :
				                      preferredDealerAccount.Dealer_Code__c;
			}
			
			Pattern nonNumber = Pattern.compile('\\D');

			resendRequestIndicator = request.Resend_Request_Indicator__c;
			nissanCode1 = getNissanCode(request.Nissan_Model_1__c);
			nissanCode2 = getNissanCode(request.Nissan_Model_2__c);
			infinitiCode1 = getInfinitiCode(request.Infiniti_Model_1__c);
			infinitiCode2 = getInfinitiCode(request.Infiniti_Model_2__c);
	    	requestDate = System.now().format('yyyyMMdd');    	
	    	nissanUpdates = request.Keep_Me_Informed_Nissan_Indicator__c == true ? 'Yes' : 'No';
	    	nissanEmail = request.Send_Nissan_Email_Indicator__c == true ? 'Yes' : 'No';
	    	infinitiUpdates = request.Keep_Me_Informed_Infiniti_Indicator__c == true ? 'Yes' : 'No';
	    	infinitiEmail = request.Send_Infiniti_Email_Indicator__c == true ? 'Yes' : 'No';
	    	salutation = account.Salutation == null ? '' : account.Salutation;
	    	firstName = account.FirstName == null ? '' : account.FirstName;
	    	middleInitial = account.MiddleName__c == null ? '' : account.MiddleName__c.substring(0,1);
	    	lastName = account.LastName == null ? '' : account.LastName;
	    	if (lastName.equals(System.label.DollarSign)) {
	    		lastName = '';
	    	}
	    	street = account.PersonMailingStreet == null ? '' : account.PersonMailingStreet;
	    	city = account.PersonMailingCity == null ? '' : account.PersonMailingCity;
	    	state = account.PersonMailingState == null ? '' : account.PersonMailingState;
	    	zip5 = account.PersonMailingPostalCode == null ? '' : account.PersonMailingPostalCode.substring(0,5);
	    	country = account.PersonMailingCountry == null ? '' : account.PersonMailingCountry;
	    	email = account.PersonEmail == null ? '' : account.PersonEmail;
	    	homePhone = account.PersonHomePhone == null ? '' : nonNumber.matcher(account.PersonHomePhone).replaceAll('');
	    	otherPhone = account.PersonOtherPhone == null ? '' : nonNumber.matcher(account.PersonOtherPhone).replaceAll('');
	    	otherPhoneExtension = account.Other_Phone_Extension__c == null ? '' : account.Other_Phone_Extension__c;
	    	mobilePhone = account.PersonMobilePhone == null ? '' : nonNumber.matcher(account.PersonMobilePhone).replaceAll('');
	    	customerId = account.Customer_ID__c == null ? '' : account.Customer_ID__c;
	    	vin = request.Vehicle_Identification_Number__c == null ? '' : request.Vehicle_Identification_Number__c;
			originatingPhone = getOriginatingPhone();
			brName = request.Name;
		}

		public void fillDataForLead(Brochure_Request__c request) {
			Lead lead = [Select Phone, OtherPhone__c, Street, City, State, PostalCode,
			                    Country, Middle_Name__c, Email, Salutation, FirstName,
			                    LastName, Customer_ID__c
			             From Lead
			             where Id = :request.Lead_Name__c limit 1];
			
			// Pattern matches everything but numbers.
			// We will use it to replace all non-numbers with ''.
			Pattern nonNumber = Pattern.compile('\\D');

			preferredDealerCode = '';
			resendRequestIndicator = request.Resend_Request_Indicator__c;
			nissanCode1 = getNissanCode(request.Nissan_Model_1__c);
			nissanCode2 = getNissanCode(request.Nissan_Model_2__c);
			infinitiCode1 = getInfinitiCode(request.Infiniti_Model_1__c);
			infinitiCode2 = getInfinitiCode(request.Infiniti_Model_2__c);
	    	requestDate = System.now().format('yyyyMMdd');    	
	    	nissanUpdates = request.Keep_Me_Informed_Nissan_Indicator__c == true ? 'Yes' : 'No';
	    	nissanEmail = request.Send_Nissan_Email_Indicator__c == true ? 'Yes' : 'No';
	    	infinitiUpdates = request.Keep_Me_Informed_Infiniti_Indicator__c == true ? 'Yes' : 'No';
	    	infinitiEmail = request.Send_Infiniti_Email_Indicator__c == true ? 'Yes' : 'No';
	    	salutation = lead.Salutation == null ? '' : lead.Salutation;
	    	firstName = lead.FirstName == null ? '' : lead.FirstName;
	    	middleInitial = lead.Middle_Name__c == null ? '' : lead.Middle_Name__c.substring(0,1);
	    	lastName = lead.LastName == null ? '' : lead.LastName;
	    	if (lastName.equals(System.label.DollarSign)) {
	    		lastName = '';
	    	}
	    	street = lead.Street == null ? '' : lead.Street;
	    	city = lead.City == null ? '' : lead.City;
	    	state = lead.State == null ? '' : lead.State;
	    	zip5 = lead.PostalCode == null ? '' : lead.PostalCode.substring(0,5);
	    	country = lead.Country == null ? '' : lead.Country;
	    	email = lead.Email == null ? '' : lead.Email;
	    	homePhone = lead.Phone == null ? '' : nonNumber.matcher(lead.Phone).replaceAll('');
	    	otherPhone = lead.OtherPhone__c == null ? '' : nonNumber.matcher(lead.OtherPhone__c).replaceAll('');
	    	otherPhoneExtension = '';
	    	mobilePhone = '';
	    	customerId = lead.Customer_ID__c == null ? '' : lead.Customer_ID__c;
	    	vin = request.Vehicle_Identification_Number__c == null ? '' : request.Vehicle_Identification_Number__c;
	    	originatingPhone = getOriginatingPhone();
			brName = request.Name;
		}
		
		public String getOriginatingPhone() {
			String phone = '';
	    	Id profileId = UserInfo.getProfileId();
	    	Profile prof = [select name from profile where id = :profileId];

	    	if (prof.Name == 'Agent' || prof.Name == 'Manager' || prof.Name == 'Supervisor') {
	    		phone = System.label.ServiceMarketingOriginatingPhone;
			} else if (prof.Name == 'Agent - DPIC' || prof.Name == 'DPIC User') {
	    		phone = System.label.DPICOriginatingPhone;
	    	} else if (prof.Name == 'CCC User') {
	    		phone = System.label.CCCOriginatingPhone;
	    	} else if (prof.Name == 'LEAF/Telematics User') {
	    		phone = System.label.LEAFOriginatingPhone;
	    	} else {
	    		phone = System.label.DefaultOriginatingPhone;
	    	}
	    	
	    	return phone;
		}

		public String getNissanRequest() {
			String xml = '';
			String nissanCampaignDefinitionId;
			
			if ((nissanCode1 != null && nissanCode1 != '') || 
			    (nissanCode2 != null && nissanCode2 != '')) {
				if (resendRequestIndicator == true) {
					nissanCampaignDefinitionId = NISSAN_RESEND_CAMPAIGN_ID;
				} else {
					nissanCampaignDefinitionId = NISSAN_CAMPAIGN_ID;
				}

				xml = '<ContactActivity>'+ 
	                        '<Request>'+ 
	                            '<CampaignDefinitionId>' + nissanCampaignDefinitionId + '</CampaignDefinitionId>'  + 
	                            '<TransactionMasterId />'+
	                            getContactXML() +  
	                            '<Survey>' + 
	                                '<Section>' +
	                                // This Question node provided contains the ids to indicate the 
	                                // first Nissan model of interest
	                                '<Question Id="837">' + 
	                                	'<Answer Id="">' + nissanCode1 + '</Answer>' + 
	                                '</Question>' + 
	                                // This Question node provided contains the ids to indicate the
	                                // second Nissan model of interest.
	                                '<Question Id="838">' + 
	                                    '<Answer Id="">' + nissanCode2 + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node provided accepts Request Date.
	                                '<Question Id="5945">' + 
	                                    '<Answer Id="">' + requestDate + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node for a uniqueid (leadID) is required
	                                // (this field doesn’t have to be unique but it is recommended for tracking purposes).
	                                '<Question Id="6856">' + 
	                                    '<Answer Id="">' + brName + '</Answer>' + 
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Updates
	                                '<Question Id="11719">' + 
	                                    '<Answer Id="">' + nissanUpdates + '</Answer>' +  
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Email
	                                '<Question Id="11721">' + 
	                                    '<Answer Id="">' + nissanEmail + '</Answer>' + 
	                                '</Question>' + 
                                    '<Question Id="11740">' +
                                        '<Answer Id="">' + originatingPhone + '</Answer>' +
                                    '</Question>' +
	                                '</Section>' + 
	                            '</Survey>' + 
	                        '</Request>' + 
	                        '<Response>' + 
	                            '<TransactionResult />' +  
	                            '<Message />' +  
	                        '</Response>' + 
	                    '</ContactActivity>';				
			}
			
			return xml;
		}
		
		public String getInfinitiRequest() {
			String xml = '';
			String infinitiCampaignDefinitionId;
			
			String infReqCode1 = infinitiCode1;
			String infReqCode2 = infinitiCode2;
				
			if ((infReqCode1 != null && infReqCode1 != '' && infReqCode1 != getInfinitiCode(system.label.Roadside_Assistance_Card)) ||
			    (infReqCode2 != null && infReqCode2 != '' && infReqCode2 != getInfinitiCode(system.label.Roadside_Assistance_Card))) {
				if (resendRequestIndicator == true) {
					infinitiCampaignDefinitionId = INFINITI_RESEND_CAMPAIGN_ID;
				} else {
					infinitiCampaignDefinitionId = INFINITI_CAMPAIGN_ID;
				}
				
				if (infReqCode1 == getInfinitiCode(system.label.Roadside_Assistance_Card)) {
					infReqCode1 = infReqCode2;
					infReqCode2 = '';
				} else if (infReqCode2 == getInfinitiCode(system.label.Roadside_Assistance_Card)) {
					infReqCode2 = '';
				}
				
				xml = '<ContactActivity>'+ 
	                        '<Request>'+ 
	                            '<CampaignDefinitionId>' + infinitiCampaignDefinitionId + '</CampaignDefinitionId>'  + 
	                            '<TransactionMasterId />'+  
	                            getContactXML() + 
	                            '<Survey>' + 
	                                '<Section>' +
	                                // This Question node provided contains the ids to indicate the 
	                                // first Infiniti model of interest
	                                '<Question Id="839">' + 
	                                	'<Answer Id="">' + infReqCode1 + '</Answer>' + 
	                                '</Question>' + 
	                                // This Question node provided contains the ids to indicate the
	                                // second Infiniti model of interest.
	                                '<Question Id="840">' + 
	                                    '<Answer Id="">' + infReqCode2 + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node provided accepts Request Date.
	                                '<Question Id="5945">' + 
	                                    '<Answer Id="">' + requestDate + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node for a uniqueid (leadID) is required
	                                // (this field doesn’t have to be unique but it is recommended for tracking purposes).
	                                '<Question Id="6856">' + 
	                                    '<Answer Id="">' + brName + '</Answer>' + 
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Updates
	                                '<Question Id="11720">' + 
	                                    '<Answer Id="">' + infinitiUpdates + '</Answer>' +  
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Email
	                                '<Question Id="11722">' + 
	                                    '<Answer Id="">' + infinitiEmail + '</Answer>' + 
	                                '</Question>' + 
                                    '<Question Id="11740">' +
                                        '<Answer Id="">' + originatingPhone + '</Answer>' +
                                    '</Question>' +
	                                '</Section>' + 
	                            '</Survey>' + 
	                        '</Request>' + 
	                        '<Response>' + 
	                            '<TransactionResult />' +  
	                            '<Message />' +  
	                        '</Response>' + 
	                    '</ContactActivity>';
			}
			
			return xml;
		}

		public String getInfinitiTOERequest() {
			String xml = '';
			String infinitiCampaignDefinitionId = INFINITI_TOE_CAMPAIGN_ID;
				
			if ((infinitiCode1 != null && infinitiCode1 != '' && infinitiCode1 == getInfinitiCode(system.label.Roadside_Assistance_Card)) ||
			    (infinitiCode2 != null && infinitiCode2 != '' && infinitiCode2 == getInfinitiCode(system.label.Roadside_Assistance_Card))) {
				
				xml = '<ContactActivity>'+ 
	                        '<Request>'+ 
	                            '<CampaignDefinitionId>' + infinitiCampaignDefinitionId + '</CampaignDefinitionId>'  + 
	                            '<TransactionMasterId />'+  
	                            getContactXML() + 
	                            '<Survey>' + 
	                                '<Section>' +
	                                // This Question node provided contains the ids to indicate the 
	                                // first Infiniti model of interest
	                                '<Question Id="839">' + 
	                                	'<Answer Id="">' + getInfinitiCode(system.label.Roadside_Assistance_Card) + '</Answer>' + 
	                                '</Question>' + 
	                                // This Question node provided contains the ids to indicate the
	                                // second Infiniti model of interest.
	                                '<Question Id="840">' + 
	                                    '<Answer Id="">' + '' + '</Answer>' +  
	                                '</Question>' +
	                                // VIN for the TOE - Roadside Assistance Card
	                                '<Question Id="778">' + 
	                                	'<Answer Id="">' + vin + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node provided accepts Request Date.
	                                '<Question Id="5945">' + 
	                                    '<Answer Id="">' + requestDate + '</Answer>' +  
	                                '</Question>' +
	                                // This free text Question node for a uniqueid (leadID) is required
	                                // (this field doesn’t have to be unique but it is recommended for tracking purposes).
	                                '<Question Id="6856">' + 
	                                    '<Answer Id="">' + brName + '</Answer>' + 
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Updates
	                                '<Question Id="11720">' + 
	                                    '<Answer Id="">' + infinitiUpdates + '</Answer>' +  
	                                '</Question>' +
	                                // This Question node provided captures that the customer Opts-in for Nissan Email
	                                '<Question Id="11722">' + 
	                                    '<Answer Id="">' + infinitiEmail + '</Answer>' + 
	                                '</Question>' + 
                                    '<Question Id="11740">' +
                                        '<Answer Id="">' + originatingPhone + '</Answer>' +
                                    '</Question>' +
	                                '</Section>' + 
	                            '</Survey>' + 
	                        '</Request>' + 
	                        '<Response>' + 
	                            '<TransactionResult />' +  
	                            '<Message />' +  
	                        '</Response>' + 
	                    '</ContactActivity>';
			}
			
			return xml;
		}

	 	public String getContactXML() {
	 		String xml =  '<Contact>' + 
	                    	'<Title>' + salutation + '</Title>' + 
	                    	'<Prefix />' +  
	                    	'<FirstName>' + firstName + '</FirstName>' + 
	                    	'<MiddleInitial>' + middleInitial + '</MiddleInitial>' +
	                    	'<LastName>' + lastName + '</LastName>' + 
	                    	'<Suffix></Suffix>' + 
	                    	'<Address>'  + 
	                            '<Line1>' + street+'</Line1> ' + 
	                            '<Line2/>'+  
	                            '<Line3/>' +  
	                            '<City>' + city + '</City>' +  
	                            '<State>' + state + '</State>' +  
	                            '<Zip5>' + zip5 + '</Zip5>' +
	                            '<Zip4/>' + 
	                            '<County/>' + 
	                            '<Country>' + country + '</Country>' +  
	                        '</Address>' +
	                        '<EmailAddress>' + email + '</EmailAddress>' +    
	                        '<HomePhone>' + homePhone + '</HomePhone>'+   
	                        '<WorkPhone>' + otherPhone + '</WorkPhone>'+  
	                        '<Extension>' + otherPhoneExtension + '</Extension>' +
	                        '<CellPhone>' + mobilePhone + '</CellPhone>' +
	                        '<FaxPhone />' + 
	                        '<DealerCode>' + preferredDealerCode + '</DealerCode>' + 
	                        '<OrganizationalName/>' +  
	                      '</Contact>';
	    	return xml;
	 	}
 	}
}