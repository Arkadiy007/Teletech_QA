/**********************************************************************
Name: TMS_Webservices_Utility_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: Test coverage class for TMS_Webservices_Utility
======================================================
History:

VERSION AUTHOR DATE DETAIL 
1.0 - Vijaya D          01/25/2011 Created
1.1 - Sonali Bhardwaj   01/28/2011 Modified code to increase code coverage.
***********************************************************************/
@isTest
private class TMS_Webservices_Utility_Test {
    private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
    static testmethod void testCheckDealerCode() {
        test.startTest();
        try {
            TMS_Webservices_Utility.CheckDealerCode('test');
            TMS_Webservices_Utility.CheckDealerCode(null);
        }
        catch(Exception e) {
            System.assert(e.getMessage() == TMS_Webservices_Utility.dealerCodeError);
        }
        test.stopTest();
    }
    
    static testmethod void testCheckToken() {
        test.startTest();
        try {
            TMS_Webservices_Utility.CheckToken('test');
            TMS_Webservices_Utility.CheckToken(null);
        }
        catch(Exception e) {
            System.assert(e.getMessage() == TMS_Webservices_Utility.tokenError);
        }
        test.stopTest();
    }
    
    static testmethod void testCheckCustomerId() {
        test.startTest();
        try {
            TMS_Webservices_Utility.CheckCustomerId('test');
            TMS_Webservices_Utility.CheckCustomerId(null);
        }
        catch(Exception e) {
            System.assert(e.getMessage() == TMS_Webservices_Utility.customerIdError);
        }
        test.stopTest();
    }
    
    static testmethod void testRunGetDealerInfo() {
        
        oUtil.isUnitTesting = true;
        oUtil.mockResponse = '<dealer code="5049"><test>211</test><dealerid>211</dealerid><enrolled>Y</enrolled><name>CLAY NISSAN OF NEWTON</name><address1>431 Washington Street</address1><city>Newton</city><stateprov>MA</stateprov><country>USA</country><postalzip>02458</postalzip><general_phone>6179643000</general_phone><general_fax>6176419931</general_fax><general_email>alant@claycars.com</general_email><sales><phone>617-964-3000</phone><hours day="1" open="9:00am" close="8:00pm" /><hours day="2" open="9:00am" close="8:00pm" /><hours day="3" open="9:00am" close="8:00pm" /><hours day="4" open="9:00am" close="8:00pm" /><hours day="5" open="9:00am" close="6:30pm" /><hours day="6" open="9:00am" close="5:00pm" /><hours closed="true"/></sales><appointments><phone>617-964-3000</phone><hours day="1" open="9:00am" close="8:00pm" /><hours day="2" open="9:00am" close="8:00pm" /><hours day="3" open="9:00am" close="8:00pm" /><hours day="4" open="9:00am" close="8:00pm" /><hours day="5" open="9:00am" close="6:30pm" /><hours day="6" open="9:00am" close="5:00pm" /><hours closed="true"/></appointments><service><phone>617-964-3000</phone><hours day="1" open="7:00am" close="7:00pm" /><hours day="2" open="7:00am" close="7:00pm" /><hours day="3" open="7:00am" close="7:00pm" /><hours day="4" open="7:00am" close="7:00pm" /><hours day="5" open="7:00am" close="6:30pm" /><hours day="6" open="7:00am" close="4:00pm" /><hours day="7" closed="true" /></service><conveniences>Highly skilled Factory-trained Technicians to fix your vehicle right the first time; Open on Saturday; Free shuttle service available; Service by appointment; Oil, lube &amp; filter with no appointment required; Work area with phone lines and desks; Comfortable waiting area; Free car wash upon request; All major credit cards and personal checks; GT-R;</conveniences><contact type="Service Manager"><test>Alan Teyssedou</test><name>Alan Teyssedou</name><email>alant@claycars.com</email><phone>6179643000</phone></contact></dealer>';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetDealerInfo('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetDealerInfoResponseOne() {
        string result = '<dealer code="5049"><test>211</test><dealerid>211</dealerid><enrolled>Y</enrolled><name>CLAY NISSAN OF NEWTON</name><address1>431 Washington Street</address1><city>Newton</city><stateprov>MA</stateprov><country>USA</country><postalzip>02458</postalzip><general_phone>6179643000</general_phone><general_fax>6176419931</general_fax><general_email>alant@claycars.com</general_email><sales><phone>617-964-3000</phone><hours day="1" open="9:00am" close="8:00pm" /><hours day="2" open="9:00am" close="8:00pm" /><hours day="3" open="9:00am" close="8:00pm" /><hours day="4" open="9:00am" close="8:00pm" /><hours day="5" open="9:00am" close="6:30pm" /><hours day="6" open="9:00am" close="5:00pm" /><hours closed="true"/></sales><appointments><phone>617-964-3000</phone><hours day="1" open="9:00am" close="8:00pm" /><hours day="2" open="9:00am" close="8:00pm" /><hours day="3" open="9:00am" close="8:00pm" /><hours day="4" open="9:00am" close="8:00pm" /><hours day="5" open="9:00am" close="6:30pm" /><hours day="6" open="9:00am" close="5:00pm" /><hours closed="true"/></appointments><service><phone>617-964-3000</phone><hours day="1" open="7:00am" close="7:00pm" /><hours day="2" open="7:00am" close="7:00pm" /><hours day="3" open="7:00am" close="7:00pm" /><hours day="4" open="7:00am" close="7:00pm" /><hours day="5" open="7:00am" close="6:30pm" /><hours day="6" open="7:00am" close="4:00pm" /><hours day="7" closed="true" /></service><conveniences>Highly skilled Factory-trained Technicians to fix your vehicle right the first time; Open on Saturday; Free shuttle service available; Service by appointment; Oil, lube &amp; filter with no appointment required; Work area with phone lines and desks; Comfortable waiting area; Free car wash upon request; All major credit cards and personal checks; GT-R;</conveniences><contact type="Service Manager"><test>Alan Teyssedou</test><name>Alan Teyssedou</name><email>alant@claycars.com</email><phone>6179643000</phone></contact></dealer>';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetDealerInfoResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    static testmethod void testParseGetDealerInfoResponseTwo() {
        string result = '<test></test>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetDealerInfoResponse(result);
        }
        catch(Exception e) {
            
        }
        test.stopTest();
    }
    
    static testmethod void testRunCheckAppointmentTime() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<time><open1>closed</open1><open>closed</open><close>closed</close></time>';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunCheckAppointmentTime('test', '11\\11\\2011');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseCheckAppointmentTimeResponseOne() {
        string result = '<time><open1>closed</open1><open>closed</open><close>closed</close></time>';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseCheckAppointmentTimeResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseCheckAppointmentTimeResponseTwo() {
        string result = '<time1></time1>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseCheckAppointmentTimeResponse(result);
        }
        catch (Exception e) {
            
        }
        test.stopTest();
        
    }
    
    static testmethod void testRunGetServicesDue() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<services><interval type="" name="Regular Maintenance"><node>test</node></test></interval></services>';
        test.startTest();
        List<TMS_Webservices_Utility.ServiceResponse> records = TMS_Webservices_Utility.RunGetServicesDue('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetServiceDueResponseOne() {
        string result = '<services><interval type="" name="Regular Maintenance"><node>test</node></test></interval></services>';
        
        test.startTest();
        List<TMS_Webservices_Utility.ServiceResponse> records = TMS_Webservices_Utility.ParseGetServiceDueResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
     static testmethod void testParseGetServiceDueResponseTwo() {
        string result = '<services1></services1>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.ServiceResponse> records = TMS_Webservices_Utility.ParseGetServiceDueResponse(result);
        }
        catch(Exception e) {
            
        }
        test.stopTest();
    }
    
    static testmethod void testRunGetPrimaryContactInfo() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<primary_contact><tmsw_cust_id1>34158540</tmsw_cust_id1><tmsw_cust_id>34158540</tmsw_cust_id><purchaser_id>51478852</purchaser_id><fname>DOUG</fname><lname>TALUS</lname><addr1>4315 FOUNTAIN LN N</addr1><addr2></addr2><city>PLYMOUTH</city><prov_id>22</prov_id><prov_cd>MN</prov_cd><postal_zip>55446-2433</postal_zip><area_cd_home>612</area_cd_home><home_phone_no>8171472</home_phone_no><area_cd_work>612</area_cd_work><work_phone_no>8171472</work_phone_no><email>NMG@A.COM</email><dealer_cust_no>TALU04</dealer_cust_no><make_name>Infiniti</make_name><model_name>G35X</model_name><model_year>2008</model_year><vin>JNKBV61F58M274085</vin></primary_contact> ';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetPrimaryContactInfo('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetPerimaryContactInfoOne() {
        string result = '<primary_contact><tmsw_cust_id1>34158540</tmsw_cust_id1><tmsw_cust_id>34158540</tmsw_cust_id><purchaser_id>51478852</purchaser_id><fname>DOUG</fname><lname>TALUS</lname><addr1>4315 FOUNTAIN LN N</addr1><addr2></addr2><city>PLYMOUTH</city><prov_id>22</prov_id><prov_cd>MN</prov_cd><postal_zip>55446-2433</postal_zip><area_cd_home>612</area_cd_home><home_phone_no>8171472</home_phone_no><area_cd_work>612</area_cd_work><work_phone_no>8171472</work_phone_no><email>NMG@A.COM</email><dealer_cust_no>TALU04</dealer_cust_no><make_name>Infiniti</make_name><model_name>G35X</model_name><model_year>2008</model_year><vin>JNKBV61F58M274085</vin></primary_contact> ';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetPerimaryContactInfo(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetPerimaryContactInfoTwo() {
        string result = '<primary_contact1></primary_contact1>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetPerimaryContactInfo(result);
        }
        catch (Exception e) {
            
        }
    }
    
    
    static testmethod void testRunCheckAppointment() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<appointment><NextApptDate1>2/3/2011</NextApptDate1><NextApptDate>2/3/2011</NextApptDate><NextApptTime>08:00:00</NextApptTime></appointment>';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunCheckAppointment('test', '11\\11\\2011', '1:1:1');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testPasreCheckAppointmentResponseOne() {
        string result = '<appointment><NextApptDate1>2/3/2011</NextApptDate1><NextApptDate>2/3/2011</NextApptDate><NextApptTime>08:00:00</NextApptTime></appointment>';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.PasreCheckAppointmentResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testPasreCheckAppointmentResponseTwo() {
        string result = '<appointment1></appointment1>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.PasreCheckAppointmentResponse(result);
        
        }
        catch (Exception e) {}
        test.stopTest();
       
    }
    
    static testmethod void testRunGetServiceHistory() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<services><service><number1>162367150</number1><number>162367150</number><date>12/9/2010</date><servicetype>M</servicetype><partsamount>175.95</partsamount><laboramount>219.50</laboramount><totalamount>444.19</totalamount><details><detail><description opcode="RBJOB">Brake Repair / Replacement</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype><paytype1>Customer</paytype1></detail><detail><description opcode="GTIRE">General Vehicle Inspection</description><servicetype>Maintenance</servicetype><paytype>Internal</paytype></detail><detail><description opcode="INSP">Misc</description><servicetype>Maintenance</servicetype><paytype>Internal</paytype></detail><detail><description opcode="LNR">Misc</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype></detail><detail><description opcode="MICRO">Air Filter Replacement</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype></detail></details></service></services>';
        test.startTest();
        List<TMS_Webservices_Utility.ServiceHistoryResponse> records = TMS_Webservices_Utility.RunGetServiceHistory('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetServiceHistoryResponseOne() {
        string result = '<services><service><number1>162367150</number1><number>162367150</number><date>12/9/2010</date><servicetype>M</servicetype><partsamount>175.95</partsamount><laboramount>219.50</laboramount><totalamount>444.19</totalamount><details><detail><description opcode="RBJOB">Brake Repair / Replacement</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype><paytype1>Customer</paytype1></detail><detail><description opcode="GTIRE">General Vehicle Inspection</description><servicetype>Maintenance</servicetype><paytype>Internal</paytype></detail><detail><description opcode="INSP">Misc</description><servicetype>Maintenance</servicetype><paytype>Internal</paytype></detail><detail><description opcode="LNR">Misc</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype></detail><detail><description opcode="MICRO">Air Filter Replacement</description><servicetype>Maintenance</servicetype><paytype>Customer</paytype></detail></details></service></services>';
        
        test.startTest();
        List<TMS_Webservices_Utility.ServiceHistoryResponse> records = TMS_Webservices_Utility.ParseGetServiceHistoryResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetServiceHistoryResponseTwo() {
        string result = '<services1></services1>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.ServiceHistoryResponse> records = TMS_Webservices_Utility.ParseGetServiceHistoryResponse(result);
        }   
        catch (Exception e) {
        }
        test.stopTest();
       
    }
    static testmethod void testParseGetServiceHistoryResponseThree() {
        string result = '<services></services>';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.ServiceHistoryResponse> records = TMS_Webservices_Utility.ParseGetServiceHistoryResponse(result);
        }   
        catch (Exception e) {
        }
        test.stopTest();
       
    }
    static testmethod void testRunGetCommunicationHistory() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<communications><communication><type>1</type><date>1</date><time>1</time><resolution>2</resolution><resolutiontext>3</resolutiontext><agent>g</agent><activity_type>d</activity_type><contact_type>g</contact_type><resolution_text>g</resolution_text><customer_comments>h</customer_comments><service_performed>h</service_performed><test>test</test></communication></communications>';
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.RunGetCommunicationHistory('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseCommunicationHistoryResponseOne() {
        string result = '<communications><communication><type>1</type><date>1</date><time>1</time><resolution>2</resolution><resolutiontext>3</resolutiontext><agent>g</agent><activity_type>d</activity_type><contact_type>g</contact_type><resolution_text>g</resolution_text><customer_comments>h</customer_comments><service_performed>h</service_performed><test>test</test></communication></communications>';
        
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseCommunicationHistoryResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseCommunicationHistoryResponseTwo() {
        string result = '<communications1></communications1>';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseCommunicationHistoryResponse(result);
        }
        catch (Exception e) {}
        test.stopTest();
       
    }
    
    static testmethod void testParseCommunicationHistoryResponseThree() {
        string result = '<communications></communications>';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseCommunicationHistoryResponse(result);
        }
        catch (Exception e) {}
        test.stopTest();
    }
    
    static testmethod void testRunGetAppointmentSubscribeURLOne() {
        Campaign camp = new Campaign(name='test');
        camp.IsActive = true;
        insert camp;
        Contact c = new Contact(LastName='test');
        insert c;
        CampaignMember member = new CampaignMember(campaignId = camp.id);
        member.Customer_ID__c = 'test';
        member.Service_Marketing_Call_ID__c = 11;
        member.contactId = c.Id;
        insert member;
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = 'test';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURL('test', 'test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testRunGetAppointmentSubscribeURLTwo() {
        test.startTest();
        try {
            TMS_Webservices_Utility.RunGetAppointmentSubscribeURL('test', 'test');
        }
        catch(Exception e) { }
        test.stopTest();
    }
    
    static testmethod void testParseGetAppointmentSubscribeURLResponse() {
        string result = 'internal';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetAppointmentSubscribeURLResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }

    static testmethod void testRunGetAppointmentSubscribeURLNCI() {
        Campaign camp = new Campaign(name='test');
        camp.IsActive = true;
        insert camp;
        Contact c = new Contact(LastName='test');
        insert c;
        CampaignMember member = new CampaignMember(campaignId = camp.id);
        member.Customer_ID__c = 'test';
        member.Service_Marketing_Call_ID__c = 11;
        member.contactId = c.Id;
        insert member;
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = 'https://xws.xtime.com';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetAppointmentSubscribeURLNCI('test', 'test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testRunGetAssociatedCustomers() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<customers><customer><tmsw_cust_id>23301148</tmsw_cust_id><total_weight>999</total_weight><total_weight1>999</total_weight1><fname>MARY E</fname><lname>SCARPA</lname><addr1>24 PEBBLE LN</addr1><addr2></addr2><city>STATEN ISLAND</city><prov_id>33</prov_id><prov_code>NY</prov_code><postal_zip>10305-3776</postal_zip><area_cd_home>718</area_cd_home><phone_num_home>5562662</phone_num_home><area_cd_work>347</area_cd_work><phone_num_work>9936244</phone_num_work><email>MHEROD@AOL.COM</email></customer></customers> ';
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.RunGetAssociatedCustomers('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetAssociatedCustomersResponseOne() {
        string result = '<customers><customer><tmsw_cust_id>23301148</tmsw_cust_id><total_weight>999</total_weight><total_weight1>999</total_weight1><fname>MARY E</fname><lname>SCARPA</lname><addr1>24 PEBBLE LN</addr1><addr2></addr2><city>STATEN ISLAND</city><prov_id>33</prov_id><prov_code>NY</prov_code><postal_zip>10305-3776</postal_zip><area_cd_home>718</area_cd_home><phone_num_home>5562662</phone_num_home><area_cd_work>347</area_cd_work><phone_num_work>9936244</phone_num_work><email>MHEROD@AOL.COM</email></customer></customers> ';
        
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseGetAssociatedCustomersResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetAssociatedCustomersResponseTwo() {
        string result = '<customers></customers> ';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseGetAssociatedCustomersResponse(result);
        }
        catch (Exception e) {}
        test.stopTest();
    }
    
    static testmethod void testParseGetAssociatedCustomersResponseThree() {
        string result = '<customers1></customers1> ';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseGetAssociatedCustomersResponse(result);
        }
        catch (Exception e) {}
        test.stopTest();
    }
    
    static testmethod void testRunSearchDealer() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;
        Account account = new Account(lastName = 'test', PersonMailingCity='1', 
                        PersonMailingState='CO', PersonMailingPostalCode='3123', FirstName = 'firstname', TMS_Customer_Id__c='111');
        RecordType personAccRec= [Select id from RecordType where name='TMS' and SobjectType = 'Account' limit 1];
        account.RecordTypeId = personAccRec.id;
        insert account;
        oUtil.IsUnitTesting = true;
         oUtil.MockResponse = '<dealers><dealer code="5049"><dealerid>211</dealerid><enrolled>Y</enrolled><name>CLAY NISSAN OF NEWTON</name><address1>431 Washington Street</address1><city>Newton</city><stateprov>MA</stateprov><country>USA</country><postalzip>02458</postalzip><sales><phone><area></area><exchange></exchange><line></line><line1></line1></phone></sales><service><phone></area></exchange></line></line1></phone></service><certification></certification><recommended>N</recommended></dealer><dealercustomer><model></model><modelyear></modelyear><modelyearcert>N</modelyearcert></dealercustomer></dealers> ';
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.RunSearchDealer(account);
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseSearchDealerResponseOne() {
        string result = '<dealers><dealer code="5049"><dealerid>211</dealerid><enrolled>Y</enrolled><name>CLAY NISSAN OF NEWTON</name><address1>431 Washington Street</address1><city>Newton</city><stateprov>MA</stateprov><country>USA</country><postalzip>02458</postalzip><sales><phone><area></area><exchange></exchange><line></line><line1></line1></phone></sales><certifications><certification></certification></certifications><service><phone><area></area><exchange></exchange><line></line><line1></line1></phone></service><certification></certification><recommended>N</recommended></dealer><dealercustomer><model></model><modelyear></modelyear><modelyearcert>N</modelyearcert></dealercustomer></dealers> ';
        
        test.startTest();
        List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseSearchDealerResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseSearchDealerResponseTwo() {
        string result = '<dealers></dealers> ';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseSearchDealerResponse(result);
        }
        catch (Exception e) {
            
        }
        test.stopTest();
        
    }
    
    static testmethod void testParseSearchDealerResponseThree() {
        string result = '<dealers1></dealers1> ';
        
        test.startTest();
        try {
            List<List<TMS_Webservices_Utility.Record>> records = TMS_Webservices_Utility.ParseSearchDealerResponse(result);
        }
        catch (Exception e) {
            
        }
        test.stopTest();
        
    }
    
    static testmethod void testRunGetassociated_dcno_id() {
        oUtil.IsUnitTesting = true;
        oUtil.MockResponse = '<customers><customer>37070564</customer><customer>56830922</customer></customers> ';
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.RunGetassociated_dcno_id('test');
        test.stopTest();
        System.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetAssociated_dcno_idResponseOne() {
        string result = '<customers><customer>37070564</customer><customer>56830922</customer></customers> ';
        
        test.startTest();
        List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetAssociated_dcno_idResponse(result);
        test.stopTest();
        
        system.assert(records.size() > 0);
    }
    
    static testmethod void testParseGetAssociated_dcno_idResponseTwo() {
        string result = '<customers1></customers1> ';
        
        test.startTest();
        try {
            List<TMS_Webservices_Utility.Record> records = TMS_Webservices_Utility.ParseGetAssociated_dcno_idResponse(result);
        
        }
        catch (Exception e) {
            
        }
        test.stopTest();
        
    }
    
    static testmethod void testcheckAppointmentDateTimeOne() {
        ApexPages.currentPage().getParameters().put(system.label.Type, 'Account');
        TMS_Webservices_Utility obj = new TMS_Webservices_Utility();
        test.startTest();
        PageReference p = obj.checkAppointmentDateTime();
        test.stopTest();
        
        system.assert(p != null);
    }
    
    static testmethod void testcheckAppointmentDateTimeTwo() {
        ApexPages.currentPage().getParameters().put(system.label.Type, 'contact');
        TMS_Webservices_Utility obj = new TMS_Webservices_Utility();
        test.startTest();
        PageReference p = obj.checkAppointmentDateTime();
        test.stopTest();
        
        system.assert(p != null);
    }
    
    static testmethod void testcheckAppointmentDateOne() {
        ApexPages.currentPage().getParameters().put(system.label.Type, 'contact');
        TMS_Webservices_Utility obj = new TMS_Webservices_Utility();
        test.startTest();
        PageReference p = obj.checkAppointmentDate();
        test.stopTest();
        
        system.assert(p != null);
    }
    
    static testmethod void testcheckAppointmentDateTwo() {
        TMS_Webservices_Utility obj = new TMS_Webservices_Utility();
        ApexPages.currentPage().getParameters().put(system.label.Type, 'Account');
        test.startTest();
        PageReference p = obj.checkAppointmentDate();
        test.stopTest();
        
        system.assert(p != null);
    }
}