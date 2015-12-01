/*
Page Title: NCICustomerVehiclesRest
Author: Aaron Bessey
Create Date: 3/16/2015
Last Update: 3/16/2015
Updated By: Aaron Bessey

Revisions:
AAB - Initial Creation
*/

@RestResource(urlMapping='/casl/api/v1/customervehicles/*')
global class NCICustomerVehiclesRest {
    global class CustomerVehicleHandler
    {
        public Long requestId {get;set;}
        public String status {get;set;}
        public String type {get;set;}
        public List<CustomerVehicle> customerVehicles{get;set;}
        public ResultHandler result {get;set;}        
        
        public CustomerVehicleHandler()
        {
            customerVehicles = new List<CustomerVehicle>();
            result = new ResultHandler();
        }
        public CustomerVehicleHandler(Long iRID, String sStatus, String sType)
        {
            requestId = iRID;
            status = sStatus;
            type = sType;
            customerVehicles = new List<CustomerVehicle>();
            result = new ResultHandler();
        }
    }
    
    global class CustomerVehicle
    {
        public integer customerNumber {get;set;}
        public string vinCode{get;set;}
        public string ownerTypeCode{get;set;}
        public string currentDriverIndicator{get;set;}
        public string make{get;set;}
        public integer modelYear{get;set;}
        public string seriesCode{get;set;}
        public string modelCode{get;set;}
        public string modelDesc{get;set;}
        public string optionGroupCode{get;set;}
        public string customerVehicleStartDate{get;set;}
        public string customerVehicleEndDate{get;set;}
        public string retailDealerCode{get;set;}
        public string serviceDealerCode{get;set;}
        public string originalRetailTypeCode{get;set;}
        public string originalRetailTypeDesc{get;set;}
        public string firstServiceSurveyDate{get;set;}
        public string secondServiceSurveyDate{get;set;}
        public integer transferFromCustomerNumber{get;set;}
        public string inServiceDate{get;set;}
        public string warrantyStartDate{get;set;}
        public string retailProcessDate{get;set;} 
    }
    
    global class ResultHandler
    {
        public integer code {get;set;}
        public string message {get;set;}        
    }
    
    @HttpGet
    global static CustomerVehicleHandler getCustomerVehicles() 
    {
        CustomerVehicleHandler cvh = new CustomerVehicleHandler();
        cvh.requestId = 1234567890;//123456800;
        cvh.status = 'success';
        cvh.type = 'Response';
        cvh.result.code = 200;
        cvh.result.message = 'test message';
        
        String customerNum = RestContext.request.params.get('customerNumber');
        if(customerNum==null)
        {
            cvh.status = 'error';
            cvh.result.code=200;
            cvh.result.message='Invalid customer number';
            return cvh;
        }
        else
        {
            customerNum = customerNum.replaceAll('[^0-9]','');
            if(customerNum=='')
            {
                cvh.status = 'error';
                cvh.result.code=200;
                cvh.result.message='Invalid customer number';
                return cvh;
            }
        }
        
        List<Account> customers = [ Select ID,  Customer_ID__c
                                   from Account where Customer_ID__c= :customerNum limit 1];

        System.debug(customers);
        
        Id custid;
        if(customers!=null && customers.size()>0)
        {
            custid = customers[0].Id;
        }
        
        CustomerVehicle custVehicle;
        
        DateTime tmpDate = DateTime.now();
        
        for(Vehicle_Ownership_History__c voh : [select Id, VIN__c, Begin_Date__c,
                                                End_Date__c, Current_Owner_Indicator__c,
                                                Primary_Owner_Indicator__c,
                                                Vehicle__c,
                                                Vehicle__r.Model_Year__c,
                                                Vehicle__r.Make_Name__c,
                                                Vehicle__r.Model_Line_Name__c
                                                from Vehicle_Ownership_History__c
                                                where Owner__c=:custid
                                               ])
        {

            tmpDate = DateTime.now();
            custVehicle = new CustomerVehicle();
            custVehicle.customerNumber = Integer.valueOf(customerNum);
            
            custVehicle.vinCode = voh.VIN__C;
            custVehicle.ownerTypeCode = '1';
            custVehicle.currentDriverIndicator = voh.Current_Owner_Indicator__c==true ? 'Y' : 'N';
            if(voh.Vehicle__c!=null)
            {
                custVehicle.modelYear = voh.Vehicle__r.Model_Year__c!=null ? Integer.valueOf(voh.Vehicle__r.Model_Year__c) : 2015;
                
            }
            custVehicle.modelCode = 'Y6SG18';
            
            custVehicle.seriesCode = 'Y';
            custVehicle.optionGroupCode = 'BK00';
            custVehicle.customerVehicleStartDate = String.valueOfGMT(voh.Begin_Date__c);
            custVehicle.customerVehicleEndDate = String.valueOfGMT(voh.End_Date__c);
            custVehicle.retailDealerCode = '12011';
            custVehicle.serviceDealerCode = '44221';
            custVehicle.originalRetailTypeCode = 'L';
            custVehicle.firstServiceSurveyDate = String.valueOfGMT(tmpDate.addMonths(3).Date());
            custVehicle.secondServiceSurveyDate = String.valueOfGMT(tmpDate.addMonths(6).Date());
            custVehicle.transferFromCustomerNumber = null;
            custVehicle.inServiceDate = String.valueOfGMT(voh.Begin_Date__c);
            custVehicle.retailProcessDate = String.valueOfGMT(voh.Begin_Date__c);
            
            
            cvh.customerVehicles.Add(custVehicle);
        }
        System.DEBUG(cvh);
        System.DEBUG(JSON.serialize(cvh));
        return cvh;
    }    
}