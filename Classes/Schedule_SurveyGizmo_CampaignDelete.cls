global class Schedule_SurveyGizmo_CampaignDelete implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    // run list campaigns method, compare current datetime to 
    
    DateTime rightnow = DateTime.now();
    DateTime targetDate = rightnow.addDays(-7);
    SurveyGizmo_Utils sg = new SurveyGIzmo_Utils();
    SurveyGizmoSettings__c sgsettings = SurveyGizmoSettings__c.getOrgDefaults();
    Map<String,DateTime> nissanMap = sg.listCampaigns(sgsettings.surveyNumberNissan__c);
    Map<String,DateTime> infinitiMap = sg.listCampaigns(sgsettings.surveyNumberInfiniti__c);
    
    // should only have 8 callouts left this execution.
    // will error out on some deletes but will be able to get them 
    // during next execution.
    
    
    for (String nissanEntry : nissanMap.keySet()) {
        
        if (nissanMap.get(nissanEntry) <= targetDate) {
            System.debug('We Can DELETE this entry:' + nissanEntry + ' : ' + nissanMap.get(nissanEntry));
            sg.deleteCampaign(sgsettings.surveyNumberNissan__c,nissanEntry);
        } else {
            System.debug('We CANNOT delete this entry:' + nissanEntry + ' : ' + nissanMap.get(nissanEntry));
        }
    }
    
    for (String infinitiEntry : infinitiMap.keySet()) {
        
        if (infinitiMap.get(infinitiEntry) <= targetDate) {
                
            System.debug('We Can DELETE this entry:' + infinitiEntry + ' : ' + infinitiMap.get(infinitiEntry));
            sg.deleteCampaign(sgsettings.surveyNumberInfiniti__c,infinitiEntry );
        } else {
            System.debug('We CANNOT delete this entry:' + infinitiEntry + ' : ' + infinitiMap.get(infinitiEntry));
        }
    }
    

    
  }
  
  
  }