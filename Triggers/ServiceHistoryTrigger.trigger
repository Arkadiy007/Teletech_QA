trigger ServiceHistoryTrigger on Service_Repair_History__c (before insert, before update) {

    if (Trigger.isInsert && Trigger.isbefore) {
       ServiceHistoryTriggerHelper.handlebeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isbefore){
       ServiceHistoryTriggerHelper.handleBeforeUpdate(Trigger.new);
    }

}