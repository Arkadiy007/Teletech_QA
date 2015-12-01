/*
  Page Title: NCI_CustomerWebServiceTest
  Author: Aaron Bessey
  Create Date: 3/15/2015
  Last Update: 3/15/2015
  Updated By: Aaron Bessey

  Revisions:
  AAB - Initial Creation
*/

@isTest
public class NCI_CustomerWebServiceTest
{
    private static String customerNumber = '15060859';

    private static testmethod void RedirectToAccount_ShouldUpdateAccountIfItPresent1() {
        NCI_CustomerWebService service = new NCI_CustomerWebService(null);
       Account acc = CreateNewCusomerAccount2();
        service.selectedAccCustomerId = customerNumber;
 NCIWebServiceSettings__c wss = new  NCIWebServiceSettings__c();
 wss.TimeoutSeconds__c = 5;
 insert wss;
       // service.RedirectToAccount();

        Account updatedAccount = [Select Id, firstName, lastName From Account WHERE Customer_ID__c = :customerNumber];
        
        Map<String,String> mp = new Map<String,String>();
        mp.put('firstname','VIG');
        mp.put('phone','5555555555');
        
        NCI_CustomerWebService.getCustomerList(mp);

        system.assertequals('ALEGRIA', updatedAccount.firstName);
        system.assertequals('JIMENEZ', updatedAccount.lastName);
    }

    private static testmethod void RedirectToAccount_ShouldInsertAccountIfItsNotPresent2() {
        Account acc = CreateNewCusomerAccount();
        acc.Customer_ID__c = '15060859';
        update acc;

        NCI_CustomerWebService service = new NCI_CustomerWebService(null);
        service.selectedAccId = acc.Id;
        service.selectedAccCustomerId = null;

        List<Account> updatedAccount = [Select Id, firstName, lastName From Account WHERE Id = :acc.id];

        system.assertequals(1, updatedAccount.size());
       // system.assertequals('ALEGRIA', updatedAccount.get(0).firstName);
       // system.assertequals('JIMENEZ', updatedAccount.get(0).lastName);
    }

    private static testmethod void RedirectToAccount_ShouldUpsertVehicleOwnershipHistory(){
        Account acc = CreateNewCusomerAccount();

        acc.Customer_ID__c = '5468479';
        update acc;

        Vehicle__c vec = CreateNewVehicle();

        Vehicle_Ownership_History__c vh = new Vehicle_Ownership_History__c(
            Vehicle__c = vec.id,
            Owner__c = acc.id
            );
        insert vh;

        NCI_CustomerWebService service = new NCI_CustomerWebService(null);
        service.selectedAccId = acc.id;
        service.selectedAccCustomerId = acc.Customer_ID__c ;

       // service.RedirectToAccount();

        List<Vehicle_Ownership_History__c> voh = [select Id, VIN__c, Begin_Date__c,
                                                End_Date__c, Current_Owner_Indicator__c,
                                                Primary_Owner_Indicator__c,
                                                Vehicle__c,
                                                Vehicle__r.Model_Year__c,
                                                Vehicle__r.Make_Name__c,
                                                Vehicle__r.Model_Line_Name__c,
                                                Vehicle__r.Vehicle_identification_Number__c
                                                from Vehicle_Ownership_History__c
                                                where Owner__c=:acc.id
                                               ];

        System.assert(!voh.isEmpty());
                                  
    }

    private static Vehicle__c CreateNewVehicle(){
        RecordType vecRecordType = [select id from RecordType where SobjectType = 'Vehicle__c' limit 1];

        Vehicle__c vec = new Vehicle__c();
        vec.Recordtypeid = vecRecordType.Id;
        vec.Vehicle_identification_Number__c = '67412312343256712';
        vec.Model_Year__c = '2015';

        insert vec;

        return vec;

    }


 private static Account CreateNewCusomerAccount2() {
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];

        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.firstName = 'ALEGRIA';
        account.lastName = 'JIMENEZ';
        account.Customer_Id__c = customerNumber;

        insert account;

        return account;
    }
    private static Account CreateNewCusomerAccount() {
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];

        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.firstName = 'Test1';
        account.lastName = 'test2';
        account.Customer_Id__c = customerNumber;

        insert account;

        return account;
    }
}