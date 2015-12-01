@isTest
public class EpsilonSurveyAfterHelper_Tests { 
	static testmethod void testBuildCase(){
		Case c = new Case(DQR_number__c = 'testepsilon1', Reason = 'Offer Owned Incentive');
		insert c;
		Epsilon_Surveys_Business_Rules__c standardSettings = new Epsilon_Surveys_Business_Rules__c(Name = '1', Dealer_Contacted__c = true, Dealer_Rating__c = 7, Field_API_Name__c = 'Status', Field_Value__c = 'Open');
		insert standardSettings;
		Epsilon_Business_Rules_with_Calls__c additionalSettings = new Epsilon_Business_Rules_with_Calls__c(Name = '1', Dealer_Contacted__c = true, Dealer_Rating__c = 7, Field_API_Name__c = 'Status', Field_Value__c = 'Closed', Check_if_less_calls__c = true, Total_Calls__c = 0);
		insert additionalSettings;
		Epsilon_Business_Rules_Priority__c prioritySettings = new Epsilon_Business_Rules_Priority__c(Name = '1', Reason__c = 'Offer Owned Incentive', Epsilon_Takes_Priority__c = true);
		insert prioritySettings;
		String epsilonSurveyRecordType = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Epsilon Survey');
		Surveys__c survey = new Surveys__c(Lead_Id__c = 'testepsilon1', DQR_Dealer_Contacted__c = 'Yes', DQR_Dealer_Rating__c = 7, recordtypeid = epsilonSurveyRecordType);
		Test.startTest();
		insert survey;
		EpsilonSurveyAfterHelper surveysHelper = new EpsilonSurveyAfterHelper();
		surveysHelper.upsertCasesForEpsilonRT(new List<Surveys__c> {survey}, false);
		c = [select id, status from Case limit 1];
		System.assertEquals(c.status, 'Closed');
		Test.stopTest();
	}
}