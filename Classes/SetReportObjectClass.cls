public class SetReportObjectClass {
        public integer pagenumber { get; set; }
    	public integer totalpages { get { if ( ReportObjectList != null){return Integer.valueof(math.ceil((double) ReportObjectList.size() / (double) pagesize));} else {return Integer.valueof(math.ceil((double) paginatedSObjectList.size() / (double) pagesize));}} set; }
        public integer pagesize { get; set; }
        public List <QuickReportsController.ReportObject > ReportObjectList { get; set; }

		public List<sObject> paginatedSObjectList {get; set;}
		
		public List <QuickReportsController.ReportObject > ExportableObjectList { get; set; }
		public List <String> ExportableObjectLabels {get; set; }

        public SetReportObjectClass(List <QuickReportsController.ReportObject > ReportObjectList, integer pagesize) {
            pagenumber = 1;
            this.pagesize = pagesize;
            this.ReportObjectList = ReportObjectList;
        }

		public SetReportObjectClass(List <sObject> SObjectList, Integer pagesize){
			pagenumber = 1;
            this.pagesize = pagesize;
            this.paginatedSObjectList = SObjectList;
		}

        public integer getPageNumber()
        {
            return pagenumber;
        }
        public integer getResultSize()
        {
			if (paginatedSObjectList != null){
				return paginatedSObjectList.size();
			}

            else if (ReportObjectList == null){
                return null;
            }

            return ReportObjectList.size();
        }
        public boolean gethasprevious() {
            return(pagenumber != 1);
        }
        public boolean gethasnext() {
            return(pagenumber != totalpages);
        }
        public pagereference Previous() {
            if (gethasprevious())
            pagenumber--;
            return null;
        }
        public pagereference next() {
            if (gethasnext())
            pagenumber++;
            return null;
        }

        public void first()
        {
            pagenumber = 1;
        }
        public void last()
        {
            pagenumber = totalpages;
        }
        public List <QuickReportsController.ReportObject > getRecords() {
            List <QuickReportsController.ReportObject > custList = new list <QuickReportsController.ReportObject > ();
            for (integer counter2 = (pagenumber - 1) * pagesize; counter2 <(math.min(pagenumber * pagesize, ReportObjectList.size())); counter2++) {
                custList.add(ReportObjectList.get(counter2));
            }
            return custList;
        }

		// Used for paginated soql pages
		public List <sObject > getRecords(Boolean isSObject) {
            List <sObject > custList = new list <sObject > ();
            for (integer counter2 = (pagenumber - 1) * pagesize; counter2 <(math.min(pagenumber * pagesize, paginatedSObjectList.size())); counter2++) {
                custList.add(paginatedSObjectList.get(counter2));
            }
            return custList;
        }
    }