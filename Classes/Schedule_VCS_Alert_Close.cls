/**********************************************************************
Name: Schedule_VCS_Alert_Close
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the VCS Alert Case Close job to run.
Run at 12:00am MT:
System.schedule('Enrollment Alert - Close Cases', '0 0 0 * * ?', new Schedule_VCS_Alert_Close());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      11/22/2013 Created
***********************************************************************/
global class Schedule_VCS_Alert_Close implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_VCS_Alert_Close batch = new Batch_VCS_Alert_Close();
        Database.executeBatch(batch);
    }
}