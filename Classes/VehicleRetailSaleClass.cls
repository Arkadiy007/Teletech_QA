/**********************************************************************
Name: VehicleRetailSaleClass
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This class inserts the Vehicle_Ownership_History__c records that are
passed to it. 

Related Apex Trigger: VehicleRetailSale_After 
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Biswa Ray 01/13/2011 Created
1.1 - Bryan Fry 01/13/2011 Initialized vOHistory to null
1.2 - Biswa Ray 01/18/2011 Functionality Changed (As per JIRA Issue RONETELETECH-91)
1.3 - Biswa Ray 02/22/2011 Updated the code to avoid governor limit as per JIRA Issue - RONETELETECH-131
1.4 - Bryan Fry 03/07/2011 Changed static variable to instance variable and set to null on method entry
1.5 - Bryan Fry 03/10/2011 Removed code to set name of Vehicle_Ownership_History after changed to AutoNumber
***********************************************************************/

public class VehicleRetailSaleClass {
          
    /*
        Whenever a new Vehicle Retail Sale is created,One Vehicle_Ownership_History__c record
        will be inserted in to the database automatically .
    */ 
    public static Vehicle_Ownership_History__c createVehicleOwnership (Vehicle_Retail_Sale__c newVehicleRetailSale,Account account) {
        ID newVehicleRetailOwner = newVehicleRetailSale.Owner_Id__c;
        ID vehicleRetailSaleId = newVehicleRetailSale.id;
        ID vehicleId = newVehicleRetailSale.Vehicle_Identification_Number__c;
        Vehicle_Ownership_History__c vOHistory = null;
               
        if (vehicleId != null && vehicleRetailSaleId != null && account!= Null){
	        vOHistory = new Vehicle_Ownership_History__c(Vehicle_Retail_Sale_Id__c = vehicleRetailSaleId,
                                                         Owner__c = newVehicleRetailOwner, Vehicle__c = vehicleId);
        }
        return vOHistory;
     }
}