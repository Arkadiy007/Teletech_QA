/**********************************************************************
Name: DTS_FI_Before_Helper
Copyright � notice: Nissan Motor Company.
======================================================
Purpose:
Created Chatter notification when owner changed
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Anna Koseikina 7/16/2015 Created
***********************************************************************/
public class DTS_FI_Helper { 
    public static void handleAfterUpdate(List<DTS_Field_Inspection__c> newValues, Map<Id, DTS_Field_Inspection__c> oldValues){
        List <Id > cases = new List <Id > ();
        List <ID > ownersIds= new List <ID > ();
        Set<Id> dtsUsers = new Set<ID> ();
        List <DTS_Field_Inspection__c > changedOwnerDts = new List <DTS_Field_Inspection__c > ();
        Map <Id, Case > dtsCases = new Map <Id, Case >();
        Map <Id, Case > caseMap = new Map <Id, Case > ();
        List <User > owners = new List<User>();

        for (DTS_Field_Inspection__c dts : newValues) {
            ownersIds.add(dts.ownerId);
            cases.add(dts.Related_Support_Case__c);
        }

        owners = [Select id, profile.Name from user where id in :ownersIds];
        for (user owner : owners) {
            if (owner.profile.Name.contains('DTS')) {
                dtsUsers.add(owner.ID);
            }
        }       
        
        if(dtsUsers.size() > 0){
            dtsCases = new Map <Id, Case >([select id, CaseNumber from case where id in :cases]);
        
            for (DTS_Field_Inspection__c dts : newValues) {         
                DTS_Field_Inspection__c old = oldValues.get(dts.ID);
                if(!Test.isRunningTest()){
                    if (old.OwnerId != dts.OwnerId && dtsUsers.contains(dts.ownerID)) {
                        changedOwnerDts.add(dts);
                        caseMap.put(dts.Related_Support_Case__c, dtsCases.get(dts.Related_Support_Case__c));
                    }
                }
            }

            if(changedOwnerDts.size() > 0 && caseMap.size() > 0){
                CaseClass.doChatterPost(changedOwnerDts, caseMap);
            }
        }
    }
    
    
    public static void handleBeforeInsert(List<DTS_Field_Inspection__c> newValues){
    	Map<String,HK_Threat_Level_Settings__c> hkThreatMap = HK_Threat_Level_Settings__c.getAll();
    	
    	for(DTS_Field_Inspection__c dtsInsp : newValues){
    		System.debug('dtsInsp.Vehicle_Findings__c:::'+dtsInsp.Vehicle_Findings__c);
    		if(dtsInsp.Vehicle_Findings__c == null || dtsInsp.Vehicle_Findings__c == ''){
    			dtsInsp.Vehicle_Findings__c = '1.Complaint\n<ul><li>Cause</li><li>Correction</li><li>Status</li></ul>';
    		}
    		
    		if(dtsInsp.Request_Type__c != null && hkThreatMap.get(dtsInsp.Request_Type__c) != null){   
     			if(dtsInsp.HK_Request_Type__c == null) { 			
     			dtsInsp.HK_Request_Type__c  = hkThreatMap.get(dtsInsp.Request_Type__c).HK_Request_Type__c;
     			}
     			if(dtsInsp.Threat_Level__c == null){
     			dtsInsp.Threat_Level__c = hkThreatMap.get(dtsInsp.Request_Type__c).Threat_Level__c;
     			}
     		}
    	}
    }
    
    public static void handleBeforeUpdate(List<DTS_Field_Inspection__c> newValues){
    	Map<String,HK_Threat_Level_Settings__c> hkThreatMap = HK_Threat_Level_Settings__c.getAll();
    	
     	for(DTS_Field_Inspection__c dtsInsp : newValues){
     		if(dtsInsp.Request_Type__c != null && hkThreatMap.get(dtsInsp.Request_Type__c) != null){   
     			if(dtsInsp.HK_Request_Type__c == null) { 			
     			dtsInsp.HK_Request_Type__c  = hkThreatMap.get(dtsInsp.Request_Type__c).HK_Request_Type__c;
     			}
     			if(dtsInsp.Threat_Level__c == null){
     			dtsInsp.Threat_Level__c = hkThreatMap.get(dtsInsp.Request_Type__c).Threat_Level__c;
     			}
     		}
     	}
     	
    }
}