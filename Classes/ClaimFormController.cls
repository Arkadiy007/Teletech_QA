public with sharing class ClaimFormController {

    private final String STRING_BREAK = '\r\n';
    private final static Integer DEFAULT_LIMIT = 1000; 
    Case caseToCreate = new Case();
    Id caseRTId;
    private ValidationUtility dataCheck = new ValidationUtility();
    Sites_Daily_Limit__c limits;
    String caseOrigin;
    boolean isLimitChecked = false;
    Boolean isValidCampaign = false;
    
    public String fName{get; set;}
    public String lName{get; set;}
    public String Address1{get; set;}
    public String Address2{get; set;}
    public String city{get; set;}
    public String state{get; set;}
    public string zipCode {get; set;}
    public String dayPhone {get; set;}
    public string ePhone{get; set;}
    public String email{get; set;}
    public string vehModel {get; set;}
    public String modelYr{get; set;}
    public String vin{get; set;}
    public String vinEncrypted{get; set;}
    public decimal amount {get; set;}
    public String caseNumber {get; set;}
    
    public String userName {get; set;} 
    public String ownerSign {get; set;} 
    public String coOwnerSign{get; set;} 
    public String date1{get; set;} 
   
    public boolean isSuccess { get; set; }
    
    public boolean canProceed { get; set; }
      
   
   //Attachments
    public List<Attachment> attachments { get; set; }
    public Integer fileSize {get; set;}
    public Attachment attachment { get; set;}
    public String extension {get; set;}
    private Boolean wasAttachmentAdded;
    public String fileName {get; set;}
    public String intrnalFileName {get; set;}
    Map<String, Claim_Form_Settings__c> claimsSettings = Claim_Form_Settings__c.getAll();
    List<String> modelYearList = new List<String>();
    List<String> modelLineList = new List<String>();
    List<Vehicle__c> vehList = new List<Vehicle__c>();
    
    public ClaimFormController(){
                
        attachment = new Attachment();
        attachments = new List<Attachment>();
        date1 = Date.today().format();
        isSuccess = false;
        canProceed = false;
        if(claimsSettings.get(Label.Claim_NissanVersa) != null){
           if(claimsSettings.get(Label.Claim_NissanVersa).Model_Line__c != null){
                modelLineList = claimsSettings.get(Label.Claim_NissanVersa).Model_Line__c.split(',');
            }
            if(claimsSettings.get(Label.Claim_NissanVersa).Model_Years__c != null){
                modelYearList = claimsSettings.get(Label.Claim_NissanVersa).Model_Years__c.split(',');            
            }  
            
            caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(claimsSettings.get(Label.Claim_NissanVersa).Case_Record_Type__c).getRecordTypeId(); 
            caseOrigin = claimsSettings.get(Label.Claim_NissanVersa).Case_Origin__c;              
        }
        isLimitChecked = true;
        
    }
    
    
    
    public PageReference CheckValidVehicle(){
    
        Set<String> validCampaigns = new Set<String>();
        isValidCampaign = false;
        if(vin != null && vin != ''){
         vehList = [Select Id, Name, Model_Year__c, Model_Line_Name__c from Vehicle__c where Name =: vin AND Model_Line_Name__c IN: modelLineList AND Model_Year__c IN :modelYearList  limit 1];
         if(vehList.size() > 0){
             if(claimsSettings.get(Label.Claim_NissanVersa).Eligible_Campaign__c != null){
             	for(String s : claimsSettings.get(Label.Claim_NissanVersa).Eligible_Campaign__c.split(',')){
             		if(s != null && s != ''){
             		validCampaigns.add(s.trim());
             		}
             	}
             
             }            
             List<Vehicle_Recall__c> vehRecList = [Select Master_Recall_Campaign__r.Name, Id From Vehicle_Recall__c where Vehicle__c =: vehList[0].Id];             
             if(vehRecList.size() > 0 && validCampaigns.size() > 0 ){
                 for(Vehicle_Recall__c vehRec : vehRecList){                 	
                     if(validCampaigns.contains(vehRec.Master_Recall_Campaign__r.Name)){
                         modelYr = vehList[0].Model_Year__c;
                         vehModel = vehList[0].Model_Line_Name__c;
                         vinEncrypted = 'XXXXXXXXX'+vin.substring(9);
                         isValidCampaign = true;
                     }
                 }
                         
             }
             if(isValidCampaign == false){ 
                     modelYr = '';
                     vehModel = '';
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Vehicle_Campaign_Invalid));
             }    
         }else{
              modelYr = '';
              vehModel = '';
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Invalid_VIN));
         }
        }else{
             modelYr = '';
             vehModel = '';
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Invalid_VIN));
        }
    
        return null;
    }
    
    public PageReference save(){
    
        isSuccess = false;
        canProceed = false;
        String caseDescription = '';
        
        if(!validateFields()){                     
            caseToCreate.RecordTypeId = caseRTId;
            if(claimsSettings.get(Label.Claim_NissanVersa) != null){
                if(claimsSettings.get(Label.Claim_NissanVersa).Case_Owner_Id__c != null){
                    caseToCreate.OwnerId = claimsSettings.get(Label.Claim_NissanVersa).Case_Owner_Id__c;
                }
                if(claimsSettings.get(Label.Claim_NissanVersa).Status__c != null){
                    caseToCreate.Status = claimsSettings.get(Label.Claim_NissanVersa).Status__c;
                }
                if(claimsSettings.get(Label.Claim_NissanVersa).Case_Origin__c != null ){
                     caseToCreate.Origin = claimsSettings.get(Label.Claim_NissanVersa).Case_Origin__c;   
                     caseOrigin = claimsSettings.get(Label.Claim_NissanVersa).Case_Origin__c;                 
                }
            }     
            
            if(vehList.size() > 0){
                 caseToCreate.Vehicle_Name__c = vehList[0].Id;
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Invalid_VIN)); 
                return null;
            }
            
            caseDescription += 'First Name: ' + 
                formatField(fName) + STRING_BREAK;               
            caseDescription += 'Last Name: ' + 
                formatField(lName) + STRING_BREAK;
            caseDescription += 'Address1: ' + 
                formatField(Address1) + STRING_BREAK;
            caseDescription += 'Address2: ' + 
                formatField(Address2) + STRING_BREAK;                
            caseDescription += 'City: ' + 
                formatField(city) + STRING_BREAK;
            caseDescription += 'State: ' + 
                formatField(state) + STRING_BREAK;
            caseDescription += 'Zip: ' + 
                formatField(zipCode) + STRING_BREAK;
            caseDescription += 'Daytime Phone: ' + 
                formatField(dayPhone) + STRING_BREAK;
            caseDescription += 'Evening Phone: ' + 
                formatField(ePhone) + STRING_BREAK;
            caseDescription += 'Email Address: ' + 
                formatField(email) + STRING_BREAK;
            caseDescription += 'Vehicle Model: ' + 
                formatField(vehModel) + STRING_BREAK;
            caseDescription += 'Model Year: ' + 
                formatField(modelYr) + STRING_BREAK;
            caseDescription += 'VIN: ' + 
                formatField(vin) + STRING_BREAK;
            caseDescription += 'Amount: $' + 
                formatField(String.valueOf(amount)) + STRING_BREAK;
            caseDescription += 'Owners Signature: ' + 
                formatField(ownerSign) + STRING_BREAK; 
            caseDescription += 'CO-Owner Signature: ' + 
                formatField(coOwnerSign) + STRING_BREAK; 
            caseDescription += 'Dated: ' + 
                formatField(date1) + STRING_BREAK;
                
            caseToCreate.Description = caseDescription;       
                
            canProceed = true;
             
            }
        
        return null;
    }
    
    
    public PageReference upload() {
        
        System.debug('caseToCreate::'+caseToCreate);
       
        
        if (String.isEmpty(fileName)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Set_File_Name));
            //this.attachment = new Attachment();
            return ApexPages.currentPage();
        }

        if (attachment.body == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Select_File));
            return ApexPages.currentPage();
        }
        if (fileSize < 26214400) {
            
          try{
               
            if(caseToCreate.Id == null){
                 insert caseToCreate;
            }    
             
            Attachment a = attachment.clone(false, true, false, false);

            //clear body of uploaded file to remove from view state
            attachment.body = null;
 
            //create the attachment
            a.OwnerId = UserInfo.getUserId();
            a.ParentId = caseToCreate.Id; // the record the file is attached to
            a.IsPrivate = false;
            a.Name = fileName + '.' + extension;

            try {
                Database.Insert(a);
                wasAttachmentAdded = true;
                a.body = null;
                attachments.add(a);
                fileName = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.Attachment_uploaded_Success));
            } catch(DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Error_Uploading_Attachment));
                return null;
            } finally {
                attachment = new Attachment();
            }
            
            return ApexPages.currentPage();
           }catch(Exception ex){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
           } 
           
        } else {
            attachment.body = null;
            attachment = new Attachment();
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.File_Size_too_Large));
            return ApexPages.currentPage();
        }
        
        return null;
    }
    
    public PageReference submit(){
        
        if(caseToCreate.Id != null){
        generatePDFandSendEmail(caseToCreate.Id);  
        if(isSuccess){
            PageReference pgRef = Page.ClaimFormThankYou;
            pgRef.getParameters().put('caseNum',caseNumber);
            pgRef.setRedirect(true);
            isSuccess = false;
            return pgRef;
        }      
        }else{
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Attach_before_Submitting));
        }
        
       return null;  
    }
    
    private void generatePDFandSendEmail(Id caseId){
        PageReference pagRef = Page.ClaimFormPDF;        
        String pdfName; 
        
        List<Case> casList = [Select Id, CaseNumber from Case where Id =: caseId LIMIT 1];
        if( casList.size() > 0 ){
        caseNumber = casList[0].CaseNumber;        
        Blob pdfBlob;
        
        pdfName = 'Claims_Case#'+casList[0].CaseNumber+'_'+Date.today().format()+'.pdf';
        
        if (Test.IsRunningTest()) {
            pdfBlob = Blob.valueOf('UNIT.TEST');
        } else {
            pdfBlob = pagRef.getContentaspdf(); 
        }
        
        Attachment attachpdf = new Attachment(parentId = casList[0].Id, name = pdfName, body = pdfBlob); 
        insert attachpdf;
            
            try {
                // Create the email attachment
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setFileName(pdfName);
                emailAttachment.setBody(pdfBlob);
                
                String fromOrgId = claimsSettings.get(Label.Claim_NissanVersa).From_Address__c + '%';
                
                OrgwideEmailAddress  orgAdd = [Select Id, DisplayName From OrgWideEmailAddress where DisplayName like :fromOrgId limit 1];
                
                // Create the email
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
                singleEmail.setToAddresses(new String[] {email});
                singleEmail.setSubject('Case Number ' + caseNumber + ' Versa Front Coil Spring Reimbursement');
                singleEmail.setorgWideEmailAddressId(orgAdd.Id);
                String textBody = 'Thank you for contacting Nissan North America in regards to the 2007 to 2011 Versa Sedan and 2007 to 2012 Versa Hatchback Front Coil Spring Voluntary Safety Campaign. <br/><br/>'+
                                +'We have received your electronically submitted claim form and attachments for reimbursement of prior repairs under this campaign. <br/>'+
                                +'Case Number '+caseNumber+' has been generated for the Nissan Assist Team to review. <br/><br/>'+                                
                                +'If the information submitted is complete, the estimated processing time is within 30 days from the date Nissan received and you will receive periodic updates from the Nissan Assist team. <br/><br/>'+
                                +'If the information was not complete for us to begin our review, a Nissan Assist Team Member will contact you for additional information or documents.<br/><br/>'+
                                +'If you have any questions of concerns, please contact the Nissan Assist Team for information: <br/>'+
                                +'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phone: 1-800-867-7669  Monday through Friday, 7:00 a.m. to 11:00 p.m. Central Time and Saturday 7 a.m. - 5 p.m. Central Time <br/>'+
                                +'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;E-mail: nissanassist@nissan-usa.com with the above case number as your subject <br/><br/>'+
                                +'Please do not reply to this e-mail as it is sent from an e-mail address that does not accept e-mail and is not monitored.<br/><br/>'+
                                +'Sincerely, <br/> Nissan Assist Team <br/> ';

                singleEmail.setHtmlBody(textBody);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmail});
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.Case_Submitted_Success+casList[0].CaseNumber));
                isSuccess = true;
                
                
                clearAllFields();
                
                
            } catch(Exception e) {
                System.debug(e.getMessage());
                isSuccess = false;
            }
        
        }
        
    }
    
    private boolean validateFields(){
        
        boolean isError = false;
        String regex = '(\\d{5}(-\\d{4})?)?';
        if(fName == null || fName == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.First_Name_Required));
            isError = true;
        }if(lName == null || lName == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Last_Name_Required)); 
             isError = true;         
        }if(Address1 == null || Address1 == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Address1_Required));   
             isError = true;       
        }if(city == null || city == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.City_Required)); 
             isError = true;         
        }if(State == null || State  == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.State_Required)); 
            isError = true;         
        }if(zipCode == null || zipCode == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Zip_Code_Required)); 
            isError = true;         
        }if(email == null || email == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Email_Required)); 
            isError = true;         
        }if(vin == null || vin == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.VIN_Required));
            isError = true;          
        }if(dayPhone == null || dayPhone == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Daytime_Phone_Required)); 
            isError = true;         
        }if(userName == null || userName == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Self_Certify)); 
            isError = true;         
        }if(amount == null || amount <= 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Reimbursement_Amount)); 
            isError = true;         
        }if(ownerSign == null || ownerSign == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Owners_Signature)); 
            isError = true;         
        }
        if(State != null && State != ''){
            State = State.toUpperCase();
            List<State__c> states = [Select Id, Name from  State__c where Name =: State ];
            
            if(states.size() <= 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.State_Validation)); 
                isError = true; 
            }
        }if(amount != null && amount > claimsSettings.get(Label.Claim_NissanVersa).Amount_Limit__c){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Reimbursement_Amount_Limit+claimsSettings.get(Label.Claim_NissanVersa).Amount_Limit__c)); 
            isError = true;         
        }
        
        if(zipCode != null && zipCode != ''){
            Matcher m = Pattern.compile(regex).matcher(zipCode);
            if(!m.matches()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Valid_ZIP_Code)); 
                isError = true;
            }
        }
        if(vin != null && vin != '' && !isValidCampaign){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Vehicle_Campaign_Invalid));
            isError = true;
        }
        
        
        return isError;
    }
    
    // It replace a null or an empty field by a '-'
    private String formatField(String field) {
        if (dataCheck.IsStringNullOrEmpty(field)) {
            return '-';
        }
        else {
            return field;   
        }   
    }
    
    private void clearAllFields(){
        
         fName = '';
         lName = '';
         Address1 = '';
         Address2 = '';
         city = '';
         state = '';
         zipCode = ''; 
         dayPhone = '';
         ePhone = '';
         email = '';
         vehModel = '';
         modelYr = '';
         vin = '';
         vinEncrypted = '';
         amount = 0;
         caseToCreate = new Case();
         canProceed = false;
         
    }
    
    public PageReference limitsProcessing() {
        Integer i = DEFAULT_LIMIT;
        if(isLimitChecked){
        isLimitChecked = false;
        limits = Sites_Daily_Limit__c.getOrgDefaults();
        
        if(limits != null && limits.Claims_Daily_Limit__c != null)  {
            i = Integer.valueOf(limits.Claims_Daily_Limit__c);
        }
        
        String usrId = Userinfo.getUserId();

        Integer countWC= database.countQuery('SELECT Count() FROM Case WHERE CreatedDate = TODAY AND RecordTypeId =:caseRTId And CreatedById =:usrId AND Origin =: caseOrigin  LIMIT : i');
        
        System.debug('countWC = ' + countWC);
        if (countWC >= limits.Claims_Daily_Limit__c) {
            PageReference inMaintenancePage = Page.InMaintenance;
            inMaintenancePage.setRedirect(true);
            System.debug('inMaintenancePage = ' + inMaintenancePage);
            return inMaintenancePage;
        }
        
        }
          
        return null;
    }

    
}