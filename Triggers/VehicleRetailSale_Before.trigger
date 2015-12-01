/**********************************************************************
Name: VehicleRetailSale_Before 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This trigger is associated with the Vehicle_Retail_Sale__c object 
and calls the createVehicleOwnership method defined in the
VehicleRetailSaleClass class. This trigger runs before new Vehicle 
Retail Sale records are inserted into the database. It sets internal
salesforce ids on lookups from external ids passed in.

Related Apex Class: VehicleRetailSaleClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 03/21/2011 Added code to set internal Salesforce id lookups from external Ids
                                                     
***********************************************************************/
trigger VehicleRetailSale_Before on Vehicle_Retail_Sale__c (before insert,  before update) {
    
    // Set Salesforce Ids by looking up from external ids.
    Set<String> customerIds = new Set<String>();
    Set<String> vins = new Set<String>();
    Set<String> dealerExternalIds = new Set<String>();
    
    // Construct a Set of Customer_IDs from the Vehicle_Retail_Sales input through Trigger.new
    for (Vehicle_Retail_Sale__c sale : Trigger.new) {
        if (sale.External_Owner_ID__c != null)
            customerIds.add(sale.External_Owner_ID__c);
        if (sale.External_Vehicle_Identification_Number__c != null)
            vins.add(sale.External_Vehicle_Identification_Number__c);
        if (sale.External_Selling_Dealer_Name__c != null)
            dealerExternalIds.add(sale.External_Selling_Dealer_Name__c + System.label.Dealer_USA);
    }  

    List<Account> accList = new List<Account>([select id, Customer_ID__c
                                               from Account 
                                               where Customer_ID__c  in: customerIds]);
    
    List<Vehicle__c> vehicles = new List<Vehicle__c>([select id, Vehicle_Identification_Number__c 
                                                      from Vehicle__c
                                                      where Vehicle_Identification_Number__c in :vins]);
                                                      
    List<Account> dealers = new List<Account>([select id, Dealer_Code__c
                                               from Account
                                               where Dealer_External_Id__c in :dealerExternalIds]);

    // Loop through Vehicle_Retail_Sales in Trigger.new and set the Owner_Id__c, 
    // Vehicle_Identification_Number__c, Selling_Dealer_Name__c for each
    for (Vehicle_Retail_Sale__c sale : Trigger.new) {
        for(Account acc: accList){
            if(sale.External_Owner_ID__c == acc.Customer_ID__c )
                sale.Owner_Id__c = acc.Id;              
        }
        for(Vehicle__c vehicle : vehicles) {
            if(sale.External_Vehicle_Identification_Number__c == vehicle.Vehicle_Identification_Number__c)
                sale.Vehicle_Identification_Number__c = vehicle.id;
        }
        for(Account dealer : dealers) {
            if(sale.External_Selling_Dealer_Name__c == dealer.Dealer_Code__c)
                sale.Selling_Dealer_Name__c = dealer.id;
        }
    }
}