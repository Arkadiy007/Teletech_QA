/**********************************************************************
Name: VehicleRetailSale_After 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This trigger is associated with the Vehicle_Retail_Sale__c object 
and calls the createVehicleOwnership method defined in the
VehicleRetailSaleClass class. This trigger runs after new Vehicle 
Retail Sale records are inserted into the database. It Creates new 
Vehicle_Ownership_History__c Records.

Related Apex Class: VehicleRetailSaleClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Biswa Ray 01/13/2011 Created
1.1 - Biswa Ray 01/18/2011 Trigger Invoke Criteria Changed. It fires 
                           Only on the after Insert event.
1.2 - Biswa Ray 02/22/2011 Updated the Code to avoid the governor limit as per comments made in JIRA Issue - RONETELETECH-131 
1.3 - Bryan Fry 03/07/2011 Fixed bug with vOHistory variable not getting cleared
                           out between rows in multiple row load.
1.4 - M. Esmail 08/17/2011 Fixed a defect DE7 that updates the related VOH records having null End_Date with the
                           VRS.Purchase_Date.  Fixed USR369 that fills End_Date when Rewind indicator is checked.                                                   
***********************************************************************/

trigger VehicleRetailSale_After on Vehicle_Retail_Sale__c (after insert, after update) {
    
    Vehicle_Ownership_History__c vOHistory = null;
    Set<Id> accIdSet = new Set<Id>();
    Map<Id, Account> accMap = new Map<Id,Account>();
    List<Id> vrsIdList = new List<Id>();
    List<Vehicle_Ownership_History__c> vOHistoryInsertList = new List<Vehicle_Ownership_History__c>();
    List<Vehicle_Ownership_History__c> vOHistoryUpdateList = new List<Vehicle_Ownership_History__c>();
    Map<Id,Vehicle_Retail_Sale__c> vrsMap = new Map<Id,Vehicle_Retail_Sale__c>();

    // Pull out lists of Ids needed from Trigger and create Map of Id to VRS.
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        accIdSet.add(Trigger.new[i].Owner_Id__c);
        vrsIdList.add(Trigger.new[i].Id);
        vrsMap.put(Trigger.new[i].Id, Trigger.new[i]);
    }
    
    // Use Vehicle_Retail_Sale__c ids to get a List of Vehicle_Ownership_History__c
    // records that exist for them that need to be updated rather than inserted.
    // Then get a Set of the Vehicle_Retail_Sale__c ids that exist there so we
    // can easily find which exist and which do not.
    List<Vehicle_Ownership_History__c> vohList = [select Id, Vehicle_Retail_Sale_Id__c, Vehicle__c
                                                  from Vehicle_Ownership_History__c
                                                  where Vehicle_Retail_Sale_Id__c in :vrsIdList];
                                            
    // Use Vehicle_Retail_Sale__c ids to get a List of Vehicle_Identification_Number__c from Vehicle objects
    // that is used to map back to VOH object to get the related records list.                                      
    List<Vehicle_Ownership_History__c> vohListEndDate = [select Id, End_Date__c, Vehicle_Retail_Sale_Id__c, Vehicle__c
                                                        from Vehicle_Ownership_History__c
                                                        where End_Date__c = null 
                                                        and Vehicle__c in (select Vehicle_Identification_Number__c
                                                                            from Vehicle_Retail_Sale__c
                                                                            where Id in :vrsIdList)];                                              
 
    Map<Id, Vehicle_Ownership_History__c> vrsIdInVohMap = new Map<Id, Vehicle_Ownership_History__c>();
    for (Vehicle_Ownership_History__c voh : vohList) {
        if (voh.Vehicle_Retail_Sale_Id__c != null)
            vrsIdInVohMap.put(voh.Vehicle_Retail_Sale_Id__c, voh);
    }
    
    // Create Account Map from List
    accMap = new Map<Id,Account>([select id,Name from Account where id in:accIdSet]);
    
    // Iterate over the list of records being processed in the trigger and
    // update VOH.End_Date with VRS.Purchase_Date of related records if End_Date is blank and
    // insert Vehicle Ownership records accordingly
    // Insert Cases, created for every Vehicle Retail Sale
    List<Case> casesToBeCreated = new List<Case>();
    String saleServiceRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Sales & Service Record Type');
    String dealerAccountRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
    Welcome_Calls__c welcomeCallsSetting = Welcome_Calls__c.getOrgDefaults();
        if(welcomeCallsSetting == null || welcomeCallsSetting.Description__c == null || welcomeCallsSetting.Subject_no_email__c == null || 
            welcomeCallsSetting.Subject_with_email__c == null || welcomeCallsSetting.Purchase_Date__c == null || welcomeCallsSetting.Close_Cases__c == null || 
            welcomeCallsSetting.Create_Cases__c == null || welcomeCallsSetting.Purchase_End_Date__c == null || welcomeCallsSetting.Make__c == null || 
            welcomeCallsSetting.Model_Line__c == null || welcomeCallsSetting.Model_Year__c == null || welcomeCallsSetting.Ignored_Sale_Type__c == null || welcomeCallsSetting.Subject_from_Hot_Alert__c == null){

            if(welcomeCallsSetting == null){
                welcomeCallsSetting = new Welcome_Calls__c();
            }
            welcomeCallsSetting.Description__c = 'Welcome Call';
            welcomeCallsSetting.Subject_no_email__c = 'Revana SSI Welcome Call -  without Email';
            welcomeCallsSetting.Subject_with_email__c = 'Revana SSI Welcome Call - with Email';
            welcomeCallsSetting.Subject_from_Hot_Alert__c = 'Revana SSI Welcome Call';
            welcomeCallsSetting.Purchase_Date__c = Date.newInstance(2015, 4, 1);
            welcomeCallsSetting.Purchase_End_Date__c = Date.newInstance(2015, 5, 15);
            welcomeCallsSetting.Close_Cases__c = true;
            welcomeCallsSetting.Create_Cases__c = true;
            welcomeCallsSetting.Make__c = 'Nissan';
            welcomeCallsSetting.Model_Line__c = 'Altima,Murano,Pathfinder,Versa Sedan,Rogue,Sentra';
            welcomeCallsSetting.Model_Year__c = '2015';
            welcomeCallsSetting.Ignored_Sale_Type__c = 'Service Loaner';
            upsert welcomeCallsSetting;
            welcomeCallsSetting = Welcome_Calls__c.getOrgDefaults();
        }

    List<String> modelLine = welcomeCallsSetting.Model_Line__c.split(',');
    Set<String> ignoredSaleTypes = new Set<String>();
    ignoredSaleTypes.addAll(welcomeCallsSetting.Ignored_Sale_Type__c.split(','));
    List<Id> vehicleIds = new List<Id>();
    List<Id> ownerIds = new List<Id>();
    Date createdDate = Date.newInstance(2015,3,15); 
    String vrsRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Vehicle_Retail_Sale__c.SObjectType, 'RDR');
    List <Group > cccGroup = [select Id, Name from Group where Name = :'CCC Campaign Queue' and Type = 'Queue'];
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if(trigger.new[i].Purchase_Date__c >= welcomeCallsSetting.Purchase_Date__c && trigger.new[i].Purchase_Date__c <= welcomeCallsSetting.Purchase_End_Date__c &&
           (!ignoredSaleTypes.contains(trigger.new[i].Sale_Type__c) || trigger.new[i].Sale_Type__c == null || trigger.new[i].Sale_Type__c == '') && 
           trigger.new[i].createdDate >= createdDate && trigger.new[i].RecordTypeId == vrsRecordTypeId){
            if(trigger.new[i].Vehicle_Identification_Number__c != null){
                vehicleIds.add(trigger.new[i].Vehicle_Identification_Number__c);
            }
            if(trigger.new[i].Owner_Id__c != null){
                ownerIds.add(trigger.new[i].Owner_Id__c);
            }
            if(trigger.new[i].Selling_Dealer_Name__c != null){
                ownerIds.add(Trigger.new[i].Selling_Dealer_Name__c);
            }
        }
    }
    Map<Id, Account> accounts = new Map<Id,Account>([SELECT Id, Name, RegionName__c, recordTypeId, ShippingStreet, PersonContactId, PersonEmail, Alternate_Email__c, Dealer_Code__c, firstName, lastName, personMailingStreet, personMailingCity, personMailingState, personMailingPostalCode, PersonHomePhone, PersonMobilePhone, PersonOtherPhone FROM Account WHERE ID IN :ownerIds]);
    Map<Id,Vehicle__c> vehciles = new Map<Id,Vehicle__c>([SELECT Id, Make_Name__c, Model_Year__c, Model_Line_Name__c FROM Vehicle__c WHERE Make_Name__c = :welcomeCallsSetting.Make__c AND Model_Year__c = :welcomeCallsSetting.Model_Year__c AND Model_Line_Name__c IN :modelLine AND Id IN :vehicleIds]);
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        for (Vehicle_Ownership_History__c vohEnd : vohListEndDate) {
            if (vohEnd.Vehicle__c == Trigger.new[i].Vehicle_Identification_Number__c
                && vohEnd.Vehicle_Retail_Sale_Id__c != Trigger.new[i].Id) //checking to make sure we do not update the new record just inserted.
            {
                vohEnd.End_Date__c = Trigger.new[i].Purchase_Date__c;
                vOHistoryUpdateList.add(vohEnd);
            }
        }
           
        vOHistory = null;
        if (!vrsIdInVohMap.keySet().contains(Trigger.new[i].Id)) {
            vOHistory = VehicleRetailSaleClass.createVehicleOwnership(Trigger.new[i],accMap.get(Trigger.new[i].Owner_Id__c));
            if (vOHistory != null) {
                if (Trigger.new[i].Rewind_Indicator__c) { //if rewind indicator is marked, then add end_date. 
                    vOHistory.End_Date__c = date.TODAY();
                }
                vOHistoryInsertList.add(vOHistory);
            }
        } else {
            vOHistory = vrsIdInVohMap.get(Trigger.new[i].Id);
            if (vOHistory != null) {
                if (Trigger.new[i].Rewind_Indicator__c) { //if rewind indicator is marked, then add end_date. 
                    vOHistory.End_Date__c = date.TODAY();
                    vOHistoryUpdateList.add(vOHistory);
                }
            }
        }       
                
        if(Trigger.new[i].Purchase_Date__c >= welcomeCallsSetting.Purchase_Date__c && trigger.isInsert && welcomeCallsSetting.Create_Cases__c == true
         && vehciles.keySet().contains(trigger.new[i].Vehicle_Identification_Number__c) && trigger.new[i].Purchase_Date__c <= welcomeCallsSetting.Purchase_End_Date__c
         && !ignoredSaleTypes.contains(trigger.new[i].Sale_Type__c)){
            Case caseItem = new Case();
            
            if(accounts.get(Trigger.new[i].Owner_Id__c) != null && ((accounts.get(Trigger.new[i].Owner_Id__c).PersonEmail != null && (accounts.get(Trigger.new[i].Owner_Id__c).PersonEmail.length() > 0)) || (accounts.get(Trigger.new[i].Owner_Id__c).Alternate_Email__c != null && accounts.get(Trigger.new[i].Owner_Id__c).Alternate_Email__c.length() > 0))){
                caseItem.Subject = welcomeCallsSetting.Subject_with_email__c;
                caseItem.Survey_Type__c = 'Sales Priority D';
                caseItem.Status = 'Open';
            }else{
                caseItem.Subject = welcomeCallsSetting.Subject_no_email__c;
                caseItem.Survey_Type__c = 'Sales Priority E';               
                caseItem.Status = 'Open';
            }

            caseItem.Description = welcomeCallsSetting.Description__c;
            caseItem.Contact_ID__c = Trigger.new[i].External_Owner_Id__c;
            caseItem.AccountId = Trigger.new[i].Owner_Id__c;
            if(accounts.get(Trigger.new[i].Owner_Id__c) != null){
                caseItem.contactId = accounts.get(Trigger.new[i].Owner_Id__c).PersonContactId;
            }
            if (cccGroup.size() > 0) {
                caseItem.OwnerId = cccGroup.get(0).Id;
            }
            caseItem.origin = 'Data Load';
            caseItem.Status = 'Item Created';
            caseItem.Priority = 'Low';
            caseItem.Business_Unit__c = 'Nissan';
            caseItem.vin__c = Trigger.new[i].VIN__c;
            caseItem.Vehicle_Name__c = Trigger.new[i].Vehicle_Identification_Number__c;
            if(accounts.get(Trigger.new[i].Owner_Id__c) != null){
                caseItem.First_Name__c = accounts.get(Trigger.new[i].Owner_Id__c).firstName;
                caseItem.Last_Name__c = accounts.get(Trigger.new[i].Owner_Id__c).lastName;
                caseItem.Mailing_Street__c = accounts.get(Trigger.new[i].Owner_Id__c).personMailingStreet;
                caseItem.Mailing_Street_2__c = accounts.get(Trigger.new[i].Owner_Id__c).personMailingStreet;
                caseItem.Mailing_City__c = accounts.get(Trigger.new[i].Owner_Id__c).personMailingCity;
                caseItem.Mailing_State__c = accounts.get(Trigger.new[i].Owner_Id__c).personMailingState;
                caseItem.Mailing_Zip_Code__c = accounts.get(Trigger.new[i].Owner_Id__c).personMailingPostalCode;
                caseItem.Home_Phone__c = accounts.get(Trigger.new[i].Owner_Id__c).PersonHomePhone;
                caseItem.Mobile_Phone__c = accounts.get(Trigger.new[i].Owner_Id__c).PersonMobilePhone;
                caseItem.Work_Phone__c = accounts.get(Trigger.new[i].Owner_Id__c).PersonOtherPhone; //no work phone
                caseItem.Email2__c = accounts.get(Trigger.new[i].Owner_Id__c).PersonEmail;
                caseItem.Alternate_Email__c = accounts.get(Trigger.new[i].Owner_Id__c).Alternate_Email__c;
            }
            caseitem.NNA_Net_Hot_Alert_Type__c = 'Welcome';         
            caseItem.event_Date__c = Trigger.new[i].Purchase_Date__c;           
            if(accounts.get(Trigger.new[i].Selling_Dealer_Name__c) != null && accounts.get(Trigger.new[i].Selling_Dealer_Name__c).recordTypeId.equals(dealerAccountRecordTypeId)){
                caseItem.dealer__c = Trigger.new[i].Selling_Dealer_Name__c;         
                caseItem.Dealer_Name__c = accounts.get(Trigger.new[i].Selling_Dealer_Name__c).name;
                caseItem.Region_d__c = accounts.get(Trigger.new[i].Selling_Dealer_Name__c).RegionName__c;
            }
            caseItem.recordTypeId = saleServiceRecordTypeId;
            caseItem.type = 'New Customer Welcome';
            casesToBeCreated.add(caseItem);
        }       
    }

    if(casesToBeCreated.size() > 0){
        insert casesToBeCreated;
    }
    // Update Vehicle Ownership Histories
    if (vOHistoryUpdateList.size() > 0) {
    Database.SaveResult[] dbResult = database.update(vOHistoryUpdateList, false);
    for (integer row = 0; row < vOHistoryUpdateList.size(); row++) {
        Vehicle_Ownership_History__c voh = vOHistoryUpdateList.get(row);
        Vehicle_Retail_Sale__c vrs = vrsMap.get(voh.Vehicle_Retail_Sale_Id__c);

        Database.SaveResult result = dbResult[row];
        if (!result.isSuccess()) {
            Database.Error err = dbResult[row].getErrors()[0];
            vrs.addError('Update failed for Vehicle Ownership History ' + voh.Id + ': ' + err.getMessage());
        }
    }
    }

    // Insert Vehicle Ownership Histories
    if (vOHistoryInsertList.size() > 0) {
    Database.SaveResult[] dbResult = database.insert(vOHistoryInsertList, false);
    for (integer row = 0; row < vOHistoryInsertList.size(); row++) {
        Vehicle_Ownership_History__c voh = vOHistoryInsertList.get(row);
        Vehicle_Retail_Sale__c vrs = vrsMap.get(voh.Vehicle_Retail_Sale_Id__c);

        Database.SaveResult result = dbResult[row];
        if (!result.isSuccess()) {
            Database.Error err = dbResult[row].getErrors()[0];
            vrs.addError('Insert failed for Vehicle Ownership History related to Vehicle Retail Sale ' + vrs.Id + ': ' + err.getMessage());
        }
    }
    }
}