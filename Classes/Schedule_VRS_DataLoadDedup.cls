/**********************************************************************
Name: Schedule_VRS_DataLoadCleanUp
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class allows the Apex Batchable cleaning up Vehicle Retail Sales data to be scheduled.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 06/07/2011 Created
***********************************************************************/
global class Schedule_VRS_DataLoadDedup implements Schedulable {
   global void execute(SchedulableContext SC) {
      Batch_VRS_DataLoadDedup vrsDedup = new Batch_VRS_DataLoadDedup();
      Database.executeBatch(vrsDedup);
   }
}