/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

For the Nissan Outbound / Inbound calls, this class creates a script link based
on value assigned from the initializing class. This script link is for loading
the appropriate ForceFlow presentation that is read through for the customer.

Initialized in Controller_AgentConsole_CM

Class:              ForceFlowScriptURL
Author:             JJ Heldman
Date:               02/28/12
Version:            1
Last Updated:       02/28/12
    * Stubbed
    * Completed
    * 04/02/12  JJ  Bug fix, the campaign member id was not properly passed
        in the url
    * 09/28/15  WT  Add _Cloud when label for ScriptURLuseNew is 'yes'
//////// TODO ////////
Make the constants labels to the design of everything else
*/

public with sharing class ForceFlowScriptURL
{
    // -------- Constants --------
    // Campaign Names
    private final string IEE = 'Infiniti English Evening';
    private final string IED = 'Infiniti English Day';
    private final string NEE = 'Nissan English Evening';
    private final string NED = 'Nissan English Day';
    private final string ISD = 'Infiniti Spanish Day';
    private final string ISE = 'Infiniti Spanish Evening';
    private final string NSE = 'Nissan Spanish Evening';
    private final string NSD = 'Nissan Spanish Day';
    private final string NCV = 'NCV English Day';
    private final string NCINEE = 'NCI Nissan English Evening';
    private final string NCINED = 'NCI Nissan English Day';
    private final string NCINFD = 'NCI Nissan French Day';
    private final string NCINFE = 'NCI Nissan French Evening';
    private final string NCIIED = 'NCI Infiniti English Day';
    private final string NCIIEE = 'NCI Infiniti English Evening';
    private final string NCIIFD = 'NCI Infiniti French Day';
    private final string NCIIFE = 'NCI Infiniti French Evening';
    
    // -------- Constructor --------
    public ForceFlowScriptURL(){}
    
    // -------- Variables --------
    // None
    
    // -------- Properties --------
    // Value for assigning campaign name used with the ScriptURL method with
    // no parameters
    public string CampaignName {get; set;}
    public string CampaignMemberID {get; set;}
    
    // -------- Methods --------
    // Create script url
    private string CreateScriptURL(string campaignName)
    {
        string scriptURL;
    
        if(campaignName == IEE || campaignName == IED)
        {
            scriptURL = label.ScriptUrlInfinitiEnglish +'&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NEE || campaignName == NED)
        {
            scriptURL = label.ScriptURLNissanEnglish +'&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == ISE || campaignName == ISD)
        {
            scriptURL = label.ScriptUrlInfinitiSpanish +'&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NSE || campaignName == NSD)
        {
            scriptURL = label.ScriptURLNissanSpanish +'&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NCV)
        {
            scriptURL = label.ScriptUrlNCV +'&CampaignMemberID='  + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NCINEE || campaignName == NCINED)
        {
            scriptURL = label.ScriptURLNCINissanEnglish + '&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NCINFD || campaignName == NCINFE)
        {
            scriptURL = label.ScriptURLNCINissanFrench + '&CampaignMemberID=' + 
                CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NCIIED || campaignName == NCIIEE)
        {
            scriptURL = label.ScriptURLNCIInfinitiEnglish + '&CampaignMemberID=' 
                + CampaignMemberID + '&UserId=' + UserInfo.getUserId(); 
        }
        else if(campaignName == NCIIFD || campaignName == NCIIFE)
        {
            scriptURL = label.ScriptURLNCIInfinitiFrench + 
                '&CampaignMemberID=' + CampaignMemberID + '&UserId=' + 
                UserInfo.getUserId(); 
        }
        if (label.ScriptURLuseNew == 'yes') {
           Pattern p = Pattern.compile('.*sparkID=(.*)&[Cc]ampaign.*');  // extract camp used
            Matcher pm = p.matcher(scriptURL);
            if( pm.matches() )
            {
                Boolean labelContainsCamp = false;
                System.debug(pm.group(1));
                List<String> labelvalues = label.ScriptURLuseNewValues.split('\\,');
                if (labelvalues.size() > 0) {
                    for(String ss: labelvalues) {
                       if(ss== pm.group(1)) { labelContainsCamp = true; }
                    }
                    if (labelContainsCamp) {
                        scriptURL = scriptURL.replace('&CampaignMemberID=','_Cloud&CampaignMemberId=');
                    }
                }
                
            }
           

        }
        System.debug(scriptURL);
        return scriptURL;
    }
    
    // Retrieve the script url based on the CampaignName property
    public string ScriptURL()
    {
        string scriptURL = 'Assign the CampaignName and CampaignMemberID ' + 
            'before using this method.';
        
        if(CampaignName != null && CampaignMemberID != null)
            scriptURL = CreateScriptURL(CampaignName);
        
        return scriptURL;
    }
    
    // -------- Test --------
    // Test script url creations
    static testMethod void ClassTest()
    {
        string scriptURLProperty;
        string scriptURLMethod;
        ForceFlowScriptURL testClass = new ForceFlowScriptURL();
        
        testClass.CampaignMemberID = '888';
        testClass.CampaignName = 'Infiniti English Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Infiniti English Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Nissan English Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Nissan English Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Infiniti Spanish Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Infiniti Spanish Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Nissan Spanish Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'Nissan Spanish Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCV English Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Nissan English Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Nissan English Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Nissan French Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Nissan French Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Infiniti English Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Infiniti English Day';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Infiniti French Evening';
        scriptURLProperty = testClass.ScriptURL();
        testClass.CampaignName = 'NCI Infiniti French Day';
        scriptURLProperty = testClass.ScriptURL();
    }
}