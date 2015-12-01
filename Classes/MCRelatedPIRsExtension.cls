public class MCRelatedPIRsExtension {
	private Monetary_Claim__c monetaryClaimRecord {get; set;} 
	public Boolean relatedRecordsAvailable {get; set;}
	
	Public List<Sorting_Report_Item__c>  sortingReportItems { get{return (List<Sorting_Report_Item__c> ) setCon.getRecords(true);} set; }
	Public SetReportObjectClass setCon { get; set; }

	Public Integer noOfRecords { get; set; }
    Public Integer noOfPages { get {return setCon.totalpages;} set; }
    Public Integer size { get; set; }


	public MCRelatedPIRsExtension(ApexPages.StandardController sc){
		monetaryClaimRecord =  [SELECT Id, Sorting_Report__c FROM Monetary_Claim__c WHERE Id =:sc.getId() LIMIT 1][0];
		size = 5;
		relatedRecordsAvailable = false;

		if (monetaryClaimRecord != null && monetaryClaimRecord.Sorting_Report__c != null){

			List<Sorting_Report_Item__c> SRItems = [SELECT Id, Name, PIR_Number__c, Reason__c, Reworked__c, No_Good__c, Sorting_Costs__c, Rework_Costs__c, No_Good_Material_Costs__c, PIR_Part_Number__c, PIR_Customer__c FROM Sorting_Report_Item__c WHERE Sorting_Report__c =:monetaryClaimRecord.Sorting_Report__c ORDER BY Name ASC];
			
			noOfRecords = SRItems.size();
			if(noOfRecords > 0){
				relatedRecordsAvailable = true;
				setCon = new SetReportObjectClass(SRItems, size);		
			} 
		}
	}

	
    
	public pageReference refresh() {
        setCon.pagesize = size;
        return null;
    }

    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {

            return(setCon == null || setCon.getPageNumber() == null) ? 1 : setCon.getPageNumber();
        }
        set;
    }

    public void first() {
        setCon.first();
    }

    public void last() {
        setCon.last();
    }

    public void previous() {
        setCon.previous();
    }

    public void next() {
        setCon.next();
    }

}