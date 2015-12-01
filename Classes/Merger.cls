public with sharing class Merger {

public static void MergeRecords(Set<ID> ids){
	
	System.debug('ids: '  + ids);
	List<MergeRelationships__c> mergeTable = new List<MergeRelationships__c>(); 
	mergeTable = [select id, childID__c,survivorID__c FROM MergeRelationships__c WHERE id in:ids];
	System.debug('mergeTable: ' + mergeTable);
	Map<String,String> childIDSurvivorIDMap = new Map<String,String>();
	Map<String,String> survivorIDChildIDMap = new Map<String,String>();
	Set<String> childIds = new Set<String>();
	Set<String> survivorIds = new Set<String>();
	// create maps for childID-->survivorID and survivorID-->childID
	for(MergeRelationships__c mrecord: mergeTable){
		System.debug('mrecord.childID__c'  + mrecord.childID__c + ' mrecord.survivorID__c: ' + mrecord.survivorID__c);
		childIds.add(mrecord.childID__c);
		survivorIds.add(mrecord.survivorID__c);
		childIDSurvivorIDMap.put(mrecord.childID__c, mrecord.survivorID__c);
		survivorIDChildIDMap.put(mrecord.survivorID__c, mrecord.childID__c);		
	}
	system.debug('childIDsurvivorIDMap: '  + childIDSurvivorIDMap);
	Schema.DescribeSObjectResult accountresult = Account.sObjectType.getDescribe();
	Map<String, Schema.SObjectField> field_map = accountresult.fields.getMap();
	List<Account> survivorAccounts = new List<Account>();
	List<Account> childAccounts = new List<Account>();
	//create soql column list
	String sofields;
	Integer i = 0;	
	for(Schema.SObjectField ssField : field_map.values()) {
	  Schema.DescribeFieldResult result = ssField.getDescribe();
	  if(result.isUpdateable() && String.valueOf(ssField) != 'Name' && String.valueOf(ssField) != 'IsPartner'){	  	
	      if(i<1){
	        sofields =  String.valueOf(ssField);	        
	      }
	      else{
	        sofields = sofields + ',' + String.valueOf(ssField);  
	      }
	        i++; 
	      }
	}    
    //soql statements for survivor and child Accounts
   	String soqlSurvivor = 'select ' + sofields + '  FROM Account WHERE Customer_ID__c in: survivorIds'; 
	String soqlChild = 'select ' + sofields + ' 	FROM Account WHERE Customer_ID__c in: childIds';
	
	system.debug(soqlSurvivor + ':  soqlSurvivor');
	survivorAccounts = Database.query(soqlSurvivor);
	childAccounts = Database.query(soqlChild);
	//creates map for childID-->survivor
	Map<String, Account> childSurvivorMap = new Map<String, Account>();
	for(Account survivor: survivorAccounts){
		childSurvivorMap.put(survivorIDChildIDMap.get(survivor.Customer_ID__c), survivor);	
	}
	
	List<Account> updateList = new List<Account>();
	//creates map for survivorID-->child
	Map<String, Account> survivorChildMap = new Map<String, Account>();
	for(Account child: childAccounts){
		system.debug('child.id' + child.Customer_ID__c ); 
		system.debug('childIDSurvivorIDMap.get(child.Customer_ID__c )' + childIDSurvivorIDMap.get(child.Customer_ID__c ));
		survivorChildMap.put(childIDSurvivorIDMap.get(child.Customer_ID__c), child);	
		//if child Account exists but not the survivor Account, then update childID with survivorID
		if(!childSurvivorMap.containsKey(child.Customer_ID__c))
		{
			Account updChAcct = survivorChildMap.get(childIDSurvivorIDMap.get(child.Customer_ID__c));
			updChAcct.Customer_ID__c = childIDSurvivorIDMap.get(child.Customer_ID__c);	
			//add child account changes to list of updates
			updateList.add(updChAcct);	
		}
	}
	system.debug('survivorChildMap ' + survivorChildMap);
	//loop through survivor accounts
	Map<Id, Account> mergeMap = new Map<id,account>();
	for(Account sa: survivorAccounts){
		Account ca = survivorChildMap.get(sa.Customer_ID__c);
		System.debug('ca: ' +  ca);
		if (ca != null)  //if child account does not exist, skip
		{
				for(Schema.SObjectField ssField : field_map.values()){
					
					Schema.DescribeFieldResult result = ssField.getDescribe();
					if(result.isUpdateable() && String.valueOf(ssField) != 'Name' && String.valueOf(ssField) != 'IsPartner'){
						//update null fields of survivor account with values from child account 
						if(ca.get(String.valueOf(ssField)) !=null && sa.get(String.valueOf(ssField)) ==null){
								
								sa.put(String.valueOf(ssField),ca.get(String.valueOf(ssField)));
							
						}
					}
				}      
           //creates map for survivorID-->child for merge data
			mergeMap.put(sa.id, ca);		
		//add survivor account changes to list of updates
	   	updateList.add(sa);
	
		} //end if
    } //end for sa
    
    //update account object
	update updateList;
	//loop thru survivor accounts and merge data(keep survivor account and delete child account)
	for(Account sa: survivorAccounts){
		if(mergeMap.containsKey(sa.id))
		{
			merge sa mergeMap.get(sa.id);
		}		
	}
		
}

}