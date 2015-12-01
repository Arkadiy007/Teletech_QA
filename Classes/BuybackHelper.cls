/*************************************************************************************
Name: BuybackHelper
=======================================================================================
History: 

VERSION AUTHOR         DATE         DETAIL 
1.0 - Vivek Batham    7/23/2015    Created Helper class for Buyback__c trigger
****************************************************************************************/

public class BuybackHelper{
    
    Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Buyback__c.getRecordTypeInfosByName();
    Map<String, Schema.RecordTypeInfo> taskRtInfosByName = Schema.SObjectType.Task.getRecordTypeInfosByName();
    
    Id bbRTid = rtInfosByName.get('DRT Resolution').getRecordTypeId();
    Id vppRTid = rtInfosByName.get('Goodwill VPP').getRecordTypeId();   
    Id taskCARTId = taskRtInfosByName.get('CA').getRecordTypeId();

    public void handleAfterInsert(List<Buyback__c> newBuybacks){
        Map<ID, Buyback__c> relatedCases = new Map<ID, Buyback__c>();
        Set<Id> caseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        
        for (Buyback__c b : newBuybacks){
            caseIds.add(b.Case__c);
            if(b.RecordTypeId == bbRTid){
                 relatedCases.put(b.Case__c, b);
            }            
        }
        
        //1.0 Upon creating a new Buyback record, need to update the related Case to populate the "Buyback" field with the Buyback ID.
        if (caseIds.size() > 0) {
           
            for (Case c : [Select Id, Buyback__c, Vehicle_Name__c, Stage_Status__c From Case WHERE ID in: caseIds]) {
                
                if(relatedCases.get(c.ID) != null && c.Buyback__c == NULL && c.Vehicle_Name__c != NULL){
                 c.Buyback__c = relatedCases.get(c.ID).ID;
                }
                c.Stage_Status__c = Label.Stage_Status_Update; // 'Update Processing';
                casesToUpdate.add(c);
            }
            
            try {
                if(casesToUpdate.size() > 0)
                    update casesToUpdate;
            } catch (DMLException e) {
                relatedCases.get(e.getDmlId(0)).addError('Exception occured while updating case BuyBack: ' + e.getMessage());
            }
        }
        
    } 
    
    public void handleAfterUpdate(List<Buyback__c> newBuybacks, Map<Id, Buyback__c> oldbuybackMap){
     Map<ID, Buyback__c[]> caseToBBs = new Map<ID, Buyback__c[]>();
     Set<Id> caseIds = new Set<Id>();
     List<Case> casesToUpdate = new List<Case>();
        
        for (Buyback__c b : newBuybacks){
          if(b.Case__c != null){
            caseIds.add(b.Case__c);
          }             
          if( b.RecordTypeId == vppRTid && oldbuybackMap.get(b.ID).CAVPP_Claim_No__c == null && b.CAVPP_Claim_No__c != null) {
            if (caseToBBs.containsKey(b.Case__c)){
                caseToBBs.get(b.Case__c).add(b);
            }else{
                caseToBBs.put(b.Case__c, new Buyback__c[]{b});
            }
          }
        } 
        
         if (caseToBBs.size() > 0) {
            //1.1 - Task Creation when VPP Claim # is populated
            List<Task> tasksToCreate = new List<Task>();
            Map<ID, Buyback__c> errorTasks = new Map<ID, Buyback__c>();
            for (Case c : [Select OwnerID, ContactID From Case WHERE ID in: caseToBBs.keySet()]) {
                Buyback__c[] bbs = caseToBBs.get(c.ID);
                for (Buyback__c b : bbs) {
                    Task t = new Task();
                    t.OwnerId = c.OwnerID;
                    t.Subject = 'Complete VPP Goodwill Process - ' + b.Name;
                    t.WhatID = c.Id;
                    t.ActivityDate = System.today();
                    t.Status = 'Not Started';
                    t.Priority = 'N/A';
                    t.WhoId = c.ContactID;
                    t.RecordTypeID = taskCARTId;
                    
                    tasksToCreate.add(t);
                    errorTasks.put(t.ID, b);
                }
            }
            
            try {
                if(tasksToCreate.size() > 0)
                    insert tasksToCreate;
            } catch (DMLException e) {
                errorTasks.get(e.getDmlId(0)).addError('Exception occured while create Complete VPP Goodwill Process task: ' + e.getMessage());
            }
          }
          
          if(caseIds.size() > 0){
             for (Case c : [Select Id, Buyback__c, Vehicle_Name__c, Stage_Status__c From Case WHERE ID in: caseIds AND Stage_Status__c != 'Update Processing']) {
                c.Stage_Status__c = Label.Stage_Status_Update; //'Update Processing';
                casesToUpdate.add(c);
            }
            
            if(casesToUpdate.size() > 0){
                Database.update(casesToUpdate, false);
            }     
          } 
            
    }
    
    public void handleAfterDelete(List<Buyback__c> oldBuybacks){
        Set<Id> caseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        for(Buyback__c buy : oldBuybacks){
            if(buy.Case__c != null){
                caseIds.add(buy.Case__c);
            }
        }
        
        if(caseIds.size() > 0){         
            for (Case c : [Select Id, Buyback__c, Vehicle_Name__c, Stage_Status__c From Case WHERE ID in: caseIds AND Stage_Status__c != 'Update Processing']) {
                c.Stage_Status__c = Label.Stage_Status_Update; //'Update Processing';
                casesToUpdate.add(c);
            }
            
            if(casesToUpdate.size() > 0){
                Database.update(casesToUpdate, false);
            }               
        }
    
    } 
    
    public void handleAfterUndelete(List<Buyback__c> newBuybacks){
        Set<Id> caseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        for(Buyback__c buy : newBuybacks){
            if(buy.Case__c != null){
                caseIds.add(buy.Case__c);
            }
        }
        
        if(caseIds.size() > 0){         
            for (Case c : [Select Id, Buyback__c, Vehicle_Name__c, Stage_Status__c From Case WHERE ID in: caseIds AND Stage_Status__c != 'Update Processing']) {
                c.Stage_Status__c = Label.Stage_Status_Update; // 'Update Processing';
                casesToUpdate.add(c);
            }
            
            if(casesToUpdate.size() > 0){
                Database.update(casesToUpdate, false);
            }               
        }
    
    }     
    
}