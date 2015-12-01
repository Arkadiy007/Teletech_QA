trigger StageRegionalAssignmentTrigger on Stage_Regional_Assignment__c (before insert, before update, before delete, after insert) {

    if(Trigger.isBefore && Trigger.isInsert){
            
        StageRegionalAssignmentHelper.handleBeforeInsert(Trigger.New);
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
    
       // StageRegionalAssignmentHelper.handleBeforeUpdate(Trigger.New);
        
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
    
        StageRegionalAssignmentHelper.handleAfterInsert(Trigger.New);    
            
    }
    
    if(Trigger.isbefore && Trigger.isDelete){
            
        StageRegionalAssignmentHelper.handleAfterDelete(Trigger.oldMap);    
        
    }    

}