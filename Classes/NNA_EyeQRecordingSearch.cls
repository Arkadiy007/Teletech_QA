global with sharing class NNA_EyeQRecordingSearch 
{
    
  
    // -------- Constants --------
    private final static String CALLOUT_EXCEPTION_RETURN_VALUE = '-99999';
    private final static String CALLOUT_EXCEPTION_ERROR_CODE = '-99999';
    private final static String CALLOUT_EXCEPTION_ERROR_MSG = 'Unable to retrieve EyeQ recording id.';
  
    // -------- Constructor --------
    public NNA_EyeQRecordingSearch(){}
    
    // -------- Variables --------
    private class RecordingNotFoundException extends Exception {}
    private NNA_EyeQRecordingSearchProxy serviceProxy = new NNA_EyeQRecordingSearchProxy();    
  
    // -------- Properties --------
    // None
  
    // -------- Methods --------
    // Get current user's profile from db.
    private String getAgentId() 
    {
        User currentUser = [SELECT cnx__Agent_ID__c FROM USER 
        WHERE Id = :UserInfo.getUserId()];
        return currentUser.cnx__Agent_ID__c;
    }
  
    // Search by user's Agent Id and set the values to the call record
    
    public void setRecordingId(String callRecordId, String AgentId) 
    {
      
      try 
      {
        if (AgentId == null) 
        {
          AgentId = getAgentId();        
        
          if (AgentId==null)
          {
            throw new RecordingNotFoundException();
          }
        }
            
        // Instantiate and call Web Service Proxy using Agent Id
        serviceProxy.setRecordingId(callRecordId, AgentId);
      }  
      catch (Exception e) 
      {
          System.debug(CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG);      
          Task cr = new Task();
          cr.id = callRecordId;        
          cr.EyeQ_Error_Code__c = CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG;
          cr.Call_Recording_ID__c = CALLOUT_EXCEPTION_RETURN_VALUE;
          update cr;        
      }
    }
    
    //Remote action called by the NNA_SM_CTI_ENHANCEMENT VFP to retrieve
    //the call recording ID when the call record is created by the B+S gadget.
    @RemoteAction
    global static string remoteRecordingId(string callRecordId)
    {
        User currentUser = [SELECT cnx__Agent_ID__c FROM USER 
        WHERE Id = :UserInfo.getUserId()];
        
        String AgentId = currentUser.cnx__Agent_ID__c;
        String returnString = 'Complete';
        NNA_EyeQRecordingSearchProxy serviceProxy = new NNA_EyeQRecordingSearchProxy();
        
        try 
      {
                
        
        if (AgentId==null)
        {
          throw new RecordingNotFoundException();
        }
        
            
        // Instantiate and call Web Service Proxy using Agent Id
        serviceProxy.setRecordingId(callRecordId, AgentId);
      }  
      catch (Exception e) 
      {
          System.debug(CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG);      
          Task cr = new Task();
          cr.id = callRecordId;        
          cr.EyeQ_Error_Code__c = CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG;
          cr.Call_Recording_ID__c = CALLOUT_EXCEPTION_RETURN_VALUE;
          update cr;        
      }
        
      return returnString;
    }
    
    
}