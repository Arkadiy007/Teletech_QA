/**********************************************************************
Name: Controller_StateListPage_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests ths Apex class Controller_StateListPage.

Related Page : Controller_StateListPage 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry	04/19/2011	Created                        
***********************************************************************/

@isTest
private class Controller_StateListPage_Test {
    private static Controller_StateListPage obj ; 
 
    static testmethod void testStateListPage() {
    	Exception e;
    	try {
	        test.startTest();
	        obj = new Controller_StateListPage();
	        test.stopTest();
    	} catch (Exception ex) {
    		e = ex;
    	}
        
        System.assert(e == null);
    }
}