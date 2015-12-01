/*
Page Title: NCICustomerDetailREST
Author: Aaron Bessey
Create Date: 3/10/2015
Last Update: 3/10/2015
Updated By: Aaron Bessey

Revisions:
AAB - Initial Creation


*/

@RestResource(urlMapping='/casl/api/v1/customer/*')
global class NCICustomerDetailRest {



    global class CustomerDetailErrorHandler {
    
        public Long requestId {get;set;}
        public String status {get;set;}
        public String type {get;set;}
        //public String customer {get;set;} 
        public ResultHandler result {get;set;}
    }








    global class CustomerDetailHandler
    {
        public Long requestId {get;set;}
        public String status {get;set;}
        public String type {get;set;}
        public CustomerHandler customer {get;set;} 
        public ResultHandler result {get;set;}        
        
        public CustomerDetailHandler()
        {
            customer = new CustomerHandler();
            result = new ResultHandler();
        }
        public CustomerDetailHandler(Long iRID, String sStatus, String sType)
        {
            requestId = iRID;
            status = sStatus;
            type = sType;
            customer = new CustomerHandler();
            result = new ResultHandler();
        }
    }
    
    global class EmailAddressHandler
    {
        public string email {get;set;}
        public boolean primary {get;set;}
    }
    
    global class PhoneHandler
    {
        public string type {get;set;}
        public Long phoneNumber {get;set;}
        public string extension {get;set;}        
    }
    
    global class ContactInfoHandler
    {
        public List<EmailAddressHandler> emailAddress {get;set;}
        public List<PhoneHandler> phone {get;set;}
        public string preferredContactMethodCode {get;set;}
        public datetime updatedTimeStamp {get;set;}
        
        public ContactInfoHandler()
        {
            emailAddress = new List<EmailAddressHandler>();
            phone = new List<PhoneHandler>();
        }
    }
    
    global class AddressHandler
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
    global class FreeFormHandler
    {
        public string addressLine1 {get;set;}
        public string addressLine2 {get;set;}
        public string addressLine3 {get;set;}
    }
    global class AddressInfoHandler
    {
        public AddressHandler address {get;set;}
        public FreeFormHandler freeformAddress {get;set;}
        public boolean addressOverride {get;set;}
        public boolean validAddressIndicator {get;set;}
        public datetime updatedTimestamp {get;set;}
        
        public AddressInfoHandler()
        {
            address = new AddressHandler();
            freeformAddress = new FreeFormHandler();
            addressOverride = false;
            validAddressIndicator = true;
        }
    }
    
    global class ConsentInfoHandler
    {
        public string consentType {get;set;}
        public string contactMethod {get;set;}
        public boolean consentFlag {get;set;}
        public string collectedBy {get;set;}
        public string collectedTimestamp {get;set;}
    }
    
    global class TrackingInfoHandler
    {
        public string source {get;set;}
        public string trackingNumber {get;set;}
        public boolean activeIndicator {get;set;}        
    }
    global class CustomerHandler
    {
        public string preferredLanguage {get;set;}
        public integer customerNumber {get;set;}
        public string customerTypeCode {get;set;}
        public string firstname {get;set;}
        public string lastname {get;set;}
        public string personalInfoUpdatedTimestamp {get;set;}
        public ContactInfoHandler contactInfo {get;set;}
        public AddressInfoHandler addressInfo {get;set;}
        public List<ConsentInfoHandler> consentInfo {get;set;}
        public List<TrackingInfoHandler> trackingInfo {get;set;}     
        
        public CustomerHandler()
        {
            contactInfo = new ContactInfoHandler();
            addressInfo = new AddressInfoHandler();
            consentInfo = new List<ConsentInfoHandler>();
            consentInfo.Add(new ConsentInfoHandler());
            trackingInfo = new List<TrackingInfoHandler>();  
            trackingInfo.Add(new TrackingInfoHandler());
        }
    }
    
    global class ResultHandler
    {
        public integer code {get;set;}
        public string message {get;set;}        
    }
    
    @HttpGet
    global static CustomerDetailHandler getCustomers() 
    {
        String phonenum;
        CustomerDetailHandler cdh = new CustomerDetailHandler();
        cdh.requestId = 1234567890;//123456800;
        cdh.status = 'success';
        cdh.type = 'Response';
        cdh.result.code = 200;
        cdh.result.message = 'test message';
        
        String customerNum = RestContext.request.params.get('customerNumber');
        String sfid = RestContext.request.params.get('trackingNumber');
        String consentType = RestContext.request.params.get('consentType');
        
        List<Account> customers = [ Select ID, Name, FirstName, LastName, Customer_ID__c,
                                   PersonEmail, PersonMailingCity, PersonMailingStreet, Phone, PersonMobilePhone, Work_Phone__c,
                                   PersonMailingState, PersonMailingCountry, PersonMailingPostalCode, LastModifiedDate
                                   from Account where Customer_ID__c= :customerNum limit 1];
        CustomerHandler customer;
        
        for(Account a : customers)
        {
            customer = new CustomerHandler();
            customer.customerNumber = a.Customer_ID__c!=null ? Integer.valueOf(a.Customer_ID__c) : 0;
            customer.customerTypeCode = '0';
            customer.firstname = a.FirstName;
            customer.lastname = a.LastName;
            customer.personalInfoUpdatedTimestamp = String.valueOfGMT(a.LastModifiedDate);
            customer.trackingInfo[0].source = 'SFDC';
            customer.trackingInfo[0].trackingNumber = a.Id;
            customer.trackingInfo[0].activeINdicator = true;
            
            customer.consentInfo[0].consentType = 'DEALER';
            customer.consentInfo[0].contactMethod = 'DEALER';
            customer.consentInfo[0].consentFlag = true;
            customer.consentInfo[0].collectedBy = 'SDIG';
            customer.consentInfo[0].collectedTimestamp = String.valueOfGMT(a.LastModifiedDate);
            
            customer.contactInfo.updatedTimestamp = a.LastModifiedDate;
            
            EmailAddressHandler eh = new EmailAddressHandler();
            eh.email = a.PersonEmail;
            eh.primary = true;
            customer.contactInfo.emailAddress.Add(eh);
            
            PhoneHandler ph;
            if(a.Phone!=null)
            {
                ph = new PhoneHandler();
            phonenum = a.Phone.replaceAll('[^0-9]', '');
            ph.phonenumber = Long.valueOf(phonenum);
                ph.type = 'HOME';
                customer.contactInfo.phone.Add(ph);
            }
            if(a.PersonMobilePhone!=null)
            {
                ph = new PhoneHandler();
            phonenum = a.PersonMobilePhone.replaceAll('[^0-9]', '');
            ph.phonenumber = Long.valueOf(phonenum);
                ph.type = 'MOBILE';
                customer.contactInfo.phone.Add(ph);
            }
            if(a.Work_Phone__c!=null)
            {
                ph = new PhoneHandler();
            phonenum = a.Work_Phone__c.replaceAll('[^0-9]', '');
            ph.phonenumber = Long.valueOf(phonenum);
                ph.type = 'WORK';
                customer.contactInfo.phone.Add(ph);
            }
            
            customer.contactInfo.preferredContactMethodCode = '1';
            
            a.PersonMailingStreet = a.PersonMailingStreet!=null ? a.PersonMailingStreet : '';
            String[] streetParts = a.PersonMailingStreet.split(' ');
            customer.addressInfo.updatedTimestamp = a.LastModifiedDate;
            customer.addressInfo.address.streetNumber = streetParts[0];
            customer.addressInfo.address.streetName = '';
            for(integer i=1;i<streetParts.size()-1;i++)
            {
                if(i!=1)
                {
                    customer.addressInfo.address.streetName += ' ';
                }
                customer.addressInfo.address.streetName += streetParts[i];
            }
            if(streetParts.size()>=2)
            {
                customer.addressInfo.address.streetType = streetParts[streetParts.size()-1];
            }
            customer.addressInfo.address.city = a.PersonMailingCity!=null ? a.PersonMailingCity : '';
            customer.addressInfo.address.province = a.PersonMailingState!=null ? a.PersonMailingState: '';
            customer.addressInfo.address.country = a.PersonMailingCountry!=null ? a.PersonMailingCountry: '';
            if(a.PersonMailingCountry!=null && (a.PersonMailingCountry=='US' || a.PersonMailingCountry=='USA'))
            {
                customer.addressInfo.address.zipCode = a.PersonMailingPostalCode!=null ? a.PersonMailingPostalCode: '';
            }
            else
            {
                customer.addressInfo.address.postalcode = a.PersonMailingPostalCode!=null ? a.PersonMailingPostalCode: '';
            }
            customer.addressInfo.freeFormAddress.addressLine3 = a.PersonMailingCity!=null ? a.PersonMailingCity : '';
            customer.addressInfo.freeFormAddress.addressLine3 += a.PersonMailingState!=null ? ' ' + a.PersonMailingState : '';
            customer.addressInfo.freeFormAddress.addressLine3 += a.PersonMailingCountry!=null ? ' ' + a.PersonMailingCountry : '';
            customer.addressInfo.freeFormAddress.addressLine3 += a.PersonMailingPostalCode!=null ? ' ' + a.PersonMailingPostalCode : '';
            customer.addressInfo.freeFormAddress.addressLine2 = a.PersonMailingStreet.substring(a.PersonMailingStreet.indexOf(' ')+1);
            customer.addressInfo.freeFormAddress.addressLine1 = streetParts[0];
            
            cdh.customer = customer;
        }
        
        return cdh;
    }    
}