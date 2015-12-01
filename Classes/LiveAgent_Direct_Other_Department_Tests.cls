/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2015, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Tests for Controller used by the LiveAgent Direct Complete landing page

Class:              LiveAgent_Direct_Complete_Tests
Author:             Koseykina A.
Date:               1/20/2015
Version:            1.0
Last Updated:       1/20/2015
    * 1/20/2015    AK - Created
*/

@isTest
public class LiveAgent_Direct_Other_Department_Tests { 
    static testMethod void testSubmitForm()
    {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-23:00', Operation_Hours_Tuesday__c = '00:12-23:00',
            Operation_Hours_Wednesday__c = '00:12-23:00', Operation_Hours_Thursday__c = '00:12-23:00',
            Operation_Hours_Friday__c = '00:12-23:00', Operation_Hours_Saturday__c = '00:12-23:00',
            Operation_Hours_Sunday__c = '00:12-23:00', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        ApexPages.currentPage().getParameters().put('firstName', 'First');
        ApexPages.currentPage().getParameters().put('lastName', 'Last');
        ApexPages.currentPage().getParameters().put('zipCode', 'Zip');
        ApexPages.currentPage().getParameters().put('email', 'Email');
        ApexPages.currentPage().getParameters().put('phone', 'Phone');
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');
        LiveAgent_Direct_Other_Department lad = new LiveAgent_Direct_Other_Department();
        lad.firstName = 'FirstName';
        lad.emailAddress = 'example@example.com';
        lad.submitForm();
        System.assertEquals(lad.showErrorMessage, false);
    }

    static testMethod void testValidateData()
    {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-12:00', Operation_Hours_Tuesday__c = '00:12-12:00',
            Operation_Hours_Wednesday__c = '00:12-12:00', Operation_Hours_Thursday__c = '00:12-12:00',
            Operation_Hours_Friday__c = '00:12-12:00', Operation_Hours_Saturday__c = '00:12-12:00',
            Operation_Hours_Sunday__c = '00:12-12:00', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        ApexPages.currentPage().getParameters().put('firstName', 'First');
        ApexPages.currentPage().getParameters().put('lastName', 'Last');
        ApexPages.currentPage().getParameters().put('zipCode', 'Zip');
        ApexPages.currentPage().getParameters().put('email', 'Email');
        ApexPages.currentPage().getParameters().put('phone', 'Phone');
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');
        LiveAgent_Direct_Other_Department lad = new LiveAgent_Direct_Other_Department();
        System.assertEquals(lad.validateData(), false);
        lad.firstName = 'FirstName';
        lad.emailAddress = 'example@example.com';
        System.assertEquals(lad.validateData(), true);
    }

    static testMethod void testSavePreChatForm()
    {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-12:00', Operation_Hours_Tuesday__c = '00:12-12:00',
            Operation_Hours_Wednesday__c = '00:12-12:00', Operation_Hours_Thursday__c = '00:12-12:00',
            Operation_Hours_Friday__c = '00:12-12:00', Operation_Hours_Saturday__c = '00:12-12:00',
            Operation_Hours_Sunday__c = '00:12-12:00', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        ApexPages.currentPage().getParameters().put('firstName', 'First');
        ApexPages.currentPage().getParameters().put('lastName', 'Last');
        ApexPages.currentPage().getParameters().put('zipCode', 'Zip');
        ApexPages.currentPage().getParameters().put('email', 'Email');
        ApexPages.currentPage().getParameters().put('phone', 'Phone');
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');        

        LiveAgent_Direct_Other_Department lad = new LiveAgent_Direct_Other_Department();
        lad.firstName = 'FirstName';
        lad.emailAddress = 'example@example.com';

        lad.savePreChatForm(acc.Id);
        Pre_Chat_Data__c dataController = [SELECT ID, First_Name__c, Email_Address__c FROM Pre_Chat_Data__c WHERE AccountId__c = :acc.Id LIMIT 1];

        System.assertEquals(dataController.First_Name__c, 'FirstName');
        System.assertEquals(dataController.Email_Address__c, 'example@example.com');
    }


    static testMethod void testRetreiveDepValues(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-12:00', Operation_Hours_Tuesday__c = '00:12-12:00',
            Operation_Hours_Wednesday__c = '00:12-12:00', Operation_Hours_Thursday__c = '00:12-12:00',
            Operation_Hours_Friday__c = '00:12-12:00', Operation_Hours_Saturday__c = '00:12-12:00',
            Operation_Hours_Sunday__c = '00:12-12:00', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        ApexPages.currentPage().getParameters().put('firstName', 'First');
        ApexPages.currentPage().getParameters().put('lastName', 'Last');
        ApexPages.currentPage().getParameters().put('zipCode', 'Zip');
        ApexPages.currentPage().getParameters().put('email', 'Email');
        ApexPages.currentPage().getParameters().put('phone', 'Phone');
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');
        LiveAgent_Direct_Other_Department lad = new LiveAgent_Direct_Other_Department();
        lad.retrieveDepartmentValues('Test');
        System.assertEquals(lad.deploymentId, 'id');
        System.assertEquals(lad.bottomMessage, 'bottom');
        System.assertEquals(lad.afterHoursMessage, 'afterHours');
        System.assertEquals(lad.chatRecordTypeId, '012F0000000yJ4B');
    }

    static testMethod void testPrecompleteValuesWithParameters(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-12:00', Operation_Hours_Tuesday__c = '00:12-12:00',
            Operation_Hours_Wednesday__c = '00:12-12:00', Operation_Hours_Thursday__c = '00:12-12:00',
            Operation_Hours_Friday__c = '00:12-12:00', Operation_Hours_Saturday__c = '00:12-12:00',
            Operation_Hours_Sunday__c = '00:12-12:00', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        ApexPages.currentPage().getParameters().put('firstName', 'First');
        ApexPages.currentPage().getParameters().put('lastName', 'Last');
        ApexPages.currentPage().getParameters().put('zipCode', 'Zip');
        ApexPages.currentPage().getParameters().put('email', 'Email');
        ApexPages.currentPage().getParameters().put('phone', 'Phone');
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');
        Map<String, String> urlParameters = new Map<String,String>();
        urlParameters.put('firstName', 'First');
        urlParameters.put('lastName', 'Last');
        urlParameters.put('zipCode', 'Zip');
        urlParameters.put('email', 'Email');
        urlParameters.put('phone', 'Phone');
        urlParameters.put('errorCode', 'Error');
        LiveAgent_Direct_Other_Department lad = new LiveAgent_Direct_Other_Department();
        lad.precompleteValuesWithParameters(urlParameters);
        System.assertEquals(lad.firstName, 'First');
        System.assertEquals(lad.lastName, 'Last');
        System.assertEquals(lad.zipCode, 'Zip');
        System.assertEquals(lad.emailAddress, 'Email');
        System.assertEquals(lad.phone, 'Phone');
        System.assertEquals(lad.errorCode, 'Error');
    }

    static testMethod void testProcessParentSiteInformation(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-00:01', Operation_Hours_Tuesday__c = '00:12-00:01',
            Operation_Hours_Wednesday__c = '00:12-00:01', Operation_Hours_Thursday__c = '00:12-00:01',
            Operation_Hours_Friday__c = '00:12-00:01', Operation_Hours_Saturday__c = '00:12-00:01',
            Operation_Hours_Sunday__c = '00:12-00:01', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');

        LiveAgent_Direct_Complete ladc = new LiveAgent_Direct_Complete();
        ladc.parentSiteURL = 'http://www.nissanusa.com/';
        ladc.userIp = '001.001.001.001';
        ladc.redirectTime = DateTime.now();

        ladc.processParentSiteInformation();

        List<Afterhours_Connection_Data__c> acd = [SELECT Id, Department__c, Parent_Site_Name__c, User_Ip__c, Visit_Time__c FROM Afterhours_Connection_Data__c];

        System.assertNotEquals(acd[0], null); 
    }

    

  
    static testMethod void testSelectedDepartmentNotEqualsRoutingGroup(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        Contact cont = new Contact(Email = 'example@example.com', AccountId = acc.Id, LastName = 'LastName');
        insert cont;
                Department__c depart = new Department__c(Name = 'Department',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-00:01', Operation_Hours_Tuesday__c = '00:12-00:01',
            Operation_Hours_Wednesday__c = '00:12-00:01', Operation_Hours_Thursday__c = '00:12-00:01',
            Operation_Hours_Friday__c = '00:12-00:01', Operation_Hours_Saturday__c = '00:12-00:01',
            Operation_Hours_Sunday__c = '00:12-00:01', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test');
        insert depart;
        Department__c depart2 = new Department__c(Name = 'Department2',
            Chat_Button_Id__c = 'button1', Chat_Button_Id_P2__c = 'button2', Chat_Button_Id_P3__c = 'button3',
            Chat_Button_Id_Queue__c = 'buttonQueue', Chat_Window_Title__c = 'ChatWindow', Deployment_Id__c = 'id',
            Operation_Hours_Monday__c = '00:12-00:01', Operation_Hours_Tuesday__c = '00:12-00:01',
            Operation_Hours_Wednesday__c = '00:12-00:01', Operation_Hours_Thursday__c = '00:12-00:01',
            Operation_Hours_Friday__c = '00:12-00:01', Operation_Hours_Saturday__c = '00:12-00:01',
            Operation_Hours_Sunday__c = '00:12-00:01', Pre_Chat_Bottom_Message__c = 'bottom',
            After_Hours_Message__c = 'afterHours', Record_Type_Id__c = '012F0000000yJ4B', GMT_Offset__c = 'gmt', URL_Parameter_Name__c = 'Test2');
        insert depart2;
        
        ApexPages.currentPage().getParameters().put('routingGroup', 'Test');

        LiveAgent_Direct_Other_Department ladc = new LiveAgent_Direct_Other_Department();
        ladc.parentSiteURL = 'http://www.nissanusa.com/';
        ladc.userIp = '001.001.001.001';
        ladc.redirectTime = DateTime.now();

        //ladc.processParentSiteInformation();
        ladc.selectedDepartment = 'Test2';
        ladc.submitForm();
        ladc.savePreChatForm(ladc.accountId);

        //System.assertEquals(true, ladc.showErrorMessage);
    }

}