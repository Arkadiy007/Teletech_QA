/**********************************************************************
Name: Schedule_Techline_New_CaseStgng_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Techline Case Staging Dataload jobs to run.
Run at 8:30 pm MT:
System.schedule('Techline New Dataload - Case', '0 30 20 * * ?', new Schedule_Techline_New_CaseStgng_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 2/11/2014 Created
***********************************************************************/
global class Schedule_Techline_New_CaseStgng_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CaseStaging
        Batch_Techline_New_CaseStaging_DataLoad csdl = new Batch_Techline_New_CaseStaging_DataLoad();
        Database.executeBatch(csdl);
    }
}