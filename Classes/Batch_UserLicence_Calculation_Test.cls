/**********************************************************************
Name: Batch_UserLicence_Calculation_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_UserLicence_Calculation.cls.
 
======================================================
History: 

VERSION     AUTHOR        DATE       DETAIL
1.0 -     Vivek Batham   1/7/2015   Created 
***********************************************************************/
@isTest
private class Batch_UserLicence_Calculation_Test {

      public static testmethod void main(){
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];      
      User u = TestData_Utils.CreateUser(p.Id);     
      insert u;
      
      Batch_UserLicence_Calculation btchUser = new Batch_UserLicence_Calculation();
      btchUser.query = 'Select Id, UserType, IsActive, ProfileId, Profile.UserLicense.Name,  Cost_Center__c, '+
                       'LastLoginDate, UserPermissionsKnowledgeUser, UserPermissionsLiveAgentUser,  Profile.Name, '+
                       'SF_License__c, License_Cost_Per_Month__c FROM User WHERE IsActive = TRUE AND Cost_Center__c != \'Partner Portal\' limit 10';
      Database.executeBatch(btchUser, 200);
      
      u = [Select Id, License_Cost_Per_Month__c from user where id=:u.Id];
      
      System.assert(u.License_Cost_Per_Month__c == 112.00); 
      
      }
      
      
}