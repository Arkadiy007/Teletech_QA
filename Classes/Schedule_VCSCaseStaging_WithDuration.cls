/**********************************************************************
Name: Schedule_VCSCaseStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the VCS Case Staging Dataload job to run.
Run at 4:00am MT:
System.schedule('Staging DataLoad - VCS Case', '0 0 4 * * ?', new Schedule_VCSCaseStaging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vivek Batham         12/19/2014 Created
***********************************************************************/
global class Schedule_VCSCaseStaging_WithDuration implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_VCSCaseStaging_LoadwithDuration batch = new Batch_VCSCaseStaging_LoadwithDuration();
        Database.executeBatch(batch);
    }
}