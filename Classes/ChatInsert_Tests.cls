@isTest
private class ChatInsert_Tests {

static testMethod void ClassTest()
    {
        // Adding the needed parameters
        ApexPages.currentPage().getParameters().put('startTime','2147483648');
        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP',
            '111.111.111.111');
        
        // Inserting the needed objects
        Account acc = new Account();
        acc.LastName = 'Rohdenburg';
        acc.RecordTypeId = '012A0000000wu5h';
        insert acc; 
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor; 
        
        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.AccountId = acc.Id;
        transcript.IpAddress = '111.111.111.111';
        transcript.StartTime = DateTime.newInstance(
            Long.valueOf('2147483648'));
        transcript.LiveChatVisitorId = visitor.Id; 
        insert transcript;
        
        // Submit the post chat form
        LiveAgent_PostChat postChat = new LiveAgent_PostChat();
        postChat.concernSatisfied = 'Yes';
        postChat.concernComments = 'Outstanding';
        postChat.experienceSatisfied = 'Yes';
        postChat.experienceComments = 'Outstanding';
        postChat.recommended = '10';
        postChat.recommendedComments = 'Outstanding'; 
        postChat.submitPostChatForm();
        
        // Submit the Infiniti post chat form
        postChat = new LiveAgent_PostChat();
        postChat.submitInfinitiForm();
    }
}