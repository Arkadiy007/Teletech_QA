/**********************************************************************
Name: TestingCookies_Test 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for TestingCookies.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestingCookies_Test{
    
    public static testmethod void test1(){
    TestingCookies cook = new TestingCookies();
    
    cook.retrieveCookie();
    
    cook.createCookie();
    
    }
    
    
}