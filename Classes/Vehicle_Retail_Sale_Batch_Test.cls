/**********************************************************************
Name: Vehicle_Retail_Sale_Batch_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Vehicle_Retail_Sale_Batch Trigger.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 03/17/2011 Created 
***********************************************************************/
@isTest
private class Vehicle_Retail_Sale_Batch_Test {
    
    static testmethod void test() {
        String dealerType = System.Label.AccRTDealer;
        String personType = System.Label.AccRTMaritz;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        
        Account prefferedAccount = new Account();
        prefferedAccount.name = 'Test';
        prefferedAccount.RecordTypeId = dealerTypeRT.Id;
        prefferedAccount.Dealer_Code__c = '123%^';
        insert prefferedAccount; 
        
        Account account = new Account();
        account.LastName = 'Test';
        account.Customer_ID__c = '1234%$';
        account.RecordTypeId = personTypeRT.Id;
        
        account.Preferred_Dealer_Id__c = prefferedAccount.id;
        insert account;
        
        Vehicle__c v = new Vehicle__c(Name = 'test');
        v.Vehicle_identification_Number__c = '123%^';
        insert v;
        
        Vehicle_Retail_Sale__c rec = new Vehicle_Retail_Sale__c();
        rec.External_Owner_Id__c = '1234%$';
        rec.External_Selling_Dealer_Name__c = '123%^';
        rec.External_Vehicle_Identification_Number__c = '123%^';
        
        Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data> dataMap = new Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data>();
		Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data data = new Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data();
		data.ownerId = account.id;
		data.dealerName = prefferedAccount.Id;
		data.VIN = v.id;
		insert rec;
		dataMap.put(rec.id, data);
		

        Test.startTest();
        
        String query = 'Select id from Vehicle_Retail_Sale__c where id =\'' + rec.id +'\'';
        database.executeBatch(new Vehicle_Retail_Sale_Batch(query, dataMap), 1);
        Test.StopTest();
        
    }
}