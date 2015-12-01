/**********************************************************************
Name: AutoCaseAssignmentExtensions_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test AutoCaseAssignmentExtensions
 
======================================================
History: 

VERSION     AUTHOR     DATE         DETAIL
1.0 -     Vivek Batham 8/31/2015     Created 
***********************************************************************/
@isTest
private class AutoCaseAssignmentExtensions_Test {

    static testmethod void LoadControllerTest(){
        
        Id CArecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
        
        Group grp = [select Id from Group where Name =: Label.CA_Email_Nissan and Type = 'Queue' Limit 1];
       
        Case casObj = TestData_Utils.CreateCase(CArecordTypeId);        
        casObj.OwnerId = grp != null ? grp.Id : UserInfo.getUserId();
        insert casObj;
        
       
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(casObj);
        AutoCaseAssignmentExtensions extns = new AutoCaseAssignmentExtensions(controller);
        extns.loadQueueData();
        
        Test.stopTest();
        System.assert(extns.caNissanCases == 1);
        
        
    }
    
     static testmethod void AssignCaseTest(){
        
        Profile prof = [Select Id from Profile where Name = 'CA Email Agent'];
        
        User usr = TestData_Utils.CreateUser(prof.Id);
        insert usr;
        
        Group grp = [select Id from Group where Name =: Label.CA_Email_Nissan and Type = 'Queue' Limit 1];
        
       // System.runAs(usr){
        Id CArecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
        Case casObj = TestData_Utils.CreateCase(CArecordTypeId);        
        casObj.OwnerId = grp != null ? grp.Id : UserInfo.getUserId();
        insert casObj;
        
       
                
        System.debug('casObj:::'+casObj);
        ApexPages.StandardController controller = new ApexPages.StandardController(casObj);
        AutoCaseAssignmentExtensions extns = new AutoCaseAssignmentExtensions(controller);
        
        
        Test.startTest();
                
        extns.assignCase();        
        System.debug('assignedcasObj:::'+[Select Id, OwnerId from Case where Id=:casObj.Id]);
        extns.loadQueueData(); 
               
        Test.stopTest();
        //System.assert([Select Count() from Case where OwnerId =: UserInfo.getUserId()] == 1);
        
       // }
               
        
    }
    
       
}