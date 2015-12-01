@isTest
public class CaseCommentsControllerTest {
 static testMethod void myTestCaseComments() {
        
        //100% code coverage
        //Unit test by: Mike Katulka @ www.itedgecrm.com - mike@itedgecrm.com
        //Component by: http://boards.developerforce.com/t5/forums/replypage/board-id/Visualforce/message-id/17704
        
		//Navigate to Case page
        PageReference pageRef = Page.ShareCaseWithDealer;     //**** Enter your Case overridden view page name here  
        		
        //Create test Case
		Case c = new Case(RecordTypeId = [Select Id from RecordType where DeveloperName='CA' and sObjectType = 'Case' limit 1].id, 
		  Description='UNIT TESTING',
		  Origin='Phone',
		  Priority='Medium',
		  Status='New'
		  );				
		insert c;
		system.assertEquals(1, [select id from case where id=:c.id and isdeleted=false].size());
		
		//create controller first
		CaseCommentsComponentController controller = new CaseCommentsComponentController();
		Test.setCurrentPage(pageRef);
		controller.caseid = c.id;
		
		//Test NewComment()
		String nextPage = controller.NewComment().getUrl();		
		system.assertEquals(true, nextPage.contains('/00a/e?parent_id=' + c.id)); //Verify that it sends you to the Standard casecomment SF page
		
		//Create a casecomment for further testing
		CaseComment cc = new CaseComment (ParentID = c.id, CommentBody = 'UNIT TESTING', isPublished=false);
		insert cc;
		system.assertNotEquals(null, cc.id);
		string commentid = cc.id;		
		
		//Test makePublicPrivate()  > to public
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CommentId_p', commentid); //parameter name = CommentId_p		
		nextPage = controller.makePublicPrivate().getUrl();
		system.assertEquals(true, nextPage.contains(c.id));
		system.assertEquals(1, [select id from casecomment where id=:commentid and isdeleted=false and isPublished=true].size());		
		
		//Test makePublicPrivate()  > to private
		Test.setCurrentPage(pageRef);		
        ApexPages.currentPage().getParameters().put('CommentId_p', commentid); //parameter name = CommentId_p		
		nextPage = controller.makePublicPrivate().getUrl();
		system.assertEquals(true, nextPage.contains(c.id));
		system.assertEquals(1, [select id from casecomment where id=:commentid and isdeleted=false and isPublished=false].size());
		
		//Test deleteComment()
		Test.setCurrentPage(pageRef);		
        ApexPages.currentPage().getParameters().put('CommentId_d', commentid); //parameter name = CommentId_d (different!)	
		nextPage = controller.DeleteComment().getUrl();
		system.assertEquals(true, nextPage.contains(c.id));
		system.assertEquals(0, [select id from casecomment where id=:commentid and isdeleted=false].size());	
		
    }
        
}