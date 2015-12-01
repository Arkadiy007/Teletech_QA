/**********************************************************************
Name: BrochureRequest_Webservices_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Test class for BrochureRequest_Webservices class.

Related Class : BrochureRequest_Webservices
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqi 01/25/2011 Created
1.1 - Sonali Bhardwaj    01/31/2011 Modified to increase code coverage. 
1.2 - Biswa Ray          02/16/2011 Incorporated Review comments            
***********************************************************************/
@isTest
private class BrochureRequest_Webservices_Test {

        private static BrochureRequest_Webservices obj;
        private static BrochureRequest_Webservices.BrochureRequestData obj1;
        private static Brochure_Request__c br = new Brochure_Request__c();
        private static UnitTestUtil oUtil = UnitTestUtil.getInstance();


        static void testdata(Boolean IsUnitTesting) {
            RecordType dealerType = [select id, name from recordtype where name = : System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
            RecordType personType = [select id, name from recordtype where name = : System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
			RecordType brRT = [select id from recordtype where sobjecttype = 'Brochure_Request__c' and name = 'Brochure Request'];

    	    State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	    insert state;

            Account prefferedAccount = new Account();
            prefferedAccount.name = 'Account';
            prefferedAccount.RecordTypeId = dealerType.id;
            prefferedAccount.Dealer_Code__c = 'Test';
            insert prefferedAccount; 
        
            Account account = new Account();
            account.lastName = 'Account';
            account.RecordTypeId = personType.id;
            account.Preferred_Dealer_Code__c = 'Test';
            account.FirstName = 'test';
            account.PersonEmail = 'test@nissan.com';
	        account.Undeliverable_Address_Indicator__c = false;
	        account.PersonMailingPostalCode = '21204';
	        account.PersonMailingStreet = 'PersonMailingStreet';
	        account.PersonMailingCity  = 'PersonMailingCity';
	        account.PersonMailingState = 'CO';
            insert account;
            
            Lead lead = new Lead(LastName = 'test', FirstName='test', PostalCode='123456');
            insert lead;
            
            br.RecordTypeId = brRT.ID;
            br.Account_Name__c = account.id;
            br.Keep_Me_Informed_Nissan_Indicator__c = true ;
            br.Keep_Me_Informed_Infiniti_Indicator__c = true ;
            br.Send_Nissan_Email_Indicator__c = true ;
            br.Send_Infiniti_Email_Indicator__c = true ;
            br.Resend_Request_Indicator__c = true ;
            br.Nissan_Model_1__c = '2010 Z Nismo' ;
            br.Infiniti_Model_1__c = '2011 Ex' ;
            br.Infiniti_Model_2__c = '2011 Fx' ;
            br.Lead_Name__c = lead.id;
            insert br;
            ApexPages.StandardController sc = new ApexPages.StandardController(br);
            obj = new BrochureRequest_Webservices (sc);
            obj1 = new BrochureRequest_Webservices.BrochureRequestData(br.id);
            obj1.fillDataForCustomer(br);
        }
  
        /*static testmethod void testSubmitRecord() {
            testdata(true);
            oUtil.isUnitTesting = true;
    
            // Start the test, this changes governor limit context to
            // that of trigger rather than test.
    
            Test.startTest();
            obj.callSubmitRecord();

            //Stop the test, this changes limit context back to test from trigger. 
        
            Test.StopTest();
    
            // Verify correct action
    
            System.assert(obj.infinitiOnly == false); 
            System.assert(obj.infinitiBoth == false); 
            System.assert(obj.infinitiOnlyResend == false); 
            System.assert(obj.nissanBoth == false); 
            System.assert(obj.nissanOnly == false); 
            System.assert(obj.nissanOnlyResend == false);          
        }
        static testmethod void runNegativeTestCases() {
            testdata(false);
            oUtil.isUnitTesting = false;
        
            // Start the test, this changes governor limit context to
            // that of trigger rather than test.
            
            Test.startTest();
            
            obj.SubmitRecord();
            br.Resend_Request_Indicator__c = false ;
            update br;
            
            // Stop the test, this changes limit context back to test from trigger. 
            
            Test.StopTest();
              
        }*/
        static testmethod void testCallSubmitRecord() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
            
            BrochureRequest_Webservices.callSubmitRecord(br.id);
            
            Test.StopTest();
        }
        
        static testmethod void testNissancodes() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
       
            Map<String,String> Nicodes = BrochureRequest_Webservices.getNissanCodes();
            
            Test.StopTest();
            //System.assert(Nicodes.size() > 0);
        }
        
        static testmethod void testInfinitiCodes() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
            
            Map<String,String> Incodes = BrochureRequest_Webservices.getInfinitiCodes();
        
            Test.StopTest();
            //System.assert(Incodes.size() > 0);
        }
        
         
        static testmethod void testfillDataForCustomer() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
           
            obj1.fillDataForCustomer(br);
            
            Test.StopTest();
            System.assert(account.lastName!=null);
        }
        
        static testmethod void testfillDataForLead() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
            
            obj1.fillDataForLead(br);
            
            Test.StopTest();
            System.assert(lead.LastName!=null);
        }
        
        static testmethod void testGetNissanRequest() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
           
            String Nireq = obj1.getNissanRequest();
            
            Test.StopTest();
        }
        
        static testmethod void testgetInfinitiRequest() {
            testdata(true);
            oUtil.isUnitTesting = true;
            obj1.fillDataForCustomer(br);
            Test.startTest();
           
            String Inreq = obj1.getInfinitiRequest();
            
            Test.StopTest();
        }
        
        static testmethod void testgetNissanCode() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
           
            String Code = BrochureRequest_Webservices.getNissanCode('5610001');
            
            Test.StopTest();
            System.assert(Code != null);
        }
        
        static testmethod void testGetInfinitiTOERequest() {
            testdata(true);
            oUtil.isUnitTesting = true;
            Test.startTest();
           
            obj1.getInfinitiTOERequest();
            
            Test.StopTest();
        }
}