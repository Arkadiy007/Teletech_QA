/*
    Page Title: UserTrigger
    Author: Aaron Bessey
    Create Date: 7/25/2015
    Last Update: 7/25/2014
    Updated By: Aaron Bessey

    Revisions:
    AAB - Initial Creation
  
*/
trigger UserTrigger on User (before insert, before update) {
    
    // Generate the data to be encrypted.
	Blob key = Blob.valueOf('ABC1234DEF9012GHIJKLZZZYYY123465');
	Blob IV = Blob.valueOf('123456ZCBDE4YAGH');
	Blob cipherText;
    String encodedCipherText;
    Blob encodedEncryptedBlob;
    Set<String> profileIds = new Set<String>();
    
	if(Trigger.isInsert)
    {
        for(User u : Trigger.new)
        {
    		if(u.VCAN_Password__c!=null)
            {
                cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(u.VCAN_Password__c));
                encodedCipherText = EncodingUtil.base64Encode(cipherText); 
    
                u.VCAN_Password__c = encodedCipherText;
            }
            
            if(u.ProfileId != null){
            	profileIds.add(u.ProfileId);
            }
            System.debug('Licence::'+u.SF_License__c) ;
    	}
    	
    	if(profileIds.size() > 0){
    	updateLicenceCost(profileIds, Trigger.new);
    	}
    	
    }   
    else
    {
        for(User u: Trigger.new)
        {
            if(u.VCAN_Password__c!=null && Trigger.oldMap.get(u.Id).VCAN_Password__c!=u.VCAN_Password__c)
            {
                //Crypto using key and IV
                cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(u.VCAN_Password__c));
                encodedCipherText = EncodingUtil.base64Encode(cipherText); 
                u.VCAN_Password__c = encodedCipherText;
            }  
            
            if(u.ProfileId != null){
            	profileIds.add(u.ProfileId);
            }
            System.debug('Licence::'+u.SF_License__c) ; 
        }
        
        if(profileIds.size() > 0){
        updateLicenceCost(profileIds, Trigger.new);
        }
    }
    
    void updateLicenceCost(Set<String> profIds, List<User> usrList){
    	
    	decimal licCost = 0.0;
    	
    	Map<Id, Profile> profileMap = new Map<Id, Profile>([Select Id, Name, UserLicense.Name from Profile where Id IN : profIds]);
    	 
    	 if(!profileMap.isEmpty()){
	    	 for(User usr : usrList){
	    	 	licCost = 0.0;
	    	 	if(profileMap.containsKey(usr.ProfileId) && usr.IsActive){
	            if(usr.UserType == 'Standard' || usr.SF_License__c == 'Salesforce'){
	                licCost += 83.00;            
	            }else if((usr.UserType == 'PowerPartner' || profileMap.get(usr.ProfileId).UserLicense.Name == 'Gold Partner')
	                  && (!(profileMap.get(usr.ProfileId).Name.contains('Dealer') || profileMap.get(usr.ProfileId).Name.contains('Infiniti')))){
	                licCost += 9.22;  
	            }
	            
	            if(usr.UserPermissionsKnowledgeUser){
	                 licCost += 9.00; 
	            }
	            if(usr.UserPermissionsLiveAgentUser){
	                licCost += 20.00;
	            }
	            
	            usr.License_Cost_Per_Month__c = licCost;
	    	 	}	
	    	}
    	}
    }
}