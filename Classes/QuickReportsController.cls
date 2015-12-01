public class QuickReportsController {

	Public String reportName { get; set; }
	Public Set<String> allReportNames {get {return new Set<String>(reportName.split(','));} }
	Public List<SelectOption> reportNames { get; set; }

	Public List<SearchResult> searchResults {get; set;}

    Public Boolean initialSearch { get; set; }


	// Strings of xml for excel which should be dynamically generated
	Public String xlsHeader {get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
	}

	Public Boolean isReport {get; set;}

	Public String seletedReportForExport {get; set;}
	Public List <QuickReportsController.ReportObject > allRecords { get; set;}
	Public List <String > reportFieldsList { get; set;}

	Public static List <QuickReportsController.ReportObject > allRecordsCached { get; set;}
	Public static List <String > reportFieldsListCached { get; set;}
 

    Private Map<String, List<EQA_Quick_Reports_Fields__c>> reportFieldsByReportName { get; set; }

	Public Boolean paramsFound { get; set; }

    Public Map<String, String> objectAPINameByReportName  {get; set;}
    Public Map<String, String> stringReportFilters {get; set;}
	Public Map<String, Boolean> booleanReportFilters {get; set;}
    Public Map<String, String> reportFiltersAPINames {get; set;}
	Public Map<String, String> prefilledReportFilters {get; set;}


	/* Date filters */
	Public List<SelectOption> dateFiltersOptions {get; set;}
	Public Set<String> dateFiltersSet {get; set;}
	Public String selectedDateFieldAPIName {get; set;}
	Public Date startTimeFilter {get; set;}
	Public Date endTimeFilter {get; set;}
	Public Datetime fixedEndTimeFilter {get {   TimeZone tz = UserInfo.getTimeZone();
											Integer timeOffset = tz.getOffset(startTimeFilter) / (60 * 60 * 1000);
											return Datetime.newInstance(endTimeFilter, Time.newInstance(0,0,0,0)).addHours(timeOffset).addDays(1);
									    } set;}
	Public Datetime fixedStartTimeFilter {get {    TimeZone tz = UserInfo.getTimeZone();
											Integer timeOffset = tz.getOffset(endTimeFilter) / (60 * 60 * 1000);
											return Datetime.newInstance(startTimeFilter, Time.newInstance(0,0,0,0)).addHours(-timeOffset);
									    } set;}

    Public Map<String, Map<String, String>> displayFields {get; set;}
    Public Map<String, Map<String, String>> selectableFields {get; set;}
    Public Map<String, Map<String, String>> reportFields {get; set;}
    Public Map<String, Map<String, String>> lookupFields {get; set;}
    Public String reportFiltersString {get; set;}

	public Class SearchResult{
		Public String reportName { get; set; }
		Public Integer noOfRecords { get; set; }
		Public Integer noOfPages { get; set; }
		

		Public Integer size { get; set; }
		Public List<String> displayFieldsList {get; set;}
   
        Public Boolean recordsFound { get; set; }
		Public SetReportObjectClass setCon { get; set; }

		Public SearchResult(SetReportObjectClass setOfObject, String rprtName, Integer pageSize, Integer numOfRecords, Integer numOfPages, Boolean rcrdsFound, List<String> displayFldList){
			reportName = rprtName;
			noOfRecords = numOfRecords;
			noOfPages = numOfPages;
			size = pageSize;
			recordsFound = rcrdsFound;
			setCon = setOfObject;
			displayFieldsList = displayFldList;
		}
	}

    public Class ReportObjectList{
        public List <ReportObject > ReportObjects { get; set; }
    }

    public Class ReportObject{
        public List<ReportField> fieldsList {get; set;}
      
        public ReportObject(sObject objectToFormReport, Set<String> fieldToShow, Map<String, String> lookupFields){
            fieldsList = new List<ReportField>();

            for(String fieldApiName : fieldToShow){
                if (lookupFields.containsKey(fieldApiName)){
                    String relationshipName = fieldApiName;

                    if (fieldApiName.contains('__c')){
                        relationshipName = fieldApiName.substringBefore('__c') + '__r';
                    }

                     fieldsList.add(new ReportField(String.valueOf(objectToFormReport.getSObject(relationshipName).get('Name')), fieldApiName, String.valueOf(objectToFormReport.get(fieldApiName))));
                }
                else if(fieldApiName.equals('Name')){
                    fieldsList.add(new ReportField(String.valueOf(objectToFormReport.get(fieldApiName)), fieldApiName, String.valueOf(objectToFormReport.get('Id'))));
                } 
                else{
                    fieldsList.add(new ReportField(String.valueOf(objectToFormReport.get(fieldApiName)), fieldApiName));
                }
            }
         
        }

    }

    public Class ReportField{
       public String value {get; set;}
       public String apiName {get; set;}
       public Boolean isLookup {get; set;}
       public String lookupId {get; set;}

       public ReportField(String value, String apiName, String lookupId){ 
            this.value = value;
            this.apiName = apiName;
            this.isLookup = true;
            this.lookupId = lookupId;
       }
       public ReportField(String value, String apiName){ 
            this.value = value;
            this.apiName = apiName;
            this.isLookup = false;
       }
    }


    Public QuickReportsController(){
        populateCustomSettings();
        populateReportNames();
        objectAPINameByReportName = obtainObjectAPINames();
        paramsFound = false;
		isReport = false;
        initialSearch = false;
		startTimeFilter = Date.today();
		endTimeFilter = Date.today();

		
    }

	public void prepareReportDataInfo(){
		populateCustomSettings();
        populateReportNames();
		isReport = true;
        objectAPINameByReportName = obtainObjectAPINames();

		reportName = ApexPages.currentpage().getparameters().get('reportName');
		reportFiltersString = ApexPages.currentpage().getparameters().get('reportFiltersString');
		startTimeFilter = Date.valueOf(ApexPages.currentpage().getparameters().get('startTimeLimit'));
		endTimeFilter = Date.valueOf(ApexPages.currentpage().getparameters().get('endTimeLimit'));
		getFieldsMaps();

		reportFieldsList = new List<String>(reportFields.get(reportName).keySet());
		allRecords = searchForReportRecords(true, reportName);
	}


    public List <ReportObject > searchForReportRecords(Boolean isReport, String rprtName){
        List<ReportObject> ReportObjectsToReturn = new List<ReportObject>();
 
         
        String query = formQueryBasedOnParameters(rprtName);

		
        for(sObject recordObject : Database.query(query)){
            Set<String> fieldsToBuildObject = new Set<String>();
            if (!isReport){
                fieldsToBuildObject = getFieldsThatAreRequiredToBeShown(rprtName);
            }
            else{
                fieldsToBuildObject = getFieldsThatAreRequiredToBeReported(rprtName);
            }
            
            ReportObject reportObj = new ReportObject(recordObject, fieldsToBuildObject, lookupFields.get(rprtName));
            
            ReportObjectsToReturn.add(reportObj);
        }
        

        return ReportObjectsToReturn;
    }

    public String formQueryBasedOnParameters(String repName){
        String report  = getObjectNameBasedOnReportName(repName);
        String fieldLists = getFieldsThatAreRequiredToBeSelectedQuery(repName);

        String query = 'SELECT ' + fieldLists + ' FROM ' + report ;


        Boolean isWhereClauseAdded = false;

		if (!isReport){
			reportFiltersString = '';

			for(String fieldLabel : stringReportFilters.keySet()){
				if(String.isNotBlank(stringReportFilters.get(fieldLabel))){
					if(!isWhereClauseAdded){
						reportFiltersString += ' WHERE ';
						isWhereClauseAdded = true;
					}
					reportFiltersString += ' ' + reportFiltersAPINames.get(fieldLabel) + ' = \'' + stringReportFilters.get(fieldLabel) + '\' AND ';
				}   
			}

			for (String fieldLabel : prefilledReportFilters.keySet()){
				if(String.isNotBlank(prefilledReportFilters.get(fieldLabel))){
					if(!isWhereClauseAdded){
						reportFiltersString += ' WHERE ';
						isWhereClauseAdded = true;
					}
					if(fieldLabel != 'Plant'){
						reportFiltersString += ' ' + reportFiltersAPINames.get(fieldLabel) + ' = \'' + prefilledReportFilters.get(fieldLabel) + '\' AND ';
					}
					else{
						reportFiltersString += ' ' + reportFiltersAPINames.get(fieldLabel) + ' IN (';
						for(String actualPlant : prefilledReportFilters.get(fieldLabel).split(';')){
							if(String.isNotBlank(actualPlant)){
								reportFiltersString += ' \'' + actualPlant + '\' ,';
							}
						}
						reportFiltersString = reportFiltersString.substring(0, reportFiltersString.length()-1);
						reportFiltersString += ') AND';
					}
				}   
			}

			for(String fieldLabel : booleanReportFilters.keySet()){
				if(!isWhereClauseAdded){
					reportFiltersString += ' WHERE ';
					isWhereClauseAdded = true;
				}
				reportFiltersString += ' ' + reportFiltersAPINames.get(fieldLabel) + ' = ' + booleanReportFilters.get(fieldLabel) + ' AND ';

			}

			if (String.isNotBlank(selectedDateFieldAPIName)){
				if(!isWhereClauseAdded){
					reportFiltersString += ' WHERE ';
				}

				if(!dateFiltersSet.contains(selectedDateFieldAPIName)){
					reportFiltersString += ' ' + selectedDateFieldAPIName + ' > :fixedStartTimeFilter AND ';
					reportFiltersString += ' ' + selectedDateFieldAPIName + ' < :fixedEndTimeFilter AND ';
				}
				else{
					reportFiltersString += ' ' + selectedDateFieldAPIName + ' > :startTimeFilter AND ';
					reportFiltersString += ' ' + selectedDateFieldAPIName + ' < :endTimeFilter AND ';
				}
			}
		}
		query += reportFiltersString;
		if(query.contains(' AND')){
              query = query.substring(0, query.length()-4);
        }

        System.debug(query);



        query += ' ORDER BY Name LIMIT 50000';
        return query;
    }


    private void populateCustomSettings(){
        reportFieldsByReportName = new Map<String, List<EQA_Quick_Reports_Fields__c>>();

        for (EQA_Quick_Reports_Fields__c eqaQR : EQA_Quick_Reports_Fields__c.getAll().values()){
            if (reportFieldsByReportName.containsKey(eqaQR.Report_Name__c)){
                reportFieldsByReportName.get(eqaQR.Report_Name__c).add(eqaQR);
            }
            
            else{
                List<EQA_Quick_Reports_Fields__c> tempList = new List<EQA_Quick_Reports_Fields__c>();
                tempList.add(eqaQR);

                reportFieldsByReportName.put(eqaQR.Report_Name__c, tempList);
            }       
        }
    }

    private void populateReportNames(){
        reportNames = new List<SelectOption>();
    
        for (String reportName : reportFieldsByReportName.keySet()){
            reportNames.add(new SelectOption(reportName, reportName));
        }

    }
    
    private void getSearchableFields(String reportName){
        stringReportFilters = new Map<String, String>();
		booleanReportFilters = new Map<String, Boolean>();
        reportFiltersAPINames = new Map<String, String>();
		dateFiltersOptions = new List<SelectOption>();
		dateFiltersSet = new Set<String>();

        for (EQA_Quick_Reports_Filters__c repFilter : EQA_Quick_Reports_Filters__c.getAll().values()){
            if (repFilter.Report_Name__c == reportName && repFilter.Type__c == 'String'){
                stringReportFilters.put(repFilter.Field_Label__c, '');
                reportFiltersAPINames.put(repFilter.Field_Label__c, repFilter.Field_API_Name__c);
            }
			else if (repFilter.Report_Name__c == reportName && repFilter.Type__c == 'Boolean'){
                booleanReportFilters.put(repFilter.Field_Label__c, false);
                reportFiltersAPINames.put(repFilter.Field_Label__c, repFilter.Field_API_Name__c);
            }
			else if(repFilter.Report_Name__c == reportName && (repFilter.Type__c == 'Date' || repFilter.Type__c == 'Datetime')){
				if(repFilter.Type__c == 'Date'){
					dateFiltersSet.add(repFilter.Field_API_Name__c);
				}
                dateFiltersOptions.add(new SelectOption( repFilter.Field_API_Name__c, repFilter.Field_Label__c));
            }
        }
    }

    private String getObjectNameBasedOnReportName(String repName){     
        return objectAPINameByReportName.get(repName);
    }

    private String getFieldsThatAreRequiredToBeSelectedQuery(String repName){
        return String.join(selectableFields.get(repName).values(), ', ');
    }

    private Set<String> getFieldsThatAreRequiredToBeShown(String repName){
        return new Set<String>(displayFields.get(repName).values());
    }

    private Set<String> getFieldsThatAreRequiredToBeReported(String repName){
          return new Set<String>(reportFields.get(repName).values());
    }

    private Set<String> getFieldsThatAreRequiredToBeSelected(String repName){
        return new Set<String>(selectableFields.get(repName).values());
    }

    public void getParamsForSelectedReport(){
        getSearchableFields(reportName);
		selectedDateFieldAPIName = '';
		prefilledReportFilters = new Map<String, String>();
		lockRecords();
        paramsFound = true;
        searchResults = new List<SearchResult>();
        initialSearch = false;
    }


    Public void getreportRecords(){
		getFieldsMaps();

		for(String rprtName : allReportNames){
			List <ReportObject > ReportObjects = searchForReportRecords(false, rprtName);
			Integer size = 10; //default
			SetReportObjectClass setCon;

			if (ReportObjects != null && ReportObjects.size() > 0)
			{
				setCon = new SetReportObjectClass(ReportObjects, size);
			}
			else
			{
				setCon = new SetReportObjectClass(new List <ReportObject > (), size);
			}

			Integer noOfRecords = setCon.getResultSize();
			noOfRecords = noOfRecords == null ? 0 : noOfRecords;
			Boolean recordsFound = noOfRecords > 0 ? true : false;

			Double dSize = (double) size;
			Double dRecords = (double) noOfRecords;
			Double dPages = Math.Ceil(dRecords / dSize);
			Integer noOfPages = (Integer) dPages;

			setCon.ExportableObjectLabels = new List<String>(reportFields.get(rprtName).keySet());
			setCon.ExportableObjectList = searchForReportRecords(true, rprtName);

			searchResults.add(new SearchResult(setCon, rprtName, size, noOfRecords, noOfPages, recordsFound, new List<String>(displayFields.get(rprtName).keySet())));
		}

    }

	
	public Pagereference redirectToExcel(){	

		for (SearchResult sr : searchResults){
			if (sr.reportName == seletedReportForExport){
				allRecords = sr.setCon.ExportableObjectList;
				reportFieldsList = sr.setCon.ExportableObjectLabels;
			}
		}

		if(allRecords.size() > 1000){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You cannot export more than 1000 record'));
			return null;
		}

		PageReference excelPage = new PageReference('/apex/QuickReportsExcel');
		excelPage.getParameters().put('reportName',seletedReportForExport);
		excelPage.getParameters().put('reportFiltersString',reportFiltersString);
		excelPage.getParameters().put('startTimeLimit', String.valueOf(startTimeFilter));
		excelPage.getParameters().put('endTimeLimit', String.valueOf(endTimeFilter));
		excelPage.setRedirect(true);


		return excelPage;
	}

	// New functionality:
	private void lockRecords(){
		Id contactId = getContactId(UserInfo.getUserId());

		if (contactId != null){
			Contact userContact = getContactInfo(contactId);

			if (userContact.Account.RecordType.DeveloperName == 'Plant'){
				if (stringReportFilters.containsKey('Customer')){
					stringReportFilters.remove('Customer');
					prefilledReportFilters.put('Customer', userContact.Account.Name);
				}
				if(stringReportFilters.containsKey('Plant')){
					stringReportFilters.remove('Plant');
					prefilledReportFilters.put('Plant', userContact.Account.Plant__c);
				}
			}

			if (userContact.Account.RecordType.DeveloperName == 'Supplier'){
				if (stringReportFilters.containsKey('Supplier Name')){
					stringReportFilters.remove('Supplier Name');
					prefilledReportFilters.put('Supplier Name', userContact.Account.Name);
				}
				if (stringReportFilters.containsKey('Supplier Code')){
					stringReportFilters.remove('Supplier Code');
					prefilledReportFilters.put('Supplier Code', userContact.Account.Supplier_Code__c);
				}
			}
		}

	}

	private Id getContactId(Id userID){
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userID LIMIT 1][0];
		return currentUser.ContactId;
	}

	private Contact getContactInfo(Id contactId){
		return [SELECT Id, AccountId, Account.Name, Account.Supplier_Code__c, Account.Plant__c, Account.RecordType.DeveloperName FROM Contact WHERE Id =:contactId][0];
	}


    private void getFieldsMaps(){
		displayFields = new Map<String, Map<String, String>>();
		selectableFields = new Map<String, Map<String, String>>();
		reportFields = new Map<String, Map<String, String>>();
		lookupFields = new Map<String, Map<String, String>>();

		for (String rprtName : allReportNames){
				

				for (EQA_Quick_Reports_Fields__c quickReports : reportFieldsByReportName.get(rprtName)){
					
					if(!selectableFields.containsKey(rprtName)){
						selectableFields.put(rprtName, new Map<String, String>());
					}
					if(!lookupFields.containsKey(rprtName)){
							lookupFields.put(rprtName, new Map<String, String>());
					}
					if(!displayFields.containsKey(rprtName)){
							displayFields.put(rprtName, new Map<String, String>());
					}
					if(!reportFields.containsKey(rprtName)){
							reportFields.put(rprtName, new Map<String, String>());
					}

					selectableFields.get(rprtName).put(quickReports.Field_Label__c, quickReports.Field_API_Name__c);
					

					if (quickReports.isDisplayable__c){
						displayFields.get(rprtName).put(quickReports.Field_Label__c, quickReports.Field_API_Name__c);
					}
					if (quickReports.isLookup__c){
						lookupFields.get(rprtName).put(quickReports.Field_API_Name__c, quickReports.Field_Label__c);
					}
					if (quickReports.isReportable__c){
						reportFields.get(rprtName).put(quickReports.Field_Label__c, quickReports.Field_API_Name__c);
					}
				}
		}
    }
    

    private Map<String, String> obtainObjectAPINames(){
        Map<String, String> objAPINamesByRepName = new Map<String, String>();

        for(EQA_Quick_Reports_API_Names__c apiNameSetting: EQA_Quick_Reports_API_Names__c.getAll().values()){
            objAPINamesByRepName.put(apiNameSetting.Report_Name__c, apiNameSetting.Object_API_Name__c);
        }

        return objAPINamesByRepName;
    }
    
    public pageReference clear(){
        searchResults = new List<SearchResult>();
        getSearchableFields(reportName);
    
       
        initialSearch = false;
        return null;
    }

    public pageReference refresh() {
        initialSearch = true;
        searchResults = new List<SearchResult>();
        getReportRecords();

        return null;
    }

}