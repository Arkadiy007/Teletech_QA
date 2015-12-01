public class FormTriggerHelper{
    
    // ********** Forms cannot be added to a closed case
    public static void handlebeforeInsert(List<Form__c> newForms){
        Set<ID> caseIds = new Set<ID>();
        for (Form__c t: newForms) {
            caseIds.add(t.Case__c);
        }
        
        List<Case> cases = [select Id from Case where Id in :caseIds and IsClosed = true and RecordType.Name not in ('DPIC','DPIC Supply Escalation','DPIC Technical Escalation')];
        Map<ID, Case> mapCases = new Map<ID, Case>(cases);
        for (Form__c t: newForms) {
            if (mapCases.containsKey(t.Case__c))
                t.addError('Forms cannot be added to a closed case.');
        }
    
    }
    
    // Upon creating a new Form IIR record, need to update the related Case to populate the "IIR__c" field with the Form ID
    public static void handleAfterInsert(List<Form__c> newForms){
        
        List<Case> casesToUpdate = new List<Case>();  
        Map<ID, Form__c> relatedCases = new Map<ID, Form__c>();  
        RecordType iirRT = [select id, name from recordtype where name = 'IIR' and sobjecttype = 'Form__c' limit 1];
        
        for (Form__c b : newForms) {
            if (b.RecordTypeId == iirRT.Id)
                relatedCases.put(b.Case__c, b);
        }        
        
        for (Case c : [Select Form__c From Case WHERE ID in: relatedCases.keySet() and Form__c = NULL]) {
            c.IIR__c = relatedCases.get(c.ID).ID;
            casesToUpdate.add(c);
        }
        
        try {
            if(casesToUpdate.size() > 0)
                update casesToUpdate;
        } catch (DMLException e) {
            relatedCases.get(e.getDmlId(0)).addError('Exception occured while updating case IIR: ' + e.getMessage());
        }
    
    }
    
    public static void handleAfterUpdate(List<Form__c> newForms){
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        Set<String> profileNames = new Set<String>();
        Set<String> profileIds = new Set<String>();
        Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Form__c.getRecordTypeInfosByName();
        Id iirRTId = rtInfosByName.get('IIR').getRecordTypeId() ;
        
        for(String s : System.label.Form_Profile_Updates.split(',')){
        	profileNames.add(s.Trim());
        }
        
        for(Profile prof : [Select Id, Name from Profile where Name IN : profileNames]){
        	profileIds.add(prof.Id);
        }
        
        if(!profileIds.contains(Userinfo.getProfileId())){
        for (Form__c b : newForms) { 
        	if(b.RecordTypeId == iirRTId){ 
        	caseIds.add(b.Case__c); 
        	}        
        }
        
        if(caseIds.size() > 0){
        for(Case c : [Select Id, DRT_Support_IIR_Status__c from Case where Id IN : caseIds AND DRT_Support_IIR_Status__c = 'Rejected']){
        	c.DRT_Support_IIR_Status__c = 'Pending';
        	casesToUpdate.add(c);
        }
        	
    	if(casesToUpdate.size() > 0){
    		Database.update(casesToUpdate, false);
    	}
        }
        
        }
         
    }

}