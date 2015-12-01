/**********************************************************************
Name: ModelOfInterest_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a new Model_Of_Interest is created, fill in
Salesforce internal Ids by looking them up from
external ids provided.
 
Related Class : ModelOfInterestClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 08/04/2011 Created
***********************************************************************/
trigger ModelOfInterest_Before on Model_Of_Interest__c (before insert, before update) {
    Set<String> customerIds = new Set<String>();
    
    // Construct a Set of Customer_IDs from the Models Of Interest input through Trigger.new
    for (Model_Of_Interest__c model : Trigger.new) {
        if (model.Customer_ID__c != null)
            customerIds.add(model.Customer_ID__c);
    }  

    List<Account> accList = new List<Account>([select id, Customer_ID__c
                                               from Account 
                                               where Customer_ID__c  in: customerIds]);
    
    Map<String,Id> customerIdMap = new Map<String,Id>();
    for (Account acct : accList) {
        customerIdMap.put(acct.Customer_ID__c, acct.Id);
    }
    
    // Loop through Models of Interest in Trigger.new and set the Account__c for each
    for (Model_Of_Interest__c model : Trigger.new) {
    	model.Account__c = customerIdMap.get(model.Customer_Id__c);
    }
}