public class PIRCommentEditExtension {
	public ApexPages.StandardController pirCommentController {get; Set;}
	

	public PIRCommentEditExtension(ApexPages.StandardController sc){
		pirCommentController = sc;
	
	}

	public PageReference save(){
		pirCommentController.save();

		if (ApexPages.currentPage().getParameters().containsKey('retURL')){
			return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
		}

		return pirCommentController.cancel();
	}
	
	public Pagereference saveAndNew(){
		pirCommentController.save();
		
		PageReference newPagePR = new PageReference('/apex/PIRCommentEdit');
		newPagePR.getParameters().putAll(ApexPages.currentPage().getParameters());
		newPagePR.setRedirect(true);

		return newPagePR;
	}
 }