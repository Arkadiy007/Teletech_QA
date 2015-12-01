/**********************************************************************
Name: DPIC_Survey_Case_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Calls the async survey creation process for each case closed.
======================================================
**********************************************************************/
trigger Dpic_Case_After on Case (after update) {
 SurveyGizmo_DPIC_Settings__c sgdpic = SurveyGizmo_DPIC_Settings__c.getOrgDefaults();
 Set<ID> closedCaseIDs = new Set<ID>();
 List<Error_Log__c> errors = new List<Error_Log__c>();
 List<RecordType> dpicIdList = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];
 List<DPICSurvey__c> dpicsList = new List<DPICSurvey__c>();
 Map<Integer,DPICSurvey__c> dpicsListMap = new Map<Integer,DPICSurvey__c>();
 Integer ins = 0;
 Boolean invalidateByEmail;
 
 for (Integer i = 0; i < Trigger.new.size(); i++) {
   if (Trigger.new[i].Status == 'Closed' && Trigger.old[i].Status != 'Closed') {
      if (Trigger.new[i].RecordTypeid==dpicIdList[0].Id && Trigger.new[i].Origin == 'Email to Case') {
       // send survey
        closedCaseIDs.add(Trigger.new[i].id);
      }  
   }
 }  

// Map for closed DPIC cases
  if (closedCaseIDs.size() > 0) {
      Map<ID, Case> mapClosedDPICCases = new Map<ID, Case>([select id, part_number_1__c, origin, contact.email, channel__c, contact.firstname, contact.lastname, owner.name, contact.name, account.name from case where id in :closedCaseIDs]);
     
      Map<String,Id> mapDPICSurveyCaseMap = new Map<String,Id>();
       Set<String> allEmails = new Set<String>();
       Set<String> invalidEmail = new Set<String>();
       Map<String,Integer> invalidMap = new Map<String,Integer>();
       Case c;
       for (Id id: mapClosedDPICCases.keyset()) {
           c = mapClosedDPICCases.get(id);
           allEmails.add(c.contact.email);
       }
       
    
    
       List<AggregateResult> ldpic = Database.query('select count(id) c, email__c from dpicsurvey__c where email__c in :allEmails and createddate=last_n_days:1 group by email__c');
       
       
       if (ldpic.size() > 0) {
           for (AggregateResult agdd: ldpic) {
               invalidMap.put((String) agdd.get('email__c'),(Integer) agdd.get('c'));
              // System.debug('putting to invalid map: ' + (String) agdd.get('email__c'));
              // System.debug('putting to invalid map2: ' + (Integer) agdd.get('c'));
               
           }
       }   
    
       
       for (DPICSurvey__c vv : [select id,sfdc_case_id__c from dpicsurvey__c  where sfdc_case_id__c in :closedCaseIDs]) {
           mapDPICSurveyCaseMap.put(vv.sfdc_case_id__c,vv.id); 
       }
       Case tcase;
         
       for (Id i : closedCaseIDs) {
            if (!mapDPICSurveyCaseMap.containsKey(i)) {
                //System.debug('the key: ' + i + ' is not in the map');
                
                    tcase = mapClosedDPICCases.get(i);
                    invalidateByEmail = false;
                    
                    if (invalidMap.containsKey(tcase.contact.email)) {
                      if ((Integer) invalidMap.get(tcase.contact.email) >= sgdpic.countPerDayPerDealerContact__c ) {
                          invalidateByEmail = true;
                      }
                    }
                        if (!invalidateByEmail) {
                            DPICSurvey__c dpic = new DPICSurvey__c();
                            dpic.Email__c = tcase.contact.email;
                            dpic.Brand__c = tcase.channel__c;
                            dpic.ContactName__c= tcase.contact.name;
                            dpic.AgentName__c= tcase.owner.name;
                            dpic.SFDC_Case_Id__c=tcase.id;
                            dpic.Case__c = tcase.id;
                            dpic.SurveySendDateTime__c = System.Now();
                            
                            dpic.partNumber__c = tcase.part_number_1__c != null && tcase.part_number_1__c.length() > 0 ? '(Part Number: ' + tcase.part_number_1__c + ')' : '';
                            
                            dpicsList.add(dpic);
                            dpicsListMap.put(ins,dpic);
                            ins++;
                           // System.debug('sending email survey on this run to ' + tcase.contact.email);
                            
                         } else {
                          //   System.debug('Not allowing email to this email address again,' +invalidMap.get(tcase.contact.email)+' survey found , but setting is ' +  sgdpic.countPerDayPerDealerContact__c + ' contacts per day per dealer.');
                              
                        }
            } else {
             //System.debug('the key: ' + i + ' is in the map, avoiding future call');
            }
        }
        
    
           Boolean updateCamp = false;
        
           Database.SaveResult[] dpicInsertList = Database.insert(dpicsList, false);
            //System.debug(dpicInsertList.size() + ' is the DPIC insert size');
    
           if (!dpicInsertList.isEmpty()) {
    
               for (integer row = 0; row < dpicInsertList.size(); row++)    {
                    if (dpicInsertList[row].isSuccess())  {
                        //System.debug('running SG create contact on ' + row + ' (number row)');
                       
                        DPICSUrvey_Utils.createDPICContact(dpicInsertList[row].id,dpicsListMap.get(row).SFDC_Case_Id__c, dpicsListMap.get(row).Email__c,  dpicsListMap.get(row).Brand__c,
                        dpicsListMap.get(row).ContactName__c, dpicsListMap.get(row).AgentName__c,dpicsListMap.get(row).partNumber__c); 
                        
                    } else {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dpicInsertList[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_Type__c = 'SurveyGizmo DPIC Survey', 
                                            Error_Message__c = err.getMessage(), 
                                            TimeStamp__c = System.now(), 
                                            Operation_Name__c = 'SurveyGizmo DPIC Survey insert error', 
                                            Source__c='Salesforce', 
                                            Log_Type__c = 'Error', 
                                            Log_Level__c = 1));
                    
                    }
        
               }
            }

   }
}