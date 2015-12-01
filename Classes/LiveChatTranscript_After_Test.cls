/**********************************************************************
  Name: LiveChatTranscript_After_Test
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose:
  Test class for LiveChatTranscript_After trigger.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev	03/20/2015 Created
 ***********************************************************************/
@isTest
public class LiveChatTranscript_After_Test {

	static testMethod void Stage_FF_SFDC_SurveyResponse_Creation() {

		LiveChatVisitor testVisitor = createLiveChatVisitor();
		Surveys__c testSurv = createSurveys();
		Pre_Chat_Data__c testPreChatData = createPreChatData();
		Case testCase = createCase();

		String body = 'Chat Started: Wednesday, March 25, 2015, 12:26:09 (-0500) ' +
						'Chat Origin: Choose Nissan ' + 
						'Agent Heena S ' +
						'( 4s ) Heena: Thank you for contacting Nissan! My name is Heena. Before we get started, may I please have your email address to access your records?';

		LiveChatTranscript testTranscript = new LiveChatTranscript(LiveChatVisitorId = testVisitor.Id, IpAddress = '10.10.20.20', StartTime = DateTime.Now(), Session_Id__c = '111', CaseId = testCase.Id, Body = body);
		insert testTranscript;

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, CustomerFb_Infiniti_ExpBrand_Comments__c,
		                                                  CustomerFb_Infiniti_ExpBrand_NPS__c, CustomerFb_Infiniti_ExpRetailer_Comments__c, CustomerFb_Infiniti_ExpRetailer_NPS__c,
														  PostChat_Agent__c, CaseId__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c];
		/*
		system.assertequals(1, result.size());
		system.assertNotequals(result[0].Id, null);
		system.assertNotequals(result[0].PostChat_Agent__c, null);
		system.assertNotequals(result[0].CaseId__c, null);
		*/
	}



	/*HERPERS----------------------------------------------------------*/
	private static LiveChatVisitor createLiveChatVisitor() {
		LiveChatVisitor visitor = new LiveChatVisitor();
		insert visitor;

		return visitor;
	}

	private static Surveys__c createSurveys() {
		String SurveyTypeId = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'Live Agent');
		Surveys__c surv = new Surveys__c(RecordTypeId = SurveyTypeId, Survey_Type__c = 'Live Agent', Live_Agent_Visitor_IP__c = '10.10.20.20' );
		insert surv;

		return surv;
	}

	private static Pre_Chat_Data__c createPreChatData() {
		Pre_Chat_Data__c preChatData = new Pre_Chat_Data__c(Session_Id__c = '111', Disposition_Code__c = 'All Other');
		insert preChatData;

		return preChatData;
	}

	private static Case createCase() {
		List<RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Case' and Name = 'DPIC'];
		Case cs = new Case(RecordTypeId = RecType[0].Id, Status = 'Open');
		insert cs;

		return cs;
	}

 }