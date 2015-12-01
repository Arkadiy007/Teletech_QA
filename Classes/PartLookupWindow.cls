public with sharing class PartLookupWindow {  
  //------------------------------------------------------------------------------
  // Constants
  private final String[] CustomerNumbersList;
  private final static String DESC_SORTING_DIRECTION = ' ORDER BY Part_Number__c DESC LIMIT 25';
  private final static String ASC_SORTING_DIRECTION = ' ORDER BY Part_Number__c ASC LIMIT 25';
  //------------------------------------------------------------------------------
  // Properties
  public Part__c[] results { get; set; } // search results
  public String searchString { get; set; } // search keyword
  
  //------------------------------------------------------------------------------
  // Internal Properties
  public Boolean isSortDESC;
  // Constructor
  public PartLookupWindow() {
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');

    // query Account for determine customer numbers
    User u = [SELECT Id, Contact.Account.Available_Customer_Numbers__c
                FROM User
               WHERE Id = :UserInfo.getUserId()];

    if (null != u.Contact.Account.Available_Customer_Numbers__c) {
      CustomerNumbersList = u.Contact.Account.Available_Customer_Numbers__c.split(';');
    } else {
      CustomerNumbersList = new String[] {};
    }

    // at the first time, retrieve all records
    runSearch(); 
  }

  //-------------------------------------------
  // Methods

  /** performs the keyword search */
  public PageReference search() {
    runSearch();
    return null;
  }

  /** used by the visualforce page to send the link to the right dom element */
  public String getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }

  /** used by the visualforce page to send the link to the right dom element for the text box */
  public String getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }

  /**
  * @description used by the visualforce page to sort by part number 
  * @return  
  */
  public void sortPartNumber() {
	if (isSortDESC) {
		results = performSearch(searchString, ASC_SORTING_DIRECTION);   
		isSortDESC = false;            
	} else {
		results = performSearch(searchString, DESC_SORTING_DIRECTION);   
		isSortDESC = true;      
	} 
  }

  //-------------------------------------------
  // Helpers

  /** prepare the query and issue the search command */
  private void runSearch() {
	isSortDESC = false;
    results = performSearch(searchString, DESC_SORTING_DIRECTION);               
  } 

  // run the search and return the records found. 
  private List<Part__c> performSearch(string searchString, String sortDirection) {
    String soql = 'SELECT Id, Name, Part_Name__c, Part_Number__c, Customer_Number__c FROM Part__c'
                + ' WHERE Customer_Number__c IN :CustomerNumbersList';

    if (null != searchString && searchString.length() > 0) {
      soql = soql +  ' AND (Name LIKE \'%' + searchString +'%\' OR Part_Name__c LIKE \'%' + searchString + '%\')';
    }

    soql = soql + sortDirection;
    return (List<Part__c>) Database.query(soql); 
  }
}