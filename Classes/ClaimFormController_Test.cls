/**********************************************************************
Name: ClaimFormController_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for ClaimFormController.cls.
 
======================================================
History: 

VERSION  AUTHOR       DATE     DETAIL
1.0 -   Vivek Batham 10/28/2015 Created 
***********************************************************************/
@isTest
private class ClaimFormController_Test {
    
    static Vehicle__c vehObj;
    
    static testmethod void positiveTestCaseCreation(){
        
        createTestData();
        ClaimFormController clmFrm = new ClaimFormController();
       
        clmFrm.fName = 'FName';
        clmFrm.lName = 'LName';
        clmFrm.Address1 = 'Add1';
        clmFrm.Address2 = 'Add2';
        clmFrm.city = 'City';
        clmFrm.state = 'TN';
        clmFrm.zipCode = '37067'; 
        clmFrm.dayPhone = '0987657890';
        clmFrm.ePhone = '8765668909';
        clmFrm.email = 'zz@yy.com';
        clmFrm.vehModel = '';
        clmFrm.modelYr = '';
        clmFrm.vin = 'VIN01000010000101';
        clmFrm.CheckValidVehicle();
        clmFrm.amount = 0;
        clmFrm.ownerSign = 'XX';
        clmFrm.coOwnerSign = 'XX';
        clmFrm.userName = 'testUser';
        clmFrm.amount = 80;
        clmFrm.save();  
        
        clmFrm.fileSize = 1000;
        clmFrm.attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        clmFrm.fileName = 'test';
        clmFrm.upload();
        clmFrm.submit();   
        
        System.assert(clmFrm.caseNumber != null);   
        
    }
    
    
    
    static testmethod void negativeTestTwo(){
        createTestData();
        ClaimFormController clmFrm = new ClaimFormController();
        clmFrm.save();
        System.assertEquals(clmFrm.isSuccess, false, 'Validate to check if the page has error before proceeding.');
    
    }
    
    static testmethod void positiveTestTwo(){
        createTestData();
        ClaimFormController clmFrm = new ClaimFormController();
        clmFrm.limitsProcessing();
        clmFrm.vin = 'VIN01000010000101';
        clmFrm.CheckValidVehicle();
        clmFrm.save();
        System.assertEquals(clmFrm.isSuccess, false, 'Validate to check if the page has error before proceeding.');
    
    }
    
     static testmethod void positiveTestThree(){
        createTestData();
        ClaimFormController clmFrm = new ClaimFormController();
        clmFrm.limitsProcessing();
        clmFrm.vin = 'VIN01000010000101';
        clmFrm.CheckValidVehicle();
        clmFrm.save();
        System.assertEquals(clmFrm.isSuccess, false, 'Validate to check if the page has error before proceeding.');
    
    }
    
    
    
     static void createTestData(){        
                
        vehObj = new Vehicle__c(Name = 'VIN01000010000101', Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2007', Model_Line_Name__c = 'VERSA');
        insert vehObj;
        
        Claim_Form_Settings__c clmForm =  new Claim_Form_Settings__c(Name=Label.Claim_NissanVersa, Case_Origin__c = 'Nissan Assist', Amount_Limit__c = 2500, Case_Owner_Id__c = Userinfo.getUserId(), From_Address__c = 'NissanSolutionOperationsSupport',
                                            Case_Record_Type__c = 'CA Email Nissan', Model_Years__c = '2007,2008,2009', Model_Line__c = 'VERSA', Status__c = 'Open', Site_User_Name__c = 'ClaimForm Site Guest User', Eligible_Campaign__c = 'RC0');
        
        insert clmForm;
        
        State__c st = new State__c(Name='TN', Name__c = 'Tennessee', Order__c = 1);
        insert st;
        
        Sites_Daily_Limit__c dLimit = new Sites_Daily_Limit__c(SetupOwnerId = UserInfo.getUserId(), Claims_Daily_Limit__c = 1000);
        insert dLimit;
        
        Master_Recall_Campaign__c existingMaster = new Master_Recall_Campaign__c(Name = 'RC0');
        existingMaster.Recall_Identifier__c = 'RC0!!';
        existingMaster.Vehicle_Recall_Business_ID__c = 'RC0!!';
        existingMaster.Dealer_Submitted_Claim_Code__c = '0980';
        insert existingMaster;
        
        //testing upserting existing Vehicle_Recall__c 
        Vehicle_Recall__c existingRecall = new Vehicle_Recall__c();
        existingRecall.Vehicle__c = vehObj.ID;
        existingRecall.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingRecall.Recall_Identifier__c = 'RC0!!';
        existingRecall.Dealer_Submitted_Claim_Code__c = '0980';
        existingRecall.Master_Recall_Campaign__c = existingMaster.ID;
        existingRecall.Vehicle_Recall_Business_ID__c = existingRecall.Recall_Identifier__c + '_' + existingRecall.Vehicle_Identification_Number__c;
        existingRecall.Effective_Date__c = System.today();
        insert existingRecall;
        
     }

}