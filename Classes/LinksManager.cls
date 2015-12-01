/**********************************************************************
Name: LinksManager
Copyright � notice: NMAC.
======================================================
Purpose:
This is a helper class to modify stored links for public ws
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/14/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public class LinksManager {
	public static String GetUrlForPage(String page) {
		if (IsPublicSite()) {
			return Site.getBaseUrl() + '/' + page;
		} else {
			return '/apex/' + page;
		}
	}

	public static String GetUrlForDocument(String urlSuffix) {
		if (IsPublicSite()) {
			String baseUrl = Site.getBaseUrl().removeEnd('/');
			return baseUrl + urlSuffix;
		} else {
			return urlSuffix;
		}
	}

	public static boolean IsPublicSite() {
		return Site.getBaseUrl() != '';
	}

}