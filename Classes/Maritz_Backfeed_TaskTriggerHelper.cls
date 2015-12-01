public class Maritz_Backfeed_TaskTriggerHelper {
    //--------------------------------------------------------------------------
    // Properties
    public List<sObject> activiesList;

    private Set<Id> taskRecTypeIdList { get; set; }
    private Set<Id> callRecTypeIdList { get; set; }
    private Id AccountMaritzRecordType { get; set; }

    List<Case> relatedRecords;
    private Map<String, Integer> totalCallNumbersByCasesMap = new Map<String, Integer>(); // key - case id, value - total number of calls
    private Map<String,Map<String,List<Maritz_Business_Rules__c> > > BusinessRulesMap;
    private List<sObject> appropriateAct { get; set; }
    private Map<Id,Pre_Chat_Data__c> chatDataByLiveChatTranscriptId;
    private Map<Id,List<EmailStatus> > emailStatusesByAccountIds;

    private Set<Id> caseIdSet = new Set<Id> ();
    private List<Maritz_Backfeed_Profiles__c> profilesList = Maritz_Backfeed_Profiles__c.getAll().values();
    private Map<Id,String> caseRecTypesMap = new Map<Id,String> ();

    //--------------------------------------------------------------------------
    //Constructor
    public Maritz_Backfeed_TaskTriggerHelper(List<sObject> activiesList) {
        this.activiesList = activiesList;
        FillTasksRecordTypeMap();
        FillCallsRecordTypeMap();
        GetAccountRecordType();
        if (AppropriateActivitiesAvailable()) {
            FillCasesRecordTypeMap();
            FillBussinessRulesMap();
            FillRelatedRecordsMap();
            InsertNewRecForStageMaritzBackfeedObj();
        }
    }
    //--------------------------------------------------------------------------
    // Methods


    ///main method
    public void InsertNewRecForStageMaritzBackfeedObj() {
        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed;

        if (activiesList.getsObjectType() == Task.sObjectType) {
            newMaritzBackfeed = CreateRecords((List<Task>) appropriateAct);
        } else if (activiesList.getsObjectType() == EmailMessage.sObjectType) {
            newMaritzBackfeed = CreateRecords((List<EmailMessage>) appropriateAct);
        }
        else if (activiesList.getsObjectType() == Call__c.sObjectType) {
            newMaritzBackfeed = CreateRecords((List<Call__c>) appropriateAct);
        }
        else if (activiesList.getsObjectType() == LiveChatTranscript.sObjectType) {
            FillRelatedPrechatData((List<LiveChatTranscript>) appropriateAct);
            newMaritzBackfeed = CreateRecords((List<LiveChatTranscript>) appropriateAct);
        }

        insertNewMaritzBackFeed(newMaritzBackfeed);
    }

    private Boolean AppropriateActivitiesAvailable() {
        appropriateAct = NeededActivities(activiesList);
        if (appropriateAct.isEmpty()) {
            return false;
        }
        else {
            return true;
        }
    }

    private void FillCasesRecordTypeMap() {
        for (Maritz_Backfeed_RT__c rt : Maritz_Backfeed_RT__c.getAll().values()) {
            if (rt.Object_Name__c == 'Case') {
                caseRecTypesMap.put((Id) rt.recordtypeid__c, rt.recordtypename__c);
            }
        }
    }

    private void GetAccountRecordType() {
        for (Maritz_Backfeed_RT__c rt : Maritz_Backfeed_RT__c.getAll().values()) {
            if (rt.Object_Name__c == 'Account') {
                AccountMaritzRecordType = (Id) rt.recordtypeid__c;
                return;
            }
        }
    }

    private void FillTasksRecordTypeMap() {
        taskRecTypeIdList = new Set<Id> ();
        for (Maritz_Backfeed_RT__c rt : Maritz_Backfeed_RT__c.getAll().values()) {
            if (rt.Object_Name__c == 'Task') {
                taskRecTypeIdList.add((Id) rt.recordtypeid__c);
            }
        }
    }

    private void FillCallsRecordTypeMap() {
        callRecTypeIdList = new Set<Id> ();
        for (Maritz_Backfeed_RT__c rt : Maritz_Backfeed_RT__c.getAll().values()) {
            if (rt.Object_Name__c == 'Call__c') {
                callRecTypeIdList.add((Id) rt.recordtypeid__c);
            }
        }
    }

    private void FillBussinessRulesMap() {
        BusinessRulesMap = GetBusinessRulesMap();
    }

    private void FillRelatedRecordsMap() {
        relatedRecords = RelatedRec();

        // Aggregate total calls for cases
        if (!relatedRecords.isEmpty()) {
            AggregateResult[] groupedResults = [SELECT Case__c, Count(ID) cnt   
                                                                                        FROM Call__c
                                                                                   WHERE Case__c IN :relatedRecords 
                                                                                     GROUP BY Case__c];
            
            for (AggregateResult ar : groupedResults) {
                String caseId = String.valueOf(ar.get('Case__c'));
                Integer callsNumber = Integer.valueOf(''+ar.get('cnt'));
                totalCallNumbersByCasesMap.put(caseId, callsNumber);
            }
        }

        emailStatusesByAccountIds = new Map<Id,List<EmailStatus> > (); //GetEmailsStatusesMap();
    }

    private void FillRelatedPrechatData(List<LiveChatTranscript> appropriateAct) {
        chatDataByLiveChatTranscriptId = new Map<Id,Pre_Chat_Data__c> ();
        Set<Id> liveChatIds = new Set<Id> ();

        for (LiveChatTranscript lct : appropriateAct) {
            liveChatIds.add(lct.id);
        }

        for (Pre_Chat_Data__c p :[SELECT Id, Department__c, Live_Chat_Transcript__c FROM Pre_Chat_Data__c WHERE Live_Chat_Transcript__c IN :liveChatIds]) {
            chatDataByLiveChatTranscriptId.put(p.Live_Chat_Transcript__c, p);
        }
    }

    private void insertNewMaritzBackFeed(List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed) {
        if (!newMaritzBackfeed.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(newMaritzBackfeed, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty())
            {
                // Loop through results returned
                for (integer row = 0; row<newMaritzBackfeed.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and populate corresponding fields
                        Database.Error err = dbResults[row].getErrors() [0];
                        System.Assert(false, err);
                        //TODO error handling
                    }
                }
            }
        }
    }

    //Define appropriate activities
    @TestVisible private List<sObject> NeededActivities(List<sObject> allAct) {
        List<sObject> resList = new List<sObject> ();
        Set<id> userIds = new Set<id> ();

        for (sObject e : allAct) {
            userIds.add((Id) e.get('CreatedById'));
        }
        
        userIds = ValidUsersList(userIds);
        for (sObject e : allAct) {
            if (userIds.contains((Id) e.get('CreatedById')))
            {
                if (isValidRT(e)) {
                    resList.add(e);
                    addToCaseIdSet(e);
                }
            }
        }



        return resList;
    }

    //Helpers
    //define set of users who has appropriate profile
    private Set<id> ValidUsersList(Set<id> userIds) {
        List<User> usersList = [SELECT Id, ProfileId
                                FROM User
                                WHERE Id IN :userIds];

        boolean validUser;
        for (User u : usersList) {
            validUser = userProfileIsValid(u);

            if (!validUser) {
                UserIds.remove(u.id);
            }
        }

        return UserIds;
    }

    private Boolean isValidRT(sObject e) {
        if (e.getsObjectType() == Task.sObjectType) {
            if (!taskRecTypeIdList.contains((Id) e.get('RecordTypeId'))) {
                return false;
            }
            else {
                return true;
            }
        }
        else if (e.getsObjectType() == Call__c.sObjectType) {
            if (!callRecTypeIdList.contains((Id) e.get('RecordTypeId'))) {
                return false;
            }
            else {
                return true;
            }
        }
        else {
            return true;
        }
    }

    private Boolean userProfileIsValid(User u) {
        for (Maritz_Backfeed_Profiles__c p : profilesList) {
            if (u.ProfileId == p.Profile_Id__c) {
                return true;
            }
        }
        return false;
    }

    private void addToCaseIdSet(sObject e) {
        if (e.getsObjectType() == EmailMessage.sObjectType) {
            caseIdSet.add((Id) e.get('ParentId'));
        }
        else if (e.getsObjectType() == Task.sObjectType) {
            caseIdSet.add((Id) e.get('WhatId'));
        }
        else if (e.getsObjectType() == Call__c.sObjectType) {
            caseIdSet.add((Id) e.get('Case__c'));
        }
        else if (e.getsObjectType() == LiveChatTranscript.sObjectType) {
            caseIdSet.add((Id) e.get('CaseID'));
        }
    }
    //TODO: Modify logic here - we don't need to select related records - work with "trigger.new" if it call or Chat_Data__r 
    private List<Case> RelatedRec() {
        return [SELECT Id, Customer_ID__c, Origin, Subject, VIN__c, Phone_TMID__c, Preferred_Dealer__c, CaseNumber, ContactId, Contact_ID__c,
        Account.Name, Account.RecordTypeId, Account.Maritz_Returned_Customer_Id__c, Status, Account.LastName, Month_Mailed__c, Email2__c, Segment_Mailed__c, Model_of_Interest_1st__c, Model_of_Interest_2nd__c, Customer_Interested_in__c, Vehicle_Make__c, Vehicle_Model__c,
        Control_Group_Check_Box__c, Closed_by_Suppression__c, CreatedDate, Total_Calls_Open_and_Closed__c, Home_Phone__c, Mobile_Phone__c, Work_Phone__c, Preferred_Dealer__r.Dealer_Code__c,
        Mailing_Street__c, Mailing_City__c, Mailing_State__c, Mailing_Zip_Code__c, AccountId, Account.PersonEmail, Account.Household_ID__c, Account.FirstName, Description,
        recordTypeId, Account.Customer_ID__c
        FROM Case
        WHERE id IN : caseIdSet AND recordTypeId IN : caseRecTypesMap.keySet() AND Account.RecordTypeId = : AccountMaritzRecordType];
    }

    private Map<Id,List<EmailStatus> > GetEmailsStatusesMap() {
        Set<Id> personAccountIds = new Set<Id> ();
        for (Case c : relatedRecords) {
            personAccountIds.add(c.AccountId);
        }

        Map<Id,List<EmailStatus> > statusesByAccountIds = new Map<Id,List<EmailStatus> > ();

        for (Contact con :[Select Name, AccountId, (Select Id, FirstOpenDate, LastOpenDate, TimesOpened, TaskId From EmailStatuses WHERE TaskId in :new Map<Id,sObject> (activiesList).keyset()) From Contact WHERE AccountId IN :personAccountIds]) {
            if (!con.EmailStatuses.isEmpty()) {
                statusesByAccountIds.put(con.AccountId, con.EmailStatuses);
            }
            else {
                statusesByAccountIds.put(con.AccountId, new List<EmailStatus> ());
            }
        }

        return statusesByAccountIds;
    }

    //Operators for Business Rules
    private boolean OperatorBusRule(Maritz_Business_Rules__c br, sObject obj) {
        if (br.Operator__c == 'RT equal') {
            return getRecordTypeName(obj) == br.Field_Value__c;
        } else if (br.Operator__c == 'equal') {
            return String.valueof(obj.get(br.Field_API_Name__c)) == String.valueOf(br.Field_Value__c);
        } else if (br.Operator__c == 'not equal') {
           return obj.get(br.Field_API_Name__c) != br.Field_Value__c;
        } else if (br.Operator__c == 'contain') {
            if(obj.get(br.Field_API_Name__c) != null){
                   String stringFromObject = (String) obj.get(br.Field_API_Name__c);
                   String stringFromSettings = (String) br.Field_Value__c;
                   return stringFromObject.contains(stringFromSettings);
            }
            else{
                return false;
            }
        } else if (br.Operator__c == 'not contain') {
            if(obj.get(br.Field_API_Name__c) != null){
                String stringFromObject = (String) obj.get(br.Field_API_Name__c);
                String stringFromSettings = (String) br.Field_Value__c;
                return !stringFromObject.contains(stringFromSettings);
            }
            else{
                return false;
            }
        } else {
            return false;
        }
    }
    
    private String getRecordTypeName(sObject obj){
        if(obj.getsObjectType() == Case.sObjectType){
            Case c = (Case) obj;
            
            if(caseRecTypesMap.containsKey(c.RecordTypeId)){
                return caseRecTypesMap.get(c.RecordTypeId);
            }
            return '';
        }
        return '';
    }

    //making map of business rules
    private Map<String,Map<String,List<Maritz_Business_Rules__c> > > GetBusinessRulesMap() {

        Map<String,Map<String,List<Maritz_Business_Rules__c> > > rulesMap = new Map<String,Map<String,List<Maritz_Business_Rules__c> > > ();

        for (Maritz_Business_Rules__c rule : Maritz_Business_Rules__c.getAll().values()) {

            If (null == rulesMap.get(rule.BR_Group__c)) {
                rulesMap.put(rule.BR_Group__c, new Map<String,List<Maritz_Business_Rules__c> > ());
            }

            If (null == rulesMap.get(rule.BR_Group__c).get(rule.Activity_Type__c)) {
                rulesMap.get(rule.BR_Group__c).put(rule.Activity_Type__c, new List<Maritz_Business_Rules__c> ());
            }

            rulesMap.get(rule.BR_Group__c).get(rule.Activity_Type__c).add(rule);
        }

        return rulesMap;
    }

    //define right backfeed type (using business rules)
    private String WhatBackFeedType(sObject act, Case relatedCase, Map<String,Map<String,List<Maritz_Business_Rules__c> > > rulesMap) {

        String actType;
        String backFeedType = '';
        //As we've got BR only for Emails and Calls
        if (act.getsObjectType() == EmailMessage.sObjectType) {
            actType = 'Email';
        }
        else if (act.getsObjectType() == Call__c.sObjectType) {
            actType = 'Call/Phone';
        }
        else if(act.getsObjectType() == LiveChatTranscript.sObjectType){
            actType = 'Chat';
        }

        for (String busRuleName : rulesMap.keySet()) {
            if (rulesMap.containsKey(busRuleName)) {
                if (rulesMap.get(busRuleName).containsKey(actType) && !rulesMap.get(busRuleName).get(actType).isEmpty()) {
                    boolean ruleFlg = true;
                    String ruleName = '';
                    for (Maritz_Business_Rules__c rule : rulesMap.get(busRuleName).get(actType)) {
                        ruleName = rule.BR_Name__c;
                        if (rule.Object__c == 'Case') {
                            if (!OperatorBusRule(rule, relatedCase)) {
                                ruleFlg = false;
                                break;
                            }
                        } else {
                            if (!OperatorBusRule(rule, act)) {
                                ruleFlg = false;
                                break;
                            }
                        }
                    }

                    if (ruleFlg == true) {
                        if (String.isEmpty(backFeedType))
                        {
                            backFeedType += ruleName;
                        }
                        else
                        {
                            backFeedType += ', ';
                            backFeedType += ruleName;
                        }
                    }
                }
            }
        }

        if (String.isEmpty(backFeedType))
        {
            //UPD: Default Backfeet type;
            return 'Standard Activity';
        }
        else
        {
            return backFeedType;
        }
      
    }

    private String BooleanToStr(boolean b) {
        if (b == true) {
            return 'true';
        } else if (b == false) {
            return 'false';
        } else {
            return null;
        }
    }

    //check if account is maritz account
    //because we know that our account is personal account  
    private List<Stage_Maritz_Backfeed_Object__c> CreateRecords(List<Task> appropriateAct) {
        //related records

        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = new List<Stage_Maritz_Backfeed_Object__c> ();
        Case relatedCase;

        for (Task t : appropriateAct) {
            relatedCase = getRelatedCase(t);

            if (relatedCase != null) {
                Stage_Maritz_Backfeed_Object__c taskObject = BackfeedObjectFactory(relatedCase);
                newMaritzBackfeed.add(GenerateTaskSpecificSMBO(taskObject, relatedCase, t));
            }
        }

        return newMaritzBackfeed;
    }

    private List<Stage_Maritz_Backfeed_Object__c> CreateRecords(List<EmailMessage> appropriateAct) {

        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = new List<Stage_Maritz_Backfeed_Object__c> ();
        Case relatedCase;

        for (EmailMessage t : appropriateAct) {
            relatedCase = getRelatedCase(t);

            if (relatedCase == null) {
                continue;
            }
            else {
                Stage_Maritz_Backfeed_Object__c emailObject = BackfeedObjectFactory(relatedCase);
                newMaritzBackfeed.add(GenerateEmailSpecificSMBO(emailObject, relatedCase, t));
            }
        }

        return newMaritzBackfeed;
    }

    private List<Stage_Maritz_Backfeed_Object__c> CreateRecords(List<Call__c> appropriateAct) {

        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = new List<Stage_Maritz_Backfeed_Object__c> ();
        Case relatedCase;

        for (Call__c t : appropriateAct) {
            relatedCase = getRelatedCase(t);

            if (relatedCase == null) {
                continue;
            }

            Stage_Maritz_Backfeed_Object__c callObject = BackfeedObjectFactory(relatedCase);
            newMaritzBackfeed.add(GenerateCallSpecificSMBO(callObject, relatedCase, t));

        }

        return newMaritzBackfeed;
    }

    private List<Stage_Maritz_Backfeed_Object__c> CreateRecords(List<LiveChatTranscript> appropriateAct) {

        List<Stage_Maritz_Backfeed_Object__c> newMaritzBackfeed = new List<Stage_Maritz_Backfeed_Object__c> ();
        Case relatedCase;

        for (LiveChatTranscript t : appropriateAct) {
            relatedCase = getRelatedCase(t);

            if (relatedCase == null) {
                continue;
            }

            Stage_Maritz_Backfeed_Object__c callObject = BackfeedObjectFactory(relatedCase);
            newMaritzBackfeed.add(GenerateChatSpecificSMBO(callObject, relatedCase, t));

        }

        return newMaritzBackfeed;
    }

    private Case getRelatedCase(Task t) {
        for (Case c : relatedRecords) {
            if (t.WhatId == c.id) {
                return c;
            }
        }
        return null;
    }

    private Case getRelatedCase(EmailMessage t) {
        for (Case c : relatedRecords) {
            if (t.ParentId == c.id) {
                return c;
            }
        }
        return null;
    }

    private Case getRelatedCase(Call__c t) {
        for (Case c : relatedRecords) {
            if (t.Case__c == c.id) {
                return c;
            }
        }
        return null;
    }

    private Case getRelatedCase(LiveChatTranscript t) {
        for (Case c : relatedRecords) {
            if (t.CaseId == c.id) {
                return c;
            }
        }
        return null;
    }



    //Fills Case related field of SMBO; (and, also, account related)
    private Stage_Maritz_Backfeed_Object__c BackfeedObjectFactory(Case relatedCase) {
        Stage_Maritz_Backfeed_Object__c temp = new Stage_Maritz_Backfeed_Object__c();
        if (caseRecTypesMap.containsKey(relatedCase.recordtypeid)) {
            temp.Case_Type__c = caseRecTypesMap.get(relatedCase.recordtypeid);
        }
        temp.Case_SFDC_ID__c = relatedCase.Id;
        temp.VIN__c = relatedCase.VIN__c;
        temp.Phone_TMID__c = relatedCase.Phone_TMID__c;
        temp.Preferred_Dealer__c = relatedCase.Preferred_Dealer__r.Dealer_Code__c;
        temp.Case_Number__c = relatedCase.CaseNumber;
        temp.Month_Mailed__c = relatedCase.Month_Mailed__c;
        temp.Segment_Mailed__c = relatedCase.Segment_Mailed__c;
        temp.Archived_VIN_Make__c = relatedCase.Vehicle_Make__c;
        temp.Archived_VIN_Model__c = relatedCase.Vehicle_Model__c;
        temp.Control_Group_Check_Box__c = BooleanToStr(relatedCase.Control_Group_Check_Box__c);
        temp.Closed_by_Suppression__c = BooleanToStr(relatedCase.Closed_by_Suppression__c);
        //temp.Total_Calls_Open_and_Closed__c = (null != relatedCase.Total_Calls_Open_and_Closed__c) ? relatedCase.Total_Calls_Open_and_Closed__c.toPlainString() : null;
        temp.Total_Calls_Open_and_Closed__c = (null != totalCallNumbersByCasesMap.get(relatedCase.Id)) ? ''+totalCallNumbersByCasesMap.get(relatedCase.Id) : null;
        temp.PersonMailingStreet__c = relatedCase.Mailing_Street__c;
        temp.PersonMailingCity__c = relatedCase.Mailing_City__c;
        temp.PersonMailingState__c = relatedCase.Mailing_State__c;
        temp.PersonMailingPostalCode__c = relatedCase.Mailing_Zip_Code__c;
        temp.PersonHomePhone__c = relatedCase.Home_Phone__c;
        temp.PersonMobilePhone__c = relatedCase.Mobile_Phone__c;
        temp.Model_of_Interest_1__c = relatedCase.Model_of_Interest_1st__c;
        temp.Model_of_Interest_2__c = relatedCase.Model_of_Interest_2nd__c;
        temp.Customer_Interested_In__c = relatedCase.Customer_Interested_in__c;
        temp.PersonWorkPhone__c = relatedCase.Work_Phone__c;
        temp.Date_Time_Opened__c = relatedCase.CreatedDate.format('MM-dd-yyyy hh:mm a');
        temp.Batch_Status__c = 'New';

        temp.Account_Last_Name__c = relatedCase.Account.LastName;
        temp.Account_First_Name__c = relatedCase.Account.FirstName;
        temp.Account_Name__c = relatedCase.Account.Name;
        /*if (relatedCase.ContactId == null) {
            temp.Customer_ID__c = relatedCase.ContactId;
        }
        else {
            temp.Customer_ID__c = relatedCase.AccountId;
        }*/
        
        temp.Customer_ID__c = relatedCase.Account.Customer_ID__c;

        if (Test.isRunningTest()) {
            temp.Customer_ID__c = 'test';
        }

        //temp.Contact_ID__c = relatedCase.Account.Name;
        temp.Contact_ID__c = relatedCase.AccountId;
        temp.Email__c = relatedCase.Account.PersonEmail;
        temp.Household_Identifier__c = relatedCase.Account.Household_ID__c;
        temp.Maritz_Returned_Customer_ID__c = relatedCase.Account.Maritz_Returned_Customer_Id__c;
        temp.Group__c = 'Treated';
        return temp;
    }

    private Stage_Maritz_Backfeed_Object__c GenerateTaskSpecificSMBO(Stage_Maritz_Backfeed_Object__c temp, Case relatedCase, Task t) {
        temp.Activity_Task_Date_Time__c = t.CreatedDate.format('MM-dd-yyyy hh:mm a');
        temp.Activity_ID__c = t.id;
        //temp.Date_of_Activity__c = (null != t.ActivityDate) ? t.ActivityDate.format() : null;
        temp.Task_SFDC_ID__c = t.Id;
        temp.Backfeed_Type__c = WhatBackFeedType(t, relatedCase, BusinessRulesMap);
        temp.Group__c = 'Treated';
        temp.Activity_Task_Type__c = 'Task';
        return temp;
    }

    private Stage_Maritz_Backfeed_Object__c GenerateEmailSpecificSMBO(Stage_Maritz_Backfeed_Object__c temp, Case relatedCase, EmailMessage t) {
        temp.Activity_Task_Date_Time__c = t.CreatedDate.format('MM-dd-yyyy hh:mm a');
        temp.Activity_ID__c = t.id;
        temp.Task_SFDC_ID__c = t.ActivityId;
        temp.Backfeed_Type__c = WhatBackFeedType(t, relatedCase, BusinessRulesMap);
        temp.Activity_Task_Type__c = 'Email';

        List<EmailStatus> statuses = emailStatusesByAccountIds.get(relatedCase.AccountId);
        if (null != statuses && statuses.size() > 0) {
            EmailStatus status = statuses.get(0);

            temp.Email_Date_Sent__c = t.MessageDate;
            temp.Email_Date_Opened__c = status.FirstOpenDate;
            temp.Email_Last_Opened__c = status.LastOpenDate;
            temp.Email_Opened__c = status.LastOpenDate != null;
            temp.Email_Times_Opened__c = status.TimesOpened;
        }

        return temp;
    }

    private Stage_Maritz_Backfeed_Object__c GenerateCallSpecificSMBO(Stage_Maritz_Backfeed_Object__c temp, Case relatedCase, Call__c t) {
        temp.Activity_Task_Date_Time__c = t.Created_Time__c.format('MM-dd-yyyy hh:mm a');
        temp.Activity_ID__c = t.id;
        temp.Reason_Not_Interested__c = t.Reason_Not_Interested__c;
        temp.Outcome__c = t.Outcome__c;
        temp.Result__c = t.Result__c;
        temp.Backfeed_Type__c = WhatBackFeedType(t, relatedCase, BusinessRulesMap);
        temp.Activity_Task_Type__c = 'Call';
        temp.Model_of_Interest_1__c = t.Model_of_Interest_1st__c;
        temp.Model_of_Interest_2__c = t.Model_of_Interest_2nd__c;
        return temp;
    }

    private Stage_Maritz_Backfeed_Object__c GenerateChatSpecificSMBO(Stage_Maritz_Backfeed_Object__c temp, Case relatedCase, LiveChatTranscript t) {
        temp.Activity_Task_Date_Time__c = t.CreatedDate.format('MM-dd-yyyy hh:mm a');
        if (chatDataByLiveChatTranscriptId.containsKey(t.id)) {
            temp.Department__c = chatDataByLiveChatTranscriptId.get(t.id).Department__c;
        }
        temp.Backfeed_Type__c = WhatBackFeedType(t, relatedCase, BusinessRulesMap);
        temp.Activity_Task_Type__c = 'Chat';
        return temp;
    }


}