/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Case_Before_Batch_Test {

    static testMethod void myUnitTest() {
    	RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
        Account testDealer = new Account(Name = 'TestDealer', RecordTypeId = dealerType.Id, Dealer_Code__c = 'DLR##');
        insert testDealer; 
        
		/*UserRole r = [Select id from UserRole where Name=:System.Label.ServiceMarketing];
		User manager = [Select id , LanguageLocaleKey, LocaleSidKey, TimeZoneSidKey, EmailEncodingKey, ProfileId from user where isactive=true and Profile.Name = 'Managed Services' limit 1];
		User u = new User(UserRoleId = r.id, ManagerId = manager.id, Username='john@123T%^.com', LastName = 'test', Email='test@test.com', Alias='test', 
		                CommunityNickname='test', TimeZoneSidKey = manager.TimeZoneSidKey, LocaleSidKey = manager.LocaleSidKey, EmailEncodingKey = manager.EmailEncodingKey,
		                ProfileId = manager.ProfileId, LanguageLocaleKey = manager.LanguageLocaleKey, ZCA_Id__c = 'ZCA#@');
		insert u;
		User uia = new User(UserRoleId = r.id, ManagerId = manager.id, Username='ZCAIA#@123T%^.com', LastName = 'ZCAIA#@', Email='ZCAIA#@test.com', Alias='ZCAIA#@', 
		                CommunityNickname='ZCAIA#@', TimeZoneSidKey = manager.TimeZoneSidKey, LocaleSidKey = manager.LocaleSidKey, EmailEncodingKey = manager.EmailEncodingKey,
		                ProfileId = manager.ProfileId, LanguageLocaleKey = manager.LanguageLocaleKey, ZCA_Id__c = 'ZCAIA#@', IsActive = false);
		insert uia;*/
	  	List<CAD_Loader__c> cads = new List<CAD_Loader__c>{
	  		new CAD_Loader__c(Consumer_First_Name__c = 'First1',
                              Consumer_Last_Name__c = 'Last1',
                              Document_ID__c = 'CA!@#$%^&',
                              Full_Model_Year__c = '095',
                              VIN_Number__c = '12345678901234567',
                              SERVICING_DEALER_NUMBER__c = 'DLR##',
                              CA_ACTION_CODE__c = 'DL2Y',
                              DIST_MGR_NAME__c = '*ZCA#@',
                              Channel_Designation_Code__c = 'I'),
           new CAD_Loader__c(Consumer_First_Name__c = 'First2',
	                          Consumer_Last_Name__c = 'Last2',
                              Document_ID__c = 'CA&^%$#@!',
	                          Full_Model_Year__c = '095',
	                          VIN_Number__c = '12345678907654321',
	                          SERVICING_DEALER_NUMBER__c = 'DLR$$',
	                          CA_ACTION_CODE__c = '@#$%',
                              DIST_MGR_NAME__c = 'ZCAIA#@',
	                          Channel_Designation_Code__c = 'N'),
           new CAD_Loader__c(Consumer_First_Name__c = 'First2',
	                          Consumer_Last_Name__c = 'Last2',
                              Document_ID__c = 'CA@#*&^%^',
	                          Full_Model_Year__c = '095',
	                          VIN_Number__c = '12345123456654321',
	                          SERVICING_DEALER_NUMBER__c = '',
	                          CA_ACTION_CODE__c = '',
                              DIST_MGR_NAME__c = '',
	                          Channel_Designation_Code__c = 'N')
		}; 
	    
	    Test.startTest();
		
	    	insert cads; 
			List<Case> cases = [Select ID, OwnerID, Owner.Name, Case_External_Id__c, Channel_Designation_Code__c,
									AccountID, Account.FirstName, Account.LastName, ContactID, Contact.Name, 
									Service_Dealer_Number__c, Servicing_Dealer__c, Servicing_Dealer__r.Name,
									Who_Took_Action__c, How_was_the_action_taken__c, What_action_was_taken__c,
									Legacy_Root_Cause__c, Legacy_Root_Cause_2__c
								From Case 
								Where Case_External_Id__c in ('CA!@#$%^&', 'CA&^%$#@!', 'CA@#*&^%^')];
			for (Case c : cases) {
				System.Debug('*** OwnerID ' + c.Owner.Name + 
								' Case_External_Id__c ' + c.Case_External_Id__c + 
								' \nChannel_Designation_Code__c ' + c.Channel_Designation_Code__c + 
								' \nAccountID ' + c.AccountID + 
								' \nAccount.FirstName ' + c.Account.FirstName + 
								' \nAccount.LastName ' + c.Account.LastName + 
								' \nContact.Name ' + c.Contact.Name + 
								' \nService_Dealer_Number__c ' + c.Service_Dealer_Number__c + 
								' \nServicing_Dealer__c ' + c.Servicing_Dealer__c + 
								' \nServicing_Dealer__r.Name ' + c.Servicing_Dealer__r.Name + 
								' \nLegacy_Root_Cause__c ' + c.Legacy_Root_Cause__c + 
								' \nLegacy_Root_Cause_2__c ' + c.Legacy_Root_Cause_2__c + 
								' \nWho_Took_Action__c ' + c.Who_Took_Action__c + 
								' \nHow_was_the_action_taken__c ' + c.How_was_the_action_taken__c + 
								' \nWhat_action_was_taken__c ' + c.What_action_was_taken__c);
			}
			
			cases[0].Legacy_Root_Cause__c = 'SRPP';
            cases[0].Legacy_Root_Cause_2__c = '20121221';
			
			cases[1].Legacy_Root_Cause__c = '20121221';
            cases[1].Legacy_Root_Cause_2__c = 'SRPP';

			cases[2].Legacy_Root_Cause__c = '20121221';
            cases[2].Legacy_Root_Cause_2__c = '20121221';
			update cases;
			
			update cads;
			
			cases = [Select ID, OwnerID, Owner.Name, Case_External_Id__c, Channel_Designation_Code__c,
									AccountID, Account.FirstName, Account.LastName, ContactID, Contact.Name, 
									Service_Dealer_Number__c, Servicing_Dealer__c, Servicing_Dealer__r.Name,
									Who_Took_Action__c, How_was_the_action_taken__c, What_action_was_taken__c,
									Legacy_Root_Cause__c, Legacy_Root_Cause_2__c
								From Case 
								Where Case_External_Id__c in ('CA!@#$%^&', 'CA&^%$#@!', 'CA@#*&^%^')];
			for (Case c : cases) {
				System.Debug('&&& OwnerID ' + c.Owner.Name + 
								' \nCase_External_Id__c ' + c.Case_External_Id__c + 
								' \nChannel_Designation_Code__c ' + c.Channel_Designation_Code__c + 
								' \nAccountID ' + c.AccountID + 
								' \nAccount.FirstName ' + c.Account.FirstName + 
								' \nAccount.LastName ' + c.Account.LastName + 
								' \nContact.Name ' + c.Contact.Name + 
								' \nService_Dealer_Number__c ' + c.Service_Dealer_Number__c + 
								' \nServicing_Dealer__c ' + c.Servicing_Dealer__c + 
								' \nServicing_Dealer__r.Name ' + c.Servicing_Dealer__r.Name + 
								' \nLegacy_Root_Cause__c ' + c.Legacy_Root_Cause__c + 
								' \nLegacy_Root_Cause_2__c ' + c.Legacy_Root_Cause_2__c + 
								' \nWho_Took_Action__c ' + c.Who_Took_Action__c + 
								' \nHow_was_the_action_taken__c ' + c.How_was_the_action_taken__c + 
								' \nWhat_action_was_taken__c ' + c.What_action_was_taken__c);
			}
			
	    Test.stopTest();
    }
}