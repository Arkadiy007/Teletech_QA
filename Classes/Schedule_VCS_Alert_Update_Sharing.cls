/**********************************************************************
Name: Schedule_VCS_Alert_Close
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the VCS Alert Case Update Sharing job to run.
Run at 12:15am MT every Sunday night:
System.schedule('Enrollment Alert - Update Sharing', '0 15 0 * 1 ?', new Schedule_VCS_Alert_Update_Sharing());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      12/19/2013 Created
***********************************************************************/
global class Schedule_VCS_Alert_Update_Sharing implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_VCS_Alert_Update_Sharing batch = new Batch_VCS_Alert_Update_Sharing();
        Database.executeBatch(batch);
    }
}