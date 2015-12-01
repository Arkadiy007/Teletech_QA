/*
  Page Title: NCI_VehicleServiceContractWebServiceTest
  Author: Aaron Bessey
  Create Date: 3/25/2015
  Last Update: 3/25/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/ 
@isTest
public class NCI_VehicleServiceContractWebServiceTest
{
    private static testmethod void initialize_ShouldInsertVehicleSC_onloading() {
        ApexPages.StandardController sc = new ApexPages.StandardController(CreateNewVehicle());
        NCI_VehicleServiceContractWebService vehicleWebSvc = new NCI_VehicleServiceContractWebService(sc);
        NCIWebServiceSettings__c ws = new NCIWebServiceSettings__c();
        ws.TimeoutSeconds__c=5;
        insert ws;
        
        
        vehicleWebSvc.initialize(); // inserts two vsc
        
        List<Vehicle_Service_Contract__c> vehs = [SELECT Id, Odometer__c, Dealer__c FROM Vehicle_Service_Contract__c];
        //System.debug(vehs);
        //System.assertEquals(2, vehs.size());
        //System.assertEquals('20000', vehs[0].Odometer__c);
       // System.assertEquals(null, vehs[1].Dealer__c);

    }

    private static testmethod void initialize_ShouldUpdateVSC_onLoading(){
        ApexPages.StandardController sc = new ApexPages.StandardController(CreateNewVehicle());
        NCI_VehicleServiceContractWebService vehicleWebSvc = new NCI_VehicleServiceContractWebService(sc);
        InsertVSC();

        vehicleWebSvc.initialize(); // updates one of vsc;

       // List<Vehicle_Service_Contract__c> vscs = [SELECT Id, Action_Code__c FROM Vehicle_Service_Contract__c WHERE vin__c = '1Nb432s']; 

       // System.assertEquals(1, vscs.size());
     //   System.assertEquals('P', vscs[0].Action_Code__c); // instead of 'X'
    }

    private static Vehicle__c CreateNewVehicle(){
        RecordType vecRecordType = [select id from RecordType where SobjectType = 'Vehicle__c' limit 1];

        Vehicle__c vec = new Vehicle__c();
        vec.Recordtypeid = vecRecordType.Id;
        vec.Vehicle_identification_Number__c = '1Nb432s';
        vec.Name = '1Nb432s';
        vec.Model_Year__c = '2015';

        insert vec;
        return vec;

    }

    private static Vehicle_Service_Contract__c InsertVSC(){
        Vehicle_Service_Contract__c vsc = new Vehicle_Service_Contract__c();

        vsc.vin__c = '1Nb432s';
        vsc.Policy_Number__c = 'PLNL90260357';
        vsc.Action_Code__c = 'X';

        insert vsc;
        return vsc;
    }



}