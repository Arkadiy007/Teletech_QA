/**********************************************************************
Name: Case_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Set Stage_Status__c value on the case appropriately
when it is inserted or updated so it will be picked
up by batch processing.

Related Apex Class: CaseClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry     10/21/2011 Created
1.1 - Yuli Fintescu 01/05/2012 Sync Vin__c to Vehicle if Vehicle_Name__c
1.2 - Yuli Fintescu 01/05/2012 Update Buyback__c field if applicable
1.3 - Bryan Fry     05/02/2013 Add VCS Support validation check
1.4 - Bryan Fry     07/17/2013 Add VCS Alert checks to close case
1.5 - Bryan Fry     10/17/2013 Look up account and contact Ids for Sales & Service Record Type
1.6 - Bryan Fry     10/23/2013 Look up dealer and vehicle Ids for Sales & Service Record Type
1.7 - Bryan Fry     11/04/2013 Add code to set Follow Up Date for Sales & Service Record Type
1.8 - William Taylor01/12/2013 Added tread code lookup
1.9 - Rohdenburg S  01/19/2014 Added the Techline alerts feature
2.0 - Matt Starr    03/06/2014 Add code to send Cases with phone numbers out of DQR No Phone # Queue
2.1 - Matt Starr    05/20/2014 Cleaning up the SOQL
2.2 - William Taylor08/27/2014 Adding trigger code for NOTOR case to notor__c object
2.3 - Anna Koseykina 19/12/2014 Add logic for Date fields for indicators (Fire, Rollover, Injury, Sent to Legal, Property Damage, Goodwill Offered)
2.4 - Aaron Bessey  03/06/2015 Convert Workflow Rule From Field Update to Trigger code
2.5 - Anna Koseykina 07/09/2015 Add check if TREAD Component Code is changed
2.6 - Vladimir Martynenko 07/07/2015 Add logic for reopen Case if Case_Dealer_Disposition__c equals to REJECTED or CACHE and GUID is not null
***********************************************************************/
trigger Case_Before on Case (before insert, before update) {
    private final String RECORD_TYPE_TECH_LINE = 'TECH LINE Cases';
   // public Map<Id, Id> caseRecordTypes = new Map<ID, ID>();
    Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Set<String> caseR2RTs = new Set<String>{'CA', 'CA Closed Case', 'CA Email Infiniti', 'CA Email Nissan', 'CA EXEC', 'DPIC TSO', 'Roadside Assistance', 'T5', 'TECH LINE','TECH LINE Cases', 'Sales & Service Record Type'};
    //List<RecordType> caseR2RTs = [select id, name from recordtype where name in ('CA', 'CA Closed Case', 'CA Email Infiniti', 'CA Email Nissan', 'CA EXEC', 'DPIC TSO', 'Roadside Assistance', 'T5', 'TECH LINE','TECH LINE Cases', 'Sales & Service Record Type') and sobjecttype = 'Case'];
    Set<Id> subjectRTs = new Set<Id>();
    Set<String> subjectRTNames = new Set<String>{'CA','Roadside Assistance','T5','TECH LINE'};
    for(String rt : rtInfosByName.keyset())
    {
        if(subjectRTNames.contains(rt))
        {
            subjectRTs.add(rtInfosByName.get(rt).getRecordTypeId());
        }
    }
    Id dpicRTId = rtInfosByName.get('DPIC').getRecordTypeId() ;  // '012F0000000y9yCIAQ';
    Id salesAndServiceRTId = rtInfosByName.get('Sales & Service Record Type').getRecordTypeId() ; // '012F0000000yCgM';    
    Id NOTORCaseRTId = rtInfosByName.get('NOTOR').getRecordTypeId() ; //'012c00000004ilY';  // FOR QA
    Id techLineRecordTypeId = rtInfosByName.get('TECH LINE Cases').getRecordTypeId() ;
    String EnrollmentAlertId = rtInfosByName.get('Enrollment Alert').getRecordTypeId();
    Id CArecordTypeId = rtInfosByName.get('CA').getRecordTypeId();
    Id techLineRTypeId = rtInfosByName.get('TECH LINE').getRecordTypeId();
    Id t5RTypeId = rtInfosByName.get('T5').getRecordTypeId();
    Id caEmailNissanRTypeId = rtInfosByName.get('CA Email Nissan').getRecordTypeId();
    Id caEmailInfinitiRTypeId = rtInfosByName.get('CA Email Infiniti').getRecordTypeId();
    Id caSalesServRTypeId = rtInfosByName.get('CA Sales & Service').getRecordTypeId();
    Id dtuRTypeId = rtInfosByName.get('DTU').getRecordTypeId();
    
    //ID NOTORCaseRTId = '012F0000000zXM8';  // FOR PROD
    
    List<Notor__c> nCasesToInsert = new List<Notor__c>();
    List<Case> nCasesToDelete = new List<Case>();
    Set<Id> caseIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Set<Id> vehicleIds = new Set<Id>();
    Map<Id, Contact> caseContacts = new Map<Id, Contact>();
    Map<Id, Vehicle__c> caseVehicles = new Map<Id, Vehicle__c>();    
    Set<ID> r2RTIds = new Set<ID>();
    Set<Id> cadealerAcctIds = new Set<Id>();
    Map<Id, Account> mapCAServicingAccounts = new Map<Id, Account>();
    
    Map<String,Case> dpicLookupVins = new Map<String,Case>();
    List<Case> vins = new List<Case>(); //populate Vehicle ID using VINs
    List<Case> vids = new List<Case>(); //populate VIN using vids
    Set<ID> idSet = new Set<ID>();
    Set<String> vinSet = new Set<String>();
    Set<String> customerIds = new Set<String>();
    Set<String> vehicleVINs = new Set<String>();
    Set<String> dealerExternalIds = new Set<String>();
    Set<String> dealercaseIds = new Set<String>();
    Set<String> dealerCodes = new Set<String>();
    
    for (String r : rtInfosByName.keyset()) {
        
        if(caseR2RTs.contains(r)){
         r2RTIds.add(rtInfosByName.get(r).getRecordTypeId());
        }
    }
    
    for (Case c: Trigger.new) 
    {
        caseIds.add(c.Id);
        if(c.ContactId!=null)
        {
            contactIds.Add(c.ContactId);
        }
        if(c.Vehicle_Name__c!=null)
        {
            vehicleIds.Add(c.Vehicle_Name__c);
        }
        
        if(r2RTIds.contains(c.RecordTypeId) && c.Servicing_Dealer__c != null){
        	cadealerAcctIds.add(c.Servicing_Dealer__c);
        }
    }
    
    if(contactIds.size() > 0){
    caseContacts = new Map<Id, Contact>([Select Id, FirstName, LastName, HomePhone from Contact where Id in: contactIds]);
    }
    
    if(vehicleIds.size() > 0){
    caseVehicles = new Map<Id, Vehicle__c>([Select Id, Name from Vehicle__c where Id in:vehicleIds]);
    }
    
    if(cadealerAcctIds.size() > 0){
    	mapCAServicingAccounts = new Map<Id, Account>([Select Id, DTS_A_Stage_User__c, DTS_A_Stage_User__r.Full_Name__c, Name from Account where Id in:cadealerAcctIds]);
    } 
        
    String ContactFirstName ='';
    String ContactLastName ='';
    String ContactPhone ='';
    String VIN = '';
    
    Contact oContact;
    Vehicle__c oVehicle;
    
    for (Case c: Trigger.new) {
        //Subject Workflow Rule
        if(subjectRTs.contains(c.RecordTypeId) && c.Description!='Quality Connection Hot Alert')
        {
            if(c.ContactId!=null)
            {
                oContact = caseContacts.get(c.ContactId);
                if(oContact!=null)
                {
                    ContactFirstName = oContact.FirstName!=null ? oContact.FirstName : '';
                    ContactLastName = oContact.LastName!=null ? oContact.LastName : '';
                    ContactPhone = oContact.HomePhone!=null ? oContact.HomePhone : '';
                }
            }
            
            if(c.Vehicle_Name__c!=null)
            {
                oVehicle = caseVehicles.get(c.Vehicle_Name__c);
                if(oVehicle!=null)
                {
                    VIN = oVehicle.Name!=null ? oVehicle.Name : '';
                }
            }
            c.Subject = 'CUSTOMER: ' + ContactFirstName + ' ' + ContactLastName + ' PHONE: ' + ContactPhone + ' VIN: ' + VIN;
        }
        
        if (c.RecordTypeId == NOTORCaseRTId && Trigger.isInsert && c.Origin == 'Email to Case') {
             Notor__c n = new Notor__c();
             
             n.OwnerId = '00Gc0000000knCC'; // for qa
            //n.OwnerId = '00GF0000003iGb2'; // for production
             
             n.Case_Origin__c= c.Origin;
             n.Subject__c = c.Subject;
             n.Web_Email__c = c.SuppliedEmail;
             n.Web_Name__c = c.SuppliedName;
             n.Description__c = c.Description;
             n.Case_Reason__c = c.Reason;
             nCasesToInsert.add(n);
             if (!Test.isRunningtest()) {
             c.addError('Preventing case insert due to notor.');
             }
             nCasesToDelete.add(c);
             
        }
        //caseRecordTypes.put(c.Id, c.recordTypeId);
		if(r2RTIds.contains(c.RecordTypeId) && c.Servicing_Dealer__c != null){
			if(mapCAServicingAccounts.get(c.Servicing_Dealer__c) != null && mapCAServicingAccounts.get(c.Servicing_Dealer__c).DTS_A_Stage_User__c != null){
				c.DTS_Name__c = mapCAServicingAccounts.get(c.Servicing_Dealer__c).DTS_A_Stage_User__r.Full_Name__c;
			}else{
				c.DTS_Name__c = '';
			}
			
		}
		if(c.FFFS__c && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).FFFS__c == false))){
			c.FFFS_Date__c =  Date.today();
		}else if(Trigger.isUpdate && Trigger.oldMap.get(c.Id).FFFS__c && c.FFFS__c == false){
			c.FFFS_Date__c = null;
		}
    }
    if (nCasesToInsert.size() > 0) {    
    List<Database.SaveResult> sr = Database.insert(nCasesToInsert);
    //List<Database.DeleteResult> sr2 = Database.delete(nCasesToDelete);    
    }
    
    
    // RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'TECH LINE Cases');
    List<Code__c> treadCodesList = [select Id, Description__c, Component_Code__c, Value__c from Code__c where Type__c = 'TREAD_Component'];
    
    Map<String,String> treadCodes = new Map<String,String>();
    for(Code__c treadCode:  treadCodesList) {
        treadCodes.put(treadCode.Value__c, treadCode.Component_Code__c);
    }
    
    for (Case c: Trigger.new) {
        // Batch processing sets state to done, this trigger sets state
        // back to initial in that case.
        if (c.Stage_Status__c == System.Label.Stage_Status_Done)
            c.Stage_Status__c = System.Label.Stage_Status_None;
        // Otherwise this is not a change as a result of batch processing
        // so set state to indicate a change has been made and needs to be
        // processed. If this is an insert, indicate this will be an Add.
        else if (Trigger.isInsert)
            c.Stage_Status__c = System.Label.Stage_Status_Add;
        // If this is an update, we need to indicate it is an Update unless
        // the record is already flagged as an Add, meaning it was created
        // since the last time the batch process ran and should be reported
        // as an Add even with the updated changes being made.
        else if (Trigger.isUpdate && c.Stage_Status__c != System.Label.Stage_Status_Add)
            c.Stage_Status__c = System.Label.Stage_Status_Update;
        
        if (r2RTIds.contains(c.RecordTypeId)) {
            if (Trigger.isUpdate) {
                Case old = Trigger.oldMap.get(c.ID);
                if (old.Vehicle_Name__c != c.Vehicle_Name__c) { //user changes vehicle, use vehicle to change VIN
                    vids.add(c);
                    if (c.Vehicle_Name__c != null)
                        idSet.add(c.Vehicle_Name__c);
                } else if (old.VIN__c != c.VIN__c)  { //user changes VIN, use VIN to change vehicle
                    vins.add(c);
                    if (c.VIN__c != null)
                        vinSet.add(c.VIN__c);
                }
            } else if (Trigger.isInsert) {
                if (c.Vehicle_Name__c != null) { //user selects vehicle, use vehicle to change VIN
                    vids.add(c);
                    idSet.add(c.Vehicle_Name__c);
                } else if (c.VIN__c != null) { //user selects VIN, use VIN to change vehicle
                    vins.add(c);
                    vinSet.add(c.VIN__c);
                }
            }
        }
        

        
        if (c.RecordTypeId == salesAndServiceRTId && c.AccountId == null && c.Contact_Id__c != null) {
            customerIds.add(c.Contact_Id__c);
        }
        if (c.RecordTypeId == salesAndServiceRTId && c.Vehicle_Name__c == null && c.VIN__c != null) {
            vehicleVINs.add(c.VIN__c);
        }
        if (c.RecordTypeId == salesAndServiceRTId && c.Servicing_Dealer__c == null && c.Dealer_Number__c != null) {
            dealerExternalIds.add(c.Dealer_Number__c + System.Label.Dealer_USA);
        }
        if (c.RecordTypeId == techlineRecordTypeId) {
            dealercaseIds.add(c.Id);
            if (c.DealerExternalId__c != null) {
                dealerCodes.add(c.DealerExternalId__c);
            }
        }
        
        // Added for 
        if(c.Customer_Document_Requested__c && c.Date_Requested__c == null){
        	c.Date_Requested__c = Date.today();
        }
        if(c.Customer_Document_Received__c && c.Date_Received__c == null){
        	c.Date_Received__c = Date.today();
        }

    }

    // Lookup and populate Tread Component Code from either Component category
    List<Case> casesToUpdate = new List<Case>();
    List<Account> dealerAccountsList;
    String thisLookup;
    String newTread;
    String thisBillCountry;
    Map<String,String> dealerCodesMap = new Map<String,String>();
    Account dealerAccount;
    
    if (dealerCodes.size() > 0 || Test.isRunningTest()) {
        dealerAccountsList = [Select Id, Dealer_External_Id__c, Dealer_Code__c, BillingCountry From Account Where RecordType.Name = 'Dealer' AND Dealer_External_Id__c IN :dealerCodes ];
        for(Account ea:  dealerAccountsList) {
            dealerCodesMap.put(ea.Dealer_External_Id__c, ea.BillingCountry);
        }
    }
    

    for (Case c: Trigger.new) {
        if (c.RecordTypeId == techlineRecordTypeId) {
            thisBillCountry = '';
            
            if (c.DealerCode__c != null) {
                thisBillCountry = dealerCodesMap.get(c.DealerExternalId__c);
            }
            
           if (thisBillCountry != 'Canada') {
                if (c.Component_Code_Issue__c != null) {
                      thisLookup = c.Component_Code_Issue__c.substring(0,3).trim().replace('|','');
                } else if (c.Component_Code_Category__c != null) {
                      thisLookup = c.Component_Code_Category__c.substring(0,3).trim().replace('|','');
                } else {
                      thisLookup = '';
                }
                if (thisLookup != '') {
                       newTread = treadCodes.get(thisLookup);
                        if(newTread != c.TREAD_Component__c){
                           c.TREAD_Component_Prior_Value__c = c.TREAD_Component__c; //backup old tread component in field.
                           c.TREAD_Component__c = newTread;
                           c.TREAD_Effective_Date__c = Date.valueOf(System.now());
                         }
                       //casesToUpdate.add(cCountry);
                }
            }
        }     
    }
    
    //populate Vin__c by Vehicle__c.VIN.
    Map<ID, Vehicle__c> mapRelatedVehicles = new Map<ID, Vehicle__c>();
    
    if(idSet.size() > 0){
    mapRelatedVehicles = new Map<Id, Vehicle__c>([Select ID, Name, Vehicle_Identification_Number__c From Vehicle__c WHERE ID in: idSet]);
    }
    
    for (Case c : vids) {
        if (c.Vehicle_Name__c == null)
            c.VIN__c = null;
        else {
            Vehicle__c v = mapRelatedVehicles.get(c.Vehicle_Name__c);
            c.VIN__c = v.Vehicle_Identification_Number__c;
        }
    }
    
    //Link Vin__c to Vehicle. Text_Util.linkVehiclesByVIN() also creates new Vehicles - use it with care
    Map<String, Vehicle__c> vehicleMap = Text_Util.linkVehiclesByVIN(vinSet, null);
    for (Case c : vins) {
        if (c.VIN__c == null || !vehicleMap.containsKey(c.VIN__c))
            c.Vehicle_Name__c = null;
        else
            c.Vehicle_Name__c = vehicleMap.get(c.VIN__c).Id;
    }
    
    //------------------------------------------------------>
    //Restrictions on buyback
    //------------------------------------------------------>
    if (Trigger.isUpdate) {
        List<Case> noBuybacks = new List<Case>();
        for (Case c: Trigger.new) {
            Case oldCase = Trigger.oldMap.get(c.ID);
            if (oldCase.Buyback__c != null && oldCase.Buyback__c != c.Buyback__c)
                c.addError('You can not modify Buyback field.');
            
            //changing vehicle info when there was a buyback
            if (oldCase.Buyback__c != null) {
                if (oldCase.Vehicle_Name__c != c.Vehicle_Name__c)
                    c.addError('You can not change Vehicle info if the case is associated with a buyback.');
            }
            
            if (c.Buyback_Restriction__c > 0 && c.Buyback__c == null && c.Vehicle_Name__c != null)
                noBuybacks.add(c);

			//2.6 Vladimir Martynenko 07/07/2015 Add logic for reopen Case if Case_Dealer_Disposition__c equals to REJECTED or CACHE and GUID is not null
            //&& c.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'MCC')			 
			if(Trigger.isBefore){
				if(c.Status == 'Closed' && (c.Case_Dealer_Disposition__c == 'CACHE' || c.Case_Dealer_Disposition__c == 'REJECTED')  && c.Case_GUID__c != null){
					c.Status = 'Open';
				}
			}
        }

		

        //Update Buyback__c field if applicable
        if (noBuybacks.size() > 0) {
            for (Buyback__c b : [Select b.Id, b.Case__c From Buyback__c b Where Case__c in: noBuybacks]) {
                Case c = Trigger.newMap.get(b.Case__c);
                c.Buyback__c = b.ID;
            }
        }
    }
    
    // Clear Shared_With__c for cases that are closed.
    for (Case c: Trigger.new) {
        if (c.Status == 'Closed' && c.Shared_With__c != null && c.Shared_With__c != '') {
            c.Shared_With__c = null;
        }
        
         // Link DPIC cases to related Vehicle__c records
        if (c.recordTypeId == dpicRTId && c.VIN__c != null && c.Vehicle_name__c == null) {
            dpicLookupVins.put(c.VIN__c, c);
        }
    }

    // Link DPIC cases to related Vehicle__c records
   /* for (Case c: Trigger.new) {
        if (c.recordTypeId == dpicRTId && c.VIN__c != null && c.Vehicle_name__c == null) {
            dpicLookupVins.put(c.VIN__c, c);
        }
    }Copied this statement in above for loop - Vivek*/
    
    if(dpicLookupVins.size() > 0){
    List<Vehicle__c> vehicles = [select id, Vehicle_Identification_Number__c
                                 from Vehicle__c
                                 where Vehicle_Identification_Number__c in :dpicLookupVins.keySet()];

    for (Vehicle__c vehicle: vehicles) {
        Case c = dpicLookupVins.get(vehicle.Vehicle_Identification_Number__c);
        if (c != null) {
            c.Vehicle_Name__c = vehicle.Id;
        }
    }
    }

    // For VCS Support cases, validate them against the VCS Validation data in the Code__c table.
    // Errors will be added to any cases that do not pass the validation.
    List<Case> vcsCases = new List<Case>();
    String vcsrtype = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'VCS Support');
    for (Case c: Trigger.new) {
        if (c.RecordTypeId == vcsrtype){    //'012F0000000yFNi') {
            vcsCases.add(c);
        }
    }
    
    if(vcsCases.size() > 0){
    CaseClass.validateVCSEscalations(vcsCases);
    }
    
    // Close VCS Alert Cases where all steps are completed or certain 'customer declined' values
    // are selected.  Ensure that VCS Enrollment Alert cases cannot be closed while TCU_Activation_Status__c
    // is false.
    //String EnrollmentAlertId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Enrollment Alert');
    for (Integer count = 0; count < Trigger.new.size(); count++) {
        Case c = Trigger.new[count];
        if (c.recordTypeId == EnrollmentAlertId) {
            Case oldCase = null;
            if (Trigger.isUpdate) {
                oldCase = Trigger.old[count];
            }

            if (c.Status != 'Closed' && c.TCU_Activation_Status__c == true) {
                if ((c.IC_Subscription_Status__c == true && c.IPA_Subscription_Status__c == true) ||
                    (c.Customer_Declined__c == 'Customer will enroll') ||
                    (c.Customer_Declined__c == 'Customer enrolled') ||
                    (c.Customer_Declined__c == 'Customer not interested')) {

                    c.Status = 'Closed';
                    c.Remove_Dealer_Sharing__c = true;
                    c.Customer_Declined__c = 'System Closed';
                }
            } else if (c.Status == 'Closed' && c.TCU_Activation_Status__c == false) {
                if (Trigger.isInsert || (Trigger.isUpdate && (oldCase.Status != 'Closed' || oldCase.TCU_Activation_Status__c != false))) {
                    c.addError('Enrollment Alert case cannot be closed while TCU Activation Status is false.');
                }
            }
        }
    }
    
    Map<String,Account> customerIdMap = new Map<String,Account>();
    if(customerIds.size() > 0){
    for (Account acct: [select Id, PersonContactId, Customer_Id__c from Account where customer_id__c in :customerIds]) {
        customerIdMap.put(acct.Customer_Id__c, acct);
    }
    }
    
    Map<String,Account> dealerIdMap = new Map<String,Account>();
    if(dealerExternalIds.size() > 0)
    for (Account acct: [select Id, Dealer_External_Id__c from Account where RecordType.Name = 'Dealer' and Dealer_External_Id__c in :dealerExternalIds]) {
        dealerIdMap.put(acct.Dealer_External_Id__c, acct);
    }

    Map<String,Vehicle__c> vehicleIdMap = new Map<String,Vehicle__c>();
    if(vehicleVINs.size() > 0){
    for (Vehicle__c vehicle: [select Id, Vehicle_Identification_Number__c from Vehicle__c where Vehicle_Identification_Number__c in :vehicleVINs]) {
        vehicleIdMap.put(vehicle.Vehicle_Identification_Number__c, vehicle);
    }
    }
    
    for (Case c: Trigger.new) {
        // Set Follow Up Date so it will not be before createddate due to Pacific time vs GMT issue.
        if (c.RecordTypeId == salesAndServiceRTId) {
            c.Follow_Up_Date__c = Datetime.now().dateGMT();
        }
        if (c.RecordTypeId == salesAndServiceRTId && c.AccountId == null && c.Contact_Id__c != null) {
            Account acct = customerIdMap.get(c.Contact_Id__c);
            if (acct != null) {
                c.AccountId = acct.Id;
                c.ContactId = acct.PersonContactId;
            }
        }
        if (c.RecordTypeId == salesAndServiceRTId && c.Vehicle_Name__c == null && c.VIN__c != null) {
            Vehicle__c vehicle = vehicleIdMap.get(c.VIN__c);
            if (vehicle != null) {
                c.Vehicle_Name__c = vehicle.Id;
            }
        }
        if (c.RecordTypeId == salesAndServiceRTId && c.Servicing_Dealer__c == null && c.Dealer_Number__c != null) {
            Account acct = dealerIdMap.get(c.Dealer_Number__c + System.Label.Dealer_USA);
            if (acct != null) {
                c.Servicing_Dealer__c = acct.Id;
            }
        }
        
        if(Trigger.isInsert){
        	if(c.RecordTypeId == t5RTypeId || c.RecordTypeId == caEmailNissanRTypeId ||  c.RecordTypeId == caEmailInfinitiRTypeId ||
        		 c.RecordTypeId == caSalesServRTypeId || c.RecordTypeId == dtuRTypeId || c.RecordTypeId == CArecordTypeId){
        		if(Datetime.now().format('EEEE') == 'Friday'){
        			c.Follow_Up_Date__c = Date.today().addDays(3);
        		}
        		if(Datetime.now().format('EEEE') == 'Saturday'){
        			c.Follow_Up_Date__c = Date.today().addDays(2);
        		}
        		if(!(Datetime.now().format('EEEE') == 'Saturday' || Datetime.now().format('EEEE') == 'Friday')){
        			c.Follow_Up_Date__c = Date.today().addDays(1);
        		}
        	}
        	
        }
    }
    
    //Techline stuff
    //if (Trigger.new.size() == 1) {
        
        //String techlineId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'TECH LINE Cases');
    
        for (Case c: Trigger.new) {
            if (c.RecordTypeId == techLineRecordTypeId) {
                //Set the Dealer Region Code
                //Adding this line as it is in PROD as of 8/27
                if (c.Dealer__c != null) {
                
                    if (c.Dealer_Region_Code_Form__c != null) {
                        c.DealerRegion_Code__c = c.Dealer_Region_Code_Form__c;
                    }
                }
                
                //Set the Heads Up date 
                if (c.Critical_Status_Flag__c && c.Heads_Up_Date__c == null) {
                    c.Heads_Up_Date__c = Date.today();
                }
                
                //Close the Case if the Issue Type is Mini
                if (c.Issue_Type__c == 'MINI') {
                    c.Status = 'Closed';
                }
                
                //Set the In Service Date
                //Adding this line as it is in PROD as of 8/27
                if (c.Vehicle_Name__c != null) {
                
                    if (c.Vehicle_In_Service_Date__c != null) {
                        c.In_Service_Date__c = c.Vehicle_In_Service_Date__c;
                    }
                }
                
                //Set the follow up date
                if (Trigger.isInsert || c.AssignmentLevel__c != Trigger.oldMap.get(c.ID).AssignmentLevel__c) {
                    if (c.AssignmentLevel__c != null && c.AssignmentLevel__c.contains('|')) {
                        List<String> codes = c.AssignmentLevel__c.split('|');
                        
                        Integer i = 0;
                        DateTime nextDay;
                        DateTime now = DateTime.now();
                        List<Date> next7WorkableDays = new List<Date>();
                        while (next7WorkableDays.size() < 7) {
                            i++;
                            nextDay = now.addDays(i);
                            if (nextDay.format('EEEE') != 'Saturday' && 
                                nextDay.format('EEEE') != 'Sunday') {
                                next7WorkableDays.add(nextDay.date());  
                            }
                        } 
                        
                        if (codes[1] == '1' || codes[1] == '2' || codes[1] == '3' || codes[1] == '6' ) {
                            c.Follow_Up_Date__c = next7WorkableDays[0];
                        }
                        else if (codes[1] == '4') {
                            c.Follow_Up_Date__c = next7WorkableDays[3];
                        }
                        else if (codes[1] == '5') {
                            c.Follow_Up_Date__c = next7WorkableDays[4];
                        }
                        else if (codes[1] == '7' || codes[1] == '8') {
                            c.Follow_Up_Date__c = next7WorkableDays[6];
                        }
                    }
                }
                /* This is not in PROD as of 8/27 , commenting for deployment 
                
                    //When the DTS is checked, the Field Inspection Indicator also
                    //needs to be checked
                    if (c.DTS_Notification__c) {
                        c.Field_Inspection_Indicator__c = true;
                    }
                */
                
            }
        }  
    //}
    
    /*** 2.0 move cases from DQR No Phone # Queue ***/    
    for(Case c : Trigger.new){
    //Move Cases that were updated with Phone numbers from the DQR No Phone # queue
    	if(c.OwnerId == '00GF0000002JDZk' && (c.Home_Phone__c != null || c.Account.PersonHomePhone != null ||
	        c.Work_Phone__c != null || c.Mobile_Phone__c != null) && Trigger.isUpdate == true){
	        
	        c.OwnerId = '005A0000001Y7Ek';
        
        }
        
       // Set DTS Inspection Date  // Combined for loops - vivek
      if (c.RecordtypeId == CArecordTypeId || c.RecordtypeId == techLineRTypeId ||
           c.RecordtypeId == techLineRecordTypeId) {
           
          if(trigger.IsUpdate){
            Case oldCase2 = trigger.oldMap.get(c.Id);
             if (oldcase2.DTS_Field_Inspection__c == null && c.DTS_Field_Inspection__c != null) {
                   c.DTS_Inspection_Date_Set__c = system.now();
             }
           }
       }
    }
    
    //2.3 - Anna Koseykina 19/12/2014 Add logic for Date fields for indicators (Fire, Rollover, Injury, Sent to Legal, Property Damage, Goodwill Offered)
    TREAD_Codes_Logic__c treadCodeSettings = TREAD_Codes_Logic__c.getOrgDefaults();
    if(treadCodeSettings == null || treadCodeSettings.Calculate_TREAD__c == null || treadCodeSettings.User_ID_not_Fire__c == null){
        treadCodeSettings = new TREAD_Codes_Logic__c();         
        treadCodeSettings.CasesTypes__c = 'CA,CA Closed Case,T5,CA Email Infiniti,CA Email Nissan,CA Sales & Service';
        treadCodeSettings.Calculate_TREAD__c = true;
        treadCodeSettings.User_ID_not_Fire__c = '005A0000001Y7Ek'; //Managed Services ID
        insert treadCodeSettings;
        treadCodeSettings = TREAD_Codes_Logic__c.getOrgDefaults();
    }
    Set<String> caCases = new Set<String> ();
    try {    
        for(String s : treadCodeSettings.CasesTypes__c.split(',')){
            caCases.add(rtInfosByName.get(s.trim()).getRecordTypeId());
        }
        //caCases.addAll(treadCodeSettings.CasesTypes__c.split(','));
    } catch(Exception e) {
    }     
      
    Set<String> usersNotExecute = new Set<String> ();
    try {
        usersNotExecute.addAll(treadCodeSettings.User_ID_not_Fire__c.split(','));
    } catch(Exception e) {
    }

    //Map<Id, RecordType> recTypes = new Map<Id, RecordType>([SELECT id, name FROM RecordType WHERE id IN :caseRecordTypes.values()]);
    for (Case c : Trigger.New) {

        if(treadCodeSettings.Calculate_TREAD__c == true && !usersNotExecute.contains(UserInfo.getUserId().substring(0, 15))){
            if(caCases.contains(c.RecordTypeId)){
                //create case with all indicators false to use it if trigger is insert
                Case oldCase = new Case(Fire_Indicator__c = false, 
                                        Rollover_Indicator__c = false, 
                                        Injury_Indicator__c = false,
                                        Sent_to_Legal_Indicator__c = false, 
                                        Property_Damage_Indicator__c = false,
                                        Goodwill_Offered__c = false);
                if(trigger.isUpdate){
                    oldCase = trigger.oldMap.get(c.Id);
                }

                if(c.Fire_Indicator__c == true && oldCase.Fire_Indicator__c != c.Fire_Indicator__c && c.Fire_Date__c == null){            
                    c.Fire_Date__c = Date.today();
                }else if(c.Fire_Indicator__c == false){
                    c.Fire_Date__c = null;
                }
            
                if(c.Rollover_Indicator__c == true && oldCase.Rollover_Indicator__c != c.Rollover_Indicator__c && c.Rollover_Date__c == null){
                    c.Rollover_Date__c = Date.today();
                }else if(c.Rollover_Indicator__c == false){
                    c.Rollover_Date__c = null;
                }
            
                if(c.Injury_Indicator__c == true && oldCase.Injury_Indicator__c != c.Injury_Indicator__c && c.Injury_Date__c == null)
                {
                    c.Injury_Date__c = Date.today();
                }else if(c.Injury_Indicator__c == false){
                    c.Injury_Date__c = null;
                }
                
                if(c.Sent_to_Legal_Indicator__c == true && oldCase.Sent_to_Legal_Indicator__c != c.Sent_to_Legal_Indicator__c && c.Sent_to_Legal_Date__c == null)
                {
                    c.Sent_to_Legal_Date__c = Date.today();
                }else if(c.Sent_to_Legal_Indicator__c == false){
                    c.Sent_to_Legal_Date__c = null;
                }
                
                if(c.Property_Damage_Indicator__c == true && oldCase.Property_Damage_Indicator__c != c.Property_Damage_Indicator__c && c.Property_Damage_Date__c == null)
                {
                    c.Property_Damage_Date__c = Date.today();
                }else if(c.Property_Damage_Indicator__c == false){
                    c.Property_Damage_Date__c = null;
                }
                
                if(c.Goodwill_Offered__c == true && oldCase.Goodwill_Offered__c != c.Goodwill_Offered__c && c.Goodwill_Offered_Date__c == null)
                {
                    c.Goodwill_Offered_Date__c = Date.today();
                }else if(c.Goodwill_Offered__c == false){
                    c.Goodwill_Offered_Date__c = null;
                } 
            }
        }
        
    }
   
    
}