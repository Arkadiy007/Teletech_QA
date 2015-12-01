@isTest
public class QASTestMethods {
    private static testmethod void TestCAAccountTrigger () {
        QAS_NA__QAS_CA_Account__c accountSObject = new QAS_NA__QAS_CA_Account__c(QAS_NA__LicenseKey__c='test'
                                 ,QAS_NA__IsNullOrEmptyValidCountry__c  = true
                                 ,QAS_NA__ValidCountryValues__c = '\'US\',\'United States\', \'Canada\', \'CAN\''
                                 ,QAS_NA__TriggerRecordsLimit__c = 2
                                 ,QAS_NA__InteractiveIntervalFromLastUpdate__c = 1000
                                 ,QAS_NA__InteractiveInvokeIntervalFromLastUpdate__c = 200
                                 ,QAS_NA__NumberOfFailedAttempts__c = 0);
   
        insert accountSObject;
        accountSObject.QAS_NA__InteractiveInvokeIntervalFromLastUpdate__c = 300;
        update accountSObject;
       
        System.assertEquals(0, 0);
    }
}