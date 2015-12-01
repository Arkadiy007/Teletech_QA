@isTest
private class Test_NNADealerSearchController { 
     static NNADealerSearchController TestData_CaseIsValid(){
            PageReference pageRef = Page.NNADealerSearch;
            Test.setCurrentPage(pageRef);

            Id caseCustomerConnectionRtId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
            Id accountDealerRtId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');

            NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();
            System.assertEquals('', nnadealsearch_controller.caseId);
            
            Account test_acc = new Account(Name ='Test Acc2',
                                            Preferred_Dealer_Code__c = '987456321',
                                            RecordTypeId = accountDealerRtId,
                                            Internet_Certified__c = true);
             insert test_acc;

             Account test_acc_d = new Account(Name ='Test Acc3',
                                            Preferred_Dealer_Code__c = '987456123',
                                            RecordTypeId = accountDealerRtId,
                                            Dealer_Code__c = '123321123',
                                            Internet_Certified__c = true);
            insert test_acc_d;
            Case test_case = new Case(Preferred_Dealer__c = test_acc_d.id,
                                        RecordTypeId = caseCustomerConnectionRtId,
                                        SuppliedEmail = 'test1@test.com',
                                        Alternate_Email__c = 'test1@test.com',
                                        Work_Phone__c = '222222',
                                        AccountId = test_acc.id,
                                          Consent_to_send_Pii__c = true,
                                        Mailing_Zip_Code__c = '2222',
                                        Considered_Vehicle_Make__c = 'Nissan' ,
                                        Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                        Lead_Provider__c = 'Lead Provider',
                                        Lead_Provider_Detail__c = 'Lead Provider Detail',
                                        Lead_Provider_Name__c = 'Lead Provider Name');
            Insert test_case;

            List<USW_Case_Mappings__c> TestMapping = new List<USW_Case_Mappings__c>();
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011100',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Account.Name',
                                                    US_Field_Name__c = 'contact_fullname'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011101',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Mailing_Zip_Code__c',
                                                    US_Field_Name__c = 'contact_postalcode'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011102',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Make__c',
                                                    US_Field_Name__c = 'vehicle_make'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011103',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Model__c',
                                                    US_Field_Name__c = 'vehicle_model'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011104',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Work_Phone__c',
                                                    US_Field_Name__c = 'contact_work_phone'));
            insert TestMapping;

            ApexPages.currentPage().getParameters().put('caseId', test_case.id);
            nnadealsearch_controller = new NNADealerSearchController();

            return nnadealsearch_controller;
    }
    
    static NNADealerSearchController TestData_CaseIsNotValid(){
            PageReference pageRef = Page.NNADealerSearch;
            Test.setCurrentPage(pageRef);

            Id caseCustomerConnectionRtId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
            Id accountDealerRtId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
            
             Account test_acc_d = new Account(Name ='Test Acc3',
                                            Preferred_Dealer_Code__c = '987456123',
                                            RecordTypeId = accountDealerRtId,//'012A0000000OfI0IAK',
                                            Dealer_Code__c = '123321123',
                                            Internet_Certified__c = true);
            insert test_acc_d;
            Case test_case = new Case(Preferred_Dealer__c = test_acc_d.id,
                                        RecordTypeId = caseCustomerConnectionRtId,//'012F0000000yBMoIAM', 
                                        SuppliedEmail = 'test1@test.com',
                                        Alternate_Email__c = 'test1@test.com',
                                        Work_Phone__c = '222222',
                                        Mailing_Zip_Code__c = '2222',
                                        Considered_Vehicle_Make__c = 'Nissan' ,
                                        Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                        Lead_Provider__c = 'Lead Provider',
                                        Lead_Provider_Detail__c = 'Lead Provider Detail',
                                        Lead_Provider_Name__c = 'Lead Provider Name');
            Insert test_case;
            
            List<USW_Case_Mappings__c> TestMapping = new List<USW_Case_Mappings__c>();
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011100',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Account.Name',
                                                    US_Field_Name__c = 'contact_fullname'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011101',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Mailing_Zip_Code__c',
                                                    US_Field_Name__c = 'contact_postalcode'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011102',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Make__c',
                                                    US_Field_Name__c = 'vehicle_make'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011103',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Model__c',
                                                    US_Field_Name__c = 'vehicle_model'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011104',
                                                    Case_Record_Type__c = 'Customer_Connection_Follow_Up',
                                                    SF_Field_Name__c = 'Work_Phone__c',
                                                    US_Field_Name__c = 'contact_work_phone'));
            insert TestMapping;

            ApexPages.currentPage().getParameters().put('caseId', test_case.id);
            NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();

            return nnadealsearch_controller;
    }

    @isTest static void Test_redirectToCase(){
            NNADealerSearchController nnadealsearch_controller = TestData_CaseIsNotValid(); 
            Pagereference pageRef = new Pagereference('/' + nnadealsearch_controller.caseid);
            System.assertEquals(pageRef.getURL(), nnadealsearch_controller.redirectToCase().getURL());
            
    }       

    @isTest static void Test_updateCaseAndRedicect_WhereCaseIsNotValid(){
            NNADealerSearchController nnadealsearch_controller = TestData_CaseIsNotValid(); 
            
            Case cs = nnadealsearch_controller.dynamicQueryCase(nnadealsearch_controller.caseId)[0];
            System.assertEquals(nnadealsearch_controller.caseId, cs.id);    
                
            Pagereference returned_pageRef  = nnadealsearch_controller.updateCaseAndRedicect();
            System.assertEquals(null, returned_pageRef);    
    }   

    @isTest static void Test_updateCaseAndRedicect_WhereCaseIsValid(){
            NNADealerSearchController nnadealsearch_controller = TestData_CaseIsValid(); 
            Pagereference pageRef = new Pagereference('/' + nnadealsearch_controller.caseid);

            Case cs = nnadealsearch_controller.dynamicQueryCase(nnadealsearch_controller.caseId)[0];
            
            //----------MOCK
            NNALeadServicesHandler.LeadApprovalResponse nl ;
            test.startTest(); 

            String xmlBody = UrbanScienceCaseMappingHelper.generateAdfXMLFromCase(cs);

            Test.setMock(HttpCalloutMock.class, new Test_NNADealerSearchController.MockHttpResponseGenerator()); 

            Pagereference returned_pageRef  = nnadealsearch_controller.updateCaseAndRedicect();
            test.stopTest(); 
            //-------------

            cs = nnadealsearch_controller.dynamicQueryCase(nnadealsearch_controller.caseId)[0];
            System.assertEquals('1111111', cs.Case_GUID__c);
            Attachment attach = nnadealsearch_controller.createAttach(xmlBody, nnadealsearch_controller.caseId); 
            insert attach;

            System.assertEquals(nnadealsearch_controller.caseId, attach.ParentId);
            System.assertEquals(pageRef.getURL(), returned_pageRef.getURL());       
    }   
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
      public HTTPResponse respond(HTTPRequest req) 
        {    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('<LeadGUId>1111111</LeadGUId><ResponseTime>11</ResponseTime><ResponseCode>301</ResponseCode><ResponseDetails>test1</ResponseDetails>');  
            return res;
        }
    }

}