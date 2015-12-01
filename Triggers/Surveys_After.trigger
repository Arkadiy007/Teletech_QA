/**********************************************************************
Name: Surveys_After_Insert
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This trigger creates a Case based on an insert of a Surveys__c
record that comes from Survey Gizmo. If the NPS score is low
this creates a new Case.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr     05/19/2014 Created
1.1 - Matt Starr     06/03/2014 Preventing Duplicates
1.2 - Matt Starr     06/12/2014 Adding the "Yes" partial response for SG DQR surveys
1.3 - Matt Starr     06/20/2014 Changing to be for update only
1.4 - William Taylor 04/20/2014 Adding code to allow auto-completes to have an actual response date
1.5 - Anna Koseikina 08/31/2015 Adding logic for Tiger Team Survey task

***********************************************************************/
trigger Surveys_After on Surveys__c (After insert, After Update) {
    
    Set<Id> caseids = new Set<Id>();
    List<Case> UPcases = new List<Case>();
    List<Surveys__c> UPsurveys = new List<Surveys__c>();
    List<Surveys__c> DELsurveys = new List<Surveys__c>();
    String newcaseTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Lead Survey');
    String SurveyTypeId = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'SurveyGizmoSurvey'); 
    SurveyGizmoSettings__c sgs = SurveyGizmoSettings__c.getOrgDefaults();
    String MCCLevel2 = sgs.MCC_Level_2_Alert_Queue__c;
    String MCCHotAlert = sgs.MCC_Lead_Hot_Alert_Queue__c;
    Boolean disRecChange = sgs.disableRecordTypeChange__c;
    Set<Id> existingcaseids = new Set<Id>();
	String TigerTeamTypeId = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'TigerTeam Survey');
	List<Case> TigerCases = new List<Case> ();
	Map<Id, id> caseSurvey = new Map<Id, Id> ();
    
   //Delete duplicate survey records from Survey Gizmo 
    if(Trigger.isInsert){
    for(Surveys__c s : Trigger.New){
        if(s.RecordTypeId == SurveyTypeId){
            caseids.add(s.SurveyGizmoCase__c); 
        }
    }
    
        if(caseids.size() > 0){
        for(Surveys__c s : [select Id, SurveyGizmoCase__c from Surveys__c where 
                        Id Not in :Trigger.New and SurveyGizmoCase__c in :caseids
                        and RecordTypeId = :SurveyTypeId]){
                            
            existingcaseids.add(s.SurveyGizmoCase__c); 
        }
    
        for(Surveys__c s : Trigger.New){
        
             if(existingcaseids.contains(s.SurveyGizmoCase__c)){
                DELsurveys.add(s);  
            }
         }
        
        if(DELsurveys.size() > 0){
            List<Surveys__c> DELsurveys2 = [select Id from Surveys__c where Id in :DELsurveys];
            delete DELsurveys2;
        }
    }
    }
    
    //For Older Surveys that were not initially inserted.
    if(Trigger.isInsert){
        for(Surveys__c s : Trigger.new){
            
           if(s.RecordTypeId == SurveyTypeId &&
                s.DQR_Dealer_Rating__c != null &&
                s.SurveyGizmoCase__c != null && 
                !existingcaseids.contains(s.SurveyGizmoCase__c)){
           
            
            Surveys__c updatesurvey = New Surveys__c(Id = s.Id);
              updatesurvey.Hot_Alert_Created__c = true;
              updatesurvey.CastIron_ETL_Status__c = false;
              UPsurveys.add(updatesurvey);
              
              Case c = new Case(Id = s.SurveyGizmoCase__c);
              
              c.Subject = 'Lead Survey Hot Alert';
              c.Origin = 'Lead Survey';
              c.Description = 'Follow-Up on Lead Survey Hot Alerts';
              
               if(disRecChange == false && ((s.DQR_Dealer_Rating__c != null &&
                                            s.DQR_Dealer_Rating__c <= 6 )|| 
                                            s.CastIron_FF_Status__c == true ||
                                            s.DQR_Dealer_Contacted__c == 'no')){
               c.RecordtypeId = newcaseTypeId;
               }
               
              c.Survey_ID__c = s.SG_Survey_Id__c;
              c.Business_Unit__c = s.Brand__c;
              c.Event_Date__c = date.valueOf(s.CreatedDate);
              c.Alert_Trigger_Verbatim__c = s.DQR_Dealer_Comments__c;
              c.Status = 'Item Created';
               
                                             
               if(s.DQR_Dealer_Contacted__c == 'no'){
                c.OwnerId = MCCLevel2;         
               } else {
                c.OwnerId = MCCHotAlert;
               }
                
               if(s.DQR_Dealer_Rating__c != null){
                   c.Survey_NPS_Score_1__c = String.valueOf(s.DQR_Dealer_Rating__c);
               }
               
               if (Trigger.isInsert && (s.DQR_Dealer_Contacted__c == 'no' ||
                    s.DQR_Dealer_Rating__c <= 3)){
                        c.Priority = 'High';
                        }
                
               if (Trigger.isInsert && (s.DQR_Dealer_Contacted__c != 'no' ||
                    s.DQR_Dealer_Rating__c != null &&
                    s.DQR_Dealer_Rating__c >= 4 &&
                    s.DQR_Dealer_Rating__c <= 6)){
                        c.Priority = 'Medium';
                        }
               
             
               UPcases.add(c);    
                
                
                
                
           }
            
        }
    } 
           
        
    
    //For newer surveys that are inserted during the batch process.    
    if(Trigger.isUpdate && UserInfo.getName() != 'Managed Services'){
        for(Surveys__c s : Trigger.new){
            if(s.RecordTypeId == SurveyTypeId && s.SurveyGizmo_Response_Date__c == null && (s.DQR_Dealer_Contacted__c == 'yes' && s.DQR_Dealer_Rating__c == null) 
                  && s.SurveyGizmoCase__c != null && s.Hot_Alert_Created__c == false) {
                  Surveys__c updatesurvey = New Surveys__c(Id = s.Id);
                  updatesurvey.SurveyGizmo_Response_Date__c = system.now();
                  UPsurveys.add(updatesurvey);
            } 
           if(s.RecordTypeId == SurveyTypeId &&
                ((s.DQR_Dealer_Contacted__c == 'yes' && s.DQR_Dealer_Rating__c != null) 
                 || (s.DQR_Dealer_Contacted__c == 'no')) &&
                s.SurveyGizmoCase__c != null &&
                s.Hot_Alert_Created__c == false){
                    
              Surveys__c updatesurvey = New Surveys__c(Id = s.Id);
              updatesurvey.Hot_Alert_Created__c = true;
              updatesurvey.CastIron_ETL_Status__c = false;
                                       
              UPsurveys.add(updatesurvey);
                    
              Case c = new Case(Id = s.SurveyGizmoCase__c);
              
              c.Subject = 'Lead Survey Hot Alert';
              c.Origin = 'Lead Survey';
              c.Description = 'Follow-Up on Lead Survey Hot Alerts';
                    
              if(disRecChange == false && ((s.DQR_Dealer_Rating__c != null &&
                  s.DQR_Dealer_Rating__c <= 6 )|| 
                  s.CastIron_FF_Status__c == true ||
                  s.DQR_Dealer_Contacted__c == 'no')){
                        c.RecordtypeId = newcaseTypeId;
                    }
                    
              c.Survey_ID__c = s.SG_Survey_Id__c;
              c.Business_Unit__c = s.Brand__c;
              c.Event_Date__c = date.valueOf(s.CreatedDate);
              c.Alert_Trigger_Verbatim__c = s.DQR_Dealer_Comments__c;
              c.Status = 'Item Created';
               
                                             
               if(s.DQR_Dealer_Contacted__c == 'no'){
                c.OwnerId = MCCLevel2;         
               } else {
                c.OwnerId = MCCHotAlert;
               }
                
               if(s.DQR_Dealer_Rating__c != null){
                   c.Survey_NPS_Score_1__c = String.valueOf(s.DQR_Dealer_Rating__c);
               }
               
               if (Trigger.isInsert && (s.DQR_Dealer_Contacted__c == 'no' ||
                    s.DQR_Dealer_Rating__c <= 3)){
                        c.Priority = 'High';
                        }
                
               if (Trigger.isInsert && (s.DQR_Dealer_Contacted__c != 'no' ||
                    s.DQR_Dealer_Rating__c != null &&
                    s.DQR_Dealer_Rating__c >= 4 &&
                    s.DQR_Dealer_Rating__c <= 6)){
                        c.Priority = 'Medium';
                        }
              
                if(Trigger.isUpdate){
                  c.Priority = 'Low';
                        }
               
             
               UPcases.add(c);      
                    
                    
                }           
            }
        
         if(UPcases.size() > 0){
            update UPcases;
        }
    
        if(UPsurveys.size() > 0){        
            update UPsurveys;
        }
        
    }
    for (Surveys__c survey : Trigger.new) {
		if (survey.recordTypeId == TigerTeamTypeId && survey.Tiger_Team_Case__c != null) {
			caseSurvey.put(survey.Tiger_Team_Case__c, survey.id);
		}
	}

	if (caseSurvey != null && caseSurvey.size() > 0) {
		for (Case tigerCase :[Select id, Survey__c from Case where id in :caseSurvey.keySet()]) {
			if (caseSurvey.get(tigerCase.ID) != null) {
				tigerCase.survey__c = caseSurvey.get(tigerCase.ID);
				TigerCases.add(tigerCase);
			}
		}

		if (TigerCases.size() > 0) {
			update TigerCases;
		}
	}    
}