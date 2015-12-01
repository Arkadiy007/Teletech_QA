/**********************************************************************
Name: Batch_OpenTasks_OpenCase
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class create an open task for non open case nightly.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 	02/25/2012 Created
***********************************************************************/
//Batch_OpenTasks_OpenCase batchJob = new Batch_OpenTasks_OpenCase();
//Database.executeBatch(batchJob);
//delete [Select ID from Task Where WhatId in (Select ID FROM Case Where Subject = 'Open Tasks for Open Cases' and IsClosed = false)];
global class Batch_OpenTasks_OpenCase implements Database.Batchable<sObject> {
    final static RecordType DPICTypeRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Task' limit 1];
    final static Set<Date> holidayDates = HolidayCalculator.AllHolidaysOfLastCurrentAndNextYearOfDay(System.now().date());
	global String query = 'Select CaseNumber, Subject, RecordTypeId, ' +
							'Account.BillingCountry, ' +
							'AccountId, ' +
							'CreatedById, ' +
							'(Select Status, ' +
							'		WhatId, ' +
							'		OwnerId, ' +
							'		RecordTypeId, ' +
							'		Subject, ' +
							'		ActivityDate, ' +
							'		Priority, ' +
							'		Description, ' +
							'		X48Hr_Due_Date_time__c, ' +
							'		X24hr_Due_Date_Time__c ' +
							'	From Tasks ' + 
							'	Where IsClosed = false) ' +
							'From Case c ' +
							'Where isClosed = false and ' +
							'	RecordType.Name in (\'DPIC\', \'DPIC Technical Escalation\', \'DPIC Supply Escalation\')';
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Case> lstCases) {
		List<Task> tasksToCreate = new List<Task>();
    	DateTime createDate = System.now();
    	
    	DateTime target24Hr = createDate, target48Hr = createDate;
    	
    	DateTime targetDate = createDate;
    	//get the next working day if today is holiday, otherwise use today.
		while (HolidayCalculator.isDayOff(targetDate, holidayDates))
			targetDate = targetDate.addHours(24);
		
		//get the next working day after today.
		targetDate = targetDate.addHours(24);
		while (HolidayCalculator.isDayOff(targetDate, holidayDates))
			targetDate = targetDate.addHours(24);
		target24Hr = targetDate;
		
		//get the next working day after 1 day after today.
		targetDate = targetDate.addHours(24);
		while (HolidayCalculator.isDayOff(targetDate, holidayDates))
			targetDate = targetDate.addHours(24);
		target48Hr = targetDate;
		
		for (Case c : lstCases) {
			if (c.Tasks.size() == 0) {
				Task t = new Task();
				t.WhatId = c.ID;
				t.OwnerID = c.CreatedById;
				t.RecordTypeId = DPICTypeRT.ID;
				t.Status = 'Not Started';
				t.Priority = 'Normal';
				
				if (c.Account.BillingCountry != null && (c.Account.BillingCountry.equalsIgnoreCase('Canada') || c.Account.BillingCountry.equalsIgnoreCase('CA'))) {
					t.Subject = '24hr Dealer Call Back';
					t.ActivityDate = target24Hr.Date();
					t.Description = 'This Task to contact the Dealer to provide an update must be completed and closed within 24 hours';
					t.X48hr_Due_Date_Time__c = target24Hr;
				} else {
					t.Subject = '48hr Dealer Call Back';
					t.ActivityDate = target48Hr.Date();
					t.Description = 'This Task to contact the Dealer to provide an update must be completed and closed within 48 hours';
					t.X24hr_Due_Date_Time__c = target48Hr;
				}
				
				tasksToCreate.add(t);
			}
		}
		
		List<Error_Log__c> errors = new List<Error_Log__c>();
		if (tasksToCreate.size() > 0) {
            Database.SaveResult[] dbResults = Database.insert(tasksToCreate, false);
            for (integer row = 0; row < tasksToCreate.size(); row++) {
                if (!dbResults[row].isSuccess()) {
                    Database.Error err = dbResults[row].getErrors()[0];
                    errors.add(new Error_Log__c(Record_ID__c = tasksToCreate[row].Id,
                                Record_Type__c = 'Task',
                                Error_Message__c = err.getMessage(), 
                                TimeStamp__c = System.now(), 
                                Operation_Name__c = 'Batch_OpenTasks_OpenCase', 
                                Source__c='Salesforce', 
                                Log_Type__c = 'Error', 
                                Log_Level__c = 1));
                }
            }
        }
        
        if (!errors.isEmpty())
            Database.SaveResult[] dbResults = Database.insert(errors, false);
	}
	
	global void finish(Database.BatchableContext BC){
		
	}
	
    static testMethod void myUnitTest() {
    	RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
	    RecordType caseDPICRT = [select id, name from recordtype where name = 'DPIC Supply Escalation' and sobjecttype = 'Case' limit 1];
	    RecordType taskDPICRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Task' limit 1];
		
		List<Account> testAccounts = new List<Account> {
			new Account(Name = 'Account', RecordTypeId = dealerType.id),
			new Account(Name = 'Account', RecordTypeId = dealerType.id, BillingCountry = 'ca')
		};
		insert testAccounts; 
        
		List<Case> testCases = new List<Case> {
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@US Open Case - create task', 					Status = 'Open', 	AccountId = testAccounts[0].Id),
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@US Open Case and closed task - create task', 	Status = 'Open', 	AccountId = testAccounts[0].Id),
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@US Open Case and open task - no create task', 	Status = 'Open', 	AccountId = testAccounts[0].Id),
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@CA Open Case - create task', 					Status = 'Open', 	AccountId = testAccounts[1].Id),
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@CA Open Case and closed task - create task', 	Status = 'Open', 	AccountId = testAccounts[1].Id),
			new Case(RecordTypeId = caseDPICRT.Id, Subject = '&&&!!!@@@CA Open Case and open task - no create task', 	Status = 'Open', 	AccountId = testAccounts[1].Id)
		};
		insert testCases;
		
		List<Task> testTasks = new List<Task> {
			new Task(WhatId = testCases[1].Id, Subject = 'Already Created', RecordTypeId = taskDPICRT.Id, Status = 'Complete'),
			new Task(WhatId = testCases[2].Id, Subject = 'Already Created', RecordTypeId = taskDPICRT.Id, Status = 'In Progress'),
			new Task(WhatId = testCases[4].Id, Subject = 'Already Created', RecordTypeId = taskDPICRT.Id, Status = 'Complete'),
			new Task(WhatId = testCases[5].Id, Subject = 'Already Created', RecordTypeId = taskDPICRT.Id, Status = 'In Progress')
		};
		insert testTasks;
		
		Test.startTest();
        Batch_OpenTasks_OpenCase batch = new Batch_OpenTasks_OpenCase();
		batch.query = 'Select CaseNumber, Subject, RecordTypeId, ' +
							'Account.BillingCountry, ' +
							'AccountId, ' +
							'CreatedById, ' +
							'(Select Status, ' +
							'		WhatId, ' +
							'		OwnerId, ' +
							'		RecordTypeId, ' +
							'		Subject, ' +
							'		ActivityDate, ' +
							'		Priority, ' +
							'		Description, ' +
							'		X48Hr_Due_Date_time__c, ' +
							'		X24hr_Due_Date_Time__c ' +
							'	From Tasks ' + 
							'	Where IsClosed = false) ' +
							'From Case c ' +
							'Where Subject LIKE \'&&&!!!@@@%\' AND isClosed = false and ' +
							'	RecordType.Name in (\'DPIC\', \'DPIC Technical Escalation\', \'DPIC Supply Escalation\')';
        Database.executeBatch(batch);
        Test.stopTest();
    	
    	List<Task> tasks = [Select X48Hr_Due_Date_time__c From Task Where WhatId =: testCases[0].Id];
    	System.assert(tasks.size() == 1);
    	System.assert(tasks[0].X48Hr_Due_Date_time__c != null);
    	
    	tasks = [Select IsClosed, X24hr_Due_Date_Time__c, Subject From Task Where WhatId =: testCases[4].Id];
    	System.assert(tasks.size() == 2);
    	for (Task t : tasks) {
        	System.Debug('*** t ' + t.X24hr_Due_Date_Time__c);
    		if (t.IsClosed == false)
    			System.assert(t.X24hr_Due_Date_Time__c != null);
    		else 
    			System.assert(t.Subject == 'Already Created');
    	}
    }
}