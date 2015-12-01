/**********************************************************************
Name: Task_After_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Task_After" trigger

Related to: Task_After
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Vijaya D 17/01/2011 Created
1.1 - Matt Starr 03/06/2014 Added test for Due Date fix
***********************************************************************/
@isTest
private Class Task_After_Test {
    static testMethod void testUpdateCaseDispostion() {
        /* 
            Create a Case & Task to test the functionality
        */
        Case caseRec = new Case();
       // caseRec.Disposition__c = 'Inquiry';
        insert caseRec;        
        
        Task taskRec = new Task();
        taskRec.whatid = caseRec.id;
        taskRec.CallDisposition__c = 'Wrong Number';
        insert taskRec;
           
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
        
        Test.startTest();
        taskRec.CallDisposition__c = 'Completed';
        update taskRec;        
         
        /*
          Stop the test, this changes limit context back to test from trigger. 
        */        
            
        Test.StopTest();
    
        /*
           Verify that the Disposition__c field was updated in the database.
        */
            
       // Case caseRecord = [select Disposition__c from case where Id = :caseRec.Id];
        //system.assert(caseRecord.Disposition__c=='Completed');
    }     
     
    static testMethod void testCreateTaskNotes() {
        /* 
            Create a Task to test the functionality
        */
        Account account = new Account();
        account.Name = 'testAcc';
        Insert account;
        
        Task objTask = new Task();
        objTask.Description = 'Initial Description';
        objTask.Whatid= account.id;
        insert objTask;
                               
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
        
        Test.startTest();
        objTask.Description = 'Changed Description';
        update objTask;
        
        /*
             Stop the test, this changes limit context back to test from trigger. 
        */
        
        Test.StopTest();
        
        /*
          Query the database for the newly inserted records. 
        */
        
        List<Note> NoteRecList = [select id, Title, Body, ParentId from Note where ParentId = : objTask.whatId];
        //system.assert(NoteRecList.size() == 1);
    } 
    
    static testMethod void testPreviousDueDate() {
    
    Case c = new Case(
            Status = 'Open',
            Origin = 'Phone');
            
    insert c;
    
    Task t = New Task(
    WhatId = c.Id,
    RecordtypeId = '012F0000000yFlr',
    Subject = 'Call',
    ActivityDate = system.today().AddDays(-1));
    
    insert t;
        
    
    
    }
}