/*
  Page Title: NCI_VehicleWebServiceTest
  Author: Aaron Bessey
  Create Date: 3/23/2015
  Last Update: 3/23/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

@isTest
public class NCI_VehicleWebServiceTest
{
    private static testmethod void initialize_Shouldupdatevehicle_onloading() {
        ApexPages.StandardController sc = new ApexPages.StandardController(CreateNewVehicle());
        NCIWebServiceSettings__c ws = new NCIWebServiceSettings__c();
        ws.TimeoutSeconds__c=5;
        insert ws;
        
        NCI_VehicleWebService vehicleWebSvc = new NCI_VehicleWebService(sc);
        vehicleWebSvc.initialize(); // updates

        List<Vehicle__c> vehs = [SELECT Id, Model_Year__c FROM Vehicle__c];
        System.assertEquals(1, vehs.size());
        System.assertEquals('2008', vehs[0].Model_Year__c);

    }

    private static Vehicle__c CreateNewVehicle(){
        RecordType vecRecordType = [select id from RecordType where SobjectType = 'Vehicle__c' limit 1];

        Vehicle__c vec = new Vehicle__c();
        vec.Recordtypeid = vecRecordType.Id;
        vec.Vehicle_identification_Number__c = '67412212343256712';
        vec.Model_Year__c = '2015';

        insert vec;

        return vec;

    }

    private static Account CreateNewCusomerAccount() {
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];

        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.firstName = 'Test1';
        account.lastName = 'test2';

        insert account;

        return account;
    }


}