trigger Check_Request_After on Check_Request__c (after update) {
	RecordType taskCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Task' limit 1];
    List<Check_Request__c> checks = [Select ID, Status__c, Case__c, Case__r.ContactID, CreatedById From Check_Request__c Where ID in: Trigger.new];
    
    List<Check_Request__c> approved = new List<Check_Request__c>();
    List<Check_Request__c> rejected = new List<Check_Request__c>();
    for (Check_Request__c c :checks) {
        Check_Request__c old = Trigger.oldMap.get(c.ID);        
        if (c.Status__c == 'Approved' && old.Status__c != 'Approved')
            approved.add(c);
            
        if (c.Status__c == 'Denied' && old.Status__c != 'Denied')
            rejected.add(c);
    }
    
    List<Task> tasksToCreate = new List<Task>();
    if (approved.size() > 0) {
        for (Check_Request__c c : approved) {
            Task t = new Task();
            t.OwnerId = c.CreatedById;
            t.Subject = 'Review Approved Check Request';
            t.WhatID = c.Case__c;
            t.ActivityDate = System.today();
            t.Status = 'Not Started';
            t.Priority = 'N/A';
            t.WhoId = c.Case__r.ContactID;
            t.RecordTypeID = taskCART.Id;
            
            tasksToCreate.add(t);
        }
    }
    
    if (rejected.size() > 0) {
        for (Check_Request__c c : rejected) {
            Task t = new Task();
            t.OwnerId = c.CreatedById;
            t.Subject = 'Review Rejected Check Request';
            t.WhatID = c.Case__c;
            t.ActivityDate = System.today();
            t.Status = 'Not Started';
            t.Priority = 'N/A';
            t.WhoId = c.Case__r.ContactID;
            t.RecordTypeID = taskCART.Id;
            
            tasksToCreate.add(t);
        }
    }
    
    if (tasksToCreate.size() > 0)
        insert tasksToCreate;
}