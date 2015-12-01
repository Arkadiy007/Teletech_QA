/**********************************************************************
Name: RecentContentCtrl
Copyright © notice: Nissan Motor Company
======================================================
Purpose:

Controller for left sidebar, Recent Content Knowledge Widget
   
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Grant Liu 11/10/2011 Created
***********************************************************************/
public with sharing class RecentContentCtrl {
	private static String langField = KBUtils.findKBLang();
	private static final KBC_Prefs__c kbPrefs = KBC_Prefs__c.getInstance();
	private static final Integer MAXTITLE_DEFAULT = 50;
	private static final Integer MAXMETA_DEFAULT = 45;
	private static final Integer MAXCONTENT_DEFAULT = 3;
	
	public List<CA_Specialist_Reference__kav> getArticles() {
		List<CA_Specialist_Reference__kav> result = new List<CA_Specialist_Reference__kav>();
		try {
			result = (List<CA_Specialist_Reference__kav>)
				Database.query('SELECT Id, Title, URLName, LastModifiedDate, ' +
							   		'(SELECT Id, ParentId, DataCategoryGroupName, toLabel(DataCategoryName), ' +
											'CreatedDate, CreatedById, IsDeleted, SystemModstamp ' +
								 	'FROM DataCategorySelections) ' +
							   'FROM CA_Specialist_Reference__kav ' + 
							   'WHERE PublishStatus=\'Online\' ' +
							   'AND Language =\'' + langField + '\' ' +
							   'ORDER BY LastModifiedDate DESC ' + 
							   'LIMIT ' + getMaxContent());
		} catch(Exception e) {
	        System.debug(Logginglevel.ERROR, '@getArticles query exception:' + e);			
		}

		/*for(CA_Specialist_Reference__kav kav : result) {
			List<CA_Specialist_Reference__DataCategorySelection> cats = 
				(List<CA_Specialist_Reference__DataCategorySelection>) kav.getSObjects('DataCategorySelections');
			System.debug(cats);
		}*/
		
		return result;
	}
	
	public Integer getMaxTitle() {
		if(kbPrefs == null || kbPrefs.Max_Recent_Content_Content_String_Size__c == null) {
			return MAXTITLE_DEFAULT;
		}
		return KBUtils.validDisplayLimit(Integer.valueOf(kbPrefs.Max_Recent_Content_Content_String_Size__c));
	}

	public Integer getMaxMeta() {
		if(kbPrefs == null || kbPrefs.Max_Recent_Content_Meta_String_Size__c == null) {
			return MAXMETA_DEFAULT;
		}
		return KBUtils.validDisplayLimit(Integer.valueOf(kbPrefs.Max_Recent_Content_Meta_String_Size__c));
	}
	
	private static Integer getMaxContent() {
		if(kbPrefs == null || kbPrefs.Max_Recent_Content__c == null) {
			return MAXCONTENT_DEFAULT;
		}
		return KBUtils.validDisplayLimit(Integer.valueOf(kbPrefs.Max_Recent_Content__c));
	}
	


	/****************************************************
	 *					Test Methods    				*
	 ****************************************************/	
	static testMethod void testRecentContentCtrl() {
		List<CA_Specialist_Reference__kav> KAVs = new List<CA_Specialist_Reference__kav>();
		for(Integer i = 0; i < getMaxContent(); i++) {
			KAVs.add(new CA_Specialist_Reference__kav(Title = 'Test' + i, URLName = 'Test' + i + DateTime.now().getTime(), Language = UserInfo.getLanguage()));		
		}
		upsert(KAVs);
		
		RecentContentCtrl ctrl = new RecentContentCtrl();
		KAVs = ctrl.getArticles();
		//System.assert(KAVs.size() == getMaxContent());		
	}	

	static testMethod void testLimits() {
		Integer maxRecentContent = MAXCONTENT_DEFAULT;
		Integer maxContentTitle = MAXTITLE_DEFAULT;
		Integer maxContentMeta = MAXMETA_DEFAULT;
		if(kbPrefs == null) {
			upsert new KBC_Prefs__c(Max_Recent_Content__c = maxRecentContent, Max_Recent_Content_Content_String_Size__c = maxContentTitle, 
				Max_Recent_Content_Meta_String_Size__c = maxContentMeta);
		} else {
			if(kbPrefs.Max_Recent_Content__c != null) {
				maxRecentContent = Integer.valueOf(kbPrefs.Max_Recent_Content__c);
			}
			if(kbPrefs.Max_Recent_Content_Content_String_Size__c != null) {
				maxContentTitle = Integer.valueOf(kbPrefs.Max_Recent_Content_Content_String_Size__c);
			}				
			if(kbPrefs.Max_Recent_Content_Meta_String_Size__c != null) {
				maxContentMeta = Integer.valueOf(kbPrefs.Max_Recent_Content_Meta_String_Size__c);
			}
		}
		
		System.assertEquals(getMaxContent(), KBUtils.validDisplayLimit(maxRecentContent));
		System.assertEquals(new RecentContentCtrl().getMaxTitle(), KBUtils.validDisplayLimit(maxContentTitle));
		System.assertEquals(new RecentContentCtrl().getMaxMeta(), KBUtils.validDisplayLimit(maxContentMeta));		
	}
}