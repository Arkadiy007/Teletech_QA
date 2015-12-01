/***********************************************************************/
@isTest
public class DTS_Field_Inspection_Before_Test {
   
     static Account dealer = new Account();
       static final String DEALER_ID = '12345';
   
   
    static testMethod void Test1() {
            
        String dealerType = System.Label.AccRTDealer;
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];


        Stage_User__c su = new Stage_User__c();
        su.Email__c = 'test@email.com';
        insert su;
        
      
        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        dealer.DTS_A_Stage_User__c = su.id;
        insert dealer;

        DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c();
        dts.Dealer__c = dealer.id;

        insert dts;
  
      }
    
}