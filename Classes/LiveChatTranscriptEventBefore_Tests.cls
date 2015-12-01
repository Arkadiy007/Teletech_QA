@istest
public class LiveChatTranscriptEventBefore_Tests {

	static testmethod void testEventTime(){
	    LiveChatVisitor visitor = new LiveChatVisitor();
		insert visitor;
		visitor = [select id from LiveChatVisitor];

		LiveChatTranscript transcript = new LiveChatTranscript(LiveChatVisitorId = visitor.id);
		insert transcript;
		transcript = [select id from LiveChatTranscript limit 1];
		
		LiveChatTranscriptEvent requestEvent = new LiveChatTranscriptEvent(LiveChatTranscriptId = transcript.id, Type = 'ChatRequest', Time = Datetime.newInstance(9000));
		LiveChatTranscriptEvent routeEvent = new LiveChatTranscriptEvent(LiveChatTranscriptId = transcript.id, Type = 'PushAssignment', Time = Datetime.newInstance(10000));
		LiveChatTranscriptEvent acceptEvent = new LiveChatTranscriptEvent(LiveChatTranscriptId = transcript.id, Type = 'Accept', Time = Datetime.newInstance(11000));
		List<LiveChatTranscriptEvent> events = new List<LiveChatTranscriptEvent> {requestEvent, routeEvent, acceptEvent};
		insert events;

		transcript = [select id, Chat_requested_time_in_ms__c, Chat_routed_in_ms__c, Chat_accepted_in_ms__c from LiveChatTranscript limit 1];
		System.assertEquals(transcript.Chat_requested_time_in_ms__c, requestEvent.time.getTime());
		System.assertEquals(transcript.Chat_routed_in_ms__c, routeEvent.time.getTime() - transcript.Chat_requested_time_in_ms__c);
		System.assertEquals(transcript.Chat_accepted_in_ms__c, acceptEvent.time.getTime()-transcript.Chat_routed_in_ms__c  - transcript.Chat_requested_time_in_ms__c);
	}
 }