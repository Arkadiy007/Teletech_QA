/**********************************************************************
Name: UserAssignment_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for UserAssignment_BI_BU Trigger.
 
======================================================
History:

VERSION     AUTHOR         DATE         DETAIL
1.0 -       Vivek Batham   01/20/2015   Created 
***********************************************************************/
@isTest
private class UserAssignment_Test  {

    static testmethod void UserAssignmentInsert(){
    
      Id recordtypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, System.Label.AccRTDealer);
           
      List<Stage_User__c> sus = new List<Stage_User__c> {new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1111', Username__c = 'ServiceManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1224',  Username__c = 'PartsManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'NNA Case support - Parts'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1114',  Username__c = 'SalesManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Sales'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1234', Username__c = 'DealerUser', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Other'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1444', Username__c = 'ServiceManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1432', Username__c = 'PartsManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'NNA Case support - Parts'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1542', Username__c = 'SalesManager', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Sales'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '1625', Username__c = 'DealerUser', Email__c = 'stgusertest@noemail.tst', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Active', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Other'),
                                                                       new Stage_User__c(User_Type__c = 'D', External_Identifier__c = '4512', Username__c = 'ServiceManager', Email__c = '', Last_Name__c='Test last name',
                                                                                                             Primary_Phone_Number__c = '111-111-1111', User_Status__c = 'Disabled', SFDC_Partner_Portal_User__c = 'Consumer Affairs - Service')};
                                                                                                             
       
      insert sus;
       
      List<Account> dealers = new List<Account> {new Account(RecordTypeId = recordtypeId, Name = 'Stage User Test Nissan Dealer', Dealer_Code__c = 'StgUserNissanDlr',
                                                             DTS_A_Stage_user__c = sus[0].Id, DTS_B_Stage_User__c = sus[1].Id, EVOM_Stage_User__c = sus[0].Id, Dealer_External_Id__c = 'StgUserNissanDlr_USA', Make_Name__c = 'Nissan'),
                                                new Account(RecordTypeId = recordtypeId, Name = 'Stage User Test Infiniti Dealer', Dealer_Code__c = 'StgUserNissanDlr2',
                                                             DTS_A_Stage_user__c = sus[2].Id, DTS_B_Stage_User__c = sus[1].Id, Dealer_External_Id__c = 'StgUserInfinitiDlr_USA', Make_Name__c = 'Nissan'),
                                                new Account(RecordTypeId = recordtypeId, Name = 'Stage User Test Nissan Dealer 2', Dealer_Code__c = 'StgUserInfinitiDlr',
                                                             EVOM_Stage_User__c = sus[0].Id,  FOM_Stage_User__c = sus[2].Id, Dealer_External_Id__c = 'StgUserNissanDlr2_USA', Make_Name__c = 'Infiniti'),
                                                new Account(RecordTypeId = recordtypeId, Name = 'Stage User Test Infiniti Dealer 2', Dealer_Code__c = 'StgUserInfinitiDlr2',
                                                            LPM_Stage_User__c = sus[3].Id, DTS_B_Stage_User__c = sus[1].Id, Dealer_External_Id__c = 'StgUserInfinitiDlr2_USA', Make_Name__c = 'Infiniti')};
                                                                                        
      insert dealers;
                                                                                        
      
      
      test.starttest();
      
      User_Assignment__c usrA = new User_Assignment__c(Dealer__c = dealers[0].Id, Stage_User__c = sus[0].Id, Employee_Role__c = 'AGM');
      
      insert usrA;
      
      User_Assignment__c usrA2 = new User_Assignment__c(Dealer__c = dealers[0].Id, Stage_User__c = sus[1].Id, Employee_Role__c = 'AGM');
      
      insert usrA2;
      
      System.assertequals(([Select Id from User_Assignment__c where Dealer__c =: dealers[0].Id]).size(), 1);
    
    }

}