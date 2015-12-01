/**********************************************************************
Name: ScheduledErrorLogDelete
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class allows the Apex Batchable deleting of old
Error_Log__c entries to be scheduled.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry		05/09/2011 Created
***********************************************************************/
global class ScheduledErrorLogDelete implements Schedulable {
   global void execute(SchedulableContext SC) {
      ErrorLogDelete eld = new ErrorLogDelete();
      Database.executeBatch(eld);
   }
}