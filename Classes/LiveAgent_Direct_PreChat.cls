/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class is used as an intermediate step for retrieving all the pre chat 
fields and routing the request to the right department

Class:              LiveAgent_Direct_PreChat
Author:             Rohdenburg
Date:               10/08/2013
Version:            1.0
Last Updated:       12/14/2013
    * 10/08/2013    SR - Created
    * 12/13/2013    SR - Modified the way that the data is retrieved. 
                    Previously, it was using a cookie, now the IP.
    * 12/14/2013    SR - Modifed the CompletedName property.
    * 01/16/2014    SR - Retrieved the session id using an API function
    * 07/30/2014    SR - Included the Dealer Code
*/

public class LiveAgent_Direct_PreChat
{
    // -------- Constants --------
    private final String COOKIE_NAME = 'LiveAgentSession';
    private final String LIVE_AGENT_ROUTING = 'liveagent.prechat.buttons';
    private final String PARAMETER_ACCOUNT = 'liveagent.prechat:Account Id';
    private final String PARAMETER_SAVE_ACCOUNT = 'liveagent.prechat:Account Id';
    private final String PARAMETER_DEALER = 'liveagent.prechat:Dealer Code';
    private final String PARAMETER_DEALER_SAVE = 'liveagent.prechat.save:Dealer Code';
    
    
    // -------- Constructor --------
    public LiveAgent_Direct_PreChat(){
        isSuccess = false;
    }

    // -------- Variables --------
    private ValidationUtility dataCheck = new ValidationUtility();
    
    // -------- Properties --------
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String zipCode {get; set;}
    public String dealerCode {get; set;}
    public String emailAddress {get; set;}
    public String phone {get; set;}
    public String accountId {get; set;}
    public String buttonSkillId {get; set;}
    public String preChatDataId {get; set;}
    public String parameterSkill {get; set;}
    public String parameterAccount {get; set;}
    public String parameterSaveAccount {get; set;}
    public String parameterDealerCode {get; set;}
    public String parameterDealerCodeSave {get; set;}
    
    public String sessionKey {get; set;}
    public String setToAction {get; set;}
    public Boolean isSuccess {get; set;}
    
    // -------- Methods --------
    public void retrievePreChatInfo(){
        try 
        {
            parameterSkill = 'nonInformedButton';
            parameterAccount = 'nonInformedAccount';
            parameterSaveAccount = 'nonInformedSaveAccount';
            
            retrieveCurrentData(sessionKey);
            isSuccess = true;
        }
        catch (Exception ex) {
            //Continue without sending hover
            //TODO: Log the error
        }
    }
    
    //It looks for the Chat Data by the sessionId
    private void retrieveCurrentData(String sessionId) {
        List<Pre_Chat_Data__c> currentData = [SELECT Id, First_Name__c, 
            Last_Name__c, Zip_Code__c, Email_Address__c, Phone__c, 
            AccountId__c, Clicked_Chat_Button__c, Session_Id__c,
            Dealer_Code__c
            FROM Pre_Chat_Data__c
            WHERE Session_Id__c = :sessionId];
            
        if (currentData != null && currentData.size() > 0) {
            preChatDataId = currentData[0].Id;
            firstName = currentData[0].First_Name__c;
            lastName = currentData[0].Last_Name__c;
            zipCode = currentData[0].Zip_Code__c;
            emailAddress = currentData[0].Email_Address__c;
            phone = currentData[0].Phone__c;
            
            
            if (!dataCheck.IsStringNullOrEmpty(currentData[0].AccountId__c)) {
                parameterAccount = PARAMETER_ACCOUNT;
                parameterSaveAccount = PARAMETER_SAVE_ACCOUNT;
                accountId = currentData[0].AccountId__c;
            }
            
            // If the chat button is informed, the request needs to be routed to a
            // different department that the original department
            if (!dataCheck.IsStringNullOrEmpty(currentData[0].Clicked_Chat_Button__c)) {
                parameterSkill = LIVE_AGENT_ROUTING;
                buttonSkillId = currentData[0].Clicked_Chat_Button__c;
            }
            
            if (!dataCheck.IsStringNullOrEmpty(currentData[0].Dealer_Code__c)) {
                parameterDealerCode = PARAMETER_DEALER;
                parameterDealerCodeSave = PARAMETER_DEALER_SAVE;
                dealerCode = currentData[0].Dealer_Code__c;
            }
        }       
    }
    
    // -------- Test --------
    static testMethod void ClassTest()
    {
        LiveAgent_Direct_PreChat ladp = new LiveAgent_Direct_PreChat();
        ladp.retrievePreChatInfo();
    }
}