/**********************************************************************
  Name: PreCall_Service_Methods
  Copyright ?? notice: Nissan Motor Company
  ======================================================
  Purpose:
  PreCall_Service_Methods class contains methods which are used in the PreCall 

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev 10/07/2015 Created
  ***********************************************************************/
global class PreCall_Service_Methods { 
    @InvocableMethod
    public static List<String> getTrimedJpbLineNumber(List<String> jlNumber) {
        List<String> result = new List<String>();
        result.add(jlNumber[0].deleteWhitespace());
        return result;
    }

}