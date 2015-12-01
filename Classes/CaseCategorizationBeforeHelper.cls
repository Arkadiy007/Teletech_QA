/**********************************************************************
  Name: CaseCategorizationBeforeHelper
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose: 
  Helper for Case_Categorization_Before trigger
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina    3/11/2015 Created to avoid recursive call of Case and Case Categorization triggers
  ***********************************************************************/
public class CaseCategorizationBeforeHelper { 
	// Static variables are local to the context of a Web request 
    // (or testMethod during a runTests call) 
    // Therefore, this variable will be initialized as false 
    // at the beginning of each Web request which accesses it. 

    private static boolean alreadyUpdatedCases = false;

    public static boolean hasAlreadyUpdatedCases() {
        return alreadyUpdatedCases;
    }

    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request 
    // (or testMethod) 
     
    public static void setAlreadyUpdatedCases() {
        alreadyUpdatedCases = true;
    }

}