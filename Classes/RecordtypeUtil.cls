/**********************************************************************
Name: RecordtypeUtil
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class returns the recordtype Id based on the name.
This eliminates the need to use a SOQL query to populate a
reordtypeId.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr     05/19/2014 Created
***********************************************************************/
public class RecordtypeUtil{
      public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName)
    {
        //Generate a map of tokens for all the Record Types for the desired object
       
       Map<String,Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

        if(!recordTypeInfo.containsKey(recordTypeName))
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');

        //Retrieve the record type id by name
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    public class RecordTypeException extends Exception{}
}