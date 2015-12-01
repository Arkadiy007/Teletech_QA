/**********************************************************************
Name: ClaimFormThankYouController_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for ClaimFormThankYouController.cls.
 
======================================================
History: 

VERSION  AUTHOR       DATE     DETAIL
1.0 -   Vivek Batham 10/28/2015 Created 
***********************************************************************/
@isTest
private class ClaimFormThankYouController_Test {

     static Vehicle__c vehObj;
     
     
     static testmethod void positiveTest1(){
     
         apexpages.currentpage().getparameters().put('caseNum', '19310925');
     
         ClaimFormThankYouController clmCont = new ClaimFormThankYouController();
         System.assert(clmCont.isSuccess);
     }
     
     static testmethod void positiveTest2(){
     
              
         ClaimFormThankYouController clmCont = new ClaimFormThankYouController();
         System.assert(!clmCont.isSuccess);
     }
     
     static void createTestData(){        
                
        vehObj = new Vehicle__c(Name = 'VIN01000010000101', Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2007', Model_Line_Name__c = 'VERSA');
        insert vehObj;
        
        Claim_Form_Settings__c clmForm =  new Claim_Form_Settings__c(Name=Label.Claim_NissanVersa, Case_Origin__c = 'Nissan Assist', Amount_Limit__c = 2500, Case_Owner_Id__c = Userinfo.getUserId(), 
                                            Case_Record_Type__c = 'CA Email Nissan', Model_Years__c = '2007,2008,2009', Model_Line__c = 'VERSA');
        
        insert clmForm;
        
     }
     
     

}