global class Maritz_Accounts_Backfill_BatchJob implements Database.Batchable<SObject> {
    private String query {get; set;}
	private DateTime startDateTime {get; set;}
	private DateTime endDateTime {get; set;}

	private List<sObject> activiesList {get; set;}
	private List<sObject> appropriateAct { get; set;}
	private Set<Id> taskRecTypeIdList { get; set; }
	private Map<Id, Account> relatedAccountMap {get; set;}
	private Map<Id, Contact> relatedContactsMap {get; set;}

    global static void runBackfillProcess(){
        Maritz_Account_BackfillSettings__c mc = Maritz_Account_BackfillSettings__c.getInstance();
        Database.executeBatch(new Maritz_Accounts_Backfill_BatchJob(mc.Start_Date__c, mc.End_Date__c), 50);
    }

    global Maritz_Accounts_Backfill_BatchJob(Datetime startTime, Datetime endTime) {
        String startTimeStr = startTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String endTimeStr = endTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        this.startDateTime = startTime;
		this.endDateTime = endTime;

		query = 'SELECT Id, LastName, FirstName, Name, Customer_ID__c, Household_ID__c, Maritz_Returned_Customer_Id__c FROM Account WHERE';

        query += ' CreatedDate >= ' + startTimeStr;
        query += ' AND CreatedDate <= ' + endTimeStr;
        query += ' AND RecordTypeId = \'' + RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz') + '\'';
    }
    
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }


    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */ 
    global void execute(Database.BatchableContext context, List<Account> scope) {
		relatedAccountMap = new Map<Id, Account>();
		relatedContactsMap = new Map<Id, Contact>();

		for(Account acc : scope){
			relatedAccountMap.put(acc.id, acc);
		}

		for(Contact c : [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, HomePhone, MobilePhone, Phone, Email, AccountId  FROM Contact WHERE AccountId IN :relatedAccountMap.keySet()]){
			relatedContactsMap.put(c.AccountId, c);
		}

		List<Task> allTasks = [SELECT Id, CreatedById, RecordTypeId, CreatedDate, LastModifiedById, WhatId, Type FROM Task WHERE WhatID IN :relatedAccountMap.keySet() AND RecordTypeId = :RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'CCC') AND CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime ALL ROWS];
		
		if(!allTasks.isEmpty()){
			createMaritzStageObjectsForTasks(allTasks);
		}
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {
        
    }

	private void createMaritzStageObjectsForTasks(List<Task> tasks){
		activiesList = tasks;
		InsertNewRecords();		
	}

	private void InsertNewRecords() {
        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = CreateRecords((List<Task>) activiesList);

		if(!newMaritzBackfeed.isEmpty()){
			try 
			{	        
				Database.insert(newMaritzBackfeed, false);
			}
			catch (Exception e)
			{
				System.debug(e);
			}
		}
	}

	 private List<Stage_Maritz_Backfeed_Object__c> CreateRecords(List<Task> appropriateAct) {

        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = new List<Stage_Maritz_Backfeed_Object__c> ();
        Account relatedAccount;

        for (Task t : appropriateAct) {
            relatedAccount = relatedAccountMap.get(t.WhatId);

            if (relatedAccount != null) {
                newMaritzBackfeed.add(BackfeedObjectFactory(relatedAccount, t));
            }
        }

        return newMaritzBackfeed;
    }

	 private Stage_Maritz_Backfeed_Object__c BackfeedObjectFactory(Account relatedAccount, Task t) {
        Stage_Maritz_Backfeed_Object__c temp = new Stage_Maritz_Backfeed_Object__c();
        temp.Batch_Status__c = 'New';
        temp.Account_Last_Name__c = relatedAccount.LastName;
        temp.Account_First_Name__c = relatedAccount.FirstName;
        temp.Account_Name__c = relatedAccount.Name;
        temp.Customer_ID__c = relatedAccount.Customer_ID__c;

		if(relatedContactsMap.containsKey(t.WhatId)){
			temp.PersonMailingStreet__c = relatedContactsMap.get(t.WhatId).MailingStreet;
			temp.PersonMailingCity__c = relatedContactsMap.get(t.WhatId).MailingCity;
			temp.PersonMailingState__c = relatedContactsMap.get(t.WhatId).MailingState;
			temp.PersonMailingPostalCode__c = relatedContactsMap.get(t.WhatId).MailingPostalCode;
			temp.PersonHomePhone__c = relatedContactsMap.get(t.WhatId).HomePhone;
			temp.PersonMobilePhone__c = relatedContactsMap.get(t.WhatId).MobilePhone;
			temp.PersonWorkPhone__c = relatedContactsMap.get(t.WhatId).Phone;
			temp.Email__c = relatedContactsMap.get(t.WhatId).Email;
		}

        if (Test.isRunningTest()) {
            temp.Customer_ID__c = 'test';
        }

        temp.Contact_ID__c = relatedAccount.id;

        temp.Household_Identifier__c = relatedAccount.Household_ID__c;
        temp.Maritz_Returned_Customer_ID__c = relatedAccount.Maritz_Returned_Customer_Id__c;
        temp.Group__c = 'Treated';

		temp.Activity_Task_Date_Time__c = t.CreatedDate.format('MM-dd-yyyy hh:mm a');
        temp.Activity_ID__c = t.id;
        temp.Task_SFDC_ID__c = t.Id;
        temp.Backfeed_Type__c = 'Standard Activity';
        temp.Group__c = 'Treated';
        temp.Activity_Task_Type__c = 'Task';
        return temp;
    }

}