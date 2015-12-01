trigger Service_Marketing_Disposition_Reporting_Before on Service_Marketing_Disposition_Reporting__c (before insert) {
    Set<String> serviceMarketingCallIdStrings = new Set<String>();
    Set<Integer> serviceMarketingCallIds = new Set<Integer>();
    Set<String> taskIds = new Set<String>();
    Map<String,CampaignMember> taskIdMembers = new Map<String,CampaignMember>();
    Map<String,Call_Resolution__c> callIdResolutions = new Map<String,Call_Resolution__c>();
    CampaignMember cm = null;
    Call_Resolution__c cr = null;
    
    // Loop through the Service_Marketing_Disposition_Reporting objects and
    // get sets of customer Ids, campaign names, and service marketing call Ids.
    for (Service_Marketing_Disposition_Reporting__c rpt: Trigger.new) {
        serviceMarketingCallIdStrings.add(rpt.Resolution_Id__c);
        taskIds.add(rpt.Task_Id__c);
    }
    
    for (String IdString: serviceMarketingCallIdStrings) {
        serviceMarketingCallIds.add(Integer.valueOf(IdString));
    }

    // Get a List of campaign members that match the customer Ids and campaign names.
    List<CampaignMember> members = [Select Id, Task_Id__c, Service_Marketing_Call_Id__c, Dealer__c, 
                                           Vehicle__c, Vehicle_Identification_Number__c, Call_Priority__c
                                    from CampaignMember
                                    where Task_Id__c in :taskIds];
    
    // Make a Map from Task Ids to the Campaign Members.
    for (CampaignMember member: members) {
        taskIdMembers.put(member.Task_Id__c, member);
    }
        
    // Find Call Resolutions that match the service marketing call ids created in the last hour.
    DateTime oneHourAgo = System.now().addHours(-1);
    List<Call_Resolution__c> callResolutions = [select Id, CreatedDate, ResolutionId__c
                                                from Call_Resolution__c
                                                where ResolutionId__c in :serviceMarketingCallIdStrings
                                                and createddate > :oneHourAgo];
                                                
    // Create a map of service marketing call ids/resolution ids to Call Resolutions.
    for (Call_Resolution__c callRes: callResolutions) {
        callIdResolutions.put(callRes.ResolutionId__c, callRes);
    }
    
    // For each row in the trigger, set values from the Campaign Member,
    // Task, and Call Resolution if they are found in the matching maps.
    for (Service_Marketing_Disposition_Reporting__c rpt: Trigger.new) {
        cm = taskIdMembers.get(rpt.Task_Id__c);

        if (cm != null) {
            rpt.Vehicle_Identification_Number__c = cm.Vehicle_Identification_Number__c;
            rpt.Priority__c = String.valueOf(cm.Call_Priority__c);
            rpt.Campaign_Member_Id__c = cm.Id;
            rpt.Dealer__c = cm.Dealer__c;
            rpt.Vehicle__c = cm.Vehicle__c;
            
            cr = callIdResolutions.get(rpt.Resolution_Id__c);
            if (cr != null) {
                rpt.Resolution_Created_Date__c = String.valueOf(cr.CreatedDate);
                rpt.Call_Resolution__c = cr.Id;
            }
        }
    }
}