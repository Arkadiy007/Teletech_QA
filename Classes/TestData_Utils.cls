/**********************************************************************
Name: TestData_Utils
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is used as a helper class for initializing all 
test data to be used across all test classes.
 
======================================================
History: 

VERSION     AUTHOR        DATE       DETAIL
1.0 -     Vivek Batham   1/7/2015   Created 
***********************************************************************/
@isTest
public class TestData_Utils{
    
    public static User CreateUser(Id profileId){
    
      User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive= true,
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = profileId, UserPermissionsKnowledgeUser = true, UserPermissionsLiveAgentUser = true,
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', VCAN_Password__c='test1234' );
      
      return usr;
    }

     public static Account createTestDealer() {
     
      Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
      Id dealerRtId= rtInfosByName.get('Dealer').getRecordTypeId();
     
      Account dealer = new Account(RecordTypeId = dealerRtId, Name = 'Stage User Test Nissan Dealer', Dealer_Code__c = 'StgUserNissanDlr',
                                   Dealer_External_Id__c = 'StgUserNissanDlr_USA', Make_Name__c = 'Nissan', Region_Code__c = '24', District_Code__c = '05');
                                                              

      return dealer;
    }
    
    public static Account createPersonAccount(){
        State__c state = new State__c(Name= 'KY', Name__c = 'Kentucky', Order__c = 18);
        insert state;
        
        String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
        
        Account testAccount = new Account(FirstName = 'Person', PersonMailingPostalCode = '40202', PersonMailingState= 'KY', PersonMailingCity = 'Louisville',
                                         RecordTypeId = personTypeRTId, lastName = 'TestAccount',PersonEmail = 'test@abc.org');
        
        return testAccount;
    }
    
    public static Stage_FF_Hot_Alerts__c CreateAlertInstance(String surveyType, String caseType){
        Stage_FF_Hot_Alerts__c alert = new Stage_FF_Hot_Alerts__c();
        alert.SurveyId__c = '150285000000';
        alert.ContactId__c = '143770668';
        alert.SurveyType__c = surveyType;
        alert.Case_Type__c = caseType;
        alert.ReceivedDate__c = date.newInstance(2014,10,1);
        alert.EventDate__c = date.newInstance(2014,10,1);
        alert.BusinessUnit__c = 'Nissan';
        alert.VIN__c = '3N1CE2CP1EL407518';
        alert.DealerCode__c = '9080';
        alert.DealerName__c = 'ABELOFF NISSAN';
        alert.Region__c = '26';
        alert.NPS_Score_1__c = '4';
        alert.NPS_Type_1__c = 'Brand NPS';
        alert.NPS_Score_2__c = '3';
        alert.NPS_Type_2__c = 'Vehicle NPS';
        alert.FirstName__c = 'Erin';
        alert.LastName__c = 'Clark';
        alert.Address__c = '111 Mohawk Trl';
        alert.City__c = 'Albrightsville';
        alert.State__c = 'PA';
        alert.PostalCode__c = '18210';
        alert.DayTimePhone__c = '4847881872';
        alert.AgentID__c = 'TCS-MW';

        return alert;
    }
    
    public static Case CreateCase(Id recordTypeId){
    	Case caseRec = new Case();
        caseRec.Status = 'Open';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = recordTypeId;
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        
		return caseRec;
    }
        
}