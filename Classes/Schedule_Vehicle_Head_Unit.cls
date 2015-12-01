/**********************************************************************
Name: Schedule_Vehicle_Head_Unit
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules the job to determine and set the
Head_Unit__c field on Vehicles.
======================================================
History:

VERSION AUTHOR DATE DETAIL

1.0 - Bryan Fry     11/06/2013 Initial creation
***********************************************************************/
global class Schedule_Vehicle_Head_Unit implements Schedulable {
  global void execute(SchedulableContext SC) {
    Batch_Vehicle_Head_Unit batch = new Batch_Vehicle_Head_Unit();
    Database.executeBatch(batch);
  }
}