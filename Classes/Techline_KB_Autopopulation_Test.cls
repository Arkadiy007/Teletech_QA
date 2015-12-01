/**********************************************************************
  Name: Techline_KB_Autopopulation_Test
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose:
  Test class for Techline_KB_Autopopulation class.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev	06/22/2015 Created
 ***********************************************************************/
@isTest
public class Techline_KB_Autopopulation_Test {

static testMethod void testAgentContributionArticleController() {
         String caseSubject = 'my test';
         String caseDesc = 'my test description';

         Case c = new Case();
         c.subject= caseSubject;
         c.description = caseDesc;
         insert c;
         String caseId = c.id;

		 CaseComment cC = new CaseComment();
		 cC.CommentBody = 'test';
		 cC.ParentId = caseId;
		 insert cC;

         System.debug('Created Case: ' + caseId);

         ApexPages.currentPage().getParameters().put('sourceId', caseId);
         ApexPages.currentPage().getParameters().put('sfdc.override', '1');

         ApexPages.KnowledgeArticleVersionStandardController ctl =
         new ApexPages.KnowledgeArticleVersionStandardController(new Techline__kav());
         new Techline_KB_Autopopulation(ctl);

         System.assertEquals(caseId, ctl.getSourceId());
         System.assertEquals(caseSubject, ctl.getRecord().get('title'));
   }

}