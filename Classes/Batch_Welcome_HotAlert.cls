/**********************************************************************
Name: Batch_Welcome_HotAlert
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class selects all the VRS records and creates new Cases for it
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina     5/6/2015 Created
***********************************************************************/
//Batch_Welcome_HotAlert batchJob = new Batch_Welcome_HotAlert(welcomeCallsSettings);
//Database.executeBatch(batchJob);
global class Batch_Welcome_HotAlert implements Database.Batchable<sObject> { 
    Welcome_Calls__c welcomeCallsSettings; 
    Set<String> ignoredSaleTypes;
    String saleServiceRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Sales & Service Record Type');
    String dealerAccountRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'); 
    String vrsRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Vehicle_Retail_Sale__c.SObjectType, 'RDR');
    List <Group > cccGroup = [select Id, Name from Group where Name = :'CCC Campaign Queue' and Type = 'Queue'];

    global Batch_Welcome_HotAlert(){
        welcomeCallsSettings = getSettings();
    }
    global String query;

    global Database.QueryLocator start(Database.BatchableContext BC){
        ignoredSaleTypes = new Set<String>();       
        ignoredSaleTypes.addAll(welcomeCallsSettings.Ignored_Sale_Type__c.split(','));
        
        Date startDate = date.valueOf(welcomeCallsSettings.Purchase_Date__c);
        Date endDate = date.valueOf(welcomeCallsSettings.Purchase_End_Date__c); 
        Date createdDate = Date.newInstance(2015,3,15);
        List<String> modelLine = welcomeCallsSettings.Model_Line__c.split(',');
        String make = welcomeCallsSettings.Make__c;
        String modelYear = welcomeCallsSettings.Model_Year__c;
        String query = 'SELECT ID, Purchase_Date__c, Vehicle_Identification_Number__c, Selling_Dealer_Name__r.RegionName__c, Selling_Dealer_Name__r.name, Selling_Dealer_Name__r.recordTypeId, Owner_Id__r.personMailingCity, Owner_Id__r.personMailingState, Owner_Id__r.personMailingPostalCode, Owner_Id__r.PersonHomePhone, Owner_Id__r.PersonMobilePhone, Owner_Id__r.PersonOtherPhone, Owner_Id__r.personMailingStreet, Owner_Id__r.lastName, Owner_Id__r.PersonContactId, Owner_Id__r.firstName, Owner_Id__r.Alternate_Email__c, Owner_Id__c, Owner_Id__r.PersonEmail, External_Owner_Id__c, VIN__c, Selling_Dealer_Name__c, Sale_Type__c FROM Vehicle_Retail_Sale__c '
                        + 'WHERE Purchase_Date__c >= :startDate'
                        + ' AND Purchase_Date__c <= :endDate'
                        + ' AND Sale_Type__c NOT IN :ignoredSaleTypes'
                        + ' AND CreatedDate >= :createdDate'
                        + ' AND RecordTypeId = :vrsRecordTypeId'
                        + ' AND Vehicle_Identification_Number__r.Make_Name__c = :make'
                        + ' AND Vehicle_Identification_Number__r.Model_Year__c = :modelYear'
                        + ' AND Vehicle_Identification_Number__r.Model_Line_Name__c IN :modelLine';

        return Database.getQueryLocator(query);     
    }
    
    global void execute(Database.BatchableContext BC, List<Vehicle_Retail_Sale__c> vrs) {
       if(welcomeCallsSettings.Create_Cases__c == true){         
            
            List<Case> casesToBeCreated = new List<Case>();
            List<Id> vehicleIds = new List<Id>();
            List<Id> ownerIds = new List<Id>();
            welcomeCallsSettings = getSettings();

            for(Vehicle_Retail_Sale__c vrsItem : vrs){ 
                if(welcomeCallsSettings.Create_Cases__c == true){         
                    Case caseItem = new Case();
            
                    if(vrsItem.Owner_Id__c != null && ((vrsItem.Owner_Id__r.PersonEmail != null && vrsItem.Owner_Id__r.PersonEmail.length() > 0) || (vrsItem.Owner_Id__r.Alternate_Email__c != null && vrsItem.Owner_Id__r.Alternate_Email__c.length() > 0))){
                        caseItem.Subject = welcomeCallsSettings.Subject_with_email__c;                  
                        caseItem.Survey_Type__c = 'Sales Priority D';
                        caseItem.Status = 'Open';
                    }else{
                        caseItem.Subject = welcomeCallsSettings.Subject_no_email__c;
                        caseItem.Survey_Type__c = 'Sales Priority E';               
                        caseItem.Status = 'Open';
                    }

                    caseItem.Description = welcomeCallsSettings.Description__c;
                    caseItem.Contact_ID__c = vrsItem.External_Owner_Id__c;
                    caseItem.AccountId = vrsItem.Owner_Id__c;
                    if(vrsItem.Owner_Id__c != null){
                        caseItem.contactId = vrsItem.Owner_Id__r.PersonContactId;
                    }
                    if (cccGroup.size() > 0) {
                        caseItem.OwnerId = cccGroup.get(0).Id;
                    }
                    caseItem.origin = 'Data Load';
                    caseItem.Status = 'Item Created';
                    caseItem.Priority = 'Low';
                    caseItem.Business_Unit__c = 'Nissan';
                    caseItem.vin__c = vrsItem.VIN__c;
                    caseItem.Vehicle_Name__c = vrsItem.Vehicle_Identification_Number__c;
                    if(vrsItem.Owner_Id__c != null){
                        caseItem.First_Name__c = vrsItem.Owner_Id__r.firstName;
                        caseItem.Last_Name__c = vrsItem.Owner_Id__r.lastName;
                        caseItem.Mailing_Street__c = vrsItem.Owner_Id__r.personMailingStreet;
                        caseItem.Mailing_Street_2__c = vrsItem.Owner_Id__r.personMailingStreet;
                        caseItem.Mailing_City__c = vrsItem.Owner_Id__r.personMailingCity;
                        caseItem.Mailing_State__c = vrsItem.Owner_Id__r.personMailingState;
                        caseItem.Mailing_Zip_Code__c = vrsItem.Owner_Id__r.personMailingPostalCode;
                        caseItem.Home_Phone__c = vrsItem.Owner_Id__r.PersonHomePhone;
                        caseItem.Mobile_Phone__c = vrsItem.Owner_Id__r.PersonMobilePhone;
                        caseItem.Work_Phone__c = vrsItem.Owner_Id__r.PersonOtherPhone; //no work phone
                        caseItem.Email2__c = vrsItem.Owner_Id__r.PersonEmail;
                        caseItem.Alternate_Email__c = vrsItem.Owner_Id__r.Alternate_Email__c;
                    }
                    caseitem.NNA_Net_Hot_Alert_Type__c = 'Welcome';
                    caseItem.event_Date__c = vrsItem.Purchase_Date__c;
                    if(vrsItem.Selling_Dealer_Name__c != null && vrsItem.Selling_Dealer_Name__r.recordTypeId.equals(dealerAccountRecordTypeId)){
                        caseItem.dealer__c = vrsItem.Selling_Dealer_Name__c;            
                        caseItem.Dealer_Name__c = vrsItem.Selling_Dealer_Name__r.name;
                        caseItem.Region_d__c = vrsItem.Selling_Dealer_Name__r.RegionName__c;
                    }
                    caseItem.recordTypeId = saleServiceRecordTypeId;
                    caseItem.type = 'New Customer Welcome';
                    casesToBeCreated.add(caseItem);
                }
            }            
    
            if(casesToBeCreated.size() > 0){
                insert casesToBeCreated;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }

    private Welcome_Calls__c getSettings(){
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
        return welcomeCallsSetting;
    }
}