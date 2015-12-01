/**********************************************************************
Name: Schedule_DeleteOldCases_Dataload
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 2am MT on the first day of each month:
System.schedule('Staging DataLoad - Case', '0 0 2 1 * ?', new Schedule_DeleteOldCases_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      04/22/2013 Created
***********************************************************************/
global class Schedule_DeleteOldCases_Dataload implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // Delete old cases and backfeed
        Batch_DeleteOldCases_DataLoad deleteOldCasesDataLoad = new Batch_DeleteOldCases_DataLoad();
        Database.executeBatch(deleteOldCasesDataLoad);
    }
}