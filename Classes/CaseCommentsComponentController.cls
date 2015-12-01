/** From http://boards.developerforce.com/t5/Visualforce-Development/Case-Comments-Related-List-using-Visualforce/td-p/151775 **/
public class CaseCommentsComponentController {
	
	public Id caseId {get; set;}
	public cComments[] comments{
		get{
			List<cComments> comments = new List<cComments>();
			for(CaseComment comment : [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody From CaseComment c where ParentId = :caseId order by c.LastModifiedDate desc])
			{
				cComments tempcComment = new cComments();
				tempcComment.cComment = comment;
				
				// Build String to display.
				tempcComment.commentText = '<b>Created By: <a href=\'/' + comment.CreatedBy.Id + '\'>' + comment.CreatedBy.Name + '</a> (' + comment.CreatedDate.format() + ') | ';
				tempcComment.commentText += 'Last Modified By: <a href=\'/' + comment.LastModifiedBy.Id + '\'>' +  comment.LastModifiedBy.Name + '</a> (' + comment.LastModifiedDate.format() + ')</b><br>';
				tempcComment.commentText += comment.CommentBody;
				
				if(comment.IsPublished) {
					tempcComment.PublicPrivateAction = 'Make Private';
					tempcComment.PublicPrivateStatus = 'Public';
				}
				else {
					tempcComment.PublicPrivateAction = 'Make Public';
					tempcComment.PublicPrivateStatus = 'Private';
				}
				//Add to list
				comments.add(tempcComment);	
			}
			return comments;
		}
		
		set;
	}
		
	public PageReference NewComment()
	{
		PageReference pr = new PageReference('/00a/e?parent_id='+ caseId + '&retURL=%2Fapex%2FShareCaseWithDealer%3FcaseId%3D' + caseId);
		pr.setRedirect(true);
		return pr;
	}
	
	public PageReference deleteComment()
	{
		Id commentId = ApexPages.currentPage().getParameters().get('CommentId_d');
		
		for(cComments Comment : comments)
		{
			if(Comment.cComment.Id == commentId)
			{	
				delete Comment.cComment;				
				break;
			}
		}
		
		PageReference pg = new PageReference('/' + caseId);
		pg.setRedirect(true);
		return pg;
	}	
	
	public PageReference makePublicPrivate()
	{
		Id commentId = ApexPages.currentPage().getParameters().get('CommentId_p');
		for(cComments Comment : comments)
		{
			if(Comment.cComment.Id == commentId)
			{	
				Comment.cComment.IsPublished = !Comment.cComment.IsPublished;
				if(Comment.cComment.IsPublished) {
					Comment.PublicPrivateAction = 'Make Private';
					Comment.PublicPrivateStatus = 'Public';
				}
				else {
					Comment.PublicPrivateAction = 'Make Public';
					Comment.PublicPrivateStatus = 'Private';
				}
					
				update Comment.cComment;				
				break;
			}
		}
		PageReference pg = new PageReference('/apex/ShareCaseWithDealer?caseId=' + caseId);
		pg.setRedirect(true);
		return pg;
	}
	
	public class cComments {
	
		public CaseComment cComment {get; set;}
		public String commentText {get; set;}
		public String PublicPrivateAction {get; set;}
		public String PublicPrivateStatus {get; set;}
	}
}