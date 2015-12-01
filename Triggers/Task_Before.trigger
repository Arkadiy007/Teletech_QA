/**********************************************************************
Name: Task_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Updating Task field whenever new Task is created from Account/Case.
Related Class: TaskClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/13/2011 Created
1.1 - Mohd Afraz Siddiqui 01/17/2011 As per issue RONETELETECH-98 removed hard 
                                     coded Ids of Case/Account/User.
1.2 - Bryan Fry           01/21/2011 Updated code for updating fields per updated
                                     CallResolution mapping.

1.3 - Seth Davidow        02/11/2011 Updated to handle call failed
1.4 - JJ Heldman          02/08/2012 Updated for NCI by having Call_Centre_Id__c pull
                                     from agentMap instead of being assigned a default 
1.5 - Bryan Fry           06/22/2012 Added processing for 24hr Dealer Email reply
1.6 - Bryan Fry           12/10/2013 Change agentMap to get single row
1.7 - Vlad Martynenko     03/13/2015 Added User_Role_Check_Enabled__c check instead of System.Label.USER_ROLE_CHECK_ENABLED as part of disposition report update task
***********************************************************************/
trigger Task_Before on Task (before insert, before update) {
    private static final String SERVICE_MARKETING = 'Service Marketing';
    private static final String OTHER = 'Other';
    private static final String USER_ROLE_SERVICE_MARKETING = '00EA0000000UneYMAS';

    // Get Agent Ids into a map
    User agent = [select id, agent_id__c, call_centre_id__c from user where id = :UserInfo.getUserId()];
   
    // Replacement to System.Label.USER_ROLE_CHECK_ENABLED as part of disposition report update task
    List<User_Role_Check_Enabled__c> userRoleCusomSetting = [Select Id, Is_User_Validation_Enabled__c From User_Role_Check_Enabled__c];

    // Identifier lists.
    List<Id> contactIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    List<String> dispositionNames = new List<String>();
    List<Id> vehicleIds = new List<Id>();
    
    // Object type identifiers for type checking
    String contactIdPrefix = Schema.sObjectType.Contact.getKeyPrefix();
    String userIdPrefix = Schema.sObjectType.User.getKeyPrefix();
    
    // Object lists to fill Task from
    List<Account> accounts = null;
    List<CampaignMember> members = new List<CampaignMember>();
    List<Vehicle__c> vehicles = null;
    List<User> users = null;
    List<Disposition__c> dispositions = null;
    
    // Map from ContactIds to Vehicle__c to provide a direct lookup from a field on Task to Vehicles
    Map<Id,Vehicle__c> contactVehicles = new Map<Id,Vehicle__c>();
    
    // Get the Role of the current user.  Only do Task processing if the user's Role is Service Marketing
    String userRole = UserInfo.getUserRoleId();
    
    // Set Department on the Task based on the Role of the User.
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (userRole == USER_ROLE_SERVICE_MARKETING) {
            Trigger.new[i].Department__c = SERVICE_MARKETING;
        } else {
            Trigger.new[i].Department__c = OTHER;
        }
    }
    
    // *********** Always check for Dispositions to set ***************
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if ((userRoleCusomSetting.size() > 0 && userRoleCusomSetting.get(0).Is_User_Validation_Enabled__c == false) || userRole == USER_ROLE_SERVICE_MARKETING) {
            if(Trigger.new[i].FailedCall__c){
                system.debug('### Call Failed '+Trigger.new[i].FailedCall__c);
            
                Trigger.new[i].CallDisposition__c = system.label.No_Answer_7_Rings;
                Trigger.new[i].Call_End_Time__c = datetime.now();
                Trigger.new[i].Call_Recording_ID__c = '0';
                
                Trigger.new[i].TMS_Disposition__c = '10';//disposition.TMS_Id__c;
                Trigger.new[i].Dialer_Disposition__c = 9;//disposition.Dialer_Code__c;
                
                Trigger.new[i].Agent_ID__c = agent.agent_id__c;
                Trigger.new[i].Call_Centre_Id__c = agent.call_centre_id__c;
                Trigger.new[i].Customer_Experience__c = '8 None of the Above';
                Trigger.new[i].CallDurationInSeconds = 0;
            }
            if (Trigger.new[i].CallDisposition__c != null) {
                if (Trigger.IsUpdate) {
                    if (Trigger.new[i].CallDisposition__c != Trigger.old[i].CallDisposition__c) {
                        dispositionNames.add(String.valueOf(Trigger.new[i].CallDisposition__c));
                    }
                } else {
                    dispositionNames.add(Trigger.new[i].CallDisposition__c);
                }
            }
            
            if (Trigger.new[i].OwnerId != null && String.valueOf(Trigger.new[i].OwnerId).startsWith(userIdPrefix)) {
                userIds.add(Trigger.new[i].OwnerId);
            }
        }
    }
    
    // Get Disposition codes from Disposition Names
    dispositions = [select Name, TMS_Id__c, Dialer_Code__c
                    from Disposition__c 
                    where Name in :dispositionNames];
                    
    // Get Users from userIds
    users = [Select id, Agent_Id__c, Call_Centre_Id__c
             from User 
             where id in :userIds];
    
    Task_Log__c log = null;
    List<Task_Log__c> logs = new List<Task_Log__c>();
    
    // Update TMS Disposition, Dialer Dispositions, and Agent Id on Task
    for (Task task : Trigger.new) {
        if ((userRoleCusomSetting.size() > 0 && userRoleCusomSetting.get(0).Is_User_Validation_Enabled__c == false) || userRole == USER_ROLE_SERVICE_MARKETING) {
            for (Disposition__c disposition : dispositions) {
                if (task.CallDisposition__c == disposition.Name) {
                    TaskClass.updateDispositionFields(task, disposition);
                }
            }
            
            for (User user : users) {
                if (task.OwnerId == user.Id && task.Agent_id__c == null) {
                    TaskClass.updateUserFields(task, user);
                }
            }
            
            if (System.label.Task_Log == 'true') {
                log = new Task_Log__c();
                log.Task_Id__c = task.id;
                log.Service_Marketing_Call_Id__c = task.Service_Marketing_Call_Id__c;
                String logInfo = 'agent = ' + task.Agent_Id__c +
                                 ', disp = ' + task.CallDisposition__c +
                                 ', end time = ' + task.Call_End_Time__c +
                                 ', rec id = ' + task.Call_Recording_Id__c +
                                 ', cust exp = ' + task.Customer_Experience__c +
                                 ', failed = ' + task.FailedCall__c +
                                 ', dialer disp = ' + task.Dialer_Disposition__c +
                                 ', subject = ' + task.Subject +
                                 ', tms disp = ' + task.TMS_Disposition__c +
                                 ', owner = ' + task.OwnerId;
                log.Log_Info__c = logInfo;
                
                logs.add(log);
            }
        }
    }
    
    insert logs;

    // ********** Only set other information if Call_End_Time__c and Call_Disposition__c is set and 
    // at least one of them was not previously set. 
    // Pull all information needed for lookups from Task objects:
    // ContactId, UserId, CallDisposition
    Task newTask = null;
    Task oldTask = null;
    for (Integer i = 0; i < Trigger.new.size(); i++) {
    	 newTask = Trigger.new[i];
        if ((userRoleCusomSetting.size() > 0 && userRoleCusomSetting.get(0).Is_User_Validation_Enabled__c == false) || userRole == USER_ROLE_SERVICE_MARKETING) {           
            if (Trigger.isUpdate) {
                oldTask = Trigger.old[i];
            }
            
            // Only update this information if Call_End_Time__c is populated and
            // was not populated previously.
            if ((oldTask == null  && newTask.Call_End_Time__c != null && newTask.CallDisposition__c != null) ||
                (oldTask != null && newTask.Call_End_Time__c != null && newTask.CallDisposition__c != null &&
                  (oldTask.Call_End_Time__c == null || oldTask.CallDisposition__c == null))) {
                if (newTask.WhoId != null && String.valueOf(newTask.WhoId).startsWith(contactIdPrefix)) {
                    contactIds.add(newTask.WhoId);
                }
                 
                if (newTask.CallDisposition__c != null) {
                    dispositionNames.add(newTask.CallDisposition__c);
                }
            }
        }
       
        // Added for deactivating Workflow CA Task Completed Date
        if((Trigger.isUpdate && newTask.Status == 'Complete' && newTask.Status != Trigger.OldMap.get(newTask.Id).Status)
        	|| (Trigger.isInsert && newTask.Status == 'Complete')){
        	newTask.Completed_Date__c = System.now();
        }
    }
    
    // Get CampaignMembers from contactIds
    /*
    members = [Select Id, ContactId, Service_Marketing_Call_Id__c, Phone_1__c, Language__c,
                      Preferred_Phone_Type__c, Preferred_Mail_Type__c, Preferred_Call_Time__c,
                      Vehicle__c, Service_Marketing_Call_Type__c
               from CampaignMember
               where ContactId in :contactIds
               and Campaign.IsActive = true];
    */
    for (Integer i = 0; i < contactIds.size(); i++) {
        List<CampaignMember> contactMembers = [Select Id, ContactId, Service_Marketing_Call_Id__c, Phone_1__c, Language__c,
                                                      Preferred_Phone_Type__c, Preferred_Mail_Type__c, Preferred_Call_Time__c,
                                                      Vehicle__c, Service_Marketing_Call_Type__c, CampaignMember.RecordType.Name
                                               from CampaignMember
                                               where ContactId =: contactIds[i] 
                                               ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
    
        if(contactMembers != null && !contactMembers.isEmpty())
        {
            members.add(contactMembers[0]);
        }
    }
    
    // Get a list of VehicleIds from the CampaignMembers
    for (CampaignMember member : members) {
        if (member.Vehicle__c != null) {
            vehicleIds.add(member.Vehicle__c);
        }
    }

    // Get Vehicle__c List from vehicleIds
    vehicles = [Select Id, Latest_Recorded_Mileage_Units__c, Latest_Recorded_Mileage_Number__c,
                       PMG_Type__c
                from Vehicle__c
                where id in :vehicleIds];
    
    // Create Map from contactId to Vehicle__c
    for (Vehicle__c vehicle : vehicles) {
        for (CampaignMember member : members) {
            if (vehicle.Id == member.Vehicle__c) {
                contactVehicles.put(member.ContactId, vehicle);
            }
        }
    }
    
    // Get Accounts from contactIds
    accounts = [Select Id,PersonContactId,Salutation,FirstName,MiddleName__c,LastName,PersonMailingStreet,
                       PersonMailingCity,PersonMailingState,PersonMailingCountry,PersonMailingPostalCode,
                       PersonHomePhone,Home_Phone_Extension__c,PersonDoNotCall,Home_Phone_Sequence__c,
                       PersonOtherPhone,Other_Phone_Extension__c, Other_Phone_Do_Not_Call_In__c,
                       Other_Phone_Sequence__c, PersonMobilePhone,Mobile_Phone_Do_Not_Call_Indicator__c,
                       Mobile_Phone_Sequence__c,PersonEmail, PersonHasOptedOutOfEmail,Alternate_Email__c,
                       Do_Not_Email_In__c,Preferred_Dealer_Id__r.Dealer_Code__c, Home_Phone_Do_Not_Call__c,Alternate_Email_Do_Not_Email__c, Email_Type_1__c, Email_Type_2__c
                from Account 
                where PersonContactId in :contactIds];
    
    // Iterate through source objects and update associated Task object with
    // needed data.
    Account acct = null;
    CampaignMember cm = null;
    Vehicle__c vehicle = null;
    List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    for (Task task : Trigger.new) {
        acct = null;
        cm = null;
        vehicle = null;
        if ((userRoleCusomSetting.size() > 0 && userRoleCusomSetting.get(0).Is_User_Validation_Enabled__c == false) || userRole == USER_ROLE_SERVICE_MARKETING) {
            if(task.Call_End_Time__c != null){
                for (Account account : accounts) {
                    if (task.WhoId == account.PersonContactId) {
                       TaskClass.updateAccountFields(task, account);
                       acct = account;
                    }
                }
        
                for (CampaignMember member : members) {
                    if (task.WhoId == member.ContactId) {
                        TaskClass.updateCampaignMemberFields(task, member);
                        if (task.Id != null) {
                            member.Task_Id__c = task.Id;
                            membersToUpdate.add(member);
                        } 
                    }
                }
        
                for (Id contactId : contactVehicles.keySet()) {
                    if (task.WhoId == contactId) {
                        vehicle = contactVehicles.get(contactId);
                        TaskClass.updateVehicleFields(task, vehicle);
                    }
                }
                                
            }
        }
    }
    
    // Update CampaignMembers to have a Task Id where possible.
    if (!membersToUpdate.isEmpty()) {
        Database.update(membersToUpdate, false);
    }
    
    // Set 24/48 hour Due Dates for Dealer Call Backs and Email Replies
    if (Trigger.isInsert) {
        DateTime createDate = System.now();
        Set<Date> holidayDates = null;
        
        for (Task task : Trigger.new) {
            if(task.Subject == System.label.Task_Subject_24hr_Dealer_Call_Back || 
                    task.Subject == System.label.Task_Subject_48hr_Dealer_Call_Back ||
                    task.Subject == System.label.Task_Subject_24hr_Dealer_Email_Reply) {
                if (holidayDates == null)
                    holidayDates = HolidayCalculator.AllHolidaysOfLastCurrentAndNextYearOfDay(createDate.date());
                
                DateTime targetDate = createDate;
                while (HolidayCalculator.isDayOff(targetDate, holidayDates))
                    targetDate = targetDate.addDays(1);
                
                if (task.Subject == System.label.Task_Subject_24hr_Dealer_Call_Back ||
                        task.Subject == System.label.Task_Subject_24hr_Dealer_Email_Reply) {
                    targetDate = targetDate.addHours(23);
                    while (HolidayCalculator.isDayOff(targetDate, holidayDates))
                        targetDate = targetDate.addDays(1);
                    
                    task.X24hr_Due_Date_Time__c = targetDate;
                    task.X48hr_Due_Date_Time__c = null;
                } 
                
                else if (task.Subject == System.label.Task_Subject_48hr_Dealer_Call_Back) {
                    targetDate = targetDate.addHours(23);
                    while (HolidayCalculator.isDayOff(targetDate, holidayDates))
                        targetDate = targetDate.addDays(1);
                    
                    targetDate = targetDate.addHours(24);
                    while (HolidayCalculator.isDayOff(targetDate, holidayDates))
                        targetDate = targetDate.addDays(1);
                    
                    task.X24hr_Due_Date_Time__c = null;
                    task.X48hr_Due_Date_Time__c = targetDate;
                }
            }
        }
    }

    // Associate Eloqua Tasks to accounts
    Map<String,Task> customerIdTasks = new Map<String,Task>();
    if (Trigger.isInsert) {
        for (Task t: Trigger.new) {
            if (t.CustomerID__c != null && t.RecordTypeId == '012F0000000yEDmIAM')
                customerIdTasks.put(t.CustomerID__c, t);
        }
    }
    
    List<Account> taskAccounts = [select id, customer_id__c from account where customer_id__c in :customerIdTasks.keySet()];
    for (Account taskAccount: taskAccounts) {
        Task t = customerIdTasks.get(taskAccount.Customer_Id__c);
        t.WhatId = taskAccount.Id;
    }
}