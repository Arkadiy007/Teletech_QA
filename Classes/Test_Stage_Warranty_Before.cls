/**
 * This class contains unit tests for Stage_Warranty_before
 * Author: Aaron Bessey
 * Date 9/9/2014
 */
@isTest
private class Test_Stage_Warranty_Before {
    private static testmethod void main() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', warranty_app_amount__c='25', warranty_vcan_delete__c=true );
        insert u;
        
        Stage_Warranty_Users__c swu = new Stage_Warranty_Users__c();
        swu.Name = 'test';
        swu.USER_CD__c = 'dwil';
        swu.APRVL_LMT_AM__c = '30';
        
        insert swu;
        
        System.assert([Select warranty_app_amount__c from User where Id =: u.Id].warranty_app_amount__c == '30');
        Test.stopTest();
    }
}