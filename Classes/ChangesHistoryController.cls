public with sharing class ChangesHistoryController {
    Public Integer noOfRecords { get; set; }
    Public Integer noOfPages { get; set; }
    Public Integer size { get; set; }
    Public List<SelectOption> objectNames { get {
            List<SelectOption> objectNames = new List<SelectOption> ();
            objectNames.add(new SelectOption('null', '-- None --'));
            objectNames.add(new SelectOption('Part Incident Report', 'Part Incident Report'));
            objectNames.add(new SelectOption('Sorting Report', 'Sorting Report'));
            objectNames.add(new SelectOption('Monetary Claim', 'Monetary Claim'));

            return objectNames;

        } set; }
    Public String objectName { get; Set; }
    Public String recordName { get; set; }

    Public Boolean recordsFound { get; set; }
    Public Boolean initialSearch { get; set; }

	Public List<HistoryObject> AllHistoryObjects {get; Set;}

    Public List<HistoryObject> historyRecords { get; set; }

    public SetHistoryObjectClass setCon { get; set; }
    public List<String> headers { get { return new List<String> { 'Object Name', 'Record Name', 'Details', 'Modified By', 'Modification Date' }; } set; }


    public Class HistoryObjectList
    {
        public List<HistoryObject> HistoryObjects { get; set; }
    }

    public Class HistoryObject
    {
        public string recordId { get; set; }
        public string recordName { get; set; }
        public string objectName { get; set; }
        public string modifiedById { get; set; }
        public string modifiedByName { get; set; }
        public string description { get; set; }
        public datetime modificationDate { get; Set; }

        public HistoryObject() {
        }

    }
    public class SetHistoryObjectClass {
        public integer pagenumber { get; set; }
        public integer totalpages { get; set; }
        public integer pagesize { get; set; }
        public List<HistoryObject> HistoryObjectList { get; set; }
        public SetHistoryObjectClass(List<HistoryObject> HistoryObjectList, integer pagesize) {
            pagenumber = 1;
            this.pagesize = pagesize;
            this.HistoryObjectList = HistoryObjectList;
            totalpages = Integer.valueof(math.ceil((double) HistoryObjectList.size() / (double) pagesize));
        }

        public integer getPageNumber()
        {
            return pagenumber;
        }
        public integer getResultSize()
        {
            if (HistoryObjectList == null)
            {
                return null;
            }
            return HistoryObjectList.size();
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
        public list<HistoryObject> getRecords() {
            list<HistoryObject> custList = new list<HistoryObject> ();
            for (integer counter2 = (pagenumber - 1) * pagesize; counter2 < (math.min(pagenumber * pagesize, HistoryObjectList.size())); counter2++) {
                custList.add(HistoryObjectList.get(counter2));
            }
            return custList;
        }

    }

    Public ChangesHistoryController()
    {
        size = 10;
        objectName = '';
        recordName = '';
        getHistoryRecords();
        initialSearch = false;
    }

    public List<HistoryObject> searchForHistoryRecords() {
        String query = formQueryBasedOnParameters();
		Map<Id, Part_Incident_Report__Share> pirSharesForUser = new Map<Id, Part_Incident_Report__Share>();
		Map<Id, Sorting_Report__Share> srSharesForUser = new Map<Id, Sorting_Report__Share>();
		Map<Id, Monetary_Claim__Share> mcSharesForUser = new Map<Id, Monetary_Claim__Share>();
		Boolean isPortalUser = false;		


		Id contactId = getContactId(UserInfo.getUserId());
		if(contactId != null){
			Contact userContact = getContactInfo(contactId);
			isPortalUser = userContact.Account.RecordType.DeveloperName == 'Plant' || userContact.Account.RecordType.DeveloperName == 'Supplier';
		}

		if(isPortalUser){
			pirSharesForUser = getPirShares();
			srSharesForUser = getSRShares();
			mcSharesForUser = getMCShares();
		}

        List<HistoryObject> historyObjectsToReturn = new List<HistoryObject> ();
        for (EQANotification__c notification : Database.query(query)) {
			if(!isPortalUser || pirSharesForUser.containsKey(notification.Record_Id__c) || srSharesForUser.containsKey(notification.Record_Id__c)  || mcSharesForUser.containsKey(notification.Record_Id__c)){
				HistoryObject historyRecord = new HistoryObject();
				historyRecord.recordId = notification.Record_Id__c;
				historyRecord.recordName = notification.Record_Name__c;
				historyRecord.objectName = notification.Object_Name__c;
				historyRecord.modifiedById = notification.Modified_By__c;
				historyRecord.modifiedByName = notification.Modified_By__r.Name;
				historyRecord.description = notification.Description__c;
				historyRecord.modificationDate = notification.Modification_Date__c;

				historyObjectsToReturn.add(historyRecord);
			}
        }
        return historyObjectsToReturn;
    }

	private Map<Id, Part_Incident_Report__Share> getPirShares(){
		Map<Id, Part_Incident_Report__Share> sharesToReturn = new Map<Id, Part_Incident_Report__Share>();

		for(Part_Incident_Report__Share sharingRecord : [SELECT Id, ParentId FROM Part_Incident_Report__Share WHERE UserOrGroupId = :UserInfo.getUserId()]){
			sharesToReturn.put(sharingRecord.ParentId, sharingRecord);
		}

		return sharesToReturn;
	}

	private Map<Id, Sorting_Report__Share> getSRShares(){
		Map<Id, Sorting_Report__Share> sharesToReturn = new Map<Id, Sorting_Report__Share>();

		for(Sorting_Report__Share sharingRecord : [SELECT Id, ParentId FROM Sorting_Report__Share WHERE UserOrGroupId = :UserInfo.getUserId()]){
			sharesToReturn.put(sharingRecord.ParentId, sharingRecord);
		}

		return sharesToReturn;
	}

	private Map<Id, Monetary_Claim__Share> getMCShares(){
		Map<Id, Monetary_Claim__Share> sharesToReturn = new Map<Id, Monetary_Claim__Share>();

		for(Monetary_Claim__Share sharingRecord : [SELECT Id, ParentId FROM Monetary_Claim__Share WHERE UserOrGroupId = :UserInfo.getUserId()]){
			sharesToReturn.put(sharingRecord.ParentId, sharingRecord);
		}

		return sharesToReturn;
	}

    public String formQueryBasedOnParameters() {
        String query = 'SELECT Id, Description__c, Modification_Date__c, Modified_By__c, Modified_By__r.Name, Object_Name__c, Record_Id__c, Record_Name__c FROM EQANotification__c ';

        if (String.isNotBlank(recordName) && objectName != 'null') {
            query += 'WHERE Record_Name__c LIKE \'%' + recordName + '%\' AND Object_Name__c =\'' + objectName + '\' ';
        }
        else if (String.isNotBlank(recordName)) {
            query += 'WHERE Record_Name__c LIKE \'%' + recordName + '%\' ';
        }
        else if (objectName != 'null') {
            query += 'WHERE Object_Name__c = \'' + objectName + '\' ';
        }

        query += 'ORDER BY Modification_Date__c DESC LIMIT 50000';
        return query;
    }



    Public List<HistoryObject> getHistoryRecords()
    {
        List<HistoryObject> HistoryObjects = searchForHistoryRecords();
        if (HistoryObjects != null && HistoryObjects.size() > 0)
        {
            setCon = new SetHistoryObjectClass(HistoryObjects, size);
        }
        else
        {
            setCon = new SetHistoryObjectClass(new List<HistoryObject> (), size);
        }

        noOfRecords = setCon.getResultSize();
        noOfRecords = noOfRecords == null ? 0 : noOfRecords;
        recordsFound = noOfRecords > 0 ? true : false;

        Double dSize = (double) size;
        Double dRecords = (double) noOfRecords;
        Double dPages = Math.Ceil(dRecords / dSize);
        noOfPages = (Integer) dPages;

        List<HistoryObject> historyObjList = new List<HistoryObject> ();

        for (HistoryObject a : (List<HistoryObject>) setCon.getRecords()) {
            historyObjList.add(a);
        }
        return historyObjList;
    }



    public pageReference clear()
    {
        setCon = null;
        objectName = '';
        recordName = '';

        recordsFound = false;
        initialSearch = false;
        return null;
    }

    public pageReference refresh() {
        initialSearch = true;
        setCon = null;
        historyRecords = getHistoryRecords();

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
        historyRecords = setCon.getRecords();
    }

    public void last() {
        setCon.last();
        historyRecords = setCon.getRecords();
    }

    public void previous() {
        setCon.previous();
        historyRecords = setCon.getRecords();
    }

    public void next() {
        setCon.next();
        historyRecords = setCon.getRecords();
    }

    // Strings of xml for excel which should be dynamically generated
    Public String xlsHeader { get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public void prepareHistoryDataInfo() {
        objectName = ApexPages.currentpage().getparameters().get('objectNameExc');
        getHistoryRecords();
    }
	
	private Id getContactId(Id userID){
		List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userID LIMIT 1];

		if (currentUser.size() > 0){
			return currentUser[0].ContactId;
		}
		return null;
	}

	private Contact getContactInfo(Id contactId){
		return [SELECT Id, AccountId, Account.Name, Account.Supplier_Code__c, Account.RecordType.DeveloperName FROM Contact WHERE Id =:contactId][0];
	}

    public Pagereference redirectToExcel() {
        if (historyRecords.size() > 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You cannot export more than 1000 record'));
            return null;
        }

		AllHistoryObjects = new List<HistoryObject>();
        for (HistoryObject a : setCon.HistoryObjectList) {
			AllHistoryObjects.add(a);
		}


		for (HistoryObject a : AllHistoryObjects) {
            if (String.isNotBlank(a.objectName)) {
                a.objectName = a.objectName.replace('<br>', '&#10;');
            }
            if (String.isNotBlank(a.recordName)) {
                a.recordName = a.recordName.replace('<br>', '&#10;');
            }
            if (String.isNotBlank(a.description)) {
                a.description = a.description.replace('<br>', '&#10;');
            }
        }
        PageReference excelPage = new PageReference('/apex/ChangeHistoryExcel');
        return excelPage;
    }
}