/**********************************************************************
Name: Batch_D360_Summary_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class contains unit tests for validating the behavior of "Account_Before_LeadMigration"
and "Account_After_LeadMigration" Triggers.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr     03/03/2014 Created
***********************************************************************/
@isTest //(seealldata = true)
public class Batch_D360_Summary_Test{
    static testMethod void D360_Summary_Test1() {
        
        //RecordType acctrec1 = [select Id from Recordtype where sobjecttype = 'Account' and Name = 'Dealer'];
        //Recordtype caserec = [select Id from Recordtype where sobjecttype = 'Case' and Name = 'CA Closed Case'];
        List<Code__c> codes = new List<Code__c>();
        List<Account> accts = new List<Account>();
        List<Case> cases = new List<Case>();
        List<Case_Categorization__c> ccs = new List<Case_Categorization__c>();
        
        
        Code__c code1 = new Code__c(
            Description__c = 'NSN DEALER SALES DEPT.',
            RecordtypeId = '012F0000000yFnY',
            Code__c = 'BE',
            Type__c = 'Category',
            Active__c = true);
        codes.add(code1);
        
        Code__c code2 = new Code__c(
            Description__c = 'test 1',
            RecordtypeId = '012F0000000yFnY',
            Code__c = 'T1',
            Type__c = 'Root_Cause_Code',
            Active__c = true);
        codes.add(code2);
        
        Code__c code3 = new Code__c(
            Description__c = 'test 1',
            RecordtypeId = '012F0000000yFnY',
            Code__c = 'T2',
            Type__c = 'Root_Cause_Code',
            Active__c = true);
        codes.add(code3);
        
        Code__c code4 = new Code__c(
            Description__c = 'NSN DEALER SERVICE DEPT.',
            RecordtypeId = '012F0000000yFnY',
            Code__c = 'BE',
            Type__c = 'Category',
            Active__c = true);
        codes.add(code4);
        
        Code__c code5 = new Code__c(
            Description__c = 'NSN DEALER SERVICE DEPT.',
            RecordtypeId = '012F0000000yFnY',
            Code__c = '24BUYBACK',
            Type__c = 'GL_Code',
            Active__c = true);
        codes.add(code5);
        
        insert codes;
        
           
        Account a = New Account(
            Name = 'test acct',
            RecordTypeId = '012A0000000OfI0',
            Dealer_Code__c = '1234',
            Make_Name__c = 'Nissan',
            Dealer_External_Id__c = '1234_USA');
        accts.add(a);
        
        Account a2 = New Account(
            Name = 'test acct',
            RecordTypeId = '012A0000000OfI0',
            Dealer_Code__c = '5678',
            Make_Name__c = 'Nissan',
            Dealer_External_Id__c = '5678_USA');
        accts.add(a2);
        
        insert accts;
        
        Closed_Dealer_Case_Summary__c sum = new Closed_Dealer_Case_Summary__c(
            Dealer_Id__c = a2.Id,
            Dealer_Name__c = a2.Name,
            Dealer_Code__c = a2.Dealer_Code__c,
            Dealer_Division__c = a2.Make_Name__c); 
        
        insert sum;
        
        Vehicle__c v = new Vehicle__c(
            RecordtypeId = '012A0000000OfXh',
            Vehicle_identification_Number__c = '456abc');
        
        insert v;            
        
        Case c = new Case(
            recordtypeId = '012F0000000yCuE',
            Status = 'Open',
            Origin = 'Phone',
            Servicing_Dealer__c = a.Id,
            Special_Root_Cause_Closing_Code__c = code2.Id,
            Who_called__c = 'P - Parts Department',
            Stage_Status__c = System.Label.Stage_Status_Done,
            Data_Net__c = true);
        cases.add(c);
        
       Case c2 = new Case(
            recordtypeId = '012F0000000yCuE',
            Status = 'Open',
            Origin = 'Phone',
            Servicing_Dealer__c = a2.Id,
            Special_Root_Cause_Closing_Code__c = code2.Id,
            Who_called__c = 'P - Parts Department',
            Stage_Status__c = System.Label.Stage_Status_Done,
            Data_Net__c = true);
        cases.add(c2);
        
        Case c3 = new Case(
            recordtypeId = '012F0000000yCuE',
            Status = 'Open',
            Origin = 'Phone',
            Servicing_Dealer__c = a2.Id,
            Special_Root_Cause_Closing_Code__c = code2.Id,
            Who_called__c = 'P - Parts Department',
            Stage_Status__c = System.Label.Stage_Status_Done,
            Vehicle_Name__c = v.Id,
            Data_Net__c = true);
        cases.add(c3);
        
         Case c4 = new Case(
            recordtypeId = '012F0000000yCuE',
            Status = 'Open',
            Origin = 'Phone',
            Servicing_Dealer__c = a.Id,
            Special_Root_Cause_Closing_Code__c = code2.Id,
            Who_called__c = 'P - Parts Department',
            Stage_Status__c = System.Label.Stage_Status_Done,
            Vehicle_Name__c = v.Id,
            Data_Net__c = true);
        cases.add(c4);
        

        insert cases;
    
         Case_Categorization__c cc = new Case_Categorization__c(
            Case__c = c.Id,
            Category__c = code1.Id);
        ccs.add(cc);
        
        Case_Categorization__c cc2 = new Case_Categorization__c(
            Case__c = c2.Id,
            Category__c = code4.Id);
        ccs.add(cc2);
        
        Case_Categorization__c cc3 = new Case_Categorization__c(
            Case__c = c3.Id,
            Category__c = code4.Id);
        ccs.add(cc3);
        
        Case_Categorization__c cc4 = new Case_Categorization__c(
            Case__c = c4.Id,
            Category__c = code4.Id);
        ccs.add(cc4);

        insert ccs;

        Check_Request__c cr = new Check_Request__c(
            Case__c = c3.Id,
            Check_Amount__c = 50,
            Check_Number__c = '1234',
            Check_Type__c = 'Customer',
            Mailing_Address_Verified__c = true,
            Business_Name_1__c = 'Test Co',
            Payment_Verification__c = true,
            GL_Code__c = code5.Id);

        insert cr;

        Check_Request__c cr2 = new Check_Request__c(
            Case__c = c4.Id,
            Check_Amount__c = 50,
            Check_Number__c = '1234',
            Check_Type__c = 'Customer',
            Mailing_Address_Verified__c = true,
            Business_Name_1__c = 'Test Co',
            Payment_Verification__c = true,
            GL_Code__c = code5.Id);
            

        insert cr2;

        test.startTest();
        
        for(Case upcase : cases){
            upcase.Status = 'Closed';}

        update cases;  

        Closed_Dealer_Case_Summary__c oldcdcs = new Closed_Dealer_Case_Summary__c();

        insert oldcdcs;

        Closed_Dealer_Case_Detail__c oldcdcd = New Closed_Dealer_Case_Detail__c(
        Closed_Dealer_Case_Summary__c = oldcdcs.Id);

        insert oldcdcd;

    
        id batchinstanceid = database.executeBatch(new Batch_D360_Delete());
     test.stopTest();
    
    }
}