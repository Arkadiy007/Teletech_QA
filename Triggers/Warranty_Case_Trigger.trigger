/**********************************************************************
Name: Warranty_case_Trigger
Copyright © notice: Nissan Motor Company., TeleTech eLoyalty
======================================================
Purpose:
Whenever a warranty case is updated and the VCAN fields change we will,
call the host system with an update VCAN call

Related Class : Warranty_Case__c
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Aaron Bessey 8/14/2014 - Created 
2.0 - Modified for Best Practices and logic for Creating Reason records                    

***********************************************************************/

trigger Warranty_Case_Trigger on Warranty_Case__c (after insert, before update) {
	
	if(Trigger_Switch__c.getInstance(Label.Trigger_Warranty_Case) != null && Trigger_Switch__c.getInstance(Label.Trigger_Warranty_Case).Disabled__c){
    	return;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){    	
    	WarrantyCaseTriggerHelper.handleAfterInsert(Trigger.newMap);    	
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
    	WarrantyCaseTriggerHelper.handleBeforeUpdate(Trigger.newMap, Trigger.OldMap);
    }
}