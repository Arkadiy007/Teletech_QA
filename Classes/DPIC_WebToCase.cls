/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller for submitting a DPIC case from a web page

Class:              DPIC_WebToCase
Author:             Rohdenburg S.
Date:               04/28/14
Version:            1.0
Last Updated:       04/28/14
    * 04/28/14      SR - Created
*/

public class DPIC_WebToCase
{
    // -------- Constants --------
    private final String ORIGIN_WEB = 'Web';
    private final String CASE_REASON = 'DPIC';
    private final String DEFAULT_OWNER = 'DPIC Call Queue';
    private final String RECORD_TYPE_DPIC = 'DPIC';
    private final String RECORD_TYPE_DEALER = 'Dealer';
    private final String ERROR_MANDATORY_FIELDS = '* Dealer Code, First ' +
        'Name, Last Name, Email, Phone, and Comments are mandatory fields';
    private final String ERROR_INVALID_EMAIL = '* The Email value is invalid';
    private final String ERROR_INVALID_DEALER = '* The provided Dealer Code ' + 
        'is invalid';
    private final String MESSAGE_SUCCESSFUL = 'The Case has been ' +
        'succesfully created';
    private final String URL_STYLE = 'style';
    private final String RESOURCE_NAME = 'DPIC_Style';

    // -------- Constructor --------
    public DPIC_WebToCase(){
        showMainForm = true;
        
        Group defaultQueue = [SELECT Id 
            FROM Group 
            WHERE Name = :DEFAULT_OWNER 
            AND Type = 'Queue'];
            
        webCase = new Case();
        webCase.Origin = ORIGIN_WEB;
        webCase.Reason = CASE_REASON;
        webCase.OwnerId = defaultQueue.Id;
        webCase.RecordTypeId = 
            Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(
                RECORD_TYPE_DPIC).getRecordTypeId();
        
        Map<String, String> urlParameters = 
            Apexpages.CurrentPage().getParameters();
        
        if (urlParameters.containsKey(URL_STYLE) && 
            !dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_STYLE))){
            urlStyle = getStylesheetURL(urlParameters.get(URL_STYLE));
        }
    }

    // -------- Variables --------
    private ValidationUtility datacheck = new ValidationUtility();
    
    // -------- Properties --------
    public Case webCase {get; set;}
    public Account enteredDealer {get; set;}
    public String dealerCode {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String errorMessage {get; set;}
    public Boolean showErrorMessage {get; set;}
    public Boolean showMainForm {get; set;}
    public String urlStyle {get; set;}
    
    // -------- Methods --------
    // It submits the entered information into a case
    public void submit() {
        showErrorMessage = false;
        enteredDealer = null;
        
        if (validateParameters()) {
            webCase.SuppliedName = firstName + ' ' + lastName;
            webCase.AccountId = enteredDealer.Id;
            
            Contact currentContact = getContact(firstName, lastName, 
            	webCase.SuppliedPhone, webCase.SuppliedEmail, 
            	enteredDealer.Id);
            	
            webCase.ContactId = currentContact.Id;
            
            if (!datacheck.IsStringNullOrEmpty(webCase.Part_Number_1__c)) {
            	webCase.Subject = webCase.Part_Number_1__c;
            }
            
            insert webCase;
            
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.INFO, MESSAGE_SUCCESSFUL);
            ApexPages.addMessage(msg);
            
            showMainForm = false;
        }
        else {
            showErrorMessage = true;
        }
    }
    
    // It validates the information provided by the user
    private Boolean validateParameters() {
        if (datacheck.IsStringNullOrEmpty(dealerCode) ||
            datacheck.IsStringNullOrEmpty(firstName) ||
            datacheck.IsStringNullOrEmpty(lastName) ||
            datacheck.IsStringNullOrEmpty(webCase.SuppliedPhone) ||
            datacheck.IsStringNullOrEmpty(webCase.SuppliedEmail) ||
            datacheck.IsStringNullOrEmpty(webCase.Description)) {
            errorMessage = ERROR_MANDATORY_FIELDS;
            return false;
        }
        
        if (!datacheck.IsEmailFormat(webCase.SuppliedEmail)) {
            errorMessage = ERROR_INVALID_EMAIL;
            return false;
        }
        
        if (!datacheck.IsStringNullOrEmpty(dealerCode)) {
            List<Account> dealers = [SELECT Id
                FROM Account
                WHERE RecordType.Name = :RECORD_TYPE_DEALER
                AND Dealer_Code__c = :dealerCode];
                
            if (dealers == null || dealers.size() == 0) {
                errorMessage = ERROR_INVALID_DEALER;
                return false;   
            }
            else {
                enteredDealer = dealers[0]; 
            }
        }
        
        return true;
    }
    
    // Pass the resource name
    public String getStylesheetURL(String stylesheetName){
        String resourceURL = '';
        
        List<StaticResource> resourceList = [SELECT Name, SystemModStamp 
            FROM StaticResource 
            WHERE Name = :RESOURCE_NAME];

        if(resourceList.size() == 1){
            resourceURL += Site.getPathPrefix();
            resourceURL += '/resource/';
            resourceURL += resourceList[0].SystemModStamp.getTime();
            resourceURL += '/' + RESOURCE_NAME; 
            resourceURL += '/' + stylesheetName + '.css';
        }
        
        return resourceURL;
    }
    
    // Search for an existing contact, or creates one
    private Contact getContact(String firstName, String lastName, 
    	String contactPhone, String contactEmail, String dealerId) {
    	Contact associatedContact = new Contact();
    	
    	List<Contact> existingContacts = [SELECT Id, FirstName, LastName
    		FROM Contact
    		WHERE Email = :contactEmail];
    		
    	if (existingContacts != null && existingContacts.size() > 0) {
    		associatedContact = existingContacts[0];
    		
    		if (existingContacts.size() > 1) {
    			for (Contact c : existingContacts) {
    				if (c.FirstName == firstName && c.LastName == lastName) {
    					associatedContact = c;
    					break;
    				}
    			}
    		}
    	}
    	else {
    		associatedContact.AccountId = dealerId;
    		associatedContact.FirstName = firstName;
    		associatedContact.LastName = lastName;
    		associatedContact.Phone = contactPhone;
    		associatedContact.Email = contactEmail;
    		insert associatedContact;
    	}

		return associatedContact;
    }
}