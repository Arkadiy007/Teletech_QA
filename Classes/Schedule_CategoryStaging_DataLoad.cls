/**********************************************************************
Name: Schedule_CategoryStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 7pm MT:
System.schedule('Staging DataLoad - Category', '0 0 19 * * ?', new Schedule_CategoryStaging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      03/20/2012 Created
***********************************************************************/
global class Schedule_CategoryStaging_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CaseCategoryStage
        Batch_CaseCategoryStaging_DataLoad caseCategoryStageDataLoad = new Batch_CaseCategoryStaging_DataLoad();
        Database.executeBatch(caseCategoryStageDataLoad);
    }
}