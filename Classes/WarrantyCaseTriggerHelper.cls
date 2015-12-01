public class WarrantyCaseTriggerHelper{
    
    
    public static void handleAfterInsert(Map<Id, Warranty_Case__c> wrtyCaseMap){
        List<Reason__c> reasonsToCreate = new List<Reason__c>();
        Reason__c reason;
        for(Warranty_Case__c newCase: wrtyCaseMap.values()){
            if(newCase.Reason__c  != null || newCase.Subreason__c != null || newCase.Error_Code__c != null){
                reasonsToCreate.add(new Reason__c(Warranty_Case__c = newCase.Id, Reason__c = newCase.Reason__c, 
                                       Subreason__c = newCase.Subreason__c, Error_Code__c = newCase.Error_Code__c));               
            }
        }
        
        if(reasonsToCreate.size() > 0){
            Database.insert(reasonsToCreate, false);        
        }
    }
    
    //Whenever a warranty case is updated and the VCAN fields change we will,
    //call the host system with an update VCAN call
    public static void handleBeforeUpdate(Map<Id, Warranty_Case__c> wrtyCaseMap, Map<Id, Warranty_Case__c> oldWrtyCaseMap){
        User thisUser;
        User precallSiteUser;
        List<Reason__c> reasonsToCreate = new List<Reason__c>();
        Set<String> recTypeids = new Set<String>();
        String[] ownerNames  = new String[]{};
        ownerNames = Label.Pre_Call_Ownership_Queue_Reassignment.split(',');
        Set<String> ownerIds = new Set<String>();
        for(Group gp : [Select Id, Name from Group where Name IN :ownerNames]){
        	ownerIds.add(gp.Id);
        }
        Boolean isTestRunning = (Label.VCAN_Debug_VCAN_Errors=='true' || Test.isRunningTest()) ? true : false; 
        for(User usr : [select ID, Name, warranty_app_amount__c, warranty_vcan_delete__c, ZCA_Id__c from User where Id=:System.UserInfo.getUserId() OR Name =: Label.Precall_Site_Guest_User Limit 2]){
        	if(usr.Name == Label.Precall_Site_Guest_User){
        		precallSiteUser = usr;
        		thisUser = usr;
        	}else{
        		thisUser = usr;
        	}
        }   
        
        Warranty_Case__c oldCase;
        Boolean onlyCommentUpdated = false;
        String ZCA_Id;
        String CaseName;
        Double approvalLimit; 
       
        
        Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Warranty_Case__c.getRecordTypeInfosByName();        
        for(String s : Label.Warranty_Case_Record_Types.split(',')){
        	recTypeids.add(s);
        }
        
        String tmpLimit = thisUser.warranty_app_amount__c;
        if(tmpLimit!= null && tmpLimit != '')
        {
            approvalLimit = Double.valueOf(thisUser.warranty_app_amount__c);
        }
        else
        {
            approvalLimit = 0;
        }
        if(isTestRunning)
        {
            System.debug('ZCA ID:' + ZCA_Id + ' Approval Limit:' + approvalLimit);
        }
        
        for(Warranty_Case__c newCase : wrtyCaseMap.values()){
            
            oldCase = oldWrtyCaseMap.get(newCase.Id);                        
            CaseName = newCase.Name;			
			
			if(newCase.CreatedById == precallSiteUser.Id && ownerIds.contains(newCase.OwnerId) && precallSiteUser.Id != Userinfo.getUserId()){
				System.debug('UserInfo.getUserId::'+ Userinfo.getUserId());
				newCase.OwnerId = userinfo.getUserId();
			}
			
            if(newCase.isApprovalStatusChanged__c == true)
            {
                newCase.isApprovalStatusChanged__c = false;
            }
            
            System.debug('newCase.Reason__c::'+newCase.Reason__c+'::newCase.Subreason__c::'+newCase.Subreason__c);
            if((newCase.Reason__c  != null && (newCase.Reason__c != oldCase.Reason__c)) 
                 || (newCase.Subreason__c != null && (newCase.Subreason__c != oldCase.Subreason__c) 
                 || newCase.Error_Code__c != null && (newCase.Error_Code__c != oldCase.Error_Code__c))){
               reasonsToCreate.add(new Reason__c(Warranty_Case__c = newCase.Id, Reason__c = newCase.Reason__c, 
                                       Subreason__c = newCase.Subreason__c, Error_Code__c = newCase.Error_Code__c));
            }
            
            if(newCase.Repair_Work_Order__c!=oldCase.Repair_Work_Order__c
               || newCase.Job_Line_Number__c!=oldCase.Job_Line_Number__c
               || newCase.Vehicle__c!=oldCase.Vehicle__c
               || newCase.Dealer_Code__c!=oldCase.Dealer_Code__c
              )
            {
                newCase.HOST_Reference_Number__c = '';
                newCase.HOST_Comments__c = '';
                newCase.HOST_Error_Message__c = '';
                newCase.isVCANUpdate__c = false;
                newCase.isSystemUpdate__c = false;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: Key Field Value Changes');
                }
                continue;
            }
            
            if(newCase.isSystemUpdate__c)
            {
                newCase.isSystemUpdate__c = false;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: System Update');
                }
                continue;
            }
            
            if(newCase.HOST_Reference_Number__c==null)
            {
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: HOST_Reference_Number__c==null');
                }
                continue;
            }
            
            if(newCase.isVCANUpdate__c==true)
            {
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: isVCANUpdate already true');
                }
                continue;
            }
            
            if(newCase.Approval_Information__c != null && newCase.Approval_Information__c.indexOf('**SFDCUPDATE**')>-1)
            {
                newCase.Approval_Information__c = newCase.Approval_Information__c.substring(14);
                newCase.isVCANUpdate__c = true;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: Approval Information contains **SFDCUPDATE**');
                }
                continue;
            } 
            
            onlyCommentUpdated = false;
            if(newCase.Repair_Work_Order_Open_Date__c==oldCase.Repair_Work_Order_Open_Date__c
               && newCase.Vehicle_Mileage__c==oldCase.Vehicle_Mileage__c
               && newCase.Primary_Failed_Part__c==oldCase.Primary_Failed_Part__c
               && newCase.Vehicle_Campaign1__c==oldCase.Vehicle_Campaign1__c
               && newCase.Requestor_s_Name__c==oldCase.Requestor_s_Name__c
               && newCase.Customer_Name__c==oldCase.Customer_Name__c
               && newCase.Parts_at_Cost__c==oldCase.Parts_at_Cost__c
               && newCase.Normal_Approval__c==oldCase.Normal_Approval__c
               && newCase.Repeat_Repair_Review__c==oldCase.Repeat_Repair_Review__c
               && newCase.Mileage__c==oldCase.Mileage__c
               && newCase.Duplicate_Campaign_Different_Dealer__c==oldCase.Duplicate_Campaign_Different_Dealer__c
               && newCase.Goodwill_Approval__c==oldCase.Goodwill_Approval__c
               && newCase.Parts__c==oldCase.Parts__c
               && newCase.Labor__c==oldCase.Labor__c
               && newCase.Expenses__c==oldCase.Expenses__c
               && newCase.Total_Amount_Approved__c==oldCase.Total_Amount_Approved__c
               && newCase.Force_Goodwill_Coverage__c==oldCase.Force_Goodwill_Coverage__c
               && newCase.Requestor_s_Phone_Number__c==oldCase.Requestor_s_Phone_Number__c
               && newCase.Approval_Status__c==oldCase.Approval_Status__c)
            {
                if(newCase.Approval_Information__C==null)
                {
                    if(isTestRunning)
                    {
                        system.debug('Trigger ended due to: VCAN Fields all equal to previous values and VCAN Comments=Null');
                    }
                    continue;
                }
                else if(newCase.Approval_Information__c!=oldCase.Approval_Information__c)
                {
                    if(isTestRunning)
                    {
                        system.debug('Only change was a new comment:' + newCase.Approval_Information__c);
                    }
                    onlyCommentUpdated = true;
                }
                else
                {
                    //Nothing at all changed exit loop
                    if(isTestRunning)
                    {
                        system.debug('Trigger ended due to: VCAN Fields all equal to previous values and VCAN Comments equal to previous comments');
                    }
                    continue;
                }
            }
            
            if(newCase.Repair_Work_Order__c==null 
               || newCase.Job_Line_Number__c==null 
               || newCase.Vehicle__c==null 
               || newCase.Dealer_Code__c==null
               || newCase.Repair_Work_Order_Open_Date__c==null
               || newCase.Vehicle_Mileage__c==null 
               || (newCase.Primary_Failed_Part__c==null && newCase.Vehicle_Campaign1__c==null)
               || newCase.Customer_Name__c == null)
            {        
                if(isTestRunning)
                {
                    system.debug('Null Case Fields: ' + 
                                 (newCase.Repair_Work_Order__c==null?'WO':'') + '|' +
                                 (newCase.Job_Line_Number__c==null?'Line':'') +'|' +
                                 (newCase.Vehicle__c==null?'Vehicle':'') +'|' +
                                 (newCase.Dealer_Code__c==null?'Dealer Code':'') +'|' +
                                 (newCase.Repair_Work_Order_Open_Date__c==null?'WODate':'') +'|' +
                                 (newCase.Vehicle_Mileage__c==null?'Miles':'') +'|' +
                                 (newCase.Primary_Failed_Part__c==null?'Part':'') +'|' +
                                 (newCase.Vehicle_Campaign1__c==null?'Campaign':'') +'|' +
                                 (newCase.Customer_Name__c==null?'Cust Name':'') + '|'
                                );
                    system.debug('Trigger ended due to: Null VCAN Fields');
                }
                continue;
            }           
            
            if(newCase.Total_Amount_Approved__c>approvalLimit)
            {
                if(!onlyCommentUpdated)
                {
                    if(newCase.Approval_Status__c!='Pending')
                    {
                        newCase.Approval_Status__c = 'Pending';  
                        newCase.isApprovalStatusChanged__c = true;
                    }
                }
                else
                {
                    if(isTestRunning)
                    {
                        system.debug('Total Amount Approved > approvalLimit but comments are the only changed values');
                    }
                }
            }   
            else
            {
                if(isTestRunning)
                {
                    system.debug('ApprovalLimit:' + approvalLimit + ' NewCase Total:' + newCase.Total_Amount_Approved__c);
                    system.debug('WC Total:' + newCase.Total_Amount_Approved__c);
                }
            }
            
            if(newCase.Approval_Information__c==null || newCase.Approval_Information__c=='')
            {
                newCase.Approval_Information__c = Label.VCAN_Auto_Update_Comment;
            }
            
            newCase.isVCANUpdate__c = true;
            
        }
        
        if(reasonsToCreate.size() > 0){
            Database.insert(reasonsToCreate, false);        
        }
        
    }
    
    
    
}