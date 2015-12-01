/**********************************************************************
Name: Schedule_VCS_Alert_Email
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the VCS Alert Case Email job to run.
Run at 12:30am MT:
System.schedule('Enrollment Alert - Reminder Emails', '0 30 0 * * ?', new Schedule_VCS_Alert_Email());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      11/25/2013 Created
***********************************************************************/
global class Schedule_VCS_Alert_Email implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_VCS_Alert_Email batch = new Batch_VCS_Alert_Email();
        Database.executeBatch(batch);
    }
}