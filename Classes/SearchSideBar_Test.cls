@isTest
private class SearchSideBar_Test {
    
    static List<Account> testPersonAccounts;
    static List<Case> testCases;
    static List<Account> testBusAccounts;
    static Vehicle__c vehicle;
    
    static void createTestData(){
    
    State__c state = new State__c(Name= 'KY', Name__c = 'Kentucky', Order__c = 18);
    insert state;
    
     String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
     String busRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
     String DPICTypeRTId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('DPIC').getRecordTypeId();
        
     testPersonAccounts= new List<Account>();
        for (Integer i = 0; i < 5; i ++) {
            Account testAccount = new Account(FirstName = 'Person', PersonMailingPostalCode = '40202', PersonMailingState= 'KY');
            testAccount.RecordTypeId = personTypeRTId ;
            testAccount.lastName = 'TestAccount';
            testAccount.PersonEmail = 'test@abc.org';
            
            testPersonAccounts.add(testAccount);
        }
        insert testPersonAccounts;
        
       testCases = new List<Case>();
        for (Integer i = 0; i < 5; i ++) {
            Case testCase = new Case();
            testCase.ContactID = testPersonAccounts[i].PersonContactId;
            testCase.RecordTypeId = DPICTypeRTId;
            testCase.Subject = 'email to case';
            
            testCases.add(testCase);
        }
        insert testCases; 
        
        testBusAccounts = new List<Account>();
        Account acct= new Account();
        acct.name = 'Business Account';
        acct.RecordTypeId = busRecordTypeId;
        acct.Dealer_Code__c = 'Test';
        acct.Dealer_External_Id__c = 'Test_USA';
        testBusAccounts.add(acct);
        insert testBusAccounts; 
        
        vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '1N345678901234567';
        insert vehicle;
        
    }
    
    static testmethod void testSideBarPersonAccounts() {
      
        createTestData();
        test.startTest();
        SearchSideBar sideBar = new SearchSideBar();
        sideBar.firstName = 'Person';
        sideBar.lastName = 'TestAccount';
        sideBar.zip = '40202';
        sideBar.State = 'KY';
        
        sideBar.searchAccounts();
        
        test.StopTest();
        
        System.assert(sideBar.accountList.size() > 0);
        
     }
     
     
     static testmethod void testSideBarforCases() {
      
        createTestData();
        
        test.startTest();
        SearchSideBar sideBar = new SearchSideBar();        
        Case casObj = [Select Id, CaseNumber from Case where Id IN : testCases limit 1];
        sideBar.caseNumber = casObj.CaseNumber;
        sideBar.searchCases();
        
        test.StopTest();
        
        System.assert(sideBar.caseList.size() > 0);
        
     }
     
     static testmethod void testSideBarforBusAccounts() {
      
        createTestData();
        test.startTest();
        SearchSideBar sideBar = new SearchSideBar();
        sideBar.consumerSearch = false;
        sideBar.acctName = 'Business';
        sideBar.searchAccounts();
        sideBar.refreshAccountsSearch();
        
        
        test.StopTest();
        System.assert(sideBar.accountList.size() > 0);
        
     }
     
     static testmethod void testSideBarforVINS() {
      
        createTestData();
        test.startTest();
        SearchSideBar sideBar = new SearchSideBar();
        sideBar.vin= '1N345678901234567';
        
        sideBar.searchVehicles();
        sideBar.backToSearch();
        sideBar.refreshAccountsSearch();        
        
        test.StopTest();
        System.assert(sideBar.vehicleList.size() > 0);
        
     }
     
     
        
}