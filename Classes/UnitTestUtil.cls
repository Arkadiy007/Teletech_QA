/**********************************************************************
Name: UnitTestUtil
Copyright © notice: Nissan Motor Company
======================================================
Purpose: Utility Class to check if a unit test is running. 

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Biswa Ray          02/16/2011 Created
         
***********************************************************************/

public class UnitTestUtil {
    private static UnitTestUtil oUnitTestUtil;
 
    public Boolean isUnitTesting {get;set;}
    public String mockResponse{get;set;}
 
    private UnitTestUtil() {
        isUnitTesting = false;
    }
 
    public static UnitTestUtil getInstance() {
        if (oUnitTestUtil == null) {
            oUnitTestUtil = new UnitTestUtil();
        }
        return oUnitTestUtil;
    }
 
}