trigger LiveChatTranscriptEvent_Before on LiveChatTranscriptEvent (before insert)  {
	try{
		List<Id> lct = new List<id>();
		for(LiveChatTranscriptEvent chatEvent : Trigger.new){
			lct.add(chatEvent.LiveChatTranscriptId);
		}
		map<id,LiveChatTranscript> mapLct = new map<Id,Livechattranscript>([select id,Chat_requested_time_in_ms__c, Chat_routed_in_ms__c from Livechattranscript where id in :lct]);
		for(LiveChatTranscriptEvent chatEvent : Trigger.new){
			if(chatEvent.Type == 'ChatRequest'){
				mapLct.get(chatEvent.LiveChatTranscriptId).Chat_requested_time_in_ms__c = chatEvent.time.getTime();
			}else if(chatEvent.Type == 'PushAssignment'){
				mapLct.get(chatEvent.LiveChatTranscriptId).Chat_routed_in_ms__c = chatEvent.time.getTime() - mapLct.get(chatEvent.LiveChatTranscriptId).Chat_requested_time_in_ms__c;
			} else if(chatEvent.Type == 'Accept'){
				mapLct.get(chatEvent.LiveChatTranscriptId).Chat_accepted_in_ms__c = chatEvent.time.getTime()-mapLct.get(chatEvent.LiveChatTranscriptId).Chat_routed_in_ms__c  - mapLct.get(chatEvent.LiveChatTranscriptId).Chat_requested_time_in_ms__c;
			}
		}

		update mapLct.values();
	}catch (exception e){
		System.debug('Exception occuried: ' + e.getMessage());
	}
 }