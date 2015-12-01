/**********************************************************************
Name: Batch_CBB_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_CBB_DataLoad.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 02/06/2012 Created 
***********************************************************************/
@isTest
private class Batch_CBB_DataLoad_Test {

    static testMethod void myUnitTest() {
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];

        List<Vehicle__c> testVehicles = new List<Vehicle__c> {
            new Vehicle__c(Vehicle_Identification_Number__c = '98765432109876543'),
            new Vehicle__c(Vehicle_Identification_Number__c = '98765432109876544'),
            new Vehicle__c(Vehicle_Identification_Number__c = '98765432109876545'),
            new Vehicle__c(Vehicle_Identification_Number__c = '98765432109876546')
        };
        insert testVehicles;

        List<Case> testCases = new List<Case> {
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Legacy_Case_Number__c = 'CALGC1001', Vehicle_Name__c = testVehicles[0].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Legacy_Case_Number__c = 'CALGC1002', Vehicle_Name__c = testVehicles[1].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Legacy_Case_Number__c = 'CALGC1003', Vehicle_Name__c = testVehicles[2].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Legacy_Case_Number__c = 'CALGC3001', Vehicle_Name__c = testVehicles[3].Id)
        };
        insert testCases;

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;
        
        List<Check_Request__c> testChecks = new List<Check_Request__c> {
            new Check_Request__c(Case__c = testCases[0].ID, Payment_Verification__c = true,Check_Amount__c = 100, Mailing_Address_Verified__c = true, Payable_To_First_Name__c = 'First', Payable_To_Last_Name__c = 'Last', GL_Code__c = glCode.Id),
            new Check_Request__c(Case__c = testCases[1].ID, Payment_Verification__c = true,Check_Amount__c = 100, Mailing_Address_Verified__c = true, Payable_To_First_Name__c = 'First', Payable_To_Last_Name__c = 'Last', GL_Code__c = glCode.Id),
            new Check_Request__c(Case__c = testCases[2].ID, Payment_Verification__c = true,Check_Amount__c = 100, Mailing_Address_Verified__c = true, Payable_To_First_Name__c = 'First', Payable_To_Last_Name__c = 'Last', GL_Code__c = glCode.Id),
            new Check_Request__c(Case__c = testCases[3].ID, Payment_Verification__c = true,Check_Amount__c = 100, Mailing_Address_Verified__c = true, Payable_To_First_Name__c = 'First', Payable_To_Last_Name__c = 'Last', GL_Code__c = glCode.Id)
        };
        insert testChecks;

        List<CBB_Loader__c> testCBBs = new List<CBB_Loader__c> {
            new CBB_Loader__c(Successful__c = 'T', CBB_VIN_NUM__c = 'VIN01000010000101', CBB_SOLD_AMT__c = '1002.00', CBB_NUM__c = '1', CBB_SEQ_NUM__c = '1', CBB_DT_SOLD__c = '2012-12-21',
                             CBB_CA_FILE1__c = 'LGC1001', CBB_CA_FILE1_AMT__c = '1001.00', CBB_CHECK_ISSU_DT__c = '2012-10-01', 
                             CBB_CA_FILE2__c = 'LGC1002', CBB_CA_FILE2_AMT__c = '1002.00', CBB_CHECK_ISSU_DT2__c = '2012-10-02'),
            new CBB_Loader__c(Successful__c = 'T', CBB_VIN_NUM__c = 'VIN01000010000102', CBB_SOLD_AMT__c = '1003.00', CBB_NUM__c = '1', CBB_SEQ_NUM__c = '2', CBB_DT_SOLD__c = '2012-12-21',
                             CBB_CA_FILE1__c = 'LGC1001', CBB_CA_FILE1_AMT__c = '1001.00', CBB_CHECK_ISSU_DT__c = '2012-10-01', 
                             CBB_CA_FILE2__c = 'LGC1002', CBB_CA_FILE2_AMT__c = '1002.00', CBB_CHECK_ISSU_DT2__c = '2012-10-02', 
                             CBB_CA_FILE3__c = 'LGC1003', CBB_CA_FILE3_AMT__c = '1003.00', CBB_CHECK_ISSU_DT3__c = '2012-10-03'),
            new CBB_Loader__c(Successful__c = 'T', CBB_VIN_NUM__c = 'VIN01000010000103', CBB_SOLD_AMT__c = '2001.00', CBB_NUM__c = '2', CBB_SEQ_NUM__c = '1', CBB_DT_SOLD__c = '2012-12-21',
                             CBB_CA_FILE2__c = 'LGC2001', CBB_CA_FILE2_AMT__c = '2001.00', CBB_CHECK_ISSU_DT__c = '2012-11-01'),
            new CBB_Loader__c(Successful__c = 'T', CBB_VIN_NUM__c = 'VIN01000010000104', CBB_SOLD_AMT__c = '3001.00', CBB_NUM__c = '3', CBB_SEQ_NUM__c = '1', CBB_DT_SOLD__c = '2012-12-21',
                             CBB_CA_FILE1__c = 'LGC3001', CBB_CA_FILE1_AMT__c = '160000', CBB_CHECK_ISSU_DT__c = '2012-10-01')
        };
        insert testCBBs;
        
        Test.startTest();
        Batch_CBB_DataLoad batch = new Batch_CBB_DataLoad();
        batch.query = 'Select Id, Error_Message__c, Successful__c, ' + 
                             'CBB_YR_OF_VEH__c, ' + 
                             'CBB_VIN_NUM__c, ' + 
                             'CBB_VEH_MODEL_LINE__c, ' + 
                             'CBB_VEH_LOC__c, ' + 
                             'CBB_VEH_LOC_ZIP_CD__c, ' + 
                             'CBB_VEH_LOC_STATE__c, ' + 
                             'CBB_VEH_LOC_PHONE__c, ' + 
                             'CBB_VEH_LOC_DT__c, ' + 
                             'CBB_VEH_LOC_CITY__c, ' + 
                             'CBB_VEH_LOC_ADDR__c, ' + 
                             'CBB_VEH_DISP__c, ' + 
                             'CBB_VEH_DISP_DT__c, ' + 
                             'CBB_TITL_STATUS_DT__c, ' + 
                             'CBB_TITLE_STATUS__c, ' + 
                             'CBB_TITLE_LOC__c, ' + 
                             'CBB_TITLE_LOC_NM__c, ' + 
                             'CBB_TITLE_LOC_DT__c, ' + 
                             'CBB_TITLE_BRAND_DT__c, ' + 
                             'CBB_STATUS__c, ' + 
                             'CBB_STATUS_DT__c, ' + 
                             'CBB_STATE_SOLD__c, ' + 
                             'CBB_STATE_REPUR_IN__c, ' + 
                             'CBB_SOLD_AMT__c, ' + 
                             'CBB_SMM_ARRIVAL_DT__c, ' + 
                             'CBB_SEQ_NUM__c, ' + 
                             'CBB_RESP_REP__c, ' + 
                             'CBB_REPUR_AMT__c, ' + 
                             'CBB_REGION__c, ' + 
                             'CBB_NUM__c, ' + 
                             'CBB_NET_LOSS__c, ' + 
                             'CBB_MAND_VOLUNTARY__c, ' + 
                             'CBB_LEGL_REPUR_AMT__c, ' + 
                             'CBB_LEGL_CASE_FILE__c, ' + 
                             'CBB_LAST_UPDATE_TS__c, ' + 
                             'CBB_LAST_UPDATE_ID__c, ' + 
                             'CBB_DT_SOLD__c, ' + 
                             'CBB_DELETE_FLAG__c, ' + 
                             'CBB_DELAY_FLAG__c, ' + 
                             'CBB_DELAY_DT__c, ' + 
                             'CBB_DELAY_COMMENT__c, ' + 
                             'CBB_DAYS_TO_SOLD__c, ' + 
                             'CBB_DAYS_TO_GROUND__c, ' + 
                             'CBB_DAYS_IN_INV__c, ' + 
                             'CBB_DAS_VENDOR__c, ' + 
                             'CBB_DAS_VENDOR_DT__c, ' + 
                             'CBB_CUST_ZIP_CD__c, ' + 
                             'CBB_CUST_STATE__c, ' + 
                             'CBB_CUST_PHONE__c, ' + 
                             'CBB_CUST_MID_INIT__c, ' + 
                             'CBB_CUST_LAST_NM__c, ' + 
                             'CBB_CUST_FIRST_NM__c, ' + 
                             'CBB_CUST_CITY__c, ' + 
                             'CBB_CUST_ADDR2__c, ' + 
                             'CBB_CUST_ADDR1__c, ' + 
                             'CBB_CONTACT_TITLE__c, ' + 
                             'CBB_CONTACT_LNAME__c, ' + 
                             'CBB_CONTACT_FNAME__c, ' + 
                             'CBB_CHECK_ISSU_DT__c, ' + 
                             'CBB_CHECK_ISSU_DT3__c, ' + 
                             'CBB_CHECK_ISSU_DT2__c, ' + 
                             'CBB_CHANNEL_DESIG__c, ' + 
                             'CBB_CA_FILE3__c, ' + 
                             'CBB_CA_FILE3_AMT__c, ' + 
                             'CBB_CA_FILE2__c, ' + 
                             'CBB_CA_FILE2_AMT__c, ' + 
                             'CBB_CA_FILE1__c, ' + 
                             'CBB_CA_FILE1_AMT__c, ' + 
                             'CBB_ADJ_REPUR_AMT__c ' + 
                            'From CBB_Loader__c Where Successful__c = \'T\' Order by CBB_NUM__c, CBB_SEQ_NUM__c desc';
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Case> cases = [SELECT ID, Legacy_Case_Number__c,
                                (Select Sold_Amount__c, Sold_Date__c, Legacy_Reported_Date__c From Buybacks__r),
                                (Select Check_Amount__c, Issue_Date__c, Buyback__c From Check_Requests__r)
                            From Case
                            Where ID in: testCases];
        for (Case c : cases) {
            if (c.Legacy_Case_Number__c == 'CALGC1001') {
                System.assert(c.Buybacks__r[0].Sold_Amount__c == 1003);
                System.assert(c.Check_Requests__r[0].Check_Amount__c == 1001);
                System.assert(c.Buybacks__r[0].Legacy_Reported_Date__c.isSameDay(Date.newInstance(2012, 10, 01)));
            } else if (c.Legacy_Case_Number__c == 'CALGC1002') {
                System.assert(c.Buybacks__r[0].Sold_Date__c.isSameDay(Date.newInstance(2012, 12, 21)));
                System.assert(c.Check_Requests__r[0].Check_Amount__c == 1002);
                System.assert(c.Buybacks__r[0].Legacy_Reported_Date__c.isSameDay(Date.newInstance(2012, 10, 01)));
            } else if (c.Legacy_Case_Number__c == 'CALGC1003') {
                System.assert(c.Check_Requests__r[0].Check_Amount__c == 1003);
                System.assert(c.Buybacks__r[0].Legacy_Reported_Date__c.isSameDay(Date.newInstance(2012, 10, 01)));
            } else if (c.Legacy_Case_Number__c == 'CALGC3001') {
                System.debug(c.Check_Requests__r[0].Check_Amount__c);
                System.assert(c.Buybacks__r[0].Legacy_Reported_Date__c.isSameDay(Date.newInstance(2012, 10, 01)));
            }
        }
        
        List<CBB_Loader__c> cbbs = [Select Successful__c From CBB_Loader__c Where ID =: testCBBs];
        System.assert(cbbs[2].Successful__c == 'N');
        System.Debug(cbbs[3].Successful__c);
    }
}