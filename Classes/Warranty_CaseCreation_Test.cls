/**********************************************************************
Name: Warranty_CaseCreation_Test 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Warranty_CaseCreation Controller.
 
======================================================
History:

VERSION    AUTHOR         DATE         DETAIL
1.0 -     Vivek Batham    04/01/2015  Created 
***********************************************************************/
@isTest
private class Warranty_CaseCreation_Test  {

     static testMethod void VehicleClaimClassTest()
    {
        
        Warranty_CaseCreation cc = new Warranty_CaseCreation();
        
        //Insert test records
        Case c1 = new Case();
        c1.RecordTypeId = cc.warrantyId;
        c1.Type = 'FULL';
        insert c1;
        
        c1 = [SELECT CaseNumber
              FROM Case
              WHERE Id = :c1.Id];
        
        Account dealer = new Account();
        dealer.RecordTypeId = '012A0000000OfI0';
        dealer.Name = 'Sebastian';
        dealer.Dealer_Code__c = '1234';
        insert dealer;
        
        Vehicle__c veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Altima';
        veh.Make_Name__c = 'Nissan';
        insert veh;
        
        // Search by an invalid caseNumber
        cc.paramCaseNumber = '1111';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search Dealer without the Code parameter
        cc.paramCaseNumber = null;
        cc.paramDealerCode = null;
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search by Unknow Dealer
        cc.paramDealerCode = 'XXXXX';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search by a valid Dealer
        cc.paramDealerCode = '1234';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        
        // Search by a valid Dealer and an invalid VIN
        cc.paramDealerCode = '1234';
        cc.paramVIN = 'ZZZ';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        System.assert(!cc.showVehicleSection);
        
        // Search with a valid Dealer and Vehicle
        cc.paramDealerCode = '1234';
        cc.paramVIN = 'JN8AZ1FY5CW100145';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        System.assert(cc.showVehicleSection);
        
        // Select a Dealer and create a new Case
        cc.selectedDealerId = dealer.Id;
        cc.selectDealer();
        
        // General Tests
        cc.clearParameters();
        cc.clearCaseInformation();
        cc.editSearch();
        cc.searchVCAN();
        cc.paramWOLine = '1234';
        cc.paramWorkOrderNumber = '1234';
        cc.paramVIN = '123456789101213';
        cc.paramDealerCode = '1234';
        cc.searchVCAN();
        cc.searchVCANS('1234','1234','1234','1234');
        
        cc.searchRelatedWarrantyCasesToTheReferenceNumber('n123456');
        cc.newCase();
        cc.newVCANCase();
    }
    
     static testMethod void DateTests()
    {    	 
        String sDate;
        Date myDate;
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);
        
        sDate = '10/23/14';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);         
        sDate = '9-9-14';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);
        sDate = '10.23.14';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);
        sDate = '10-23';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);
        
        sDate = '10/23/9';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);     
        
        sDate = '10/23/97';
        myDate = Warranty_CaseCreation.convertMMDDYYToDate(sDate);    
        
        
        
    }
    
      static testMethod void DealerSusClaimTest()
    {
        
        Warranty_CaseCreation cc = new Warranty_CaseCreation();
        
        //Insert test records
        Case c1 = new Case();
        c1.RecordTypeId = cc.warrantyId;
        c1.Type = 'FULL';
        insert c1;
        
        c1 = [SELECT CaseNumber
              FROM Case
              WHERE Id = :c1.Id];
        
        Account dealer = new Account();
        dealer.RecordTypeId = '012A0000000OfI0';
        dealer.Name = 'Sebastian';
        dealer.Dealer_Code__c = '1234';
        insert dealer;
        
        Vehicle__c veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Altima';
        veh.Make_Name__c = 'Nissan';
        insert veh;
        
        test.startTest();
        // Search by an invalid caseNumber
        cc.paramCaseNumber = '1111';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search Dealer without the Code parameter
        cc.paramCaseNumber = null;
        cc.paramDealerCode = null;
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search by Unknow Dealer
        cc.paramDealerCode = 'XXXXX';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
                
        // Select a Dealer and create a new Case
        cc.selectedDealerId = dealer.Id;
        cc.selectDealer();
        
        // General Tests
        cc.clearParameters();
        cc.clearCaseInformation();
        cc.editSearch();       
        cc.paramWOLine = '';
        cc.paramWorkOrderNumber = '0938';
        cc.paramVIN = 'VIN01000010000102';
        cc.paramDealerCode = '08648';        
        
        cc.refreshDealerInfo();
        List<Service_Repair_History__c> srhs = cc.lstDealerSusClaimsPage;
        System.debug('srhs:::'+srhs);
        System.assert(srhs.size() > 0);
        cc.Beginning();
        cc.Previous();
        cc.Next();
        cc.End();
        test.stopTest();
        
    }
    
    
}