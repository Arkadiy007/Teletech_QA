/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2014, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class is the controller of the sidebar component used for searching 
Accounts, Contacts and VINs

Class:              Controller_SearchTechlineConsole
Author:             Matt Starr
Date:               03/17/2014
Version:            1.0
Last Updated:       03/17/2014
    * 03/17/2014    Created
*/

public with sharing class Controller_SearchTechlineConsole
{


    // -------- Constants --------
    private final String LIMIT_RECORDS = '5';
    private final String LIMIT_VEHICLE_RECORDS = '5';
    
    // -------- Constructor --------
    public Controller_SearchTechlineConsole(){
        showAccounts = false;
        showVehicles = false;
        showDealers = false;
        showCases = false;
        showNoRecords = false;
        showRefineSearch = false;
        showVehRefineSearch = false;
        showAcctFields = true;
        disperrormsg = false;
        veherrormsg = false;
        accterrormsg = false;
        caseerrormsg = false;
        showclear = false;
        showNoRecordscase = false;
        showNoRecordscust = false;
        showNoRecordsveh = false;
        showNoRecordsdealer = false;
            }

    // -------- Variables --------
    private ValidationUtility datacheck = new ValidationUtility();
    
    // -------- Properties --------
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String state {get;set;}
    public String zip {get;set;}
    public String vin {get;set;}
    public String DealerCode {get;set;} 
    public String caseNumber {get;set;}   
    public List<Account> accountList {get;set;}
    public List<Account> dealerList {get;set;}
    public List<Vehicle__c> vehicleList {get;set;}  
    public List<Case> caseList {get;set;}  
    public Boolean showAccounts {get;set;}
    public Boolean showDealers {get;set;}
    public Boolean showVehicles {get;set;}  
    public Boolean showCases {get;set;}
    public Boolean showNoRecords {get;set;}   
    public Boolean showRefineSearch {get;set;} 
    public Boolean showVehRefineSearch {get;set;}
    public Boolean showAcctFields {get;set;}   
    public boolean disperrormsg {get;set;}
    public Boolean veherrormsg {get;set;}
    public Boolean accterrormsg {get;set;}
    public Boolean caseerrormsg {get;set;}
    public Boolean showclear {get;set;}
    public Boolean showNoRecordscase {get;set;} 
    public Boolean showNoRecordscust {get;set;} 
    public Boolean showNoRecordsveh {get;set;} 
    public Boolean showNoRecordsdealer {get;set;}  
    
    
    // -------- Methods --------
     public void searchAccounts() {
    removeExtraSpaces();
    hideAllPanels();
     
    if(datacheck.IsStringNullOrEmpty(firstName) && datacheck.IsStringNullOrEmpty(lastName)
        && datacheck.IsStringNullOrEmpty(zip) && State == 'None'){
            accterrormsg = true;
        }
        
    else{
    showclear = true;
    String query = '';
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
    
    query += 'LIMIT ' + LIMIT_RECORDS;
    accountList = Database.query(query);
    
    if (accountList.size() > 0) {
      showAccounts = true;
      showAcctFields = false;
      
      if (accountList.size() == 5) {
        accountList.remove(4);
        showRefineSearch = true;
      }
      else {
        showRefineSearch = false;
      }
    }
    else {
      showRefineSearch = false;
      //showNoRecords = true;
      showNoRecordscust = true;
     
    }
  }
 } 
  private void removeExtraSpaces() {
    firstName = firstName.trim();
    lastName = lastName.trim();
    zip = zip.trim(); 
  }
    
    public void searchDealers() {
    
    hideAllPanels();
        
        if(datacheck.IsStringNullOrEmpty(DealerCode)){
     disperrormsg = true;
        
     }
        
        if(!datacheck.IsStringNullOrEmpty(DealerCode)){
         disperrormsg = false;
         showclear = true;
       
        dealerList = [Select Id, Name, LastName, BillingCity, Dealer_Code__c,
                        BillingState, BillingPostalCode From Account where Dealer_Code__c = :dealercode Limit 3];
        
       
        if (dealerList.size() > 0 ) {
            showDealers = true;
          }
        else {
            //showNoRecords = true;
            showNoRecordsdealer = true;
        }
     }

 }
    
    public void searchVehicles() {
       
        hideAllPanels();
           
        if(datacheck.IsStringNullOrEmpty(vin)){
        veherrormsg = true;
        }
        
        String query = '';
        
        if(!datacheck.IsStringNullOrEmpty(vin)){
        vin = vin.trim();
        showclear = true;
        
        query += 'SELECT Id, Make_Model__c, Vehicle_identification_Number__c ';
        query += 'FROM Vehicle__c ';
        query += 'WHERE IsDeleted = false ';
        
        
            if (vin.length() == 6) {
                query += 'AND Vehicle_identification_Number__c LIKE \'%' + 
                    vin + '\' ';
            }
            else {
                query += 'AND Vehicle_identification_Number__c = \'' + vin + 
                    '\' ';  
            }
        
        
        query += 'LIMIT ' + LIMIT_VEHICLE_RECORDS;
        vehicleList = Database.query(query);
        
       
        if (vehicleList.size() > 0) {
            showVehicles = true;
            
            if (vehicleList.size() == 5) {
                vehicleList.remove(4);
                showVehRefineSearch = true;
            }
            else {
                showVehRefineSearch = false;
            }
        }
        else {
            showVehRefineSearch = false;
            //showNoRecords = true;
            showNoRecordsveh = true;
           
        }
    }
 }
    
 public void searchCases() {
     hideAllPanels();
    caseNumber = caseNumber.trim();
    
    if(datacheck.IsStringNullOrEmpty(caseNumber)){
    
    caseerrormsg = true;
    
    }
    
    else{
    showclear = true;
    caseList = [Select Id, CaseNumber, CustomerNameFormula__c from Case where CaseNumber = :caseNumber Limit 1];
    
    if (caseList.size() > 0) {
      showCases = true;
      }
    else {
     //showNoRecords = true; 
     showNoRecordscase = true;    
    }
  }
  }
  
    public void hideAllPanels() {
        showAccounts = false;
        showVehicles = false;
        showDealers = false;
        showCases = false;
        showNoRecords = false;
        showRefineSearch = false;
        showVehRefineSearch = false;
        showAcctFields = true;
        disperrormsg = false;
        veherrormsg = false;
        accterrormsg = false;
        caseerrormsg = false; 
        
               
    }
    
     public void clear() {
        showAccounts = false;
        showVehicles = false;
        showDealers = false;
        showCases = false;
        showNoRecords = false;
        showRefineSearch = false;
        showVehRefineSearch = false;
        showAcctFields = true;
        disperrormsg = false;
        veherrormsg = false;
        accterrormsg = false;
        caseerrormsg = false; 
        firstName = '';
        lastName = '';
        state ='';
        zip ='';
        vin ='';
        DealerCode ='';
        caseNumber =''; 
        showclear = false; 
        showNoRecordscase = false;
        showNoRecordscust = false;
        showNoRecordsveh = false;
        showNoRecordsdealer = false;  
     
     }
    
}