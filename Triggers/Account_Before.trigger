/**********************************************************************
Name: Account_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a new Account is created, fill in
Salesforce internal Ids by looking them up from
external ids provided.
 
Related Class : AccountClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 01/17/2011 Created
1.1 - Bryan Fry 01/18/2011 Added Dealer RecordType check
1.2 - Bryan Fry 01/19/2011 Added null check for Preferred_Dealer_Code__c
1.3 - Sonali bhardwaj 03/10/2011 Added code to update previous address fields.
1.4 - Bryan Fry 09/27/2011 Added Regional Staff population code
1.5 - Bryan Fry 10/09/2013 Get dealers by Dealer_External_Id__c to avoid
                           duplicate dealer code issue between USA and CAN
1.6 - William T 2/4/2014   Added code for privacy object reporting when 
                           privacy fields changed.    
1.7 - William T 3/18/2014  Added Profile check to ensure non-sysadmins are
                           the only users who append to Privacy_Reporting__c                       
                          
***********************************************************************/

trigger Account_Before on Account (before insert, before update) {
    Account oldAccount;
    Account newAccount;
    
    /** Set Preferred_Dealer_Id__c lookup from Preferred_Dealer_Code__c **/

    Set<String> dealerExternalIds = new Set<String>();
    Set<Id> dealerIds = new Set<Id>();
    
    // Get Dealer RecordType for Account object 
    Id dealerTypeId = '012A0000000OfI0IAK';
    
    // Construct a Set of Preferred_Dealer_Codes from the Accounts input through Trigger.new
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (Trigger.isUpdate)
            oldAccount = Trigger.old[i];
        newAccount = Trigger.new[i];

        if (newAccount.RecordTypeId != dealerTypeId) {
            if (Trigger.isInsert || (Trigger.isUpdate && oldAccount.Preferred_Dealer_Code__c != newAccount.Preferred_Dealer_Code__c)) {
                if (newAccount.Preferred_Dealer_Code__c != null) {
                    if (newAccount.PersonMailingCountry != null && newAccount.PersonMailingCountry.toUpperCase().startsWith('CAN')) {
                        dealerExternalIds.add(newAccount.Preferred_Dealer_Code__c + System.Label.Dealer_Canada);
                    } else {
                        dealerExternalIds.add(newAccount.Preferred_Dealer_Code__c + System.Label.Dealer_USA);
                    }
                }
            } else if (Trigger.isInsert || (Trigger.isUpdate && oldAccount.Preferred_Dealer_Id__c != newAccount.Preferred_Dealer_Id__c)) {
                if (newAccount.Preferred_Dealer_Id__c != null)
                    dealerIds.add(newAccount.Preferred_Dealer_Id__c);
            }
        }
    }
System.debug('dealer external ids = ' + dealerExternalIds);
    List<Account> dealersFromCodes = new List<Account>();
    if (!dealerExternalIds.isEmpty()) {
        dealersFromCodes = new List<Account>([select id, Dealer_Code__c, Dealer_External_Id__c
                                              from Account
                                              where Dealer_External_Id__c in :dealerExternalIds]);
    }

    List<Account> dealersFromIds = new List<Account>();
    if (!dealerIds.isEmpty()) {
        dealersFromIds = new List<Account>([select id, Dealer_Code__c
                                            from Account
                                            where Id in :dealerIds]);
    }
                                                   
    Map<String,Id> dealerExternalIdMap = new Map<String,Id>();
    for (Account dealer : dealersFromCodes) {
        dealerExternalIdMap.put(dealer.Dealer_External_Id__c, dealer.Id);
    }

    Map<Id,String> dealerIdMap = new Map<Id,String>();
    for (Account dealer : dealersFromIds) {
        dealerIdMap.put(dealer.Id, dealer.Dealer_Code__c);
    }
    
    // Loop through Accounts in Trigger.new and set the Preferred_Dealer_Id__c or Preferred_Dealer_Code__c for each
    String dealerExternalId;
    for (Account acct : Trigger.new) {
        if (newAccount.PersonMailingCountry != null && newAccount.PersonMailingCountry.toUpperCase().startsWith('CAN')) {
            dealerExternalId = acct.Preferred_Dealer_Code__c + System.Label.Dealer_Canada;
        } else {
            dealerExternalId = acct.Preferred_Dealer_Code__c + System.Label.Dealer_USA;
        }
        
        if (dealerExternalIds.contains(dealerExternalId))
            acct.Preferred_Dealer_Id__c = dealerExternalIdMap.get(dealerExternalId);
        else if (dealerIds.contains(acct.Preferred_Dealer_Id__c))
            acct.Preferred_Dealer_Code__c = dealerIdMap.get(acct.Preferred_Dealer_Id__c);
    }
    
    // When mailing address is updated, copy old address data to previous address fields and set
    // do not mail/undeliverable address fields to false.
    if (Trigger.isUpdate) {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            oldAccount = Trigger.old[i];
            newAccount = Trigger.new[i];
            if (oldAccount.isPersonAccount && newAccount.isPersonAccount) {
                if (oldAccount.PersonMailingStreet != newAccount.PersonMailingStreet ||
                    oldAccount.PersonMailingCity != newAccount.PersonMailingCity ||
                    oldAccount.PersonMailingPostalCode != newAccount.PersonMailingPostalCode ||
                    oldAccount.PersonMailingState != newAccount.PersonMailingState || 
                    oldAccount.PersonMailingCountry != newAccount.PersonMailingCountry) {
                        newAccount.Previous_Mailing_Street__c = oldAccount.PersonMailingStreet;
                        newAccount.Previous_Mailing_State__c = oldAccount.PersonMailingState;
                        newAccount.Previous_Mailing_City__c = oldAccount.PersonMailingCity;
                        newAccount.Previous_Mailing_Postal_Code__c = oldAccount.PersonMailingPostalCode;
                        newAccount.Previous_Mailing_Country__c = oldAccount.PersonMailingCountry;
                        newAccount.Undeliverable_Address_Indicator__c = false;
                        newAccount.Do_Not_Mail_Indicator__c = false;
                }
            }
        }
    }

    List<Privacy_Reporting__c> lstPrivacyInsert = new List<Privacy_Reporting__c>();   
    List<Error_Log__c> errors = new List<Error_Log__c>();
    Map<String, Schema.SObjectField> m = Schema.SObjectType.Account.fields.getMap(); 
    Privacy_Reporting__c newPrivacy;
    
    
    Profile thisProfile;
    String strProfile;
    thisprofile = [Select p.Name FROM Profile p where p.Id=:UserInfo.getProfileId() LIMIT 1];
    strProfile = thisProfile.Name;


    if (Trigger.isUpdate && strProfile != 'System Admin Integration') {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            oldAccount = Trigger.old[i];
            newAccount = Trigger.new[i];

            if (oldAccount.isPersonAccount && newAccount.isPersonAccount) {
               for(String field: m.keySet()){ 
               
                   if (field.contains('do_not_')) {
                       Datetime myDatetime = Datetime.now();

                      if(String.valueOf(newAccount.get(field)) != String.valueOf(oldAccount.get(field))){ // value has changed 
                            newPrivacy = new Privacy_Reporting__c();
                            newPrivacy.Account_Name__c = newAccount.FirstName + ' ' + newAccount.LastName;
                            newPrivacy.Do_Not_Contact_Type__c = m.get(field).getDescribe().getLabel();
                            newPrivacy.Edit_Date__c = myDatetime.format('M/d/yyyy h:mm');
                            newPrivacy.First_Name__c = newAccount.FirstName;
                            newPrivacy.Last_Name__c = newAccount.LastName;
                            newPrivacy.Last_Modified_By__c = newAccount.LastModifiedBy.Name;
                            newPrivacy.New_Value__c = String.valueOf(newAccount.get(field));
                            newPrivacy.Old_Value__c = String.valueOf(oldAccount.get(field));
                            newPrivacy.Person_Account_Email__c = newAccount.PersonEmail;
                            newPrivacy.Person_Account_Home_Phone__c = newAccount.PersonHomePhone;
                            newPrivacy.Person_Account_Mobile__c = newAccount.PersonMobilePhone;
                            newPrivacy.Person_Account_Work_Phone__c = newAccount.PersonOtherPhone;
                            newPrivacy.Person_Phone__c = newAccount.Phone;
                            newPrivacy.Record_Type__c = String.valueOf(newAccount.RecordTypeId);                            
                            newPrivacy.TMS_Contact_ID__c = newAccount.TMS_Customer_ID__c;
                            newPrivacy.Maritz_Contact_ID__c = newAccount.Customer_ID__c;
                            newPrivacy.PersonMailingStreet__c = newAccount.PersonMailingStreet;
                            newPrivacy.PersonMailingPostalCode__c = newAccount.PersonMailingPostalCode;
                            newPrivacy.PersonMailingCity__c = newAccount.PersonMailingCity;
                            newPrivacy.PersonMailingState__c = newAccount.PersonMailingState;
                            newPrivacy.Alternate_Email__c = newAccount.Alternate_Email__c;
                            newPrivacy.Country__c = newAccount.PersonMailingCountry;
                            newPrivacy.Username__c = UserInfo.getName();
                            newPrivacy.Username_Unique__c = UserInfo.getUserName();
                            
                            
                            lstPrivacyInsert.add(newPrivacy);
                            
                            if (field == 'alternate_email_do_not_email__c') { newAccount.Alternate_Email_Previous_DNC_PL__c = String.valueOf(oldAccount.get(field));}
                            if (field == 'do_not_email_in__c') {newAccount.Email_DNC_Previous_Value_PL__c =  String.valueOf(oldAccount.get(field));}
                            if (field == 'home_phone_do_not_call__c') {newAccount.Home_Phone_DNC_Previous_Value_PL__c = String.valueOf(oldAccount.get(field));}
                            if (field == 'mobile_phone_do_not_call_indicator__c') {newAccount.Mobile_Phone_DNC_Previous_Value_PL__c = String.valueOf(oldAccount.get(field));}
                            if (field == 'other_phone_do_not_call_in__c') {newAccount.Work_Phone_DNC_Previous_Value_PL__c = String.valueOf(oldAccount.get(field));}


                            




                       } 
                   }

                }
            }     
         }
            
         if (lstPrivacyInsert.size() > 0)  {
            Database.SaveResult[] dbResults = Database.insert(lstPrivacyInsert, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty())  {
                // Loop through results returned
                for (integer row = 0; row < lstPrivacyInsert.size(); row++) {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess()) {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = lstPrivacyInsert[row].Account_Name__c,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Trigger_Account_Privacy_Issue', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
                
                  // If any errors were returned, add them to the Error_Log table.
                if (!errors.isEmpty()) {
                // Insert rows
                Database.insert(errors, false);
                }  
                
            }

         }
    }
    
    // Convert Y to YES and N to NO for Do Not Call fields
    for (Account acct : Trigger.new) {
        if (acct.Home_Phone_Do_Not_Call__c != null && acct.Home_Phone_Do_Not_Call__c.contains('Y')) {
            acct.Home_Phone_Do_Not_Call__c = 'YES';
        } else if (acct.Home_Phone_Do_Not_Call__c != null && acct.Home_Phone_Do_Not_Call__c.contains('N') &&
                   !acct.Home_Phone_Do_Not_Call__c.contains('NONE')) {
            acct.Home_Phone_Do_Not_Call__c = 'NO';
        }

        if (acct.Other_Phone_Do_Not_Call_In__c != null && acct.Other_Phone_Do_Not_Call_In__c.contains('Y')) {
            acct.Other_Phone_Do_Not_Call_In__c = 'YES';
        } else if (acct.Other_Phone_Do_Not_Call_In__c != null && acct.Other_Phone_Do_Not_Call_In__c.contains('N') &&
                   !acct.Other_Phone_Do_Not_Call_In__c.contains('NONE')) {
            acct.Other_Phone_Do_Not_Call_In__c = 'NO';
        }
        
        if (acct.Mobile_Phone_Do_Not_Call_Indicator__c != null && acct.Mobile_Phone_Do_Not_Call_Indicator__c.contains('Y')) {
            acct.Mobile_Phone_Do_Not_Call_Indicator__c = 'YES';
        } else if (acct.Mobile_Phone_Do_Not_Call_Indicator__c != null && acct.Mobile_Phone_Do_Not_Call_Indicator__c.contains('N') &&
                   !acct.Mobile_Phone_Do_Not_Call_Indicator__c.contains('NONE')) {
            acct.Mobile_Phone_Do_Not_Call_Indicator__c = 'NO';
        }
    }
    
    // Get list of states passed to trigger
    List<String> states = new List<String>();
    for (Account acct : Trigger.new) {
        states.add(acct.PersonMailingState);
    }
    
    // Look for matches in the State__c to the list of states from the trigger and get a list
    // of the matching state abbreviations.
    List<State__c> matches = new List<State__c>();
    if (!states.isEmpty()) {
        matches = [select id, name, name__c from state__c where name in :states];
    }
    Set<String> stateCodes = new Set<String>();
    for (State__c state: matches) {
        stateCodes.add(state.name);
    }
    
    // Go through the trigger inputs and see if a matching state was found for each. If not,
    // add an error to that row.
    for (Account acct : Trigger.new) {
        if (acct.PersonMailingState != null && acct.PersonMailingState != '' && 
            (stateCodes == null || !stateCodes.contains(acct.PersonMailingState))) {
            acct.PersonMailingState.addError(System.Label.State_Invalid_Error);
        }
    }
}