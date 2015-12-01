/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2013, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller used by the post-chat form (live agent feature)

Class:              LiveAgent_PostChat
Author:             Rohdenburg S.
Date:               05/13/2013
Version:            1.0
Last Updated:       01/11/2014
    * 05/13/2013    SR - Stubbed
    * 05/17/2013    SR - Included the upload feature 
    * 05/29/2013    SR - Cleaned up
    * 06/12/2013    SR - Moved the Survey RecordTypeId to a custom Label
    * 07/05/2013    SR - Cleaned up according to the Code Review
    * 01/11/2014    SR - Improved the association with the Surveys
    * 01/28/2015    Arkadiy Sychev - Fixed bugs with possible NullPointerExceptions
*/

public class LiveAgent_PostChat
{
    // -------- Constants --------
    private final String PARAMETER_START_TIME = 'startTime';
    private final String PARAMETER_VISITOR_IP = 'X-Salesforce-SIP';
    private final String ERROR_SAVING_SURVEY = 'There was an error saving ' + 
        'the survey';
    private final String EXIT_PAGE = 'LiveAgentExit';
    private final String NISSAN_NEW_EXIT_PAGE = 'LiveAgent_NewNissanExit';
    private final String INFINITI_EXIT_PAGE = 'LiveAgent_InfinitiExit';
    private final String INFINITI_NEW_EXIT_PAGE = 'LiveAgent_NewInfinitiExit';
    private final String LEAF_NEW_EXIT_PAGE = 'LiveAgent_NewLeafExit';
    private final String NCV_EXIT_PAGE = 'LiveAgent_NCVExit';
    private final String SURVEY_TYPE = 'Live Agent';
    private final String DPIC_EXIT_PAGE = 'LiveAgent_DPICExit';
    
    // -------- Constructor --------
    public LiveAgent_PostChat(){
        retrieveTheInformedStartDate();
    }

    // -------- Variables --------
    private ValidationUtility dataCheck = new ValidationUtility();
    
    // -------- Properties --------
    public DateTime startDateTime {get; set;}
    public String concernSatisfied {get; set;}
    public String concernComments {get; set;}
    public String experienceSatisfied {get; set;}
    public String experienceComments {get; set;}
    public String recommended {get; set;}
    public String recommendedComments {get; set;}
    
    // -------- Methods --------
    // It records the survey and redirects you to the Exit Page
    public PageReference submitPostChatForm()
    {
        return submitSurvey(EXIT_PAGE);
    }
    
    public PageReference submitInfinitiForm() {
        return submitSurvey(INFINITI_EXIT_PAGE);
    }
    
    public PageReference submitNewNissanForm() {
        return submitSurvey(NISSAN_NEW_EXIT_PAGE);
    }
    
    public PageReference submitNewInfinitiForm() {
        return submitSurvey(INFINITI_NEW_EXIT_PAGE);
    }
    
    public PageReference submitNewLeafForm() {
        return submitSurvey(LEAF_NEW_EXIT_PAGE);
    }
    
    public PageReference submitNCV() {
        return submitSurvey(NCV_EXIT_PAGE);
    }

    public PageReference submitDpic(){
        return submitSurvey(DPIC_EXIT_PAGE);
    }
    
    private PageReference submitSurvey(string pageExitName)
    {
        insertSurvey();

        PageReference pageRef = new PageReference(getExitUrl(pageExitName));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // It inserts the survey record
    private void insertSurvey()
    {
        Surveys__c currentSurvey = new Surveys__c();
        currentSurvey.Live_Agent_Concern_Satisfied__c = concernSatisfied;
        currentSurvey.Live_Agent_Concern_Comments__c = concernComments;
        currentSurvey.Live_Agent_Experience_Satisfied__c = experienceSatisfied;
        currentSurvey.Live_Agent_Experience_Comments__c = experienceComments;
        currentSurvey.Live_Agent_Recommended__c = recommended;
        currentSurvey.Live_Agent_Recommended_Comments__c = recommendedComments; 
        currentSurvey.Live_Agent_Visitor_IP__c = 
            ApexPages.currentPage().getHeaders().get(PARAMETER_VISITOR_IP);
        currentSurvey.Live_Agent_Chat_Session_Start_Time__c = startDateTime;
        currentSurvey.RecordTypeId = Label.LiveAgent_SurveyRecordTypeId;
        currentSurvey.Survey_Type__c = SURVEY_TYPE;

        Database.SaveResult result = Database.insert(currentSurvey);
        
        if (result.isSuccess()) {
            AssociateToTranscript(currentSurvey);
        } 
    }

    // It associates the Survey object to the Transcript object
    private void AssociateToTranscript(Surveys__c currentSurvey) {
        List<LiveChatTranscript> chatSessions = [
            SELECT Id, Survey__c, AccountId, StartTime
            FROM LiveChatTranscript 
            WHERE IpAddress = :currentSurvey.Live_Agent_Visitor_IP__c
            AND Survey__c = null
            ORDER BY CreatedDate DESC
            LIMIT 1];

        if (chatSessions.size() > 0) {
         Decimal MinDiff;
            if (currentSurvey.Live_Agent_Chat_Session_Start_Time__c == null) {
                // Arkadiy Sychev - CreatedDate is not automatically populated in the object after insert. But ID does.
                // Retrieving newly inserted object from DB to get it's CreatedDate
                List<Surveys__c> currentSurveyDate = [Select CreatedDate from Surveys__c where Id= :currentSurvey.Id LIMIT 1];
                if (currentSurveyDate.size()==0) {
                    return;
                }

                minDiff = (currentSurveyDate[0].CreatedDate.getTime() - chatSessions[0].StartTime.getTime()) / 60000;
                
                //If the Start Time is empty we define a limit of 30 mins
                if (minDiff >= -30 && minDiff <= 30) {
                    currentSurvey.Live_Chat_Transcript__c = chatSessions[0].Id;
                    currentSurvey.Customer__c = chatSessions[0].AccountId;
                    update currentSurvey;
        
                    chatSessions[0].Survey__c = currentSurvey.Id;
                    update chatSessions[0];
                }
            }
            else {
                // Arkadiy Sychev - Confirming that all required data is present and we won't get NullPointerException.
                if (currentSurvey.Live_Agent_Chat_Session_Start_Time__c == null || chatSessions[0].StartTime == null) {
                    return;
                }

                minDiff = (currentSurvey.Live_Agent_Chat_Session_Start_Time__c.getTime() - chatSessions[0].StartTime.getTime()) / 60000;
                
                //In some cases the start time has presented a difference of some minutes
                if (minDiff >= -15 && minDiff <= 15) {
                    currentSurvey.Live_Chat_Transcript__c = chatSessions[0].Id;
                    currentSurvey.Customer__c = chatSessions[0].AccountId;
                    update currentSurvey;
        
                    chatSessions[0].Survey__c = currentSurvey.Id;
                    update chatSessions[0];
                }
            }
        }
    }
    
    // It retrieves the informed Start Time paramete
    private void retrieveTheInformedStartDate() {
        if (Apexpages.CurrentPage().getParameters().containsKey(
        PARAMETER_START_TIME)) {
            String startValue = Apexpages.CurrentPage().getParameters().get(
                PARAMETER_START_TIME);
                
            if (!dataCheck.IsStringNullOrEmpty(startValue) && startValue != 'null') {
                startDateTime = DateTime.newInstance(Long.valueOf(startValue));
            }
        }
    }
    
    //It obtains the URL of the Exit Page dinamically 
    private String getExitUrl(string pageExitName) {
        String exitUrl = URL.getCurrentRequestUrl().toExternalForm();
        Integer lastIndex = exitUrl.lastIndexOf('/');
        exitUrl = exitUrl.substring(0, lastIndex + 1);
        exitUrl += pageExitName;
        
        return exitUrl;
    }
}