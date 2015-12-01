/**********************************************************************
Name: TMS_Webservices_Utility
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Execute TMS Web Service Calls.

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 01/24/2011 Created
1.1 - Sonali Bhardwaj 01/24/2011 As per issue RONETELETECH-117 updated code to take
                                 valid address parameters.
1.2 - Sonali Bhardwaj 01/28/2011 Splitted code into separate functions so that it can be covered 
                                 by test class.
1.3 - JJ Heldman      02/08/2012 Modified for NCI by removing default user name and password and
                                 adding a setter for these values plus the endpoint  
1.4 - JJ Heldman
      Bruno Asis      03/02/2012 Fixed RunSearchDealer to fetch and send appropriate data,
                                 added a method for validating null/empty    
1.5 - JJ Heldman      06/28/2012 Changed query in RunGetAppointmentSubscribeURL to not check for
                                 an active campaign but rather pull from last campaign        
***********************************************************************/

public class TMS_Webservices_Utility {
    
    public static nissanoneToOneNnanetComCallcentre.CallCentreSoap ccp = new nissanoneToOneNnanetComCallcentre.CallCentreSoap();
    public static string userName = '';
    public static string password = '';
    public static string tokenError = system.label.tokenError;
    public static string prefferedDealerError = system.label.prefferedDealerError;
    public static string customerIdError = system.label.customerIdError;
    public static string dealerCodeError = system.label.dealerCodeError;
    public static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    public string appointmentDate {get; set;}
    public string appointmentTime {get; set;}
    
    /*
        Class to stores the name value pair.
    */
    public class Record {
        public string value{get; set;}
        public string param{get; set;}
        public Record(string p, string v) {
            value = v;
            param = p;
        }
    }
    
    /*
        Class to store the response of GetServicesDue.
    */
    public class ServiceResponse {
        public List<Record> records{get; set;}
        public List<string> services{get; set;}
    }
    
     /*
        Class to handle custom Exception.
    */
    public class WebServiceException extends Exception {
        
        
    }
    
    /*
        Class to store the response of GetServiceHistory
    */
    public class ServiceHistoryResponse {
        public List<Record> records{get; set;}
        public List<List<Record>> details{get; set;}
    }
    

    public static void CheckDealerCode(string dealerCode) {
        if (dealerCode == null || dealerCode.length() <= 0) {
                throw new WebServiceException(dealerCodeError);
        }
		TMS_Webservices_Utility utility = new TMS_Webservices_Utility();
    }
    
    public static void CheckToken(string token) {
        if (token == null || token.length() <= 0) {
                throw new WebServiceException(tokenError);
        }
    }
    
    public static void CheckCustomerId(string customerId) {
        if (customerId == null || customerId.length() <= 0) {
                throw new WebServiceException(customerIdError);
        }
    }
    /*
        Runs the GetDealerInfo Web-Service Call and parses the response.
    */
    public static List<Record> RunGetDealerInfo(string dealerCode) {
        string result = '';
        string token;
        CheckDealerCode(dealerCode);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse;
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else{
            result = ccp.GetDealerInfo(dealerCode , token);
        }
        return ParseGetDealerInfoResponse(result);
    }
    
    /*
        Parse the response of GetDealerInfo Web-Service call.
    */
    public static List<Record> ParseGetDealerInfoResponse(String result) {
        List<Record> records = new List<Record>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.dealer);
        if (root == null) {
            throw new WebServiceException(result);
        }
        Record codeRec = new Record(system.label.Dealer_Code, root.getAttribute(system.label.code));
        records.add(codeRec);
        for (XMLDom.Element child : root.childNodes) {
            Record rec = null;
            
            if (child.nodeName.equalsIgnoreCase(system.label.dealerid))
                rec = new Record(system.label.Dealer_Id, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.enrolled))
                rec = new Record(system.label.Enrolled1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.name))
                rec = new Record(system.label.Name1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.address1))
                rec = new Record(system.label.Addres1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.city))
                rec = new Record(system.label.City1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.stateprov))
                rec = new Record(system.label.State_Prov, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.country))
                rec = new Record(system.label.Country1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.postalzip))
                rec = new Record(system.label.Postal_Zip, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.general_phone))
                rec = new Record(system.label.General_Phone1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.general_fax))
                rec = new Record(system.label.General_Fax1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.general_email))
                rec = new Record(system.label.General_Email1, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.sales)){
                for (XMLDom.Element subchild : child.childNodes) {
                    Record subRecord = null;
                    if(subchild.nodeName.equalsIgnoreCase(system.label.phone))
                        subRecord = new Record(system.label.Sales_Phone, subchild.NodeValue);
                    if(subchild.nodeName.equalsIgnoreCase(system.label.hours)) {
                        String closed = subchild.getAttribute(system.label.closed);
                        if (closed != null && closed.equalsIgnoreCase(system.label.true))
                            subRecord = new Record(system.label.Sales_Day + subchild.getAttribute(system.label.day), system.label.closed);
                        else {
                            subRecord = new Record(system.label.Sales_Day  + subchild.getAttribute(system.label.day) + system.label.open, subchild.getAttribute(system.label.open));
                            records.add(subRecord);
                            subRecord = new Record(system.label.Sales_Day + subchild.getAttribute(system.label.day) + system.label.close, subchild.getAttribute(system.label.close));
                        }
                    }
                    records.add(subRecord); 
                }
            }
            else if(child.nodeName.equalsIgnoreCase(system.label.service)) {
                for (XMLDom.Element subchild : child.childNodes) {
                    Record subRecord = null;
                    if(subchild.nodeName.equalsIgnoreCase(system.label.phone))
                        subRecord = new Record(system.label.Service_Phone, subchild.NodeValue);
                    if(subchild.nodeName.equalsIgnoreCase(system.label.hours)) {
                        String closed = subchild.getAttribute(system.label.closed);
                        if (closed != null && closed.equalsIgnoreCase(system.label.true))
                            subRecord = new Record(system.label.Service_Day + subchild.getAttribute(system.label.day), system.label.closed);
                        else {
                            subRecord = new Record(system.label.Service_Day + subchild.getAttribute(system.label.day) + system.label.open, subchild.getAttribute(system.label.open));
                            records.add(subRecord);
                            subRecord = new Record(system.label.Service_Day  + subchild.getAttribute(system.label.day) + system.label.close, subchild.getAttribute(system.label.close));
                        }
                    }
                    records.add(subRecord); 
                }
            }
            else if(child.nodeName.equalsIgnoreCase(system.label.appointments)) {
                for (XMLDom.Element subchild : child.childNodes) {
                    Record subRecord = null;
                    if(subchild.nodeName.equalsIgnoreCase(system.label.phone))
                        subRecord = new Record(system.label.Appointment_Phone, subchild.NodeValue);
                    if(subchild.nodeName.equalsIgnoreCase(system.label.hours)) {
                        String closed = subchild.getAttribute(system.label.closed);
                        if (closed != null && closed.equalsIgnoreCase(system.label.true))
                            subRecord = new Record(system.label.Appointment_Day + subchild.getAttribute(system.label.day), system.label.Closed);
                        else {
                            subRecord = new Record(system.label.Appointment_Day + subchild.getAttribute(system.label.day) + system.label.open, subchild.getAttribute(system.label.open));
                            records.add(subRecord);
                            subRecord = new Record(system.label.Appointment_Day + subchild.getAttribute(system.label.day) + system.label.close, subchild.getAttribute(system.label.close));
                        }
                    }
                    records.add(subRecord); 
                }
            }
            else if (child.nodeName.equalsIgnoreCase(system.label.conveniences))
                rec = new Record(system.label.conveniences, child.NodeValue);
            else if (child.nodeName.equalsIgnoreCase(system.label.contact)) {
                for (XMLDom.Element subchild : child.childNodes) {
                    Record subRecord = null;
                    if (subchild.nodeName.equalsIgnoreCase(system.label.name))
                        subRecord = new Record(child.getAttribute(system.label.type) + system.label.name, subchild.NodeValue);
                    else if(subchild.nodeName.equalsIgnoreCase(system.label.email))
                        subRecord = new Record(child.getAttribute(system.label.type) + system.label.email, subchild.NodeValue);
                    else if(subchild.nodeName.equalsIgnoreCase(system.label.phone))
                        subRecord = new Record(child.getAttribute(system.label.type) + system.label.phone, subchild.NodeValue);
                    else
                        subRecord = new Record(child.getAttribute(system.label.type) + ' ' + subchild.nodeName, subchild.NodeValue);
                
                    records.add(subRecord);
                }
            }
            else {
                rec = new Record(child.nodeName, child.NodeValue);
            }
            if (rec != null)
                records.add(rec);
        } 
        return records;
    }
    
    /*
        Runs the CheckAppointmentTime Web-Service Call and parses the response.
    */
    public static List<Record> RunCheckAppointmentTime(String dealerCode, string appointmentDate) {
        string result = '';
        string token;
        string xml = '<appointment><DealerCode>'+ dealerCode + '</DealerCode> <RequestDate>' + appointmentDate + '</RequestDate></appointment>'; 
        CheckDealerCode(dealerCode);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse;
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else{
            result = ccp.CheckAppointmentTime(xml, token);
        }
        return ParseCheckAppointmentTimeResponse(result);
    }
    
    /*
        Parse the response of CheckAppointmentTime Web-Service call.
    */
    public static List<Record> ParseCheckAppointmentTimeResponse(string result) {
        List<Record> records = new List<Record>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.time);
        if (root == null) {
            throw new WebServiceException(result);
        }
        for (XMLDom.Element child : root.childNodes) {
            Record rec = null;
            if (child.NodeName.equalsIgnoreCase(system.label.open))
                rec = new Record(system.label.Open_Time, child.NodeValue);
            else if (child.NodeName.equalsIgnoreCase(system.label.close))
                rec = new Record(system.label.Close_Time, child.NodeValue);
            else 
                rec = new Record(child.nodeName, child.NodeValue);
                
            records.add(rec);
            //Record rec = new Record(child.nodeName, child.NodeValue);
            //records.add(rec);
        }
        return records;
    }
    
    /*
        Runs the GetServicesDue Web-Service Call and parses the response.
    */
    public static List<ServiceResponse> RunGetServicesDue(string customerId) {
         string result = '';
         string token;
         CheckCustomerId(customerId);
         if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse;
         }
         else{
            token = ccp.GetSecurityToken(userName, password);
         }
         CheckToken(token);
         if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
         }
         else{
            result = ccp.GetServicesDue(customerId, token);
         }
         return ParseGetServiceDueResponse(result);
    }
    
    /*
        Parse the response of GetServiceDue Web-Service call.
    */
    public static List<ServiceResponse> ParseGetServiceDueResponse(string result) {
         List<ServiceResponse> serviceResponses = new List<ServiceResponse>();
         XMLDom dom = new XMLDom(result);
         XMLDom.Element root = dom.getElementByTagName(system.label.services);
         if (root == null) {
            throw new WebServiceException(result);
         }
         List<XMLDom.Element> intervals = root.getElementsByPath(system.label.services_interval);
         for (XMLDom.Element interval : intervals) {
             ServiceResponse res = new ServiceResponse();
             //res.intervalType = interval.getAttribute(system.label.type);
             //res.intervalName = interval.getAttribute(system.label.name);
             res.records = new List<Record>();
             res.records.add(new Record(system.label.Interval_Type, interval.getAttribute(system.label.type)));
             res.records.add(new Record(system.label.Interval_Name, interval.getAttribute(system.label.name)));

             res.services = new List<String>();
             for (XMLDom.Element service : interval.childNodes) {
                 res.services.add(service.Nodevalue);
             }
            serviceResponses.add(res);
         }
         return serviceResponses;
    }
    
    
    /*
        Runs the GetPrimaryContactInfo Web-Service Call and parses the response.
    */
    public static List<Record> RunGetPrimaryContactInfo(string customerId) {
         string result = '';
         string token;
         CheckCustomerId(customerId);
         if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
         }
         else {
            token = ccp.GetSecurityToken(userName, password);
         }
         CheckToken(token);
         if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
         }
         else {
            result =  ccp.GetPrimaryContactInfo(Integer.valueof(customerId), token);
         }
         return ParseGetPerimaryContactInfo(result);
    }
    
    /*
        Parse the response of GetPerimaryContactInfo Web-Service call.
    */
    public static List<Record> ParseGetPerimaryContactInfo(string result) {
        List<Record> records = new List<Record>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.primary_contact);
         if (root == null) {
            throw new WebServiceException(result);
         }
         string homeNumber = '';
         string homeAreaCode = '';
         string workNumber = '';
         string workAreaCode = '';
         for (XMLDom.Element child : root.childNodes) {
             Record rec = null;
             if (child.NodeName.equalsIgnoreCase(system.label.tmsw_cust_id))
                rec = new Record(system.label.TMSW_Customer_ID, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.purchaser_id))
                rec = new Record(system.label.purchaser_id, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.fname))
                rec = new Record(system.label.First_Name, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.lname))
                rec = new Record(system.label.Last_Name, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.addr1))
                rec = new Record(system.label.Address_1, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.addr2))
                rec = new Record(system.label.Address_2, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.city))
                rec = new Record(system.label.city, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.prov_id))
                rec = new Record(system.label.Province_Id, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.prov_cd))
                rec = new Record(system.label.Province_CD, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.postal_zip))
                rec = new Record(system.label.Postal_ZIP1, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.area_cd_home)) {
                //rec = new Record(system.label.Home_Area_Code, child.NodeValue);
                homeAreaCode = child.NodeValue;
             }
             else if (child.NodeName.equalsIgnoreCase(system.label.home_phone_no)) {
                //rec = new Record(system.label.Home_Phone_Number1, child.NodeValue);
                homeNumber = child.NodeValue;
             }
             else if (child.NodeName.equalsIgnoreCase(system.label.area_cd_work)) {
                //rec = new Record(system.label.Work_Area_Code, child.NodeValue);
                workAreaCode = child.NodeValue;
             }
             else if (child.NodeName.equalsIgnoreCase(system.label.work_phone_no)) {
                //rec = new Record(system.label.Work_Phone_Number, child.NodeValue);
                workNumber = child.NodeValue;
             }
             else if (child.NodeName.equalsIgnoreCase(system.label.email))
                rec = new Record(system.label.email, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.dealer_cust_no))
                rec = new Record(system.label.Customer_Dealer_Number, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.make_name))
                rec = new Record(system.label.Make, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.model_name))
                rec = new Record(system.label.Model, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.model_year))
                rec = new Record(system.label.Model_Year1, child.NodeValue);
             else if (child.NodeName.equalsIgnoreCase(system.label.vin))
                rec = new Record(system.label.Vehicle_Identification_Number, child.NodeValue);
             else
                rec = new Record(child.NodeName, child.NodeValue);  
             
             records.add(rec);          
             //Record rec = new Record(child.nodeName, child.NodeValue);
             //records.add(rec);
         }
         Record rec = new Record(system.label.Home_Phone_Number, '(' + system.label.homeAreaCode + ') ' + system.label.homeNumber );
         records.add(rec);
         rec = new Record(system.label.Work_Phone_Number, '(' + system.label.workAreaCode + ') ' + system.label.workNumber);
         records.add(rec);
         
         return records;
    }
    /*
        Runs the CheckAppointment Web-Service Call and parses the response.
    */
    public static List<Record> RunCheckAppointment(string dealerCode, string appointmentDate, string appointmentTime) {
        string result = '';
        string token;
        string xml = '<appointment><DealerCode>' + dealerCode + '</DealerCode><RequestDate>'+ appointmentDate+'</RequestDate><RequestTime>'+ appointmentTime +'</RequestTime></appointment>';
        CheckDealerCode(dealerCode);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else {
        result = ccp.CheckAppointment(xml, token);
        }
        return PasreCheckAppointmentResponse(result);
    }
    
    /*
        Parse the response of CheckAppointment Web-Service call.
    */
    public static List<Record> PasreCheckAppointmentResponse(string result) {
        List<Record> records = new List<Record>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.appointment);
        if (root == null) {
            throw new WebServiceException(result);
        }
        for (XMLDom.Element child : root.childNodes) {
            Record rec = null;
            if (child.NodeName.equalsIgnoreCase(system.label.NextApptDate))
                rec = new Record(system.label.Next_Appointment_Date, child.NodeValue);
            else if (child.NodeName.equalsIgnoreCase(system.label.NextApptTime))
                rec = new Record(system.label.Next_Appointment_Time, child.NodeValue);
            else
                rec = new Record(child.NodeName, child.NodeValue);
            
            records.add(rec);
            //Record rec = new Record(child.nodeName, child.NodeValue);
            //records.add(rec);
        }
        return records;
    }
    
    /*
        Runs the GetServiceHistory Web-Service Call and parses the response.
    */
    public static List<ServiceHistoryResponse> RunGetServiceHistory(string customerId) {
        string result = '';
        string token;
        CheckCustomerId(customerId);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else{
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else{
            result = ccp.GetServiceHistory(Integer.valueof(customerId), token);
        }
        return ParseGetServiceHistoryResponse(result);
    }
    
     /*
        Parse the response of GetServiceHistoryResponse Web-Service call.
    */
    public static List<ServiceHistoryResponse> ParseGetServiceHistoryResponse(string result) {
        List<ServiceHistoryResponse> serviceHistoryResponses = new List<ServiceHistoryResponse>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.services);
        if (root == null) {
            throw new WebServiceException(result);
        }
        List<XMLDom.Element> services = root.getElementsByPath(system.label.services_service);
        if (services.size() <= 0 ) {
            throw new WebServiceException(system.label.WebServiceExceptioNoServiceHistory);
        }
        for (XMLDom.Element service : services) {
            ServiceHistoryResponse res = new ServiceHistoryResponse();
            res.records = new List<Record>();
            res.details = new List<List<Record>>();
            for (XMLDom.Element child : service.childNodes) {
                Record rec = null;
                if (child.nodeName.equalsIgnoreCase(system.label.Number))
                    rec = new Record(system.label.Number, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.Date))
                    rec = new Record(system.label.Date, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.servicetype))
                    rec = new Record(system.label.Service_Type, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.partsamount))
                    rec = new Record(system.label.Parts_Amount, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.laboramount))
                    rec = new Record(system.label.Labor_Amount, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.totalamount))
                    rec = new Record(system.label.Total_Amount, child.NodeValue); 
                else if (child.nodeName.equalsIgnoreCase(system.label.Details)) {
                    for (XMLDom.Element detail: child.childNodes) {
                        List<Record> records = new List<Record>();
                        for (XMLDom.Element subchild : detail.childNodes) {
                            Record subRec = null;
                            
                            if (subchild.nodeName.equalsIgnoreCase(system.label.description)) {
                                subRec = new Record(system.label.Description_OpCode, subchild.getAttribute(system.label.opcode));
                                records.add(subRec);
                                subRec = new Record(system.label.Description, subchild.NodeValue);
                            }
                            else if (subchild.nodeName.equalsIgnoreCase(system.label.servicetype))
                                subRec = new Record(system.label.Service_Type, subchild.NodeValue);
                            else if (subchild.nodeName.equalsIgnoreCase(system.label.paytype))
                                subRec = new Record(system.label.Pay_Type, subchild.NodeValue);
                            else
                                subRec = new Record(subchild.nodeName, subchild.NodeValue);
                            records.add(subRec);
                        }
                        res.details.add(records);   
                     }
                }
                else
                    rec = new Record(child.NodeName, child.NodeValue); 
                res.records.add(rec);
            }
            serviceHistoryResponses.add(res);
        }
        return serviceHistoryResponses;
    }
    
    /*
        Runs the GetCommunicationHistory Web-Service Call and parses the response.
    */
    public static List<List<Record>> RunGetCommunicationHistory(string customerId) {
        string result = '';
        string token;
        CheckCustomerId(customerId);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else{
            result = ccp.GetCommunicationHistory(Integer.valueof(customerId), token);
        }
        return ParseCommunicationHistoryResponse(result);
    }
    
    /*
        Parse the response of CommunicationHistory Web-Service call.
    */
    public static List<List<Record>> ParseCommunicationHistoryResponse(string result) {
        List<List<Record>> listOfRecords = new List<List<Record>>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.communications);
        if (root == null) {
            throw new WebServiceException(result);
        }
        List<XMLDom.Element> communications = root.getElementsByPath(system.label.communications_communication);
        if (communications.size() <= 0) {
            throw new WebServiceException(system.label.WebServiceExceptionCommunicationHistoryExc);
        }
        for (XMLDom.Element communication : communications) {
            List<Record> records = new List<Record>();
            for (XMLDom.Element child : communication.childNodes) {
                Record rec;
                if (child.nodeName.equalsIgnoreCase(system.label.type))
                    rec = new Record(system.label.type, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.date))
                    rec = new Record(system.label.date, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.time))
                    rec = new Record(system.label.time, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.resolution))
                    rec = new Record(system.label.resolution, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.resolutiontext))
                    rec = new Record(system.label.Resolution_Text, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.agent))
                    rec = new Record(system.label.agent, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.activity_type))
                    rec = new Record(system.label.activity_type, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.contact_type))
                    rec = new Record(system.label.Contact_Type1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.resolution_text))
                    rec = new Record(system.label.Resolution1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.customer_comments))
                    rec = new Record(system.label.Customer_Comments1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.service_performed))
                    rec = new Record(system.label.Service_Performed1, child.NodeValue);
                else 
                    rec = new Record(child.nodeName, child.NodeValue);
                records.add(rec);
                //Record rec = new Record(child.nodeName, child.nodeValue);
                //records.add(rec);
            }
            listOfRecords.add(records);
        }
        return listOfRecords;
    }
    
    /*
        Runs the GetAppointmentSubscribeURL Web-Service Call and parses the response.
    */
    public static List<Record> RunGetAppointmentSubscribeURL(string dealerCode, string customerId) {
        string result = '';
        string token;
        Integer cust_activity_dtl_id;
        //List<CampaignMember> members =  [Select Service_Marketing_Call_ID__c from CampaignMember
                                          //  where Campaign.IsActive = true and Customer_ID__c = :customerId];
                                          
        List<CampaignMember> members = [SELECT Service_Marketing_Call_ID__c FROM CampaignMember
            WHERE Customer_ID__c = :customerId ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
        
        if (members.size() > 0) {
            string temp = String.valueOf(members[0].Service_Marketing_Call_ID__c);
            if (temp != null)
                cust_activity_dtl_id = Integer.valueOf(temp);
        }
       
        
        if(cust_activity_dtl_id == null) {
            throw new WebServiceException(system.label.WebServiceExceptionMarketingCallId);
        }
        CheckCustomerId(customerId);
		
        CheckDealerCode(dealerCode);
		
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;
        } 
        else {      
            result =  ccp.GetAppointmentSubscribeURL(dealerCode, Integer.valueof(customerId), cust_activity_dtl_id, token);
        }
        return ParseGetAppointmentSubscribeURLResponse(result);
    }
    
    /*
        Parse the response of GetAppointmentSubscribeUR Web-Service call.
    */
    public static List<Record> ParseGetAppointmentSubscribeURLResponse(string result) {
        List<Record> records = new List<Record>();
        Record rec = new Record(system.label.Appointment_Subscribe_URL, result);
        records.add(rec);
        return records;
    }

    /*
        Runs the GetAppointmentSubscribeURLNCI Web-Service Call and parses the response. This call is to
        a URL with parameters included, not a SOAP call like the others.
    */
    public static List<Record> RunGetAppointmentSubscribeURLNCI(string dealerCode, string customerId) {
        string result = '';
        string token;
        Integer cust_activity_dtl_id;
                                          
        List<CampaignMember> members = [SELECT Service_Marketing_Call_ID__c FROM CampaignMember
            WHERE Customer_ID__c = :customerId ORDER BY CampaignMember.Campaign.CreatedDate DESC LIMIT 1];
        
        if (members.size() > 0) {
            string temp = String.valueOf(members[0].Service_Marketing_Call_ID__c);
            if (temp != null)
                cust_activity_dtl_id = Integer.valueOf(temp);
        }        
        
        if(cust_activity_dtl_id == null) {
            throw new WebServiceException(system.label.WebServiceExceptionMarketingCallId);
        }

        // Verify that the inputs are valid
        CheckCustomerId(customerId);
        CheckDealerCode(dealerCode);

        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        // Construct the URL
        String url = System.Label.TMS_API_ENDPOINT + '/Xtime/' + dealerCode + '/' + customerId + '/' + cust_activity_dtl_id + '/' + token + '/NCI';

        HttpRequest request = new HttpRequest();
        request.setTimeout(30 * 1000);
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;
        } 
        else {
        HttpResponse httpResponse = http.send(request);

            result =  httpResponse.getBody();
        }
        return ParseGetAppointmentSubscribeURLResponse(result);
    }

    /*
        Runs the GetAssociatedCustomers Web-Service Call and parses the response.
    */
    public static List<List<Record>> RunGetAssociatedCustomers(string customerId) {
        string result = '';
        string token;
        CheckCustomerId(customerId);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else {
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else {
            result = ccp.GetAssociatedCustomers(Integer.valueof(customerId), token);
        }
        return ParseGetAssociatedCustomersResponse(result);
    }
    
    /*
        Parse the response of GetAssociatedCustomers Web-Service call.
    */
    public static List<List<Record>> ParseGetAssociatedCustomersResponse(string result) {
        List<List<Record>> listOfRecords = new List<List<Record>>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.customers);
        if (root == null) {
            throw new WebServiceException(result);
        }
        List<XMLDom.Element> customers = root.getElementsByPath(system.label.customers_customer);
        if (customers.size() <= 0) {
            throw new WebServiceException(system.label.WebServiceExcNoCustFound);
        }
        for (XMLDom.Element customer : customers) {
            List<Record> records = new List<Record>();
            string homeNumber = '';
            string homeAreaCode = '';
            string workNumber = '';
            string workAreaCode = '';
            for (XMLDom.Element child : customer.childNodes) {
                Record rec;
                if(child.NodeName.equalsIgnoreCase(system.label.tmsw_cust_id))
                    rec = new Record(system.label.TMSW_Customer_ID, child.NodeValue);
                else if (child.NodeName.equalsIgnoreCase(system.label.total_weight))
                    rec = new Record(system.label.Total_Weight1, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.fname))
                    rec = new Record(system.label.First_Name, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.lname))
                    rec = new Record(system.label.Last_Name, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.addr1))
                    rec = new Record(system.label.Addres1, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.addr2))
                    rec = new Record(system.label.Address2, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.City))
                    rec = new Record(system.label.City, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.prov_id))
                    rec = new Record(system.label.Province_Id, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.prov_code))
                    rec = new Record(system.label.Province_Code, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.postal_zip2))
                    rec = new Record(system.label.Postal_Zip, child.NodeValue);
                else if(child.NodeName.equalsIgnoreCase(system.label.area_cd_home)) {
                    //rec = new Record(system.label.Home_Area_Code, child.NodeValue);
                    homeAreaCode = child.NodeValue;
                }
                else if(child.NodeName.equalsIgnoreCase(system.label.phone_num_home)) {
                    //rec = new Record(system.label.Home_Phone_Number, child.NodeValue);
                    homeNumber = child.NodeValue;
                }
                else if(child.NodeName.equalsIgnoreCase(system.label.area_cd_work)) {
                    workAreaCode = child.NodeValue;
                    //rec = new Record(system.label.Work_Area_Code, child.NodeValue);
                }
                else if(child.NodeName.equalsIgnoreCase(system.label.phone_num_work)) {
                    workNumber = child.NodeValue;
                    //rec = new Record(system.label.Work_Phone_Number, child.NodeValue);
                }
                else if(child.NodeName.equalsIgnoreCase(system.label.Email))
                    rec = new Record(system.label.Email, child.NodeValue);
                else
                    rec = new Record(child.NodeName, child.NodeValue);
                
                records.add(rec);
                /*Record rec = new Record(child.nodeName, child.nodeValue);
                records.add(rec);*/
            }
            String phone = '';
            if (homeNumber != null && homeNumber != '') {
                if (homeAreaCode != null && homeAreaCode != '')
                    phone = '(' + system.label.homeAreaCode + ') ';
                phone = phone + system.label.homeNumber;
            }
            Record rec = new Record(system.label.Home_Phone_Number, phone);
            records.add(rec);
            phone = '';
            if (workNumber != null && workNumber != '') {
                if (workAreaCode != null && workAreaCode != '')
                    phone = '(' + system.label.workAreaCode + ') ';
                phone = phone + workNumber;
            }
            rec = new Record(system.label.Work_Phone_Number, phone);
            records.add(rec);
            listOfRecords.add(records);
        }
        return listOfRecords;
    }
    
    /*
        Runs the SearchDealer Web-Service Call and parses the response.
    */
    
    private static boolean IsNullOrEmpty(string value)
    {
        return (value == '' || value == null) ? true : false;
    }
    
     public static List<List<Record>> RunSearchDealer(Account account)
     {
        string result;
        string xml;
        string token;
        Account dealer;
        string dealerCity = '';
        string dealerState = '';
        string dealerZipCode = '';
        string dealerPhone = '';
        string dealerName = '';
        string customerID = ''; 
        
        try
        {
            dealer = [SELECT Id, Dealer_Code__c, Name, BillingCity, 
                BillingState, BillingPostalCode, Phone FROM Account 
                WHERE Id =: account.Preferred_Dealer_Id__c];
        }
        catch(Exception e)
        {           
            if (oUtil.isUnitTesting) 
                result = oUtil.mockResponse;    
            else
                result = '<SearchDealerResponse><SearchDealerResult>' + 
                    '<dealers /></SearchDealerResult></SearchDealerResponse>';
            
            return ParseSearchDealerResponse(result);
        }
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(dealer.Name))
            dealerName = dealer.Name;
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(dealer.BillingState))
            dealerState = dealer.BillingState;
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(dealer.BillingCity))
            dealerCity = dealer.BillingCity;
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(dealer.BillingPostalCode))
            dealerZipCode = dealer.BillingPostalCode;
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(dealer.Phone))
            dealerPhone = dealer.Phone;
        
        if(!TMS_Webservices_Utility.IsNullOrEmpty(account.TMS_Customer_Id__c))
            customerID = account.TMS_Customer_Id__c;
        
        xml = '<SearchDealer><DealerName>' + dealerName + '</DealerName>' + 
            '<City>' + dealerCity + '</City><State>' + dealerState + 
            '</State><PostalZipCode>' + dealerZipCode + '</PostalZipCode>' + 
            '<PhoneNumber>' + dealerPhone + '</PhoneNumber><CustomerID>' + 
            customerID + '</CustomerID></SearchDealer>';
        
        if (oUtil.isUnitTesting)
            token = oUtil.mockResponse; 
        else 
            token = ccp.GetSecurityToken(userName, password);
            
        CheckToken(token);
        
        if (oUtil.isUnitTesting) 
            result = oUtil.mockResponse;    
        else
            result = ccp.SearchDealer(xml, token);
        
        return ParseSearchDealerResponse(result);
    }
    
    /*
        Parse the response of SearchDealer Web-Service call.
    */
    public static List<List<Record>> ParseSearchDealerResponse(string result) {
        List<List<Record>> listOfRecords = new List<List<Record>>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.dealers);
        if (root == null) {
            throw new WebServiceException(result);
        }
        List<XMLDom.Element> dealers = root.getElementsByPath(system.label.dealers_dealer);
        if (dealers.size() <= 0) {
            throw new WebServiceException(system.label.WebServiceExceptionNoDelaer);
        }
        for (XMLDom.Element dealer : dealers) {
            List<Record> records = new List<Record>();
            Record r =  new Record(system.label.Dealer_Code, dealer.getAttribute(system.label.code));
            records.add(r);
            for (XMLDom.Element child : dealer.childNodes) {
                Record rec;
                if (child.nodeName.equalsIgnoreCase(system.label.dealerid)) 
                    rec = new Record(system.label.Dealer_Id, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.enrolled))
                    rec = new Record(system.label.Enrolled1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.name))
                    rec = new Record(system.label.Name1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.Address1))
                    rec = new Record(system.label.Address_1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.City))               
                    rec = new Record(system.label.City, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.stateprov))
                    rec = new Record(system.label.State_Province, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.country))
                    rec = new Record(system.label.Country1, child.NodeValue);
                else if (child.nodeName.equalsIgnoreCase(system.label.postalzip))
                    rec = new Record(system.label.Postal_Zip, child.NodeValue);
                else if(child.nodeName.equalsIgnoreCase(system.label.sales)) {
                    for (XMLDom.Element subchild : child.childNodes) {
                        if(subchild.nodeName.equalsIgnoreCase(system.label.phone)) {
                            Record r1 = new Record(system.label.Sales_Phone, subchild.NodeValue);
                            records.add(r1);
                            for (XMLDom.Element subchild2 : subchild.childNodes) {
                                Record subRecord;
                                if (subchild2.nodeName.equalsIgnoreCase(system.label.area))
                                    subRecord = new Record(system.label.Sales_Phone_Area, subchild2.NodeValue);
                                else if (subchild2.nodeName.equalsIgnoreCase(system.label.exchange))
                                    subRecord = new Record(system.label.Sales_Phone_Exchange, subchild2.NodeValue);
                                else if (subchild2.nodeName.equalsIgnoreCase(system.label.line))
                                    subRecord = new Record(system.label.Sales_Phone_Line, subchild2.NodeValue);
                                else
                                    subRecord = new Record(subchild2.NodeName, subchild2.NodeValue);
                                
                                records.add(subRecord);

                            }
                        }
                    }
                }
                else if (child.nodeName.equalsIgnoreCase(system.label.service)) {
                    for (XMLDom.Element subchild : child.childNodes) {
                        if(subchild.nodeName.equalsIgnoreCase(system.label.phone)) {
                            Record r1 = new Record(system.label.Service_Phone, subchild.NodeValue);
                            records.add(r1);
                            for (XMLDom.Element subchild2 : subchild.childNodes) {
                                Record subRecord;
                                if (subchild2.nodeName.equalsIgnoreCase(system.label.area))
                                    subRecord = new Record(system.label.Service_Phone_Area, subchild2.NodeValue);
                                else if (subchild2.nodeName.equalsIgnoreCase(system.label.exchange))
                                    subRecord = new Record(system.label.exchange, subchild2.NodeValue);
                                else if (subchild2.nodeName.equalsIgnoreCase(system.label.line))
                                    subRecord = new Record(system.label.line, subchild2.NodeValue);
                                else
                                    subRecord = new Record(subchild2.NodeName, subchild2.NodeValue);
                                
                                records.add(subRecord);
                            }
                        }   
                    }
                }
                else if (child.nodeName.equalsIgnoreCase(system.label.certifications)) {
                    rec =  new Record(system.label.Certifications_Match, child.getAttribute(system.label.match));
                    for (XMLDom.Element subchild : child.childNodes) {
                        Record subRecord;
                        if (subchild.nodeName.equalsIgnoreCase(system.label.certification)) {
                            subRecord = new Record(system.label.Certification_Type, subchild.getAttribute(system.label.type));
                            records.add(subRecord);
                            subRecord = new Record(system.label.certification, subchild.nodevalue);
                            records.add(subRecord);
                        }
                    }
                }
                else if (child.nodeName.equalsIgnoreCase(system.label.recommended)) 
                    rec = new Record(system.label.recommended, child.NodeValue);
                else
                    rec = new Record(child.NodeName, child.NodeValue);
                    
                records.add(rec);
                //Record rec = new Record(child.nodeName, child.nodeValue);
                //records.add(rec);
            }
            listOfRecords.add(records);
        }
        return listOfRecords;
    }
    
    /*
        Runs the Getassociated_dcno_id Web-Service Call and parses the response.
    */
    public static List<Record> RunGetassociated_dcno_id(string customerId) {
        string result;
        string token;
        CheckCustomerId(customerId);
        if (oUtil.isUnitTesting) {
            token = oUtil.mockResponse; 
        }
        else{
            token = ccp.GetSecurityToken(userName, password);
        }
        CheckToken(token);
        if (oUtil.isUnitTesting) {
            result = oUtil.mockResponse;    
        }
        else{
            result = ccp.Getassociated_dcno_id(Integer.valueof(customerId), token);
        }
        return ParseGetAssociated_dcno_idResponse(result);
    }
    
    /*
        Parse the response of GetAssociated_dcno_id Web-Service call.
    */
    public static List<Record> ParseGetAssociated_dcno_idResponse(string result) {
        List<Record> records = new List<Record>();
        XMLDom dom = new XMLDom(result);
        XMLDom.Element root = dom.getElementByTagName(system.label.customers);
        if (root == null) {
            throw new WebServiceException(result);
        }
        List<XMLDom.Element> customers = root.getElementsByPath(system.label.customers_customer);
        for (XMLDom.Element customer : customers) {
            Record rec = new Record(system.label.DCNO_Id, customer.nodeValue);
            records.add(rec);
            
        }
        return records;
    }
    
    /*
        Redirects to Account_Webservices or contact_Webservices page with apiName, id, date parameter set.
    */
    public PageReference checkAppointmentDateTime() {
        string apiName = ApexPages.currentPage().getParameters().get(system.label.api);
        string id = ApexPages.currentPage().getParameters().get(system.label.id);
        string objType = ApexPages.currentPage().getParameters().get(system.label.Type);
        PageReference page;
        if (objType == system.label.contact){
            page = new PageReference('/apex/contact_Webservices?'+'&'+system.label.api+'='+apiName+'&'+system.label.id+'='+id+'&'+system.label.date+'='+appointmentDate);
        }
        else {
            page = new PageReference('/apex/Account_Webservices?'+'&'+system.label.api+'='+apiName+'&'+system.label.id+'='+id+'&'+system.label.date+'='+appointmentDate);
        }
        return page;
    }
    
    /*
        Redirects to Account_Webservices or contact_Webservices page with apiName, id, date, time parameter set.
    */
    public PageReference checkAppointmentDate() {
        string apiName = ApexPages.currentPage().getParameters().get(system.label.api);
        string id = ApexPages.currentPage().getParameters().get(system.label.id);
        string objType = ApexPages.currentPage().getParameters().get(system.label.Type);
        PageReference page;
        if (objType == system.label.contact){
            page = new PageReference('/apex/contact_Webservices?'+'&'+system.label.api+'='+apiName+'&'+system.label.id+'='+id+'&'+system.label.date+'='+appointmentDate+'&'+system.label.time+'='+appointmentTime);
        }
        else{
            page = new PageReference('/apex/Account_Webservices?'+'&'+system.label.api+'='+apiName+'&'+system.label.id+'='+id+'&'+system.label.date+'='+appointmentDate+'&'+system.label.time+'='+appointmentTime);
        }
        return page;
    }
    
    // Setter for endpoint, username and password
    public static void setServiceAccess(string endpoint, string serverUsername, string serverPassword)
    {
        ccp.endpoint_x = endpoint;
        TMS_Webservices_Utility.userName = serverUsername;
        TMS_Webservices_Utility.password = serverPassword;
    }
}