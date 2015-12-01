public class SRIEditExtension { 
    public ApexPages.StandardController srController {get; Set;}
    

    public SRIEditExtension(ApexPages.StandardController sc){
        srController = sc;
    }

    public PageReference save(){
        try {           
            upsert srController.getRecord();
        }
        catch (Exception e){
            if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                String errorMessage = prepareErrorMessage(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
                return null;
        }
		
       Sorting_Report_Item__c item = (Sorting_Report_Item__c) srController.getRecord();
       PageReference newPagePR = new PageReference('/'+String.valueOf(item.Sorting_Report__c));
	   newPagePR.setRedirect(true);
       return newPagePR;
    }
    
    public Pagereference saveAndNew(){
        try {           
            upsert srController.getRecord();

			Sorting_Report_Item__c item = (Sorting_Report_Item__c) srController.getRecord();
            PageReference newPagePR = new PageReference('/apex/SortingReportItemEdit?retURL=/'+String.valueOf(item.Sorting_Report__c));
            newPagePR.setRedirect(true);

            return newPagePR;
            
        }
        catch (Exception e){
            if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                String errorMessage = prepareErrorMessage(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
                return null;
        }
    }

    private String prepareErrorMessage(String errorMsg){
        if (errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            return errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
        }

        return errorMsg;
    }
}