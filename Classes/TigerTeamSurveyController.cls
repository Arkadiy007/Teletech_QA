public without sharing class TigerTeamSurveyController {

	public String surveyId { get; set; }
	public String caseId { get; set; }

	public List<SelectOption> waitTime {
		get {
			list<SelectOption> wait = new List<SelectOption> ();
			wait.add(new SelectOption('Not long at all', 'Not long at all'));
			wait.add(new SelectOption('Slightly long', 'Slightly long'));
			wait.add(new SelectOption('Moderately long', 'Moderately long'));
			wait.add(new SelectOption('Very long', 'Very long'));
			wait.add(new SelectOption('Extremely long', 'Extremely long'));
			return wait;
		}
		set;
	}
	public List<SelectOption> knowledgeLevel {
		get {
			list<SelectOption> wait = new List<SelectOption> ();
			wait.add(new SelectOption('Extremely knowledgeable', 'Extremely knowledgeable'));
			wait.add(new SelectOption('Very knowledgeable', 'Very knowledgeable'));
			wait.add(new SelectOption('Moderately knowledgeable', 'Moderately knowledgeable'));
			wait.add(new SelectOption('Slightly knowledgeable', 'Slightly knowledgeable'));
			wait.add(new SelectOption('Not knowledgeable at all', 'Not knowledgeable at all'));
			return wait;
		}
		set;
	}
	public List<SelectOption> helpfulLevel {
		get {
			list<SelectOption> wait = new List<SelectOption> ();
			wait.add(new SelectOption('Extremely helpful', 'Extremely helpful'));
			wait.add(new SelectOption('Very helpful', 'Very helpful'));
			wait.add(new SelectOption('Moderately helpful', 'Moderately helpful'));
			wait.add(new SelectOption('Slightly helpful', 'Slightly helpful'));
			wait.add(new SelectOption('Not helpful at all', 'Not helpful at all'));
			return wait;
		}
		set;
	}
	public List<SelectOption> experience {
		get {
			list<SelectOption> wait = new List<SelectOption> ();
			wait.add(new SelectOption('Much better', 'Much better'));
			wait.add(new SelectOption('Somewhat better', 'Somewhat better'));
			wait.add(new SelectOption('Slightly better', 'Slightly better'));
			wait.add(new SelectOption('About what was expected', 'About what was expected'));
			wait.add(new SelectOption('Slightly worse', 'Slightly worse'));
			wait.add(new SelectOption('Somewhat worse', 'Somewhat worse'));
			wait.add(new SelectOption('Much worse', 'Much worse'));
			return wait;
		}
		set;
	}
	public List<SelectOption> resolved {
		get {
			list<SelectOption> wait = new List<SelectOption> ();
			wait.add(new SelectOption('Yes', 'Yes'));
			wait.add(new SelectOption('No', 'No'));
			return wait;
		}
		set;
	}
	//------------------------------------------------------------------------------// 
	public TigerTeamSurveyController(ApexPages.StandardController stdController) {
		// Get url parameters
		surveyId = Apexpages.currentPage().getParameters().get('id');
		caseId = Apexpages.currentPage().getParameters().get('caId');
	}
	public TigerTeamSurveyController() {

	}
	public PageReference checkSubmitted() {
		surveyId = Apexpages.currentPage().getParameters().get('id');
		caseId = Apexpages.currentPage().getParameters().get('caId');
		if (surveyId != null && surveyId != '') {
			Surveys__c survey = [Select id, Survey_Submitted__c from Surveys__c where Id = :surveyId limit 1];
			if (survey != null && survey.Survey_Submitted__c) {
				String newPageReference = 'javascript:  window.open(\'\\TigerTeam_ThankYou\', \'_self\', \'Thank you\');';
				PageReference pageRef = new PageReference(newPageReference); //pageExitName));
				pageRef.setRedirect(true);
				return pageRef;
			}
		}

		return null;
	}
	public PageReference checkSixthQuest() {
		if (surveyId != null && surveyId != '') {
			Surveys__c survey = [Select id, Question_resolved_TT__c, Survey_Submitted__c, Feedback_TT__c from Surveys__c where Id = :surveyId limit 1];

			if (survey != null && survey.Question_resolved_TT__c != null && survey.Question_resolved_TT__c == 'No') {
				if (String.isBlank(survey.Feedback_TT__c)) {
					Tiger_Team_Settings__c settings = Tiger_Team_Settings__c.getOrgDefaults();
					if (settings != null && settings.Specify_Feedback__c != null) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, settings.Specify_Feedback__c));
					} else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Controller')); //'Please specify feedback for we to know why your question or concern has not been resolved'));
					}
					return null;
				}
				if (caseId != null && caseId != '') {
					Case c = [Select id, status, OwnerId, owner.email, owner.Name, caseNumber from Case where Id = :caseId limit 1];
					if (c != null) {
						c.Status = 'Open';
						update c;
						List<String> emailsToSend = new List<String> ();
						if (c.owner.email != null) {
							emailsToSend.add(c.owner.Email);
						}
						EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = :'Case Reopened'];
						if (emailTemplate != null && emailsToSend.size() > 0) {
							String plainBody = emailTemplate.Body;
							plainBody = plainBody.replace('{!Case.OwnerFullName}', c.owner.Name);
							plainBody = plainBody.replace('{!Case.CaseNumber}', c.caseNumber);
							Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

							email.setReplyTo('TigerTeamSTP@nissan-usa.com');
							email.setSenderDisplayName('TigerTeamSTP@nissan-usa.com');

							email.setToAddresses(emailsToSend);
							email.setSubject(emailTemplate.subject);
							email.setPlainTextBody(plainBody);
							Messaging.sendEmail(new Messaging.SingleEmailmessage[] { email });
						}
					}
				}

			}
			survey.Survey_Submitted__c = true;

			update survey;
			String newPageReference = 'javascript:  window.open(\'\\TigerTeam_ThankYou\', \'_self\', \'Thank you\');';

			PageReference pageRef = new PageReference(newPageReference); //pageExitName));
			pageRef.setRedirect(true);
			return pageRef;
		}
		return null;
	}
}