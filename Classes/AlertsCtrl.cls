/**********************************************************************
Name: AlertsCtrl
Copyright © notice: Nissan Motor Company
======================================================
Purpose:

Controller for left sidebar, Alerts Knowledge Widget
   
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Grant Liu 11/10/2011 Created
***********************************************************************/
public with sharing class AlertsCtrl {
	private static String langField = KBUtils.findKBLang();
	private static final KBC_Prefs__c kbPrefs = KBC_Prefs__c.getInstance();
	private static final Integer FALLBACK_DEFAULT = 1;
	private static final Integer MAXTITLE_DEFAULT = 60;
	private static final Integer MAXALERTS_DEFAULT = 3;
		
	public List<Alert__kav> getArticles() {
		List<Alert__kav> result = new List<Alert__kav>();
		try {
			result = (List<Alert__kav>)
				Database.query('SELECT Id, Title, URLName, LastModifiedDate, Criticality__c, ' +
							   		'(SELECT Id, ParentId, DataCategoryGroupName, toLabel(DataCategoryName), ' +
											'CreatedDate, CreatedById, IsDeleted, SystemModstamp ' +
									'FROM DataCategorySelections) ' +
							   'FROM Alert__kav ' + 
							   'WHERE PublishStatus=\'Online\' ' +
							   'AND Language =\'' + langField + '\' ' +
							   'ORDER BY LastModifiedDate DESC ' + 
							   'LIMIT ' + getMaxAlerts());
		} catch(Exception e) {
	        System.debug(Logginglevel.ERROR, '@getArticles query exception:' + e);			
		}
		return result;
	}

	public Integer getMaxTitle() {
		if(kbPrefs == null || kbPrefs.Max_Alert_Title_String_Size__c == null) {
			return MAXTITLE_DEFAULT;
		}
		return KBUtils.validDisplayLimit(Integer.valueOf(kbPrefs.Max_Alert_Title_String_Size__c));
	}
	
	private static Integer getMaxAlerts() {
		if(kbPrefs == null || kbPrefs.Max_Sidebar_Alerts__c == null) {
			return MAXALERTS_DEFAULT;
		}
		return KBUtils.validDisplayLimit(Integer.valueOf(kbPrefs.Max_Sidebar_Alerts__c));
	}

	/****************************************************
	 *					Test Methods    				*
	 ****************************************************/	
	static testMethod void testAlertsCtrl() {
		List<Alert__kav> KAVs = new List<Alert__kav>();
		for(Integer i = 0; i < getMaxAlerts(); i++) {
			KAVs.add(new Alert__kav(Title = 'Test' + i, URLName = 'Test' + i + DateTime.now().getTime(), Language = UserInfo.getLanguage()));		
		}
		upsert(KAVs);

		AlertsCtrl ctrl = new AlertsCtrl();
		KAVs = ctrl.getArticles();
		// Commented out by Bryan Fry - KAVs inserted here get PublishStatus = 'Draft', but ctrl.getArticles() only
		// returns 'Online; articles.  PublishStatus is not writeable so we can't just set that on the new
		// records. If there is some way to trigger the status to move forward from within this Test coverage,
		// that would work, but I don't know of a way.
		//System.assert(KAVs.size() == getMaxAlerts());		
	}
	
	static testMethod void testLimits() {
		Integer maxSidebarAlerts = MAXALERTS_DEFAULT;
		Integer maxAlertTitle = MAXTITLE_DEFAULT;
		if(kbPrefs == null) {
			insert new KBC_Prefs__c(Max_Sidebar_Alerts__c = maxSidebarAlerts, Max_Alert_Title_String_Size__c = maxAlertTitle);
		} else {
			if(kbPrefs.Max_Sidebar_Alerts__c != null) {
				maxSidebarAlerts = Integer.valueOf(kbPrefs.Max_Sidebar_Alerts__c);
			}
			if(kbPrefs.Max_Alert_Title_String_Size__c != null) {
				maxAlertTitle = Integer.valueOf(kbPrefs.Max_Alert_Title_String_Size__c);
			}				
		}
		
		System.assertEquals(getMaxAlerts(), KBUtils.validDisplayLimit(maxSidebarAlerts));		
		System.assertEquals(new AlertsCtrl().getMaxTitle(), KBUtils.validDisplayLimit(maxAlertTitle));
	}
}