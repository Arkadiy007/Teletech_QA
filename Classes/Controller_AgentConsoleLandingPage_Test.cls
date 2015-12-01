/**********************************************************************
Name: Controller_AgentConsoleLandingPage_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
This is a test class for Controller_AgentConsoleLandingPage.

Related Class : Controller_AgentConsoleLandingPage
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/31/2011 Created    
1.1 - JJ, removed isactive=true from the manager query class in 
        test constructor three, production has no active users of this
        role                      
***********************************************************************/
@isTest
private class Controller_AgentConsoleLandingPage_Test {
    private static Contact contact;
    static void  InitializeData() {
        contact = new Contact();
        contact.LastName = 'Test';
        insert contact;
        ApexPages.currentPage().getParameters().put(system.label.contactID, contact.id);
        Campaign camp = new Campaign();
        camp.Name = 'test';
        camp.StartDate = date.newinstance(1960, 2, 17);
        camp.EndDate = date.newinstance(1960, 5, 20);
        camp.IsActive = true;
        insert camp;
        CampaignMember campmem = new CampaignMember();
        campmem.Status = 'Sent';
        campmem.CampaignId = camp.id;
        campmem.ContactId = contact.id;
        insert campmem; 
        
    } 
    
 
    static void  Initialize() {
        contact = new Contact();
        contact.LastName = 'Test1';   
        insert contact; 
        ApexPages.currentPage().getParameters().put(system.label.contactID, contact.id);
        Campaign camp = new Campaign();
        camp.Name = 'test1';
        camp.StartDate = date.newinstance(1960, 2, 17);
        camp.EndDate = date.newinstance(1960, 5, 20);
        camp.IsActive = false;
        insert camp;
        CampaignMember campmem = new CampaignMember();
        campmem.Status = 'Sent';
        campmem.CampaignId = camp.id;
        campmem.ContactId = contact.id;
        insert campmem; 


    }
    
       
    static testMethod void testConstructorOne() {
        InitializeData();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        
        test.startTest();
        Controller_AgentConsoleLandingPage scon = new Controller_AgentConsoleLandingPage(sc);
        scon.getContact();
        scon.getIncludeString();
        test.stopTest();
        
        //system.assert(scon.IncludeString == system.label.StandardContact);
    }
    
    static testMethod void  testConstructorTwo() {
        Initialize();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        
        test.startTest();
        Controller_AgentConsoleLandingPage scon = new Controller_AgentConsoleLandingPage(sc);
        scon.getContact();
        scon.getIncludeString();
        test.stopTest();
        
        system.assert(scon.IncludeString == system.label.StandardContact); 
    }
    
    static testMethod void  testConstructorThree() {
         UserRole r = [Select id from UserRole where Name=:System.Label.ServiceMarketing];
         User manager = [Select id , LanguageLocaleKey, LocaleSidKey, TimeZoneSidKey, EmailEncodingKey, ProfileId from user where Profile.Name = 'System Administrator' limit 1];
         User u = new User(UserRoleId = r.id, ManagerId = manager.id, Username='john@123T%^.com', LastName = 'test', Email='test@test.com', Alias='test', 
                        CommunityNickname='testerson', TimeZoneSidKey = manager.TimeZoneSidKey, LocaleSidKey = manager.LocaleSidKey, EmailEncodingKey = manager.EmailEncodingKey,
                        ProfileId = manager.ProfileId, LanguageLocaleKey = manager.LanguageLocaleKey);
         insert u;
         Controller_AgentConsoleLandingPage scon;

         system.runAs(u) {
         InitializeData();
         ApexPages.StandardController sc = new ApexPages.StandardController(contact);
         test.startTest();
         scon = new Controller_AgentConsoleLandingPage(sc);
         test.stopTest();
         }
         system.assert(scon.IncludeString == system.label.AgentConsole);
    }
    
    
}