@isTest
private class CAUserManagementExtension_Test {

    static testmethod void testSearchUsersWithValidations(){
    
        Profile profile = [SELECT Id FROM Profile WHERE Name='CA DRT' limit 1];
         
            
        User caDrtUser = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ZCA_Id__c = '123hj',
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
        
        insert caDrtUser;
        
        
        
        Profile profile2 = [SELECT Id FROM Profile WHERE Name='CA Manager' limit 1]; 
        
        User caMgrUser = new User(Alias = 'adminUT1', Email = 'fake1@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing1', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile2.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing1@CB_ADMIN__TMS_Testing.com');
        
        insert caMgrUser ;
        
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(caMgrUser);
        CAUserManagementExtension caMgt = new CAUserManagementExtension(controller);
        
        caMgt.acct.RCAS__c = caDrtUser.Id;
        caMgt.userDisplay();
        
        // Check for required fields
        caMgt.userMgracct.RCAS__c  = caMgrUser.Id;
        caMgt.updateUser();
        
        System.assert([Select Id, ManagerId from User where Id =:caDrtUser.Id].ManagerId != caMgrUser.Id);        
       
        
    } 
    
    
     static testmethod void testSearchUsersWithUpdate(){
    
        Profile profile = [SELECT Id FROM Profile WHERE Name='CA DRT' limit 1];
         
            
        User caDrtUser = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles',Segment__c = 'A - Nissan Assist', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com', Location__c = 'Franklin');
        
        insert caDrtUser;
        
        
        
        Profile profile2 = [SELECT Id FROM Profile WHERE Name='CA Manager' limit 1]; 
        
        User caMgrUser = new User(Alias = 'adminUT1', Email = 'fake1@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing1', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile2.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing1@CB_ADMIN__TMS_Testing.com');
        
        insert caMgrUser ;
        
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(caMgrUser);
        CAUserManagementExtension caMgt = new CAUserManagementExtension(controller);
        
        caMgt.acct.RCAS__c = caDrtUser.Id;
        caMgt.SearchUser();
        
        // Check for required fields
        caMgt.userMgracct.RCAS__c  = caMgrUser.Id;
        caMgt.updateUser();      
              
        System.assert([Select Id, ManagerId from User where Id =:caDrtUser.Id].ManagerId == caMgrUser.Id);
        
    } 
    
    
    static testmethod void testNonCAprofile(){
    
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
         
            
        User caDrtUser = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles',Segment__c = 'A - Nissan Assist', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com', Location__c = 'Franklin');
        
        insert caDrtUser;
        
        
                
        User caMgrUser = new User(Alias = 'adminUT1', Email = 'fake1@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing1', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing1@CB_ADMIN__TMS_Testing.com');
        
        insert caMgrUser ;
        
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(caMgrUser);
        CAUserManagementExtension caMgt = new CAUserManagementExtension(controller);
        
        caMgt.acct.RCAS__c = caDrtUser.Id;
        caMgt.SearchUser();
        
        System.assert([Select Id, ManagerId from User where Id =:caDrtUser.Id].ManagerId != caMgrUser.Id);
        
        // Check for required fields
        caMgt.userMgracct.RCAS__c  = caMgrUser.Id;
        caMgt.updateUser();      
              
        System.assert([Select Id, ManagerId from User where Id =:caDrtUser.Id].ManagerId != caMgrUser.Id);
        
    } 

}