/**********************************************************************
Name: StopCheckPaymentController_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for StopCheckPaymentController.cls.
 
======================================================
History: 

VERSION  AUTHOR        DATE         DETAIL
1.0 -   Vivek Batham  11/19/2015   Created 
***********************************************************************/
@isTest
private class StopCheckPaymentController_Test{
    
    static Check_Request__c chkReq;
    
    static testMethod void stopPaymentTest() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        StopCheckPaymentController chkExtension = new StopCheckPaymentController(chkController);
        chkExtension.getReqActions();
        chkExtension.getReasonItems();
        chkExtension.saveChk();
        
        System.assert(ApexPages.hasMessages(ApexPages.Severity.Error));
        
        chkExtension.reason = 'Expired Check';
        chkExtension.action = 'Stop Payment';
        
        chkExtension.saveChk();
        
        System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
        
    }
    
    static testMethod void voidPaymentTest() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        StopCheckPaymentController chkExtension = new StopCheckPaymentController(chkController);
               
        chkExtension.reason = 'Expired Check';
        chkExtension.action = 'void';
        
        chkExtension.saveChk();
        chkExtension.cancel();
        
        System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
        
    }
    
    static void createTestData(){
        
        Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id caEmailNissanRTypeId = rtInfosByName.get('CA Email Nissan').getRecordTypeId();
        
        Vehicle__c veh = new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005');
        insert veh;
        
        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;
        
        Case cas = TestData_Utils.CreateCase(caEmailNissanRTypeId);
        cas.Vehicle_Name__c = veh.Id;
        insert cas;
        
        List<State__c> stateList = new List<State__c>();
        stateList.add(new State__c(Name = 'TX', Name__c = 'Texas', Order__c = 1));
        stateList.add(new State__c(Name = 'ON', Name__c = 'Ontario', Order__c = 2));
       
        insert stateList;
        
        
        chkReq = new Check_Request__c();
        chkReq.Case__c = cas.id;
        chkReq.Special_Comments__c = 'Special Comments';
        chkReq.Check_Amount__c = 100;
        chkReq.Payable_To_First_Name__c = 'First';
        chkReq.Payable_To_Last_Name__c = 'ZYXABC';
        chkReq.GL_Code__c = glCode.Id;
        chkReq.Mailing_Address_Verified__c = true;
        chkReq.Approval_Indicator__c = 'Y';        
        chkReq.Payment_Verification__c = true;
        
        insert chkReq;
    
    }    
    
 }