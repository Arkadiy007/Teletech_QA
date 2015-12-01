/**********************************************************************
Name: Schedule_DealerPortal_SetManagerFields
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the Dealer Portal Set Manager Fields job to run.
Run at 5am MT:
System.schedule('Dealer Portal Set Manager Fields', '0 0 5 * * ?', new Schedule_DealerPortal_SetManagerFields());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      06/07/2013 Changed to call multiple Batch jobs
***********************************************************************/
global class Schedule_DealerPortal_SetManagerFields implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_DealerPortal_SetManagerFields batch = new Batch_DealerPortal_SetManagerFields();
        Database.executeBatch(batch);
    }
}