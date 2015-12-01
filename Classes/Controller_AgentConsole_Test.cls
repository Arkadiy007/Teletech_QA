/**********************************************************************
Name: Controller_AgentConsole_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_AgentConsole.

Related Class : Controller_AgentConsole
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Biswa Ray 01/31/2011 Created
1.1 - Sonali Bhardwaj 02/17/2011 Increased code coverage.
  
01/31/12: JJ
Changed test code for display email checkbox changes, lines
349, 353 commented out and 350 added                    
***********************************************************************/
@isTest
private class Controller_AgentConsole_Test {
    private static  Controller_AgentConsole obj;
    private static Contact contact;
    private static Account accObj;
    public static void loadObjectsData() {
        RecordType dealer = [Select id from RecordType where name=: system.label.dealer and SobjectType = 'Account' limit 1];
        RecordType personAccRec = [Select id from RecordType where name=: system.label.TMS and SobjectType = 'Account' limit 1];

		State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
		insert state;

        Account acc = new Account();
        acc.name = 'testacc';
        acc.RecordTypeId = dealer.id;
        acc.Dealer_Attributes_Text__c = system.label.E;
        acc.mobile_phone_sequence__c = '1';
        acc.home_phone_sequence__c = '2';
        acc.other_phone_sequence__c = '3';
        insert acc;
        
        Account account = new Account();
        account.name = 'Test';
        account.RecordTypeId = dealer.id;
        account.Preferred_Dealer_Id__c = acc.id; 
        account.Dealer_Attributes_Text__c = system.label.I;
        account.mobile_phone_sequence__c = '1';
        account.home_phone_sequence__c = '2';
        account.other_phone_sequence__c = '3';
        account.Home_Phone_Sequence__c   = '1'; 
        account.Other_Phone_Sequence__c   = '2';
        //account.FirstName   = '2';
        insert account;
        
        accObj = new Account();
        accObj.FirstName ='text';
        accObj.LastName ='LastName';
        accObj.PersonMailingPostalCode = '21204';
        accObj.RecordTypeId = personAccRec.id; 
        insert accObj ;
        
        contact = [select id from contact where Accountid = :accObj.id limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        obj = new Controller_AgentConsole(sc);
        obj.getWLCVisiblity();
        ApexPages.currentPage().getParameters().put(system.label.id, account.id);
        ApexPages.currentPage().getParameters().put(system.label.contactId, contact.id);
        obj = new Controller_AgentConsole();
        
        obj = new Controller_AgentConsole(sc);
        
        // Assign endpoint, user and password for web services test
        obj.serviceAccessAssigned = true;
        TMS_Webservices_Utility.setServiceAccess(System.label.TMS_Endpoint, System.label.username, System.label.password);
         
        
        Campaign camp = new Campaign();
        camp.Name = 'test';
        camp.StartDate = date.newinstance(1960, 2, 17);
        camp.EndDate = date.newinstance(1960, 5, 20);
        camp.IsActive = true;
        insert camp;
        
        camp.Name = 'test2';
        camp.StartDate = date.newinstance(1960, 7, 17);
        camp.EndDate = date.newinstance(1960, 8, 20);
        camp.IsActive = true;
        update camp;
        
        Vehicle__c vehicle = new Vehicle__c();
        insert vehicle;
        update vehicle;
        
        CampaignMember campmem = new CampaignMember();
        campmem.CampaignId = camp.id;
        campmem.ContactId = contact.id;
        campmem.Vehicle__c = vehicle.id;
        campmem.Service_Marketing_Call_Type__c = system.label.NSC;
        campmem.Non_Solicit__c=true;
        //campmem.Preferred_Mail_Type__c = 'Email';
        insert campmem;
        obj.loadObjects(contact.id);
        obj.getWLCVisiblity();
        obj.getDisplaySendEmailCheckbox();
        obj.getHeader();
        campmem.Service_Marketing_Call_Type__c = system.label.WLC;
        update campmem;
        obj.loadObjects(contact.id);
        obj.getWLCVisiblity();
        obj.getDisplaySendEmailCheckbox();
        obj.getHeader();
        campmem.Service_Marketing_Call_Type__c = system.label.SFC;
        update campmem;
        
                
        Task task = new task();
        task.whoid = contact.id;
        task.Subject = 'Reservation1';
        insert task; 
        Task taskObj = new Task(CallDisposition__c = '',Description = '');
        insert taskObj; 
        
        acc.Dealer_Attributes_Text__c = system.label.E;
        update acc;
        obj.loadObjects(contact.id);
        obj.getIsExpressDealer();
        
        acc.Dealer_Attributes_Text__c = system.label.I;
        update acc;
        obj.loadObjects(contact.id);
        obj.getDisplaySendEmailCheckbox();
        accObj.Preferred_Dealer_Id__c = acc.id;
    }   
    
    static testmethod void testSave1() {
        loadObjectsData();  
        
        Test.startTest();
        accObj.PersonMailingCity = '4';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Home_Phone_Sequence__c = '1';
        accObj.Other_Phone_Sequence__c = '1';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Home_Phone_Sequence__c = '1';
        accObj.Mobile_Phone_Sequence__c = '1';
        accObj.Other_Phone_Sequence__c = '2';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        Test.stopTest();
    }
    
    static testmethod void testSave2() {
        loadObjectsData();
        Test.startTest();
        accObj.PersonMailingCity = null;
        accObj.PersonMailingCountry = null;
        accObj.PersonMailingPostalCode  = '23';
        accObj.PersonMailingState = null;
        accObj.Other_Phone_Sequence__c = null;
        accObj.Home_Phone_Sequence__c = null ;
        accObj.Mobile_Phone_Sequence__c = null;
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Other_Phone_Sequence__c = system.label.None;
        accObj.Home_Phone_Sequence__c = system.label.None;
        accObj.Mobile_Phone_Sequence__c = system.label.None;
        accObj.PersonHomePhone = '303-3230210';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Other_Phone_Sequence__c = '1';
        accObj.Home_Phone_Sequence__c = '3';
        accObj.Mobile_Phone_Sequence__c = '2';
        accObj.PersonHomePhone = '123';
        update accObj;
        obj.loadObjects(contact.id);
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Other_Phone_Sequence__c = '1';
        accObj.Home_Phone_Sequence__c = '3';
        accObj.Mobile_Phone_Sequence__c = '2';
        accObj.PersonHomePhone = '123';
        update accObj;
        obj.loadObjects(contact.id);
        obj.thisCall.Service_Description__c = '11';
        obj.customSave();
        
        accObj.PersonMailingCity = '4';
        accObj.firstName = 'fname';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Other_Phone_Sequence__c = '1';
        accObj.Home_Phone_Sequence__c = '3';
        accObj.Mobile_Phone_Sequence__c = '2';
        accObj.PersonHomePhone = '123';
        accObj.PersonMailingPostalCode = '21204';
        update accObj;        
        obj.loadObjects(contact.id);
        obj.thisCall.Service_Description__c = '11';
        obj.customSave();

        accObj.PersonMailingCity = '4';
        accObj.firstName = 'null';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.Other_Phone_Sequence__c = '1';
        accObj.Home_Phone_Sequence__c = '3';
        accObj.Mobile_Phone_Sequence__c = '2';
        accObj.PersonHomePhone = '123';
        update accObj;
        obj.loadObjects(contact.id);
        obj.thisCall.Service_Description__c = '11';
        obj.thisCall.Customer_Experience__c  = '11';        
        obj.customSave();
        Test.stopTest();
        

    }
    static testmethod void testSave3() {
        loadObjectsData();
        Test.startTest();
        accObj.PersonMailingCity = '4';
        accObj.firstName = 'null';
        accObj.PersonMailingCountry = 'US';
        accObj.PersonMailingPostalCode  = 'f';
        accObj.PersonMailingState = 'CO';
        accObj.PersonMailingStreet = '4';
        accObj.Other_Phone_Sequence__c = '1';
        accObj.Home_Phone_Sequence__c = '3';
        accObj.Mobile_Phone_Sequence__c = '2';
        accObj.PersonHomePhone = '123';
        update accObj;
        obj.loadObjects(contact.id);
        obj.thisCall.Service_Description__c = '11';
        obj.thisCall.Customer_Experience__c  = '11';        
        obj.customSave();
        Test.stopTest();
    }
    
    static testmethod void testLoadObjects() {
        loadObjectsData();
        
        test.startTest();
        obj.loadObjects(contact.id);
        test.stopTest();
        
        system.assert(obj.campmem != null);
        system.assert(obj.account != null);
        system.assert(obj.dealer != null);
        system.assert(obj.callList != null);
        system.assert(obj.vehicle != null);
        system.assert(obj.contact != null);
        
    }
    
    static testmethod void testGetIsExpressDealer() {
        loadObjectsData(); 
        obj.loadObjects(contact.id);
        
        test.startTest();
        string isExpressDealer = obj.getIsExpressDealer();
        test.stopTest();
        
        system.assert(isExpressDealer == system.label.NO);
    }
    
    
    static testmethod void testGetWLCVisibilty() {
        loadObjectsData();
        
        test.startTest();
        string theURL = obj.getWLCVisiblity();
        test.stopTest();
        
        system.assert(theURL!= null);
    }
    
    static testmethod void testGetChangeContact() {
        
        loadObjectsData();
        
        test.startTest();
        string theURL = obj.getChangeContact();
        test.stopTest();
        
        system.assert(theURL!= null);
    }
    
    static testmethod void testGetDisplaySendEmailCheckbox() {
        loadObjectsData();
        obj.loadObjects(contact.id);
        
        test.startTest();
        //string displaySendEmailChebox = obj.getDisplaySendEmailCheckbox();
        boolean displaySendEmailChebox = obj.getDisplaySendEmailCheckbox();
        test.stopTest();
        
        //system.assert(displaySendEmailChebox == system.label.Send_Email_Checkbox_Visible);
    }
    
    static testmethod void testGetHeader() {
        loadObjectsData();
        obj.loadObjects(contact.id);
        
        test.startTest();
        string header = obj.getHeader();
        test.stopTest();
        
        system.assert(header != null);
    }
    
    static testmethod void testgetAccount(){
        loadObjectsData();
        
        test.startTest();
        obj.getAccount();
        test.stopTest();    
    }
    static testmethod void testgetVehicle() {
        loadObjectsData();
        
        test.startTest();
        obj.getVehicle();
        test.stopTest();
    }
    
    static testmethod void testgetCampMemb() {
        loadObjectsData();
        
        test.startTest();
        obj.getCampMemb();
        test.stopTest();
    }
    
    static testmethod void testgetDealer() {
        loadObjectsData();
        
        test.startTest();
        obj.getDealer();
        test.stopTest();
    }
    
    static testmethod void testgetCallList() {
        loadObjectsData();
        
        test.startTest();
        obj.getCallList();
        test.stopTest();
    }
    
    static testmethod void testgetThisCall() {
        loadObjectsData();
        
        test.startTest();
        obj.getThisCall();
        test.stopTest();
    }
    
    
    static testmethod void testgetScriptURL() {
        loadObjectsData();
        obj.loadObjects(contact.id);
        
        test.startTest();
        string scriptURL = obj.getScriptURL();
        test.stopTest();
        
        //system.assert(scriptURL == null);
    }
    
    
    static testmethod void testCustomSave() {
        loadObjectsData();
        obj.loadObjects(contact.id);
        Task updateCall =[select CallDisposition__c from Task limit 1];
        test.startTest();
        obj.customSave();
        test.stopTest();    
    }
     static testmethod void testRunWebServiceGetDealerInfoNegative() {
        loadObjectsData();
        obj.apiName = system.label.GetDealerInfo;
        obj.dealerCode = '5049';
        obj.havePrefferedDealerAccount = false;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);  
}

     

    static testmethod void testRunWebServiceGetDealerInfoPositive() {
        loadObjectsData();
        obj.apiName = system.label.GetDealerInfo;
        obj.dealerCode = '5049';
        
            
        Test.startTest();
        obj.RunWebService();
        Test.StopTest(); 
    }
    
    static testmethod void testRunWebServiceSearchDealer() {
        loadObjectsData();
        obj.apiName = system.label.SearchDealer;  
                    
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
       
    }
    
    static testmethod void testRunWebServiceGetPrimaryContactInfo() {
        loadObjectsData();
        obj.apiName = system.label.GetPrimaryContactInfo;
         
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceGetServiceHistory() {
        loadObjectsData();
        obj.apiName = system.label.GetServiceHistory;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isServiceHistoryResponse == false);   
       
    }   
    
    static testmethod void testRunWebServiceGetCommunicationHistory() {
        loadObjectsData();
        obj.apiName = system.label.GetCommunicationHistory;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
       
    } 
    
    static testmethod void testRunWebServiceCheckAppointmentNegative() {
        loadObjectsData();
        obj.apiName = system.label.CheckAppointment;
        obj.havePrefferedDealerAccount = false;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceCheckAppointmentPositive() {
        loadObjectsData();
        obj.apiName = system.label.CheckAppointment;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        
    }
    
    
    static testmethod void testRunWebServiceCheckAppointmentTimePositive() {
        loadObjectsData();
        obj.apiName = system.label.CheckAppointmentTime;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        
    }
    
    static testmethod void testRunWebServiceCheckAppointmentTimeNegative() {
        loadObjectsData();
        obj.apiName = system.label.CheckAppointmentTime;
        obj.havePrefferedDealerAccount = false;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isSimpleRecord == false);
    }
    
    static testmethod void testRunWebServiceGetServicesDue() {
        loadObjectsData();
        obj.apiName = system.label.GetServicesDue;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isServiceResponse == false);
    } 
    
    static testmethod void testRunWebServiceGetAssociatedCustomers() {
        loadObjectsData();
        obj.apiName = system.label.GetAssociatedCustomers;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        System.assert(obj.isListOfRecords == false);   
    }   
    
     static testmethod void testRunWebServiceGetAppointmentSubscribeURLNegative() {
        loadObjectsData();
        obj.apiName = system.label.GetAppointmentSubscribeURL; 
        obj.havePrefferedDealerAccount = false;
        
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
        //System.assert(obj.isSimpleRecord == false);   
       
    }
    
    static testmethod void testRunWebServiceGetAppointmentSubscribeURLPositive() {
        loadObjectsData();
        obj.apiName = system.label.GetAppointmentSubscribeURL; 
            
        Test.startTest();
        obj.RunWebService();
        Test.StopTest(); 
    }         
    static testmethod void testRunWebServiceGetassociated_dcno_id() {
        loadObjectsData();
        obj.apiName = system.label.Getassociated_dcno_id; 
               
        Test.startTest();
        obj.RunWebService();
        Test.StopTest();
        
        System.assert(obj.isError == true);
    }  
    
    static testmethod void testPaasParams() {
        loadObjectsData();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        obj = new Controller_AgentConsole(sc);
        
        Test.startTest();
        PageReference page = obj.PaasParams();
        Test.StopTest();
        
        System.assert(page != null);
        
    }
    
    static testmethod void testPaasParamsforDateTime() {
        loadObjectsData();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        obj = new Controller_AgentConsole(sc);
        
        Test.startTest();
        PageReference page = obj.PaasParamsforDateTime();
        Test.StopTest();
        
        System.assert(page != null);
    }
    
    static testmethod void testPaasParamsforDate() {
        loadObjectsData();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        obj = new Controller_AgentConsole(sc);
        
        Test.startTest();
        PageReference page = obj.PaasParamsforDate();
        Test.StopTest();
        
        System.assert(page != null);
    }
    
    static testmethod void testcheckLatestTask() {
        loadObjectsData();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        obj = new Controller_AgentConsole(sc);
        
        Test.startTest();
        PageReference page = obj.checkLatestTask();
        Test.StopTest();
        
        //System.assert(page != null);
    }
}