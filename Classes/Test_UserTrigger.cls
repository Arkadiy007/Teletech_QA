/**
 * This class contains unit tests for UserTrigger
 * Author: Aaron Bessey
 * Date 9/12/2014
 */
@isTest
private class Test_UserTrigger {
    private static testmethod void main() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = TestData_Utils.CreateUser(p.Id);
        insert u;
        
        u = [Select Id, License_Cost_Per_Month__c, VCAN_Password__c from user where id=:u.Id];
        
        System.assert(u.VCAN_password__c != 'test1234');   
        System.assert(u.License_Cost_Per_Month__c == 112.00); 
        
        u.VCAN_Password__c = 'newPword1234';
        u.UserPermissionsKnowledgeUser = false;
        update u;
        
        u = [Select Id, License_Cost_Per_Month__c, VCAN_Password__c from user where id=:u.Id];
        
        System.assert(u.VCAN_Password__c != 'newPword1234');
        
        Test.stopTest();
        
        System.assert(u.License_Cost_Per_Month__c == 103.00);
    }
}