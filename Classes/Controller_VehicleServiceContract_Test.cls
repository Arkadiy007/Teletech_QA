/**********************************************************************
Name: Controller_VehicleServiceContract_Test
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Tests the Apex class Controller_VehicleServiceContractComment.

Related Page : Controller_VehicleServiceContractComment 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 10/05/2011 Created                        
***********************************************************************/

@isTest
private class Controller_VehicleServiceContract_Test {
    private static final String VIN = '1N123456789012345';

    private static String personType;
    private static RecordType personTypeRT;
    private static Vehicle__c vehicle;
    private static Account acct;
    private static Vehicle_Service_Contract__c vsc;
    private static List<Generic_Text__c> lines;
    
    /* Insert Vehicle__c, Account, and Vehicle_Service_Contract__c needed for testing */
    public static void InitializeData() {
        personType = System.Label.AccRTMaritz;
        personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

        vehicle = new Vehicle__c(Vehicle_Identification_Number__c = VIN);
        insert vehicle;

        acct = new Account(Customer_Id__c = 'testId1', FirstName = 'Test', LastName = 'User1', RecordTypeId = personTypeRT.id);
        insert acct;

        vsc = new Vehicle_Service_Contract__c(Policy_Number__c = 'VSC12345', VIN__c = VIN, Vehicle_Id__c = vehicle.Id, Account_Id__c = acct.Id);
        insert vsc;
    }
    
    /* Test creating an initial line and then several additional lines */
    static testMethod void TestVSC_CreateLines() {
        System.debug('***** TestVSC_CreateLines *****');
        
        InitializeData();
        Test.startTest();

            // Initialize current page and set VSCId input on it
            PageReference objPageRef = Page.VehicleServiceContractComment;      
            Test.setCurrentPage(objPageRef);
            ApexPages.currentPage().getParameters().put('VSCId', vsc.id);
            
            // Initialize controller    
            Controller_VehicleServiceContractComment objController = new Controller_VehicleServiceContractComment();

            // Insert single comment line
            objController.newComments = 'Test Line 1';
            objController.doSaveCommentLines();
            
            // Ensure that the single comment line inserted properly
            lines = [select Id, Line_Number__c, Comment_Text__c from Generic_Text__c where VIN__c = :VIN];
            System.assert(lines.size() == 1);
            if (lines.size() == 1){
                System.assert(lines[0].Line_Number__c == 1);
                System.assert(lines[0].Comment_Text__c == 'Test Line 1');
            }
            
            // Re-initialize controller to get first inserted row as part of existing text
            objController = new Controller_VehicleServiceContractComment();
            
            // Insert 4 more comment lines which should be split as shown when inserted
            objController.newComments = 'Test Line 2\n' +
                                        '123456789012345678901234567890123456789012345678901234567890123456789012' +
                                        '34567890\n' +
                                        'Test Line 5';
            objController.doSaveCommentLines();
            
            // Ensure that the additional text was split and inserted as expected
            lines = [select Id, Line_Number__c, Comment_Text__c from Generic_Text__c where VIN__c = :VIN order by Line_Number__c];
            System.assert(lines.size() == 5);
            if (lines.size() == 5){
                System.assert(lines[0].Line_Number__c == 1);
                System.assert(lines[0].Comment_Text__c == 'Test Line 1');
                System.assert(lines[1].Line_Number__c == 2);
                System.assert(lines[1].Comment_Text__c == 'Test Line 2');
                System.assert(lines[2].Line_Number__c == 3);
                System.assert(lines[2].Comment_Text__c == '123456789012345678901234567890123456789012345678901234567890123456789012');
                System.assert(lines[3].Line_Number__c == 4);
                System.assert(lines[3].Comment_Text__c == '34567890');
                System.assert(lines[4].Line_Number__c == 5);
                System.assert(lines[4].Comment_Text__c == 'Test Line 5');
            }
        
        	objController.doCancel();
        Test.stopTest();
    }
}