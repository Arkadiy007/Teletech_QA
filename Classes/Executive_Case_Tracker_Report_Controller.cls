/**********************************************************************
Name: Executive_Case_Tracker_Report_Controller
Copyright � notice: Nissan Motor Company.
======================================================
Purpose:
This is a controller for Executive_Case_Tracker_Report_Excel and Executive_Case_Tracker_Reports_Page pages.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 9/11/2015 Created 
***********************************************************************/
public class Executive_Case_Tracker_Report_Controller {
    //Filters
    public List < String > recordTypes { get; set; }
    public Boolean executiveFlag { get; set; }

    //
    public Map < Id, Case > casesMap = new Map < Id, Case >();
    public Map<Id, List<Case_Categorization__c>> caseCategorizationsMap = new Map<Id, List<Case_Categorization__c>>();

    public List < SelectOption > recordTypesSO { get; set; }
    private transient Map < String, Schema.RecordTypeInfo > recordTypesMap { get; set; }

    public Executive_Case_Tracker_Report_Settings__c setting { get; set; }
	public SettingProxy settingProxyDate {get; set;}

	//Url parameters
	public String caseIdsSet;
	public String caseCatIds;

    public Executive_Case_Tracker_Report_Controller() {
        recordTypesSO = fillRecordTypesSelectOptions();
        executiveFlag = true;
        recordTypes = tryGetExistingRecordTypesSet();
		
    }

    /**
     * @description Main method which is invoked by "Generate Report" button 
     */
    public PageReference generateReport() {
        if (isValidationPassed()) {
			setRecordTypesSettings(recordTypes);
			setting.Last_Modified_Date_Filter_From__c = settingProxyDate.lastModifiedDateFilterFrom;
			setting.Last_Modified_Date_Filter_To__c = settingProxyDate.lastModifiedDateFilterTo;
			try {
				upsert setting;
			} catch (Exception e) {
				System.debug(e.getMessage());
			}

            List < Id > recordTypesIdsList = grtRecTypeIdsFromNames();
            Set<Id> recordTypesIdsSet = new Set<Id> (recordTypesIdsList);
					
            List <Case> cases = [SELECT Id, Contact.Account.Name, Servicing_Dealer__r.Name, Servicing_Dealer_Region__c, Exec_Received_Date__c, 
								ClosedDate, Description, Executive_Referral__c, Executive_Actions_To_Resolve__c, 
								Model_Year__c, Model_Line__c, Current_Mileage__c 
								FROM Case 
								WHERE RecordTypeId IN :recordTypesIdsSet
								AND Executive_Referral__c =: executiveFlag
								AND LastModifiedDate >=: setting.Last_Modified_Date_Filter_From__c
								AND LastModifiedDate <=: setting.Last_Modified_Date_Filter_To__c
								LIMIT 1001];
			if (cases.size() > 1000) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'More than 1000 records found. Please modify filters to reduce number of matching records'));
				return ApexPages.currentPage();
			}

            if (cases.size() > 0) {
                //Create Map with Ids as keys and cases as values
                casesMap = new Map < Id, Case > ();
				caseIdsSet = '';
                for (Case c : cases) {
                    casesMap.put(c.Id, c);
					caseIdsSet +=  String.valueOf(c.Id) + ',';
                }
				caseIdsSet = caseIdsSet.removeEnd(',');

                List < Case_Categorization__c > caseCategorizations = [SELECT Id, Case__c, Concern_Description__c, Category_Description__c FROM Case_Categorization__c WHERE Case__c IN :casesMap.keySet()];
                caseCategorizationsMap = new Map<Id, List<Case_Categorization__c>>();
                if(caseCategorizations.size() > 0) {
                    //Create Map with Case records ids as keys and Lists of Case_Categorization__c which are related to particular Case records as values
                    caseCategorizationsMap = getCaseToCaseCategorizationMap(caseCategorizations); 
                }

				caseCatIds = '';
				for(Id i : caseCategorizationsMap.keySet()) {
					caseCatIds += String.valueOf(i) + ',';
				}
				caseCatIds = caseCatIds.removeEnd(',');

                PageReference pageRef = Page.Executive_Case_Tracker_Report_Excel;
				
				pageRef.getParameters().put('caseIds', caseIdsSet);
				pageRef.getParameters().put('caseCatIds',caseCatIds);
				
				pageRef.setRedirect(true);

                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No Cases found matching filter criteria'));
            }
        }
        return null;
    }

    /**
     * @description Revert changed filters to the original state
     * @return PageReference 
     */
    public PageReference revertSettings() {
        getSettings();
        return ApexPages.currentPage();
    }

	public class SettingProxy {
		public DateTime lastModifiedDateFilterFrom {get; set;}
		public DateTime lastModifiedDateFilterTo {get; set;}

		 public SettingProxy(Executive_Case_Tracker_Report_Settings__c stng) {
			if (null != stng) {
				this.lastModifiedDateFilterFrom = stng.Last_Modified_Date_Filter_From__c;
				this.lastModifiedDateFilterTo = stng.Last_Modified_Date_Filter_To__c;
			} else {
				this.lastModifiedDateFilterFrom = DateTime.now().addDays(-7);
				this.lastModifiedDateFilterTo = DateTime.now();
			}
        }

		public SettingProxy() {}


	}

    /*---------------------------------------------------------------HELPERS------------------------------------------------------------------*/
    /**
     * @description Retrieves Case Record Types and put it to Record Types select option
     * @return List<SelectOption> 
     */
    private List < SelectOption > fillRecordTypesSelectOptions() {
        recordTypesMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        List < SelectOption > SO = new List < SelectOption > ();
        if (recordTypesMap.size() > 1) {
            for (String recTypeLabel : recordTypesMap.keySet()) {
                if (recordTypesMap.get(recTypeLabel).isAvailable()) {
                    SO.add(new SelectOption(recTypeLabel, recTypeLabel));
                }
            }
        }
        return SO;
    }

    /**
     * @description Tries to retrieve exixting set of Record Types names from Record Types Set 1 and 
      Record Types Set 2 fields of Executive Case Tracker Report Settings 
     * @return List<String> 
     */
    private List < String > tryGetExistingRecordTypesSet() {
        List < String > result = new List < String > ();

        try {
            result.addAll(setting.Record_Types_Set_1__c.split(','));
            result.addAll(setting.Record_Types_Set_2__c.split(','));
        } catch(Exception e) {
        }

        return result;
    }

    /**
     * @description Retrieves Default Organization Level Value of Executive_Case_Tracker_Report_Settings__c 
      or creates one
     * @return Executive_Case_Tracker_Report_Controller 
     */
    public void getSettings() {
        setting = Executive_Case_Tracker_Report_Settings__c.getOrgDefaults();
        if ((setting == null) || (setting.id == null)) {
			setting = new Executive_Case_Tracker_Report_Settings__c();
			insert setting;
			setting = Executive_Case_Tracker_Report_Settings__c.getOrgDefaults();
		}
		settingProxyDate = new SettingProxy(setting);
    }

    /**
     * @description Fills Record_Types_Set_1__c (and Record_Types_Set_2__c if it is needed) of 
      Executive_Case_Tracker_Report_Settings__c custom setting
     * @param recTypes selected Record Types
     */
    private void setRecordTypesSettings(List < String > recTypes) {
        setting.Record_Types_Set_1__c = '';
		setting.Record_Types_Set_2__c = '';
        for (String rt : recTypes) {
			if ((setting.Record_Types_Set_1__c.length() + rt.length()) <=255) {
				setting.Record_Types_Set_1__c = setting.Record_Types_Set_1__c + rt;
				if (setting.Record_Types_Set_1__c.length() < 255) {
					setting.Record_Types_Set_1__c += ',';
				}
			} else if ((setting.Record_Types_Set_2__c.length() + rt.length()) <=255) {
				setting.Record_Types_Set_2__c = setting.Record_Types_Set_2__c + rt;
				if (setting.Record_Types_Set_2__c.length() < 255) {
					setting.Record_Types_Set_2__c += ',';
				}
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Too much Record Types are selected'));
			}
        }
    }

    /**
     * @description Retrieve Ids of Selected Record Types
     */
    private List < Id > grtRecTypeIdsFromNames() {
        List < Id > result = new List < String > ();
        recordTypesMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        if (null != recordTypes && null != recordTypesMap) {
            for (String rt : recordTypes) {
                result.add(recordTypesMap.get(rt).getRecordTypeId());
            }
            return result;
        }
        return result;
    }

    /**
     * @description Performs validation of the filters values
     * @returns True if validation is passes otherwise false 
     */
    private Boolean isValidationPassed() {
        if(!(recordTypes.size() > 0)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'At least one Record Type should be selected'));
            return false;
        } else if (null == settingProxyDate.lastModifiedDateFilterFrom)  {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Last Modified Date Filter From should be filled'));
            return false;
        } else if (null == settingProxyDate.lastModifiedDateFilterTo)  {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Last Modified Date Filter To should be filled'));
            return false;
        }
		return true;
    }

    private Map<Id, List<Case_Categorization__c>> getCaseToCaseCategorizationMap(List<Case_Categorization__c> caseCategorizations) {
        Map<Id, List<Case_Categorization__c>> result = new  Map<Id, List<Case_Categorization__c>>();
        for (Case_Categorization__c cc : caseCategorizations) {
            if(result.containsKey(cc.Case__c)) {
                List<Case_Categorization__c> tempList = new List<Case_Categorization__c>(result.get(cc.Case__c));
                tempList.add(cc);
                result.put(cc.Case__c,tempList);
            } else {
                result.put(cc.Case__c, new List<Case_Categorization__c> {cc});
            }
        }
        return result;
    }

    /*****************************************************ExcelPage****************************************************/
	public Integer secondTableRowIndex {get; set;} 

	final static String DEFAULT_STYLE_NAME_FOR_CASE_DESCRIPTION = 'NormalTextLeftAlignment';

	final static String DEFAULT_UINDENTIFIED_REGION_NAME = 'Unidentified Region';
	final static String SOUTHEAST_REGION_NAME = 'Southeast Region';
	final static String NORTHEAST_REGION_NAME = 'Northeast Region';
	final static String MIDWEST_REGION_NAME = 'Midwest Region';
	final static String CENTRAL_REGION_NAME = 'Central Region';
	final static String WEST_REGION_NAME = 'West Region';
	final static String MOUNTAIN_REGION_NAME = 'Mountain Region';
	final static String NISSAN_MID_ATHLANTIC_REGION_NAME = 'Nissan Mid Atlantic Region';
	final static String NISSAN_NORTHWEST_REGION_NAME = 'Nissan Northwest Region';
	final static String WESTERN_REGION_NAME = 'Western Region';

	final static String INF_EAST_REGION_NAME = 'INF East  Region';
	final static String INF_WEST_REGION_NAME = 'INF West Region';
	final static String INF_NORTH_REGION_NAME = 'INF North  Region';
	final static String INF_SOUTH_REGION_NAME = 'INF South Region';

	final static String INF_EAST_REGION_STRING= 'Infiniti East Region';
	final static String INF_WEST_REGION_STRING = 'Infiniti West Region';
	final static String INF_NORTH_REGION_STRING = 'Infiniti North Region';
	final static String INF_SOUTH_REGION_STRING = 'Infiniti South Region';

	final static String DEALER_STATISTIC_NAME = 'Dealer';
	final static String CVT_STATISTIC_NAME = 'CVT';
	final static String NISSAN_DEALER_ISSUES_STRING = 'NISSAN DEALER ISSUES';

	//Words in Executive Actions To Resolve column which should be transferred to the new line
	final static String REVIEW_SPLITTER_STRING = 'REVIEW:';
	final static String ACTIONS_SPLITTER_STRING = 'ACTIONS:';
	final static String RESOLUTION_SPLITTER_STRING = 'RESOLUTION';

	//Words in Case Description column which should be transferred to the new line
	final static String EXECUTIVE_REFERRAL_SPLITTER_STRING = 'Exec';
	final static String LETTER_SPLITTER_STRING = 'Letter';
	final static String EMAIL_SPLITTER_STRING = 'Email';
	final static String PHONE_SPLITTER_STRING = 'Phone';
	final static String CALL_SPLITTER_STRING = 'Call';
	final static String VOICEMAIL_SPLITTER_STRING = 'Voicemail';
	final static String REFRRRED_SPLITTER_STRING = 'Referred';
	final static String CUSTOMER_SPLITTER_STRING = 'Customer';

	// Strings of xml for excel which should be dynamically generated
	Public String xlsHeader {get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
	}

	public String rowFirstPart {get {
			return '<Cell ss:StyleID="NormalText"><Data ss:Type="String">';
		} set;} 
	public String rowSecondPart {get {
			return '</Data></Cell>';
		} set;} 

	public String worksheetOptionsOpenTag {get {
			return '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
		} set;}

	public String worksheetOptionsCloseTag {get {
			return '</WorksheetOptions>';
		} set;}
	//Highlighting
	public List<String> stylesList {get; set;}
	private Map<String, String> usersToColorsMap {get; set;}
	
	//For the last Statistic Table
	public Map<String, Integer> regionStatisticMap {get; set;}
	public Map<String, Integer> dealerAndCVTStatisticMap {get; set;}
	public String statisticString {get; set;}
	//

	public String weekDate {get; set;}
	public String myModelMileageColumnName {get; set;}
	
    Public List<TabelRepresentation> casesReportData {get; set;}

	private Set<String> executionActionsSplitterWords {get; set;}
	private Set<String> caseDescriptionSplitterWords {get; set;}

	
	public void initializeDataWrapper() {
		getSettings(); 
		String caseIdsSet = ApexPages.currentpage().getparameters().get('caseIds');
		String caseCatIdsSet = ApexPages.currentpage().getparameters().get('caseCatIds');

		List <String> caseIdsList = new List <String>();
		caseIdsList.addAll(caseIdsSet.split(','));

		List <String> caseCatIdsList = new List <String>();
		caseCatIdsList.addAll(caseCatIdsSet.split(','));

		List <Case> cases = [SELECT Id, Contact.Account.Name, Servicing_Dealer__r.Name, Servicing_Dealer__r.Dealer_Code__c, Servicing_Dealer_Region__c, Exec_Received_Date__c, 
								ClosedDate, Description, Executive_Referral__c, Executive_Actions_To_Resolve__c, 
								Model_Year__c, Model_Line__c, Current_Mileage__c 
								FROM Case 
								WHERE Id IN :caseIdsList						
								LIMIT 1001];

		if (cases.size() > 0) {
                //Create Map with Ids as keys and cases as values
                casesMap = new Map < Id, Case > ();
				
                for (Case c : cases) {
                    casesMap.put(c.Id, c);
                }
		}

		List < Case_Categorization__c > caseCategorizations = [SELECT Id, Case__c, Concern_Description__c, Category_Description__c 
																FROM Case_Categorization__c 
																WHERE Case__c IN :caseCatIdsList];	
		caseCategorizationsMap = new Map<Id, List<Case_Categorization__c>>();
                if(caseCategorizations.size() > 0) {
                    //Create Map with Case records ids as keys and Lists of Case_Categorization__c which are related to particular Case records as values
                    caseCategorizationsMap = getCaseToCaseCategorizationMap(caseCategorizations); 
                }

		initializeData(casesMap, caseCategorizationsMap);
	}
	
    public void initializeData(Map <Id, Case> c, Map<Id, List<Case_Categorization__c>> cc) {
        if(null != c && !c.isEmpty()) {
            casesReportData = new List<TabelRepresentation>();
			weekDate = setting.Last_Modified_Date_Filter_From__c.format('MM/dd');
			myModelMileageColumnName = 'MY &#10; Model &#10; Mileage';

			if (null != setting && null != setting.Highlighted_Persons__c && null != setting.Highlighting_Colors__c && 
					setting.Highlighted_Persons__c.length() > 0 && setting.Highlighting_Colors__c.length() > 0) {
				//creation styles for highlighting Case Descriptions
				usersToColorsMap = retrieveHightlightedUsersToColorsMap();
				stylesList = createStylesMarkup();
			}

			//Initialize regionStatisticMap for Region Statistic and dealerAndCVTStatisticMap
			regionStatisticMap = new Map<String, Integer>{
				SOUTHEAST_REGION_NAME => 0,
				NORTHEAST_REGION_NAME => 0,
				MIDWEST_REGION_NAME => 0,
				CENTRAL_REGION_NAME => 0,
				WEST_REGION_NAME => 0,
				MOUNTAIN_REGION_NAME => 0,
				NISSAN_MID_ATHLANTIC_REGION_NAME => 0,
				NISSAN_NORTHWEST_REGION_NAME => 0,
				WESTERN_REGION_NAME => 0,
				INF_WEST_REGION_NAME => 0,
				INF_EAST_REGION_NAME => 0,
				INF_NORTH_REGION_NAME => 0,
				INF_SOUTH_REGION_NAME => 0,
				DEFAULT_UINDENTIFIED_REGION_NAME => 0
			};
			dealerAndCVTStatisticMap = new Map<String, Integer>{
				CVT_STATISTIC_NAME => 0,
				DEALER_STATISTIC_NAME => 0
			};

			executionActionsSplitterWords = new Set<String> {REVIEW_SPLITTER_STRING,
															ACTIONS_SPLITTER_STRING,
															RESOLUTION_SPLITTER_STRING};

			caseDescriptionSplitterWords = new Set<String> {LETTER_SPLITTER_STRING,
															EMAIL_SPLITTER_STRING,
															PHONE_SPLITTER_STRING,
															CALL_SPLITTER_STRING,
															VOICEMAIL_SPLITTER_STRING,
															REFRRRED_SPLITTER_STRING,
															CUSTOMER_SPLITTER_STRING};

            for (Id i : c.keySet()) {
				String color = getColorOfCurrentCaseDescription(c.get(i));
                casesReportData.add(new TabelRepresentation(c.get(i), cc.get(i), color, executionActionsSplitterWords, caseDescriptionSplitterWords));

            }   
        }
    }

	private String getColorOfCurrentCaseDescription (Case c) {
		if (null != usersToColorsMap && !usersToColorsMap.isEmpty() && null != c.Description){
			for (String name : usersToColorsMap.keySet()) {
				if (c.Description.contains(name)) {
					return usersToColorsMap.get(name);
				}
			}
		}
		return DEFAULT_STYLE_NAME_FOR_CASE_DESCRIPTION;
	}
	
	/**
	* @description Method which generates style code bits for highlighting particular Case Description
	*/
	private List<String> createStylesMarkup () {
		List<String> result = new List<String>();
		List<String> colorsList = usersToColorsMap.values();

		for (String color : colorsList) {
			String style = '';
			style += '<Style ss:ID="';
			style += color;
			style += '">' +
                    '<Alignment ss:Vertical="Top" ss:Horizontal="Left" ss:WrapText="1"/ >' + 
                    '<Borders > ' +
                        '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/ >' + 
                    '</Borders > <Font ss:FontName="Calibri" x:Family="Swiss"/ >' + 
                    '<Interior ss:Color="';
			style += color;
			style += '" ss:Pattern="Solid"/ >' + 
                    '<NumberFormat/ >' +
                    '<Protection/ >' +
					'</Style>';
			result.add(style);
		}
		return result;
	}

	/**
	* @description This method splits Highlighted_Persons__c and Highlighting_Colors__c and then connect it to Map<String, String> usersToColorsMap
	*/
	private Map<String, String> retrieveHightlightedUsersToColorsMap() {
		// Split Highlighted_Persons__c
		List <String> usersList = new List <String> ();

        try {
            usersList.addAll(setting.Highlighted_Persons__c.split(','));
        } catch(Exception e) {
        } 	

		// Split Highlighting_Colors__c
		List <String> colorsList = new List <String> ();

        try {
            colorsList.addAll(setting.Highlighting_Colors__c.split(','));
        } catch(Exception e) {
        } 	

		Map<String, String> result = new Map<String, String>();
		for (Integer i = 0; i < usersList.size(); i++) {
			result.put(usersList[i], colorsList[i]);
		}

		return result;
	}
	
	class TabelRepresentation {
        public String customerName {get; set;}
        public String dealer {get; set;}
        public String region {get; set;}
        public String execRecievedDate {get; set;}
        public String dateClosed {get; set;}
        public String myModelMileage {get; set;}
        public String concernDescription {get; set;}
        public String subcategoryDescription {get; set;}
        public String caseDescriptionWithXMLMarkup {get; set;}
        public String executiveActionsToResolve {get; set;}

        public TabelRepresentation(Case c, List<Case_Categorization__c> cc, String highlightColor, Set<String> splitterWords, Set<String> caseDescriptionSplitterWords) {
			//customerName
            this.customerName = c.Contact.Account.Name;
			//dealer
			this.dealer = c.Servicing_Dealer__r.Name;
			if (null != this.dealer && null != c.Servicing_Dealer__r.Dealer_Code__c) {
				this.dealer += '-' + c.Servicing_Dealer__r.Dealer_Code__c;
			}
			//region
			this.region = c.Servicing_Dealer_Region__c;
			//execRecievedDate
			if (null != c.Exec_Received_Date__c) {
				this.execRecievedDate = c.Exec_Received_Date__c.format();
			}
			//dateClosed
			if (null != c.ClosedDate) {
				this.dateClosed = c.ClosedDate.format('MM/dd/yyyy');
			}
			//myModelMileage
            this.myModelMileage = (null == c.Model_Year__c) ? '' :  (c.Model_Year__c + '&#10;');
			this.myModelMileage += (null == c.Model_Line__c) ? '' : (c.Model_Line__c + '&#10;');
			this.myModelMileage += (null == c.Current_Mileage__c) ? '' : String.valueOf(c.Current_Mileage__c);
			//concernDescription and subcategoryDescription
            this.concernDescription = '';
            this.subcategoryDescription = '';
            if(null != cc && cc.size() > 0) {
                for(Case_Categorization__c caseCat : cc) {
                    this.concernDescription += caseCat.Concern_Description__c + '&#10;';
                    this.subcategoryDescription += caseCat.Category_Description__c + '&#10;';
                }
            }
			//caseDescriptionWithXMLMarkup
			String caseDescrStr = c.Description;
			if (null != c.Description) {
				caseDescrStr = deleteServiceCharackters(c.Description);
				caseDescrStr = createStackingText(caseDescrStr, caseDescriptionSplitterWords);
			} else {
				caseDescrStr = '';
			}
			caseDescrStr = createStackingText(caseDescrStr, caseDescriptionSplitterWords);
            this.caseDescriptionWithXMLMarkup = createCaseDescriptionMarkup(highlightColor, caseDescrStr);
			//executiveActionsToResolve
			if (null != c.Executive_Actions_To_Resolve__c) {
				String str = deleteServiceCharackters(c.Executive_Actions_To_Resolve__c);
				this.executiveActionsToResolve = createStackingText(str, splitterWords);
			}
        }

		private String createCaseDescriptionMarkup (String color,  String caseDescr){
			String result = '';
			result += '<Cell ss:StyleID="';
			result += color;
			result += '"><Data ss:Type="String">';
			result += caseDescr;
			result += '</Data></Cell>';

			return result;
		}

		private String deleteServiceCharackters(String str) {
			String result = str.replaceAll('<', '_');
			result = result.replaceAll('</', '_');
			result = result.replaceAll('/>', '_');
			result = result.replaceAll('>', '_');

			return result;
		}

		private String createStackingText (String str, Set<String> splitterWords ){
			String result = '';
			Integer currentIndex = 0;
			for (String splitter : splitterWords) {
				Integer i = str.indexOf(splitter);
				if (i > 0) {
					result += str.substring(currentIndex, i - 1) + '&#10;';
					currentIndex = i;
				}
			}
			if (currentIndex != 0) {
				result += str.substring(currentIndex) ;
			} else {
				result = str;
			}
			return result;
		}
	}   
}