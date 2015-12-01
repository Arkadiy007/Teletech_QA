/*
  Page Title: NCIAccountController
  Author: Aaron Bessey
  Description: Controller Class to control the account search page for NCI
  Dependencies: Accounts Field Set(NCI Account Search Fields), Custom settings (NCI_Account_Fields), Custom Label (NCI_Accounts_Debugging)
  Create Date: 11/31/2014
  Last Update: 7/27/2015
  Updated By: William Taylor

  Revisions:
  AAB - Initial Creation
  AAB - 03/16/2015 - Updates to use NCI Customer Search Rest
  WT  - 07/27/2015 - Updates to integrate with the staging service.
 
*/

public with sharing class NCIAccountController {
    Public List<Case> vinCases {get; set;}
    Public List<Account> vinAccounts {get; set;}
    Public List<Vehicle_Ownership_History__c> vinVohs {get; set;}
    Public Vehicle__c tempVehicle {get; set;}
    Public Boolean vinSearch {get; set;}
    Public Boolean onlyvinSearch {get; set;}
    Public Boolean onlyCaseSearch {get; set;}
    Public Id returnedId {get; set;}
    Public Integer noOfRecords { get; set; }
    Public Integer noOfPages { get; set; }
    Public Integer size { get; set; }
    Public String accountName { get; set; }
    Public String phone { get; set; }
    Public String vin { get; set; }
    Public String casenumber {get; set;}
    Public String dealerNumber {get; set;}
   
    Public string postalcode { get; set; }
    Public Boolean recordsFound { get; set; }
    Public String oldSortField { get; set; }
    Public String queryString { get; set; }
    Public String whereString { get; set; }
    Public String searchString { get; set; }
    Public Boolean orSearch { get; set; }
    Public Boolean initialSearch { get; set; }
    Public Boolean showQuery { get; set; }
    Public List <Map <String, String > > lstColumns { get; set; }
    Public List <Map <String, String > > lstSearchFields { get; set; }
    Public Map <String, String > searchValues { get; set; }
    Public Boolean allowCustomize { get; set; }
    Public Boolean showAvailableFields { get; set; }
    Public Boolean showAvailableColumns { get; set; }
    Public List <String > searchChoices { get; set; }
    Public List <String > columnChoices { get; set; }
    Public List <String > columnChoicesOrder { get; set; }
    Public List <String > displayColumns { get; set; }
    Public NCI_Account_Fields__c ncisettings { get; set; }
    Public List <Customer > Accounts { get; set; }
    Public List <SelectOption > availableFields { get; set; }
    Public List <SelectOption > availableColumns { get; set; }
    Public List <SelectOption > selectedColumns { get; set; }
    Public String moveValue { get; set; }

    Public SObjectType accountType;
    Public Map <String, Schema.SObjectField > mfields;
    Public Map <String, String > fieldLabels { get; set; }
    Public Map <String, String > searchFieldLabels { get; set; }
RecordType personalAccRecordType;
    public SetCustomerClass setCon { get; set; }

    public String sortDir {
        get { return(sortDir == null) ? 'asc' : sortDir; }
        set;
    }

    // the current field to sort by. defaults to last name
    public String sortField {
        get { return(sortField == null) ? 'Name' : sortField; }
        set {
            oldSortField = sortField;
            sortField = value; }
    }
    public Class CustomerList
    {
        public List <Customer > customers { get; set; }
    }

    public Class Customer implements Comparable
    {
        public string firstName { get; set; }
        public string lastName { get; set; }
        public string name { get; set; }
        public string id { get; set; }
        public string Customer_Id { get; set; }
        public string trackingNumber { get; set; }
        
        public string PersonMailingStreet { get; set; }
        public string PersonMailingCity { get; set; }
        public string PersonMailingPostalCode { get; set; }
        public string PersonMailingState { get; set; }
        public string PersonMailingCountry { get; set; }
        public string PersonEmail { get; set; }
        public string PersonOtherPhone { get; set; }
        public string PersonHomePhone { get; set; }
        public string PersonMobilePhone { get; set; }
        public string Work_Phone { get; set; }
        public string sortField { get; set; }
        public string sortDir { get; set; }

        public Customer()
        {
            sortField = 'name';
            sortDir = 'asc';
        }

        public Customer(string sortField, string sortDir)
        {
            this.sortField = sortField;
            this.sortDir = sortDir;
        }

        public integer compareTo(Object compareTo)
        {
            Customer compareToCust = (Customer) compareTo;
            String JSONOrg = JSON.serialize(this);


            Map <String, Object > mOrg = (Map <String, Object >) JSON.deserializeUntyped(JSONOrg);
            String JSONComp = JSON.serialize(compareToCust);


            Map <String, Object > mComp = (Map <String, Object >) JSON.deserializeUntyped(JSONComp);

            String tmp = (String) mOrg.get(sortField);
            String tmp2 = (String) mComp.get(sortField);

            if (tmp == null && tmp2 != null) return 1;
            if (tmp != null && tmp2 == null) return - 1;
            if (tmp == null && tmp2 == null) return 0;


            if (sortDir == 'asc')
            {
                return tmp.compareTo(tmp2);
            }
            return tmp.compareTo(tmp2) * (- 1);

        }
    }
    public class SetCustomerClass {
        public integer pagenumber { get; set; }
        public integer totalpages { get; set; }
        public integer pagesize { get; set; }
        public list <Customer > customerList { get; set; }
        public SetCustomerClass(List <Customer > customerList, integer pagesize) {
            pagenumber = 1;
            this.pagesize = pagesize;
            this.customerList = customerList;
            totalpages = Integer.valueof(math.ceil((double) customerList.size() / (double) pagesize));
        }
        public void sortRecords(string columnName, string direction)
        {
            System.DEBUG('Inside of the sortRecords method');
            for (Customer c : customerList)
            {
                System.DEBUG('inside of for loop: ' + c);
                c.sortField = columnName;
                c.sortDir = direction;
            }
            customerList.sort();
        }
        public integer getPageNumber()
        {
            return pagenumber;
        }
        public integer getResultSize()
        {
            if (customerList == null)
            {
                return null;
            }
            return customerList.size();
        }
        public boolean gethasprevious() {
            return(pagenumber != 1);
        }
        public boolean gethasnext() {
            return(pagenumber != totalpages);
        }
        public pagereference Previous() {
            if (gethasprevious())
            pagenumber--;
            return null;
        }
        public pagereference next() {
            if (gethasnext())
            pagenumber++;
            return null;
        }

        public void first()
        {
            pagenumber = 1;
        }
        public void last()
        {
            pagenumber = totalpages;
        }
        public list <Customer > getRecords() {
            list <Customer > custList = new list <Customer > ();
            for (integer counter2 = (pagenumber - 1) * pagesize; counter2 <(math.min(pagenumber * pagesize, customerList.size())); counter2++) {
                custList.add(customerList.get(counter2));
            }
            return custList;
        }

    }

    Public NCIAccountController()
    {
        vinSearch = false;
        onlyvinSearch  = false;
        onlyCaseSearch = false;
        personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND Name='NCI' and IsPersonType = True limit 1];
        showQuery = Label.NCI_Accounts_Debugging == 'true' ? true : false;
        size = 10;
        queryString = '';
        searchString = '';
        whereString = '';
        orSearch = false;
        lstColumns = new List <Map <String, String > > ();
        accountType = Schema.getGlobalDescribe().get('Account');
        mfields = accountType.getDescribe().fields.getMap();
        searchValues = new Map <String, String > ();
        searchChoices = new List <String > ();
        columnChoices = new List <String > ();
        columnChoicesOrder = new List <String > ();
        availableFields = new List <SelectOption > ();
        availableColumns = new List <SelectOption > ();
        addSearchFields(getSearchFields());
        displayColumns = getDisplayColumns();
        allowCustomize = true;
        initialSearch = false;
        //selectedColumns = new List<SelectOption>();
        moveValue = '';
        fieldLabels = new Map <String, String > ();
        searchFieldLabels = new Map <String, String > ();
        getAvailableFields();
        PageReference tPR = updateColumns();


    }

    public List <Customer > searchAccounts()
    {
        addDataFields(BuildDisplayColumnsList());
        String searchResult;
        String responseJSON = '';
        List<Error_Log__c> errors = new List<Error_Log__c>();
       try {
       
            if (!Test.isRunningTest()) {
                if (vin != null && vin.length() > 0) {
                
                    System.debug('vin is set on search');
                    searchValues.put('vin',vin);
                    searchResult = NCI_CustomerWebService.getCustomerList(searchValues);
                     if (searchResult.length() > 0 && searchResult.indexOf('\"status\":\"error\",\"type\":\"error\",') == -1) {
                      
                        // search vehicle by vin, return in separate content block 
                       
                        Schema.SObjectField f = Vehicle__c.Fields.Vehicle_identification_Number__c;
                        tempVehicle = new Vehicle__c(Name=vin,Vehicle_identification_Number__c=vin);
                        Database.UpsertResult ur = database.upsert(tempVehicle,f,false);
                        system.debug(ur.id);
                        if (ur.isSuccess()) {
                        onlyvinSearch = true;
                                
                        }
                        
                       }

                    
                 } else {
                 
                    searchResult = NCI_CustomerWebService.getCustomerList(searchValues);
                 
                 }
            }
            else {
                searchResult = '{"type":"Response","status":"success","result":{"message":"test message","code":200},"requestId":1234567890,"customers":[{"trackingInfo":[{"trackingNumber":"001M000000dm0M2IAI","source":"SFDC","activeIndicator":true}],"personalInfoUpdatedTimestamp":"2015-03-31T05:22:04.000Z","lastname":"MOTTERN","firstname":"JIM","customerTypeCode":"0","customerNumber":5468479,"contactInfo":{"updatedTimeStamp":"2015-03-31T05:22:04.000Z","preferredContactMethodCode":1,"phone":[{"type":"HOME","phoneNumber":4234227395,"extension":null}],"emailAddress":[{"primary":true,"email":"test@test.com"}]},"consentInfo":[{"contactMethod":"DEALER","consentType":"INFINITI","consentFlag":true,"collectedTimestamp":"2015-03-31T05:22:04.000Z","collectedBy":"SDIG"}],"addressInfo":{"validAddressIndicator":true,"updatedTimestamp":"2015-03-31T05:22:04.000Z","freeformAddress":{"address3":"Midway TN USA","address2":"","address1":""},"addressOverride":false,"address":{"zipCode":"","streetType":null,"streetNumberSuffix":null,"streetNumber":"","streetName":"","streetDirection":null,"routeNumber":null,"province":"TN","postalCode":null,"deliveryQualifier":null,"deliveryMode":null,"country":"USA","city":"Midway","boxNumber":null,"apartmentNumber":null}}},{"trackingInfo":[{"trackingNumber":"001M000000dm0RbIAI","source":"SFDC","activeIndicator":true}],"personalInfoUpdatedTimestamp":"2015-03-30T12:26:37.000Z","lastname":"WILDAY","firstname":"JIM","customerTypeCode":"0","customerNumber":1234567,"contactInfo":{"updatedTimeStamp":"2015-03-30T12:26:37.000Z","preferredContactMethodCode":1,"phone":[],"emailAddress":[{"primary":true,"email":"wildays@hotmail.com.qa"}]},"consentInfo":[{"contactMethod":"MAIL","consentType":"NISSAN","consentFlag":true,"collectedTimestamp":"2015-03-30T12:26:37.000Z","collectedBy":"SDIG"}],"addressInfo":{"validAddressIndicator":true,"updatedTimestamp":"2015-03-30T12:26:37.000Z","freeformAddress":{"address3":"Taylors SC USA 29687-6401","address2":"Apple Jack Ln","address1":"15"},"addressOverride":false,"address":{"zipCode":"29687-6401","streetType":"Ln","streetNumberSuffix":null,"streetNumber":"15","streetName":"Apple Jack","streetDirection":null,"routeNumber":null,"province":"SC","postalCode":null,"deliveryQualifier":null,"deliveryMode":null,"country":"USA","city":"Taylors","boxNumber":null,"apartmentNumber":null}}},{"trackingInfo":[{"trackingNumber":"001M000000dm0UiIAI","source":"SFDC","activeIndicator":true}],"personalInfoUpdatedTimestamp":"2015-03-17T18:29:18.000Z","lastname":"MCGAHA","firstname":"JIMMY","customerTypeCode":"0","customerNumber":5471637,"contactInfo":{"updatedTimeStamp":"2015-03-17T18:29:18.000Z","preferredContactMethodCode":1,"phone":[{"type":"HOME","phoneNumber":4236235418,"extension":null},{"type":"MOBILE","phoneNumber":8657892843,"extension":null}],"emailAddress":[{"primary":true,"email":"jimpam_mcghee@msn.com.qa"}]},"consentInfo":[{"contactMethod":"DEALER","consentType":"DEALER","consentFlag":true,"collectedTimestamp":"2015-03-17T18:29:18.000Z","collectedBy":"SDIG"}],"addressInfo":{"validAddressIndicator":true,"updatedTimestamp":"2015-03-17T18:29:18.000Z","freeformAddress":{"address3":"DEL RIO US","address2":"25 70","address1":"HIGHWAY"},"addressOverride":false,"address":{"zipCode":"","streetType":"70","streetNumberSuffix":null,"streetNumber":"HIGHWAY","streetName":"25","streetDirection":null,"routeNumber":null,"province":"","postalCode":null,"deliveryQualifier":null,"deliveryMode":null,"country":"US","city":"DEL RIO","boxNumber":null,"apartmentNumber":null}}},{"trackingInfo":[{"trackingNumber":"001M000000dm0WNIAY","source":"SFDC","activeIndicator":true}],"personalInfoUpdatedTimestamp":"2013-11-25T05:11:45.000Z","lastname":"SANDERS","firstname":"JIMMY","customerTypeCode":"0","customerNumber":5526528,"contactInfo":{"updatedTimeStamp":"2013-11-25T05:11:45.000Z","preferredContactMethodCode":1,"phone":[],"emailAddress":[{"primary":true,"email":null}]},"consentInfo":[{"contactMethod":"DEALER","consentType":"DEALER","consentFlag":true,"collectedTimestamp":"2013-11-25T05:11:45.000Z","collectedBy":"SDIG"}],"addressInfo":{"validAddressIndicator":true,"updatedTimestamp":"2013-11-25T05:11:45.000Z","freeformAddress":{"address3":"Artesia USA 39736-0021","address2":"Box 21","address1":"PO"},"addressOverride":false,"address":{"zipCode":"39736-0021","streetType":"21","streetNumberSuffix":null,"streetNumber":"PO","streetName":"Box","streetDirection":null,"routeNumber":null,"province":"","postalCode":null,"deliveryQualifier":null,"deliveryMode":null,"country":"USA","city":"Artesia","boxNumber":null,"apartmentNumber":null}}}]}}';
            }
            if (NCI_Account_Fields__c.getValues(System.UserInfo.getUserId()) == null) {
                insertSearchDefaults(System.UserInfo.getUserId());
            }
            System.debug('search result');
            System.debug(searchResult);
            if (searchResult.length() > 0) {
               if (searchResult.indexOf('\"status\":\"error\",\"type\":\"error\",') != -1) {
                      System.debug('found that this is an error... will not try to parse out. gonna error diff.');
                      NCICustomerDetailRest.CustomerDetailErrorHandler cde = (NCICustomerDetailRest.CustomerDetailErrorHandler) Json.deserialize(searchResult, NCICustomerDetailRest.CustomerDetailErrorHandler.Class);
                      String msg = 'There was a problem searching for this record.';
                      if (cde.result != null && cde.result.code != null) {
                        msg = returnErrorMessage(String.valueOf(cde.result.code));
                        errors.add(new Error_Log__c(Record_ID__c = Customer_Id,
                                        Record_Type__c = 'NCI Account', 
                                        Error_Message__c = msg, 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'NCIAccountController Search', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
                      }
                      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,msg));
                      if (!errors.isEmpty()) {
                        // Insert rows
                        Database.SaveResult[] dbResults = Database.insert(errors, false);
                      }
                      return null;
                 
               }
           }
            
            
            
            NCICustomerSearchRest.CustomerListHandler clh = (NCICustomerSearchRest.CustomerListHandler) Json.deserialize(searchResult, NCICustomerSearchRest.CustomerListHandler.Class);

            List <Customer > customers = new List <Customer > ();
            Customer cust;
            for (NCICustomerSearchRest.CustomerHandler ch : clh.customers)
            {
                cust = new Customer(sortField, sortDir);
                cust.name = ch.firstName + ' ' + ch.lastName;
                cust.firstName = ch.firstName;
                cust.lastName = ch.lastName;
                //cust.id = ch.trackinginfo[0].trackingNumber;
                cust.Customer_Id = String.valueOf(ch.customerNumber);
                cust.trackingNumber = String.valueOf(ch.trackingNumber);
                cust.PersonMailingStreet = ch.addressInfo.address.streetName;
                cust.PersonMailingCity = ch.addressInfo.address.city;
                cust.PersonMailingPostalCode = ch.addressInfo.address.postalcode;
                cust.PersonMailingState = ch.addressInfo.address.province;
                cust.PersonMailingCountry = ch.addressInfo.address.country;
                cust.PersonEmail = ch.contactInfo.emailAddress[0].email;
                for (NCICustomerSearchRest.PhoneHandler ph : ch.contactInfo.phone) {
                    if (ph.type == 'HOME') {
                        cust.PersonHomePhone = String.valueOf(ph.phonenumber);
                    }
                    else if (ph.type == 'MOBILE') {
                        cust.PersonMobilePhone = String.valueOf(ph.phonenumber);
                    }
                    else if (ph.type == 'WORK') {
                        cust.Work_Phone = String.valueOf(ph.phonenumber);
                    }
                }
                
             
                
                
                
                customers.add(cust);
            }

            customers.sort();
            return customers;
        }
        catch(Exception ex) {
            System.debug('error occurred');
            System.debug(ex);
            
            errors.add(new Error_Log__c(Record_ID__c = Customer_Id,
                                        Record_Type__c = 'NCI Account', 
                                        Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'NCIAccountController Search System Error', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
            String msg = 'There was a system problem searching for this record.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,msg));
            if (!errors.isEmpty()) {
            // Insert rows
                    Database.SaveResult[] dbResults = Database.insert(errors, false);
            }
            // In case when there is a problem parsing JSON, or callout failed, we will show standard error message, that we failed to find customer.
            return new List <Customer > ();
        }
    }

    private List <String > BuildDisplayColumnsList() {
        List <String > result = new List <String > ();

        for (String displayStr : displayColumns) {
            result.add(displayStr);
        }

        return result;
    }

    public PageReference moveUp()
    {
        if (moveValue == null || moveValue == '')
        {
            return null;
        }
        List <SelectOption > newOptions = new List <SelectOption > ();
        SelectOption so;
        integer size = selectedColumns.size();
        Integer i;
        for (i = size - 1; i >= 0; i--)
        {
            so = selectedColumns[i];
            if (so.getValue() == moveValue && i > 0)
            {
                newOptions.add(selectedColumns[i - 1]);
                newOptions.add(so);
                i--;
            }
            else
            {
                newOptions.add(so);
            }
        }

        selectedColumns = new List <SelectOption > ();
        columnChoicesOrder = new List <String > ();
        size = newOptions.size();
        for (i = size - 1; i >= 0; i--)
        {
            so = newOptions[i];
            selectedColumns.add(so);
            columnChoicesOrder.Add(so.getValue());
        }

        return null;
    }
    public PageReference moveDown()
    {
        if (moveValue == null || moveValue == '')
        {
            return null;
        }
        List <SelectOption > newOptions = new List <SelectOption > ();
        SelectOption so;
        integer size = selectedColumns.size();
        Integer i;
        for (i = 0; i <size; i++)
        {
            so = selectedColumns[i];
            if (so.getValue() == moveValue && i <size - 1)
            {
                newOptions.add(selectedColumns[i + 1]);
                newOptions.add(so);
                i++;
            }
            else
            {
                newOptions.add(so);
            }
        }

        selectedColumns = new List <SelectOption > ();
        columnChoicesOrder = new List <String > ();
        for (i = 0; i <size; i++)
        {
            so = newOptions[i];
            selectedColumns.add(so);
            columnChoicesOrder.Add(so.getValue());
        }

        return null;
    }



    public string searchPhone(String inputPhone)
    {
        if (inputPhone == null || inputPhone.length() == 0)
        {
            return '';
        }

        inputPhone = inputPhone.replaceAll('[^0-9]', '');

        String newPhone = '';
        Integer len = inputPhone.length();

        if (len <= 3)
        {
            return inputPhone;
        }
        else if (len <7)
        {
            newPhone = inputPhone.mid(0, 3) + '%' + inputPhone.substring(3);
        }
        else if (len <= 10)
        {
            newPhone = inputPhone.mid(0, 3) + '%' + inputPhone.mid(3, 3) + '%' + inputPhone.substring(6);
        }
        else
        {
            newPhone = inputPhone.mid(0, 1) + '%' + inputPhone.mid(1, 3) + '%' + inputPhone.mid(4, 3) + '%' + inputPhone.substring(7);
        }

        return newPhone;

    }

    public void addDataFields(List <String > fields) // adds columns for search result
    {
        List <String > lfields = new List <String > (fields);
        queryString = 'Select ' + String.join(lfields, ', ') + ' from Account';
        lstColumns = new List <Map <String, String > > ();

        Schema.SObjectField field;
        Schema.DescribeFieldResult dfr;
        Map <String, String > column;
        for (String name : fields)
        {
            if (name == 'Id')
            {
                continue;
            }
            field = mfields.get(name);
            dfr = field.getDescribe();
            column = new Map <String, String > ();
            column.put('name', name);
            column.put('label', dfr.getLabel());
            if (dfr.isNameField())
            {
                column.put('namefield', 'true');
            }
            else
            {
                column.put('namefield', 'false');
            }
            lstColumns.add(column);

        }
    }

    public void addSearchFields(List <String > fields)
    {
        lstSearchFields = new List <Map <String, String > > ();

        Schema.SObjectField field;
        Schema.DescribeFieldResult dfr;
        Map <String, String > column;
        for (String name : fields)
        {
            field = mfields.get(name);
            dfr = field.getDescribe();
            column = new Map <String, String > ();
            column.put('name', name);
            column.put('label', dfr.getLabel());
            column.put('type', String.valueOf(dfr.getType()));

            lstSearchFields.add(column);
            searchValues.put(name, '');

        }
    }
    public String formatDate(String sdate)
    {
        Date newDate = Date.parse(sdate);
        return String.valueOf(newDate);
    }
    public void addSearchParams()
    {
        String name;
        String type;

        for (Map <String, String > field : lstSearchFields)
        {
            name = field.get('name');
            type = field.get('type');

            if (name == 'Name' || name == 'FirstName' || name == 'LastName')
            {
                addSearchParam(name, searchValues.get(name), 2);
            }
            else
            {
                if (type == 'PHONE')
                {
                    addSearchParam(name, searchPhone(searchValues.get(name)), 2);
                }
                else if (type == 'STRING')
                {
                    addSearchParam(name, searchValues.get(name), 3);
                }
                else if (type == 'DATE')
                {
                    addSearchParam(name, formatDate(searchValues.get(name)));
                }
                else
                {
                    addSearchParam(name, searchValues.get(name));
                }
            }
        }
        /*

          addSearchParam('Phone', searchPhone(phone), 3);
          addSearchParam('BillingPostalCode', postalcode, 3, null); */
    }

    public void addSearchParam(String fieldName, String value, Integer minCharacters, Boolean isOr)
    {
        if (value == null || value.length() == 0)
        {
            return;
        }

        whereString = (whereString.length() == 0 && value.length() > 0) ? ' where' : whereString;
        integer length = value.length();
        if (isOr == false)
        {
            searchString += searchString.length() > 0 ? ' and ' : ' ';
            searchString += fieldName + ' Like \'';
            searchString += length > minCharacters ? '%' : '';
            searchString += value + '%\'';
        }
        else
        {
            searchString += searchString.length() > 0 && orSearch ? ' or ' : ' ';
            orSearch = true;
            searchString += fieldName + ' Like \'';
            searchString += length > minCharacters ? '%' : '';
            searchString += value + '%\'';
        }
    }

    public void addSearchParam(String fieldName, String value, Integer minCharacters)
    {
        addSearchParam(fieldName, value, minCharacters, false);
    }

    public void addSearchParam(String fieldName, String value)
    {
        if (value == null || value.length() == 0)
        {
            return;
        }

        whereString = (whereString.length() == 0 && value.length() > 0) ? ' where' : whereString;
        integer length = value.length();
        searchString += searchString.length() > 0 && orSearch ? ' or ' : ' ';
        orSearch = true;
        searchString += fieldName + ' = ' + value;
    }

    public void getAvailableFields() {
        List <Schema.FieldSetMember > fields = SObjectType.Account.FieldSets.NCI_Account_Search_Results_Fields.getFields();
        String fieldPath;
        for (Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            fieldLabels.put(fieldPath, field.getLabel());
        }

        fields = SObjectType.Account.FieldSets.NCI_Account_Search_Fields.getFields();
        for (Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            searchFieldLabels.put(fieldPath, field.getLabel());
        }
    }

    public List <String > getCustomFields()
    {
        List <Schema.FieldSetMember > fields = SObjectType.Account.FieldSets.NCI_Account_Search_Results_Fields.getFields();
        List <String > ofields = new List <String > ();

        ncisettings = NCI_Account_Fields__c.getValues(System.UserInfo.getUserId()); //getOrgDefaults();
        Set<String> userFields = new Set<String> ();
        Set<String> requiredFields = new Set<String> ();
        requiredFields.addAll('Id,Name'.split(','));

        String compare;
        String prefix = 'Selected_Field_';
        for (Integer i = 1; i <= 15; i++)
        {
            compare = i <10 ? prefix + '0' + i + '__c' : prefix + i + '__c';
            if (ncisettings.get(compare) != null)
            {
                userFields.Add(String.valueOf(ncisettings.get(compare)));
            }
        }

        String fieldPath;
        for (Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            if (requiredFields.contains(fieldPath) || userFields.contains(fieldPath))
            {
                ofields.Add(fieldPath);
            }
        }

        return ofields;

    }

    public List <String > getDisplayColumns()
    {
        List <Schema.FieldSetMember > fields = SObjectType.Account.FieldSets.NCI_Account_Search_Results_Fields.getFields();
        List <String > ofields = new List <String > ();

        ncisettings = NCI_Account_Fields__c.getValues(System.UserInfo.getUserId()); //getOrgDefaults();
        if (ncisettings == null)
        {
              // insert new ncisettings for this user
             NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
             accFields.SetupOwnerId = System.UserInfo.getUserId();
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
            
             ncisettings = accFields;
        }
        Set<String> userFields = new Set<String> ();
        Set<String> requiredFields = new Set<String> ();
        //requiredFields.add('Name');

        String fieldPath;
        SelectOption so;
        Set<String> reserved = new Set<String> ();
        reserved.add('Id');
        String label;

        String compare;
        String prefix = 'Selected_Field_';
        String value;

        Map <String, String > fieldLabels = new Map <String, String > ();
        for (Schema.FieldSetMember field : fields)
        {
            fieldLabels.put(field.getFieldPath(), field.getLabel());
        }
        //Updated for Item 9:  “First Name” should always be displayed in the Search Results column
        Boolean isFirstNameSelected = false;


        for (Integer i = 1; i <= 15; i++)
        {
            if (i <10)
            {
                compare = (prefix + '0') + i + '__c';
            }
            else
            {
                compare = prefix + i + '__c';
            }
            value = String.valueOf(ncisettings.get(compare));
            if (value != null)
            {
                userFields.Add(value);
                columnChoices.Add(value);
                columnChoicesOrder.Add(value);

                so = new SelectOption(value, fieldLabels.get(value));
                reserved.Add(value);
                if (requiredFields.contains(value))
                {
                    so.setDisabled(true);
                }
                availableColumns.Add(so);

                if(value == 'FirstName'){
                    isFirstNameSelected = true;
                }
            }
        }


        for (Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            label = field.getLabel();
            if (!reserved.contains(fieldPath))
            {
                so = new SelectOption(fieldPath, label);
                reserved.Add(fieldPath);
                if (requiredFields.contains(fieldPath))
                {
                    so.setDisabled(true);
                }
                availableColumns.Add(so);
            }

            if(availableColumns.isEmpty()){
                SelectOption soption = new SelectOption('FirstName', 'First Name');
            }

            if (requiredFields.contains(fieldPath) || userFields.contains(fieldPath))
            {
                ofields.Add(fieldPath);
            }
        }

        return ofields;

    }

    public List <String > getSearchFields()
    {
        List <Schema.FieldSetMember > fields = SObjectType.Account.FieldSets.NCI_Account_Search_Fields.getFields();
        List <String > ofields = new List <String > ();

        ncisettings = NCI_Account_Fields__c.getValues(System.UserInfo.getUserId()); //.getOrgDefaults();
        
        if (ncisettings == null) {
            // insert new ncisettings for this user
             NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
             accFields.SetupOwnerId = System.UserInfo.getUserId();
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
            
             ncisettings = accFields;
             
        }
        
        Set<String> userFields = new Set<String> ();
        Set<String> requiredFields = new Set<String> ();
        requiredFields.add('Name');
        System.DEBUG(ncisettings);
        System.DEBUG(System.UserInfo.getUserId());
        String compare;
        String prefix = 'Search_Field_';
        for (Integer i = 1; i <= 6; i++)
        {
            compare = prefix + i + '__c';
            if (ncisettings.get(compare) != null)
            {
                userFields.Add(String.valueOf(ncisettings.get(compare)));
                searchChoices.Add(String.valueOf(ncisettings.get(compare)));
            }
        }


        String fieldPath;
        SelectOption so;
        Set<String> reserved = new Set<String> ();
        reserved.addAll('Id,Name'.split(','));
        String label;
        for (Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            label = field.getLabel();
            if (!reserved.contains(fieldPath))
            {
                so = new SelectOption(fieldPath, label);
                reserved.Add(fieldPath);
                availableFields.Add(so);
            }

            if (requiredFields.contains(fieldPath) || userFields.contains(fieldPath))
            {
                ofields.Add(fieldPath);
            }
        }

        
        return ofields;

    }

public static void insertSearchDefaults(String userId)

        {  
             NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
             accFields.SetupOwnerId = userId;
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
        }


    public List <String > getFields()
    {
        List <String > fieldNames = new List <String > ();
        List <Schema.FieldSetMember > fields = SObjectType.Account.FieldSets.NCI_Account_Search_Results_Fields.getFields();
        for (Schema.FieldSetMember f : fields) {
            fieldNames.Add(f.getFieldPath());
        }

        return fieldNames;
    }



    /*public ApexPages.StandardSetController setCon {
      get{
      if(setCon == null){
      if(size==null)
      {
      size = 10;
      sortField = 'Name';
      sortDir = 'Asc';
      }

      addDataFields(displayColumns);

      whereString = '';
      searchString = '';
      orSearch = false;

      addSearchParams();

      queryString += whereString + searchString;


      if(vin!=null && vin.length()>0)
      {
      List<String> ids = new List<String>();
      List<Vehicle_Ownership_History__c> vohs = [select Owner__c from Vehicle_Ownership_History__c where VIN__c=:vin];
      if(vohs!=null && vohs.size()>0)
      {
      for(Vehicle_Ownership_History__c voh : vohs)
      {
      ids.Add('\'' + voh.Owner__c + '\'');
      }

      if(whereString.length()==0)
      {
      queryString += ' where';
      }
      if(searchString.length()>0)
      {
      queryString += ' and';
      }
      queryString += ' Id in (' + String.join(ids,',') + ')';
      }
      }

      queryString += ' order by ' + sortField + ' ' + sortDir + ' NULLS LAST Limit 1000';
      system.debug(queryString);

      setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));

      setCon.setPageSize(size);
      noOfRecords = setCon.getResultSize();
      noOfRecords = noOfRecords==null ? 0: noOfRecords;
      recordsFound = noOfRecords > 0 ? true: false;

      Double dSize = (double) size;
      Double dRecords = (double) noOfRecords;
      Double dPages = Math.Ceil(dRecords/dSize);                
      noOfPages = (Integer) dPages;
      }
      return setCon;
      }set;
      }
     */

    Public List <Customer > getAccounts()
    {
        List <Customer > customers = searchAccounts();
        if (customers != null && customers.size() > 0)
        {
            setCon = new SetCustomerClass(customers, size);
        }
        else
        {
            setCon = new SetCustomerClass(new List <Customer > (), size);
        }

        noOfRecords = setCon.getResultSize();
        noOfRecords = noOfRecords == null ? 0 : noOfRecords;
        recordsFound = noOfRecords > 0 ? true : false;

        Double dSize = (double) size;
        Double dRecords = (double) noOfRecords;
        Double dPages = Math.Ceil(dRecords / dSize);
        noOfPages = (Integer) dPages;

        List <Customer > accList = new List <Customer > ();
        for (Customer a : (List <Customer >) setCon.getRecords())
        accList.add(a);
        return accList;
    }

    public void sortCol()
    {
        if (oldSortField == sortField)
        {
            sortDir = (sortDir == 'Asc') ? 'Desc' : 'Asc';
        }
        else
        {
            sortDir = 'Asc';
        }

        //PageReference pr = refresh();
        System.DEBUG(sortField);
        System.DEBUG(sortDir);
        setCon.sortRecords(sortField, sortDir);
        setCon.first();
        Accounts = setCon.getRecords();
    }

    public pageReference customizeSearch()
    {
        showAvailableFields = true;
        return null;
    }

    public pageReference customizeDisplay()
    {
        showAvailableColumns = true;
        return null;
    }

public string returnErrorMessage(string code) {
      Map<string, string> internal_storage = new Map<String, String>();
      Map<string, NCIWebServiceErrors__c> allRecords = NCIWebServiceErrors__c.getAll();
         for(NCIWebServiceErrors__c tcs:allRecords.values()){
                     if(! internal_storage.containsKey(tcs.ErrorNumber__c)){
                             internal_storage.put(tcs.ErrorNumber__c,tcs.ErrorMessage__c);
                       }
         }
         
      if (internal_storage.get(code) != null) {
          
      return internal_storage.get(code);
      
      } else {
      return 'An error has occured.';
      
      }
}



    
public string Customer_Id { get; set; }
public string trackingNumber { get; set; }
public string CxName { get; set;}

    public pageReference checkCustomerList() {
        // check to see if cx id exists
       List<Error_Log__c> errors = new List<Error_Log__c>();
       
       if (Customer_Id != null) {
           System.debug('Trying to search on customer id: ' + Customer_Id);
           System.debug('or maybe trying to search on trackingNumber: ' + trackingNumber);
           
           try {
               
               Id personId = personalAccRecordType.Id;
               Id accid;
               Account acc;
               Boolean createAccount = false;
               String responseJSON;
               String respVehicle;
               Boolean wsCheck = true;
               
               if (trackingNumber == null || trackingNumber == '') {
                   List<Account> results =  Database.query('Select id, name from account where NCI_Customer_id__c=:Customer_Id and recordtypeid=:personId LIMIT 1');

                   if (results.size() >= 1) {
                       acc = results[0];
                       // using this account
                       accid = results[0].Id;
          
                   } else {
                         createAccount = true;
                       
                   }
                   
               } else {
                    
                   List<Account> results =  Database.query('Select id, name from account where id=:trackingNumber and recordtypeid=:personId LIMIT 1');
                   if (results.size() >= 1) {
                       acc = results[0];
                       accid = acc.id;
                       returnedId = trackingNumber;
                       acc.Customer_Id__c = customer_Id;  //Warning:  Potential overwrite of customer id if trackingNumber provided...
                       update acc;
                       //acc.Id = trackingNumber;
                   }
                   
               }
               
               if (createAccount) {
                   
                   // create account
                   System.debug('creating new account ...');
                   acc = CreateCustomerAccount2(Customer_Id);
    
               } else {
                   // updating the account 
                   //UpdateCustomerAccount(ch);
                   System.debug('would ordinarily try to update here.. ');
                  
               }
    
              // UpsertVehicleOwnership(respVehicle,acc);
               PageReference pg = new PageReference('/' + acc.Id + '?isdtp=nv');
               returnedId = acc.Id;
               accountName = CxName;
               
               //return pg;
               return null;
               
        } catch(Exception ex) {
            System.debug(ex);
             errors.add(new Error_Log__c(Record_ID__c = Customer_Id,
                                    Record_Type__c = 'NCI Account', 
                                    Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'NCIAccountController Webservice System Error', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
           
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There was a system problem searching customer detail for this record.'));
              if (!errors.isEmpty()) {
            // Insert rows
                    Database.SaveResult[] dbResults = Database.insert(errors, false);
              }
              return null;
             
            
            
            
          
        }
       
        
       
          
       } else {
           return null;
       }
         
    }
     private Account UpdateCustomerAccount(NCICustomerDetailRest.CustomerHandler ch) {
     String thiscx = String.valueOf(ch.customerNumber);
                    RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND Name='NCI' and IsPersonType = True limit 1];
               Id personId = personalAccRecordType.Id;
        Account customer = [select id, NCI_Customer_ID__c, Phone, PersonMobilePhone, Work_Phone__c, firstName, lastName, PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, PersonEmail from Account where recordtypeid=:personId and NCI_Customer_ID__c= :thiscx limit 1];

        if (!IsNullOrEmptyString(ch.lastname)) {
            customer.firstName = ch.firstName;
            customer.lastName = ch.lastName;
            //customer.Customer_ID__c = String.valueOf(ch.customerNumber);
            customer.PersonMailingStreet = BuildPersonalMailingStreetValue(ch);
            customer.PersonMailingCity = ch.addressInfo.address.city;
            //customer.PersonMailingPostalCode = ch.addressInfo.address.postalcode; this causes Address verification to begin recurrsion for address update.
            customer.PersonMailingState = ch.addressInfo.address.province;
            customer.PersonMailingCountry = ch.addressInfo.address.country;
            if (ch.contactInfo.emailAddress.size() > 0) {
                customer.PersonEmail = ch.contactInfo.emailAddress.get(0).email;
            }

            for (NCICustomerDetailRest.PhoneHandler ph : ch.contactInfo.phone) {
                if (ph.type == 'HOME') {
                    customer.Phone = String.valueOf(ph.phonenumber);
                }
                else if (ph.type == 'MOBILE') {
                    customer.PersonMobilePhone = String.valueOf(ph.phonenumber);
                }
                else if (ph.type == 'WORK') {
                    customer.Work_Phone__c = String.valueOf(ph.phonenumber);
                }
            }
            for (NCICustomerDetailRest.ConsentInfoHandler ci : ch.consentInfo) {
                    if (ci.consentType == 'NISSAN') {
                        if (ci.contactMethod == 'MAIL') { customer.Nissan_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Nissan_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Nissan_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Nissan_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Nissan_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Nissan_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Nissan_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Nissan_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Nissan_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                    if (ci.consentType == 'INFINITI') {
                        if (ci.contactMethod == 'MAIL') { customer.Infiniti_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Infiniti_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Infiniti_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Infiniti_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Infiniti_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Infiniti_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Infiniti_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Infiniti_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Infiniti_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                    if (ci.consentType == 'DEALER') {
                        if (ci.contactMethod == 'MAIL') { customer.Dealer_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'EMAIL') { customer.Dealer_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'TXTMSG') { customer.Dealer_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'PHONE') { customer.Dealer_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADPHONE') { customer.Dealer_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'WPHONE') { customer.Dealer_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADWPHONE') { customer.Dealer_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'MPHONE') { customer.Dealer_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                        if (ci.contactMethod == 'ADMPHONE') { customer.Dealer_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
                    }
                }
                
            update customer;
        }

        return customer;
    }
      private Account CreateCustomerAccount2(String cxid){
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND Name='NCI' and IsPersonType = True limit 1];
        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.NCI_Customer_ID__c = cxid;
        account.lastname = '_';
        insert account; return account;
      }
      
      private Account CreateCustomerAccount(NCICustomerDetailRest.CustomerHandler ch) {
        RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND Name='NCI' and IsPersonType = True limit 1];
        Account account = new Account();
        account.Recordtypeid = personalAccRecordType.Id;
        account.NCI_Customer_ID__c = String.valueOf(ch.customerNumber);
        /*account.firstName = ch.firstName;
        account.lastName = ch.lastName;
        account.PersonMailingStreet = BuildPersonalMailingStreetValue(ch);
        account.PersonMailingCity = ch.addressInfo.address.city;
        account.PersonMailingPostalCode = ch.addressInfo.address.postalcode;
        account.PersonMailingState = ch.addressInfo.address.province;
        account.PersonMailingCountry = ch.addressInfo.address.country;
        if (ch.contactInfo.emailAddress.size() > 0) {
            account.PersonEmail = ch.contactInfo.emailAddress[0].email;
        }
        for (NCICustomerDetailRest.PhoneHandler ph : ch.contactInfo.phone) {
            if (ph.type == 'HOME') {
                account.Phone = String.valueOf(ph.phonenumber);
            }
            else if (ph.type == 'MOBILE') {
                account.PersonMobilePhone = String.valueOf(ph.phonenumber);
            }
            else if (ph.type == 'WORK') {
                account.Work_Phone__c = String.valueOf(ph.phonenumber);
            }
        }
   
        for (NCICustomerDetailRest.ConsentInfoHandler ci : ch.consentInfo) {
            if (ci.consentType == 'NISSAN') {
                if (ci.contactMethod == 'MAIL') { account.Nissan_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'EMAIL') { account.Nissan_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'TXTMSG') { account.Nissan_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'PHONE') { account.Nissan_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADPHONE') { account.Nissan_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'WPHONE') { account.Nissan_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADWPHONE') { account.Nissan_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'MPHONE') { account.Nissan_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADMPHONE') { account.Nissan_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
            }
            if (ci.consentType == 'INFINITI') {
                if (ci.contactMethod == 'MAIL') { account.Infiniti_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'EMAIL') { account.Infiniti_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'TXTMSG') { account.Infiniti_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'PHONE') { account.Infiniti_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADPHONE') { account.Infiniti_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'WPHONE') { account.Infiniti_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADWPHONE') { account.Infiniti_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'MPHONE') { account.Infiniti_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADMPHONE') { account.Infiniti_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
            }
            if (ci.consentType == 'DEALER') {
                if (ci.contactMethod == 'MAIL') { account.Dealer_Mail__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'EMAIL') { account.Dealer_Email__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'TXTMSG') { account.Dealer_Text_Message__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'PHONE') { account.Dealer_Call_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADPHONE') { account.Dealer_Auto_Dial_Home_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'WPHONE') { account.Dealer_Call_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADWPHONE') { account.Dealer_Auto_Dial_Work_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'MPHONE') { account.Dealer_Call_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; }
                if (ci.contactMethod == 'ADMPHONE') { account.Dealer_Auto_Dial_Mobile_Phone__c = ci.consentFlag != null ? ci.consentFlag : false; } 
            }
        }
          */      
        insert account;
        
        
        return account;
    }
    
  private Boolean IsNullOrEmptyString(String value) {
        if (value != null && value != '') {
            return false;
        }

        return true;
    }
    
    
       private void UpsertVehicleOwnership(String resp,Account acc) {
        NCICustomerVehiclesRest.CustomerVehicleHandler cvh = (NCICustomerVehiclesRest.CustomerVehicleHandler) Json.deserialize(resp, NCICustomerVehiclesRest.CustomerVehicleHandler.class);
        List <NCICustomerVehiclesRest.CustomerVehicle > cv = null;
        if (cvh != null) {
            cv = cvh.customerVehicles;
        }

        if (cv != null) {
            Account customer = [SELECT id, Customer_ID__c from Account where id = :acc.id limit 1];

            Map <String, Vehicle__c > vehicles = new Map <String, Vehicle__c > ();

            Vehicle__c vec;
            for (NCICustomerVehiclesRest.CustomerVehicle cVeh : cv) {
                if (cVeh.vinCode != null) {
                    vec = new Vehicle__c(Make_Name__c = cVeh.make,Model_Name__c= cVeh.modelDesc,
                                         Name = cVeh.vinCode,
                                         Model_Year__c = String.valueOf(cVeh.modelYear),
                                         Vehicle_identification_Number__c = cVeh.vinCode,
                                         Model_Series__c = cVeh.seriesCode,
                                         In_Service_Date__c = cVeh.inServiceDate == null ? null : Date.valueOf(cVeh.inServiceDate)
                    );
                }
                vehicles.put(cVeh.vinCode, vec);
            }

            List <Vehicle__c > insertedVehicles = [SELECT Id, Name,Make_Name__c,Model_Name__c, Model_Series__c, In_Service_Date__c, Model_Year__c, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :vehicles.keySet()];
            List <Vehicle__c > updateVehicleTemp = new List<Vehicle__c>();
            Vehicle__c tempVehicle;
            
            for (Vehicle__c v : insertedVehicles) {
                System.debug('checking to see if vehicle is in system already.., this is in the system:');
                System.debug(v.Name);
                if (vehicles.containsKey(v.Vehicle_identification_Number__c)) {
                    System.debug('attempting to remove vheicle named: ' + v.Name);
                    vehicles.remove(v.Vehicle_identification_Number__c);
                    updateVehicleTemp.add(v);
                    
                }
            }

            for (Vehicle__c v : updateVehicleTemp) {
                for (NCICustomerVehiclesRest.CustomerVehicle cVeh : cv) {
                    if (cVeh.vinCode == v.Vehicle_Identification_Number__c) {
                           
                           v.Make_Name__c=cVeh.make;
                           v.Model_Name__c = cVeh.modelDesc;
                           v.Name = cVeh.vinCode;
                           v.Model_Year__c = String.valueOf(cVeh.modelYear);
                           v.Model_Series__c = cVeh.seriesCode;
                           v.In_Service_Date__c = cVeh.inServiceDate == null ? null : Date.valueOf(cVeh.inServiceDate);
                    }
                 }
            }
            
            
            upsert updateVehicleTemp;
            upsert vehicles.values();
            

            Map <String, Vehicle_Ownership_History__c > vohs = new Map <String, Vehicle_Ownership_History__c > ();
            Vehicle_Ownership_History__c tempVOH;

            for (NCICustomerVehiclesRest.CustomerVehicle cusVeh : cv) {
                if (vehicles.get(cusVeh.vinCode) != null) {
                    tempVOH = new Vehicle_Ownership_History__c(Owner__c = customer.id, Vehicle__c = vehicles.get(cusVeh.vinCode).id);
                    tempVOH.Begin_Date__c = cusVeh.customerVehicleStartDate == '' ? null : Date.valueOf(cusVeh.customerVehicleStartDate);
                    tempVOH.End_Date__c = cusVeh.customerVehicleEndDate == '' ? null : Date.valueOf(cusVeh.customerVehicleEndDate);
                    if ( cusVeh.customerVehicleEndDate == '9999-12-31') {
                        tempVOH.End_Date__c = null;
                    }
                    
                    tempVOH.Current_Owner_Indicator__c = cusVeh.currentDriverIndicator == 'Y' ? true : false;
                    vohs.put(cusVeh.vinCode, tempVOH);
                }
            }

            for (Vehicle_Ownership_History__c v :[select Id, VIN__c, Begin_Date__c,
                 End_Date__c, Current_Owner_Indicator__c,
                 Primary_Owner_Indicator__c,
                 Vehicle__c,
                 Vehicle__r.Model_Year__c,
                 Vehicle__r.Make_Name__c,
                 Vehicle__r.Model_Line_Name__c,
                 Vehicle__r.Vehicle_identification_Number__c
                 from Vehicle_Ownership_History__c
                 where Owner__c = :customer.id
                 ]) {
                if (vohs.containsKey(v.Vehicle__r.Vehicle_identification_Number__c)) {
                    vehicles.remove(v.Vehicle__r.Vehicle_identification_Number__c);
                }
            }

            upsert vohs.values();
        }
    }
    
        private String BuildPersonalMailingStreetValue(NCICustomerDetailRest.CustomerHandler ch) {
        String street = '';

        street += (ch.addressInfo.address.apartmentNumber != null && ch.addressInfo.address.apartmentNumber != '') ? ch.addressInfo.address.apartmentNumber : '';
        street += (ch.addressInfo.address.streetNumber != null && ch.addressInfo.address.streetNumber != '') ?
        (street != '' ? '-' + ch.addressInfo.address.streetNumber : ch.addressInfo.address.streetNumber) : '';
        street += (ch.addressInfo.address.streetNumberSuffix != null && ch.addressInfo.address.streetNumberSuffix != '') ? ' ' + ch.addressInfo.address.streetNumberSuffix : '';
        street += (ch.addressInfo.address.streetName != null && ch.addressInfo.address.streetName != '') ? ' ' + ch.addressInfo.address.streetName : '';
        street += (ch.addressInfo.address.streetType != null && ch.addressInfo.address.streetType != '') ? ' ' + ch.addressInfo.address.streetType : '';
        street += (ch.addressInfo.address.streetDirection != null && ch.addressInfo.address.streetDirection != '') ? ' ' + ch.addressInfo.address.streetDirection : '';

        return street;
    }
    
    

    public PageReference updateColumns()
    {
        selectedColumns = new List <SelectOption > ();

        Set<String> availColumns = new Set<String> (columnChoices);
        Set<String> chosenColumns = new Set<String> (columnChoicesOrder);

        for (String val : columnChoicesOrder)
        {
            if (availColumns.contains(val) && fieldLabels.containsKey(val))
            {
                selectedColumns.Add(new SelectOption(val, fieldLabels.get(val)));
            }
        }
        for (String val : columnChoices)
        {
            if (!chosenColumns.contains(val) && fieldLabels.containsKey(val))
            {
                selectedColumns.Add(new SelectOption(val, fieldLabels.get(val)));
            }
        }

        columnChoicesOrder = new List <String > ();
        for (SelectOption so : selectedColumns)
        {
            columnChoicesOrder.Add(so.getValue());
        }

        if(columnChoices.isEmpty()){
                SelectOption soption = new SelectOption('FirstName', 'First Name');
                columnChoicesOrder.add(soption.getValue());
        }

        return null;
    }
    public PageReference cancelSaveColumns()
    {
        showAvailableColumns = false;
        return null;
    }
    public pageReference saveColumns()
    {
        Integer iChoice = 1;
        for (String choice : columnChoicesOrder)
        {
            if (iChoice > 15)
            {
                break;
            }
            if (iChoice <10)
            {
                ncisettings.put('Selected_Field_0' + iChoice + '__c', choice);
            }
            else
            {
                ncisettings.put('Selected_Field_' + iChoice + '__c', choice);
            }
            iChoice++;
        }

        for (Integer i = iChoice; i <= 15; i++)
        {
            if (i <10)
            {
                ncisettings.put('Selected_Field_0' + i + '__c', '');
            }
            else
            {
                ncisettings.put('Selected_Field_' + i + '__c', '');
            }
        }

        //upsert ncisettings; // maybe we should upsert after the callout?
        showAvailableColumns = false;
        displayColumns = columnChoicesOrder;

        if (initialSearch)
        {
            return refresh();
        }
        else
        {
            return null;
        }
    }


    public PageReference cancelSaveSearch()
    {
        showAvailableFields = false;
        return null;
    }
    public PageReference saveSearch()
    {
        Integer iChoice = 1;
        for (String choice : searchChoices)
        {
            if (iChoice > 7)
            {
                break;
            }
            ncisettings.put('Search_Field_' + iChoice + '__c', choice);
            iChoice++;
        }
        for (Integer i = iChoice; i <= 6; i++)
        {
            ncisettings.put('Search_Field_' + i + '__c', '');
        }

        upsert ncisettings;
        showAvailableFields = false;
        searchChoices = new List <String > ();
        availableFields = new List <SelectOption > ();
        addSearchFields(getSearchFields());
        return null;
    }

    public pageReference clear()
    {
        setCon = null;
        for (String key : searchValues.keySet())
        {
            searchValues.put(key, '');
        }
        vinSearch = false;
        onlyvinSearch = false;
        recordsFound = false;
        onlyCaseSearch = false;
        initialSearch = false;
        vin = '';
        casenumber = '';
        dealerNumber = '';
        return null;
    }

    public pageReference refresh() {
        vinSearch = false;
        onlyvinSearch  = false;
        onlyCaseSearch = false;
        initialSearch = true;
        setCon = null;
        if (ncisettings == null) {
            // insert new ncisettings for this user
             NCI_Account_Fields__c accFields = new NCI_Account_Fields__c();
             accFields.SetupOwnerId = System.UserInfo.getUserId();
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
            
             ncisettings = accFields;
             
        }
        // search Cases or dealer number
        
        if(casenumber != null && casenumber.length()>0 || 
        dealerNumber != null && dealerNumber.length()>0 || 
        searchValues.get('Phone') != null && searchValues.get('Phone').length() >0 ||   
        (searchValues.get('LastName') != null && searchValues.get('LastName').length() > 0 && searchValues.get('PersonMailingPostalCode') != null && searchValues.get('PersonMailingPostalCode').length() > 0)
        
         ) {
            
            vinSearch = true;
            searchCases(vin,casenumber, dealerNumber);
            
            
        }
        if (casenumber != null && casenumber.length() > 0 ) {
            return null;
        }
        
        
        Accounts = getAccounts();
       // upsert ncisettings;
         
     
        if (NCI_Account_Fields__c.getValues(System.UserInfo.getUserId()) == null) {
                insertSearchDefaults(System.UserInfo.getUserId());
    }
        return null;
    }
    public void searchCases(String vin, String casenumber, String dealerNumber) {
          String rtss = '(';
         List<RecordType> nciCaseRtId = [select id from RecordType where SobjectType = 'Case' and Name LIKE '%NCI%'];
         
                     for (RecordType r : nciCaseRtId) {
                         rtss = rtss + '\'' + r.id + '\',';
                     }
                     rtss = rtss.substring(0,rtss.length()-1) + ')';
                     
                     System.debug(rtss);
         
         
             if (casenumber != null && casenumber.length() > 0) {
                 vinCases = [ select id,createddate,Dealer__r.Name, Servicing_Dealer__r.Name,Account.Name,casenumber, description, subject from case WHERE (CaseNumber = :casenumber) and RecordTypeId IN :nciCaseRtId LIMIT 1 ];
                  setCon = null;
                  onlyCaseSearch = true;
             } else {
                     String searchS = '';
                     if (dealerNumber != null && dealerNumber.length() > 0) {
                         searchS = searchS + 'AND (Dealer__r.Name LIKE \''+ dealerNumber +  '%\' OR Servicing_Dealer__r.Name LIKE \''+ dealerNumber +  '%\')  ';                      
                     }
                     if (searchValues.get('PersonMailingPostalCode') != null && searchValues.get('PersonMailingPostalCode').length() > 0) {
                         searchS = searchS + 'AND Account.PersonMailingPostalCode =\'' + searchValues.get('PersonMailingPostalCode')+ '\' ';
                     }
                      if (searchValues.get('LastName') != null && searchValues.get('LastName').length() > 0) {
                         searchS = searchS + 'AND Account.lastName =\'' + searchValues.get('LastName')+ '\' ';
                     }
                      if (searchValues.get('FirstName') != null && searchValues.get('FirstName').length() > 0) {
                         searchS = searchS + 'AND Account.FirstName=\'' + searchValues.get('FirstName')+ '\' ';
                     }
                     
                     if (searchValues.get('Phone') != null && searchValues.get('Phone').length() > 0) {
                         searchS = searchS + 'AND Account.Phone =\'' + searchValues.get('Phone').replaceAll('[^0-9]', '') + '\' ';
                     }
                    /* 
                     if (vehicleType != null && vehicleType.length() > 0) {
                         searchS = searchS + 'AND Vehicle_Name__r.Make_Model__c LIKE \'' + vehicleType + '\' ';
                     }
                     */
                     System.debug(searchS);
                    
                     System.debug('select id,createddate,Dealer__r.Name, Account.Name,casenumber, description, subject from case WHERE  RecordTypeId IN ' + rtss + searchS + '  ORDER BY CreatedDate DESC  LIMIT 20');
                     
                     vinCases = Database.query('select id,createddate,Account.Name,Servicing_Dealer__r.Name,Dealer__r.Name, casenumber, description, subject from case WHERE  RecordTypeId IN ' + rtss +' ' + searchS + ' ORDER BY CreatedDate DESC  LIMIT 20');

             }
                 

          /*  if (results.size() > 0) {
                  
                Set<Id> vohsetids = new Set<Id>();
                
                for (vehicle_ownership_history__c v : results) {
                    vohsetids.add(v.Owner__c);
                }
                
                vinAccounts = [select id, name, personmailingcity, phone from account where id in :vohsetids ];
            }
            */
            
        }
    
    public Boolean hasNext {
        get {
        if (setCon != null) {
            return setCon.getHasNext();
        } else {
            return null;
        }
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            if (setCon != null) {
            return setCon.getHasPrevious();
            } else {
            return null;
            }
        }
        set;
    }

    public Integer pageNumber {
        get {

            return(setCon == null || setCon.getPageNumber() == null) ? 1 : setCon.getPageNumber();
        }
        set;
    }

    public void first() {
        setCon.first();
        Accounts = setCon.getRecords();
    }

    public void last() {
        setCon.last();
        Accounts = setCon.getRecords();
    }

    public void previous() {
        setCon.previous();
        Accounts = setCon.getRecords();
    }

    public void next() {
        setCon.next();
        Accounts = setCon.getRecords();
    }
}