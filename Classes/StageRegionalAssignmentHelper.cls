public class StageRegionalAssignmentHelper{

    public static void handleBeforeInsert(List<Stage_Regional_Assignment__c> regAssignments){
        
       // Map<String, Dealer_Regional_Assignment__c> mapAGMAreaAssignment = Dealer_Regional_Assignment__c.getAll();
            
        for(Stage_Regional_Assignment__c stg : regAssignments){  
            if(stg.District_Code__c == '' || stg.District_Code__c == null){
                stg.Region_External_Id__c = stg.Position__c + stg.Region_Code__c;
            }else{      
            stg.Region_External_Id__c = stg.Position__c + stg.Region_Code__c + stg.District_Code__c;
            }
              
           /* if(mapAGMAreaAssignment != null){
                for(Dealer_Regional_Assignment__c deaReg : mapAGMAreaAssignment.values()){
                    String[] codes = deaReg.Region_District_Codes__c != null ? deaReg.Region_District_Codes__c.split(',') : new String[]{''};
                    for(String s : codes){
                       if(s == stg.Region_Code__c + stg.District_Code__c){
                           stg.Area__c = deaReg.Name;
                           break;
                       } 
                    }                    
                }
            }*/           
        }
    }
    
    public static void handleBeforeUpdate(List<Stage_Regional_Assignment__c> regAssignments){
        
    }
    
    
    public static void handleAfterInsert(List<Stage_Regional_Assignment__c> regAssignments){
        List<String> regCodes = new List<String>();
        List<String> distCodes = new List<String>();
        String uniquekey;
        String[] codes;
        String[] regDistrictCodes;
        Map<String, Dealer_Regional_Assignment__c> mapAGMAreaAssignment = Dealer_Regional_Assignment__c.getAll();
        Map<String, List<Stage_Regional_Assignment__c>> mapStgRegionalAssignments = new Map<String, List<Stage_Regional_Assignment__c>>();
        
          for(Stage_Regional_Assignment__c stg : regAssignments){        
           
           
            
            if(stg.Position__c == 'AGM' || stg.Position__c == 'DMC'){
            	if(mapAGMAreaAssignment != null && mapAGMAreaAssignment.get(stg.Region_Code__c) != null){
            		codes = mapAGMAreaAssignment.get(stg.Region_Code__c).Region_District_Codes__c != null ? mapAGMAreaAssignment.get(stg.Region_Code__c).Region_District_Codes__c.split(',') : new String[]{''};
            		for(String regCode : codes){
            			if(regCode.contains('-')){
            				regDistrictCodes = regCode.split('-');
            				uniquekey= regDistrictCodes[0] + regDistrictCodes[1];
            				regCodes.add(regDistrictCodes[0]);
            				distCodes.add(stg.District_Code__c);
            			}else{
            				uniquekey= regDistrictCodes[0];
            				regCodes.add(regDistrictCodes[0]);
            			}
            			
            			 if(mapStgRegionalAssignments != null && mapStgRegionalAssignments.get(uniquekey) != null){
				                mapStgRegionalAssignments.get(uniquekey).add(stg);                
				          }else{                                
				                mapStgRegionalAssignments.put(uniquekey, new List<Stage_Regional_Assignment__c>{stg});
				          }
            		}
            	}
            }else{
            	 distCodes.add(stg.District_Code__c);
          		 regCodes.add(stg.Region_Code__c);
	            if(stg.District_Code__c == null || stg.District_Code__c == ''){
	                uniquekey= stg.Region_Code__c;
	            }else{
	            uniquekey= stg.Region_Code__c+stg.District_Code__c;
	            }
	            
	            if(mapStgRegionalAssignments != null && mapStgRegionalAssignments.get(uniquekey) != null){
	                mapStgRegionalAssignments.get(uniquekey).add(stg);                
	            }else{                                
	                mapStgRegionalAssignments.put(uniquekey, new List<Stage_Regional_Assignment__c>{stg});
	            }
            }
           
        }
        
        loadUserAssignments(regCodes, distCodes, mapStgRegionalAssignments);
    
    }
    
    public static void handleAfterDelete(Map<Id, Stage_Regional_Assignment__c> regAssignmentsMap){
        
        System.debug('regAssignmentsMap::'+regAssignmentsMap);
       
        List<User_Assignment__c> usrAssignToDelete = [Select Id from User_Assignment__c where Regional_Assigned_User__c IN : regAssignmentsMap.keyset()];
                 
        if(!usrAssignToDelete.isEmpty()){
            Database.delete(usrAssignToDelete, false);
        }
        
        
    }
    

    public static void loadUserAssignments(List<String> rCodes, List<String> dCodes, Map<String, List<Stage_Regional_Assignment__c>> regAssignMap){
        
        Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id dealerRTId = rtInfosByName.get('Dealer').getRecordTypeId();
        List<User_Assignment__c> assignmentsToCreate = new List<User_Assignment__c>();
        String uniquekey;
        
        System.debug('regAssignMap::'+regAssignMap);
        
        for(Account acc : [Select Id, Region_Code__c, District_Code__c from Account where RecordtypeId =: dealerRTId
                           AND Dealer_Inactive_Indicator__c = false AND (Region_Code__c IN : rCodes OR District_Code__c IN: dCodes) LIMIT 5000]){
            
            if(regAssignMap != null){
               
                uniquekey = acc.Region_Code__c;
                if(regAssignMap.get(uniquekey) != null){               
                     for(Stage_Regional_Assignment__c stgAssign : regAssignMap.get(uniquekey)){
                          assignmentsToCreate.add(new User_Assignment__c(Dealer__c = acc.Id, Regional_Assigned_User__c = stgAssign.Id,
                                                      Employee_Role__c = stgAssign.Position__c));
                     } 
                }
              
                uniquekey = acc.Region_Code__c + acc.District_Code__c;
                if(regAssignMap.get(uniquekey) != null){               
                     for(Stage_Regional_Assignment__c stgAssign : regAssignMap.get(uniquekey)){
                          assignmentsToCreate.add(new User_Assignment__c(Dealer__c = acc.Id, Regional_Assigned_User__c = stgAssign.Id,
                                                      Employee_Role__c = stgAssign.Position__c));
                     } 
                }
                
                System.debug('regAssignMap uniquekey::'+regAssignMap);
                
           }               
        } 
        
        if(!assignmentsToCreate.isEmpty()){
            Database.insert(assignmentsToCreate, true);
        }                  
    }
    
    
}