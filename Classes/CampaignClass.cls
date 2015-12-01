/**********************************************************************
Name: CampaignClass
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Whenever new Campaign is created of any Record Type,
only new campaign should be active else other old 
campaigns becomes inactive of the samne Record Type.

Related Trigger: Campaign_After
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/11/2011 Created
***********************************************************************/

public class CampaignClass{ 

	/* 
		Returns campaign list of same record type as of newCamp.
		Also updates the IsActive and EndDate.
	*/
	public static List<Campaign> updateCampaign(Campaign newCamp, List<Campaign> campaignList) {
		List<Campaign> campaigns = new List<Campaign>();
		for (Campaign campaign : campaignList) { 
			if (campaign.RecordTypeId == newCamp.RecordTypeId) {
				if (campaign.id != newCamp.Id) {
					campaign.IsActive = false;
					campaign.EndDate = system.Today(); 
				}
        		if (campaign.id == newCamp.Id) {
                	campaign.IsActive = true;
            	}
            	campaigns.add(campaign);
			}
        }
        return campaigns;
	}            
}