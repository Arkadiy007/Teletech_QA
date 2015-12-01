global class BellomyStageObjects_VCSBatchJob implements Database.Batchable<SObject> {
    private String query {get; set;}
    private Bellomy_Reports_Settings__c reportSettings {get; Set;}
    private static Map<Id, String> userNamesById {get; Set;}

    global BellomyStageObjects_VCSBatchJob() {
        retriveCustomSettings();
        query = 'SELECT Id, RecordTypeId, Account.Phone, Account.Customer_ID__c, CreatedDate, ClosedDate, Account.PersonMailingPostalCode, Account.PersonMailingState, Status, CaseNumber, Case_Servicing_Dealer_Code__c, Owner.UserRole.Name, Case_Owner_Email__c, Case_Owner_Location2__c, Account.PersonOtherPostalCode, Account.PersonHomePhone, Account.PersonMailingStreet, Account.PersonMailingCity, Days_Closed__c, Account.Name, Channel_Designation_Code__c, (SELECT Id, Category_Code__c, Category_Description__c, Concern_Code__c, Concern_Description__c, Subcategory_Code__c, Subcategory_Description__c, Symptom_Code__c, Symptom_Description__c FROM Case_Categorizations__r), Model_Line__c, Model_Year__c, Date_Opened__c, Date_Closed__c, Who_contacted_us__c, Origin, Action_Code__c, Root_Cause_Code__c, Root_Cause_Code_2__c, AccountId,  Service_Dealer_Number__c, Responsible_Region__c, Responsible_District__c, CreatedById, OwnerId, Customer_ID__c, Servicing_Dealer__r.Name, Type, Incident_Category_Code__c, Incident_Category_Name__c, Account.PersonEmail, Primary_Reason__c, Secondary_Reason__c FROM Case ';
        query += addWhereClauses();
        query += limitRecordsDate();
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
    global void execute(Database.BatchableContext context, List<Case> scope) {
        List<StageBellomyCases__c> newBellomyCasesList = new List<StageBellomyCases__c>();

        userNamesById = new Map<Id, String>();
        getUserNamesById(scope);


        for(Case cs : scope){
            newBellomyCasesList.add(newVCSStageObject(cs));
        }

        insert newBellomyCasesList;
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {
        
    }

    private void retriveCustomSettings(){
        for (Bellomy_Reports_Settings__c settings : Bellomy_Reports_Settings__c.getAll().values()){
            if (settings.Name == 'Bellomy Test Extract-VCS'){
                reportSettings = settings;
            }
        }
    }

    private String addWhereClauses(){
        String whereClause = 'WHERE ' +  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
        return whereClause;
    }

    private String limitRecordsDate(){
        TimeZone tz = UserInfo.getTimeZone();
        Integer startOffset = tz.getOffset(reportSettings.Start_Date__c) / (60 * 60 * 1000);
        Integer endOffset = tz.getOffset(reportSettings.End_Date__c) / (60 * 60 * 1000);
        String endTimeStr = reportSettings.End_Date__c.addHours(endOffset).addDays(1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String startTimeStr = reportSettings.Start_Date__c.addHours(startOffset).addDays(1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');


        String timeLimits = ' AND ' + reportSettings.Data_Range_Field__c + ' >= ' + startTimeStr;
        timeLimits += ' AND ' + reportSettings.Data_Range_Field__c + ' <= ' + endTimeStr;
        return timeLimits;
    }


    private StageBellomyCases__c newVCSStageObject(Case cs){
        StageBellomyCases__c stageObject = new StageBellomyCases__c();
        stageObject.Case_Number__c = cs.CaseNumber;
        stageObject.Case_owner_Email__c = cs.Case_Owner_Email__c;
        stageObject.Related_vehicle_Make__c = cs.Channel_Designation_Code__c;
        stageObject.Model_Line__c = cs.Model_Line__c;
        stageObject.Model_Year__c = cs.Model_Year__c;
        
        if(cs.CreatedDate != null){
            stageObject.Opened_Date__c = cs.CreatedDate.format('MM/dd/yyyy');
        }
        if(cs.ClosedDate != null){
            stageObject.Closed_date__c = cs.ClosedDate.format('MM/dd/yyyy');
        }

        stageObject.Who_contacted_us__c = cs.Who_contacted_us__c;
        stageObject.Case_origin__c = cs.Origin;
        stageObject.Action_Code__c = cs.Action_Code__c;
        stageObject.Primary_Reason__c = cs.Primary_Reason__c; //
        stageObject.Secondary_Reason__c = cs.Secondary_Reason__c; //
        stageObject.Account_Name__c = cs.Account.Name;
        stageObject.Case_Servicing_Dealer__c = cs.Servicing_Dealer__r.Name;
        stageObject.Case_Servicing_Dealer_Code__c = cs.Case_Servicing_Dealer_Code__c; 
        stageObject.Responsible_Region__c = cs.Responsible_Region__c;
        stageObject.Responsible_District__c = cs.Responsible_District__c;

        if (userNamesById.containsKey(cs.CreatedById)){
              stageObject.Created_By__c = userNamesById.get(cs.CreatedById);
        }
        
        if (userNamesById.containsKey(cs.OwnerId)){
              stageObject.Case_Owner__c = userNamesById.get(cs.OwnerId);
        }

        stageObject.Customer_ID__c = cs.Account.Customer_ID__c;
        stageObject.Case_Owner_Role__c = cs.Owner.UserRole.Name;
        stageObject.Case_Owner_Location__c = cs.Case_Owner_Location2__c;
        stageObject.Query_Filters__c =  reportSettings.Query_Filters__c  + ' ' + reportSettings.Query_Filters_2__c;
        stageObject.Report_Name__c = 'Bellomy Test Extract-VCS';
        stageObject.Person_Account_Email__c = cs.Account.PersonEmail;
        stageObject.Person_Account_home_Phone__c = cs.Account.PersonHomePhone;
        stageObject.Person_Account_mailing_city__c = cs.Account.PersonMailingCity;
        stageObject.Person_Account_Mailing_state_provin__c = cs.Account.PersonMailingState;
        stageObject.Person_Account_mailing_Street__c = cs.Account.PersonMailingStreet;
        stageObject.Person_Account_Mailing_Zip_postal__c = cs.Account.PersonMailingPostalCode; 
        stageObject.Person_Account_work_Phone__c = cs.Account.Phone; 
        stageObject.Batch_Status__c = 'New';
        return stageObject;
    }


    private void getUserNamesById(List<Case> cases){
        Set<Id> userIds = new Set<Id>();

        for (Case cs : cases){
            userIds.add(cs.CreatedById);
            userIds.add(cs.OwnerId);
        }

        for (User u : [SELECT Id, Name FROM User WHERE ID IN: userIds]){
            userNamesById.put(u.id, u.Name);
        }
    }

}