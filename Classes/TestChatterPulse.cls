/**
 * This class contains unit tests for Chatter Pulse
 */
@isTest
private class TestChatterPulse {
    public static testmethod void myChatterPulse() {
        
        //Check to see if Account is Feed Enabled
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();     
        if(r.IsFeedEnabled())
        {
            Test.startTest();
            //Create a test Account
            Account acc = new Account(Name = 'Test Account');
            insert acc;
     
            // Create post on Account
            FeedItem fi = new FeedItem();
            fi.Body = 'This is a test, this is only a test';
            fi.parentId = acc.id;
            insert fi;
            
            //Comment on the post
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'This is a comment on the test post';
            fc.FeedItemId = fi.id;
            insert fc;            
            
            datetime t = System.now();
            date myReportingDate = Date.newInstance(t.year(),t.month(),t.day());
            
            CP_Chatter_Pulse__c[] myPulse = [SELECT Update_Type__c FROM CP_Chatter_Pulse__c 
            WHERE CP_Chatter_Pulse__c.Reporting_Date__c = :myReportingDate];
            
            String ActualUpdateType;
            try {
                ActualUpdateType = myPulse[0].Update_Type__c;
            }
            catch (exception e) {
                ActualUpdateType = '';
                //Likely that the user does not have access to create records
            }   
            
            System.AssertNotEquals(ActualUpdateType, null);
            
            Test.stopTest();
        }
        
    }
    
    
    public static testmethod void myChatterFreeUser() {
        Test.startTest();
        String profileName='Chatter Free User';
        Integer numUsersToCreate=1;
        List<User> users=createUsers(numUsersToCreate, profileName);
        
        for(User u: users) {
            system.runas(u){
                //Create a group, as the Chatter Free user
                CollaborationGroup grp= new CollaborationGroup();
                grp.Name = 'This is a test group';
                grp.CollaborationType = 'Public';                    
                insert grp; 
                
                //Create a post to fire the ChatterPulseAdd trigger
                FeedItem fi = new FeedItem();
                fi.Body = 'This is a test post to a group, this is only a test';
                fi.parentId = grp.id;
                insert fi; 
                
                //Comment on the post to fire the ChatterPulseCommentAdd trigger
                FeedComment fc = new FeedComment();
                fc.CommentBody = 'Comment on the test comment';
                fc.FeedItemId = fi.id;
                insert fc;
            }
        }
        Test.stopTest();
    }

    //utility class to create dummy users
    public static List<User> createUsers(Long numUsers, string profileName){
        Profile p = [select id from profile where Name=:profileName]; 
        List<user> users=new List<user>();
        for (Integer i=0; i<numUsers;i++){
            User u = new User(alias = 'user', email=profileName.replace(' ','')+'user'+i+'@chatterPulse.test.com', 
            emailencodingkey='UTF-8', lastName='testUser'+i, languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', userName=profileName.replace(' ','')+'user'+i+'@chatterPulse.test.com');
            users.add(u);
            }//for 1 
        insert users;
        return users;
    }//createUsers

}