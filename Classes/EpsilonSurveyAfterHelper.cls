/**********************************************************************
  Name: EpsilonSurveyAfterHelper
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger helper created to upsert related Cases based on leadid recieved from Epsilon
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 8/11/2015 Created
 ***********************************************************************/
public class EpsilonSurveyAfterHelper {
	private final String epsilonSurveyRecordType = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Epsilon Survey');

	private static Set<String> existingLeadIds = new Set<String> ();
	private static Set<String> leadIds = new Set<String> ();

	private static Map<String, Boolean> prioritySettings { get; set; }

	private List<Case> casesToUpdate = new List<Case> ();
	private List<Surveys__c> surveysToUpdate = new List<Surveys__c> ();

	private static Map<String, Case> casesByDQRNumber = new Map<String, Case> ();
	private static List<Epsilon_Surveys_Business_Rules__c> allEpsilonSettings { get; Set; }
	private static List<Epsilon_Business_Rules_with_Calls__c> EpsilonSettingsWithCalls { get; Set; }
	private Map<Id, List<Call__c>> callsMap = new Map<ID, List<Call__c>> ();

	public void upsertCasesForEpsilonRT(List<Surveys__c> insertedSurveys, boolean newSurveys) {
		allEpsilonSettings = Epsilon_Surveys_Business_Rules__c.getAll().values();
		EpsilonSettingsWithCalls = Epsilon_Business_Rules_with_Calls__c.getAll().values();
		getPrioritySettings();

		for (Surveys__c s : insertedSurveys) {
			if (s.RecordTypeId == epsilonSurveyRecordType) {
				leadIds.add(s.Lead_Id__c);
			}
		}
		if (newSurveys) {
			deleteNewlyInsertedSurveys(insertedSurveys);
		}

		for (Case cs :[SELECT Id, DQR_Number__c, Reason, Total_Calls_Open_and_Closed__c FROM Case WHERE DQR_Number__c IN :leadIds]) {
			casesByDQRNumber.put(cs.DQR_Number__c, cs);
		}

		callsMap = new Map<ID, List<Call__c>> ();
		for (Case c :[SELECT Id, (SELECT Id, Call_Type__c, Outcome__c FROM Calls__r) FROM Case WHERE Id = :casesByDQRNumber.values()])
		{
			callsMap.put(c.Id, c.Calls__r);
		}
		Map<Id, Surveys__c> caseSurvey = new Map<Id, Surveys__c> ();
		for (Surveys__c survey : insertedSurveys) {
			if (isSurveyEpsilon(survey)) {

				Surveys__c updatedSurvey = buildSurvey(survey);
				System.debug('****casesByDQRNumber ' + casesByDQRNumber);
				System.debug('****survey.Lead_Id__c ' + survey.Lead_Id__c);
				if (casesByDQRNumber.containsKey(survey.Lead_Id__c)) {
					Case updatedCase = new Case();
					if (survey.DQR_Dealer_Contacted__c == 'Yes') {
						updatedCase = buildCase(survey.Lead_Id__c, true, survey.DQR_Dealer_Rating__c, survey.Id);
					} else if (survey.DQR_Dealer_Contacted__c == 'No') {
						updatedCase = buildCase(survey.Lead_Id__c, false, survey.DQR_Dealer_Rating__c, survey.Id);
					}else{
						continue;
					}

					updatedSurvey.Epsilon_Case__c = updatedCase.Id;
					updatedCase.Survey__c = updatedSurvey.id;
					updatedCase.Epsilon_Survey_Created__c = Datetime.now();
					
					casesToUpdate.add(updatedCase);
					caseSurvey.put(updatedCase.Id, updatedSurvey);
				}
				else {
					updatedSurvey.EpErrors__c = 'Case with such leadId cannot be found';
					surveysToUpdate.add(updatedSurvey);
				}

				
			}

		}

		if (casesToUpdate.size() > 0) {
			Database.SaveResult[] dbResults = Database.update(casesToUpdate, false);
			//update casesToUpdate;
			if (!dbResults.isEmpty())
			{
				// Loop through results returned
				for (integer row = 0; row < casesToUpdate.size(); row++)
				{
					// If the current row was not sucessful, handle the error.
					if (!dbResults[row].isSuccess())
					{
						Database.Error err = dbResults[row].getErrors() [0];
						if (caseSurvey.get(casesToUpdate[row].Id) != null) {
							caseSurvey.get(casesToUpdate[row].Id).EpErrors__c = 'Error on Case update: ' + err.getMessage();					
						}
					}else{
						if (caseSurvey.get(casesToUpdate[row].Id) != null) {
							caseSurvey.get(casesToUpdate[row].Id).Epsilon_Case__c = dbResults[row].getId();
							caseSurvey.get(casesToUpdate[row].Id).EpErrors__c = '';
						}
					}
					if (caseSurvey.get(casesToUpdate[row].Id) != null) {
						surveysToUpdate.add(caseSurvey.get(casesToUpdate[row].ID));
					}
				}
			}
			
		}
		if (surveysToUpdate.size() > 0) {
			update surveysToUpdate;
		}
	}
	private Case buildCase(String leadId, Boolean dealerContacted, Decimal dealerRating, Id surveyId) {
		sObject caseToReturn = casesByDQRNumber.get(leadId);

		if (!prioritySettings.containsKey(casesByDQRNumber.get(leadId).Reason) || prioritySettings.get(casesByDQRNumber.get(leadId).Reason)) {
			applyStandardLogic(dealerContacted, dealerRating, caseToReturn);
			applyLogicWithCalls(dealerContacted, dealerRating, caseToReturn, casesByDQRNumber.get(leadId).Total_Calls_Open_and_Closed__c);
		}

		return(Case) caseToReturn;
	}

	private void applyStandardLogic(Boolean dealerContacted, Decimal dealerRating, sObject caseToReturn) {
		for (Epsilon_Surveys_Business_Rules__c settings : allEpsilonSettings) {
			if (settings.Dealer_Contacted__c == dealerContacted && (!dealerContacted || settings.Dealer_Rating__c == dealerRating)) {
				caseToReturn.put(settings.Field_API_Name__c, settings.Field_Value__c);
			}
		}
	}

	private void applyLogicWithCalls(Boolean dealerContacted, Decimal dealerRating, sObject caseToReturn, Decimal totalCalls) {
		for (Epsilon_Business_Rules_with_Calls__c settings : EpsilonSettingsWithCalls) {
			if (settings.Dealer_Contacted__c == dealerContacted && settings.Dealer_Rating__c == dealerRating) {
				if (totalCalls > settings.Total_Calls__c && callsMap.get(caseToReturn.id) != null) {
					for (Call__c call : callsMap.get(caseToReturn.id)) {
						if (call.Call_Type__c == settings.Call_Type__c && call.Outcome__c == settings.Call_Outcome__c && !String.isBlank(settings.Field_Value__c) && settings.Outcome_should_equal__c) {
							caseToReturn.put(settings.Field_API_Name__c, settings.Field_Value__c);
							break;
						} else if (call.Call_Type__c == settings.Call_Type__c && call.Outcome__c != settings.Call_Outcome__c && !String.isBlank(settings.Field_Value__c) && !settings.Outcome_should_equal__c) {
							caseToReturn.put(settings.Field_API_Name__c, settings.Field_Value__c);
							break;
						}
					}
				} else if (totalCalls <= settings.Total_Calls__c && settings.Check_if_less_calls__c) {
					caseToReturn.put(settings.Field_API_Name__c, settings.Field_Value__c);
				}
			}
		}
	}

	private Boolean isSurveyEpsilon(Surveys__c s) {
		return s.RecordTypeId == epsilonSurveyRecordType &&

		s.Lead_Id__c != null &&
		!existingLeadIds.contains(s.Lead_Id__c);
	}

	private Surveys__c buildSurvey(Surveys__c s) {
		Surveys__c updatedSurvey = New Surveys__c(Id = s.Id);
		updatedSurvey.Hot_Alert_Created__c = true;
		updatedSurvey.CastIron_ETL_Status__c = false;


		return updatedSurvey;
	}

	private void getPrioritySettings() {
		prioritySettings = new Map<String, Boolean> ();

		for (Epsilon_Business_Rules_Priority__c prioritySetting : Epsilon_Business_Rules_Priority__c.getAll().values()) {
			prioritySettings.put(prioritySetting.Reason__c, prioritySetting.Epsilon_Takes_Priority__c);
		}
	}

	private void deleteNewlyInsertedSurveys(List<Surveys__c> insertedSurveys) {
		List<Surveys__c> surveysToDelete = new List<Surveys__c> ();
		Set<Surveys__c> surveysSet = new Set<Surveys__c> ();

		if (leadIds.size() > 0) {
			for (Surveys__c s :[select Id, Lead_Id__c from Surveys__c where
			     Id Not in :insertedSurveys and Lead_Id__c in :leadIds
			     and RecordTypeId = :epsilonSurveyRecordType]) {

				existingLeadIds.add(s.Lead_Id__c);
			}

			for (Surveys__c s : insertedSurveys) {
				if (existingLeadIds.contains(s.Lead_Id__c)) {
					surveysToDelete.add(s);
				}
				else {
					surveysSet.add(s);
				}
			}

			if (surveysToDelete.size() > 0) {
				delete[select Id from Surveys__c where Id in : surveysToDelete];
			}
		}

		insertedSurveys.clear();
		insertedSurveys.addAll(surveysSet);

	}
}