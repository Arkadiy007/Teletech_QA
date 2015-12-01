/**********************************************************************
Name: PullCheckRequestExtensions_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for PullCheckRequestExtensions.cls.
 
======================================================
History: 

VERSION  AUTHOR       DATE     DETAIL
1.0 -   Vivek Batham 09/29/2015 Created 
***********************************************************************/
@isTest
private class PullCheckRequestExtensions_Test {
    
    static Check_Request__c chkReq;
    
    static testMethod void createPullCheckTest() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        PullCheckRequestExtensions chkExtension = new PullCheckRequestExtensions(chkController);
        
        chkExtension.cancel();       
        
        chkExtension.useExistingAddressChk = true;
        chkExtension.evaluatePCFields();
        chkExtension.save();
        
        System.assert(ApexPages.hasMessages());
        chkExtension.tempChk.PC_Mail_To_Name__c = 'Test1';
        chkExtension.tempChk.PC_Mail_To_Address__c = 'Add1';
        chkExtension.tempChk.PC_Mail_To_State__c = 'TX';
        chkExtension.tempChk.PC_Mail_To_City__c = 'Irving';
        chkExtension.tempChk.PC_Mail_To_Country__c = 'US';
        chkExtension.tempChk.PC_Mail_To_Zip__c = '75080';
        chkExtension.save();
        
    }
    
    static testMethod void createPullCheckTest2() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        PullCheckRequestExtensions chkExtension = new PullCheckRequestExtensions(chkController);
        
        chkExtension.useExistingAddressChk = false;
        
        chkExtension.tempChk.PC_Mail_To_Name__c = 'Test1';
        chkExtension.tempChk.PC_Mail_To_Address__c = 'Add1';
        chkExtension.tempChk.PC_Mail_To_State__c = 'Ti';
        chkExtension.tempChk.PC_Mail_To_City__c = 'Irving';
        chkExtension.tempChk.PC_Mail_To_Country__c = 'US';
        chkExtension.tempChk.PC_Mail_To_Zip__c = '75080';
        chkExtension.save();
        
        boolean b = false;

        for(Apexpages.Message msg:ApexPages.getMessages()){        
            if (msg.getDetail().contains(Label.Valid_PC_Mail_to_State)) b = true;        
        }
        
        system.assert(b);
       
    }
    
    static testMethod void createPullCheckRequestValidationTest() {
        createTestData();
        chkReq.Payable_To_First_Name__c= 'PFName';
        chkReq.Payable_To_Last_Name__c = 'PLName';
        chkReq.Business_Name_1__c = 'BName1';
        chkReq.Business_Name_2__c = 'BName2';
        chkReq.PC_Mail_To_Address__c = 'Add1';
        chkReq.PC_Mail_To_City__c = 'tCity';
        chkReq.PC_Mail_To_Country__c = 'US';
        chkReq.PC_Mail_To_State__c = 'TX';
        chkReq.PC_Mail_To_Zip__c = '75080';
        chkReq.Issue_Date__c = Date.today();
        update chkReq;
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        PullCheckRequestExtensions chkExtension = new PullCheckRequestExtensions(chkController);
        
        chkExtension.cancel();       
        
        chkExtension.useExistingAddressChk = true;
        chkExtension.evaluatePCFields();
        chkExtension.save();
        
        System.assert(ApexPages.hasMessages());
        chkExtension.tempChk.PC_Mail_To_Name__c = 'Test1';
        chkExtension.tempChk.PC_Mail_To_Address__c = 'Add1';
        chkExtension.tempChk.PC_Mail_To_State__c = 'TX';
        chkExtension.tempChk.PC_Mail_To_City__c = 'Irving';
        chkExtension.tempChk.PC_Mail_To_Country__c = 'US';
        chkExtension.tempChk.PC_Mail_To_Zip__c = '75080';
        chkExtension.save();
        
    }
    
    static testMethod void pcZipValidationUS() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        PullCheckRequestExtensions chkExtension = new PullCheckRequestExtensions(chkController);
        
        chkExtension.useExistingAddressChk = false;
        chkExtension.tempChk.PC_Mail_To_Name__c = 'Test1';
        chkExtension.tempChk.PC_Mail_To_Address__c = 'Add1';
        chkExtension.tempChk.PC_Mail_To_State__c = 'TX';
        chkExtension.tempChk.PC_Mail_To_City__c = 'Irving';
        chkExtension.tempChk.PC_Mail_To_Country__c = 'US';
        chkExtension.tempChk.PC_Mail_To_Zip__c = '750880';
        chkExtension.save();
        boolean b = false;

        for(Apexpages.Message msg:ApexPages.getMessages()){        
            if (msg.getDetail().contains(Label.Valid_PC_Zip_Code)) b = true;        
        }
        
        system.assert(b);
        
    }
    
    static testMethod void pcZipValidationCAN() {
        createTestData();
        
        ApexPages.StandardController chkController =  new ApexPages.StandardController(chkReq);        
        PullCheckRequestExtensions chkExtension = new PullCheckRequestExtensions(chkController);
        
        chkExtension.useExistingAddressChk = false;
        chkExtension.tempChk.PC_Mail_To_Name__c = 'Test1';
        chkExtension.tempChk.PC_Mail_To_Address__c = 'Add1';
        chkExtension.tempChk.PC_Mail_To_State__c = 'ON';
        chkExtension.tempChk.PC_Mail_To_City__c = 'Ottawa';
        chkExtension.tempChk.PC_Mail_To_Country__c = 'CA';
        chkExtension.tempChk.PC_Mail_To_Zip__c = '9tg';
        chkExtension.save();
        boolean b = false;

        for(Apexpages.Message msg:ApexPages.getMessages()){        
            if (msg.getDetail().contains(Label.Valid_PC_Zip_Code_Canada)) b = true;        
        }
        
        system.assert(b);
        
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