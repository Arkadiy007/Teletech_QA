/**********************************************************************
Name: Account_After
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a new Account is created perform logic:
Populate Account_Address object. Account Address will only contain 
previous addresses
Update existing Account_Address
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Aaron Bessey - 02/17/2015 Created
1.1 - Aaron Bessey - 02/20/2015 Modified to only trigger After Update
***********************************************************************/

trigger Account_After on Account (after update) 
{
    Account oldAccount;
    Account newAccount;
    
    Boolean isUpdate = Trigger.isUpdate;
    
    Set<String> sRecordTypeNames = new Set<String>();
    Set<Id> recordTypeIds = new Set<Id>();
    List<Account_Address_RecordTypes__c> recordTypeNames = Account_Address_RecordTypes__c.getall().values();
    for(Account_Address_RecordTypes__c oRecordTypeName : recordTypeNames)
    {
        sRecordTypeNames.Add(oRecordTypeName.Record_Type_Name__c);
    }
    
    for(RecordType oRT : [Select Id, Name from RecordType where sobjecttype='Account' and isPersonType=true and isActive=true and name in :sRecordTypeNames])
    {
        recordTypeIds.Add(oRT.Id);
    }   
        
    List<Account_Address__c> newAccountAddresses = new List<Account_Address__c>();
    Account_Address__c oAccountAddress;
    List<Account_Address__c> updateAccountAddresses;
    Set<Id> setUpdateAccountIds = new Set<Id>();
    Map<Id, Date> accountCreatedDates = new Map<Id, Date>();
    Map<Id, Account_Address__c> mapAccountAddresses = new Map<Id, Account_Address__c>();
    
    Boolean addressChanged;
    Date currentDate = DateTime.now().date();
    
    for (Integer i = 0; i < Trigger.new.size(); i++) 
    {
        newAccount = Trigger.new[i];
        oldAccount = Trigger.old[i];
        
        if(recordTypeIds.contains(newAccount.RecordTypeId)==false)
        {
            continue;
        }
        
        /* AAB - Removing code for inserts. Account Address only contains previous addresses now
        if(isUpdate)
        {
            oldAccount = Trigger.old[i];
        }
        else
        {
            oldAccount = null;
            if(newAccount.ValidationStatus_MailingAddress__c==null)
            {
                oAccountAddress = new Account_Address__c();
                oAccountAddress.Account__c = newAccount.Id;
                oAccountAddress.Address_Line_1__c = newAccount.PersonMailingStreet;
                oAccountAddress.City__c = newAccount.PersonMailingCity;
                oAccountAddress.Country__c = newAccount.PersonMailingCountry;
                oAccountAddress.Province_State__c = newAccount.PersonMailingState;
                oAccountAddress.Start_Date__c = DateTime.now().date();
                oAccountAddress.Postal_Code_Zip_Code__c = newAccount.PersonMailingPostalCode;
                oAccountAddress.Current_Address__c = true;
                newAccountAddresses.Add(oAccountAddress);
            }
        }
        */
        
        addressChanged = false;
        
        if(newAccount.PersonMailingStreet != null && (oldAccount.PersonMailingStreet==null || 
                                                      oldAccount.PersonMailingStreet!=newAccount.PersonMailingStreet))
        {
            addressChanged = true;
        }  
        else if(newAccount.PersonMailingStreet==null && oldAccount.PersonMailingStreet!=null)
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingCity != null && (oldAccount.PersonMailingCity==null || 
                                                          oldAccount.PersonMailingCity!=newAccount.PersonMailingCity))
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingCity==null && oldAccount.PersonMailingCity!=null)
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingCountry != null && (oldAccount.PersonMailingCountry==null || 
                                                             oldAccount.PersonMailingCountry!=newAccount.PersonMailingCountry))
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingCountry==null && oldAccount.PersonMailingCountry!=null)
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingState != null && (oldAccount.PersonMailingState==null || 
                                                           oldAccount.PersonMailingState!=newAccount.PersonMailingState))
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingState==null && oldAccount.PersonMailingState!=null)
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingPostalCode != null && (oldAccount.PersonMailingPostalCode==null || 
                                                                oldAccount.PersonMailingPostalCode!=newAccount.PersonMailingPostalCode))
        {
            addressChanged = true;
        }
        else if(newAccount.PersonMailingPostalCode==null && oldAccount.PersonMailingPostalCode!=null)
        {
            addressChanged = true;
        }   
        
        else if(newAccount.PersonMobilePhone != null && (oldAccount.PersonMobilePhone ==null || 
                                                                oldAccount.PersonMobilePhone !=newAccount.PersonMobilePhone ))
        {
            addressChanged = true;
        }
        else if(newAccount.Phone != null && (oldAccount.Phone ==null || 
                                                                oldAccount.Phone !=newAccount.Phone ))
        {
            addressChanged = true;
        }
        else if(newAccount.Work_Phone__c!= null && (oldAccount.Work_Phone__c==null || 
                                                                oldAccount.Work_Phone__c!=newAccount.Work_Phone__c))
        {
            addressChanged = true;
        }
        
        
        if(addressChanged)
        {
            if (isUpdate)
            {
                setUpdateAccountIds.add(newAccount.Id);
                accountCreatedDates.put(newAccount.Id, newAccount.CreatedDate.Date());
            }
            
            oAccountAddress = new Account_Address__c();
            oAccountAddress.Account__c = newAccount.Id;
            oAccountAddress.Address_Line_1__c = oldAccount.PersonMailingStreet!=null ? oldAccount.PersonMailingStreet : '';
            oAccountAddress.City__c = oldAccount.PersonMailingCity!=null ? oldAccount.PersonMailingCity : '';
            oAccountAddress.Country__c = oldAccount.PersonMailingCountry!=null ? oldAccount.PersonMailingCountry : '';
            oAccountAddress.Province_State__c = oldAccount.PersonMailingState!=null ? oldAccount.PersonMailingState : '';
            oAccountAddress.End_Date__c = currentDate;
            oAccountAddress.Postal_Code_Zip_Code__c = oldAccount.PersonMailingPostalCode!=null ? oldAccount.PersonMailingPostalCode : '';
            oAccountAddress.Last_Address__c = true;
            oAccountAddress.Home_Phone__c = oldAccount.Phone != null ? oldAccount.Phone : '';
            oAccountAddress.Mobile_Phone__c = oldAccount.PersonMobilePhone != null ? oldAccount.PersonMobilePhone : '';
            oAccountAddress.Work_Phone__c = oldAccount.Work_Phone__c != null ?  oldAccount.Work_Phone__c : '';
            
            mapAccountAddresses.Put(newAccount.Id, oAccountAddress);
            
        }
    }            
    
    updateAccountAddresses = [Select Id, Account__c, Start_Date__c, End_Date__c 
                              from Account_Address__c 
                              where Account__c in :setUpdateAccountIds and Last_Address__c=true];
    
    if(updateAccountAddresses!=null && updateAccountAddresses.size()>0)
    {
        for (Account_Address__c oAddress : updateAccountAddresses) 
        {
            oAccountAddress = mapAccountAddresses.get(oAddress.Account__c);
            if(oAddress.End_Date__c==currentDate && oAccountAddress.End_Date__c==oAddress.End_Date__c)
            {
                //Logic to skip updating previous 
                mapAccountAddresses.remove(oAddress.Account__c);
                continue;
            }
            oAddress.Last_Address__c = false;            
            oAccountAddress.Start_Date__c = oAddress.End_Date__c;            
        }
        update updateAccountAddresses;
    }
    
    newAccountAddresses = mapAccountAddresses.values();
    for(Account_Address__c oAddress : newAccountAddresses)
    {
        if(oAddress.Start_Date__c==null)
        {
            oAddress.Start_Date__c = accountCreatedDates.get(oAddress.Account__c);
        }
    }
    
    upsert newAccountAddresses;

    ShareHelper.shareNewParts(Trigger.newMap, Trigger.oldMap);
}