/**********************************************************************
Name: Schedule_Techline_New_CmtStg_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Batch_TechlineNewCommentStag_DataLoad jobs to run.
Run at 8:30 pm MT:
System.schedule('Techline New Dataload - Comments', '0 30 20 * * ?', new Schedule_Techline_New_CmtStg_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 2/11/2014 Created
***********************************************************************/
global class Schedule_Techline_New_CmtStg_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CaseStaging
        Batch_TechlineNewCommentStag_DataLoad csdl = new Batch_TechlineNewCommentStag_DataLoad();
        Database.executeBatch(csdl);
    }
}