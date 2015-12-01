public class LithiumUserDetialsExtCls {
    public Li_Community_User__c liUser {get; set;}
    public String iconUrl {get; set;}
    public boolean hasDetail {get; set;}
    
    public LithiumUserDetialsExtCls(ApexPages.StandardController controller) {
        String liUserId = controller.getId();
        hasDetail = false;
        
        List <Li_Community_User__c> lUser = new List<Li_Community_User__c> ();
        if(liUserId.startsWith('003')) {
        	lUser.addAll([SELECT Name, isUserDeleted__c, Roles__c, Registration_Time__c, Rank__c, 
				        	REST_URL__c, Metric_Private_Messages_Sent__c, Metric_Private_Messages_Received__c, Metric_Posts__c, 
				        	Metric_Page_Views__c, Metric_Minutes_Online__c, Metric_Messages_Read__c, Metric_Logins__c, 
				        	Metric_Average_Message_Rating__c, Location__c, Lithium_User_Id__c, Last_Visit_Time__c, 
				        	Last_Name__c, Homepage_URL__c, First_Name__c, Email_Address__c, Contact__c, 
				        	Biography__c, Administrative_Notes__c
				        	From Li_Community_User__c 
				        	WHERE Contact__c = :liUserId]);
	    	if(!lUser.isEmpty()) {
	    		liUser = lUser[0];
	    		}
        	}
        else if(liUserId.startsWith('001')) { // Person Account
        	lUser.addAll([SELECT Name, isUserDeleted__c, Roles__c, Registration_Time__c, Rank__c, 
				        	REST_URL__c, Metric_Private_Messages_Sent__c, Metric_Private_Messages_Received__c, Metric_Posts__c, 
				        	Metric_Page_Views__c, Metric_Minutes_Online__c, Metric_Messages_Read__c, Metric_Logins__c, 
				        	Metric_Average_Message_Rating__c, Location__c, Lithium_User_Id__c, Last_Visit_Time__c, 
				        	Last_Name__c, Homepage_URL__c, First_Name__c, Email_Address__c, Contact__c, 
				        	Biography__c, Administrative_Notes__c
				        	From Li_Community_User__c 
				        	WHERE Person_Account__c = :liUserId]);
	    	if(!lUser.isEmpty()) {
	    		liUser = lUser[0];
	    		}
        	}
        else {
        	lUser.addAll( [SELECT Name, isUserDeleted__c, Roles__c, Registration_Time__c, Rank__c, 
				           REST_URL__c, Metric_Private_Messages_Sent__c, Metric_Private_Messages_Received__c, Metric_Posts__c, 
				           Metric_Page_Views__c, Metric_Minutes_Online__c, Metric_Messages_Read__c, Metric_Logins__c, 
				           Metric_Average_Message_Rating__c, Location__c, Lithium_User_Id__c, Last_Visit_Time__c, 
				           Last_Name__c, Homepage_URL__c, First_Name__c, Email_Address__c, Contact__c, 
				           Biography__c, Administrative_Notes__c 
				           From Li_Community_User__c 
				           WHERE Id = :liUserId]);
			if(!lUser.isEmpty()) {
        		liUser = lUser[0];
        		}
        	}
        
        if(liUser != NULL){       
            iconUrl = LithiumAPIUtil.getUserIconUrl(liUser.Lithium_User_Id__c.format());
            hasDetail = true;
        	}
    	}
	}