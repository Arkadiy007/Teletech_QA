@isTest
private class RCASSearchExtension_Test {
    
    static testmethod void testSearchAccounts(){
        String dealerTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i ++) {
            Account testAccount = new Account(RecordTypeId = dealerTypeRTId, Name = 'TestAccount', Dealer_Code__c = String.valueOf(i+10), 
                                                Region_Code__c = String.valueOf(i+15), District_Code__c =String.valueOf(i+20));
            
            testAccounts.add(testAccount);
        }
        insert testAccounts;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         
            
        User adminUserTest = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
        
        insert adminUserTest;
    
        test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testAccounts[0]);
        
        RCASSearchExtension rcasController = new RCASSearchExtension(controller);
        
        rcasController.regionCode = '16';
        rcasController.districtCode = '21';
        
        rcasController.search();
        
        System.assert(rcasController.acctList.size() > 0, true);
        
        rcasController.acctList[0].selAcct = true;        
        
        rcasController.userAcct.RCAS__c =  adminUserTest.Id; 
        rcasController.reAssignAccounts();
        
        System.assertequals([Select Id, RCAS__c from Account where Id =: rcasController.acctList[0].acctObj.Id].RCAS__c,  adminUserTest.Id);
    }
}