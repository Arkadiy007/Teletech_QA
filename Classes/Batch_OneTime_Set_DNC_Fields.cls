/**********************************************************************
Name: Batch_OneTime_Set_DNC_Fields
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 4/17/2013 Created
***********************************************************************/
global class Batch_OneTime_Set_DNC_Fields implements Database.Batchable<sObject> {
    
    //  012A0000000wu5hIAA   is maritz Account type
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = ' recordtypeid=\'012A0000000wu5hIAA\' ';  
        //WClause = WClause + ' and ID IN  (\'001A000000bgrrKIAQ\',\'001A000000bgs9cIAA\',\'001A000000bgsIbIAI\',\'001A000000bgsYPIAY\',\'001A000000bgtDAIAY\') ';
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('Account', WClause);
        
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Account> lstAccountsToUpdate) {
        List<Error_Log__c> errors = new List<Error_Log__c>();
        if (lstAccountsToUpdate.size() > 0) {
            for (Account aa : lstAccountsToUpdate) {
                  if (aa.alternate_email_do_not_email__c == 'YES') { 
                      aa.Alternate_Email_Do_Not_Email_CB__c = true; 
                  } else {
                      aa.Alternate_Email_Do_Not_Email_CB__c = false;    
                  }
                  if (aa.do_not_email_in__c  == 'YES') {
                      aa.Do_Not_Email_CB__c = true;
                  } else {
                      aa.Do_Not_Email_CB__c = false;    
                  }

                  if (aa.home_phone_do_not_call__c  == 'true' || aa.home_phone_do_not_call__c  == 'YES') {
                      aa.Home_Phone_Do_Not_Call_CB__c = true;
                  } else {
                      aa.Home_Phone_Do_Not_Call_CB__c = false;    
                  }

                  if (aa.mobile_phone_do_not_call_indicator__c  == 'true' || aa.mobile_phone_do_not_call_indicator__c  == 'YES') {
                      aa.Mobile_Do_Not_Call_CB__c = true;
                  } else {
                      aa.Mobile_Do_Not_Call_CB__c = false;    
                  }
         
                  if (aa.other_phone_do_not_call_in__c == 'true' || aa.other_phone_do_not_call_in__c == 'YES') {
                      aa.Work_Phone_Do_Not_Call_CB__c = true;
                  } else {
                      aa.Work_Phone_Do_Not_Call_CB__c = false;    
                  }
            }
             Database.SaveResult[] lstCSIns = Database.update(lstAccountsToUpdate, false);
            if (lstCSIns.size() > 0) {
                for (integer x = 0; x < lstCSIns.size(); x++) {
                    if (lstCSIns[x].isSuccess()) {
                     
                    } else {           
                        Database.Error err = lstCSIns[x].getErrors()[0];    
                        errors.add(new Error_Log__c(
                                    Record_Type__c = 'Case Comment', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_New_OneTime_Set_DNC_Fields', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                        System.debug('FAILED DML operation' + err.getMessage());                        
                    }
                     
    
                }
            }
        
        } else {
              
        }
        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
        
        
    }

    global void finish(Database.BatchableContext BC){
    }

    
}