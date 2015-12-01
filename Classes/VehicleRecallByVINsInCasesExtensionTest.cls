@isTest
public class VehicleRecallByVINsInCasesExtensionTest{

    static testmethod void myUnit(){
    

        // Retrieve TECH LINE recordType
        String cccRtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('CCC').getRecordTypeId();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='CCC Manager' limit 1];
            
        User caDrtUser = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ZCA_Id__c = '123hj',
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
        
        insert caDrtUser;   
        
        Account acc = new Account();
        acc.Name = 'Test Account1234';
        Insert acc;
        System.runas(caDrtUser){
               
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name='3N1AB7AP3DL731620';
        vehicle.Make_Name__c = 'Nissan';
        vehicle.Model_Year__c = '2015';
        vehicle.Model_Line_Name__c = 'Altima';
        vehicle.In_Service_Date__c= Date.parse(Label.In_Service_Start_Date) ;
        insert vehicle;
        
        Case testCase = new Case();
        testCase.RecordTypeId = cccRtypeId;
        testCase.Critical_Status_Flag__c = true;
        testCase.DTS_Notification__c = true;
        testCase.Issue_Type__c = 'FULL';       
        testCase.AssignmentLevel__c = '5|DTS REQUEST SUBMITTED';
        testCase.Vehicle_name__c = vehicle.Id;
             
        insert(testCase);
       
        Test.startTest();
        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);
        VehicleRecallByVINsInCasesExtension inCasesExtn = new VehicleRecallByVINsInCasesExtension(controller);        
        Test.stopTest();
                
        if(Label.Show_JD_Power_Message == 'Yes'){        
             System.assert(inCasesExtn.showPowerCust);
        }else{
             System.assert(!inCasesExtn.showPowerCust);
        }    
        
        }      
       
    
    }
    
     static testmethod void f1dealerTest(){
    

        // Retrieve TECH LINE recordType
        String cccRtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('TECH LINE').getRecordTypeId();
        String dealerRtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='TECH LINE Agent' limit 1];
            
        User caDrtUser = new User(Alias = 'adminUT', Email = 'fake@fake.com', 
        EmailEncodingKey = 'UTF-8', LastName = 'CB_ADMIN__TMS_Testing', 
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ZCA_Id__c = '123hj',
        ProfileId = profile.Id, TimeZoneSidKey ='America/Los_Angeles', 
        UserName = 'CB_ADMIN__TMS_Testing@CB_ADMIN__TMS_Testing.com');
        
        insert caDrtUser;   
        
        Account acc = new Account();
        acc.Name = 'Test Account1234';
        acc.RecordTypeId = dealerRtypeId;
        acc.F1_Dealer__c = 'F1';
        Insert acc;
        System.runas(caDrtUser){
               
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name='3N1AB7AP3DL731620';
        vehicle.Make_Name__c = 'Nissan';
        vehicle.Model_Year__c = '2015';
        vehicle.Model_Line_Name__c = 'Altima';
        vehicle.Vehicle_identification_Number__c  = '3N1AB7AP3DL731620';
        vehicle.In_Service_Date__c= Date.parse(Label.In_Service_Start_Date) ;
        insert vehicle;
        
        Case testCase = new Case();
        testCase.RecordTypeId = cccRtypeId;
        testCase.Critical_Status_Flag__c = true;
        testCase.DTS_Notification__c = true;
        testCase.Issue_Type__c = 'FULL';       
        testCase.AssignmentLevel__c = '5|DTS REQUEST SUBMITTED';
        testCase.Vehicle_name__c = vehicle.Id;
        testCase.Dealer__c = acc.Id;    
        insert(testCase);
       
        Test.startTest();
        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);
        VehicleRecallByVINsInCasesExtension inCasesExtn = new VehicleRecallByVINsInCasesExtension(controller);        
        Test.stopTest();
                
        System.assert(inCasesExtn.showF1Dealer);  
        
        }      
       
    
    }

}