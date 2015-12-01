/**********************************************************************
Name: Campaign_After_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of trigger "Campaign_After".

Related to:Campaign_After and CampaignClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Biswa Ray 01/20/2011 Created

***********************************************************************/

@isTest
private Class Campaign_After_Test{
    
    static testMethod void testTrigger() {
        // Insert an initial Campaign
        Campaign initCampaign = new Campaign();
        initCampaign.Name = 'InitCampaign';
        initCampaign.Isactive = true;
        initCampaign.StartDate = Date.newInstance(1979, 1, 1);
        initCampaign.EndDate = Date.newInstance(1979, 2, 2);
        insert initCampaign;

        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        Test.startTest();

        // Insert the Campaign records that cause the trigger to execute.
        Campaign objCampaign = new Campaign();
        objCampaign.Name = 'TestCampaign';
        objCampaign.Isactive = true;
        objCampaign.StartDate = Date.newInstance(1980, 1, 1);
        objCampaign.EndDate = Date.newInstance(1980, 2, 2);
        insert objCampaign;
             
        // Stop the test, this changes limit context back to test from trigger. 
        Test.stopTest();

        // Query the database for the newly inserted records. 
        objCampaign = [select Id, RecordTypeId from Campaign where name = 'TestCampaign'];
        List<Campaign> campaignList = [select id, IsActive from Campaign where IsActive = true AND EndDate != null and RecordTypeId = :objCampaign.RecordTypeId];
       
        // Assert that the there is only one active campaign present in the database for the record type used and
        // that it is the second one inserted.
        system.assert(campaignList.size() == 1 && campaignList[0].Id == objCampaign.Id);
    }
}