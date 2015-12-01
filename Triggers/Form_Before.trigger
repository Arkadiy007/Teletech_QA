/**********************************************************************
Name: Form_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Forms cannot be added to a closed case.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Yuli Fintescu    02/09/2012 Created
1.1 -  Bryan Fry        12/19/2012 Added clause to allow DPIC closed cases to have Forms added
***********************************************************************/
trigger Form_Before on Form__c (before insert, after insert, after update) {
    
    if(Trigger_Switch__c.getInstance(Label.Trigger_FormBefore) != null && Trigger_Switch__c.getInstance(Label.Trigger_FormBefore).Disabled__c){
        return;
    }
    
    if (Trigger.isInsert && Trigger.isbefore) {
       FormTriggerHelper.handlebeforeInsert(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
       FormTriggerHelper.handleAfterInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
    	FormTriggerHelper.handleAfterUpdate(Trigger.new);
    }
}