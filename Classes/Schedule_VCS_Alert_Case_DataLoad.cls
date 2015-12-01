/**********************************************************************
Name: Schedule_VCS_Alert_Case_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the VCS Alert Case Dataload job to run.
Run at 4:30am MT:
System.schedule('Staging DataLoad - Case', '0 30 4 * * ?', new Schedule_VCS_Alert_Case_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      07/05/2013 Created
***********************************************************************/
global class Schedule_VCS_Alert_Case_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_VCS_Alert_Case_DataLoad vcsDataLoad = new Batch_VCS_Alert_Case_DataLoad();
        Database.executeBatch(vcsDataLoad);
    }
}