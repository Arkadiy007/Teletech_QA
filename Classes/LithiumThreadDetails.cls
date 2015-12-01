public class LithiumThreadDetails {
	public Case aCase {get; private set;}
	public Boolean hasDetail {get; private set;}
	public List<LithiumAPIUtil.LiMessage> messageList {get; private set;}
	
	public LithiumThreadDetails(ApexPages.StandardController controller) {
		String caseId = controller.getId();
        messageList = new List<LithiumAPIUtil.LiMessage> ();
        List<Case> caseList = new List<Case>();
        caseList.addAll([SELECT Origin, 
		        			Thread_ID__c, 
		        			Message_Posted__c, 
		        			Li_Community_User__c, 
		        			Community_URL__c, 
		        			Community_ID__c, 
		        			//Board_ID__c, 
		        			//Author_Rank__c, 
		        			//Author_Login__c, 
		        			//Agent_Reason__c, 
		        			//Agent_Login__c, 
		        			Agent_Comments__c 
		        			FROM Case
		        			WHERE Id = :caseId]);
		
		if(!caseList.isEmpty()) {
			aCase = caseList[0];
			
			if(aCase.Thread_ID__c != NULL)
				messageList = LithiumAPIUtil.threadList(aCase.Thread_ID__c, aCase.Board_ID__c);
			}
			
		hasDetail = !messageList.isEmpty();	
		}
	}