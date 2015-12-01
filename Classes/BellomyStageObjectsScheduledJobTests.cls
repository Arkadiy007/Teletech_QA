/**********************************************************************
  Name: NNAScheduledCheckDealerIntCertTests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Unit-tests for BellomyStageObjectsScheduledJob scheduled job
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/1/2015 Created
 ***********************************************************************/
@isTest
public class BellomyStageObjectsScheduledJobTests {
    
    private static Account testAcc {get; set;}
    private static Account testAccDealer {get; set;}

    static
    {
        prepareAccounts();
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForCA(){
        insert insertCase(true, 'test', '');
        insert insertCaseCategorizations(1);
        update updateAllCasesClosedDate();
        //insert insertComments(1);
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
    
        Test.startTest();
            Database.executeBatch(new BellomyStageObject_CACBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(1, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals([SELECT CaseNumber FROM Case LIMIT 1][0].CaseNumber, [SELECT Case_Number__c FROM StageBellomyCases__c LIMIT 1][0].Case_Number__c);
        System.AssertEquals([SELECT Type FROM Case LIMIT 1][0].Type, [SELECT Type__c FROM StageBellomyCases__c LIMIT 1][0].Type__c);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForCA_Bulk(){
        List<Case> casesToInsert = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                casesToInsert.add(insertCase(true, String.valueof(i), ''));
            }
        insert casesToInsert;
        insert insertCaseCategorizations(50);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(50, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObject_CACBatchJob(), 50);
        Test.stopTest();
        System.AssertEquals(50, [SELECT Count() FROM StageBellomyCases__c]);
    }
        
    @isTest
    static void BatchJobShouldProcessValidCaseForBellamy(){
        insert insertCase(true, 'test', '1');
        insert insertCaseCategorizations(1);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();
            Database.executeBatch(new BellomyStageObject_BTEBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(1, [SELECT Count() FROM StageBellomyCases__c]);
    }
    
    @isTest
    static void BatchJobShouldProcessValidCaseForBellamy_Bulk(){
        List<Case> casesToInsert = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                casesToInsert.add(insertCase(true, String.valueof(i), '1'));
            }
        insert casesToInsert;
        insert insertCaseCategorizations(50);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(50, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObject_BTEBatchJob(), 50);
        Test.stopTest();
        System.AssertEquals(50, [SELECT Count() FROM StageBellomyCases__c]);
    }
    
    @isTest
    static void BatchJobShouldProcessValidCaseForBellamyText(){
        insert insertCase(true, 'test', '2');
        insert insertComments(1);
        insert insertCaseCategorizations(1);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();
            Database.executeBatch(new BellomyStageObject_BTETBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(1, [SELECT Count() FROM StageBellomyCases__c]);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForBellamyText_Bulk(){
        List<Case> casesToInsert = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                casesToInsert.add(insertCase(true, String.valueof(i), '2'));
            }
        insert casesToInsert;
        insert insertComments(50);
        insert insertCaseCategorizations(50);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(50, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObject_BTETBatchJob(), 50);
        Test.stopTest();
        System.AssertEquals(50, [SELECT Count() FROM StageBellomyCases__c]);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForVCS(){
        insert insertCase(true, 'test', '3');
        insert insertComments(1);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();
            Database.executeBatch(new BellomyStageObjects_VCSBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(1, [SELECT Count() FROM StageBellomyCases__c]);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForVCS_Bulk(){
        List<Case> casesToInsert = new List<Case>();
            for(Integer i = 0; i < 100; i++){
                casesToInsert.add(insertCase(true, String.valueof(i), '3'));
            }
        insert casesToInsert;
        insert insertComments(100);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(100, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObjects_VCSBatchJob(), 200);
        Test.stopTest();
        System.AssertEquals(100, [SELECT Count() FROM StageBellomyCases__c]);
    }
    
    @isTest
    static void BatchJobShouldProcessValidCaseForGLCodes(){

        insert insertCheckRequests(1);
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();
            Database.executeBatch(new BellomyStageObject_CheckReqBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(1, [SELECT Count() FROM StageBellomyCases__c]);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForGLCodes_Bulk(){
    
        insert insertCheckRequests(100);
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObject_CheckReqBatchJob(), 200);
        Test.stopTest();
        System.AssertEquals(100, [SELECT Count() FROM StageBellomyCases__c]);
    }   
    
	 @isTest
    static void BatchJobShouldProcessValidCaseForVCST(){
        insert insertCase(true, 'test', '5');
        insert insertComments(1);
        insert insertCaseCategorizations(1);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(1, [SELECT Count() FROM Case]);
        Test.startTest();
            Database.executeBatch(new BellomyStageObjects_VCSTBatchJob(), 25);
        Test.stopTest();
        System.AssertEquals(2, [SELECT Count() FROM StageBellomyCases__c]);
    }

    @isTest
    static void BatchJobShouldProcessValidCaseForVCST_Bulk(){
        List<Case> casesToInsert = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                casesToInsert.add(insertCase(true, String.valueof(i), '5'));
            }
        insert casesToInsert;
        insert insertComments(50);
        update updateAllCasesClosedDate();
        System.AssertEquals(0, [SELECT Count() FROM StageBellomyCases__c]);
        System.AssertEquals(50, [SELECT Count() FROM Case]);
        Test.startTest();   
            Database.executeBatch(new BellomyStageObjects_VCSTBatchJob(), 50);
        Test.stopTest();
        System.AssertEquals(100, [SELECT Count() FROM StageBellomyCases__c]);
    }
    
    @isTest
    static void BatchToUpdateCasesAsExtracted(){
    	
        Case testCase = insertCase(true, 'test', '');
        insert testCase;
        List<Case_Categorization__c> caseComments = insertCaseCategorizations(1);
        insert caseComments;
        update updateAllCasesClosedDate();
        
        StageBellomyCases__c stg = new StageBellomyCases__c(Account_Name__c = testAcc.Id, Case_ID__c = testCase.Id, Category_Description__c = caseComments[0].Id);
        insert stg;    	
    	    	
        Test.startTest();        	
            Database.executeBatch(new Batch_StageBellomyExtracted(), 25);
        Test.stopTest();
        
        System.AssertEquals([SELECT Batch_Status__c FROM StageBellomyCases__c LIMIT 1][0].Batch_Status__c, 'Extracted');
    }
	    
    @isTest
    static void TestSchedule_Batch_StageBellomyExtracted(){
        Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('Test Batch_StageBellomyExtracted', CRON_EXP, new Batch_StageBellomyExtracted());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
     @isTest
    static void ScheduledJob_TestSchedulingIsWorking(){
        Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('TestZZZZZZZZ Bellomy Scheduled Job', CRON_EXP, new BellomyStageObjectsScheduledJob());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
    private static void prepareAccounts(){
        testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

        testAccDealer = new Account(Name = 'Test Ac2c3',
                                            Preferred_Dealer_Code__c = '987356123',
                                            RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer'),
                                            Dealer_Code__c = '12332231123',
                                            Internet_Certified__c = true);
        insert testAccDealer;

        List<Bellomy_Reports_Settings__c> reportSettings = new List<Bellomy_Reports_Settings__c>();
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='Bellomy Test Extract', Allow_Auto_Update__c=false, Data_Range_Field__c='ClosedDate', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='RecordType.Name IN (\'CA\', \'CA Closed Case\', \'CA Email Infiniti\', \'CA Email Nissan\') AND Channel_Designation_Code__c IN (\'\', \'Nissan\', \'Infiniti\')', Query_Filters_2__c='AND Owner.UserRole.Name NOT IN (\'CA DRT\', \'CA DRT Support\', \'CA DRT Support Team Lead\', \'CA DRT Team Lead\') AND Action_Code__c != \'NP4E\' AND Who_contacted_us__c = \'Consumer\''));
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='Bellomy Test Extract- Text', Allow_Auto_Update__c=false, Data_Range_Field__c='ClosedDate', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='RecordType.Name IN (\'CA\', \'CA Closed Case\', \'CA Email Infiniti\', \'CA Email Nissan\', \'T5\') AND Owner.UserRole.Name NOT IN (\'CA DRT\', \'CA DRT Support\', \'CA DRT Support Team Lead\')', Query_Filters_2__c='AND Who_contacted_us__c = \'Consumer\''));
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='Bellomy Test Extract-VCS', Allow_Auto_Update__c=false, Data_Range_Field__c='ClosedDate', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='RecordType.Name = \'VCS Support\' AND Channel_Designation_Code__c IN (\'Nissan\', \'Infiniti\') AND Owner.UserRole.Name NOT IN (\'CA DRT\', \'CA DRT Support\', \'CA DRT Support Team Lead\')', Query_Filters_2__c='AND Origin != \'Chat\' AND Who_contacted_us__c IN (\'Consumer\', \'Customer\')'));
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='Bellomy Test Extract-VCS Text', Allow_Auto_Update__c=false, Data_Range_Field__c='ClosedDate', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='RecordType.Name = \'VCS Support\' AND Channel_Designation_Code__c IN (\'Nissan\', \'Infiniti\') AND Owner.UserRole.Name NOT IN (\'CA DRT\', \'CA DRT Support\', \'CA DRT Support Team Lead\')', Query_Filters_2__c='AND Who_contacted_us__c IN (\'Consumer\', \'Customer\')'));
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='CA Categorizations', Allow_Auto_Update__c=false, Data_Range_Field__c='ClosedDate', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='RecordType.Name IN (\'CA\', \'CA Closed Case\', \'CA Email Infiniti\', \'CA Email Nissan\', \'T5\')', Query_Filters_2__c='AND Channel_Designation_Code__c IN (\'Nissan\', \'Infiniti\')'));
        reportSettings.add(new Bellomy_Reports_Settings__c(Name='Check/GL Codes-Bellomy', Allow_Auto_Update__c=false, Data_Range_Field__c='Date_Approved__c', Start_Date__c=System.now().addDays(-21) , End_Date__c=System.now().addDays(21), Offset__c =7 , Query_Filters__c='Status__c = \'Approved\'', Query_Filters_2__c='AND Case__r.Owner.UserRole.Name NOT IN (\'CA DRT\', \'CA DRT Support\', \'CA DRT Support Team Lead\')'));

        insert reportSettings;
    }

    // default report type is CA Categorizations
    private static Case insertCase(Boolean isValid, String i, String ReportType){
        Case testCase = new Case(Preferred_Dealer__c = testAccDealer.id,
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
                                 Work_Phone__c = '2212222',
                                 VIN__C = '12323'+i,
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Channel_Designation_Code__c = 'Nissan',
                                 Lead_Provider__c = 'Lead Provider',
                                 Who_called__c = 'Doctor Suicide',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');
        
        if(isValid){ //valid as CA Categorization Rec.
             testCase.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'T5');
        }
        else{
             testCase.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up');
        }

        if(ReportType == '1'){
            testCase.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'CA');
            testCase.Who_contacted_us__c = 'Consumer';
        }
        if(ReportType == '2'){
            testCase.Who_contacted_us__c = 'Consumer';
        }

        if(ReportType == '3'){
            testCase.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'VCS Support');
            testCase.Who_contacted_us__c = 'Customer';
        }

        if(ReportType == '4'){
            testCase.Status = 'Approved';
        }

		if (ReportType == '5'){
			testCase.RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'VCS Support');
			testCase.Who_contacted_us__c = 'Consumer';	
		}

        return testCase;
    }

    private static List<CaseComment> insertComments(Integer limitCase){
        List<CaseComment> caseComments = new List<CaseComment>();

        for (Case cs : [SELECT Id FROM Case LIMIT :limitCase])
        {
            CaseComment cComment = new CaseComment(ParentId = cs.id, CommentBody='Vasiliy');
            caseComments.add(cComment);
        }

        return caseComments;
    }

    private static List<Case_Categorization__c> insertCaseCategorizations(Integer limitCase){
        List<Case_Categorization__c> caseComments = new List<Case_Categorization__c>();

        for (Case cs : [SELECT Id FROM Case LIMIT :limitCase])
        {
            Case_Categorization__c cComment = new Case_Categorization__c(Case__c = cs.id, Category_Code__c='1');
            caseComments.add(cComment);
        }

        return caseComments;
    }

    private static List<Case> updateAllCasesClosedDate(){
        List<Case> casesToUpdate = new List<Case>();

        for(Case cs: [SELECT Id, ClosedDate FROM Case]){
            cs.Status = 'Closed';
            casesToUpdate.add(cs);
        }

        return casesToUpdate;
    }

    private static List<Check_Request__c> insertCheckRequests(Integer numberOfRecords){
        List<Check_Request__c> requests = new List<Check_Request__c>();

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;

        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '98765432109876543';
        insert vehicle;

        Case glCase = insertCase(true, 'test', '4');
        glCase.Status = 'Approved';
        glCase.Vehicle_Name__c = vehicle.Id;

        insert glCase;

        for (Integer i = 1; i <= numberOfRecords; i++){
            requests.add(new Check_Request__c(Case__c = glCase.Id, Status__c= 'Approved', Date_Approved__c = Date.today(), Check_Amount__c = i, Payable_To_Last_Name__c = 'Last'+String.valueOf(i), Payable_To_First_Name__c = 'First', Mailing_Address_Verified__c = true, GL_Code__c = glCode.Id, Payment_Verification__c  = true));
        }
        return requests;
    } 
 }