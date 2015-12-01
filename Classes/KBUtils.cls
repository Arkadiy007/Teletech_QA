/**********************************************************************
Name: KBUtils
Copyright © notice: Nissan Motor Company
======================================================
Purpose:

Knowledge Utilities
   
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Grant Liu 11/10/2011 Created
***********************************************************************/
public with sharing class KBUtils {
	private static final Map<String, Schema.SObjectField> KnowledgeArticleVersionFields = 
		KnowledgeArticleVersion.sObjectType.getDescribe().fields.getMap();
	
	/* Find suitable KB Lang value for this user. UserInfo.getLanguage should really do the trick, 
	   but let's idiot proof this. */
	public static String findKBLang() {
		String langField = 'en_US';
		Schema.SObjectField kavLangField = KnowledgeArticleVersionFields.get('Language');
		if(kavLangField != null && kavLangField.getDescribe().getType() == DisplayType.PICKLIST) {
			String uLang = UserInfo.getLanguage();
			List<Schema.PicklistEntry> entries = kavLangField.getDescribe().getPicklistValues();
			for(Schema.PicklistEntry entry : entries) {
				if(uLang.equals(entry.getValue())) {
					langField = entry.getValue();
					break;
				}
			}
		} else {
	        System.debug(Logginglevel.DEBUG, '@findKBLang - No language options, multi lingual may not be enabled or Language field is not picklist.' +
	        	' Language field:' + (kavLangField == null ? 'null' : kavLangField.getDescribe().getName()) + 
	        	' Language field is picklist:' + (kavLangField == null ? 'n/a' : String.valueOf(kavLangField.getDescribe().getType() == DisplayType.PICKLIST)));
		}
		return langField;
	}
	
	public static final Integer FALLBACK_DEFAULT = 1;
	public static Integer validDisplayLimit(Integer input) {
		return input <= 0 ? FALLBACK_DEFAULT : input;
	}
	
	/****************************************************
	 *					Test Methods    				*
	 ****************************************************/	
	static testMethod void testKBUtils() {
		System.assert(findKBLang() == UserInfo.getLanguage());
		
		System.assertEquals(1, validDisplayLimit(1));
		System.assertEquals(3, validDisplayLimit(3));
		System.assertEquals(150, validDisplayLimit(150));
		System.assertEquals(FALLBACK_DEFAULT, validDisplayLimit(0));
		System.assertEquals(FALLBACK_DEFAULT, validDisplayLimit(-234));
		System.assertEquals(FALLBACK_DEFAULT, validDisplayLimit(-99));
	}
}