/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2015, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Tests for Controller used by the Live Agent PostChat pages

Class:              LiveAgent_Direct_Tests
Author:             Arkadiy Sychev
Date:               1/29/2015
Version:            1.0
Last Updated:       1/29/2015
    * 1/20/2015    Arkadiy Sychev - Created
*/

@isTest

public class LiveAgent_PostChat_Test {
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

	static testMethod void ClassTest2()
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
        
        // Submit the new Nissan form
        LiveAgent_PostChat postChat = new LiveAgent_PostChat();
        postChat.concernSatisfied = 'Yes';
        postChat.concernComments = 'Outstanding';
        postChat.experienceSatisfied = 'Yes';
        postChat.experienceComments = 'Outstanding';
        postChat.recommended = '10';
        postChat.recommendedComments = 'Outstanding'; 
		postChat.startDateTime = null;
        postChat.submitNewNissanForm();
        
        // Submit the new Infiniti post chat form
        postChat = new LiveAgent_PostChat();
        postChat.submitNewInfinitiForm();

		// Submit the new Leaf post chat form
        postChat = new LiveAgent_PostChat();
        postChat.submitNewLeafForm();

		// Submit the NCV post chat form
        postChat = new LiveAgent_PostChat();
        postChat.submitNCV();

		// Submit the DPIC post chat form
        postChat = new LiveAgent_PostChat();
        postChat.submitDpic();
    }
}