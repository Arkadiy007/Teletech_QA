/**********************************************************************
Name: Specialty_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test Class for Speciaty_Before Trigger on Specialty__c
Object.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/26/2014 Created
***********************************************************************/
@isTest
public class Specialty_Before_Test{
    static testMethod void Speciaty_Before_Test1() {
     
        test.startTest();
        TechlineVirtualAcademy__c tva = new TechlineVirtualAcademy__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            SFDC_External_Id__c = 'x1234');
        
        insert tva;
        
        Specialty__c s = new Specialty__c(
            Specialty__c = 'GTR Specialist',
            SFDC_Dealer_External_ID__c = 'x1234');
        
        insert s;
        test.stopTest();
            
        TechlineVirtualAcademy__c tvacheck = [select id from TechlineVirtualAcademy__c where id = :tva.id];
        Specialty__c scheck = [select Id, Technician__c from Specialty__c where id = :s.Id];
        system.assert(scheck.Technician__c == tvacheck.Id);
        
     }
    

static testMethod void Speciaty_Before_Test2() {
     
        test.startTest();
        TechlineVirtualAcademy__c tva = new TechlineVirtualAcademy__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            SFDC_External_Id__c = 'x1234');
        
        insert tva;
        
        Specialty__c s = new Specialty__c(
            Specialty__c = 'GTR Specialist',
            Technician__c = tva.Id);
        
        insert s;
        test.stopTest();
            
        TechlineVirtualAcademy__c tvacheck = [select id from TechlineVirtualAcademy__c where id = :tva.id];
        Specialty__c scheck = [select Id, Technician__c from Specialty__c where id = :s.Id];
        system.assert(scheck.Technician__c == tvacheck.Id);
        
     }
    
    static testMethod void Speciaty_Before_Test3() {
     
        test.startTest();
        TechlineVirtualAcademy__c tva = new TechlineVirtualAcademy__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            SFDC_External_Id__c = 'x1234');
        
        insert tva;
        
        Specialty__c s = new Specialty__c(
            Specialty__c = 'GTR Specialist');
        
        insert s;
        test.stopTest();
        
        Specialty__c scheck = [select Id, Technician__c from Specialty__c where id = :s.Id];
        system.assert(scheck.Technician__c == null);
        
     }

}