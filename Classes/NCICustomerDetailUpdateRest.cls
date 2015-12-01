/*
Page Title: NCICustomerDetailUpdateREST
Author: Aaron Bessey
Create Date: 10/20/2015
Last Update: 10/20/2015
Updated By: Will Taylor

Revisions:
WFT - Initial Creation


*/

public class NCICustomerDetailUpdateRest {



    public class CustomerDetailErrorHandler {
    
        public Long requestId {get;set;}
        public String status {get;set;}
        public String type {get;set;}
        //public String customer {get;set;} 
        public ResultHandler result {get;set;}
    }

    public class CustomerDetailHandler
    {
        public String supplier {get; set;}
        public Long requestId {get;set;}
        public String updatedTimestamp {get;set;}
        public String clientId {get; set;}
        public CustomerHandler customer {get;set;} 

        public CustomerDetailHandler()
        {
            customer = new CustomerHandler();
        //    result = new ResultHandler();
        }
        public CustomerDetailHandler(Long iRID, String sStatus, String sType)
        {
            requestId = iRID;
            //type = sType;
            customer = new CustomerHandler();
        //    result = new ResultHandler();
        }
    }
    
    public class EmailAddressHandler
    {
        public string email {get;set;}
        public boolean primary {get;set;}
    }
    
    public class PhoneHandler
    {
        public string type {get;set;}
        public Long phoneNumber {get;set;}
        public string extension {get;set;}        
    }
    
    public class ContactInfoHandler
    {
        public List<EmailAddressHandler> emailAddress {get;set;}
        public List<PhoneHandler> phone {get;set;}
        public string preferredContactMethodCode {get;set;}
        public string updatedTimeStamp {get;set;}
        
        public ContactInfoHandler()
        {
            emailAddress = new List<EmailAddressHandler>();
            phone = new List<PhoneHandler>();
        }
    }
    
    public class AddressHandler
    {
        public string apartmentNumber {get;set;}
        public string streetNumber {get;set;}
        public string streetNumberSuffix {get;set;}
        public string streetName {get;set;}
        public string streetType {get;set;}
        public string streetDirection {get;set;}
        public string deliveryMode {get;set;}
        public string routeNumber {get;set;}
        public string boxNumber {get;set;}
        public string deliveryQualifier {get;set;}
        public string city {get;set;}
        public string province {get;set;}
        public string country {get;set;}
        public string postalCode {get;set;}
        public string zipCode {get;set;}
    }
    public class FreeFormHandler
    {
        public string addressLine1 {get;set;}
        public string addressLine2 {get;set;}
        public string addressLine3 {get;set;}
    }
    public class AddressInfoHandler
    {
        public AddressHandler address {get;set;}
        public FreeFormHandler freeformAddress {get;set;}
        public boolean addressOverride {get;set;}
        public boolean validAddressIndicator {get;set;}
        public string updatedTimestamp {get;set;}
        
        public AddressInfoHandler()
        {
            address = new AddressHandler();
            freeformAddress = new FreeFormHandler();
            addressOverride = false;
            validAddressIndicator = true;
        }
    }
    
    public class ConsentInfoHandler
    {
        public string consentType {get;set;}
        public string contactMethod {get;set;}
        public boolean consentFlag {get;set;}
        public string collectedBy {get;set;}
        public string collectedTimestamp {get;set;}
    }
    
    public class TrackingInfoHandler
    {
        public string source {get;set;}
        public string trackingNumber {get;set;}
        public boolean activeIndicator {get;set;}        
    }
    public class CustomerHandler
    {
        public string preferredLanguage {get;set;}
        public integer customerNumber {get;set;}
       // public string customerTypeCode {get;set;}
        public string firstname {get;set;}
        public string lastname {get;set;}
        public string personalInfoUpdatedTimestamp {get;set;}
        public ContactInfoHandler contactInfo {get;set;}
        public AddressInfoHandler addressInfo {get;set;}
        public List<ConsentInfoHandler> consentInfo {get;set;}
        public String trackingNumber {get; set;}
        public String companyName {get; set;}
        
        public CustomerHandler()
        {
            contactInfo = new ContactInfoHandler();
            addressInfo = new AddressInfoHandler();
            consentInfo = new List<ConsentInfoHandler>();
          
           // trackingInfo = new List<TrackingInfoHandler>();  
           // trackingInfo.Add(new TrackingInfoHandler());
        }
    }
    
    public class ResultHandler
    {
        public integer code {get;set;}
        public string message {get;set;}        
    }
    
}