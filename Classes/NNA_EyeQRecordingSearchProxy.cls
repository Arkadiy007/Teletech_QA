/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2013, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Class:              NNA_EyeQRecordingSearchProxy
Author:             Deepak Williams (Adapted for Nissan by Jeremy Vitzthum)
Date:               12/18/2014
Version:            1
Last Updated:       12/18/2014
    * MM/DD/YY Name Note
    
This class is a proxy to access the ESB service to get the EyeQ360 recording 
id for a specific agent id when available. In case of an exception, 
the exceptionMessage property contains the detail. The class can be tested 
using the unit test companion class Test_EQ_RecordingSearchProxy.
*/

public class NNA_EyeQRecordingSearchProxy 
{
    // -------- Constants --------
    private final static String CALLOUT_INVALID_AGENT_ID = '11111';
    private final static String CALLOUT_VALID_RETURN_VALUE = '999999999';   
    private final static String CALLOUT_EXCEPTION_RETURN_VALUE = '-99999';
    private final static String CALLOUT_EXCEPTION_ERROR_CODE = '-99999';
    private final static String CALLOUT_EXCEPTION_ERROR_MSG = 'Unable to ' + 
        'retrieve EyeQ recording id.'; 
    private final static integer EYEQ_SERVICE_TIMEOUT = 59000;
    
    // Nissan Tenant for EyeQ instance
    private final static string EYEQ_SERVICE_TENANT_ID = '2';
    
    // -------- Constructor --------
    public NNA_EyeQRecordingSearchProxy(){}
   
    // -------- Variables --------
    // None
    
    // -------- Properties --------
    public boolean useProxy 
    {
        get 
        {
            if (useProxy == null) useProxy = (System.label.Activate_Test_Mode == 'true');
            return useProxy;  
        }
        set;
    }
    
    // -------- Methods --------
    // Search by user's Agent Id and set the values to the call record - 
    // if using proxy skip the call out and populate with defaults
    public void setRecordingId(String callRecordId, String AgentId) 
    {
 
        system.debug('AgentID: ' + AgentId);
        Task cr = new Task();
        cr.id = callRecordId;               
 
        try 
        { 
            if (AgentId==null) 
            {
                throw new Nullpointerexception();
            }
            
            if(useProxy) 
            {
                
                if (AgentId==CALLOUT_INVALID_AGENT_ID) 
                {
                    cr.EyeQ_Error_Code__c = CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG;
                    cr.Call_Recording_ID__c = CALLOUT_EXCEPTION_RETURN_VALUE;
                }
                else { 
                    cr.EyeQ_Error_Code__c = null;
                    cr.Call_Recording_ID__c = CALLOUT_VALID_RETURN_VALUE;
                }
                
                update cr;              
            } 
            else 
            {
                NNA_EyeQRecordingServiceWSDL.RecordingServiceSOAP recordingService = 
                    new NNA_EyeQRecordingServiceWSDL.RecordingServiceSOAP();
                recordingService.timeout_x = EYEQ_SERVICE_TIMEOUT;
                recordingService.endpoint_x = System.label.EyeQ_Recording_Service_EndPoint;
                                
                recordingService.header = new NNA_EyeQRecordingServiceWSDL.Header_element();
                recordingService.header.tenant = EYEQ_SERVICE_TENANT_ID;
                
                setRecordingIdFromWS(callRecordId, integer.valueof(AgentId));
            }
        }  
        catch (Exception e) 
        {
            System.debug(CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG);
            cr.EyeQ_Error_Code__c = CALLOUT_EXCEPTION_ERROR_CODE + ': ' + CALLOUT_EXCEPTION_ERROR_MSG;
            cr.Call_Recording_ID__c = CALLOUT_EXCEPTION_RETURN_VALUE;
            update cr;              
        }
    }
    
    // Search by user's Agent Id
    @future (callout=true)
    private static void setRecordingIdFromWS(string callRecordId, integer loginId) 
    {
        try 
        {
            Task cr = new Task();
            cr.id = callRecordId;
            system.debug('Call Record ID' + callRecordId);
            
            NNA_EyeQRecordingServiceWSDL.RecordingServiceSOAP recordingService = 
                new NNA_EyeQRecordingServiceWSDL.RecordingServiceSOAP();
            recordingService.timeout_x = EYEQ_SERVICE_TIMEOUT;
            recordingService.endpoint_x = System.label.EyeQ_Recording_Service_EndPoint;           
            recordingService.header = new NNA_EyeQRecordingServiceWSDL.Header_element();
            recordingService.header.tenant = EYEQ_SERVICE_TENANT_ID;
            
            system.debug(recordingService.getRecordingId(loginId));
            
            NNA_EyeQRecordingServiceWSDL.GetRecordingIdResponse_element respElement = recordingService.getRecordingId(loginId);
            
            if (respElement.GetRecordingIdResult < 1) 
            {
                if (respElement.result != null) 
                {
                    cr.EyeQ_Error_Code__c = respElement.result.errorCode + ': ' + respElement.result.errorMsg;
                    system.debug('Error Code: '+ cr.EyeQ_Error_Code__c);
                }
            }
            
            cr.Call_Recording_ID__c = string.valueof(respElement.GetRecordingIdResult);
            system.debug('Recording ID:' + cr.Call_Recording_ID__c);
            update cr;
        }  
        catch (Exception e) 
        {
            throw e;
        }
    }
}