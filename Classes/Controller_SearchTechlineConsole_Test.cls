@isTest (seeAllData=true)
Public class Controller_SearchTechlineConsole_Test{
    public static testMethod void test1(){
    PageReference pageRef = Page.SearchTechlineConsole;
    Test.setCurrentPageReference(pageRef);
    
     RecordType acctrec1 = [select Id from Recordtype where sobjecttype = 'Account' and Name = 'Dealer'];
     RecordType acctrec2 = [select Id from Recordtype where sobjecttype = 'Account' and Name = 'TMS'];
     List<Account> accts = new List<Account>();
     String caseno;   
        
     Account a1 = New Account(
            Name = 'test acct',
            RecordTypeId = acctrec1.Id,
            Dealer_Code__c = '1234',
            Make_Name__c = 'Nissan',
            Dealer_External_Id__c = '1234_USA');
     accts.add(a1);
        
     Account a2 = New Account(RecordTypeId = acctrec2.Id);
            a2.FirstName = 'test';
            a2.LastName = 'last';
            a2.PersonMailingState = 'CO';
            a2.PersonMailingPostalCode = '80221';
            a2.PersonEmail = 'test@sfdc.com';
            a2.RecordTypeId = acctrec2.Id;
            a2.PersonHomePhone = '3039999999';
     accts.add(a2); 
        
        insert accts;
        
        Vehicle__c v = new Vehicle__c(
        Vehicle_identification_Number__c = 'abcd1234567890123');
        
        insert v;
        
        Case c = new Case(
            Status = 'Open',
            Origin = 'Phone');
       
        insert c;
        
        
         
   Controller_SearchTechlineConsole cont = new Controller_SearchTechlineConsole();   

        cont.dealercode = '1234';
        cont.searchDealers();
        cont.firstname = 'test';
        cont.lastname = 'last';
        cont.zip = '80221';
        cont.state = 'CO';
        cont.searchAccounts();
        cont.vin = 'abcd1234567890123';
        cont.searchVehicles();
        Case cc = [select CaseNumber from Case where Id = :c.Id];
        cont.caseNumber = cc.CaseNumber;
        cont.searchCases();
        cont.clear();  
            
        
    
    }
 }