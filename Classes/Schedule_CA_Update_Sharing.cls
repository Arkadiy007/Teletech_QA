/**********************************************************************
Name: Schedule_CA_Update_Sharing
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the CA Case Update Sharing job to run.
Run at 1:15am MT every Sunday night:
System.schedule('Enrollment Alert - Update Sharing', '0 15 1 * 1 ?', new Schedule_CA_Update_Sharing());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      12/26/2013 Created
***********************************************************************/
global class Schedule_CA_Update_Sharing implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_CA_Update_Sharing batch = new Batch_CA_Update_Sharing();
        Database.executeBatch(batch);
    }
}