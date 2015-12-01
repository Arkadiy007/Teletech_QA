@isTest
public class Batch_CommentsExport_DataLoad_Test {

    static testMethod void BatchCommentsExportWithVerbiage() {
         String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
         String rtId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
         
         List<Vehicle__c> testVehicles = new List<Vehicle__c>();
         testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
         insert testVehicles;
         
         Account acct = new Account(LastName = 'Test', RecordTypeId = personTypeRTId, PersonEmail = 'test@abc.org');
         insert acct;
            
         List<Case> cases = new List<Case>();
         for(Integer i=0; i< 5; i++){
           Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rtId);
            cases.add(c1); 
          }
                    
         insert cases;
       
         List<CaseComment> caseComments = new List<CaseComment>();
         for(Case cas : cases){
         CaseComment cc1 = new CaseComment();
         cc1.ParentId = cas.Id;
         cc1.CommentBody = 'ZYXABC CVT Test' + cas.Id;
         caseComments.add(cc1);
         }
         
         insert caseComments; 
         
        Test.startTest();
    
         Batch_CommentsExport_DataLoad batch = new Batch_CommentsExport_DataLoad();
         batch.query = 'Select Id, LastModifiedById, CreatedById, CaseNumber, VIN__c, Type, Model_Year__c, Model_Line__c, Contact.MailingState, CreatedDate, RecordType.Name, Contact.OtherState,'
                    + 'Model_Code__c, Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Vehicle_Name__r.In_Service_Date__c, Vehicle_Name__r.Engine_4_Code__c, Vehicle_Name__r.M_F_Plant__c, Vehicle_Name__c, Manufacturer_Date__c, '        
                    + '(Select Id, ParentId, CommentBody, CreatedDate, LastModifiedDate From CaseComments) From Case';
                    
         batch.verbiageFilter = 'CVT, test';
         batch.dateRangeFilter = '+Date.today().addYears(-1)) - Date.today()+';
         
         Database.executeBatch(batch);
    
        Test.stopTest();
        
         System.assert([Select Id from Case_Comment_Header__c].size() > 0);
         System.assert([Select Id from Case_Comment_Detail__c].size() > 0);
    
    }
    
    static testMethod void BatchCommentsExportWithCases() {
         String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
         String rtId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('CA').getRecordTypeId();
         
         List<Vehicle__c> testVehicles = new List<Vehicle__c>();
         testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
         insert testVehicles;
         
         Account acct = new Account(LastName = 'Test', RecordTypeId = personTypeRTId, PersonEmail = 'test@abc.org');
         insert acct;
            
         List<Case> cases = new List<Case>();
         for(Integer i=0; i< 5; i++){
           Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rtId);
            cases.add(c1); 
          }
                    
         insert cases;
       
         List<CaseComment> caseComments = new List<CaseComment>();
         for(Case cas : cases){
         CaseComment cc1 = new CaseComment();
         cc1.ParentId = cas.Id;
         cc1.CommentBody = 'ZYXABC CVT Test' + cas.Id;
         caseComments.add(cc1);
         }
         
         insert caseComments; 
         
         Test.startTest();
    
         Batch_CommentsExport_DataLoad batch = new Batch_CommentsExport_DataLoad();
         batch.query = 'Select Id, LastModifiedById, CreatedById, CaseNumber, VIN__c, Type, Model_Year__c, Model_Line__c, Contact.MailingState, CreatedDate, RecordType.Name, Contact.OtherState,'
                    + 'Model_Code__c, Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Vehicle_Name__r.In_Service_Date__c, Vehicle_Name__r.Engine_4_Code__c, Vehicle_Name__r.M_F_Plant__c, Vehicle_Name__c, Manufacturer_Date__c, '        
                    + '(Select Id, ParentId, CommentBody, CreatedDate, LastModifiedDate From CaseComments) From Case';
                    
                 
         Database.executeBatch(batch);
    
         Test.stopTest();
        
         System.assert([Select Id from Case_Comment_Header__c].size() > 0);
         System.assert([Select Id from Case_Comment_Detail__c].size() > 0);
    }

}