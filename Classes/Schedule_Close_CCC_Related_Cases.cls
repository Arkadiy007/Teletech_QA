/**********************************************************************
Name: Schedule_Close_CCC_Related_Cases
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules a job to close CCC-related Cases
90 days after creation
Run at 12am MT every day:
System.schedule('Close CCC-Related Cases', '0 0 0 * * ?', new Schedule_Close_CCC_Related_Cases());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      04/22/2013 Created
***********************************************************************/
global class Schedule_Close_CCC_Related_Cases implements Schedulable {
    global void execute(SchedulableContext SC) {

        // Close CCC-Related Cases
        Batch_Close_CCC_Related_Cases closeCCCRelatedCases = new Batch_Close_CCC_Related_Cases();
        Database.executeBatch(closeCCCRelatedCases);
    }
}