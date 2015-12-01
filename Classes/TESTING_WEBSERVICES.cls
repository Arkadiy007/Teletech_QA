/**********************************************************************
Name: TESTING_WEBSERVICES
Copyright Â© notice: Nissan Motor Company
======================================================
Purpose:
Tests TMS Web Service Calls.

Related Page : TESTING_WEBSERVICES
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Stephen Goldberg 12/27/2010 Created
1.1 - Sonali Bhardwaj 12/28/2010 Added code for rest of Web-Service Calls.
***********************************************************************/

public with sharing class TESTING_WEBSERVICES {
    public nissanoneToOneNnanetComCallcentre.CallCentreSoap ccp = new nissanoneToOneNnanetComCallcentre.CallCentreSoap();
    public string token;
    public string dealerInfo {get; set;}
    public string appointmentTime{get; set;}
    public string log{get; set;}
    public string servicesDue{get; set;}
    public string primaryContactInfo{get; set;}
    public boolean ping{get; set;}
    public string appointment{get; set;}
    public string callResolution{get; set;}
    public string serviceHistory{get; set;}
    public string communicationHistory{get; set;}
    public string securityToken{get; set;} 
    public string appointmentSubscribeURL{get; set;}
    public string associatedCustomers{get; set;}
    public string dealers{get; set;}
    public string version{get; set;}
    public string customers{get; set;}
    public string associated_dcno_id{get; set;}
    
    /*
        Gets Security Token for user.
    */
    
    public TESTING_WEBSERVICES(){ 
        
    }
    
    public TESTING_WEBSERVICES(ApexPages.StandardController controller){ 
        token = ccp.GetSecurityToken('teletech', 'teletech1');
    }
    
    /*
        Runs GetDealerInfo.
    */
    public void RunGetDealerInfo() {
        dealerInfo = ccp.GetDealerInfo('5049', token);
       
    }
    
    /*
        Runs CheckAppointmentTime.
    */
    public void RunCheckAppointmentTime() {
        string xml = '<appointment><DealerCode> 5049 </DealerCode> <RequestDate>04/30/2011</RequestDate></appointment>'; 
        appointmentTime = ccp.CheckAppointmentTime(xml, token);
    }
    
    /*
        Runs GetLog.
    */
    public void RunGetLog() {
        log = ccp.GetLog(token);
    }
    
    /*
        Runs GetServicesDue.
    */
    public void RunGetServicesDue() {
        ServicesDue =  ccp.GetServicesDue('58085652', token);
    }
    
    /*
        Runs GetPrimaryContactInfo.
    */
    public void RunGetPrimaryContactInfo() {
        PrimaryContactInfo =  ccp.GetPrimaryContactInfo(58083160, token);
        
    }
    
    /*
        Runs Ping.
    */
    public void RunPing() {
        Ping =  ccp.Ping();
    }
    
    /*
        Runs CheckAppointment.
    */
    public void RunCheckAppointment() {
        string xml = '<appointment><DealerCode>5049</DealerCode><RequestDate>04/30/2005</RequestDate><RequestTime>08:00:00</RequestTime></appointment>';
        Appointment =  ccp.CheckAppointment(xml, token);
    
    }
    
    /*
        Runs CallResolution.
    */
    public void RunCallResolution() {
        string xml = '<Resolution id="1">' + 
                        '<AgentID>199129</AgentID>' + 
                        '<CallCentreID>5</CallCentreID>' +
                        '<CallStatus>3</CallStatus>' +
                        '<CallDuration>120</CallDuration>' +
                        '<CallDate>2005-01-24</CallDate>' +
                        '<CallTime>19:45:13</CallTime>' +
                        '<CallBackDate Daytime="true">2005-12-03</CallBackDate>' +
                        '<CallPhone>' +
                            '<area>415</area>' +
                            '<exchange>555</exchange>' +
                            '<line>1234</line>' +
                        '</CallPhone>' +
                        '<Feedback>' +
                            '<PMGChange>Light</PMGChange>' +
                            '<PrefDealerChange>4458</PrefDealerChange>' +
                            '<PrefDealerChangeReason>Closer to home</PrefDealerChangeReason>' +
                            '<CustomerComments>' +
                                'Customer loves the service at' +
                                'Joe\'s Nissan. "Amazing", he said.' +
                            '</CustomerComments>' +
                            '<Question1>Y</Question1>' +
                            '<Question2>Y</Question2>' +
                            '<Satisfaction>2</Satisfaction>' +
                            '<CommentAudience>2</CommentAudience>' +
                            '<VoxFile>123456.vox</VoxFile>' +
                            '<CustomerExperience>1</CustomerExperience>' +
                        '</Feedback>' +
                        '<customer>' +
                            '<deceased>Y</deceased>' +
                            '<title>Mr.</title>' +
                            '<firstname>John</firstname>' +
                            '<middlename>Harry</middlename>' +
                            '<lastname>Smith</lastname>' +
                            '<address type="home">' +
                                '<address1>123 Main Street</address1>' +
                                '<address2>Apt 102</address2>' +
                                '<city>Anytown</city>' +
                                '<stateprov>CA</stateprov>' +
                                '<country>USA</country>' +
                                '<postalzip>90210-1111</postalzip>' +
                            '</address>' +
                            '<language>en-US</language>' +
                            '<phone type="home" seq="1" consent="true">' +
                                '<area>415</area>' +
                                '<exchange>555</exchange>' +
                                '<line>1234</line>' +
                            '</phone>' +
                            '<phone type="work" seq="2" consent="true">' +
                                '<area>415</area>' +
                                '<exchange>555</exchange>' +
                                '<line>1234</line>' +
                                '<ext>557</ext>' +
                            '</phone>' +
                            '<phone type="mobile" seq="3" consent="true">' +
                                '<area>415</area>' +
                                '<exchange>555</exchange>' +
                                '<line>1234</line>' +
                            '</phone>' +
                            '<email type="home" consent="true">johnsmith1234@hotmail.com</email>' +
                            '<email type="work" consent="true">john.smith@tmsw.com</email>' +
                            '</customer>' +
                            '<vehicle>' +
                                '<odometer units="M">9988</odometer>' +
                            '</vehicle>' +
                            '<preferences>' +
                                '<prefphone>home</prefphone>' +
                                '<prefmail>mail</prefmail>' +
                                '<prefcalltime>E</prefcalltime>' +
                            '</preferences>' +
                            '<AppointmentRequest>' +
                                '<DealerCode>33B0</DealerCode>' +
                                '<RequestDate>2005-04-30</RequestDate>' +
                                '<RequestTime>08:00:00</RequestTime>' +
                                '<ActionType>1</ActionType>' +
                                '<ServiceDesc>Just an oil change</ServiceDesc>' +
                            '</AppointmentRequest>' +
                            '<AppointmentLead>' +
                                '<DealerCode>33B0</DealerCode>' +
                                '<ServiceDesc>Customer would like to know what services are due.</ServiceDesc>' +
                            '</AppointmentLead>' +
                            '<MiscellaneousRequest>' +
                            '<MailStop>' +
                                '<StartDate>2004-08-01</StartDate>' +
                                '<EndDate>2004-12-31</EndDate>' +
                            '</MailStop>' +
                        '<TempAway>' +
                            ' <StartDate>2004-08-01</StartDate>' +
                             '<EndDate>2004-12-31</EndDate>' +
                        '</TempAway>' +
                        '<SendEmailRequest type="ESRN" />' +
                        '</MiscellaneousRequest>' +
                        '<primary_maintainer never_change="no">' +
                            '<new_contact tmsw_cust_id="-1">' +      
                            '<firstname>John</firstname>  ' +   
                            '<lastname>Smith</lastname>' +
                            '<address type="home">' +
                                '<address1>123 Main Street</address1>' +
                                '<address2>Apt 102</address2>' +
                                '<city>Anytown</city>' +
                                '<stateprov>CA</stateprov>' +
                                '<country>USA</country>' +
                                '<postalzip>90210-1111</postalzip>' +
                            '</address>' +
                        '<phone type="home" seq="1">' +
                            '<area>415</area>' +
                            '<exchange>555</exchange>' +
                            '<line>1234</line>' +
                            '<ext>557</ext>' +
                        '</phone>' +
                        '<phone type="work" seq="2">' +
                            '<area>415</area>' +
                            '<exchange>555</exchange>' +
                            '<line>7777</line>' +
                            '<ext>888</ext>' +
                        '</phone>' +
                        '</new_contact>' +
                        '</primary_maintainer>' +
                        '</Resolution>';
        //string xml = '<Resolution id="1"></Resolution>';
                    
        
        CallResolution = ccp.CallResolution(xml, token);
    }
    
    /*
        Runs GetServiceHistory.
    */
    public void RunGetServiceHistory() {
        ServiceHistory = ccp.GetServiceHistory(58083160, token);
        
    }
    
    /*
        Runs GetCommunicationHistory.
    */
    public void RunGetCommunicationHistory() {
        CommunicationHistory = ccp.GetCommunicationHistory(58083160, token);
    }
    
    /*
        Runs GetSecurityToken.
    */
    public void RunGetSecurityToken() {
        securityToken = ccp.GetSecurityToken('teletech', 'teletech1');
    }
    
    /*
        Runs GetAppointmentSubscribeURL.
    */
    public void RunGetAppointmentSubscribeURL() {
        appointmentSubscribeURL = ccp.GetAppointmentSubscribeURL('5049', 58083160, 1, token);
    }
    
    /*
        Runs GetAssociatedCustomers.
    */
    public void RunGetAssociatedCustomers() {
        associatedCustomers = ccp.GetAssociatedCustomers(58083160, token);
    }
    
    /*
        Runs SearchDealer.
    */
    public void RunSearchDealer() {
        /*string xml = '<SearchDealer>' +
                        '<DealerName>CLAY NISSAN OF NEWTON</DealerName>' +
                    '</SearchDealer>' ;*/
        string xml = '<SearchDealer>' +
                        '<City>NASHVILLE</City>' +
                        //'<State>TN</State>' +
                         //'<PostalZipCode>37215-2122</PostalZipCode>' + 
                         //'<CustomerID>58058224</CustomerID>' +
                             '</SearchDealer>'; 

        dealers = ccp.SearchDealer(xml, token);
    }
    
    /*
        Runs GetVersion.
    */
    public void RunGetVersion() {
        version = ccp.GetVersion();
    }
    
    /*
        Runs SearchCustomer.
    */
    public void RunSearchCustomer() {
        string xml = '<SearchCustomer>' +
                        '<City>RANDOLPH</City>' +
                    '</SearchCustomer>' ;

        customers = ccp.SearchCustomer(xml, token);
    }
    
    /*
        Runs Getassociated_dcno_id.
    */
    public void RunGetassociated_dcno_id() {
        associated_dcno_id = ccp.Getassociated_dcno_id(58083160, token);
    }
    
   
}