/**
 * This class contains unit tests for VCANComponent
 * Author: Aaron Bessey
 * Date 9/12/2014
 */
@isTest
private class Test_VCANComponent {
    
    public static Warranty_Case__c queryWarrantyCase (Id caseId)
    {
        return [select ID, Name, Dealer__c, Dealer_Code__c, Vehicle__c, Vehicle__r.Name, Repair_Work_Order__c, 
                Job_Line_Number__c, Customer_Concern__c,
                Repair_Work_Order_Open_Date__c,
                Vehicle_Mileage__c,
               // Primary_Failed_Part__c,
                Requestor_s_Name__c,
                Customer_Name__c,
                Parts_at_Cost__c,
                Force_Goodwill_Coverage__c,
                Parts__c,
                Labor__c,
                Expenses__c,
                Total_Amount_Approved__c,
                Requestor_s_Phone_Number__c,
                Internal_Comments__c,
                Approval_Information__c,
                Approval_Status__c, 
                Normal_Approval__c,
                Repeat_Repair_Review__c,
                Mileage__c,
                Duplicate_Campaign_Different_Dealer__c,
                Goodwill_Approval__c,
                HOST_Error_Message__c, HOST_Reference_Number__c,
                Host_Comments__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                Vehicle_Campaign1__c,
                Vehicle_Campaign1__r.Name,
                isVCANUpdate__c, isSystemUpdate__c, isApprovalStatusChanged__c
                from Warranty_Case__c where Id =:caseId];
    }
    
    private static testmethod void main() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', VCAN_Password__c='test1234' );
        insert u;
        
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

        Warranty_Case__c wc = new Warranty_Case__c();
        wc.parts__c=0;
        wc.Labor__c=0;
        wc.expenses__c = 100;
        wc.Vehicle__c = veh.Id;
        wc.Dealer__c = dealer.Id;
        //wc.Approval_Information__c = '**SFDCUPDATE**Blah';
        wc.Repair_Work_Order__c = '73819';
        wc.Job_Line_Number__c = '1A';
        wc.Repair_Work_Order_Open_Date__c = Date.today();
        wc.Vehicle_Mileage__c = 12000;
       // wc.Primary_Failed_Part__c = 'abc1324';
        wc.Parts_at_Cost__c = 'No';
        wc.Requestor_s_Phone_Number__c = '5555555555';
        wc.Requestor_s_Name__c = 'Aaron';
        wc.Approval_Status__c = 'Pending';
        wc.Customer_Name__c ='Aaron';
        wc.Normal_Approval__c = 'A';
        wc.Repeat_Repair_Review__c = 'A';
        wc.Duplicate_Campaign_Different_Dealer__c = 'A';
        wc.Goodwill_Approval__c = 'A';
        wc.Mileage__c = 'A';
        
        
        
        Id RTId = Schema.SObjectType.Warranty_Case__c.getRecordTypeInfosByName().get('WCC VCAN').getRecordTypeId();
        
        wc.RecordTypeId = RTId;        
        insert wc;
        
        wc = queryWarrantyCase(wc.Id);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(wc);
        VCANComponent vc = new VCANComponent(sc);      
        
        system.debug('Testing Status:' +Label.VCAN_Testing_Status);
        system.debug('VCAN_Service_User = ' + Label.VCAN_Service_User);
        system.debug('VCAN_Service_Password = ' + Label.VCAN_Service_Password);
        
        String url = vc.getPageURL();
        wc = vc.getWarrantyCase(wc.Id);
        
        PageReference pr = vc.refreshVCAN();
        
        VCANComponent.VCANJSONResponse VCANResponse = vc.checkWarrantyCaseVCAN(wc.Id);
        pr = vc.createVCAN();
        vc.warrantyCase.Approval_Information__c = 'Blah';
        wc.Approval_Information__c = 'Blah';
        update wc;
        
        pr = vc.createVCAN();
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        pr = vc.updateVCAN();
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);        
        pr = vc.deleteVCAN();
        VCANResponse = vc.deleteWarrantyCaseVCAN(wc.Id);
        
        wc.HOST_Reference_Number__c = 'N1234543w2';
        update wc;
        System.runAs(u)
        {
             pr = vc.refreshVCAN();
        }
        vc.useRefreshTimeout = true;
        pr= vc.refreshVCAN();
        
        
        wc = new Warranty_Case__c();
        wc.parts__c=0;
        wc.Labor__c=0;
        wc.expenses__c = 100;
        wc.Parts_at_Cost__c = 'Yes';
        
        insert wc;
        
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id); 
                
        wc.Vehicle__c = veh.Id;
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id); 
        wc.Dealer__c = dealer.Id;
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Approval_Information__c = 'Blah';
        wc.Repair_Work_Order__c = '73819';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Job_Line_Number__c = '1A';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Repair_Work_Order_Open_Date__c = Date.today();
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Vehicle_Mileage__c = 12000;
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        Master_Recall_Campaign__c campaign = new Master_Recall_Campaign__c();
        campaign.Name='test';
        insert campaign;
        wc.Vehicle_Campaign1__c = campaign.Id;
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
       // wc.Primary_Failed_Part__c = 'abc1324';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Parts_at_Cost__c = 'No';
        wc.Requestor_s_Phone_Number__c = '5555555555';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Requestor_s_Name__c = 'Aaron';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Approval_Status__c = 'Pending';
        wc.Customer_Name__c ='Aaron';
        wc.Force_Goodwill_Coverage__c = 'Yes';
        update wc;
        VCANResponse = vc.createWarrantyCaseVCAN(wc.Id);
        VCANResponse = vc.updateWarrantyCaseVCAN(wc.Id);
        wc.Normal_Approval__c = 'A';
        wc.Repeat_Repair_Review__c = 'A';
        wc.Duplicate_Campaign_Different_Dealer__c = 'A';
        wc.Goodwill_Approval__c = 'A';
        
        pr = vc.changePassword();
       	vc.newVCANPassword = '1234sbkb';
        pr = vc.savePassword();
        vc.newVCANPassword = null;
        pr = vc.savePassword();
        
        u.VCAN_Password__c = null;
        u.warranty_vcan_delete__c = true;
        update u;
        
        system.runAs(u)
        {
            sc = new ApexPages.StandardController(wc);
            vc = new VCANComponent(sc);
            pr= vc.refreshVCAN();
            
            u.warranty_vcan_delete__c = false;
        	update u;
            sc = new ApexPages.StandardController(wc);
            vc = new VCANComponent(sc);
            pr= vc.refreshVCAN();
            pr = vc.deleteVCAN();
            vc.deleteWarrantyCaseVCAN(wc.Id);
        }
        
        wc.Vehicle__c = veh.Id;
        wc.Dealer__c = dealer.Id;
        
        wc.Vehicle__c = null;
        update wc;
        sc = new ApexPages.StandardController(wc);
        vc = new VCANComponent(sc);
        
        wc.Vehicle__c = veh.Id;
        wc.Dealer__c = null;
        update wc;
        sc = new ApexPages.StandardController(wc);
        vc = new VCANComponent(sc);
  
        Test.stopTest();
    }
    
    private static testMethod void DateTests()
    {
        String sDate;
        Date myDate;
        myDate = VCANComponent.convertMMDDYYToDate(sDate);
        
        sDate = '10/23/14';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);         
        sDate = '9-9-14';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);
        sDate = '10.23.14';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);
        sDate = '10-23';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);
        
        sDate = '10/23/9';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);     
        
        sDate = '10/23/97';
        myDate = VCANComponent.convertMMDDYYToDate(sDate);   
    }
    
    private static testMethod void testTitleCase()
    {
        String sString = '';
        sString = VCANComponent.toTitleCase(sString);
        sString = null;
        sString = VCANComponent.toTitleCase(sString);
        sString = 'aaron bessey';
        sString = VCANComponent.toTitleCase(sString);
        System.assertEquals('Aaron Bessey', sString);
    }
}