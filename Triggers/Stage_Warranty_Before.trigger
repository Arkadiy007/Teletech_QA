// -------------
// Stage_Warranty_Before trigger:   populates the approval amounts and approval delete ability 
//                                  on the user object based on zca id given.
// -------------

trigger Stage_Warranty_Before on Stage_Warranty_Users__c (before insert, before update) {
    List<User> userList = [select Id, warranty_app_amount__c, warranty_vcan_delete__c, ZCA_Id__c from User where ZCA_Id__c != null ];
    List<User> userUpdate = new List<User>();
    String zcaId;
    Map<String,User> userMap = new Map<String,User>();
    for(User u: userList) {
        if (u.ZCA_Id__c == null) {
            // skip record, don't add to list
        } else {
        	zcaId = u.ZCA_Id__c.toLowerCase();
            userMap.put(zcaId, u);
        }
    }

    //if (Trigger.isInsert) {
        for (Stage_Warranty_Users__c swu : Trigger.New) {
            // find user, populate with   swu.
            if(swu.USER_CD__c != null){
	            User uu = null;
	            zcaId = swu.USER_CD__c.toLowerCase();
	            uu = userMap.get(zcaId);
	            if (uu == null) {
	                // no result from search
	            } else {
	                uu.warranty_app_amount__c = swu.APRVL_LMT_AM__c;
	                //uu.warranty_vcan_delete__c = ??
	                userUpdate.add(uu);
	            }
            
            }
            
        }
   
    
update userUpdate;

        


}