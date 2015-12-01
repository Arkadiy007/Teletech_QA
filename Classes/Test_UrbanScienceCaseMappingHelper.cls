@isTest
private class Test_UrbanScienceCaseMappingHelper { 
    static Case TestData_CaseIsValid(){
            PageReference pageRef = Page.NNADealerSearch;
            Test.setCurrentPage(pageRef);

            insertCustomSettings();

            Id caseCustomerConnectionRtId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
            Id accountDealerRtId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
        
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
                                        Consent_to_send_Pii__c = true,
                                        AccountId = test_acc.id,
                                        Mailing_Zip_Code__c = '2222',
                                        Lease_Monthly_Payment__c =33,
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

            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011105',
                                                    Case_Record_Type__c = 'IB_Case',
                                                    SF_Field_Name__c = 'Account.Name',
                                                    US_Field_Name__c = 'contact_fullname'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011107',
                                                    Case_Record_Type__c = 'IB_Case',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Make__c',
                                                    US_Field_Name__c = 'vehicle_make'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011108',
                                                    Case_Record_Type__c = 'IB_Case',
                                                    SF_Field_Name__c = 'Model_of_Interest_1st__c',
                                                    US_Field_Name__c = 'vehicle_model'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011109',
                                                    Case_Record_Type__c = 'IB_Case',
                                                    SF_Field_Name__c = 'Work_Phone__c',
                                                    US_Field_Name__c = 'contact_work_phone'));

            insert TestMapping;

            ApexPages.currentPage().getParameters().put('caseId', test_case.id);
            NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();
            Case cs = nnadealsearch_controller.dynamicQueryCase(nnadealsearch_controller.caseId)[0];

            return cs;
    }

    static void insertCustomSettings(){
        List<Dealer_Backfeed_Business_Rules__c> br = new List<Dealer_Backfeed_Business_Rules__c>();
        br.add(new Dealer_Backfeed_Business_Rules__c(NameValue__c='CallCenter', OriginValue__c='', RecordTypeValue__c=RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType,'Customer Connection Follow Up'), ServiceNameValue__c='WarmLead'));
        br.add(new Dealer_Backfeed_Business_Rules__c(NameValue__c='CallCenter', OriginValue__c='', RecordTypeValue__c=RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType,'Lead Survey'), ServiceNameValue__c='WarmLead'));
        br.add(new Dealer_Backfeed_Business_Rules__c(NameValue__c='CallCenter', OriginValue__c='', RecordTypeValue__c=RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType,'Lease Loyalty'), ServiceNameValue__c='WarmLead'));
        br.add(new Dealer_Backfeed_Business_Rules__c(NameValue__c='CallCenter', OriginValue__c='', RecordTypeValue__c=RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType,'Retail Loyalty'), ServiceNameValue__c='WarmLead'));
        br.add(new Dealer_Backfeed_Business_Rules__c(NameValue__c='CallCenter', OriginValue__c='', RecordTypeValue__c=RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType,'CCC'), ServiceNameValue__c='EmailLead'));
    
        Integer i = 10000;

        for(Dealer_Backfeed_Business_Rules__c rule : br){
            rule.Name = String.valueOf(i);
            i++;
        }

        insert br;
    }
    
    static Case TestData_CaseIsNotValid(){
            PageReference pageRef = Page.NNADealerSearch;
            Test.setCurrentPage(pageRef);

            Id caseCustomerConnectionRtId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
            Id accountDealerRtId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
            
             Account test_acc_d = new Account(Name ='Test Acc3',
                                            Preferred_Dealer_Code__c = '987456123',
                                            RecordTypeId = accountDealerRtId,
                                            Dealer_Code__c = '123321123',
                                            Internet_Certified__c = false);
            insert test_acc_d;
            Case test_case = new Case(  Preferred_Dealer__c = test_acc_d.id,
                                        RecordTypeId = caseCustomerConnectionRtId,
                                        Mailing_Zip_Code__c = '2222',
                                        Consent_to_send_Pii__c = true,
                                        Considered_Vehicle_Make__c = 'Infiniti' ,
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

            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011105',
                                                    Case_Record_Type__c = 'IB Case',
                                                    SF_Field_Name__c = 'Account.Name',
                                                    US_Field_Name__c = 'contact_fullname'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011106',
                                                    Case_Record_Type__c = 'IB Case',
                                                    SF_Field_Name__c = 'Mailing_Zip_Code__c',
                                                    US_Field_Name__c = 'contact_postalcode'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011107',
                                                    Case_Record_Type__c = 'IB Case',
                                                    SF_Field_Name__c = 'Considered_Vehicle_Make__c',
                                                    US_Field_Name__c = 'vehicle_make'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011108',
                                                    Case_Record_Type__c = 'IB Case',
                                                    SF_Field_Name__c = 'Model_of_Interest_1st__c',
                                                    US_Field_Name__c = 'vehicle_model'));
            TestMapping.add(new USW_Case_Mappings__c(Name = '00000011109',
                                                    Case_Record_Type__c = 'IB Case',
                                                    SF_Field_Name__c = 'Work_Phone__c',
                                                    US_Field_Name__c = 'contact_work_phone'));
            insert TestMapping;

            ApexPages.currentPage().getParameters().put('caseId', test_case.id);
            NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();
            Case cs = nnadealsearch_controller.dynamicQueryCase(nnadealsearch_controller.caseId)[0];

            return cs;
    }

    @isTest static void Test_convertValue(){
            Case cs = TestData_CaseIsValid();
            Map <String, DescribeFieldResult > caseDescription = UrbanScienceCaseMappingHelper.getFieldsMap(Case.SObjectType);
            String res = UrbanScienceCaseMappingHelper.convertValue(caseDescription.get('Considered_Vehicle_Model__c'), (Sobject) cs);

            System.assertEquals(true, res.contains('Considered_Vehicle_Model__c=Considered Vehicle Model'));    
            
            res=UrbanScienceCaseMappingHelper.convertValue(caseDescription.get('Considered_Vehicle_Model__c'), null);
            System.assertEquals('', res);   

            res = UrbanScienceCaseMappingHelper.convertValue(caseDescription.get('Lease_Monthly_Payment__c'), (Sobject) cs);
            System.assertEquals(true, res.contains('Considered_Vehicle_Model__c=Considered Vehicle Model'));
            
    }   

    @isTest static void Test_validateCase(){
        Case cs = TestData_CaseIsValid();

        List <USW_Case_Mappings__c > mappings = UrbanScienceCaseMappingHelper.getMappings(cs.RecordType.DeveloperName);
        Map <String, String > request = UrbanScienceCaseMappingHelper.mapCaseToIntermediateMap(cs, mappings);
        Boolean isValid = UrbanScienceCaseMappingHelper.validateCase(cs, request, mappings);

        System.assertEquals(true, isValid); 

        cs.Dealer__c = cs.Preferred_Dealer__c;
        update cs;
        isValid = UrbanScienceCaseMappingHelper.validateCase(cs, request, mappings);
        System.assertEquals(true, isValid);

        cs.Preferred_Dealer__c=null;
        update cs;
        isValid = UrbanScienceCaseMappingHelper.validateCase(cs, request, mappings);
        System.assertEquals(false, isValid);

        cs = TestData_CaseIsNotValid();
        isValid = UrbanScienceCaseMappingHelper.validateCase(cs, request, mappings);
        System.assertEquals(false, isValid);
    }

    @isTest static void Test_validateIBCase(){
        Case cs = TestData_CaseIsValid();
        cs.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case');
        
        Call__c call = generateValidCall(cs);
        insert call;

        update cs;

         NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();
        Case updatedCase = nnadealsearch_controller.dynamicQueryCase(cs.id)[0];
        List <USW_Case_Mappings__c > mappings = UrbanScienceCaseMappingHelper.getMappings(updatedCase.RecordType.DeveloperName);
        Map <String, String > request = UrbanScienceCaseMappingHelper.mapCaseToIntermediateMap(updatedCase, mappings);
        Boolean isValid = UrbanScienceCaseMappingHelper.validateCase(updatedCase, request, mappings);

        System.assertEquals(true, isValid); 
        
        String XML = UrbanScienceCaseMappingHelper.generateAdfXMLFromCase(updatedCase);
        System.assert(XML.contains('ROGUE'));
        System.assert(!XML.contains('&&&'));
        System.assert(XML.contains('NOTES TEST'));
    }

    @isTest static void Test_validateIBCaseChat(){
        Case cs = TestData_CaseIsValid();
        cs.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case');
        cs.Origin = 'Chat';

        Pre_Chat_Data__c call = generatePrechatData(cs);
        insert call;

        update cs;

         NNADealerSearchController nnadealsearch_controller = new NNADealerSearchController();
        Case updatedCase = nnadealsearch_controller.dynamicQueryCase(cs.id)[0];
        List <USW_Case_Mappings__c > mappings = UrbanScienceCaseMappingHelper.getMappings(updatedCase.RecordType.DeveloperName);
        Map <String, String > request = UrbanScienceCaseMappingHelper.mapCaseToIntermediateMap(updatedCase, mappings);
        Boolean isValid = UrbanScienceCaseMappingHelper.validateCase(updatedCase, request, mappings);

        System.assertEquals(true, isValid); 
        
        String XML = UrbanScienceCaseMappingHelper.generateAdfXMLFromCase(updatedCase);
        System.assert(XML.contains('ROGUE'));
    }


    @isTest static void Test_generateAdfXMLFromCase(){
        Case cs = TestData_CaseIsValid();
        String XML = UrbanScienceCaseMappingHelper.generateAdfXMLFromCase(cs);
        System.assertEquals(true, XML.contains('<model>' + 'CONSIDERED VEHICLE MODEL' + '</model>')); 
        System.assertEquals(true, XML.contains('<name part="full">' + 'CallCenter' + '</name>')); 
        System.assertEquals(true, XML.contains('<service>' + 'WarmLead' + '</service>'));   
    }
    
    private static Call__c generateValidCall(Case cs){
        return new Call__c(Call_Type__c = 'Inbound Customer Call', Case__c = cs.Id, Model_of_Interest_1st__c='Nissan Rogue', Model_of_Interest_Year_1st__c='2014', Notes__c = 'NOTES TEST &&&', Model_of_Interest_2nd__c = 'Nissan Rogue');
    }

    private static Pre_Chat_Data__c generatePrechatData(Case cs){
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript testTranscript = new LiveChatTranscript(LiveChatVisitorId = visitor.Id, IpAddress = '10.10.20.20', StartTime = DateTime.Now(), Session_Id__c = '111', CaseId = cs.Id);
        insert testTranscript;

        return new Pre_Chat_Data__c(Make__c = 'Nissan', Model__c = 'ROGUE', Live_Chat_Transcript__c = testTranscript.Id, RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Pre_Chat_Data__c.SObjectType, 'MCC'));

    }
}