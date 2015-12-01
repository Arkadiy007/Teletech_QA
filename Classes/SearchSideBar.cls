/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class is the controller of the sidebar component used for searching 
Accounts, Contacts and VINs

Class:              SearchSideBar
Author:                         Rohdenburg S.
Date:               06/06/2013
Version:            1.0
Last Updated:       06/06/2013
    * 06/06/2013        SR - Stubbed
    * 06/14/2013        SR - Implemented new filter on the Account search 
*/

public with sharing class SearchSideBar
{
        // -------- Constants --------
        private final String LIMIT_RECORDS = '10';
        private final String LIMIT_VEHICLE_RECORDS = '10';
        
        // -------- Constructor --------
    public SearchSideBar(){
        showAccounts = false;
        showVehicles = false;
        showCases = false;
        showNoRecords = false;
        showRefineSearch = false;
        showTabs = true;
        redirectUrl = '/';
        consumerSearch = Search_Tool_Settings__c.getInstance(UserInfo.getUserId()).Person_A_C_Search__c; //true;
    }

    // -------- Variables --------
        private ValidationUtility datacheck = new ValidationUtility();
        
        // -------- Properties --------
        public String selectedTab {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String vin {get;set;}
        public String caseNumber {get;set;}
        public List<Account> accountList {get;set;}
        public List<Vehicle__c> vehicleList {get;set;}
        public List<Case> caseList {get;set;}
        public Boolean showAccounts {get;set;}
        public Boolean showVehicles {get;set;}
        public Boolean showCases {get;set;}
        public Boolean showNoRecords {get;set;}
        public Boolean showTabs {get;set;}
        public Boolean showRefineSearch {get;set;}
        public String redirectUrl {get;set;}
        public boolean consumerSearch {get; set;}
        public String acctName {get; set;}
        public String busName {get; set;}
        public String certCode {get; set;}
        
        // -------- Methods --------
        public void searchAccounts() {
                
              Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
              String busAcctRTid = rtInfosByName.get('Business').getRecordTypeId();
                                
                String query = '';
                if(consumerSearch){
                removeExtraSpaces();
                query += 'SELECT Id, FirstName, LastName, Name, PersonMailingCity, ';
                query += 'PersonMailingState, PersonMailingPostalCode, PersonEmail, ';
                query += 'PersonHomePhone ';
                query += 'FROM Account ';
                query += 'WHERE IsDeleted = false ';
                
                if (!datacheck.IsStringNullOrEmpty(firstName)) {
                        query += 'AND FirstName = \'' + firstName + '\' ';      
                }
                
                if (!datacheck.IsStringNullOrEmpty(lastName)) {
                        query += 'AND LastName = \'' + lastName + '\' ';        
                }
                
                if (!datacheck.IsStringNullOrEmpty(zip)) {
                        //This regex matches US zip codes in 9 digit format
                        Pattern usPostCode = Pattern.Compile('^\\d{5}-\\d{4}$');
                        Matcher usMatch = usPostCode.matcher(zip);
                        Boolean isUsZip = usMatch.Matches();
                        
                        //This regex matches Canadian zip codes
                        Pattern canadianPostCode = Pattern.Compile('^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1} *\\d{1}[A-Z]{1}\\d{1}$');
                        Matcher canadianMatch = canadianPostCode.matcher(zip);
                        Boolean isCanadianZip = canadianMatch.Matches();
                                
                        if (isUsZip || isCanadianZip) {
                                query += 'AND PersonMailingPostalCode = \'' + zip + '\' ';      
                        }
                        else {
                                query += 'AND PersonMailingPostalCode LIKE \'' + zip + '%\' ';
                        }       
                }
                
                if (!datacheck.IsStringNullOrEmpty(state) && state != 'None') {
                        query += 'AND PersonMailingState = \'' + state + '\' '; 
                }
                }else{
                     query += 'SELECT Id, Name, BillingState, Cert_Code__c From Account ';
                     query += 'WHERE IsDeleted = false ';
                     
                      if (!datacheck.IsStringNullOrEmpty(acctName)) {
                        query += 'AND Name Like \'' + acctName+ '%\'';        
                      }
                      if(!datacheck.IsStringNullOrEmpty(certCode)){
                          query += 'AND RecordTypeId =: busAcctRTid AND Cert_Code__c Like \'' + certCode+ '%\'';
                      }
                }
                
                
                query += 'LIMIT ' + LIMIT_RECORDS;
                accountList = Database.query(query);
                
                hideAllPanels();
                if (accountList.size() > 0) {
                        showAccounts = true;
                        
                        if (accountList.size() == 10) {
                                accountList.remove(9);
                                showRefineSearch = true;
                        }
                        else {
                                showRefineSearch = false;
                        }
                }
                else {
                        showRefineSearch = false;
                        showNoRecords = true;
                        showTabs = true;
                }
        }
        
        private void removeExtraSpaces() {
                firstName = firstName.trim();
                lastName = lastName.trim();
                zip = zip.trim(); 
        }
        
        public void searchVehicles() {
                vin = vin.trim();
                
                String query = '';
                query += 'SELECT Id, Make_Model__c, Vehicle_identification_Number__c ';
                query += 'FROM Vehicle__c ';
                query += 'WHERE IsDeleted = false ';
                
                if (!datacheck.IsStringNullOrEmpty(vin)) {
                        if (vin.length() == 6) {
                                query += 'AND Vehicle_identification_Number__c LIKE \'%' + 
                                        vin + '\' ';
                        }
                        else {
                                query += 'AND Vehicle_identification_Number__c = \'' + vin + 
                                        '\' ';  
                        }
                }
                
                query += 'LIMIT ' + LIMIT_VEHICLE_RECORDS;
                vehicleList = Database.query(query);
                
                hideAllPanels();
                if (vehicleList.size() > 0) {
                        showVehicles = true;
                        
                        if (vehicleList.size() == 10) {
                                vehicleList.remove(9);
                                showRefineSearch = true;
                        }
                        else {
                                showRefineSearch = false;
                        }
                }
                else {
                        showRefineSearch = false;
                        showNoRecords = true;
                        showTabs = true;
                }
        }
        
        public void searchCases() {
                caseNumber = caseNumber.trim();
                
                String query = '';
                query += 'SELECT Id, CaseNumber, CustomerNameFormula__c ';
                query += 'FROM Case ';
                query += 'WHERE IsDeleted = false ';
                
                if (!datacheck.IsStringNullOrEmpty(caseNumber)) {
                        query += 'AND CaseNumber = \'' + caseNumber + '\' ';    
                }
                
                query += 'LIMIT ' + LIMIT_RECORDS;
                caseList = Database.query(query);
                
                hideAllPanels();
                if (caseList.size() > 0) {
                        showCases = true;
                        
                        if (caseList.size() == 10) {
                                caseList.remove(9);
                                showRefineSearch = true;
                        }
                        else {
                                showRefineSearch = false;
                        }
                }
                else {
                        showRefineSearch = false;
                        showNoRecords = true;
                        showTabs = true;
                }
        }
        
       
        
        public void backToSearch() {
                hideAllPanels();
                showTabs = true;
        }
        
        private void hideAllPanels() {
                showTabs = false;
                showNoRecords = false;
                showAccounts = false;
                showVehicles = false;
                showCases = false;
        }  
        
        public Pagereference refreshAccountsSearch(){
        
            return null;
        }      
      
}