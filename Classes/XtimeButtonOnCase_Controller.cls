public without sharing class XtimeButtonOnCase_Controller {
	public String xtimeLink { get; set; }
	public XtimeButtonOnCase_Controller() {
		String dealerId = ApexPages.currentPage().getParameters().get('servDealer');
		String accountId = ApexPages.currentPage().getParameters().get('account');
		String caseId = ApexPages.currentPage().getParameters().get('case');
		Xtimesettings__c settings = Xtimesettings__c.getOrgDefaults();
		if (!String.isBlank(dealerId)) {
			Account dealer;
			if (!String.isBlank(dealerId)) {
				dealer = [SELECT ID, Dealer_Attributes_Text__c, Dealer_Code__c, Dealer_Inactive_Indicator__c, BillingCountry, Make_Name__c from Account where id = :dealerId];
			}
			if (!dealer.Dealer_Inactive_Indicator__c) {
				if (!String.isBlank(dealer.Dealer_Attributes_Text__c) && dealer.Dealer_Attributes_Text__c.containsIgnoreCase('x') && (dealer.BillingCountry == null || dealer.BillingCountry != 'Canada')) {
					if (!String.isBlank(accountId)) {
						TMS_Webservices_Utility.setServiceAccess(System.label.TMS_Endpoint, System.label.username, System.label.password);
						//List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURL(dealer.Dealer_Code__c, '11111111');
						//xtimeLink = records[0].value;
						xtimeLink = 'https://loginptr1.xtime.com/?cc=70001&ci=2463&d=&f=true&mi=3047&pls=true&sab=&act=ma';
						//xtimeLink = 'https://login.xtime.com/xwssso/businesslogin/?cc=70001&ci=3101&d=20160114&di=&f=true&fn=Dale&ln=Rider&mi=3047&p=K8UX82B9&pls=true&pn=7813969050&sab=&u=nnauat1&vin=JN1BV7AP0EM672660';

						PageReference pageref = new PageReference(xtimeLink);

						if (settings != null) {
							pageref.getParameters().put('ci', settings.ci__c);
						}
						String validationErrors = '';
						if (!String.isBlank(caseId)) {
							
							if (settings != null) {
								String query = 'select id, ';
								if (settings.d_url_parameter__c != null) {
									query += settings.d_url_parameter__c + ', ';
								}
								if (settings.ln_url_parameter__c != null) {
									query += settings.ln_url_parameter__c + ', ';
								}
								if (settings.fn_url_parameter__c != null) {
									query += settings.fn_url_parameter__c + ', ';
								}
								if (settings.pn_url_parameter__c != null) {
									query += settings.pn_url_parameter__c + ', ';
								}
								if (settings.cc_url_parameter__c != null) {
									query += settings.cc_url_parameter__c + ', ';
								}
								if (settings.vin_url_parameter__c != null) {
									query += settings.vin_url_parameter__c + ', ';
								}
								if (settings.mi_url_parameter__c != null) {
									query += settings.mi_url_parameter__c + ', AccountID, Servicing_Dealer__c';
								}
								query += ' from case where id = :caseId';
								Case c = Database.query(query);
								if (c.AccountId == null && settings.Require_VIN_Acc_Name_Dealer__c) {
									validationErrors += settings.Account_is_empty_message__c;
								}
								if (settings.d_url_parameter__c != null && c.get(settings.d_url_parameter__c) != null) {
									Datetime appoitmentDate = (Datetime) c.get(settings.d_url_parameter__c);
									String appDate = String.valueOf(appoitmentDate.year()) + String.valueOf(appoitmentDate.month()) + String.valueOf(appoitmentDate.day());
									pageref.getParameters().put('d', appDate);
								}
								if (settings.ln_url_parameter__c != null && c.AccountId != null && c.getSobject(settings.ln_url_parameter__c.split('\\.')[0]).get(settings.ln_url_parameter__c.split('\\.')[1]) != null) {
									pageref.getParameters().put('ln', (String)(c.getSobject(settings.ln_url_parameter__c.split('\\.')[0]).get(settings.ln_url_parameter__c.split('\\.')[1])));
								}
								if (settings.fn_url_parameter__c != null && c.AccountId != null && c.getSobject(settings.fn_url_parameter__c.split('\\.')[0]).get(settings.fn_url_parameter__c.split('\\.')[1]) != null) {
									pageref.getParameters().put('fn', String.valueOf(c.getSobject(settings.fn_url_parameter__c.split('\\.')[0]).get(settings.fn_url_parameter__c.split('\\.')[1])));
								}
								if (settings.pn_url_parameter__c != null && c.AccountId != null && c.getSobject(settings.pn_url_parameter__c.split('\\.')[0]).get(settings.pn_url_parameter__c.split('\\.')[1])  != null) {
									pageref.getParameters().put('pn', String.valueOf(c.getSobject(settings.pn_url_parameter__c.split('\\.')[0]).get(settings.pn_url_parameter__c.split('\\.')[1]) ));
								}
								if (settings.cc_url_parameter__c != null && c.getSobject(settings.cc_url_parameter__c.split('\\.')[0]).get(settings.cc_url_parameter__c.split('\\.')[1])  != null) {
									pageref.getParameters().put('cc', String.valueOf(c.getSobject(settings.cc_url_parameter__c.split('\\.')[0]).get(settings.cc_url_parameter__c.split('\\.')[1]) ));
									//pageref.getParameters().put('w', String.valueOf(c.getSobject(settings.cc_url_parameter__c.split('\\.')[0]).get(settings.cc_url_parameter__c.split('\\.')[1]) ));

			
								} else if (settings.Require_VIN_Acc_Name_Dealer__c) {
									validationErrors += ' ' + settings.Dealer_not_populated_message__c;
								}
								if (settings.vin_url_parameter__c != null && c.getSobject(settings.vin_url_parameter__c.split('\\.')[0]).get(settings.vin_url_parameter__c.split('\\.')[1])  != null) {
									pageref.getParameters().put('vin', String.valueOf(c.getSobject(settings.vin_url_parameter__c.split('\\.')[0]).get(settings.vin_url_parameter__c.split('\\.')[1])  ));
								} else if (settings.Require_VIN_Acc_Name_Dealer__c) {
									validationErrors += ' ' + settings.Vin_cannot_be_empty__c;
								}
								if (settings.mi_url_parameter__c != null && c.getSobject(settings.mi_url_parameter__c.split('\\.')[0]).get(settings.mi_url_parameter__c.split('\\.')[1])   != null) {
									pageref.getParameters().put('mi', String.valueOf(c.getSobject(settings.mi_url_parameter__c.split('\\.')[0]).get(settings.mi_url_parameter__c.split('\\.')[1]) ));
								}
							} /*else {
							   String query = 'Select id, Confirmed_Appointment_Date__c from case where id = :caseId';
							   Case c = Database.query(query);
							   if (c.Confirmed_Appointment_Date__c != null) {
							   String appDate = String.valueOf(c.Confirmed_Appointment_Date__c.year()) + String.valueOf(c.Confirmed_Appointment_Date__c.month()) + String.valueOf(c.Confirmed_Appointment_Date__c.day());
							   pageref.getParameters().put('d', appDate);
							   }
							   https://c.cs16.visual.force.com/apex/apex/XtimeButtonOnCase?dealer={!Case.DealerId__c}&account={!Case.AccountId}&vehicle={!Case.Vehicle_NameId__c}&servDealer={!Case.Servicing_DealerId__c}&case={!Case.Id}
							   }*/
						}
						/*if (settings != null && settings.ln_url_parameter__c != null && settings.ln_url_parameter__c.contains(':')) {
						  String query = 'Select id, ' + settings.ln_url_parameter__c.split(':') [1] + ', ' + settings.fn_url_parameter__c.split(':') [1] + ', ' + settings.pn_url_parameter__c.split(':') [1] + ' from Account where id = :accountId';
						  Account persAcc = Database.query(query);
						  if (!String.isBlank(String.valueOf(persAcc.get(settings.ln_url_parameter__c.split(':') [1])))) {
						  pageref.getParameters().put('ln', String.valueOf(persAcc.get(settings.ln_url_parameter__c.split(':') [1])));
						  pageref.getParameters().put('fn', String.valueOf(persAcc.get(settings.fn_url_parameter__c.split(':') [1])));
						  pageref.getParameters().put('pn', String.valueOf(persAcc.get(settings.pn_url_parameter__c.split(':') [1])));
						  //persData = '&ln=' + persAcc.lastname + '&fn=' + persAcc.firstName + '&pn=' + persAcc.PersonHomePhone;
						  }
						  } else {
						  //pageref.getParameters().put('w', 'inf'+dealer.Dealer_Code__c);
						  Account persAcc = [SELECT ID, lastname, firstname, PersonHomePhone from Account where id = :accountId];
						  //string persData = ''; 
						  if (!String.isBlank(persAcc.lastname)) {
						  pageref.getParameters().put('ln', persAcc.lastname);
						  pageref.getParameters().put('fn', persAcc.firstname);
						  pageref.getParameters().put('pn', persAcc.PersonHomePhone);
						  //persData = '&ln=' + persAcc.lastname + '&fn=' + persAcc.firstName + '&pn=' + persAcc.PersonHomePhone;
						  }
						  }
						  pageref.getParameters().put('cc', dealer.Dealer_Code__c);
						  //pageref.getParameters().put('cc', '08064'); 
						  pageref.getParameters().put('di', '');
						  string vehicleId = ApexPages.currentPage().getParameters().get('vehicle');

						  if (!String.isBlank(vehicleId)) {
						  Vehicle__c vehicleItem = [select id, Vehicle_identification_Number__c, Latest_Recorded_Mileage_Number__c from Vehicle__c where id = :vehicleId limit 1];

						  pageref.getParameters().put('vin', vehicleItem.Vehicle_identification_Number__c);
						  //persData = persData + '&vin=' + persAcc.lastname;
						  pageref.getParameters().put('mi', String.valueOf(vehicleItem.Latest_Recorded_Mileage_Number__c));
						  } else {
						  pageref.getParameters().put('vin', '');
						  pageref.getParameters().put('mi', '');
						  }*/
						//pageref.getParameters().put('data', encryptData(persData));
						if (String.isBlank(validationErrors)) {
							xtimeLink = pageref.getUrl();
							System.debug('***check xtime ' + xtimeLink);
						}
						else {
							xtimeLink = validationErrors;
						}

					} else {
						if (settings != null) {
							xtimeLink = settings.Account_is_empty_message__c;
						}
						else {
							xtimeLink = 'Account is empty.';
						}
					}

				} else {
					if (settings != null) {
						xtimeLink = settings.Dealer_not_enrolled_message__c;
					}
					else {
						xtimeLink = 'Dealer is not enrolled in XTime.';
					}
				}
			} else {
				if (settings != null) {
					xtimeLink = settings.Dealer_inactive_message__c;
				}
				else {
					xtimeLink = 'Dealer is inactive.';
				}
			}
		}
		else {
			if (settings != null) {
				xtimeLink = settings.Dealer_not_populated_message__c;
			}
			else {
				xtimeLink = 'Dealer is not populated.';
			}
		}

	}

	/*private string encryptData(string parameters) {
	  String encoded = EncodingUtil.urlEncode(parameters, 'UTF-8');
	  //String encoded = EncodingUtil.urlEncode('Test', 'UTF-8');
	  System.debug('           ****encoded ' + encoded);
	  Blob data = blob.valueOf('Test');
	  System.debug('           ****data ' + data);
	  //Blob cryptoKey = Blob.valueOf('MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD2epAM8tDdxgEjUZTlvCKikae6KjPxlNqdDmXnKHBo0+TOLKbgxLR0IzOozrC8A57rvadCLDm/1oJJFfYzehTVPhJZJ4tFsMfh0JMWxrLVwBTO3y/UiX0wk4CECB8TeUhlv/W52ZsdJzTaysdEtHbJN07olgpPs8tnF9YqspI/mQIDAQAB');
	  Blob cryptoKey = Crypto.generateAesKey(256);

	  System.debug('           ****cryptoKey ' + cryptoKey);
	  Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
	  System.debug('           ****encryptedData ' + encryptedData);
	  // String decryptedData = EncodingUtil.base64Encode(Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData));
	  //	 System.debug('       ****decryptedData ' + decryptedData);
	  String toReturn = EncodingUtil.base64Encode(encryptedData);

	  System.debug('           ****toReturn ' + toReturn);
	  /                        *Blob afterblob = EncodingUtil.base64Decode(toReturn);
	  System.debug('           ****afterblob ' + afterblob);
	  System.debug('           ***decode ' + afterblob.toString());*/
	//return toReturn;
	//	}

	public PageReference ifSuccess() {
		if (xtimeLink.startsWith('https')) {
			PageReference pageref = new PageReference(xtimeLink);
			pageref.setRedirect(true);
			return pageref;
		}

		return null;
	}
}