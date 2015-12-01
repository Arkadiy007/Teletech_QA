@isTest
public class NotificationsHelperTest {
    
    @isTest
    static void onFieldUpdateOnSortingReport_NotificationShouldBeCreated(){
        Part__c part = sObjectFactory.createPart();
        insert part;
        
        Sorting_Report__c sr = sObjectFactory.createSR(part);
        insert sr;      
            
        Test.startTest();
            sr.Certified_NEC_RAN__c = 'Accept';
            update sr;

            System.assert([SELECT Count() FROM EQANotification__c WHERE Object_Name__c = 'Sorting Report'] > 0);
            
            Boolean descriptionFound = false;
            for (EQANotification__c notification : [SELECT Description__c FROM EQANotification__c WHERE Object_Name__c = 'Sorting Report']){
                if (notification.Description__c.contains('Certified NEC RAN')){
                    descriptionFound = true;
                }
            }
            
            System.assert(descriptionFound);
        Test.stopTest();    
    }

    @isTest
    static void onFieldUpdateOnPartIncidentReport_NotificationShouldBeCreated(){
        Part__c part = sObjectFactory.createPart();
        insert part;
        
        Part_Incident_Report__c pir = sObjectFactory.createPIR('PIR-CC23', part);
        insert pir;

        Test.startTest();
            pir.Last_Suspect_RAN__c = true;
            update pir;

            System.assert([SELECT Count() FROM EQANotification__c WHERE Object_Name__c = 'Part Incident Report'] > 0);
            
            Boolean descriptionFound = false;
            for (EQANotification__c notification : [SELECT Description__c FROM EQANotification__c WHERE Object_Name__c = 'Part Incident Report']){
                if (notification.Description__c.contains('Last Suspect RAN')){
                    descriptionFound = true;
                }
            }
            
            System.assert(descriptionFound);
        Test.stopTest();    
    }

    @isTest
    static void onFieldUpdateOnMonetaryClaim_NotificationShouldBeCreated(){
        Part__c part = sObjectFactory.createPart();
        insert part;
        
        Monetary_Claim__c mc = sObjectFactory.createMC(null, null);
        insert mc;

        Test.startTest();
            mc.Account_Coding__c = 'Test2';
            update mc;

             System.assert([SELECT Count() FROM EQANotification__c WHERE Object_Name__c = 'Monetary Claim'] > 0);
            
        Test.stopTest();    
    }

}