@isTest
public class TigerTeamSurveyController_Tests {
    private static list<SelectOption> exp = new List<SelectOption> ();
    private static list<SelectOption> help = new List<SelectOption> ();
    private static list<SelectOption> wait = new List<SelectOption> ();
    private static list<SelectOption> know = new List<SelectOption> ();
    private static List<Case> cases = new List<Case> { };
    private static Contact cont = new Contact();
    private static Case caseRec = new Case();
    private static User tigerUser = new User();
    private static void setupController() {
        exp.add(new SelectOption('Much better', 'Much better'));
        exp.add(new SelectOption('Somewhat better', 'Somewhat better'));
        exp.add(new SelectOption('Slightly better', 'Slightly better'));
        exp.add(new SelectOption('About what was expected', 'About what was expected'));
        exp.add(new SelectOption('Slightly worse', 'Slightly worse'));
        exp.add(new SelectOption('Somewhat worse', 'Somewhat worse'));
        exp.add(new SelectOption('Much worse', 'Much worse'));

        help.add(new SelectOption('Extremely helpful', 'Extremely helpful'));
        help.add(new SelectOption('Very helpful', 'Very helpful'));
        help.add(new SelectOption('Moderately helpful', 'Moderately helpful'));
        help.add(new SelectOption('Slightly helpful', 'Slightly helpful'));
        help.add(new SelectOption('Not helpful at all', 'Not helpful at all'));

        wait.add(new SelectOption('Not long at all', 'Not long at all'));
        wait.add(new SelectOption('Slightly long', 'Slightly long'));
        wait.add(new SelectOption('Moderately long', 'Moderately long'));
        wait.add(new SelectOption('Very long', 'Very long'));
        wait.add(new SelectOption('Extremely long', 'Extremely long'));

        know.add(new SelectOption('Extremely knowledgeable', 'Extremely knowledgeable'));
        know.add(new SelectOption('Very knowledgeable', 'Very knowledgeable'));
        know.add(new SelectOption('Moderately knowledgeable', 'Moderately knowledgeable'));
        know.add(new SelectOption('Slightly knowledgeable', 'Slightly knowledgeable'));
        know.add(new SelectOption('Not knowledgeable at all', 'Not knowledgeable at all'));

        RecordType caseDIPCRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
        cont = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert cont;
        cont = [select id from contact limit 1];
        tigerUser = [Select id, name from User where Segment__c= 'T - Tiger Team' and IsActive = true limit 1];
        System.runAs(tigerUser){
            caseRec = new Case();
            caseRec.Status = 'Open';
            caseRec.Origin = 'Phone';
            caseRec.Reason = 'Tiger Team / STP';
            caseRec.ContactId = cont.id;
            caseRec.RecordTypeId = caseDIPCRT.ID;
            cases.add(caseRec);
            insert cases;       
        }
    }

    static testmethod void checkSixthQuestTest() {
    
        setupController();
        System.runAs(tigerUser){
        caseRec = [select id, Status from Case limit 1];
        caseRec.Status = 'Closed';
        update caseRec;
        caseRec = [select id, Status from Case limit 1];
        Surveys__c survey = [select id from Surveys__c limit 1];
        PageReference pageRef = Page.SurveyPage;
        pageRef.getParameters().put('id', String.valueOf(survey.Id));
        pageRef.getParameters().put('caId', String.valueOf(caseRec.Id));

        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(survey);
        TigerTeamSurveyController controller = new TigerTeamSurveyController(sc);
        survey.Question_resolved_TT__c = 'No';
        survey.Feedback_TT__c = 'Test';
        update survey;
        System.debug(exp);
        System.debug(know);
        System.assertNotEquals(controller.checkSixthQuest(), null);
        
        System.assertEquals(exp, controller.experience);
        
        System.assertEquals(help, controller.helpfulLevel);
        
        System.assertEquals(wait, controller.waitTime);
        
        System.assertEquals(know, controller.knowledgeLevel);
        Test.stopTest();
        }
    }
}