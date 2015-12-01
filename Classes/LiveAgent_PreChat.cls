/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2013, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller used by the pre-chat form (live agent feature)

Class:              LiveAgent_PreChat
Author:             Rohdenburg S.
Date:               05/13/2013
Version:            1.0
Last Updated:       08/05/2013
    * 05/13/2013    SR - Stubbed
    * 05/17/2013    SR - Included the upload feature
    * 05/28/2013    SR - Implemented the Routing feature
    * 05/29/2013    SR - Cleanup + Test code
    * 06/05/2013    SR - Included the Infiniti chat button
    * 06/12/2013    SR - Commented the skill routing code out
    * 07/03/2013    SR - Removed the unused methods + cleaned up according to 
    				the code review
    * 07/10/2013    SR - Implemented the search by phone
    * 08/05/2013	SR - Modified for saving the PreChatData object even if the
    				provided email matches with a valid Contact
*/
public class LiveAgent_PreChat 
{
	// -------- Constants --------
	private final String CHAT_DATA_TITLE = ' Chat Data';
    private final String ERROR_EMAIL = '* The email address is invalid';
    private final String ERROR_FIRST_NAME_MANDATORY = '* First name is a ' + 
    	'mandatory field';
    
    // -------- Constructor --------
    public LiveAgent_PreChat() {
    	showErrorMessage = false;
		isSuccess = false;
	}
	
	// -------- Variables --------
	private ValidationUtility dataCheck = new ValidationUtility();
	
	// -------- Properties --------
	public String firstName {get; set;}
	public String lastName {get; set;}
	public String zipCode {get; set;}
	public String emailAddress {get; set;}
	public String phone {get; set;}
	public String contactId {get; set;}
	public String accountId {get; set;}
	public String preChatDataId {get; set;}
	public String errorMessage {get; set;}
	public Boolean isSuccess {get; set;}
	public Boolean showErrorMessage {get; set;}
	
	public String getCompletedName() {
		if (dataCheck.IsStringNullOrEmpty(lastName))
			return firstName;
		else
			return firstName + ' ' + lastName;
	}
	
	// -------- Methods --------
	// It submits the pre-chat form
	public void submitForm() {
		if (validateData()) {
			retrieveContact();
			showErrorMessage = false;
			isSuccess = true;
		}
		else {
			showErrorMessage = true;
		}
	}
	
	//It validates the format of the entered data
	private Boolean validateData() {
		if (dataCheck.IsStringNullOrEmpty(firstName)) {
			errorMessage = ERROR_FIRST_NAME_MANDATORY;
			return false;
		}
		
		if (!dataCheck.IsStringNullOrEmpty(emailAddress) && 
			!dataCheck.IsEmailFormat(emailAddress)) {
			errorMessage = ERROR_EMAIL;
			return false;
		}
		
		return true;		
	}
	
	// It retrieves the Contact associated to the informed email, the informed
	// phone or saves a pre chat data object
	private void retrieveContact() {
		if (!dataCheck.IsStringNullOrEmpty(emailAddress)) {
			List<Contact> chatContact = [SELECT Id, AccountId 
				FROM Contact 
				WHERE Email = :emailAddress
				LIMIT 1];
				
			if (chatContact.size() > 0) {
				contactId = chatContact[0].Id;
				accountId = chatContact[0].AccountId;
				//return;
			}
		}
		
		savePreChatForm();
	}
	
	// It records all the entered data on a Pre_Chat_Data__c object
	private void savePreChatForm() {
		Pre_Chat_Data__c preChatData = new Pre_Chat_Data__c();
		preChatData.Name = getCompletedName() + CHAT_DATA_TITLE;
		preChatData.First_Name__c = firstName;
		preChatData.Last_Name__c = lastName;
		preChatData.Zip_Code__c = zipCode;
		preChatData.Email_Address__c = emailAddress;
		preChatData.Phone__c = phone;
		
		if (!dataCheck.IsStringNullOrEmpty(accountId)) {
			preChatData.AccountId__c = accountId;
		}
		
		insert preChatData;
		preChatDataId = preChatData.Id;
	}
	
	// -------- Test --------
    static testMethod void ClassTest()
    {
    	LiveAgent_PreChat preChat = new LiveAgent_PreChat();
    	
        // Inserting the needed testing data
        Account testAccount = new Account();
        testAccount.Name = 'TeleTech';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'Sebastian';
        testContact.LastName = 'Rohdenburg';
        testContact.Email = 'srohdenburg@teletech.com.ar';
        insert testContact;
        
        // Submit a form without filling the mandatory fields
        preChat.submitForm();
        system.assert(preChat.showErrorMessage);
        
        // Submit a form with an invalid email
        preChat.firstName = 'Sebastian';
        preChat.emailAddress = '123';
        preChat.submitForm();
        system.assert(preChat.showErrorMessage);
        
        // Submit a form only filling the First Name
        preChat.firstName = 'Sebastian';
        preChat.emailAddress = null;
        preChat.submitForm();
        system.assert(!preChat.showErrorMessage);
        system.assert(preChat.isSuccess);
        
        // Submit a form with a valid contact email address
        preChat.firstName = 'Sebastian';
        preChat.emailAddress = 'srohdenburg@teletech.com.ar.qa';
        preChat.submitForm();
        system.assert(preChat.isSuccess);
        
        // Submit a form with a non-existing email address
        preChat.firstName = 'Sebastian';
        preChat.emailAddress = 'nonexisting@mail.com';
        preChat.submitForm();
        system.assert(preChat.isSuccess);
        
		// General Tests
        preChat.getCompletedName();
        preChat.lastName = 'Rohdenburg';
        preChat.getCompletedName();
    }
}