@isTest
private class Merger_Test {

  	static testMethod void testMerge() {
        String personType = System.Label.AccRTMaritz;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

	    List<Account> accountList = new List<Account> {new Account(RecordTypeID = personTypeRT.ID, FirstName = 'First', LastName = 'Last', PersonMailingState = 'CO', Customer_ID__c = '%%%%%%'),
	    											new Account(RecordTypeID = personTypeRT.ID, FirstName = 'First', LastName = 'Last', PersonMailingState = 'CO', Customer_ID__c = '$$$$$$')};
	    //([select id, Customer_ID__c FROM Account WHERE Customer_ID__c != null limit 2]); 
	    insert accountList;
	    set<ID> accountIDs = new set<ID>(); 
	    accountIDs.add(accountList[0].id);
	    accountIDs.add(accountList[1].id);
	  	
	    MergeRelationships__c mr = new MergeRelationships__c(childID__c = accountList[0].Customer_ID__c, survivorID__c = accountList[1].Customer_ID__c); 
	    insert mr; 
	    
	    List<Account> testList = new List<Account>();
	    try{
	    	testList = [select id FROM Account where id in:accountIDs];  
	    }
	    catch(Exception e){
	    }
	   	// system.assert(testList.size() == 0);
  	}

}