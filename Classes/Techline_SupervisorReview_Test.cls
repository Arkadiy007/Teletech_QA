/**********************************************************************
Name: Techline_SupervisorReview_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline_SupervisorReview.cls.
 
======================================================
History: 

VERSION AUTHOR     DATE       DETAIL
1.0 - Vivek Batham 08/03/2015 Created 
***********************************************************************/
@isTest(seeAllData = false)
private class Techline_SupervisorReview_Test {
    
     // -------- Test --------
    static testMethod void ClassTest()
    {
        Contact con = new Contact();
        con.FirstName = 'Auto-generated';
        con.LastName = 'Contact';
        con.Email = 'no-reply@organization.com';
        insert con;
      
    
        Case techlineCase = new Case();
        techlineCase.Issue_Type__c = 'Full';
        insert techlineCase;
        
        Techline_SupervisorReview tsr = new Techline_SupervisorReview();
        tsr.createSupervisorTasks(techlineCase.Id, techlineCase.CaseNumber);
    }

}