/**********************************************************************
Name: Batch_Techline_OneTimeSetPublic_Test 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for OneTimesetpublic Techline job for comments.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 4/7/2014
***********************************************************************/   
   
@isTest
private class Batch_Techline_OneTimeSetPublic_Test  {
   
    static testMethod void Batch_Techline_OneTimeSetPublic_Test  () {

       List<Case> cases = new List<Case>();
        Case c1 = new Case(RecordTypeId = '012F0000000yFmQ');
        c1.Report_Type__c='MINI';
        cases.add(c1); 
                
        insert cases;

        List<CaseComment> caseComments = new List<CaseComment>();
        CaseComment cc1 = new CaseComment();
        cc1.isPublished = false;
        cc1.ParentId = c1.Id;
        cc1.CommentBody = 'ZYXABC';
        caseComments.add(cc1);


        Test.startTest();
    //System.assertEquals(false,cc1.isPublished);
            Batch_Techline_OneTimeSetPublic batch = new Batch_Techline_OneTimeSetPublic();
            Database.executeBatch(batch);
    //System.assertEquals(true,cc1.isPublished);
        Test.stopTest();
        
        
        
        
    }   
    
    
    
}