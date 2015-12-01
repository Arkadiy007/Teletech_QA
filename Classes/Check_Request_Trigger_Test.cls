/**********************************************************************
Name: Check_Request_Trigger_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Test Check_Request Trigger
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 2/21/2012 Created 
***********************************************************************/
@isTest
private class Check_Request_Trigger_Test {

    static testMethod void myUnitTest() {
        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        insert caseRec;
        
            Code__c concern = new Code__c(Type__c = 'Concern', Code__c = 'OA', Description__c = 'VEHICLE CONCERNS');
            Code__c category = new Code__c(Type__c = 'Category', Code__c = 'AA', Description__c = 'AUDIO/VIDEO/NAVI');
            Code__c subcategory = new Code__c(Type__c = 'Subcategory', Code__c = '136500', Description__c = 'STARTER');
            Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'ZA', Description__c = 'ACCESSORIES DISCREPANCY');
        Code__c rootcause = new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'RootCause', Description__c = 'RootCause');
        insert rootcause;
        
        List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
        Case_Categorization__c caseCat = new Case_Categorization__c();
        caseCat.Concern__c = concern.Id;
        caseCat.Category__c = category.Id;
        caseCat.Subcategory__c = subcategory.Id;
        caseCat.Symptom__c = symptom.Id;
        caseCat.Case__c = caseRec.Id;
        caseCats.add(caseCat);
        insert caseCats;
        
        caseRec.Status = 'Closed';
        caseRec.Special_Root_Cause_Closing_Code__c = rootcause.Id;
        update caseRec;
        
        Test.startTest();
        try {
            Check_Request__c testCheck = new Check_Request__c(Case__c = caseRec.Id, Check_Amount__c = 100, Payable_To_Last_Name__c = 'Last', Payable_To_First_Name__c = 'First', Mailing_Address_Verified__c = true, Payment_Verification__c = true);
            insert testCheck;
        } catch (Exception e) {
        
        }
        Test.stopTest();
    }

    static testMethod void TestFormAfterApproval() {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '98765432109876543';
        insert vehicle;
        
        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec.Vehicle_Name__c = vehicle.Id;
        insert caseRec;

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;

        Check_Request__c testCheck = new Check_Request__c(Case__c = caseRec.Id, Check_Amount__c = 100, Payable_To_Last_Name__c = 'Last', Payable_To_First_Name__c = 'First', Mailing_Address_Verified__c = true, GL_Code__c = glCode.Id, Payment_Verification__c  = true);
        insert testCheck;
            
        User u = new User(ID = '005A0000001Y7Ek');
        
        Test.startTest();
            system.runAs(u) {
                testCheck.Status__c = 'Not Submitted';
                update testCheck;
                testCheck.Status__c = 'Approved';
                update testCheck;
            }
        Test.stopTest();
    }

    static testMethod void TestFormAfterReject() {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '98765432109876543';
        insert vehicle;

        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec.Vehicle_Name__c = vehicle.Id;
        insert caseRec;

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;

        Test.startTest();
            Check_Request__c testCheck = new Check_Request__c(Case__c = caseRec.Id, Check_Amount__c = 100, Payable_To_Last_Name__c = 'Last', Payable_To_First_Name__c = 'First', Mailing_Address_Verified__c = true, GL_Code__c = glCode.Id, Payment_Verification__c = true);
            insert testCheck;
            
            testCheck.Status__c = 'Denied';
            update testCheck;
        Test.stopTest();
    }
    
    static testMethod void TestValidateState() {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Vehicle_Identification_Number__c = '98765432109876543';
        insert vehicle;

        Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec.Vehicle_Name__c = vehicle.Id;
        insert caseRec;

        Code__c glCode = new Code__c(Type__c = 'GL_Code', Code__c = 'TST99', Description__c = 'Test GL Code', Active__c=true);
        insert glCode;

        Test.startTest();
            Check_Request__c testCheck = new Check_Request__c(Case__c = caseRec.Id, Check_Amount__c = 100, Payable_To_Last_Name__c = 'Last', Payable_To_First_Name__c = 'First', Mailing_Address_Verified__c = true,
            												State__c = 'FF', GL_Code__c = glCode.Id, Payment_Verification__c = true);
            try{
            insert testCheck;
            }
            catch(Exception ex){
            	System.assert(ex.getMessage().contains(Label.State_Validation));
            }
            
        Test.stopTest();
    }
}