/**********************************************************************************
Name: Case_Before_Owner_Update
Copyright © notice: Nissan Motor Company
===================================================================================
Purpose: 
Update Case Owner email field

History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Will Taylor     4/14/2014 Created
2.0 - Vivek Batham	  2/24/2015 Modified for Best Practices and adding VCS Record Type

************************************************************************************/
trigger Case_Before_OwnerIdUpdate on Case (before insert, before update) {
    Set<String> recordTypeList = new Set<String>();
    Map<String, Schema.RecordTypeInfo> recorTypemap = Schema.Sobjecttype.Case.getRecordTypeInfosByName(); 
    Map<String, String> ownerIdQueueMap = new Map<String, String>();
    
    for(String s : recorTypemap.keyset()){
    	if(s == Label.CA_Email_Nissan || s == Label.CA_Email_Infiniti || s == Label.CA_Sales_Service
    		|| s == Label.T5 || s == Label.CA || s == Label.VCS_Support){
    			
    			recordTypeList.add(recorTypemap.get(s).getRecordTypeId());
    		}
    }

    Map<String,User> users = new Map<String,User>([SELECT Id, FirstName, LastName, Name, Email, Location__c FROM User where IsActive = true]);
    
    List<QueueSobject> queuesExcludeQ = [select id, Queue.Name, QueueId from QueueSobject where SobjectType = 'Case'];
    Set<ID> queuesExcludeList = new Set<ID>();
    
    for (QueueSobject r : queuesExcludeQ ) {
        queuesExcludeList.add(r.QueueId);
        ownerIdQueueMap.put(r.QueueId, r.Queue.Name);
    }
    
      
    for (Case c: Trigger.new) {
        if (!queuesExcludeList.contains(c.OwnerId)) {
        	User user = users.get(c.OwnerId);   
            if (recordTypeList.contains(c.RecordTypeId) && c.Ownerid != null) { 
                if(user != null){
	                if (user.Email != null && user.Name != Label.Managed_Services) {
	                    c.Case_Owner_Email__c = user.Email;
	                    c.Case_Owner_Location2__c = user.Location__c;
	                }
	             c.Case_Owner_First_Name__c = user.FirstName; 
	             c.Case_Owner_Last_Name__c = user.LastName;    
            	}                
      		}                  
      }
       else{
       	     c.Case_Owner_First_Name__c = '';
             c.Case_Owner_Last_Name__c = ownerIdQueueMap.get(c.OwnerId);
           }  
      
    } 
    
    

    
}