/**********************************************************************
Name: Campaign_After
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever new Campaign is created on any record type,
only new campaign should be active else other old 
campaigns becomes inactive
 
Related Class : CampaignClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/10/2011 Created
1.1 - Mohd Afraz Siddiqui 01/11/2011 Incorporated Code Comments and Headers
***********************************************************************/

trigger Campaign_After on Campaign (after insert) {
    Map<id, Campaign> toUpdateCamMap = new Map<id, Campaign>();
    List<Campaign> campListUpdate = new List<Campaign>();
    List<Id> recordTypes = new List<Id>();
   
    /* 
        Storing Campaign Record types
    */     
    for (Campaign camp : Trigger.new) { 
        recordTypes.add(camp.RecordTypeId);
    }
   
    /* 
        Fetch all Campaign records
    */
     List<Campaign> campaignList = [Select RecordTypeId, IsActive, EndDate, id from Campaign 
                                 where RecordTypeId in : recordTypes AND IsActive =: TRUE];
     
    /*
       Update campaign records and put them in List
    */
     
     for (Campaign camp : Trigger.new) {
        List<Campaign> campaigns = CampaignClass.updateCampaign(camp, campaignList);
        for (Campaign campRec : campaigns) {
            if (toUpdateCamMap.get(campRec.id) == null) {
                toUpdateCamMap.put(campRec.id, campRec);
                campListUpdate.add(campRec);
            }
        }
    }                           
    
    /* 
        Update Campaign records
    */
    try {
        if (campListUpdate.size() > 0) {
            update campListUpdate;
        }
    }
    catch (DMLException e) {
        for (Campaign campRec: Trigger.new) {
            campRec.addError(system.label.Exception_occured_while_inserting_Campaign + e.getMessage());
        }
    }      
}