@isTest
private class NCIAccountControllerTests
{
    private static User validUser {get; set;}
    private static User invalidUser {get; set;}

 @isTest
    static void controllerFieldsMustInitializeCorrectly22()
    {
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        
        System.assert(!accController.availableFields.isEmpty());
        System.assert(!accController.displayColumns.isEmpty());

            }
        Test.stopTest();
    }
    @isTest
    static void controllerFieldsMustInitializeCorrectly()
    {
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        System.assert(!accController.availableFields.isEmpty());
        System.assert(!accController.displayColumns.isEmpty());

            }
        Test.stopTest();
    }

    /*
    *   !Returning JSON from NCIAccountController contains 4 customers with firstname Jim
    *   @checks that if we call refresh() method it will call the getAccounts method, that get Accounts from customer rest 
    */
    @isTest
    static void refreshMethodMustGetAccounts(){
        Test.startTest();
        
        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();

        System.assert(!accController.Accounts.isEmpty());
        System.assertEquals(accController.Accounts.size(), 4);
        System.assertEquals(1, accController.pageNumber);

        }
        Test.stopTest();
    }
    @isTest
    static void checkupdateAccountTest(){
        CreateNewCusomerAccount2();
         NCIWebServiceSettings__c wss = new  NCIWebServiceSettings__c();
 wss.TimeoutSeconds__c = 5;
 insert wss;
        Test.startTest();
        
        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.Customer_Id='15060859';       
       accController.checkCustomerList();
        }
        Test.stopTest();
    }
        @isTest
    static void checkInsertAccountTest(){
        CreateNewCusomerAccount2();
         NCIWebServiceSettings__c wss = new  NCIWebServiceSettings__c();
 wss.TimeoutSeconds__c = 5;
 insert wss;
        Test.startTest();
        
        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.Customer_Id='15060860';       
       accController.checkCustomerList();
        }
        Test.stopTest();
    }
 private static Account CreateNewCusomerAccount2() {
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' and Name='NCI' AND IsPersonType = True limit 1];

        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.firstName = 'ALEGRIA';
        account.lastName = 'JIMENEZ';
        account.NCI_Customer_Id__c = '15060859';

        insert account;

        return account;
    }
    /*
    * @checks if user moveUp and moveDown selectOption - list don't change
    */
    @isTest
    static void moveUpAndmoveDown_ShouldNotChangeOrder(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        accController.moveValue = 'PersonEmail';
        List<System.SelectOption> oldSelCol = accController.selectedColumns;
        accController.moveUp();
        accController.moveDown();

        System.assertEquals(accController.selectedColumns, oldSelCol);

        }
        Test.stopTest();
    }

    /*
    * @checks if getFields return valid fieldNames
    */
    @isTest
    static void getFields_ShouldReturnValidStringList(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();

        Boolean isValid = false;

        for(String s: accController.getFields()){
            if(s.contains('PersonEmail')) isValid = true;
        }

        System.assert(isValid);
        }
        Test.stopTest();
    }

    /*
    * @checks if  getCustomFields return valid fieldNames
    */
    @isTest
    static void  getCustomFields_ShouldReturnValidStringList(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();

        Boolean isValid = false;

        for(String s: accController.getCustomFields()){
            if(s.contains('PersonMailingCountry')) isValid = true; // Customer_ID__c for example
        }

        System.assert(isValid);
        }
        Test.stopTest();
    }


    /*
    * @checks if customizeSearch and customizeDisplay sets controller fields to true 
    */
    @isTest
    static void customizeMethods_ShouldChangeControllerShowFieldsToTrue(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        
        accController.showAvailableColumns = false;
        accController.showAvailableFields = false;

        accController.customizeSearch();
        accController.customizeDisplay();

        System.assert(accController.showAvailableFields); // should be true
        System.assert(accController.showAvailableColumns);  // should be true
        }

        Test.stopTest();
    }

    /*
    * @checks searchParams methods(addSearchParam and addSearchParams) works correctly;
    */
    @isTest
    static void addSearchParams_ShouldChangeControllerSearchString(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        
        accController.addSearchParams();

        accController.addSearchParam('firstName', 'jim', 2, true);
        System.assert(accController.searchString.contains('firstName Like'));
        accController.searchString = ''; // for clear previous test case result;

        accController.addSearchParam('firstName', 'jim', 3, false);
        System.assert(accController.searchString.contains('firstName Like'));
        accController.searchString = ''; // for clear previous test case result;

        accController.addSearchParam('firstName', 'jim');
        System.assert(accController.searchString.contains('jim'));
        accController.searchString = ''; // for clear previous test case result;

        }

        Test.stopTest();
    }

    /*
    * @checks saveColumn method call the refresh method and inside of refresh initialSearch set to false;
    */
    @isTest
    static void saveColumns_ShouldCallRefreshMethod(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        accController.initialSearch = false;
        accController.saveColumns();

        System.assert(!accController.initialSearch); //should be true
        }
        Test.stopTest();
    }

    /*
    * @checks if clear method sets setCon to null
    */
    static void clear_ShouldDeleteSetCon(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();
        System.assertNotEquals(null, accController.setCon);

        accController.clear();
        System.assertEquals(accController.setCon, null);
        }
        Test.stopTest();
    }

    /*
    * TODO: add test methods to test it all
    */
    @isTest
    static void TemporarySmallMethodsTests(){
        Test.startTest();

        System.runAs(getUser(true)){
        Test.setCurrentPage(Page.AccountList);

        NCIAccountController accController = new NCIAccountController();
        accController.refresh();

        accController.searchPhone('4234227395');


        accController.sortCol();
        accController.saveSearch();
        accController.cancelSaveColumns();
        accController.cancelSaveSearch();

        Boolean test1 = accController.hasNext;
        test1 = accController.hasPrevious;

    
        accController.first();
        accController.last();
        accController.previous();
        accController.next();

        }
        Test.stopTest();
    }


    private static User getUser(boolean isValid){
        
        if(isValid){
            if(validUser == null){
                   Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
                   User u = new User(Alias = 'stasndt', Email='stadasndarduser@testorg.com', 
                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                   LocaleSidKey='en_US', ProfileId = p.Id, 
                   TimeZoneSidKey='America/Los_Angeles', UserName='standdasdsarduser@testorg.com');
                   insert u;

                   NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
                   accFields.SetupOwnerId = u.id;
                   accFields.Search_Field_1__c = 'LastName';
                   accFields.Search_Field_2__c = 'PersonHomePhone';
                   accFields.Search_Field_3__c = 'PersonEmail';
                   accFields.Search_Field_4__c = 'FirstName';
                   accFields.Search_Field_5__c = 'PersonMailingPostalCode';

                   accFields.Selected_Field_01__c = 'Name';
                   accFields.Selected_Field_02__c = 'PersonEmail';
                   accFields.Selected_Field_03__c = 'PersonHomePhone';
                   accFields.Selected_Field_04__c = 'PersonMailingCountry';
                   accFields.Selected_Field_05__c = 'PersonMailingState';
                   accFields.Selected_Field_06__c = 'PersonMailingPostalCode';

                   insert accFields;

                   validUser = u;
            }
                return validUser;
        }

        else{
            if(invalidUser == null){
                 Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
                   User u = new User(Alias = 'stsdasndt', Email='stadasndasdasrduser@testorg.com', 
                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                   LocaleSidKey='en_US', ProfileId = p.Id, 
                   TimeZoneSidKey='America/Los_Angeles', UserName='standdasdasdasdasdsarduser@testorg.com');
                   insert u;

                   NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
                   accFields.SetupOwnerId = u.id;

                   insert accFields;

                   invalidUser = u;

            }

            return invalidUser;
        }
    }


    
}