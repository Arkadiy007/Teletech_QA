@isTest
public class CaseCommentsExportTest {

 static testMethod void commentsExport() {
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
     
     Test.starttest();
     
     CaseCommentsExportController commntsExpo = new CaseCommentsExportController();
     commntsExpo.verbiageSearch = true;
     commntsExpo.fromCont.Birthdate = System.today().addMonths(-3);
     commntsExpo.toCont.Birthdate = System.today();
     commntsExpo.selectedVal = '['+rtId+']';
     commntsExpo.commVerbage = 'CVT, test';
     
     commntsExpo.submitJob();
     
     Test.stopTest();
 }
 
 static testMethod void commentsExportValidations() {
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
     
     Test.starttest();
     
     CaseCommentsExportController commntsExpo = new CaseCommentsExportController();
     commntsExpo.verbiageSearch = true;     
     commntsExpo.submitJob();
     commntsExpo.verbiageSearch = false;     
     commntsExpo.submitJob();
     Test.stopTest();
     
 }
 
 static testMethod void commentsExportusingCases() {
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
     
     Test.starttest();
     
     CaseCommentsExportController commntsExpo = new CaseCommentsExportController();
     commntsExpo.verbiageSearch = false; 
     commntsExpo.submitJob();
     System.assert(ApexPages.hasMessages());
     
     commntsExpo.caseNumbers = cases[0].CaseNumber +','+ cases[1].CaseNumber+','+cases[2].CaseNumber;   
     commntsExpo.submitJob();
    
     Test.stopTest();
     
     System.assert(ApexPages.hasMessages());
     
 }
  
}