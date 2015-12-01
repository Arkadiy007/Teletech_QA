/**********************************************************************
  Name:Stage_FF_Hot_Alert_Before
  Copyright � notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger creates new Case, whenever new record created for Stage FF Hot Alerts object
  ======================================================
  History:
 
  VERSION AUTHOR DATE DETAIL 
  1.0 - Vlad Martynenko 01/09/2015 Created
  1.1 - Vlad Martynenko 01/29/2015 Updated Description field and Status field according to Jesica's comments
 ***********************************************************************/
trigger Stage_FF_Hot_Alert_Before on Stage_FF_Hot_Alerts__c(before insert) {
	List<Error_Log__c> errors = new List<Error_Log__c> ();
	List<Case> QCHotAlertCases = new List<Case> ();
	List<String> customerIds = new List<String> ();
	List<String> vins = new List<String> ();
	List<String> dealerCodes = new List<String> ();
	List<String> agentIds = new List<String> ();

	for (Stage_FF_Hot_Alerts__c alert : Trigger.New) {
		if (alert.ContactId__c != null && alert.ContactId__c != '') {
			customerIds.add(alert.ContactId__c);
		}

		if (alert.VIN__c != null && alert.VIN__c != '') {
			vins.add(alert.VIN__c);
		}

		if (alert.DealerCode__c != null && alert.DealerCode__c != '') {
			dealerCodes.add(alert.DealerCode__c);
		}

		if (alert.AgentID__c != null && alert.AgentID__c != '') {
			agentIds.add(alert.AgentID__c);
		}
	}

	List<Account> customers = [Select Id, PersonContactId, Customer_ID__c FROM Account WHERE Customer_ID__c in :customerIds];
	List<Account> dealers = [Select Id, Dealer_Code__c, RCAS__c FROM Account WHERE Dealer_Code__c in :dealerCodes];
	List<Vehicle__c> vehicles = [Select Id, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :vins];
	List<User> owners = [Select Id, Alias FROM User WHERE Alias in :agentIds];

	List<RecordType> t5RecordType = [Select Id, Name from RecordType WHERE Name = :'T5'];
	List<RecordType> salesRecordType = [Select Id, Name from RecordType WHERE Name = :'Sales & Service Record Type'];
	List<RecordType> dtuRecordType = [Select Id, Name from RecordType WHERE Name = :'DTU'];
	List<RecordType> leadSurveyRecordType = [Select Id, Name from RecordType WHERE Name = :'Lead Survey'];

	List<Group> t5Group = [select Id, Name from Group where Name = :'T5 Case Queue' and Type = 'Queue'];
	List<Group> cccGroup = [select Id, Name from Group where Name = :'CCC Campaign Queue' and Type = 'Queue'];
	List<Group> dtuGroup = [select Id, Name from Group where Name = :'DTU Queue' and Type = 'Queue'];
	List<Group> oneminuteGroup = [select Id, Name from Group where Name = :'OneMinute Survey Queue' and Type = 'Queue'];
	List<Group> nissanOmfGroup = [select Id, Name from Group where Name = :'Nissan OMF Queue' and Type = 'Queue'];
	List<Group> mccLeadHotAlertGroup = [select Id, Name from Group where Name = :'MCC Lead Hot Alert' and Type = 'Queue'];

	Welcome_Calls__c welcomeCallsSetting = Welcome_Calls__c.getOrgDefaults();
	if (welcomeCallsSetting == null || welcomeCallsSetting.Description__c == null || welcomeCallsSetting.Subject_no_email__c == null ||
	    welcomeCallsSetting.Subject_with_email__c == null || welcomeCallsSetting.Purchase_Date__c == null || welcomeCallsSetting.Close_Cases__c == null ||
	    welcomeCallsSetting.Create_Cases__c == null || welcomeCallsSetting.Purchase_End_Date__c == null || welcomeCallsSetting.Make__c == null ||
	    welcomeCallsSetting.Model_Line__c == null || welcomeCallsSetting.Model_Year__c == null || welcomeCallsSetting.Ignored_Sale_Type__c == null || welcomeCallsSetting.Subject_from_Hot_Alert__c == null) {

		if (welcomeCallsSetting == null) {
			welcomeCallsSetting = new Welcome_Calls__c();
		}
		welcomeCallsSetting.Description__c = 'Welcome Call';
		welcomeCallsSetting.Subject_no_email__c = 'Revana SSI Welcome Call -  without Email';
		welcomeCallsSetting.Subject_with_email__c = 'Revana SSI Welcome Call - with Email';
		welcomeCallsSetting.Subject_from_Hot_Alert__c = 'Revana SSI Welcome Call';
		welcomeCallsSetting.Purchase_Date__c = Date.newInstance(2015, 4, 1);
		welcomeCallsSetting.Purchase_End_Date__c = Date.newInstance(2015, 5, 15);
		welcomeCallsSetting.Close_Cases__c = true;
		welcomeCallsSetting.Create_Cases__c = true;
		welcomeCallsSetting.Make__c = 'Nissan';
		welcomeCallsSetting.Model_Line__c = 'Altima,Murano,Pathfinder,Versa Sedan,Rogue,Sentra';
		welcomeCallsSetting.Model_Year__c = '2015';
		welcomeCallsSetting.Ignored_Sale_Type__c = 'Service Loaner';
		upsert welcomeCallsSetting;
		welcomeCallsSetting = Welcome_Calls__c.getOrgDefaults();
	}
	//cases with priority d to be closed created date last 6 months and record type
	//List<Case> DandECasesToBeClosed = [select id, vin__c, Contact_ID__c, Vehicle_Name__c  from Case where vin__c in :vins and Contact_ID__c in :customerIds and (Survey_Type__c = 'Sales Priority D' OR Survey_Type__c = 'Sales Priority E') and recordtypeid in :salesRecordType and createddate = LAST_N_DAYS:180 AND Status != 'Closed' AND (Subject = :welcomeCallsSetting.Subject_no_email__c OR Subject = :welcomeCallsSetting.Subject_with_email__c)];

	Map<String, Account> customersMap = new Map<String, Account> ();
	for (Account customer : customers) {
		customersMap.put(customer.Customer_ID__c, customer);
	}

	Map<String, Account> dealersMap = new Map<String, Account> ();
	for (Account dealer : dealers) {
		dealersMap.put(dealer.Dealer_Code__c, dealer);
	}

	Map<String, Vehicle__c> vehiclesMap = new Map<String, Vehicle__c> ();
	for (Vehicle__c vehicle : vehicles) {
		vehiclesMap.put(vehicle.Vehicle_identification_Number__c, vehicle);
	}

	Map<String, User> agentsMap = new Map<String, User> ();
	for (User agent : owners) {
		agentsMap.put(agent.Alias, agent);
	}
	//map for owners for CA T5 Cases
	Map<String, Id> rcasUsers = new Map<String, Id> ();
	//map to store corresponding alerts and its number in list
	Map<Integer, Stage_FF_Hot_Alerts__c> alertsCasesMap = new Map<Integer, Stage_FF_Hot_Alerts__c> ();
	Integer counter = 0;
	//map to store corresponding Hot alerts number and case number in list
	Map<Integer, Integer> hotAlertsCasesMap = new Map<Integer, Integer> ();
	Integer counterCases = 0;

	List<String> epsilonCasesDqrNumbers = new List<String> ();
	Map<String, List<Stage_FF_Hot_Alerts__c>> epsilonAlerts = new Map<String, List<Stage_FF_Hot_Alerts__c>> ();
	for (Stage_FF_Hot_Alerts__c alert : Trigger.New) {
		
		if (alert.SurveyType__c == 'Pre-Sales' && alert.Case_Type__c == 'Lead VHA' && alert.HotAlertType__c == 'Lead') {
			if (!String.isBlank(alert.Text_Field_1__c)) {
				epsilonCasesDqrNumbers.add(alert.Text_Field_1__c);
				if (epsilonAlerts.get(alert.Text_Field_1__c) == null) {
					List<Stage_FF_Hot_Alerts__c> alerts = new List<Stage_FF_Hot_Alerts__c> ();
					alerts.add(alert);
					epsilonAlerts.put(alert.Text_Field_1__c, alerts);
				} else {
					epsilonAlerts.get(alert.Text_Field_1__c).add(alert);
				}
			} else {
				alert.Successful__c = false;
				alert.Error_Description__c = 'Lead ID is empty, cannot find matching Case';
			}
			counter++;
		} else {
			Case alertCase = new Case();

			if (alert.ContactId__c == null || alert.ContactId__c == '') {

				// If Contact Id is empty, then we log an error and skip to next record in trigger
				alert.Successful__c = false;
				alert.Error_Description__c = 'Contact ID is empty, cannot create a Case';
				counter++;
				continue;
			}
			Account customer = customersMap.get(alert.ContactId__c);
			if (customer == null) {

				// If there is no customer account found by corresponding ContactId__c, then we log an error and skip to next record in trigger
				alert.Successful__c = false;
				alert.Error_Description__c = String.format('There is no customer Account for ContactId__c={0}', new String[] { alert.ContactId__c });
				counter++;
				continue;
			}
			else {
				alertCase.AccountId = customer.Id;
			}

			alertCase.Mailing_Street__c = alert.Address__c;
			alertCase.Hot_Alert_Status__c = alert.Alert_Status__c;
			alertCase.Business_Unit__c = alert.BusinessUnit__c;
			alertCase.Case_Type__c = alert.Case_Type__c;
			alertCase.Contact_ID__c = alert.ContactId__c;
			alertCase.Work_Phone__c = alert.DayTimePhone__c;
			alertCase.Dealer_Number__c = alert.DealerCode__c;
			alertCase.Dealer_Name__c = alert.DealerName__c;

			Account dealer = dealersMap.get(alert.DealerCode__c);
			if (dealer != null) {
				alertCase.Dealer__c = dealer.Id;
				alertCase.Servicing_Dealer__c = dealer.Id;
				if (dealer.RCAS__c != null) {
					rcasUsers.put(alert.DealerCode__c, dealer.RCAS__c);
				}
			}

			alertCase.Email2__c = alert.EmailAddress__c;
			alertCase.Home_Phone__c = alert.EveningPhone__c;
			alertCase.Field_Close_Date__c = alert.Field_Close_Date__c;
			alertCase.Field_Open_Date__c = alert.Field_Open_Date__c;
			alertCase.First_Name__c = alert.FirstName__c;
			alertCase.Hot_Alert_Date__c = alert.Hot_alert_Date__c;
			alertCase.NNA_Net_Hot_Alert_Type__c = alert.HotAlertType__c;
			alertCase.Last_Name__c = alert.LastName__c;
			alertCase.Event_Date__c = alert.EventDate__c;
			alertCase.Survey_NPS_Score_1__c = alert.NPS_Score_1__c;
			alertCase.Survey_NPS_Score_2__c = alert.NPS_Score_2__c;
			alertCase.Survey_NPS_Score_3__c = alert.NPS_Score_3__c;
			alertCase.Survey_NPS_Type_1__c = alert.NPS_Type_1__c;
			alertCase.Survey_NPS_Type_2__c = alert.NPS_Type_2__c;
			alertCase.Survey_NPS_Type_3__c = alert.NPS_Type_3__c;
			alertCase.Origin = 'Data Load';
			alertCase.Overall_Customer_Satisfaction__c = alert.OverallSatisfaction__c;
			alertCase.ContactId = customer.PersonContactId;
			alertCase.Mailing_Zip_Code__c = alert.PostalCode__c;
			alertCase.Priority = 'Low';
			alertCase.Receipt_Date_ID__c = alert.ReceivedDate__c;
			alertCase.Region_d__c = alert.Region__c;
			alertCase.Mailing_State__c = alert.State__c;
			alertCase.Status = 'Item Created';
			alertCase.Hot_Alert_Source__c = alert.SurveyType__c;
			alertCase.SurveyScore__c = alert.SurveyIndexScore__c;
			alertCase.Other_Information__c = alert.OtherInfo__c;
			alertCase.Survey_Specific_Contact_Information__c = String.Format('Name:{0} {1} - Address:{2},{3},{4},{5} - DayTime Phone:{6} - Evening Phone:{7} - Email Address:{8} - Preferred Email:{9}',
			                                                                 new String[] {
				                                                                alert.FirstName__c != null ? alert.FirstName__c : '',
				                                                                alert.LastName__c != null ? alert.LastName__c : '',
				                                                                alert.Address__c != null ? alert.Address__c : '',
				                                                                alert.City__c != null ? alert.City__c : '',
				                                                                alert.State__c != null ? alert.State__c : '',
				                                                                alert.PostalCode__c != null ? alert.PostalCode__c : '',
				                                                                alert.DayTimePhone__c != null ? alert.DayTimePhone__c : '',
				                                                                alert.EveningPhone__c != null ? alert.EveningPhone__c : '',
				                                                                alert.EmailAddress__c != null ? alert.EmailAddress__c : '',
				                                                                alert.PreferredEmail__c != null ? alert.PreferredEmail__c : '' });
			alertCase.Mailing_City__c = alert.City__c;
			alertCase.Survey_ID__c = alert.SurveyId__c;
			if (alert.SurveyIndexScore__c != null && alert.SurveyIndexScore__c != '') {
				alertCase.Survey_Index_Score__c = decimal.valueof(alert.SurveyIndexScore__c);
			}
			alertCase.Survey_Type__c = alert.SurveyType__c;
			alertCase.Alert_Trigger_Verbatim__c = alert.V01_alert_Trigger__c;
			alertCase.Survey_Verbatim_2__c = alert.V02_Supporting__c;
			alertCase.Infiniti_Action_History__c = alert.V03_Action_History__c;
			alertCase.Description = alert.SurveyType__c + ' Hot Alert';

			Vehicle__c vehicle = vehiclesMap.get(alert.VIN__c);
			if (vehicle != null) {
				alertCase.Vehicle_Name__c = vehicle.Id;
			}
			alertCase.VIN__c = alert.VIN__c;
			if (alert.SurveyType__c != null) {
				// Defection hot alerts
				if (alert.SurveyType__c == 'Former Owner Follow-up') {
					if (salesRecordType.size() > 0) {
						alertCase.RecordTypeId = salesRecordType.get(0).Id;
					}

					alertCase.Subject = 'Sales & Service Quality Follow-Up';

					if (cccGroup.size() > 0) {
						alertCase.OwnerId = cccGroup.get(0).Id;
					}
				}
				// DTU hot alerts
				else if (alert.SurveyType__c.contains('Quality Connection') &&
				         alert.SurveyType__c.contains('Main')) {
					if (dtuRecordType.size() > 0) {
						alertCase.RecordTypeId = dtuRecordType.get(0).Id;
					}

					alertCase.Subject = 'DTU Hot Alert';
					alertCase.Type = 'T5';
					alertCase.Status = 'Open';

					if (dtuGroup.size() > 0) {
						alertCase.OwnerId = dtuGroup.get(0).Id;
					}
				}
				// Quality connection hot alerts
				else if (alert.SurveyType__c == 'Quality Connection') {
					if (t5RecordType.size() > 0) {
						alertCase.RecordTypeId = t5RecordType.get(0).Id;
					}

					alertCase.Subject = 'Quality Connection Follow Up';

					// Assign case to the user based on AgentId field from Stage_FF_Hot_Alerts__c record
					User user = agentsMap.get(alert.AgentId__c);
					if (user != null) {
						alertCase.OwnerId = user.Id;
					}
				}
				//One minute feedback
				else if (alert.SurveyType__c.contains('One-Minute')) {
					if (alert.ConsentToComm__c == 'NO') {
						alertCase.Do_Not_Contact__c = true;
					}

					alertCase.Description = 'One-Minute Feedback Hot Alert';
					if (alert.BusinessUnit__c != null && alert.BusinessUnit__c.contains('Nissan')) {
						if (nissanOmfGroup.size() > 0) {
							alertCase.OwnerId = nissanOmfGroup.get(0).Id;
						}
					}
					else if (alert.BusinessUnit__c != null && alert.BusinessUnit__c.contains('Infiniti')) {
						if (oneminuteGroup.size() > 0) {
							alertCase.OwnerId = oneminuteGroup.get(0).Id;
						}
					} else {
						if (oneminuteGroup.size() > 0) {
							alertCase.OwnerId = oneminuteGroup.get(0).Id;
						}
					}
					if (t5RecordType.size() > 0) {
						alertCase.RecordTypeId = t5RecordType.get(0).Id;
					}
					alertCase.Subject = 'One-Minute Feedback';
				} else if (alert.SurveyType__c == '') {
					// If Survey Type is empty, then we log an error and skip to next record in trigger
					alert.Successful__c = false;
					alert.Error_Description__c = 'Survey Type is empty, cannot specify type';
					counter++;
					continue;
				}
				else {
					// Infiniti hot alerts
					if (alert.Case_Type__c != null) {
						if (alert.Case_Type__c.contains('Infiniti')) {
							if (salesRecordType.size() > 0) {
								alertCase.RecordTypeId = salesRecordType.get(0).Id;
							}

							alertCase.Subject = 'Sales & Service Quality Follow-Up';

							if (cccGroup.size() > 0) {
								alertCase.OwnerId = cccGroup.get(0).Id;
							}
						}
						// Nissan Hot alerts
						else if (alert.Case_Type__c.contains('OFS')) {
							if (salesRecordType.size() > 0) {
								alertCase.RecordTypeId = salesRecordType.get(0).Id;
							}

							alertCase.Subject = 'Sales & Service Quality Follow-Up';

							if (cccGroup.size() > 0) {
								alertCase.OwnerId = cccGroup.get(0).Id;
							}
						}
						//Welcome Hot Alerts
						else if (alert.Case_Type__c.contains('New Customer Welcome')) {
							alertCase.status = 'Item Created';
							if (cccGroup.size() > 0) {
								alertCase.OwnerId = cccGroup.get(0).Id;
							}
							if (salesRecordType.size() > 0) {
								alertCase.RecordTypeId = salesRecordType.get(0).Id;
							}
							alertCase.Subject = welcomeCallsSetting.Subject_from_Hot_Alert__c;
							alertCase.Description = alert.SurveyType__c + ' Welcome Call';
							/*if(welcomeCallsSetting.Close_Cases__c){
							  for(case caseItem : casesWithPriorityD){
							  if(caseItem.vin__c == alert.VIN__c && caseItem.Contact_ID__c == alert.ContactId__c && caseItem.Vehicle_Name__c == vehiclesMap.get(alert.VIN__c).Id){
							  caseItem.status = 'Closed';
							  casesWithPriorityDClosed.add(caseItem);
							  }
							  }
							  }*/
						}
						// CA T5 hot alerts
						else if (alert.Case_Type__c.contains('Nissan')) {
							if (t5RecordType.size() > 0) {
								alertCase.RecordTypeId = t5RecordType.get(0).Id;
							}
							Id rcasOwner = rcasUsers.get(alert.DealerCode__c);
							if (rcasOwner != null) {
								alertCase.OwnerId = rcasOwner;
							} else if (t5Group.size() > 0) {
								alertCase.OwnerId = t5Group.get(0).Id;
							}

							alertCase.Status = 'Open';
						} else {
							// If Case_Type__c is empty, then we log an error and skip to next record in trigger
							alert.Successful__c = false;
							alert.Error_Description__c = 'Case or Survey Type is empty or invalid, cannot specify type';
							counter++;
							continue;
						}
					} else {
						// If Case_Type__c is empty, then we log an error and skip to next record in trigger
						alert.Successful__c = false;
						alert.Error_Description__c = 'Case Type is empty cannot specify type';
						counter++;
						continue;
					}
				}
			} else {
				// If Survey Type is empty, then we log an error and skip to next record in trigger
				alert.Successful__c = false;
				alert.Error_Description__c = 'Survey Type is empty, cannot specify type';
				counter++;
				continue;
			}
			QCHotAlertCases.Add(alertCase);
			// number + alert
			hotAlertsCasesMap.put(counterCases, counter);
			counterCases++;
			alertsCasesMap.put(counter, alert);
			counter++;
		}
	}
	// Insert new Cases
	if (!QCHotAlertCases.isEmpty()) {
		List<Case> casesWithPriorityDClosed = new List<Case> ();
		Set<Case> casesWithPriorityDClosedSet = new Set<Case> ();
		// Insert rows
		System.debug('before insert of QCHotAlertCases');
		Database.SaveResult[] dbResults = Database.insert(QCHotAlertCases, false);
		System.debug('after insert of QCHotAlertCases' + Json.serialize(dbResults));
		// If there are any results, handle the errors
		if (!dbResults.isEmpty())
		{
			// Loop through results returned
			for (integer row = 0; row < QCHotAlertCases.size(); row++)
			{
				// If the current row was not sucessful, handle the error.
				if (!dbResults[row].isSuccess())
				{
					// Get the error for this row and populate corresponding fields
					Database.Error err = dbResults[row].getErrors() [0];
					alertsCasesMap.get(hotAlertsCasesMap.get(row)).Successful__c = false;
					alertsCasesMap.get(hotAlertsCasesMap.get(row)).Error_Description__c = err.getMessage();
				} else {
					alertsCasesMap.get(hotAlertsCasesMap.get(row)).Successful__c = true;
					alertsCasesMap.get(hotAlertsCasesMap.get(row)).Error_Description__c = '';
					alertsCasesMap.get(hotAlertsCasesMap.get(row)).Case_ID__c = dbResults[row].getId();
					/*if (alertsCasesMap.get(hotAlertsCasesMap.get(row)).Case_Type__c != null && alertsCasesMap.get(hotAlertsCasesMap.get(row)).Case_Type__c.contains('New Customer Welcome')) {
					  if(welcomeCallsSetting.Close_Cases__c){
					  for(case caseItem : DandECasesToBeClosed){
					  if(caseItem.vin__c == alertsCasesMap.get(hotAlertsCasesMap.get(row)).VIN__c && caseItem.Contact_ID__c == alertsCasesMap.get(hotAlertsCasesMap.get(row)).ContactId__c && caseItem.Vehicle_Name__c == vehiclesMap.get(alertsCasesMap.get(hotAlertsCasesMap.get(row)).VIN__c).Id){
					  caseItem.status = 'Closed';
					  casesWithPriorityDClosedSet.add(caseItem);
					  }
					  }
					  }
					  }*/
				}
			}
		}

		/*//close cases with prioroty d
		  if(!casesWithPriorityDClosedSet.isEmpty()){
		  casesWithPriorityDClosed.addAll(casesWithPriorityDClosedSet);
		  update casesWithPriorityDClosed;
		  }*/
	}
	//epsilon cases update
	if (epsilonCasesDqrNumbers.size() > 0) {
		Map<String, Case> epsCases = new Map<String, Case> ();
		List<Case> updCases = [SELECT DQR_Number__c, ID FROM Case WHERE DQR_Number__c = :epsilonCasesDqrNumbers];
		for (Case c : updCases) {
			if (mccLeadHotAlertGroup.size() > 0) {
				c.OwnerId = mccLeadHotAlertGroup[0].Id;
			}
			c.Description = 'Follow up on Lead Survey Hot Alert';
			c.Priority = 'Low';
			c.Status = 'Item Created';
			c.Epsilon_survey_Created__c = Datetime.now();
			if (leadSurveyRecordType.size() > 0) {
				c.recordTypeId = leadSurveyRecordType[0].Id;
			}
			c.Origin = 'Lead Survey';
			c.Subject = 'Lead Survey Hot Alert';
			epsCases.put(c.DQR_Number__c, c);
		}
		Database.SaveResult[] dbResults = Database.update(updCases, false);

		if (!dbResults.isEmpty())
		{
			// Loop through results returned
			for (integer row = 0; row < updCases.size(); row++)
			{
				// If the current row was not sucessful, handle the error.
				if (dbResults[row].isSuccess())
				{
					if (epsilonAlerts.get(updCases[row].DQR_Number__c) != null) {
						for (Stage_FF_Hot_Alerts__c alert : epsilonAlerts.get(updCases[row].DQR_Number__c)) {
							alert.Successful__c = true;
							alert.Error_Description__c = '';
							alert.Case_ID__c = dbResults[row].getId();
						}
					}
				} else {
					if (epsilonAlerts.get(updCases[row].DQR_Number__c) != null) {
						for (Stage_FF_Hot_Alerts__c alert : epsilonAlerts.get(updCases[row].DQR_Number__c)) {
							Database.Error err = dbResults[row].getErrors() [0];
							alert.Successful__c = false;
							alert.Error_Description__c = err.getMessage();
							alert.Case_ID__c = dbResults[row].getId();
						}
					}
				}
			}
		}

		for (List<Stage_FF_Hot_Alerts__c> listAlerts : epsilonAlerts.values()) {
			for (Stage_FF_Hot_Alerts__c alert : listAlerts) {
				if(epsCases.get(alert.Text_Field_1__c) == null){
					alert.Successful__c = false;
					alert.Error_Description__c = 'Case with such leadId cannot be found';
				}
			}
		}
	}
	insert errors;
}