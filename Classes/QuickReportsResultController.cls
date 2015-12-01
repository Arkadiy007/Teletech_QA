public class QuickReportsResultController {
	
    Public List <QuickReportsController.ReportObject> reportRecords { get{return (List <QuickReportsController.ReportObject>) setCon.getRecords();} set; }
	Public SetReportObjectClass setCon { get; set; }
	Public String ReportName {get; set; }  

	Public Integer noOfRecords { get; set; }
    Public Integer noOfPages { get {return setCon.totalpages;} set; }
    Public Integer size { get; set; }
	
    Public Integer realSize {get {if(realSize == null) return size; else{return realSize;}} set;}
    
    
	public pageReference refresh() {
        setCon.pagesize = realSize;
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
        reportRecords = setCon.getRecords();
    }

    public void last() {
        setCon.last();
        reportRecords = setCon.getRecords();
    }

    public void previous() {
        setCon.previous();
        reportRecords = setCon.getRecords();
    }

    public void next() {
        setCon.next();
        reportRecords = setCon.getRecords();
    }

}