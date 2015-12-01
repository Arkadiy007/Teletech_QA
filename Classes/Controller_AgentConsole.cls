public class Controller_AgentConsole {
    
    /***
    TO DO: 
call attempt number - fix alignment 
email consents 
phone seq 
consent for home and work phone 
    
    ***/
    // 01/05/12:    JJ      
    // Added new property isXTimeDisplay, used to display a new section of content on Contact_Webservices
    // This parameter is used in the GetAppointmentSubscribeURL service call, isSimpleRecord was removed from that call
    // Added new property isNotXTimeDealer, as a quick solution to handling the "internal" message recieved on non-xtime dealers
    // without changing any of the service methods. Added check for internal value upon record return in the above method.
    
    // 01/24/12:    JJ
    // Added new else statement at getScriptURL to test loading the NCI script for Nissan English

    // 01/31/12:    JJ
    // Modified getDisplaySendEmailCheckbox() to include check on incentives field and correct the return type
    // Added remaining if statements in getScriptURL ofr NCI campaigns, reformatted method, added Incentive_Offer__c to query
    
    // 02/08/12:    JJ
    // Added method to retrieve call centre id of user, and to assign username, password and endpoint based
    // on this data, defaulted to 6 based on feedback from non-agent account access.
    // Added header for WFC call type and organized heeader retrieve
    
    // 02/09/2012:  JJ
    // Add getIsXTimeDealer method and rendered attribute on appoint subscribe url based on this value
    
    // 03/16/2012: JJ
    // Added CallType to the task query and set it to NULL, as it will be expected by TMS webservices
    // Undid this change on 03/26/2012, Seba told me orchestration doesn't care
    
    public CampaignMember campmem{get;set;}
    public Contact contact{get;set;}
    public Vehicle__c vehicle{get;set;}
    public Account account{get;set;}
    public Account dealer{get;set;}
    public List<Task> callList{get;set;}
    public Task thisCall{get;set;}
    public boolean displayPopup {get; set;}
    
    Contact Cont;
    public Account contAccount; 
    
    public List<SelectOption> workPhoneSequences {get; set;}
    public List<SelectOption> mobilePhoneSequences {get; set;}
    public List<SelectOption> phoneSequences {get; set;}
    public List<SelectOption> consentValues{get;set; }
    public List<SelectOption> emailTypeValues{get;set; }
    public List<SelectOption> commaudTypeValues{get;set; }
    
    
    
    public Controller_AgentConsole(ApexPages.StandardController controller) {
        Id cId = ((Contact) controller.getRecord()).Id;
        Cont = (Contact) controller.getRecord();
        loadObjects(cId);
    }
    
    //What is this? Does not seem to be called anywhere
    public String getWLCVisiblity(){
        String isVisible;
        System.debug('campmem: ' + campmem);
        try{
        if(campmem.Service_Marketing_Call_Type__c !=null && campmem.Service_Marketing_Call_Type__c == system.label.WLC){
        
            isVisible = system.label.visible;
        }
        else{
            isVisible = system.label.hidden;
        }
        
        return isVisible;
        }
        catch (Exception e){
            System.debug('Exception e:' + e);
            return system.label.hidden;
        }
    }
    
    

    public void loadObjects(Id cId){
        System.debug('cId 1: ' + cId); 
        try{
        this.campmem = [SELECT id, Incentive_Offer__c, Preferred_Mail_Type__c, Call_Attempt_Number__c, Non_Solicit__c, ContactId, Language__c, Vehicle_Make__c,Vehicle__c, Vehicle_Year__c, VehicleModel__c, Service_Marketing_Call_Type__c, 
            Vehicle_Identification_Number__c,Preferred_Call_Time__c, Contact.AccountId, Phone_1__c, RecordType.Name FROM CampaignMember WHERE ContactId =: cId AND CampaignMember.Campaign.isActive =: TRUE ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
        this.account = [select id,  Email_Type_1__c, Email_Type_2__c,  Other_Phone_Extension__c,Home_Phone_Do_Not_Call__c, Mobile_Phone_Do_Not_Call_Indicator__c, Salutation, PersonHasOptedOutOfEmail, Alternate_Email__c, Home_Phone_Sequence__c, Other_Phone_Sequence__c, Mobile_Phone_Sequence__c, PersonOtherPhone, FirstName, MiddleName__c, LastName, PersonMailingCountry, PersonMailingPostalCode, PersonMailingState, Preferred_Dealer_Id__c, 
            IsPersonAccount, PersonContactId, Do_Not_Email_In__c, PersonMailingCity, PersonMailingStreet, PersonEmail, PersonMobilePhone, PersonHomePhone, TMS_Customer_ID__c, PersonDoNotCall, Other_Phone_Do_Not_Call_In__c FROM Account where id =: campmem.Contact.Accountid];
        
       Schema.DescribeFieldResult comment_audience = Schema.sObjectType.Task.fields.Comment_Audience__c;
        List<Schema.PicklistEntry> comValues = comment_audience.getPicklistValues();
        commaudTypeValues = new List<SelectOption>();
     
        for(Schema.PicklistEntry val : comValues) {
            commaudTypeValues.add(new SelectOption(val.getLabel(), val.getValue()));
        }
     
     
     
     
        Schema.DescribeFieldResult email_type_1 = Schema.sObjectType.Account.fields.Email_Type_1__c;
        List<Schema.PicklistEntry> eValues = email_type_1.getPicklistValues();
        emailTypeValues = new List<SelectOption>();
     
        for(Schema.PicklistEntry val : eValues) {
            emailTypeValues.add(new SelectOption(val.getLabel(), val.getValue()));
        }
     
     
     
     
     
        Schema.DescribeFieldResult home_phone_consent = Schema.sObjectType.Account.fields.Home_Phone_Do_Not_Call__c;
        List<Schema.PicklistEntry> cValues = home_phone_consent.getPicklistValues();
        consentValues = new List<SelectOption>();
     
        for(Schema.PicklistEntry val : cValues) {
            consentValues.add(new SelectOption(val.getLabel(), val.getValue()));
        }
     
     
        Schema.DescribeFieldResult home_Phone_Sequence = Schema.sObjectType.Account.fields.Home_Phone_Sequence__c;
        List<Schema.PicklistEntry> values = home_Phone_Sequence.getPicklistValues();
        phoneSequences = new List<SelectOption>();
        phoneSequences.add(new SelectOption(system.label.None,system.label.None));
        for(Schema.PicklistEntry val : values) {
            phoneSequences.add(new SelectOption(val.getLabel(), val.getValue()));
        }
        
        Schema.DescribeFieldResult work_Phone_Sequence = Schema.sObjectType.Account.fields.Other_Phone_Sequence__c;
        values = work_Phone_Sequence.getPicklistValues();
        workPhoneSequences = new List<SelectOption>();
        workPhoneSequences.add(new SelectOption(system.label.None,system.label.None));
        for(Schema.PicklistEntry val : values) {
            workPhoneSequences.add(new SelectOption(val.getLabel(), val.getValue()));
        }  
        
        Schema.DescribeFieldResult mobile_Phone_Sequence = Schema.sObjectType.Account.fields.Mobile_Phone_Sequence__c;
        values = mobile_Phone_Sequence.getPicklistValues();
        mobilePhoneSequences = new List<SelectOption>();
        mobilePhoneSequences.add(new SelectOption(system.label.None,system.label.None));
        for(Schema.PicklistEntry val : values) {
            mobilePhoneSequences.add(new SelectOption(val.getLabel(), val.getValue()));
        }     
        //////////////////////////////////////////////////////////////
        
        if(account.Preferred_Dealer_Id__c !=null){
            this.dealer =  [select id, Name, Dealer_Attributes_Text__c, Dealer_Code__c FROM Account WHERE id =: account.Preferred_Dealer_Id__c];
        } 
        else{
            Account blankDealer = new Account(name = system.label.No_Selection, Dealer_Code__c = '', Dealer_Attributes_Text__c = '');
            this.dealer = blankDealer;
            
        }
        

        
        
        System.debug('cId 2 :' + cId);
        this.callList  = [select id,Temp_Away_Start_Date__c , Question_1__c, Question_2__c, Satisfaction__c, Comment_Audience__c, Customer_Experience__c,  WhatId, Temp_Away_End_Date__c, Mail_Stop_Start_Date__c, Mail_Stop_End_Date__c, AccountId, Preferred_Dealer_Change_Reason__c, Preferred_Dealer_Change__c, Service_Description__c, Request_Date__c,
         Request_Time__c, Action_Type__c, Call_End_Time__c, CallDisposition__c, Send_Email_Request_Indicator__c, Deceased__c, Agent_ID__c,
         Owner.Name, Call_Back_Time__c, Call_Start_Time__c, CreatedDate,CallObject, Description
         FROM Task WHERE Task.WhoId =: cId ORDER BY CreatedDate DESC LIMIT 10];
        
         this.vehicle = [select id, PMG_Type__c, Latest_Recorded_Mileage_Number__c,
         Latest_Recorded_Mileage_Units__c FROM Vehicle__c WHERE  id =: campmem.Vehicle__c]; 
                    
        this.contact = [select id , Customer_Id__c, AccountId from Contact where id =: cId];
        this.thisCall = new Task(CallDisposition__c = '',Description = '', Call_Back_Phone__c = campmem.Phone_1__c);    
        
        }
        catch(Exception e){
            System.debug('Exception e:' + e);
            
        }
            
        
        //system.debug('callList.size: ' + callList.size());
        system.debug('cId: '  + cId);
        system.debug('campmem: ' + campmem);
        system.debug('account: ' + account);
        system.debug('dealer: ' + dealer);
        system.debug('callList: ' + callList);
        system.debug('vehicle: ' + vehicle);    
        system.debug('thisCall : '  + thisCall );
        
    }
    
    public String getChangeContact(){
        PageReference pageRef = Page.createNewTMSContact;
        String theURL = pageRef + '';
        return theURL;
        
    }
    
    public String getIsExpressDealer(){
        String isExpressDealer;
        if(dealer.Dealer_Attributes_Text__c != null && dealer.Dealer_Attributes_Text__c.contains(system.label.Express))
            isExpressDealer = system.label.YES;
        else
            isExpressDealer = system.label.NO; 
    
        return isExpressDealer;
        
    }
    
    public Boolean getDisplaySendEmailCheckbox(){
        Boolean displaySendEmailCustomField;
        
        if(dealer.Dealer_Attributes_Text__c != null && campmem.Incentive_Offer__c != null)
        {
            if(dealer.Dealer_Attributes_Text__c.contains(system.label.Incentives) && campmem.Incentive_Offer__c != '')
                displaySendEmailCustomField = true;
            else
                displaySendEmailCustomField = false;
        }
        else
        {
            displaySendEmailCustomField = false;
        }
        
        return displaySendEmailCustomField;
    }
    
    public Boolean getIsXTimeDealer(){
        Boolean isXTimeDealer = false;
        
        if(dealer.Dealer_Attributes_Text__c != null && dealer.Dealer_Attributes_Text__c.contains(system.label.XTime))
        {
            isXTimeDealer = true; 
        }
        
        return isXTimeDealer;
    }
    
    public String getHeader(){
        String header = '';
        String nonsol = ' ';
        if(campmem.Non_Solicit__c)
        {
            nonsol = system.label.Non_Solicit;
        }
        
        if(campmem.Service_Marketing_Call_Type__c == system.label.NSC)
        { 
            header = system.label.Overdue_Service_Call + nonsol;
        }
        else if(campmem.Service_Marketing_Call_Type__c == system.label.WLC)
        {
            header= system.label.Welcome_Call + nonsol;
        }
        else if(campmem.Service_Marketing_Call_Type__c == system.label.SFC)
        {
            header= system.label.Service_Follow_up_Call + nonsol;
        }
        else if(campmem.Service_Marketing_Call_Type__c == system.label.WFC)
        {
            header= system.label.Warranty_Followup_Call + nonsol;
        }
        
        return header;
    }
    
    public Account getAccount(){
        return account;
        
    }
    
    public Vehicle__c getVehicle(){
        return vehicle;
        
    }
    
    public CampaignMember getCampMemb(){
        
        return campmem;
    }
    
    public Account getDealer(){
        return dealer; 
        
    }
    
    
    public List<Task> getCallList(){
        return callList;
        
    }
    
    public Task getThisCall(){
        return thisCall;
        
    }
    
    public String getScriptURL(){
        string scriptURL;
        if (campmem.RecordType.Name == 'Infiniti English Evening' || campmem.RecordType.Name == 'Infiniti English Day') {
            scriptURL = label.ScriptUrlInfinitiEnglish +'&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'Nissan English Day' || campmem.RecordType.Name == 'Nissan English Evening') {
            scriptURL = label.ScriptURLNissanEnglish +'&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'Infiniti Spanish Day' || campmem.RecordType.Name == 'Infiniti Spanish Evening') {
            scriptURL = label.ScriptUrlInfinitiSpanish +'&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'Nissan Spanish Evening' || campmem.RecordType.Name == 'Nissan Spanish Day') {
            scriptURL = label.ScriptURLNissanSpanish +'&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'NCV English Day') {
            scriptURL = label.ScriptUrlNCV +'&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'NCI Nissan English Evening' || campmem.RecordType.Name == 'NCI Nissan English Day')
        {
            scriptURL = label.ScriptURLNCINissanEnglish + '&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'NCI Nissan French Day' || campmem.RecordType.Name == 'NCI Nissan French Evening')
        {
            scriptURL = label.ScriptURLNCINissanFrench + '&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'NCI Infiniti English Day' || campmem.RecordType.Name == 'NCI Infiniti English Evening')
        {
            scriptURL = label.ScriptURLNCIInfinitiEnglish + '&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        else if (campmem.RecordType.Name == 'NCI Infiniti French Day' || campmem.RecordType.Name == 'NCI Infiniti French Evening')
        {
            scriptURL = label.ScriptURLNCIInfinitiFrench + '&CampaignMemberID='  + campmem.id + '&UserId=' + UserInfo.getUserId(); 
        }
        System.debug(scriptURL);
        return scriptURL; 
    }   
    
   String callDispo;


   public PageReference customSave() {
        try{
        id theuserid = UserInfo.getUserId();    
         List<Task>updateCallList = new List<Task>([select id,Temp_Away_Start_Date__c ,Temp_Away_End_Date__c, Mail_Stop_Start_Date__c, Mail_Stop_End_Date__c, AccountId, Preferred_Dealer_Change_Reason__c, Service_Description__c, Request_Date__c,
         Request_Time__c, Action_Type__c, WhatId, Call_End_Time__c, CallDisposition__c, Send_Email_Request_Indicator__c, Deceased__c, Agent_ID__c,
         Owner.Name, Call_Back_Time__c, Call_Start_Time__c, CreatedDate,CallObject, Description, CallType
         FROM Task WHERE Task.WhoId =: account.PersonContactId 
         AND Task.Subject like 'Reservation%'
         AND Task.CreatedById = : theuserid
         ORDER BY CreatedDate DESC LIMIT 10]);
        
        system.debug('Task ID: ' + updateCallList[0].id);
        system.debug('account.PersonContactId:  ' + account.PersonContactId);
    
        Boolean NewTask;
        Task updateCall = new Task();     
        
        updateCall = updateCallList[0];
        updateCall.Temp_Away_Start_Date__c = thisCall.Temp_Away_Start_Date__c ;
        updateCall.Temp_Away_End_Date__c =thisCall.Temp_Away_End_Date__c ;
        updateCall.Mail_Stop_Start_Date__c =thisCall.Mail_Stop_Start_Date__c ;
        updateCall.Mail_Stop_End_Date__c =thisCall.Mail_Stop_End_Date__c ;
        updateCall.WhatId =thisCall.WhatId ;
        updateCall.Preferred_Dealer_Change_Reason__c =thisCall.Preferred_Dealer_Change_Reason__c ;
        updateCall.Service_Description__c =thisCall.Service_Description__c ;
        updateCall.Request_Date__c=thisCall.Request_Date__c;
        updateCall.Request_Time__c =thisCall.Request_Time__c ;
        updateCall.Action_Type__c =thisCall.Action_Type__c ;
        updateCall.Preferred_Dealer_Change__c = thisCall.Preferred_Dealer_Change__c;
        updateCall.CallDisposition__c =thisCall.CallDisposition__c ;
        updateCall.Send_Email_Request_Indicator__c =thisCall.Send_Email_Request_Indicator__c ;
        updateCall.Deceased__c =thisCall.Deceased__c;
        updateCall.Agent_ID__c = thisCall.Agent_ID__c;
        Pattern nonNumber = Pattern.compile('\\D');
        updateCall.Call_Back_Phone__c = thisCall.Call_Back_Phone__c == null ? '' : nonNumber.matcher(thisCall.Call_Back_Phone__c).replaceAll('');
        updateCall.Call_Back_Time__c = thisCall.Call_Back_Time__c;
        updateCall.Call_Back_Daytime_Indicator__c = thisCall.Call_Back_Daytime_Indicator__c;
    
        updateCall.CallObject =thisCall.CallObject ;
        updateCall.Description=thisCall.Description;
        updateCall.Question_1__c=thisCall.Question_1__c;
        updateCall.Question_2__c=thisCall.Question_2__c;
        updateCall.Satisfaction__c=thisCall.Satisfaction__c;
        updateCall.Comment_Audience__c= thisCall.Comment_Audience__c;
        updateCall.Customer_Experience__c=thisCall.Customer_Experience__c;
        updateCall.Service_Description__c=thisCall.Service_Description__c;
        updateCall.Temp_Away_Start_Date__c=thisCall.Temp_Away_Start_Date__c;
        
        if (System.label.Task_Log == 'true') {
            Task_Log__c log = null;
            log = new Task_Log__c();
            log.Task_Id__c = updateCall.id;
            log.Service_Marketing_Call_Id__c = updateCall.Service_Marketing_Call_Id__c;
            String logInfo = 'Custom Save called';
            log.Log_Info__c = logInfo;
            insert log;
        }

    /**
        updateCall.Call_Back_Time__c = thisCall.Call_Back_Time__c;
        updateCall.Call_End_Time__c = thisCall.Call_End_Time__c;
        updateCall.Call_Start_Time__c = thisCall.Call_Start_Time__c; 
        **/
        System.debug('thisCall.Call_Back_Time__c: ' + thisCall.Call_Back_Time__c);
        System.debug('thisCall.Call_End_Time__c: ' + thisCall.Call_End_Time__c); 
        System.debug('updateCall.Call_End_Time__c: '  +         updateCall.Call_End_Time__c);
        System.debug(' updateCall.Call_End_Time__c: '  +  updateCall.Call_End_Time__c);
        System.debug('updateCall: '  + updateCall);
        System.debug('Person Mailing State: ' + account.PersonMailingState);
        if(updateCall.CallDisposition__c !=null && updateCall.CallDisposition__c.contains(system.label.Callback) &&
           (updateCall.Call_Back_Time__c == null ||
            updateCall.Call_Back_Phone__c == null)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.warning,system.label.Error_Message_on_Call_Disposition));
        }
        if(updateCall.CallDisposition__c !=null && !updateCall.CallDisposition__c.contains(system.label.Callback) &&
            (updateCall.Call_Back_Time__c != null || updateCall.Call_Back_Daytime_Indicator__c == true)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.warning,system.label.Call_Back_Time_Not_On_Callback));
        }
        if(updateCall.CallDisposition__c !=null && updateCall.CallDisposition__c.contains(system.label.Callback) &&
                updateCall.Call_Back_Time__c <= System.now()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.warning,system.label.Call_Back_Time_Must_Be_Future));
        }
        if (account.PersonMailingCity == null || account.PersonMailingCity.length() <= 0) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Please_provide_Mailing_City));
        }
        if (account.PersonMailingCountry == null || account.PersonMailingCountry.length() <= 0) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Please_provide_Mailing_Country));
        }
        if (account.PersonMailingPostalCode == null || account.PersonMailingPostalCode.length() <= 0) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Please_provide_Mailing_Postal_Code));
        }
        if (account.PersonMailingState == null || account.PersonMailingState.length() <= 0) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Please_provide_Mailing_State));
        }
        if (account.Home_Phone_Sequence__c != system.label.None && account.Other_Phone_Sequence__c != system.label.None  && account.Home_Phone_Sequence__c == account.Other_Phone_Sequence__c) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Home_Phone_Sequence_cannot_equal_Work_Phone_sequence));
        }
        if (account.Home_Phone_Sequence__c != system.label.None  && account.Mobile_Phone_Sequence__c != system.label.None  && account.Mobile_Phone_Sequence__c == account.Home_Phone_Sequence__c) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Home_Phone_Sequence_cannot_equal_Mobile_Phone_sequence));
        }
        if (account.Other_Phone_Sequence__c != system.label.None && account.Mobile_Phone_Sequence__c != system.label.None && account.Mobile_Phone_Sequence__c == account.Other_Phone_Sequence__c) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Other_phone_Sequence_cannot_equal_Mobile_Phone_sequence));
        }
        if ((account.Home_Phone_Sequence__c == system.label.None  && account.PersonHomePhone != null)  || (account.Other_Phone_Sequence__c == system.label.None   && account.PersonOtherPhone != null) ||(account.Mobile_Phone_Sequence__c == system.label.None   && account.PersonMobilePhone != null)) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.If_phone_is_populated_you_must_selected_a_phone_sequence));
        }
        if (thisCall.Service_Description__c  == null &&
                 (updateCall.CallDisposition__c == system.label.Appointment_Lead ||
                  updateCall.CallDisposition__c == system.label.Appointment_Requested)) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Service_Description_is_Required));
        }
        if ((thisCall.Request_Date__c  == null ||
                  thisCall.Request_Time__c == null) &&
                 (updateCall.CallDisposition__c == system.label.Appointment_Requested)) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Request_Date_and_Time_are_Required));
        }
        if (thisCall.Customer_Experience__c  == null) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Customer_Experience_is_Required));
        }
        if (account.FirstName == null) {
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.First_name_is_a_required_field));
        }
        if (CampMem.Preferred_Mail_Type__c == system.label.Email && (account.Alternate_Email__c == null || account.Alternate_Email__c == '') && (account.PersonEmail == null || account.PersonEmail == '')){
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Email_or_Alternate_Email_is_required_if_Preferred_mail_is_email));
        }
        if ( updateCall.Request_Date__c != null && updateCall.Action_Type__c == null){
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Action_Type_is_required_if_Request_Date_is_selected));
        }     
        if ((account.PersonMailingStreet != null && (account.PersonMailingCity == null || account.personmailingstate == null || account.PersonMailingPostalCode == null || account.personmailingCountry == null)) ||
                (account.PersonMailingCity != null && (account.PersonMailingStreet == null || account.personmailingstate == null || account.PersonMailingPostalCode == null || account.personmailingCountry == null)) ||
                (account.personmailingstate != null && (account.PersonMailingCity == null || account.PersonMailingStreet == null || account.PersonMailingPostalCode == null || account.personmailingCountry == null)) ||
                (account.PersonMailingPostalCode != null && (account.PersonMailingCity == null || account.personmailingstate == null || account.PersonMailingStreet == null || account.personmailingCountry == null)) ||
                (account.personmailingCountry != null && (account.PersonMailingCity == null || account.personmailingstate == null || account.PersonMailingPostalCode == null || account.PersonMailingStreet == null))) {
            
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Address_Is_Required));  
        }
        if ((updateCall.Mail_Stop_Start_Date__c == null && updateCall.Mail_Stop_End_Date__c != null) ||
                 (updateCall.Mail_Stop_Start_Date__c != null && updateCall.Mail_Stop_End_Date__c == null)){
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Mail_Stop_Date_Error));
        }

        if ((updateCall.Temp_Away_Start_Date__c == null && updateCall.Temp_Away_End_Date__c != null) ||
                 (updateCall.Temp_Away_Start_Date__c != null && updateCall.Temp_Away_End_Date__c == null)){
            ApexPages.addMessage(new Apexpages.message(Apexpages.severity.warning, system.label.Temp_Away_Date_Error));
        }
        if (!ApexPages.hasMessages()) {
        //system.debug('### mail types:  ' + thisCall.Preferred_Mail_Type__c);
            /**
             * 2/25/2011 Bryan Fry - try to go to another page when disposition 
             * is saved to see if it makes a difference with screen pops not
             * overwriting data in agent console.            
             */
            // Keep track of whether we've updated the objects.
            Boolean updated = false;
            
              if (updateCall.CallDisposition__c != null && System.label.CheckLatestTaskOnSave == 'true') {
                  Id userId = UserInfo.getUserId();
                  Task checkTask = [select Id, WhoId from Task where createdbyid = :userId and CallDisposition__c = null order by createddate desc limit 1];
                        System.debug('userid = ' + userId + ' task = ' + checkTask + ' contactId = ' + account.PersonContactId);
                  if (checkTask != null && checkTask.WhoId != null && checkTask.WhoId != account.PersonContactId) {
                        // The newest undispositioned task is not what we're trying to save,
                        // so save our Task information to that newest Task,but don't save any
                        // other information outside of just the Task.
                        checkTask.Customer_Experience__c = updateCall.Customer_Experience__c;
                        checkTask.Service_Description__c = updateCall.Service_Description__c;
                        checkTask.CallDisposition__c = updateCall.CallDisposition__c;
                        update checkTask;
                        updated = true;
                  }
            }
                  
            // If we did not update the call to a different task, do the normal updates here
            if (updated == false) {
                  update campmem;
                  update vehicle;
                  update account;
      
                  if(dealer.Name == system.label.no_selection){
                 
                  }
                  else{
                        update dealer;
                  }
      
                  update updateCall;
            }
            
            
            
            // Direct to the home page if the call is dispositioned.
            if (updateCall.CallDisposition__c != null) {
                  return new PageReference('/apex/NNA_closeAgentConsoleTab');
            } else {                
                  return null;
            }
            
            

            /*
            if(NewTask){
                  updateCall.WhoId = contact.Id; 
                  insert updateCall;
                  system.debug('### Inserted ' + updateCall);
            }
            else {
                  update updateCall;
                  system.debug('### Updated ' + updateCall);
            }
            */
        }
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.Your_record_did_not_save_properly_Error+ e));
            
        }
            
    
        return null;
   }
   
   
    /*
        TMS Web-Service Calls Code
    */
    
    
    public string appointmentDate {get; set;}
    public string appointmentTime {get; set;}
    public string id {get; set;}
    public string apiName {get; set;}
    public string error {get; set;}
    public boolean isError {get; set;}
    public boolean isSimpleRecord {get; set;}
    public List<TMS_Webservices_Utility.Record> records {get; set;}
    public boolean isServiceResponse {get; set;}
    public boolean isServiceHistoryResponse {get; set;}
    public boolean isListOfRecords {get; set;}
    public boolean isXTimeDisplay { get; set; }
    public boolean isNotXTimeDealer { get; set; }
    public List<List<TMS_Webservices_Utility.Record>> listOfRecords {get; set;}
    public List<TMS_Webservices_Utility.ServiceResponse> serviceResponses{get; set;}
    public List<TMS_Webservices_Utility.ServiceHistoryResponse> serviceHistoryResponses{get; set;}
    public Account accountRec {get; set;}
    public Contact contactRec {get; set;}
    public boolean havePrefferedDealerAccount {get; set;}
    public string dealerCode {get; set;}
    public string customerId {get; set;}
    public Controller_AgentConsole() {
        apiName = ApexPages.currentPage().getParameters().get(system.label.api);
        string contactId = ApexPages.currentPage().getParameters().get(system.label.contactID);
        string id = ApexPages.currentPage().getParameters().get(system.label.id);
        accountRec = [Select id, Preferred_Dealer_Id__c, Dealer_Code__c, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, TMS_Customer_ID__c, billingcity, billingpostalcode, billingstate, name, phone from Account where id = :id];
        if (contactId != null) {
            contactRec = [Select id,name,Customer_ID__c from contact where id = :contactId];
        }
        customerId = accountRec.TMS_Customer_ID__c;
        havePrefferedDealerAccount = false;
        if(accountRec.Preferred_Dealer_Id__c != null){
            Account prfferedDealer =  [select id, Dealer_Attributes_Text__c, Dealer_Code__c FROM Account WHERE id =: accountRec.Preferred_Dealer_Id__c];
            havePrefferedDealerAccount = true;
            dealerCode = prfferedDealer.Dealer_Code__c;
        } 
        isError = false;
        appointmentDate = ApexPages.currentPage().getParameters().get(system.label.date);
        appointmentTime = ApexPages.currentPage().getParameters().get(system.label.Time);
    }
    
    public void RunWebService() {
        
        if(!serviceAccessAssigned)
        {
            if(getCallCentreID() != 4)
            {
                TMS_Webservices_Utility.setServiceAccess(System.label.TMS_Endpoint, System.label.username, System.label.password);
            }
            else if(getCallCentreID() == 4)
            {
                TMS_Webservices_Utility.setServiceAccess(System.label.TMS_NCI_Endpoint, System.label.usernameNCI, System.label.passwordNCI);
            }
            
            serviceAccessAssigned = true;
        }
        
        if (apiName == system.label.GetDealerInfo) {
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunGetDealerInfo(dealerCode);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            isSimpleRecord  = true && !isError;
        }   
    
     else if (apiName == system.label.SearchDealer) {
            try {
                
                listOfRecords = TMS_Webservices_Utility.RunSearchDealer(accountRec);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunSearchDealer();
            isListOfRecords = true && !isError;
        } 
     
     else if (apiName == system.label.GetPrimaryContactInfo) {
            try {
                records = TMS_Webservices_Utility.RunGetPrimaryContactInfo(customerId);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetPrimaryContactInfo();
            isSimpleRecord = true && !isError;
        }
   
     else if (apiName == system.label.GetServiceHistory) {
            try {
                               
                serviceHistoryResponses = TMS_Webservices_Utility.RunGetServiceHistory(customerId);
                
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetServiceHistory();
            isServiceHistoryResponse = true && !isError;
        }
     
    else if (apiName == system.label.GetCommunicationHistory) {
            try {
                listOfRecords = TMS_Webservices_Utility.RunGetCommunicationHistory(customerId);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetCommunicationHistory();
            isListOfRecords = true && !isError;
        }
    
    else if (apiName == system.label.CheckAppointment) {
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunCheckAppointment(dealerCode, appointmentDate, appointmentTime);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunCheckAppointment();
            isSimpleRecord = true && !isError;
        }
        
   
    else if (apiName == system.label.CheckAppointmentTime) {
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunCheckAppointmentTime(dealerCode, appointmentDate);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            isSimpleRecord = true && !isError;
    }
     
    
    else if (apiName == system.label.GetServicesDue) {
            try {
                serviceResponses = TMS_Webservices_Utility.RunGetServicesDue(customerId);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetServicesDue();
            isServiceResponse = true && !isError;
        }
    
   
    else if (apiName == system.label.GetAssociatedCustomers) {
            try {
                listOfRecords = TMS_Webservices_Utility.RunGetAssociatedCustomers(customerId);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            //RunGetAssociatedCustomers();
            isListOfRecords = true && !isError;
        }
  
    else if (apiName == system.label.GetAppointmentSubscribeURL) {
            
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURL(dealerCode, customerId);
                
                if(records[0].value == 'internal')
                {
                    isNotXTimeDealer = true;
                }
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            /// Adding for XTime display
            isXTimeDisplay = true && !isError;
        }

    else if (apiName == system.label.GetAppointmentSubscribeURLNCI) {
            
            try {
                if (havePrefferedDealerAccount == false) {
                    throw new TMS_Webservices_Utility.WebServiceException(TMS_Webservices_Utility.prefferedDealerError);
                }
                records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURLNCI(dealerCode, customerId);
                System.debug('records = ' + records);
                if(!records[0].value.contains('xtime.com'))
                {
                    isNotXTimeDealer = true;
                }
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            /// Adding for XTime display
            isXTimeDisplay = true && !isError;
        }   

    else if (apiName == system.label.Getassociated_dcno_id) {
             try {
                records = TMS_Webservices_Utility.RunGetassociated_dcno_id(customerId);
            }
            catch (Exception e) {
                error =  e.getMessage();
                isError = true;
            }
            
            //RunGetassociated_dcno_id();
            isSimpleRecord = true && !isError;
        }  
   
    }
    public PageReference PaasParams() {
        cont = [select id, AccountId from Contact where id = :Cont.id];
        contAccount = [Select Name, id from Account where Id = :Cont.AccountId];
        return new PageReference('/apex/contact_Webservices?'+'&'+system.label.api+'='+apiName + '&'+system.label.id +'='+ contAccount.Id + '&'+system.label.contactID+'=' +Cont.Id); 
    }
    
    public PageReference PaasParamsforDate() {
        cont = [select id, AccountId from Contact where id = :Cont.id];
        contAccount = [Select Name, id from Account where Id = :Cont.AccountId];
        return new PageReference('/apex/CheckDateTime?'+'&'+system.label.api+'='+apiName +'&'+system.label.id+'='+ contAccount.Id +'&'+system.label.contactID+'='+ Cont.Id +'&'+system.label.Type+'=contact');
    }
    
    public PageReference PaasParamsforDateTime() {
        cont = [select id, AccountId from Contact where id = :Cont.id];
        contAccount = [Select Name, id from Account where Id = :Cont.AccountId];
        return new PageReference('/apex/CheckDate?'+'&'+system.label.api+'='+apiName + '&'+system.label.id+'=' + contAccount.Id + '&'+system.label.contactID+'=' + Cont.Id +'&'+system.label.Type+'=contact');
    }
    public PageReference checkLatestTask() {
      if (System.label.CheckLatestTaskOnLoad == 'true') {
            Id userId = UserInfo.getUserId();
            Id contactId = ApexPages.currentPage().getParameters().get('id');
            Task checkTask = [select WhoId from Task where createdbyid = :userId and CallDisposition__c = null order by createddate desc limit 1];
                  System.debug('userid = ' + userId + ' task = ' + checkTask + ' contactId = ' + contactId);
            if (checkTask != null && checkTask.WhoId != null && checkTask.WhoId != contactId) {
                  return new PageReference('/' + checkTask.WhoId);
            }
      }
      return null;
   }
   
   // Store call centre id off user and if the endpoint, username and password based on this
   // id have been assigned
   private integer callCenterID;
   public boolean serviceAccessAssigned = false;
   
   // Retrieve call centre id of user
   public integer getCallCentreID()
   {
        if(callCenterID == null)
        {
            User userRecord =  [Select Call_Centre_Id__c From User Where Id =: UserInfo.getUserId()];
            
            if(userRecord == null || userRecord.Call_Centre_Id__c == null)
            {
                callCenterID = 6;
            }
            else
            {
                callCenterID = integer.valueOf(userRecord.Call_Centre_Id__c);
            }
        }
        
        return callCenterID;
   }
}