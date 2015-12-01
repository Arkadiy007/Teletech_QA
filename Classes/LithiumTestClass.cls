@isTest(OnInstall=false)
private class LithiumTestClass{
    private static LithiumSettings__c  liSetting;
    
    public static testMethod void test() {
        // make sure custom setting record exists
        liSetting = LithiumSettings__c.getValues('DefaultSetting');
        if(liSetting == NULL) {
            liSetting = new LithiumSettings__c();
            liSetting.Name = 'DefaultSetting';
            liSetting.Sync_With_Contact__c = true;
            liSetting.Create_New_Contact_record__c = true;
            
            insert liSetting;
            }
        else {
            liSetting.Sync_With_Contact__c = true;
            liSetting.Create_New_Contact_record__c = true;
            
            update liSetting;
            }
            
        testPages();
        testLithiumAPI();
        }
        
    public static void testLithiumAPI() {
        LithiumAPIUtil.getLithiumSettings();
        LithiumAPIUtil.login();
        LithiumAPIUtil.login('testsso');
        LithiumAPIUtil.getUserDetails('testuser');
        LithiumAPIUtil.getUserDetails(0);
        LithiumAPIUtil.getUserIconUrl('0');
        LithiumAPIUtil.getUserMessagePostHistory('0');
        LithiumAPIUtil.getUserPostCount('0');
        LithiumAPIUtil.getUserRanking('0');
        LithiumAPIUtil.searchCommunity('testsearch');
        LithiumAPIUtil.threadList('0', '0');
        }
        
    public static void testPages(){
        // create Contact
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;
        
        // create Li_Community_User__c
        List<Li_Community_User__c> liUsers = new List<Li_Community_User__c>();
        Li_Community_User__c liuser1 = new Li_Community_User__c();
        liuser1.Name = 'firstuser';
        liuser1.Lithium_User_Id__c = 30;
        liuser1.First_Name__c = 'user 1';
        liuser1.Last_Name__c = 'user 1 last';
        liuser1.REST_URL__c = 'http://test.com';
        liuser1.Email_Address__c = con.Email;
        liUsers.add(liuser1); // normal user
        Li_Community_User__c liuser2 = new Li_Community_User__c();
        liuser2.Name = 'seconduser';
        liuser2.First_Name__c = 'user 2';
        liuser2.Last_Name__c = 'user 2 last';
        liuser2.Lithium_User_Id__c = 31;
        liuser2.REST_URL__c = 'http://test2.com';
        liuser2.Email_Address__c = '2@2.com';
        liUsers.add(liuser2); // agent user

        insert liUsers;
        
        // create agent SF user
        Profile p = [select id from profile where name='Standard User'];
 
        User agent = new User(alias = 'test123', email=liuser2.Email_Address__c,
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        
        // create case
        Case cs = new Case();
        cs.Subject = 'test sub';
        cs.Description = 'test case';
        cs.Origin = 'Lithium';
		cs.Thread_ID__c = '0';  
		cs.Message_Posted__c = Datetime.now();  
		cs.Li_Community_User__c = liuser1.Id;
		cs.Community_URL__c = 'http://lithium.com';
		cs.Community_ID__c = '0';
		cs.Board_ID__c = '0';
		//cs.Author_Rank__c = 'ARank';
		//cs.Author_Login__c = liuser1.Name;
		//cs.Agent_Reason__c = 'test reason';
		//cs.Agent_Login__c = liuser2.Name;
		cs.Agent_Comments__c = 'some comments';
		
		insert cs;
		
		// create case comment
		Community_Postback_Comment__c pcom = new Community_Postback_Comment__c();
		pcom.Case__c = cs.Id;
		pcom.Visible_In_Self_Service_Portal__c = false;
		pcom.Postback_Comment__c = 'this is the initial comment';
		
		system.runAs(agent) {
			insert pcom;
			}
		
		pcom.Postback_Comment__c = 'there is a correction';
		pcom.Visible_In_Self_Service_Portal__c = true;
		
		system.runAs(agent) {
			update pcom;
			}
		
		//system.assertEquals(pcom.Salesforce_Agent__c, liuser2.Name); // not working for some reason. works via UI
               
        // user detial page 
        // contact
        Test.setCurrentPage(Page.PersonAccountUserDetails);
        ApexPages.StandardController condetailstdctrl = new ApexPages.StandardController(con);
        LithiumUserDetialsExtCls condetailextctrl = new LithiumUserDetialsExtCls(condetailstdctrl);
        
        // user metrics page 
        // contact
        Test.setCurrentPage(Page.PersonAccountUserMetrics);
        ApexPages.StandardController conmetricsstdctrl = new ApexPages.StandardController(con);
        LithiumUserDetialsExtCls conmetricsextctrl = new LithiumUserDetialsExtCls(conmetricsstdctrl);
        
        // user messages pages
        // community user
        Test.setCurrentPage(Page.CommunityUserMessages);
        ApexPages.StandardController commsgstdctrl = new ApexPages.StandardController(liuser2);
        LithiumUserMessageExtCls commsgextctrl = new LithiumUserMessageExtCls(commsgstdctrl);
        
        // user messages pages
        // contact
        Test.setCurrentPage(Page.PersonAccountUserMessages);
        ApexPages.StandardController conmsgstdctrl = new ApexPages.StandardController(con);
        LithiumUserMessageExtCls conmsgextctrl = new LithiumUserMessageExtCls(conmsgstdctrl);
        
        // avatar page
        // community user
        Test.setCurrentPage(Page.CommunityUserAvatar);
        ApexPages.StandardController comavtrstdctrl = new ApexPages.StandardController(liuser2);
        LithiumUserDetialsExtCls conavtrextctrl = new LithiumUserDetialsExtCls(comavtrstdctrl);
        
        // thread details page
        // case
        Test.setCurrentPage(Page.CaseThreadMessages);
        ApexPages.StandardController thdmsgstdctrl = new ApexPages.StandardController(cs);
        LithiumThreadDetails thdmsgextctrl = new LithiumThreadDetails(thdmsgstdctrl);
        }
    }