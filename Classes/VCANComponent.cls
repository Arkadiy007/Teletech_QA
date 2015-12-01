/*
Page Title: VCANComponent
Author: Aaron Bessey
Create Date: 7/25/2015
Last Update: 7/29/2014
Updated By: Aaron Bessey

Revisions:
AAB - Initial Creation
AAB - 7/29/2014 - Updates to VCAN Comments
AAB - 8/1/2014 - Updates to VCAN Comments
AAB - 8/7/2014 - Fixes to VCAN error handling
AAB - 9/9/2014 - Save/Change Host Password
AAB - 9/11/2014 - Disable Logins to turn off host system
AAB - 9/12/2014 - Cleaned up disabled login messages
AAB - 9/24/2014 - WPS Authentication error messages  
AAB - 10/02/2014 - Adding Dealer/VIN Alerts
AAB - 12/19/2014 - Prevent users without write access from updating warranty case
AAB - 01/07/2015 - Fix for blank customer name in HOST VCAN
*/

public class VCANComponent {
    
    public String errorMessage {get; set;}    
    public String errorColor {get; set;} //Color:red css style
    public Boolean showErrorMessage {get; set;}
    public Boolean hasVCAN {get; set;}
    public String VCANHostComments {get;set;}
    
    //Dont save data when agent has no access
    public Boolean hasWriteAccess {get;set;}
    
    public Boolean canDelete {get;set;}
    public Boolean showDelete {get;set;}
    public Boolean canCreate {get;set;}
    public Boolean disableLogins {get;set;}
    public Double approvalLimit {get;set;}
    public Integer refrshTimeout {get;set;}
    public Boolean useRefreshTimeout{get;set;}
    public Boolean addSpace {get;set;}
    public Boolean parseVCANUsername {get;set;}
    
    public Warranty_Case__c warrantyCase {get; set;}
    
    public String pageURL {set;}    
    public Boolean showProgress {get; set;}
    public String LastModifiedByName {get; set;}
    public String VCANComment {get;set;}
    public String authKey {get;set;}
    
    public Dealer_VIN_Alerts__c foundDealerAlert {get;set;}
    public List<Dealer_VIN_Alerts__c> dealerVINAlerts {get;set;}
    public Boolean DealerVINAlert {get;set;}
    
    public String ApprovalStatus {get;set;}
    public String HostReferenceNumber {get;set;}
    public String HostErrorMessage {get;set;}
    public String HostComments {get;set;}
    public String ZCA_Id {get;set;}
    public String VCAN_Password {get;set;}
    public String VCAN_Service_User {get;set;}
    public String VCAN_Service_Password {get;set;}
    
    public string VCAN_Account_Locked_Error_String {get; set;}
    public string VCAN_Account_Locked_Error {get; set;}
    public string VCAN_Password_Error_String {get; set;}
    public string VCAN_Password_Error {get; set;}
    
    //Params for saving password
    public Boolean hasPassword {get;set;}
    public Boolean allowPasswordEntry {get;set;}
    public String newVCANPassword {get;set;}
    private Map<String, String> pgParamsMap = new Map<String, String>();
    private static final Blob key = Blob.valueOf('ABC1234DEF9012GHIJKLZZZYYY123465');
    private static final Blob IV = Blob.valueOf('123456ZCBDE4YAGH');
    
    public String CaseName {get;set;}    
    public User thisUser {get;set;}
    public String getPageURL() {
        ApexPages.StandardController sc = new ApexPages.StandardController(warrantyCase);   
        PageReference pageRef = sc.view();
        return pageRef.getUrl();    
    }
    
     Set<String> vCanSet = new Set<String>();
        
     
    
    public VCANComponent(ApexPages.StandardController stdController) {
        warrantyCase = (Warranty_Case__c) stdController.getRecord();
        
        hasWriteAccess = Schema.sObjectType.Warranty_Case__c.fields.Customer_Name__c.isUpdateable();
        
        //showErrorMessage = true;
        //errorMessage = 'Updateable: ' + hasWriteAccess;
        authKey = Label.VCAN_Auth_Key;
        //authKey = 'test:test';
        refrshTimeout = -1; //1 min ago
        parseVCANUsername = true;
        
        dealerVINAlerts = new List<Dealer_VIN_Alerts__c>();
        
        VCAN_Service_User = Label.VCAN_Service_User;
        VCAN_Service_Password = Label.VCAN_Service_Password;
        
        //AAB - 9/24/2014 - Params for password errors
        VCAN_Account_Locked_Error = Label.VCAN_Account_Locked_Error;
        VCAN_Account_Locked_Error_String = Label.VCAN_Account_Locked_Error_String;
        VCAN_Password_Error = Label.VCAN_Password_Error;
        VCAN_Password_Error_String = Label.VCAN_Password_Error_String;
        addSpace = true;
        thisUser = [select ID, warranty_app_amount__c, warranty_vcan_delete__c, ZCA_Id__c, VCAN_Password__c from User where Id=:System.UserInfo.getUserId()];
        
        String tmpLimit = thisUser.warranty_app_amount__c;
        
        String[] vCanCodes = Label.VCANErrorMessageCodes.split(';');
	    for(String s : vCanCodes){
	    	vCanSet.add(s);
	    }
        
        if(tmpLimit!= null && tmpLimit != '')
        {
            approvalLimit = Double.valueOf(thisUser.warranty_app_amount__c);
        }
        else
        {
            approvalLimit = 0;
        }
        canDelete = thisUser.warranty_vcan_delete__c;
        
        ZCA_Id = thisUser.ZCA_Id__c;
        VCAN_Password = thisUser.VCAN_Password__c;
        
        //Downgrade this user's access cause no write access to warranty cases
        if(!hasWriteAccess)
        {
            ZCA_Id = null;
            VCAN_Password = null;
        }
        
        if(Label.VCAN_Testing_Status=='true')
        {
            ZCA_Id = VCAN_Service_User;
            VCAN_Password = VCAN_Service_Password;
            Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(VCAN_Password));
            VCAN_Password = EncodingUtil.base64Encode(cipherText); 
        }
        
        if(VCAN_Password != null)
        {
            hasPassword = true;
        }
        
        if(ZCA_Id !='' && ZCA_Id != null && VCAN_Password!='' && VCAN_Password!=null)
        {
            canCreate = true;
        }
        else if(ZCA_Id != null)
        {
            allowPasswordEntry = true;
            VCAN_Password = '';
        }
        else
        {
            VCAN_Password = '';
        }   
        
        if(Label.VCAN_Disable_Logins=='true')
        {
            disableLogins = true;
        }
        else
        {
            disableLogins = false;
        }
        
        warrantyCase = [select ID, Name, Dealer__c, Dealer_Code__c, Vehicle__c, Vehicle__r.Name, Repair_Work_Order__c, 
                        Job_Line_Number__c, Customer_Concern__c,
                        Repair_Work_Order_Open_Date__c,
                        Vehicle_Mileage__c,
                        Primary_Failed_Part__c,
                        Requestor_s_Name__c,
                        Customer_Name__c,
                        Parts_at_Cost__c,
                        Force_Goodwill_Coverage__c,
                        Parts__c,
                        Labor__c,
                        Expenses__c,
                        Total_Amount_Approved__c,
                        Requestor_s_Phone_Number__c,
                        Internal_Comments__c,
                        Approval_Status__c, 
                        Approval_Information__c,
                        Normal_Approval__c,
                        Repeat_Repair_Review__c,
                        Mileage__c,
                        Duplicate_Campaign_Different_Dealer__c,
                        Goodwill_Approval__c,
                        HOST_Error_Message__c, HOST_Reference_Number__c,
                        Host_Comments__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                        Vehicle_Campaign1__c,
                        Vehicle_Campaign1__r.Name,
                        isVCANUpdate__c,
                        isSystemUpdate__c,
                        isApprovalStatusChanged__c,
                        CreatedDate
                        from Warranty_Case__c where Id=:warrantyCase.Id]; 
        
        ApprovalStatus = warrantyCase.Approval_Status__c;
        HostReferenceNumber = warrantyCase.HOST_Reference_Number__c;
        
        List<Dealer_VIN_Alerts__c> alerts = new List<Dealer_VIN_Alerts__c>();
        if(warrantyCase.Vehicle__c!=null)
        {
       		alerts = [select Alert_Comments__c, Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where VIN__c=:warrantyCase.Vehicle__c and Status__c='Active' order by ID desc];
       		dealerVINAlerts.addAll(alerts);
       		DealerVINAlert = dealerVINAlerts.size() > 0 ? true: false;
        }
        if(warrantyCase.Dealer__c!=null)
        {
            alerts = [select Alert_Comments__c, Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where Dealer__c=:warrantyCase.Dealer__c and Status__c='Active' AND VIN__c =null order by ID desc];
			dealerVINAlerts.addAll(alerts);
			DealerVINAlert = dealerVINAlerts.size() > 0 ? true: false;
        }
        /*else if (warrantyCase.Vehicle__c!=null)
        {
            alerts = [select Alert_Comments__c, Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where VIN__c=:warrantyCase.Vehicle__c and Status__c='Active' order by ID desc];
        }*/
        
       
        
        if(warrantyCase.Approval_Information__c!=null)
        {
            VCANComment = warrantyCase.Approval_Information__c;
        }
        
        if(HostReferenceNumber !=null && canDelete==true)
        {
            showDelete = true;
        }
        
        HostErrorMessage = warrantyCase.HOST_Error_Message__c;
        HostComments = warrantyCase.Host_Comments__c;
        CaseName = warrantyCase.Name;
        
        LastModifiedByName = warrantyCase.LastModifiedBy.Name + ', ' + warrantyCase.LastModifiedDate.format('MM/dd/yyyy HH:mm a');
        if(warrantyCase.Host_Reference_Number__c!=null)
        {
            hasVCAN = true;
            //Has vcan so canCreate=false
            canCreate = false;
        }
        else
        {
            hasVCAN = false;
        }
        
    }
    
    public PageReference refreshVCAN()
    {
        VCANJSONResponse oResponse;
        boolean didUpdate = false;
        String updateComments;  
        Boolean makeUpdateCallout = false;       
         
        System.debug('warrantyCase.HOST_Reference_Number__c::'+warrantyCase.HOST_Reference_Number__c+'--VCAN_Password::'+VCAN_Password+'--warrantyCase.Approval_Information__c'+warrantyCase.Approval_Information__c+'--warrantyCase.isVCANUpdate__c'+warrantyCase.isVCANUpdate__c);             
        System.debug('warrantyCase.HOST_Reference_Number__c::'+warrantyCase.HOST_Reference_Number__c);
        if(warrantyCase.HOST_Reference_Number__c!=null && VCAN_Password!=null && VCAN_Password.length() > 0 && warrantyCase.Approval_Information__c!=null && warrantyCase.isVCANUpdate__c)
        {
           oResponse =  updateVCANcallout(oResponse, warrantyCase);
           if(oResponse == null){
           	return null;
           }else{
           	warrantyCase.Approval_Information__c = '';
           }
        }
        
        oResponse = checkWarrantyCaseVCAN(warrantyCase.Id);
        System.debug('oResponse:::'+oResponse);
        
        if(oResponse.VCANRefNumber!=null)
        {
            Boolean doUpdate = false;
            if(didUpdate==false)
            {
                LastModifiedByName = oResponse.ChangedByName + ', ' + oResponse.ChangedDate;
            }
            
            if(warrantyCase.HOST_Reference_Number__c==null && warrantyCase.Approval_Information__c!=null)
            {
                doUpdate = true;
                updateComments = warrantyCase.Approval_Information__c;
            }
            
            warrantyCase.HOST_Reference_Number__c = oResponse.VCANRefNumber;
            hasVCAN = true;
            canCreate = false;
            if(canDelete)
            {
                showDelete = true;
            }
            HostReferenceNumber = warrantyCase.HOST_Reference_Number__c;
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            if(!didUpdate)
            {
                String hApprovalStatus = oResponse.ApprovalStatus.substring(0,1);
                if(hApprovalStatus=='P')
                {
                    warrantyCase.Approval_Status__c = 'Pending';
                }
                else if(hApprovalStatus=='A')
                {
                    warrantyCase.Approval_Status__c = 'Approved';
                }
                else if(hApprovalStatus=='D')
                {
                    warrantyCase.Approval_Status__c = 'Denied';
                }
                
                //AAB 01/07/2015 - Default to Warranty Case values if response is null.
                warrantyCase.Vehicle_Mileage__c = (oResponse.Miles!=null && oResponse.Miles!='') ? Double.valueOf(oResponse.Miles): warrantyCase.Vehicle_Mileage__c;
                
                List<Master_Recall_Campaign__c> campaigns = [select Id, Name from Master_Recall_Campaign__c where Name=:oResponse.PFPPO];
                warrantyCase.Primary_Failed_Part__c = (oResponse.PFPPO!=null && oResponse.PFPPO!='' && (campaigns==null || campaigns.size()==0)) ? oResponse.PFPPO : warrantyCase.Primary_Failed_Part__c;
                warrantyCase.Vehicle_Campaign1__c = (campaigns!=null && campaigns.size()>0) ? campaigns[0].Id : warrantyCase.Vehicle_Campaign1__c;
                warrantyCase.Normal_Approval__c = (oResponse.NormalApproval!=null && oResponse.NormalApproval!='') ? oResponse.NormalApproval : warrantyCase.Normal_Approval__c;
                warrantyCase.Repeat_Repair_Review__c = (oResponse.RepairReview!=null && oResponse.RepairReview!='') ? oResponse.RepairReview : warrantyCase.Repeat_Repair_Review__c;
                warrantyCase.Mileage__c = (oResponse.MileageProgressReview!=null && oResponse.MileageProgressReview!='') ? oResponse.MileageProgressReview : warrantyCase.Mileage__c;
                warrantyCase.Duplicate_Campaign_Different_Dealer__c = (oResponse.CampaignDiffDealer!=null && oResponse.CampaignDiffDealer!='') ? oResponse.CampaignDiffDealer : warrantyCase.Duplicate_Campaign_Different_Dealer__c;
                warrantyCase.Goodwill_Approval__c = (oResponse.GoodwillApproval!=null && oResponse.GoodwillApproval!='') ? oResponse.GoodwillApproval : warrantyCase.Goodwill_Approval__c;
                    
                warrantyCase.Requestor_s_Name__c= (oResponse.CallerName!=null && oResponse.CallerName!='') ? toTitleCase(oResponse.CallerName): warrantyCase.Requestor_s_Name__c;
                warrantyCase.Requestor_s_Phone_Number__c = (oResponse.CallerPhone!=null && oResponse.CallerPhone!='') ? oResponse.CallerPhone : warrantyCase.Requestor_s_Phone_Number__c;
                warrantyCase.Customer_Name__c = (oResponse.CustomerName!=null && oResponse.CustomerName!='') ? toTitleCase(oResponse.CustomerName): warrantyCase.Customer_Name__c;
                System.debug('oResponse.Parts::'+oResponse.Parts+'--warrantyCase.CreatedDate.getTime()--'+warrantyCase.CreatedDate.getTime()+'--Datetime.now().getTime()---'+Datetime.now().getTime());
                if(Datetime.now().getTime() - warrantyCase.CreatedDate.getTime() <= 35000 && (oResponse.Parts !=null && oResponse.Parts!='' && warrantyCase.Parts__c != null && warrantyCase.Parts__c != Double.valueOf(oResponse.Parts) 
                	|| (oResponse.LBR !=null && oResponse.LBR!='' && warrantyCase.Labor__c != null && warrantyCase.Labor__c != Double.valueOf(oResponse.LBR)) 
                	|| (oResponse.Expense !=null && oResponse.Expense!='' && warrantyCase.Expenses__c != null && warrantyCase.Expenses__c != Double.valueOf(oResponse.Expense)))){
                		makeUpdateCallout = true;
                }else{
	                warrantyCase.Parts__c = (oResponse.Parts !=null && oResponse.Parts!='') ? Double.valueOf(oResponse.Parts) : warrantyCase.Parts__c;
	                warrantyCase.Labor__c = (oResponse.LBR !=null && oResponse.LBR!='') ? Double.valueOf(oResponse.LBR) : warrantyCase.Labor__c;
	                warrantyCase.Expenses__c = (oResponse.Expense !=null && oResponse.Expense!='') ? Double.valueOf(oResponse.Expense) : warrantyCase.Expenses__c;
                }
                if(oResponse.PartsAtCost=='Y')
                {
                    warrantyCase.Parts_at_Cost__c = 'Yes';
                }
                else
                {
                    warrantyCase.Parts_at_Cost__c = 'No';
                }
                              
                if(oResponse.ForceGoodwill=='Y')
                {
                    warrantyCase.Force_Goodwill_Coverage__c = 'Yes';
                }
                else
                {
                    warrantyCase.Force_Goodwill_Coverage__c = 'No';
                }
            }
            warrantyCase.Host_Comments__c = oResponse.ApprovalComments;   
            HostComments = oResponse.ApprovalComments;
            ApprovalStatus = warrantyCase.Approval_Status__c;
            HostErrorMessage = 'Updated with VCAN Info: ' + oResponse.VCANRefNumber;
            showErrorMessage = true;
            if(makeUpdateCallout){
            	System.debug('warrantyCase.Approval_Information__c:::'+warrantyCase.Approval_Information__c);
            	if(VCAN_Password!=null && VCAN_Password.length() > 0){
	             	oResponse = updateVCANcallout(oResponse, warrantyCase);
	             	 if(oResponse == null){
		           	   return null;
		             }
		             else{
		             	didUpdate = true;
		             	warrantyCase.Approval_Information__c = '';
		             }
            	}
            }
            
            if(didUpdate==false)
            {
                errorColor = 'color: black';
                errorMessage = 'Updated with VCAN Info: ' + oResponse.VCANRefNumber;  
            }
            warrantyCase.isSystemUpdate__c = true;
            if(hasWriteAccess)
            {
            	update warrantyCase;
            }
            else
            {
                doUpdate = false;
            }
            
            if(doUpdate==true)
            {
                String now = String.ValueOf(system.now());
                String userString = ZCA_Id + ', ' + CaseName + ', ' + now;
                HostComments = buildOutputComments(updateComments, HostComments, userString);
                futureUpdateVCAN(warrantyCase.Id);
                //warrantyCase.Approval_Information__c = '';
            }
        }
        else if(oResponse.message==VCAN_Password_Error || oResponse.message==VCAN_Account_Locked_Error)
        {
            errorMessage = oResponse.message;
            showErrorMessage = true;
        }
        
        return null;
    }
    
    private VCANJSONResponse updateVCANcallout(VCANJSONResponse oResponse, Warranty_Case__c warrantyCase){
    	    oResponse = updateWarrantyCaseVCAN(warrantyCase.Id);
            showErrorMessage = true;
            
            if(oResponse.success == false || oResponse.message == null || !vCanSet.contains(oResponse.message.substring(0,3)))
            {
                if(oResponse.message == null)
                {
                    warrantyCase.HOST_Error_Message__c = 'Update VCAN Failed, unexpected HOST Error, no Response Returned';
                    errorMessage = warrantyCase.HOST_Error_Message__c;
                	update warrantyCase;
                	errorColor = 'color: red';
                	return null;
                }
                
                Integer errorLength = oResponse.message.length();
                if(errorLength>255)
                {
                    warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
                }
                else
                {
                    warrantyCase.HOST_Error_Message__c = oResponse.message;
                }
                errorMessage = oResponse.message;
                update warrantyCase;
                errorColor = 'color: red';
                return null;
            }
            else
            {
                Integer errorLength = oResponse.message.length();
                if(errorLength>255)
                {
                    warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
                }
                else
                {
                    warrantyCase.HOST_Error_Message__c = oResponse.message;
                }
                
                LastModifiedByName = System.UserInfo.getName() + ', ' + datetime.now().format('MM/dd/yyyy HH:mm a');
                
                if(warrantyCase.isApprovalStatusChanged__c && warrantyCase.Total_Amount_Approved__c>approvalLimit)
                {
                    errorColor = 'color: black';
                    errorMessage = 'The total approval amount ' + warrantyCase.Total_Amount_Approved__c + ' exceeds your approval limit ' + approvalLimit + ' the VCAN has been set to an approval status of pending';
                }
                else
                {
                    errorColor = 'color: black';
                    errorMessage = 'Updated with VCAN Info: ' + warrantyCase.HOST_Reference_Number__c;  
                }
                
                String now = String.ValueOf(system.now());
                if(warrantyCase.Internal_Comments__c== null){
                    warrantyCase.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>' + warrantyCase.Approval_Information__c;
                }
                else{
                    warrantyCase.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+warrantyCase.Approval_Information__c;
                }
                                
                warrantyCase.isVCANUpdate__c = false;
                
                //update warrantyCase;   
                hasVCAN = true;
                VCANComment = '';                
                return oResponse;
            }
    }
    
    private static String buildOutputComments(String comments, String oldComments, String userString)
    {
        oldComments += '<br/>' + userString;        
        
        String tmpVCANComment = comments;
        String remainingChars = comments;        
        String OutputComments = oldComments;
        Integer commentLength = tmpVCANComment != null ? tmpVCANComment.length() : 0;
        
        while(remainingChars != null && remainingChars.length()>0)
        {
            if(remainingChars.length()>60)
            {
                OutputComments += '<br/>' + remainingChars.substring(0,60);
                remainingChars = remainingChars.substring(60);
            }
            else
            {
                OutputComments += '<br/>' + remainingChars;
                remainingChars = '';
            }
        }    
        
        OutputComments = OutputComments.toUpperCase();
        
        return OutputComments;
    }
    
    @future(callout=true)
    private static void futureUpdateVCAN(Id warrantyId)
    {	
    	Set<String> vCanSet = new Set<String>();
        Warranty_Case__c warrantyCase = [select ID, Approval_Information__c, HOST_Error_Message__c, Internal_Comments__c from Warranty_Case__c where Id=:warrantyId];  
        ApexPages.StandardController sc = new ApexPages.StandardController(warrantyCase);
        VCANComponent vc = new VCANComponent(sc);
        
        String[] vCanCodes = Label.VCANErrorMessageCodes.split(';');
        for(String s : vCanCodes){
        	vCanSet.add(s);
        }
        
        VCANJSONResponse oResponse = vc.updateWarrantyCaseVCAN(warrantyCase.Id);
        if(oResponse.success == false || oResponse.message==null || !vCanSet.contains(oResponse.message.substring(0,3)))
        {
            if(oResponse.message == null)
            {
                warrantyCase.HOST_Error_Message__c = 'Update VCAN Failed, unexpected HOST Error, no Response Returned';
                warrantyCase.isSystemUpdate__c = true;
                update warrantyCase;
                return;
            }
            
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            warrantyCase.isSystemUpdate__c = true;
            update warrantyCase;
        }
        else
        {
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            
            String now = String.ValueOf(system.now());
            if(warrantyCase.Internal_Comments__c== null){
                warrantyCase.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>' + warrantyCase.Approval_Information__c;
            }
            else{
                warrantyCase.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+warrantyCase.Approval_Information__c;
            }
            
            warrantyCase.Approval_Information__c = '';
            warrantyCase.isSystemUpdate__c = true;
            update warrantyCase; 
        }
    }
    
    public VCANJSONResponse checkWarrantyCaseVCAN(String warrantyId ) 
    {
        VCANJSONResponse oResponse = new VCANJSONResponse();
        
        Warranty_Case__c wc = [select ID, Dealer_Code__c, Vehicle__r.Name, Repair_Work_Order__c, 
                               Job_Line_Number__c, Customer_Concern__c,
                               Repair_Work_Order_Open_Date__c,
                               Vehicle_Mileage__c,
                               Primary_Failed_Part__c,
                               Requestor_s_Name__c,
                               Customer_Name__c,
                               Parts_at_Cost__c,
                               Force_Goodwill_Coverage__c,
                               Parts__c,
                               Labor__c,
                               Expenses__c,
                               Total_Amount_Approved__c,
                               Requestor_s_Phone_Number__c,
                               Approval_Status__c,
                               Normal_Approval__c,
                               Repeat_Repair_Review__c,
                               Mileage__c,
                               Duplicate_Campaign_Different_Dealer__c,
                               Goodwill_Approval__c,
                               Vehicle_Campaign1__c,
                               Vehicle_Campaign1__r.Name,
                               Approval_Information__c
                               from Warranty_Case__c where Id=:warrantyId];     
        if(wc == null)
        {
            oResponse.message = 'Failed - no warranty case found';
            oResponse.success = false;
            
            return oResponse;
        }
        
        Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort service = new Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort();
        service.inputHttpHeaders_x=new Map<String,String>();
        service.timeout_x = 120000;
        Blob headerValue = Blob.valueOf(authKey);  //X987147   -90NissanT
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        String tmplistVins;
        if(wc.Vehicle__r !=null && wc.Vehicle__r.Name!='')
        {
            tmplistVins = wc.Vehicle__r.Name;
            if(tmplistVins.indexOf(' ')!=11 && addSpace==true)
            {
                tmplistVins = tmplistVins.substring(0,11) + ' ' + tmplistVins.substring(11);
            }
        }
        else
        {
            oResponse.message = 'You must associate a vehicle with this warranty case.';
            oResponse.success = false;
            
            return oResponse;
        }
        String tmpWONumber = wc.Repair_Work_Order__c;
        String tmpWOLine = wc.Job_Line_Number__c;
        String tmpServiceFacility = wc.Dealer_Code__c;
        Nna360VCAN2MasterServiceSoap.viewVCANResp response;
        
        String username = VCAN_Service_User; //'DWH001L';
        
        Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(username));
        username = EncodingUtil.base64Encode(cipherText); 
        String password = VCAN_Service_Password; //'NISSAN22';
        cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(password));
        password = EncodingUtil.base64Encode(cipherText);         
        
        if(disableLogins || Test.isRunningTest())
        {
            oResponse.message = Label.VCAN_Maintenance_Message;
            oResponse.success = false;
            
            return oResponse;
        }
        
        response = service.viewVCAN(tmplistVINs,tmpWONumber,tmpWOLine,tmpServiceFacility, username, password);
        if(response != null)
        {
            Nna360VCAN2MasterServiceSoap.VCANDetails details = response.viewVCANResp.vcanDetails;
                        
            if(details!=null)
            {
                oResponse.VCANRefNumber=details.VCANRefNumber;
                oResponse.AffiliateCode=details.AffiliateCode;               
                oResponse.WONumber=details.WONumber;
                oResponse.WOLine=details.WOLine;
                oResponse.ServiceFacility=details.ServiceFacility;                
                oResponse.VIN=details.VIN;                
                oResponse.WOOpenDate=details.WOOpenDate;                
                oResponse.Miles=details.Miles;
                oResponse.PFPPO=details.PFPPO;
                oResponse.CallerName=details.CallerName;
                oResponse.CallerPhone=details.CallerPhone;
                oResponse.CallerExt=details.CallerExt;
                oResponse.CustomerName=details.CustomerName;
                oResponse.PartsAtCost=details.PartsAtCost;                
                oResponse.ForceGoodwill=details.ForceGoodwill;
                oResponse.ApprovalStatus=details.ApprovalStatus;
                oResponse.ApprId=details.ApprId;
                oResponse.ApprByName=details.ApprId;
                if(oResponse.ApprId!=null && oResponse.ApprId!='')
                {
                    List<User> approvers = [Select Name from user where ZCA_Id__c=:oResponse.ApprId];
                    if(approvers!=null && approvers.size()>0)
                    {
                        oResponse.ApprByName = approvers[0].Name;
                    }
                }
                oResponse.ApprDate=details.ApprDate;
                oResponse.EnteredByUserId=details.EnteredByUserId;
                oResponse.EnteredDate=details.EnteredDate;
                oResponse.ChangedByUserId=details.ChangedByUserId;
                oResponse.ChangedByName=details.ChangedByUserId;
                if(oResponse.ChangedByUserId!=null && oResponse.ChangedByUserId!='')
                {
                    List<User> updaters = [Select Name from user where ZCA_Id__c=:oResponse.ChangedByUserId];
                    if(updaters!=null && updaters.size()>0)
                    {
                        oResponse.ChangedByName = updaters[0].Name;
                    }
                }
                oResponse.ChangedDate=details.ChangedDate;
                oResponse.LanId=details.LanId;    
                
                Nna360VCAN2MasterServiceSoap.ApprovalAmounts apAmounts = details.ApprovalAmounts;
                System.debug('apAmounts:::'+apAmounts);
                if(apAmounts != null)
                {
                    oResponse.Parts = apAmounts.Parts;
                    oResponse.LBR = apAmounts.LBR;
                    oResponse.Expense = apAmounts.Expense;
                    oResponse.Total = apAmounts.Total;
                }
                
                Nna360VCAN2MasterServiceSoap.ActApprovalCondition actCond = details.ActApprovalCondition;
                if(actCond != null)
                {
                    oResponse.NormalApproval = actCond.NormalApproval;
        			oResponse.RepairReview = actCond.RepairReview;
        			oResponse.MileageProgressReview = actCond.MileageProgressReview;
        			oResponse.CampaignDiffDealer = actCond.CampaignDiffDealer;
        			oResponse.GoodwillApproval = actCond.GoodwillApproval;
                }
                
                List<String> comments = new List<String>(details.ApprovalComments);
                String commentString = '';
                if(!comments.isEmpty())
                {
                    //parse out date and updatedby
                    //[comments in line] 080114 DWH001L
                    string tmpComment = comments[0];
                    
                    if(parseVCANUsername==true)
                    {
                        if(tmpComment.lastIndexOf(' ')>0)
                        {
                            tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                        }   
                        if(tmpComment.lastIndexOf(' ')>0)
                        {
                            tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                        }   
                    }
                    
                    commentString = tmpComment;
                    
                    
                    comments.remove(0);
                    while(!comments.isEmpty())
                    {
                        tmpComment = comments[0];
                        if(parseVCANUsername==true)
                        {
                            if(tmpComment.lastIndexOf(' ')>0)
                            {
                                tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                            }   
                            if(tmpComment.lastIndexOf(' ')>0)
                            {
                                tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                            }   
                        }
                        commentString += '<br/>' + tmpComment;
                        comments.remove(0);
                    }
                }                
                oResponse.ApprovalComments=commentString;
                
                oResponse.message = details.message;
                oResponse.success = true;
                
                return oResponse;
            }
            else
            {
                Nna360VCAN2MasterServiceSoap.viewVCAN_Output errorOutput = (Nna360VCAN2MasterServiceSoap.viewVCAN_Output) response.viewVCANResp;
                if(errorOutput != null)
                {
                    if(errorOutput.MessageDescription != null)
                    {
                        String errorMsg = errorOutput.MessageDescription;
                        if(errorMsg.indexOf(VCAN_Password_Error_String)>-1)
                        {
                            oResponse.message = VCAN_Password_Error;
                            oResponse.success = false;
                            
                            return oResponse;
                        }
                        else if(errorMsg.indexOf(VCAN_Account_Locked_Error_String)>-1)
                        {
                            oResponse.message = VCAN_Account_Locked_Error;
                            oResponse.success = false;
                            
                            return oResponse;
                        }
                        else
                        {
                            oResponse.message = errorMsg;
                            oResponse.success = false;
                            
                            return oResponse;
                        }
                    }
                    else
                    {
                        oResponse.message = 'Unexpected Error';
                        oResponse.success = false;
                        
                        return oResponse;
                    }
                }
                else
                {
                    oResponse.message = 'Unexpected Error';
                    oResponse.success = false;
                    
                    return oResponse;
                }
            }              
        }        
        else
        {
            oResponse.message = 'Unexpected Error';
            oResponse.success = false;
            
            return oResponse;
        }        
    }
    
    public PageReference createVCAN()
    {
        if(warrantyCase.Approval_Information__c==null)
        {
            errorMessage = 'You must provide comments about this VCAN before you can create a VCAN.';
            errorColor = 'color: red';
            showErrorMessage = true;
            return null;
        }
        
        showProgress = true;
        VCANJSONResponse oResponse = createWarrantyCaseVCAN(warrantyCase.Id);
        showErrorMessage = true;
        errorMessage = oResponse.message;
        showProgress = false;
        
        if(oResponse.success == false || oResponse.message==null || oResponse.message.length()<3 || oResponse.message.substring(0,3)!='308')
        {
            if(oResponse.message == null)
            {
                warrantyCase.HOST_Error_Message__c = 'Create VCAN Failed, unexpected HOST Error, no Response Returned';
                errorMessage = warrantyCase.HOST_Error_Message__c;
                warrantyCase.isSystemUpdate__c = true;
                update warrantyCase;
                errorColor = 'color: red';
                return null;
            }
            
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            errorMessage = oResponse.message;
            errorColor = 'color: red';    
            update warrantyCase;  
            return null;
        }
        else
        {
            String vCanRefNumber = oResponse.message;
            Integer errorLength = vCanRefNumber.length();
            vCanRefNumber = vCanRefNumber.substring(errorLength-14);
            warrantyCase.HOST_Reference_Number__c = vCanRefNumber;
            warrantyCase.HOST_Error_Message__c = oResponse.message;
            HostErrorMessage = oResponse.message;
            warrantyCase.Host_Comments__c = oResponse.ApprovalComments;
            HostComments = oResponse.ApprovalComments;
            LastModifiedByName = System.UserInfo.getName() + ', ' + datetime.now().format('MM/dd/yyyy HH:mm a');
            
            errorMessage = 'VCAN Created successfully, VCAN Ref#: ' + warrantyCase.HOST_Reference_Number__c;
            //AAB Set the page values
            HostReferenceNumber = warrantyCase.HOST_Reference_Number__c;
            canCreate = false;
            if(canDelete == true)
            {
                showDelete = true;
            }
            
            if(warrantyCase.Total_Amount_Approved__c>approvalLimit)
            {
                errorMessage = 'The total approval amount ' + warrantyCase.Total_Amount_Approved__c + ' exceeds your approval limit ' + approvalLimit + ' the VCAN Ref#: ' + warrantyCase.HOST_Reference_Number__c + ' has been created with an approval status of pending';
                ApprovalStatus = 'Pending';
                warrantyCase.Approval_Status__c = 'Pending';
            }
            else
            {
                ApprovalStatus = warrantyCase.Approval_Status__c;
            }
            
            String now = String.ValueOf(system.now());
            if(warrantyCase.Internal_Comments__c== null){
                warrantyCase.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>' + warrantyCase.Approval_Information__c;
            }
            else{
                warrantyCase.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+warrantyCase.Approval_Information__c;
            }        
            
            warrantyCase.Approval_Information__c = '';
            warrantyCase.isSystemUpdate__c = true;
            update warrantyCase;    
            hasVCAN = true;
        }
        return null;
    }
    
    public VCANJSONResponse createWarrantyCaseVCAN(String warrantyId) 
    {
        VCANJSONResponse oResponse = new VCANJSONResponse();
        
        Warranty_Case__c wc = getWarrantyCase(warrantyId);        
        
        Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort service = new Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort();
        service.inputHttpHeaders_x=new Map<String,String>();
        service.timeout_x = 120000;
        Blob headerValue = Blob.valueOf(authKey);  //  -X987147 -90NissanT
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        
        Nna360VCAN2MasterServiceSoap.createVCANResp response;
        Nna360VCAN2MasterServiceSoap.VCANDetails details = new Nna360VCAN2MasterServiceSoap.VCANDetails();
        Nna360VCAN2MasterServiceSoap.ApprovalAmounts apamounts = new Nna360VCAN2MasterServiceSoap.ApprovalAmounts();
        Nna360VCAN2MasterServiceSoap.ActApprovalCondition actCond = new Nna360VCAN2MasterServiceSoap.ActApprovalCondition();
        
        if(wc.Repair_Work_Order__c==null)
        {
            oResponse.message = '"Repair/Work Order" is required please enter a work order.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        details.WONumber = wc.Repair_Work_Order__c; //'74731';//
        
        if(wc.Job_Line_Number__c==null)
        {
            oResponse.message = '"Job/Line Number" is required please enter a line number.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        details.WOLine = wc.Job_Line_Number__c; //'ABC';//
        
        
        if(wc.Vehicle__c==null)
        {
            oResponse.message = '"Vehicle" is required please select a vehicle.';
            oResponse.success = false;
            
            return oResponse;
        }    
        
        details.VIN= wc.Vehicle__r.Name; //'JNKAJ09E78M 306003';//
        
        if(details.VIN.indexOf(' ')!=11 && addSpace==true)
        {
            details.VIN = details.VIN.substring(0,11) + ' ' + details.VIN.substring(11);
        }
        
        if(wc.Dealer_Code__c==null)
        {
            oResponse.message = '"Dealer Code" is required please select a dealer.';
            oResponse.success = false;
            
            return oResponse;
        } 
        
        details.ServiceFacility = wc.Dealer_Code__c;//'73319';//
        if(wc.Repair_Work_Order_Open_Date__c==null)
        {
            oResponse.message = '"Repair/Work Order Open Date" is required please enter a work order date.';
            oResponse.success = false;
            
            return oResponse;
        }
        Date woOpenDate = wc.Repair_Work_Order_Open_Date__c;        
        DateTime woOpenDateTime = DateTime.newInstance(woOpenDate.year(), woOpenDate.month(), woOpenDate.day());
        details.WOOpenDate = woOpenDateTime.format('MM/dd/yy');
        if(wc.Vehicle_Mileage__c==null || '' + wc.Vehicle_Mileage__c=='')
        {
            oResponse.message = '"Vehicle Mileage" is required please enter vehicle mileage.';
            oResponse.success = false;
            
            return oResponse;
        }
        details.Miles= '' + wc.Vehicle_Mileage__c;
        
        if(wc.Primary_Failed_Part__c==null && wc.Vehicle_Campaign1__c==null)
        {
            oResponse.message = '"Primary Failed Part" or "Vehicle Campaign" is required please enter a primary failed part or vehicle campaign.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        if(wc.Vehicle_Campaign1__c==null)
        {
            details.PFPPO= wc.Primary_Failed_Part__c;
        }
        else
        {
            details.PFPPO= wc.Vehicle_Campaign1__r.Name;
        }
        
        details.CallerName = wc.Requestor_s_Name__c;
        if(wc.Customer_Name__c == null)
        {            
            oResponse.message = '"Customer" is required please select a customer.';
            oResponse.success = false;
            
            return oResponse;
        }
        details.CustomerName= wc.Customer_Name__c;
        if(wc.Parts_at_Cost__c== 'Yes')
        {
            details.PartsAtCost= 'Y';
        }
        else
        {
            details.PartsAtCost= 'N';
        }
        
        //AAB - Approval Stuff
        if(wc.Normal_Approval__c!=null)
        {
            actCond.NormalApproval = wc.Normal_Approval__c.substring(0,1);
        }
        if(wc.Repeat_Repair_Review__c!=null)
        {
            actCond.RepairReview = wc.Repeat_Repair_Review__c.substring(0,1);
        }
        
        if(wc.Mileage__c!=null)
        {
            actCond.MileageProgressReview = wc.Mileage__c.substring(0,1);
        }
        if(wc.Duplicate_Campaign_Different_Dealer__c!=null)
        {
            actCond.CampaignDiffDealer = wc.Duplicate_Campaign_Different_Dealer__c.substring(0,1);
        }
        if(wc.Goodwill_Approval__c!=null)
        {
            actCond.GoodwillApproval = wc.Goodwill_Approval__c.substring(0,1);
        }
        
        details.ActApprovalCondition = actCond;
        
        apamounts.Parts = wc.Parts__c==null ? '0' : '' + wc.Parts__c;
        apamounts.LBR = wc.Labor__c==null ? '0' : '' + wc.Labor__c;
        apamounts.Expense = wc.Expenses__c==null ? '0' : '' + wc.Expenses__c;
        apamounts.Total = wc.Total_Amount_Approved__c==null? '0' : '' + wc.Total_Amount_Approved__c;
        
        details.ApprovalAmounts = apamounts;
       if(wc.Force_Goodwill_Coverage__c== 'Yes')
        {
            details.ForceGoodwill= 'Y';
        }
        else
        {
            details.ForceGoodwill= 'N';
        }
        
        details.CallerPhone= formatPhoneNumber(wc.Requestor_s_Phone_Number__c);
        //details.CallerExt= '1234';//paramCallerExt;
        
        List<String> commentsstuff = new List<String>();
        //AAB 8/1/2014 - Adding in a USer/Timestamp
        String now = String.ValueOf(system.now());
        commentsstuff.add(ZCA_Id + ', ' + CaseName + ', ' + now);
        oResponse.ApprovalComments = ZCA_Id + ', ' + CaseName + ', ' + now;
        
        if(wc.Approval_Information__c==null)
        {
            wc.Approval_Information__c = '';
        }
        
        String tmpVCANComment = wc.Approval_Information__c;
        String remainingChars = wc.Approval_Information__c;        
        
        Integer commentLength = tmpVCANComment.length();
        if(commentLength>240)
        {
            oResponse.message = 'Comments exceed the maximum length, using ' + commentLength + ' of 240 characters';
            oResponse.success = false;
            return oResponse;            
        }
        while(remainingChars.length()>0)
        {
            if(remainingChars.length()>60)
            {
                commentsstuff.add(remainingChars.substring(0,60));
                oResponse.ApprovalComments += '<br/>' + remainingChars.substring(0,60);
                remainingChars = remainingChars.substring(60);
            }
            else
            {
                commentsstuff.add(remainingChars);
                oResponse.ApprovalComments += '<br/>' + remainingChars;
                remainingChars = '';
            }
        }    
        
        oResponse.ApprovalComments = oResponse.ApprovalComments.toUpperCase();
        
        details.ApprovalComments = commentsstuff;
        
        if(wc.Approval_Status__c!= null)
        {
            details.ApprovalStatus = wc.Approval_Status__c.substring(0,1);
        }
        else
        {
            details.ApprovalStatus = 'P';
        }
        
        if(wc.Total_Amount_Approved__c>approvalLimit)
        {
            details.ApprovalStatus = 'P';
        }
        Nna360VCAN2MasterServiceSoap.createVCAN_Output respOutput;
        
        String username;
        String password;
        
        if(ZCA_Id==null || ZCA_Id.length()<1)
        {
            oResponse.message = 'ZCA_Id missing';
            oResponse.success = false;
            return oResponse;
        }
        
        if(VCAN_Password== null || VCAN_Password.length()<1)
        {
            oResponse.message = 'Please update your host password in setup. You must provide your host password each time it changes.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        String clearText = ZCA_Id;//DWH001L
        Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
        username = EncodingUtil.base64Encode(cipherText); 
        //AAB Password is already encrypted
        /*clearText = 'NISSAN22';
cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
password = EncodingUtil.base64Encode(cipherText); 
*/
        password = VCAN_Password;       
        
        if(disableLogins || Test.isRunningTest())
        {
            oResponse.message = Label.VCAN_Maintenance_Message;
            oResponse.success = false;
            
            return oResponse;
        }
        
        response = service.createVCAN(details, username, password);
        System.debug('response:::'+response);
        respOutput = response.createVCANResp;
        
        String respMSG = respOutput.MessageDescription;
        String respCode = respOutput.MessageCode;
        String respVCANNum = respOutput.VCANRefNumber;
        
        oResponse.message = respMSG;
        oResponse.success = true;
        
        if(respMSG!=null)
        {
            String errorMsg = respMSG;
            if(errorMsg.indexOf(VCAN_Password_Error_String)>-1)
            {
                oResponse.message = VCAN_Password_Error;
                oResponse.success = false;
            }
            else if(errorMsg.indexOf(VCAN_Account_Locked_Error_String)>-1)
            {
                oResponse.message = VCAN_Account_Locked_Error;
                oResponse.success = false;
            }
            else
            {
                oResponse.message = errorMsg;
            }
        }
        
        System.debug('createWarrantyCaseVCAN:::'+oResponse);
        
        return oResponse;
    }
    
    public PageReference updateVCAN()
    {
        showProgress = true;
        VCANJSONResponse oResponse = updateWarrantyCaseVCAN(warrantyCase.Id);
        showErrorMessage = true;
        hasVCAN = true;
        showProgress = false;
        
        System.debug('oResponse2:::'+oResponse);
        
        if(oResponse.success == false || oResponse.message==null || oResponse.message.length()<3 || oResponse.message.substring(0,3)!='308')
        {
            if(oResponse.message == null)
            {
                warrantyCase.HOST_Error_Message__c = 'Update VCAN Failed, unexpected HOST Error, no Response Returned';
                errorMessage = warrantyCase.HOST_Error_Message__c;
                warrantyCase.isSystemUpdate__c = true;
                update warrantyCase;
                errorColor = 'color: red';
                return null;
            }
            
            Integer errorLength = oResponse.message.length();
            //No Alert of error due to system not having ZCA_ID
            if(oResponse.message=='ZCA_Id missing')
            {
                return null;                
            }
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            errorMessage = oResponse.message;
            update warrantyCase;
            errorColor = 'color: red';
            return null;
        }
        else
        {
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            
            LastModifiedByName = System.UserInfo.getName() + ', ' + datetime.now().format('MM/dd/yyyy HH:mm a');
            
            errorMessage = 'VCAN updated successfully';
            
            String now = String.ValueOf(system.now());
            if(warrantyCase.Internal_Comments__c== null){
                warrantyCase.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>' + warrantyCase.Approval_Information__c;
            }
            else{
                warrantyCase.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+warrantyCase.Approval_Information__c;
            }
            warrantyCase.Approval_Information__c = '';
            warrantyCase.isSystemUpdate__c = true;
            update warrantyCase;   
            hasVCAN = true;
        }
        return null;
    }
    
    public VCANJSONResponse updateWarrantyCaseVCAN(String warrantyId ) 
    {
        VCANJSONResponse oResponse = new VCANJSONResponse();
        
        Warranty_Case__c wc = getWarrantyCase(warrantyId);       
        
        Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort service = new Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort();
        service.inputHttpHeaders_x=new Map<String,String>();
        service.timeout_x = 120000;
        Blob headerValue = Blob.valueOf(authKey);  //  -X987147 -90NissanT
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        
        Nna360VCAN2MasterServiceSoap.updateVCANResp response;
        Nna360VCAN2MasterServiceSoap.VCANDetails details = new Nna360VCAN2MasterServiceSoap.VCANDetails();
        Nna360VCAN2MasterServiceSoap.ApprovalAmounts apamounts = new Nna360VCAN2MasterServiceSoap.ApprovalAmounts();
        Nna360VCAN2MasterServiceSoap.ActApprovalCondition actCond = new Nna360VCAN2MasterServiceSoap.ActApprovalCondition();
        
        if(wc.Repair_Work_Order__c==null)
        {
            oResponse.message = '"Repair/Work Order" is required please enter a work order.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        details.WONumber = wc.Repair_Work_Order__c; //'74731';//
        
        if(wc.Job_Line_Number__c==null)
        {
            oResponse.message = '"Job/Line Number" is required please enter a line number.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        details.WOLine = wc.Job_Line_Number__c; //'ABC';//
        
        
        if(wc.Vehicle__c==null)
        {
            oResponse.message = '"Vehicle" is required please select a vehicle.';
            oResponse.success = false;
            
            return oResponse;
        }    
        
        details.VIN= wc.Vehicle__r.Name; //'JNKAJ09E78M 306003';//
        
        if(details.VIN.indexOf(' ')!=11 && addSpace==true)
        {
            details.VIN = details.VIN.substring(0,11) + ' ' + details.VIN.substring(11);
        }
        
        if(wc.Dealer_Code__c==null)
        {
            oResponse.message = '"Dealer Code" is required please select a dealer.';
            oResponse.success = false;
            
            return oResponse;
        } 
        
        details.ServiceFacility = wc.Dealer_Code__c;//'73319';//
        if(wc.Repair_Work_Order_Open_Date__c==null)
        {
            oResponse.message = '"Repair/Work Order Open Date" is required please enter a work order date.';
            oResponse.success = false;
            
            return oResponse;
        }
        Date woOpenDate = wc.Repair_Work_Order_Open_Date__c;        
        DateTime woOpenDateTime = DateTime.newInstance(woOpenDate.year(), woOpenDate.month(), woOpenDate.day());
        details.WOOpenDate = woOpenDateTime.format('MM/dd/yy');
        
        if(wc.Vehicle_Mileage__c ==null || '' + wc.Vehicle_Mileage__c=='')
        {
            oResponse.message = '"Vehicle Mileage" is required please enter vehicle mileage.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        details.Miles= '' + wc.Vehicle_Mileage__c;
        
        if(wc.Primary_Failed_Part__c==null && wc.Vehicle_Campaign1__c==null)
        {
            oResponse.message = '"Primary Failed Part" or "Vehicle Campaign" is required please enter a primary failed part or vehicle campaign.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        if(wc.Vehicle_Campaign1__c==null)
        {
            details.PFPPO= wc.Primary_Failed_Part__c;
        }
        else
        {
            details.PFPPO= wc.Vehicle_Campaign1__r.Name;
        }
        
        details.CallerName = wc.Requestor_s_Name__c;
        if(wc.Customer_Name__c == null)
        {            
            oResponse.message = '"Customer" is required please select a customer.';
            oResponse.success = false;
            
            return oResponse;
        }
        details.CustomerName= wc.Customer_Name__c;
        if(wc.Parts_at_Cost__c== 'Yes')
        {
            details.PartsAtCost= 'Y';
        }
        else
        {
            details.PartsAtCost= 'N';
        }
        
        //AAB - Approval Stuff
        if(wc.Normal_Approval__c!=null)
        {
            actCond.NormalApproval = wc.Normal_Approval__c.substring(0,1);
        }
        if(wc.Repeat_Repair_Review__c!=null)
        {
            actCond.RepairReview = wc.Repeat_Repair_Review__c.substring(0,1);
        }
        
        if(wc.Mileage__c!=null)
        {
            actCond.MileageProgressReview = wc.Mileage__c.substring(0,1);
        }
        if(wc.Duplicate_Campaign_Different_Dealer__c!=null)
        {
            actCond.CampaignDiffDealer = wc.Duplicate_Campaign_Different_Dealer__c.substring(0,1);
        }
        if(wc.Goodwill_Approval__c!=null)
        {
            actCond.GoodwillApproval = wc.Goodwill_Approval__c.substring(0,1);
        }
        
        details.ActApprovalCondition = actCond;
        
        System.debug('wc.Parts__c:::'+wc.Parts__c+'---wc.Labor__c'+wc.Labor__c);
        apamounts.Parts = wc.Parts__c==null ? '0' : '' + wc.Parts__c;
        apamounts.LBR = wc.Labor__c==null ? '0' : '' + wc.Labor__c;
        apamounts.Expense = wc.Expenses__c==null ? '0' : '' + wc.Expenses__c;
        apamounts.Total = wc.Total_Amount_Approved__c==null? '0' : '' + wc.Total_Amount_Approved__c;        
        
        details.ApprovalAmounts = apamounts;
        if(wc.Force_Goodwill_Coverage__c== 'Yes')
        {
            details.ForceGoodwill= 'Y';
        }
        else
        {
            details.ForceGoodwill= 'N';
        }
        
        details.CallerPhone= formatPhoneNumber(wc.Requestor_s_Phone_Number__c);
        //details.CallerExt= '1234';//paramCallerExt;
        
        List<String> commentsstuff = new List<String>();         
        //AAB 8/1/2014 - Adding in a USer/Timestamp
        String now = String.ValueOf(system.now());
        commentsstuff.add(ZCA_Id + ', ' + CaseName + ', ' + now);
        String tmpVCANComment = wc.Approval_Information__c;
        String remainingChars = wc.Approval_Information__c;
        
        Integer commentLength = tmpVCANComment != null ? tmpVCANComment.length() : 0;
        if(commentLength>720)
        {
            oResponse.message = 'Comments exceed the maximum length, using ' + commentLength + ' of 720 characters';
            oResponse.success = false;
            return oResponse;            
        }
        while(remainingChars !=null && remainingChars.length()>0)
        {
            if(remainingChars.length()>60)
            {
                commentsstuff.add(remainingChars.substring(0,60));
                remainingChars = remainingChars.substring(60);
            }
            else
            {
                commentsstuff.add(remainingChars);
                remainingChars = '';
            }
        }    
        details.ApprovalComments = commentsstuff;
        
        if(wc.Approval_Status__c!= null)
        {
            details.ApprovalStatus = wc.Approval_Status__c.substring(0,1);
        }
        else
        {
            details.ApprovalStatus = 'P';
        }
        
        if(warrantyCase.isApprovalStatusChanged__c && wc.Total_Amount_Approved__c>approvalLimit)
        {
            oResponse.message = 'The total approval amount ' + apamounts.Total + ' exceeds your approval limit ' + approvalLimit + ' the VCAN has been set to an Approval Status of Pending';
            oResponse.success = true;
            
            details.ApprovalStatus = 'P';
        }
        
        Nna360VCAN2MasterServiceSoap.updateVCAN_Output respOutput;
        
        String username;
        String password;
        
        if(ZCA_Id==null || ZCA_Id.length()<1)
        {
            oResponse.message = 'ZCA_Id missing';
            oResponse.success = false;
            return oResponse;
        }
        
        if(VCAN_Password==null || VCAN_Password.length()<1)
        {
            oResponse.message = 'Please update your host password in setup. You must provide your host password each time it changes.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        String clearText = ZCA_Id;//DWH001L
        Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
        username = EncodingUtil.base64Encode(cipherText); 
        //AAB Password is already encrypted
        /*clearText = 'NISSAN22';
cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
password = EncodingUtil.base64Encode(cipherText); 
*/
        password = VCAN_Password;   
        
        if(disableLogins || Test.isRunningTest())
        {
            oResponse.message = Label.VCAN_Maintenance_Message;
            oResponse.success = false;
            
            return oResponse;
        }
        
        response = service.updateVCAN(details, username, password);
        respOutput = response.updateVCANResp;
        
        String respMSG = respOutput.MessageDescription;
        String respCode = respOutput.MessageCode;
        
        oResponse.message = respMSG;
        oResponse.success = true;
        
        if(respMSG!=null)
        {
            String errorMsg = respMSG;
            if(errorMsg.indexOf(VCAN_Password_Error_String)>-1)
            {
                oResponse.message = VCAN_Password_Error;
                oResponse.success = false;
            }
            else if(errorMsg.indexOf(VCAN_Account_Locked_Error_String)>-1)
            {
                oResponse.message = VCAN_Account_Locked_Error;
                oResponse.success = false;
            }
            else
            {
                oResponse.message = errorMsg;
            }
        }
        
        System.debug('oResponse:::'+oResponse);
        return oResponse;
    }
    
    public PageReference deleteVCAN()
    {
        if(canDelete==false)
        {
            errorMessage = 'You do not have permissions to delete a VCAN';
            errorColor = 'color: red';
            return null;            
        }
        
        showProgress = true;
        VCANJSONResponse oResponse = deleteWarrantyCaseVCAN(warrantyCase.Id);
        showErrorMessage = true;
        showProgress = false;
        
        
        
        if(oResponse.success == false || oResponse.message == null || oResponse.message.length()<3 || oResponse.message.substring(0,3)!='322')
        {
            if(oResponse.message == null)
            {
                warrantyCase.HOST_Error_Message__c = 'Delete VCAN Failed, unexpected HOST Error, no Response Returned';
                errorMessage = warrantyCase.HOST_Error_Message__c;
                warrantyCase.isSystemUpdate__c = true;
                update warrantyCase;
                errorColor = 'color: red';
                return null;
            }
            
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            errorMessage = oResponse.message;
            update warrantyCase;
            errorColor = 'color: red';
        }
        else
        {
            Integer errorLength = oResponse.message.length();
            if(errorLength>255)
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message.substring(0,255);
            }
            else
            {
                warrantyCase.HOST_Error_Message__c = oResponse.message;
            }
            
            LastModifiedByName = System.UserInfo.getName() + ', ' + datetime.now().format('MM/dd/yyyy HH:mm a');
            
            warrantyCase.Host_Reference_Number__c = '';
            warrantyCase.HOST_Comments__c = '';
            errorMessage = 'VCAN deleted successfully';
            
            HostReferenceNumber = '';
            HostErrorMessage = errorMessage;
            ApprovalStatus = '';
            HostComments = '';
            
            if(ZCA_Id!=null)
            {
                canCreate = true;
                showDelete = false;
            }
            
            if(VCANComment != null)
            {
                String now = String.ValueOf(system.now());
                if(warrantyCase.Internal_Comments__c== null){
                    warrantyCase.Internal_Comments__c= '<b>'+UserInfo.getName()+' - '+now+'</b><br/>' + 'VCAN Deleted';
                }
                else{
                    warrantyCase.Internal_Comments__c+= '<br/><br/>****************************<br/><b>'+UserInfo.getName()+' - '+now+'</b><br/>'+ 'VCAN Deleted';
                }
            }
            
            update warrantyCase;   
            hasVCAN = false;
            return null;
        }
        
        return null;
    }
    
    public VCANJSONResponse deleteWarrantyCaseVCAN(String warrantyId ) 
    {
        VCANJSONResponse oResponse = new VCANJSONResponse();
        
        Warranty_Case__c wc = getWarrantyCase(warrantyId);        
        
        Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort service = new Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort();
        service.inputHttpHeaders_x=new Map<String,String>();
        service.timeout_x = 120000;
        Blob headerValue = Blob.valueOf('X987147' + ':' + '90NissanT');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        Nna360VCAN2MasterServiceSoap.deleteVCANResp response;
        Nna360VCAN2MasterServiceSoap.vcanQueryData qd = new Nna360VCAN2MasterServiceSoap.vcanQueryData();
        
        qd.WONumber = wc.Repair_Work_Order__c; //'74731';//
        qd.WOLine = wc.Job_Line_Number__c; //'ABC';//
        qd.VIN= wc.Vehicle__r.Name; //'JNKAJ09E78M 306003';//
        if(qd.VIN.indexOf(' ')!=11 && addSpace==true)
        {
            qd.VIN = qd.VIN.substring(0,11) + ' ' + qd.VIN.substring(11);
        }
        qd.ServiceFacility = wc.Dealer_Code__c;//'73319';//
        
        Nna360VCAN2MasterServiceSoap.deleteVCAN_Output respOutput;
        
        String username;
        String password;
        
        if(ZCA_Id == null || ZCA_Id.length()<1)
        {
            oResponse.message = 'ZCA_Id missing';
            oResponse.success = false;
            return oResponse;
        }
        
        if(VCAN_Password.length()<1)
        {
            oResponse.message = 'Please update your host password in setup. You must provide your host password each time it changes.';
            oResponse.success = false;
            
            return oResponse;
        }
        
        String clearText = ZCA_Id;//DWH001L
        Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
        username = EncodingUtil.base64Encode(cipherText); 
        //AAB Password is already encrypted
        /*clearText = 'NISSAN22';
cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(clearText));
password = EncodingUtil.base64Encode(cipherText); 
*/
        password = VCAN_Password;   
        
        if(disableLogins || Test.isRunningTest())
        {
            oResponse.message = Label.VCAN_Maintenance_Message;
            oResponse.success = false;
            
            return oResponse;
        }
        
        response = service.deleteVCAN(qd, username, password);
        respOutput = response.deleteVCANResp;
        System.debug(respOutput.MessageDescription);
        
        String respMSG = respOutput.MessageDescription;
        String respCode = respOutput.MessageCode;  
        
        oResponse.message = respMSG;
        oResponse.success = true;
        
        if(respMSG!=null)
        {
            String errorMsg = respMSG;
            if(errorMsg.indexOf(VCAN_Password_Error_String)>-1)
            {
                oResponse.message = VCAN_Password_Error;
                oResponse.success = false;
            }
            else if(errorMsg.indexOf(VCAN_Account_Locked_Error_String)>-1)
            {
                oResponse.message = VCAN_Account_Locked_Error;
                oResponse.success = false;
            }
            else
            {
                oResponse.message = errorMsg;
            }
        }
        
        return oResponse;
    }
    
    public PageReference changePassword()
    {
        allowPasswordEntry = true;
        newVCANPassword = '';
        return null;
    }
    
    public PageReference savePassword()
    {
        if(newVCANPassword==null)
        {
            return null;
        }
        
        thisUser.VCAN_Password__c = newVCANPassword;
        update thisUser;
        
        thisUser = [select ID, warranty_app_amount__c, warranty_vcan_delete__c, ZCA_Id__c, VCAN_Password__c from User where Id=:System.UserInfo.getUserId()];
        
        VCAN_Password = thisUser.VCAN_Password__c;
        
        if(ZCA_Id !='' && ZCA_Id != null && VCAN_Password!='' && VCAN_Password!=null)
        {
            canCreate = true;
            allowPasswordEntry = false;
            hasPassword = true;
            newVCANPassword = VCAN_Password;
            errorMessage = 'HOST Password saved successfully.';
            errorColor = 'color: black';
            showErrorMessage = true;
        }
        return null;
    }
    
    private static string formatPhoneNumber(String phone)
    {
        if(phone==null)
        {
            return null;
        }
        
        return phone.replaceAll('[^0-9]','');        
    }
    
    public class VCANJSONResponse {
        public string message {get;set;}
        public boolean success {get;set;}   
        public String VCANRefNumber {get;set;}
        public String AffiliateCode {get;set;}
        public String WONumber {get;set;}
        public String WOLine {get;set;}
        public String ServiceFacility {get;set;}
        public String VIN {get;set;}
        public String WOOpenDate {get;set;}
        public String Miles {get;set;}
        public String PFPPO {get;set;}
        public String CallerName {get;set;}
        public String CallerPhone {get;set;}
        public String CallerExt {get;set;}
        public String CustomerName {get;set;}
        public String PartsAtCost {get;set;}
        //Approval Amounts
        public String Parts {get;set;}
        public String LBR {get;set;}
        public String Expense {get;set;}
        public String Total {get;set;}
        public String ApprovalComments {get;set;}
        public String ForceGoodwill {get;set;}
        
        //Act Approval Condition
        public String NormalApproval {get;set;}
        public String RepairReview {get;set;}
        public String MileageProgressReview {get;set;}
        public String CampaignDiffDealer {get;set;}
        public String GoodwillApproval {get;set;}        
        
        public String ApprovalStatus {get;set;}
        public String ApprId {get;set;}
        public String ApprByName {get;set;}
        public String ApprDate {get;set;}
        public String EnteredByUserId {get;set;}
        public String EnteredDate {get;set;}
        public String ChangedByUserId {get;set;}
        public String ChangedByName {get;set;}
        public String ChangedDate {get;set;}
        public String LanId {get;set;}
    }
    
    public Warranty_Case__c getWarrantyCase(String warrantyId)
    {
        return [select ID, Name, Dealer__c, Dealer_Code__c, Vehicle__c, Vehicle__r.Name, Repair_Work_Order__c, 
                Job_Line_Number__c, Customer_Concern__c,
                Repair_Work_Order_Open_Date__c,
                Vehicle_Mileage__c,
                Primary_Failed_Part__c,
                Requestor_s_Name__c,
                Customer_Name__c,
                Parts_at_Cost__c,
                Force_Goodwill_Coverage__c,
                Parts__c,
                Labor__c,
                Expenses__c,
                Total_Amount_Approved__c,
                Requestor_s_Phone_Number__c,
                Internal_Comments__c,
                Approval_Information__c,
                Approval_Status__c, 
                Normal_Approval__c,
                Repeat_Repair_Review__c,
                Mileage__c,
                Duplicate_Campaign_Different_Dealer__c,
                Goodwill_Approval__c,
                HOST_Error_Message__c, HOST_Reference_Number__c,
                Host_Comments__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                Vehicle_Campaign1__c,
                Vehicle_Campaign1__r.Name,
                isVCANUpdate__c, isSystemUpdate__c, isApprovalStatusChanged__c
                from Warranty_Case__c where Id=:warrantyId];
    }
    
    //AAB Method to convert form upper case to title Case
    public static String toTitleCase ( String inStr ) 
    {
        
        if(inStr!=null && inStr.length()>0)
        {
            inStr = inStr.toLowerCase();
        }
        else
        {
            return inStr;
        }
        String outStr = '';
        for ( String word : inStr.trim().split(' +')) 
        {
            outStr += outStr.length()>1 ? ' ' : '';
            outStr += word.subString(0,1).toUpperCase();
            outStr += (word.length() > 1) ? word.SubString(1) : '';
        }
        return outStr;
    }
    
    public static Date convertMMDDYYToDate(String sDate)
    {
        if(sDate==null || sDate=='')
        {
            return null;
        }
        
        List<String> parts;
        if(sDate.contains('-'))
        {
            parts = sDate.split('-');
        }
        else if(sDate.contains('/'))
        {
            parts = sDate.split('/');
        }
        else
        {
            return null;
        }
        
        if(parts==null || parts.size()<3)
        {
            return null;
        }
        
        String SFDate = '';
        
        integer compareVal = Integer.valueOf(parts[2]);
        if(compareVal<30)
        {
            if(compareVal<10)
            {
                SFDate = '200' + compareVal;
            }
            else
            {
                SFDate = '20' + compareVal;
            }
        }
        else
        {
            SFDate = '19' + compareVal;
        }
        
        //Month
        compareVal = Integer.valueOf(parts[0]);
        if(compareVal<10)
        {
            SFDate += '-0' + compareVal;
        }
        else
        {
            SFDate += '-' + compareVal;
        }
        
        //Day
        compareVal = Integer.valueOf(parts[1]);
        if(compareVal<10)
        {
            SFDate += '-0' + compareVal;
        }
        else
        {
            SFDate += '-' + compareVal;
        }
        SFDate += ' 12:00:00';
        
        return Date.valueOf(SFDate);
    }
}