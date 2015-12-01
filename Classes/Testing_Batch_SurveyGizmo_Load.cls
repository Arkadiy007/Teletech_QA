/**********************************************************************
Name: Testing_Batch_SurveyGizmo_Load (Reads case table to determine which
    DQR cases to send a survey for.  Creates a survey__c record and sends
    the survey through SurveyGizmo       :Test ids:
        // WClause = Wclause + ' ID in (\'500c0000003HYS7AAO\',\'500F000000IH3c6IAD\') ';
         //  WClause = Wclause + ' and ID in (\'500F000000MvaGKIAZ\',\'500F000000MvaGAIAZ\') ';
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 5/7/2014 Created
1.1 - William Taylor 7/21/2014  insert the actual survey, instead of 
                                surveygizmo doing the insert
     
// **

This class only runs against ids (comma separated as string) provided in the surveygizmo custom settings object field: IdsForTestingClass 
 i.e.
 ('500axasfasdfasdf','500asdfasdfasd')
 
 
 
***********************************************************************/
global class Testing_Batch_SurveyGizmo_Load implements Database.Batchable<sObject>,Database.AllowsCallouts {


    global Testing_Batch_SurveyGizmo_Load() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        String WClause = '';
        String caseRecordType = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
        SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
        DateTime dt1 = DateTime.now();
        
        
        // checks to see if the Apex job is already processing records.
        // if so, it changes the where clause to ensure 0 rows return.
        
        
        if (Test.isRunningTest()) {
             WClause = 'WHERE Surveyable__c=true ';
        } else {
            Integer runCount = Database.countquery('select count() FROM asyncapexjob where apexclass.name=\'Batch_SurveyGizmo_Load\' and JobType=\'BatchApex\' and status IN (\'Processing\')');
            if (runCount > 0) {
                   System.debug('Checked existing jobs, JOBS ARE EXECUTING.  Preventing job from sending surveys until queue clears.');
                   WClause = ' LIMIT 0';
            } else {
                    System.debug('Checked existing jobs, none running. Executing the job.');
                    WClause = 'WHERE Surveyable__c=true and SurveyGizmoSurveySent__c=false and surveygizmo24hoursent__c=false and SurveyGizmoBatchdatetime__c <= :dt1 and RECORDTypeid=\'' + caseRecordType + '\' and CreatedDate >= LAST_N_DAYS:20 and Id IN '+sg.idsForTestClass__c+' ';
            }

        }   

        query = 'select id, SurveyGizmoSurveySent__c, SurveyGizmoBatchSendDateTime__c, SurveyGizmoBatchdatetime__c, date_sent__c, Maritz_Customer_Id__c, DQR_Number__c, Lead_Date__c, Considered_Vehicle_Make__c, Vehicle_Year__c, Considered_Vehicle_Model__c, SurveyGizmoSendStatus__c, Contact.FirstName, Contact.LastName, Account.id, Contact.Email, Contact.Id, Dealer__r.Name, Dealer__r.Id, Dealer__r.Dealer_Time_Zone__c FROM Case ' + WClause;
        
        
        
        if (Database.countQuery('select count() FROM Case ' + WCLause) > 0) {
            // create new campaign, update ids on sg object.
            SurveyGizmo_Utils sgutils = new SurveyGizmo_Utils();
            
            String newCampaignNissan;
            String newCampaignInfiniti;
            if (!Test.isRunningTest()) {
                newCampaignNissan = sgutils.cloneCampaign(sg.surveyNumberNissan__c,sg.campaignNumberNissan__c,'TESTING PROD Camp ' + dt1.format('yyyy-MM-dd HH:mm'));
                newCampaignInfiniti = sgutils.cloneCampaign(sg.surveyNumberInfiniti__c,sg.campaignNumberInfiniti__c,'TESTING PROD Camp ' + dt1.format('yyyy-MM-dd HH:mm'));
            
            sg.campaignNumberNissan__c = newCampaignNissan;
            sg.campaignNumberInfiniti__c = newCampaignInfiniti;
            update sg;
            }
                
        }
        
        return Database.getQueryLocator(query);
        
        
        
        
    } 

    global void execute(Database.BatchableContext BC, List<Case> lstSurveyCases) {

        Integer ins = 0;
        Surveys__c thisSurvey;
        List<Surveys__c> listAllSurveys = new List<Surveys__c>();  
        List<Case> listUpdateCases = new List<Case>();  
        String surveysRt = RecordtypeUtil.getObjectRecordTypeId(Surveys__c.SObjectType, 'SurveyGizmoSurvey');
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        if (lstSurveyCases.size() > 0) {

            for (Case thisSurveyCase: lstSurveyCases) {

                try {

                    thisSurvey = new Surveys__c();
                    thisSurvey.RecordTypeId = surveysRt;
                    thisSurvey.SurveyGizmoDateSent__c = DateTime.now();
                    thisSurvey.Lead_Id__c = thisSurveyCase.DQR_Number__c;
                    thisSurvey.Customer_Id__c = thisSurveyCase.Maritz_Customer_Id__c;
                    thisSurvey.Case_Id__c = thisSurveyCase.Id;
                    thisSurvey.SurveyGizmoCase__c = thisSurveyCase.Id;
                    thisSurvey.Dealer__c = thisSurveyCase.Dealer__r.Id;
                    thisSurvey.Brand__c = thisSurveyCase.Considered_Vehicle_Make__c;
                    thisSurvey.Customer__c = thisSurveyCase.Account.Id;
                    if (thisSurveyCase.Contact.FirstName != null) {
                        thisSurvey.First_Name__c = thisSurveyCase.Contact.FirstName.toUpperCase();
                    }
                    if (thisSurveyCase.Contact.LastName != null) {
                        thisSurvey.Last_Name__c = thisSurveyCase.Contact.LastName.toUpperCase();
                    }
                    //thisSurvey.First_Name__c = thisSurveyCase.Contact.FirstName;
                    //thisSurvey.Last_Name__c = thisSurveyCase.Contact.LastName;
                    
                    
                    SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
                    
                    if (sg.useDevelopmentEmail__c == true) {
                        thisSurvey.Email__c = sg.sgDevelopmentEmail__c;
                    } else {
                        thisSurvey.Email__c = thisSurveyCase.Contact.Email;
                    }    
                    
                    
                    //if (thisSurveyCase.SurveyGizmoBatchdatetime__c != null) {
                    //    thisSurvey.SurveyGizmoExpireDateTime__c = thisSurveyCase.SurveyGizmoBatchdatetime__c.addDays(7);
                    //} else {
                        thisSurvey.SurveyGizmoExpireDateTime__c = DateTime.now().addDays(7);
                    //}
                    
                    
                    String sgLeadDate = '';
                    Datetime thisdt = Datetime.newInstanceGmt(thisSurveyCase.date_sent__c,Time.newInstance(12, 0, 0, 0)); 
                    
                    sgLeadDate = thisdt.format('M-d-yyyy');
                    
                    String thisSurveyNumber = '';
                    String thisCampaignNumber = '';
                    String createResult = '';
                    

                    if (thisSurvey.Brand__c.toUpperCase() == 'NISSAN') {
                        thisSurvey.Brand__c = 'Nissan';
                        thisSurveyNumber = sg.surveyNumberNissan__c;
                        thisCampaignNumber = sg.campaignNumberNissan__c;
                    }  else if (thisSurvey.Brand__c.toUpperCase() == 'INFINITI') {
                        thisSurvey.Brand__c = 'Infiniti';
                        thisSurveyNumber = sg.surveyNumberInfiniti__c;
                        thisCampaignNumber = sg.campaignNumberInfiniti__c;
                    } else {
                        // not infiniti or nissan, don't send request?
                    }  
                    SurveyGizmo_Utils sgUtils = new SurveyGizmo_Utils();
                    
                    if (!Test.isRunningTest()) {                    
                        createResult = sgUtils.createSurveyGizmoContact(thisSurveyNumber, thisCampaignNumber, thisSurvey,thisSurveyCase.Id,thisSurveyCase.Dealer__r.Name,thisSurveyCase.Considered_Vehicle_Model__c, thisSurveyCase.Vehicle_Year__c, sgLeadDate);
                    }
                    thisSurveyCase.SurveyGizmoSendStatus__c = 'contact id: ' + createResult + ' (' + thisSurveyNumber + ', ' + thisCampaignNumber + ')';

                    thisSurveyCase.SurveyGizmoSurveySent__c = true;
                    thisSurveyCase.SurveyGizmoBatchSendDateTime__c = DateTime.now();
                    
                    listAllSurveys.add(thisSurvey);  
                    listUpdateCases.add(thisSurveyCase);
                    ins++;
                    
                } catch (Exception err) {
                    errors.add(new Error_Log__c(Record_ID__c = thisSurveyCase.Id,
                        Record_Type__c = 'Batch_SurveyGizmo_Load', 
                        Error_Message__c = err.getMessage() + err.getLineNumber(), 
                        TimeStamp__c = System.now(), 
                        Operation_Name__c = 'Batch_SurveyGizmo_Load Error', 
                        Source__c='Salesforce', 
                        Log_Type__c = 'Error', 
                        Log_Level__c = 1));
                }
                
                

            }
            
           try {
               Database.SaveResult[] sr4 = Database.update(listUpdateCases,false);

            } catch (Exception err) {                
                errors.add(new Error_Log__c(Record_Type__c = 'Batch_SurveyGizmo_Load ', Error_Message__c = err.getMessage() + err.getLineNumber(), TimeStamp__c = System.now(), Operation_Name__c = 'Batch_SurveyGizmo_Case Update',  Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
            }

           try {
               Database.SaveResult[] sr5 = Database.insert(listAllSurveys,false);

            } catch (Exception err2) {                
                errors.add(new Error_Log__c(Record_Type__c = 'Batch_SurveyGizmo_Load Survey Insert ', Error_Message__c = err2.getMessage() + err2.getLineNumber(), TimeStamp__c = System.now(), Operation_Name__c = 'Batch_SurveyGizmo_Case Update',  Source__c='Salesforce', Log_Type__c = 'Error', Log_Level__c = 1));
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