/**********************************************************************
Name: Account_Webservices_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Test class for Account_Webservices class.

Related Class : Account_Webservices
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqi 01/25/2011 Created
1.1 - Sonali Bhardwaj    01/31/2011 Modified to increase code coverage.                          
***********************************************************************/
@isTest
private class Account_Webservices_Test {
    private static Account_Webservices obj = new Account_Webservices();
    private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
    public static void InitializeData() {
        
        String dealerType = System.Label.AccRTDealer;
        String personType = System.Label.AccRTMaritz;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        
        Account prefferedAccount = new Account();
        prefferedAccount.name = 'Test';
        prefferedAccount.RecordTypeId = dealerTypeRT.Id;
        insert prefferedAccount; 
        
        Account account = new Account();
        account.LastName = 'Test';
        account.RecordTypeId = personTypeRT.Id;
        
        account.Preferred_Dealer_Id__c = prefferedAccount.id;
        insert account;
        
        ApexPages.currentPage().getParameters().put(system.label.id, account.id);
    }
    
    static testmethod void testInitialize() {
        InitializeData();
        obj = new Account_Webservices(null);
        test.startTest();
        obj.initialize();
        test.stopTest();
        
        system.assert(obj.isError == false);    
    }
    
     static testmethod void testRunWebServiceGetDealerInfoNegative() {
        obj.apiName = system.label.GetDealerInfo;
        obj.havePrefferedDealerAccount = false;
        
        /*
            Switch to the runtime context
        */
       
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);    
    }
    
    static testmethod void testRunWebServiceGetDealerInfoPositive() {
        obj.apiName = system.label.GetDealerInfo;
        obj.dealerCode = '5049';
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest(); 
    }
    
   static testmethod void testRunWebServiceCheckAppointmentTimeNegative() {
        obj.apiName = system.label.CheckAppointmentTime;
        obj.havePrefferedDealerAccount = false;
        obj.appointmentDate = '1230';      
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);    
    }
    
    static testmethod void testRunWebServiceCheckAppointmentTimePositive() {
        obj.apiName = system.label.CheckAppointmentTime;
        obj.dealerCode = '5049';
        obj.appointmentDate = '1230';  
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest(); 
                
    }   
    
    static testmethod void testRunWebServiceGetServicesDueNegative() {
        obj.apiName = system.label.GetServicesDue; 
        
        /*
            Switch to the runtime context
        */
              
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
       
    }
    
    static testmethod void testRunWebServiceGetServicesDuePositive() {
        obj.apiName = system.label.GetServicesDue;
         
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest(); 
                
    }   
   
    static testmethod void testRunWebServiceGetPrimaryContactInfoNegative() {
        obj.apiName = system.label.GetPrimaryContactInfo; 
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceGetPrimaryContactInfoPositive() {
        obj.apiName = system.label.GetPrimaryContactInfo; 
       
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
   static testmethod void testRunWebServiceCheckAppointmentNegative() {
        obj.apiName = system.label.CheckAppointment; 
        
        
        /*
            Switch to the runtime context
        */
              
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceCheckAppointmentPositive() {
        obj.apiName = system.label.CheckAppointment; 
        obj.appointmentDate='1234';
        obj.appointmentTime='1234';
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
    static testmethod void testRunWebServiceGetServiceHistoryNegative() {
        obj.apiName = system.label.GetServiceHistory; 
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isServiceHistoryResponse == false);   
       
    }
    
    static testmethod void testRunWebServiceGetServiceHistoryPositive() {
       
        obj.apiName = system.label.GetServiceHistory; 
          
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
     static testmethod void testRunWebServiceGetCommunicationHistoryNegative() {
        obj.apiName = system.label.GetCommunicationHistory; 
        
        /*
            Switch to the runtime context
        */
                    
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
       
    }
    
    static testmethod void testRunWebServiceGetCommunicationHistoryPositive() {
       
        obj.apiName = system.label.GetCommunicationHistory; 
               
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
    static testmethod void testRunWebServiceGetAppointmentSubscribeURLNegative() {
        obj.apiName = system.label.GetAppointmentSubscribeURL; 
        obj.havePrefferedDealerAccount = false;
        /*
            Switch to the runtime context
        */
                      
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceGetAppointmentSubscribeURLPositive() {
       
        obj.apiName = system.label.GetAppointmentSubscribeURL; 
            
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
    static testmethod void testRunWebServiceGetAssociatedCustomersNegative() {
        obj.apiName = system.label.GetAssociatedCustomers; 
        
        /*
            Switch to the runtime context
        */
                      
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
       
    }
    
    static testmethod void testRunWebServiceGetAssociatedCustomersPositive() {
       
        obj.apiName = system.label.GetAssociatedCustomers; 
               
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    static testmethod void testRunWebServiceSearchDealerNegative() {
        obj.apiName = system.label.SearchDealer; 
        
        /*
            Switch to the runtime context
        */
                      
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
       
    }
    
    static testmethod void testRunWebServiceSearchDealerPositive() {
       
        obj.apiName = system.label.SearchDealer; 
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
    static testmethod void testRunWebServiceGetassociated_dcno_idNegative() {
        obj.apiName = system.label.Getassociated_dcno_id; 
        
        /*
            Switch to the runtime context
        */
                      
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
        System.assert(obj.isError == true);
    }
    
    static testmethod void testRunWebServiceGetassociated_dcno_idPositive() {
       
        obj.apiName = system.label.Getassociated_dcno_id; 
        
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        
    }
    
    static testmethod void testRunWebServiceMaritzCreditCardTransactionHistory() {
       
        obj.apiName = 'CC_Transaction_History';
        oUtil.isUnitTesting = true;
        /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.RunWebService();
        /*
            Switch back to the original context
        */
        Test.StopTest();
        System.assert(obj.isError == false);
    }
    
    static testmethod void testredirectToSSLCJ() {
      	
      	oUtil.isUnitTesting = true;
      	    /*
            Switch to the runtime context
        */
        
        Test.startTest();
        obj.redirectToSSLCJ();
        /*
            Switch back to the original context
        */
        Test.StopTest();
      
    }
    
    static testmethod void testCallSaveCustomer() {
      	
      	oUtil.isUnitTesting = true;
      	Lead lead = new Lead();
        lead.LastName = 'Test';
        insert lead;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
        RecordType personTypeRT = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
        
        Account prefferedAccount = new Account();
        prefferedAccount.name = 'Test';
        prefferedAccount.RecordTypeId = dealerTypeRT.Id;
        insert prefferedAccount; 
        
        Account account = new Account();
        account.LastName = 'Test';
        account.RecordTypeId = personTypeRT.Id;
        
        account.Preferred_Dealer_Id__c = prefferedAccount.id;
        insert account;
        
      	/*
            Switch to the runtime context
        */
        
        Test.startTest();
        Account_Webservices.callSaveCustomer(account.id);  
        Account_Webservices.callSaveCustomer(lead.id); 
        /*
            Switch back to the original context
        */
        Test.StopTest();
      
    }
}