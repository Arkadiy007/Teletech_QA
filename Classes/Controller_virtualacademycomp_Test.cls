/**********************************************************************
Name: Controller_virtualacademycomp_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test Class for Controller_virtualacademycomp Class, used
for virtualacademycomp VF page.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/27/2014 Created
***********************************************************************/
@isTest
public class Controller_virtualacademycomp_Test{
    public static testMethod void test1(){
    PageReference pageRef = Page.virtualacademycomp;
    Test.setCurrentPageReference(pageRef);
        
        TechlineVirtualAcademy__c tva = new TechlineVirtualAcademy__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            Dealer_Code__c = '1234',
            SFDC_External_Id__c = 'x1234',
            Technician_Proficiency_Level__c = 'Nissan SCOPE Master Technician');
        
        insert tva;
        
        Specialty__c s = new Specialty__c(
            Specialty__c = 'GT-R Specialist',
            SFDC_Dealer_External_ID__c = 'x1234',
            Technician__c = tva.id);
        
        insert s;
        
        TechlineVirtualAcademy__c tva2 = new TechlineVirtualAcademy__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            Dealer_Code__c = '2345',
            SFDC_External_Id__c = 'x2345');
        
        insert tva2;
        
        Specialty__c s2 = new Specialty__c(
            Specialty__c = 'GT-R Specialist',
            SFDC_Dealer_External_ID__c = 'x1234',
            Technician__c = tva2.id);
        
        insert s2;
        
        
         Controller_virtualacademycomp cont = new Controller_virtualacademycomp();
        
        cont.dealercode='1234';
        cont.techrecord();
        cont.clear();
        
        Controller_virtualacademycomp cont2 = new Controller_virtualacademycomp();
        
        cont2.dealercode='1234';
        cont2.lastname = 'Smith';
        cont2.techrecord();
        cont2.clear();
        
        Controller_virtualacademycomp cont3 = new Controller_virtualacademycomp();
        
        cont3.techrecord();
        cont3.clear();
        
        Controller_virtualacademycomp cont4 = new Controller_virtualacademycomp();
        
        cont4.dealercode='5678';
        cont4.techrecord();
        cont4.clear();
        
        Controller_virtualacademycomp cont5 = new Controller_virtualacademycomp();
        
        cont5.dealercode='2345';
        cont5.techrecord();
        cont5.clear();
        
        
    }
            
    
}