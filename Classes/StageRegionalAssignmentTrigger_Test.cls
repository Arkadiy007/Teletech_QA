/**********************************************************************
Name: StageRegionalAssignmentTrigger_Test 
Copyright © notice: Nissan Motor Company.
=====================================================================
Purpose: Test class for StageRegionalAssignmentTrigger.        
=====================================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        07/08/2014    Created

***********************************************************************/

@isTest
private class StageRegionalAssignmentTrigger_Test {

      public static testmethod void testRelateDealerAssignment(){
         Account dealerAcct = TestData_Utils.createTestDealer();
         insert dealerAcct; 
         
         Test.startTest();
          
         Stage_Regional_Assignment__c deaRegAsnt = new Stage_Regional_Assignment__c(
                                                     Position__c = 'DOM', Email__c = 'testDOM@nissa-usa.com', 
                                                     Cell_Phone__c = '9876789768', District_Code__c = '05', Region_Code__c = '24',
                                                     Primary_DMA__c = 'N. CHICAGO / MILWAUKEE', Region__c = 'CHICAGO' /*, 
                                                     Regional_User__c = 'testDealer'*/);
         insert deaRegAsnt;
         
         Test.stopTest();
         
         System.assert(([Select Id from User_Assignment__c where Dealer__c =: dealerAcct.Id]).size() > 0, true); 
         
         
      }
      
       public static testmethod void testRelateDealerwRegionCodeOnly(){
         Account dealerAcct = TestData_Utils.createTestDealer();
         dealerAcct.District_Code__c = '';
         insert dealerAcct; 
         
         Test.startTest();
          
         Stage_Regional_Assignment__c deaRegAsnt = new Stage_Regional_Assignment__c(
                                                     Position__c = 'DOM', Email__c = 'testDOM@nissa-usa.com', 
                                                     Cell_Phone__c = '9876789768',  Region_Code__c = '24',
                                                     Primary_DMA__c = 'N. CHICAGO / MILWAUKEE', Region__c = 'CHICAGO' /*, 
                                                     Regional_User__c = 'testDealer'*/);
         insert deaRegAsnt;
         
         Test.stopTest();
         
         System.assert(([Select Id from User_Assignment__c where Dealer__c =: dealerAcct.Id]).size() > 0, true); 
         
         
      }
      
      public static testmethod void testRelateDealerAGMAssignment(){
         Account dealerAcct = TestData_Utils.createTestDealer();
         insert dealerAcct; 
         
         Dealer_Regional_Assignment__c dealerAssignment = new Dealer_Regional_Assignment__c(Name='24A', Region_District_Codes__c = '24-01,24-05');
         insert dealerAssignment;
         
         Test.startTest();
          
         Stage_Regional_Assignment__c deaRegAsnt = new Stage_Regional_Assignment__c(
                                                     Position__c = 'AGM', Email__c = 'lawrence.schwartz@nissa-usa.com', 
                                                     Cell_Phone__c = '9876789768', Region_Code__c = '24A',
                                                     Primary_DMA__c = 'N. CHICAGO / MILWAUKEE', Region__c = 'CHICAGO' /*, 
                                                     Regional_User__c = 'testAGMDealer'*/);
         insert deaRegAsnt;
         
         Test.stopTest();
         
         System.assert(([Select Id from User_Assignment__c where Dealer__c =: dealerAcct.Id]).size() > 0, true); 
         
         
      }
      
      public static testmethod void testdeleteStageAssignment(){
         Account dealerAcct = TestData_Utils.createTestDealer();
         insert dealerAcct; 
         
        
          
         Stage_Regional_Assignment__c deaRegAsnt = new Stage_Regional_Assignment__c(
                                                     Position__c = 'DOM', Email__c = 'lawrence.schwartz@nissa-usa.com', 
                                                     Cell_Phone__c = '9876789768', District_Code__c = '05', Region_Code__c = '24',
                                                     Primary_DMA__c = 'N. CHICAGO / MILWAUKEE', Region__c = 'CHICAGO' /*, 
                                                     Regional_User__c = 'Larry Schwartz'*/);
         insert deaRegAsnt;
         
         Test.startTest();
         
         delete deaRegAsnt;
         
         Test.stopTest();
         
         System.assert(([Select Id from User_Assignment__c where Dealer__c =: dealerAcct.Id]).size() == 0, false); 
         
         
      }
      
}