/**********************************************************************
Name: Account_DNC_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever an Account is updated, ensure do not call checkboxes are
populated based on picklists and vice versa.

Picklists                              Checkboxes
alternate_email_do_not_email__c         Alternate_Email_Do_Not_Email_CB__c
do_not_email_in__c                      Do_Not_Email_CB__c
home_phone_do_not_call__c               Home_Phone_Do_Not_Call_CB__c
mobile_phone_do_not_call_indicator__c   Mobile_Do_Not_Call_CB__c
other_phone_do_not_call_in__c           Work_Phone_Do_Not_Call_CB__c
=================================

History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  William Taylor      4/10/2014 Created

***********************************************************************/
trigger Account_DNC_Before on Account (before update) {
   
    Account oldAccount;
    Account newAccount;
    System.debug('Will - Entering Account_DNC_Before trigger');
    for (Integer i = 0; i < Trigger.new.size(); i++) {
            oldAccount = Trigger.old[i];
            newAccount = Trigger.new[i];
          
            //check if the picklists have changed
             
            if(newAccount.alternate_email_do_not_email__c != oldAccount.alternate_email_do_not_email__c) { 
                  if (newAccount.alternate_email_do_not_email__c == 'YES' || newAccount.alternate_email_do_not_email__c == 'true') {
                      newAccount.Alternate_Email_Do_Not_Email_CB__c = true;
                  } else {
                      newAccount.Alternate_Email_Do_Not_Email_CB__c = false;    
                  }
            }
            
            if(newAccount.do_not_email_in__c != oldAccount.do_not_email_in__c) { 
                  if (newAccount.do_not_email_in__c  == 'YES' || newAccount.do_not_email_in__c  == 'true') {
                      newAccount.Do_Not_Email_CB__c = true;
                  } else {
                      newAccount.Do_Not_Email_CB__c = false;    
                  }
            }
         if(newAccount.home_phone_do_not_call__c != oldAccount.home_phone_do_not_call__c) { 
                  if (newAccount.home_phone_do_not_call__c  == 'true' || newAccount.home_phone_do_not_call__c  == 'YES') {
                      newAccount.Home_Phone_Do_Not_Call_CB__c = true;
                  } else {
                      newAccount.Home_Phone_Do_Not_Call_CB__c = false;    
                  }
            }
         if(newAccount.mobile_phone_do_not_call_indicator__c != oldAccount.mobile_phone_do_not_call_indicator__c) { 
                  if (newAccount.mobile_phone_do_not_call_indicator__c  == 'true' || newAccount.mobile_phone_do_not_call_indicator__c  == 'YES' ) {
                      newAccount.Mobile_Do_Not_Call_CB__c = true;
                  } else {
                      newAccount.Mobile_Do_Not_Call_CB__c = false;    
                  }
            }
         
          if(newAccount.other_phone_do_not_call_in__c != oldAccount.other_phone_do_not_call_in__c) { 
                  if (newAccount.other_phone_do_not_call_in__c == 'true' || newAccount.other_phone_do_not_call_in__c == 'YES' ) {
                      newAccount.Work_Phone_Do_Not_Call_CB__c = true;
                  } else {
                      newAccount.Work_Phone_Do_Not_Call_CB__c = false;    
                  }
            }
            // check if the checkboxes have changed
            
            if(newAccount.Alternate_Email_Do_Not_Email_CB__c != oldAccount.Alternate_Email_Do_Not_Email_CB__c) { 
                if (newAccount.Alternate_Email_Do_Not_Email_CB__c == true) {
                    newAccount.alternate_email_do_not_email__c = 'YES';
                } else {
                    newAccount.alternate_email_do_not_email__c = 'NO';
                }
            }
    
            if(newAccount.Do_Not_Email_CB__c != oldAccount.Do_Not_Email_CB__c) { 
                if (newAccount.Do_Not_Email_CB__c == true) {
                    newAccount.do_not_email_in__c = 'YES';
                } else {
                    newAccount.do_not_email_in__c = 'NO';
                }
            }
            
            if(newAccount.Home_Phone_Do_Not_Call_CB__c != oldAccount.Home_Phone_Do_Not_Call_CB__c) { 
                if (newAccount.Home_Phone_Do_Not_Call_CB__c == true) {
                    newAccount.home_phone_do_not_call__c  = 'true';
                } else {
                    newAccount.home_phone_do_not_call__c  = 'false';
                }
            }
             if(newAccount.Mobile_Do_Not_Call_CB__c != oldAccount.Mobile_Do_Not_Call_CB__c) { 
                if (newAccount.Mobile_Do_Not_Call_CB__c == true) {
                    newAccount.mobile_phone_do_not_call_indicator__c  = 'true';
                } else {
                    newAccount.mobile_phone_do_not_call_indicator__c  = 'false';
                }
            }
             if(newAccount.Work_Phone_Do_Not_Call_CB__c != oldAccount.Work_Phone_Do_Not_Call_CB__c) { 
                if (newAccount.Work_Phone_Do_Not_Call_CB__c == true) {
                    newAccount.other_phone_do_not_call_in__c  = 'true';
                } else {
                    newAccount.other_phone_do_not_call_in__c  = 'false';
                }
            }


    }






}