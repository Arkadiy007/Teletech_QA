@isTest
public class ByVinsInAccount_TestUtil {
    public static Account testAccount;
    public static Account testDealer;
    public static List<Vehicle__c> testVehicles;
    public static List<Vehicle_Ownership_History__c> testOwners;
    public static List<String> testVINs;
    public final static String DEALER_CODE = 'DLRCD!@';
    public final static String CUSTOMER_ID = 'CUSTID!@';
    final static RecordType dealerType = [select id, name from recordtype where name =: System.Label.AccRTDealer and sobjecttype = 'Account' limit 1];
    final static RecordType personType = [select id, name from recordtype where name =: System.Label.AccRTMaritz and sobjecttype = 'Account' limit 1];
    /**
        create test data
    */
    public static void TestData() {
        testAccount = new Account();
        testAccount.FirstName = 'First';
        testAccount.LastName = 'Last';
        testAccount.RecordTypeID = personType.Id;
        testAccount.Customer_ID__c = CUSTOMER_ID;
        insert testAccount; 
        
        testDealer = new Account();
        testDealer.name = 'Test Dealer';
        testDealer.RecordTypeID = dealerType.Id;
        testDealer.Dealer_Code__C = DEALER_CODE;
        insert testDealer; 
        
        testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000102'));
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000103'));
        insert testVehicles;
        testVINs = new List<String> {'VIN01000010000101', 'VIN01000010000102', 'VIN01000010000103'};
        
        testOwners = new List<Vehicle_Ownership_History__c>();
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[0].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[1].ID));
        testOwners.add(new Vehicle_Ownership_History__c(Owner__c = testAccount.ID, Vehicle__c = testVehicles[2].ID));
        insert testOwners;
        
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingClaim = new Service_Repair_History__c();
        existingClaim.Vehicle_ID__c = testVehicles[0].ID;
        existingClaim.Dealer_Number__c = DEALER_CODE;
        existingClaim.Work_Order_Number__c = 'WO0@@';
        existingClaim.Claim_Line_Number__c = '01';
        existingClaim.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingClaim.Transaction_Date__c = DateTime.newInstance(1999, 1, 1);
        existingClaim.Warranty_Claim_Line_Business_ID__c = existingClaim.Dealer_Number__c + '_' + existingClaim.Work_Order_Number__c + '_' + existingClaim.Vehicle_Identification_Number__c + '_' + existingClaim.Claim_Line_Number__c;
        insert existingClaim;
        
        //testing upserting existing Master_Recall_Campaign__c 
        Master_Recall_Campaign__c existingMaster = new Master_Recall_Campaign__c();
        existingMaster.Recall_Identifier__c = 'RC0!!';
        existingMaster.Vehicle_Recall_Business_ID__c = 'RC0!!';
        existingMaster.Dealer_Submitted_Claim_Code__c = DEALER_CODE;
        insert existingMaster;
        
        //testing upserting existing Vehicle_Recall__c 
        Vehicle_Recall__c existingRecall = new Vehicle_Recall__c();
        existingRecall.Vehicle__c = testVehicles[0].ID;
        existingRecall.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingRecall.Recall_Identifier__c = 'RC0!!';
        existingRecall.Dealer_Submitted_Claim_Code__c = DEALER_CODE;
        existingRecall.Master_Recall_Campaign__c = existingMaster.ID;
        existingRecall.Vehicle_Recall_Business_ID__c = existingRecall.Recall_Identifier__c + '_' + existingRecall.Vehicle_Identification_Number__c;
        existingRecall.Effective_Date__c = System.today();
        insert existingRecall;
        
        //testing upserting existing Service_Repair_History__c 
        Service_Repair_History__c existingRO = new Service_Repair_History__c();
        existingRO.Vehicle_ID__c = testVehicles[0].ID;
        existingRO.Dealer_Number__c = DEALER_CODE;
        existingRO.Dealer_Repair_Order_Number__c = 'RO0@@';
        existingRO.Primary_Operation_Code__c = 'CC';
        existingRO.Pay_Type__c = 'PT';
        existingRO.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingRO.Warranty_Claim_Line_Business_ID__c = existingRO.Dealer_Number__c + '_' + existingRO.Dealer_Repair_Order_Number__c + '_' + existingRO.Vehicle_Identification_Number__c + '_' + existingRO.Primary_Operation_Code__c + '_' + existingRO.Pay_Type__c;
        insert existingRO;
        
        //testing upserting existing Vehicle_Service_Contract__c 
        Vehicle_Service_Contract__c existingVSC = new Vehicle_Service_Contract__c();
        existingVSC.Vehicle_Id__c = testVehicles[0].ID;
        existingVSC.VIN__c = 'VIN01000010000101';
        existingVSC.Policy_Number__c = 'PLCY##';
        insert existingVSC;
        
        //testing upserting existing Warranty_Information__c 
        Warranty_Information__c existingWarranty = new Warranty_Information__c();
        existingWarranty.Vehicle_ID__c = testVehicles[0].ID;
        existingWarranty.Vehicle_Identification_Number__c = 'VIN01000010000101';
        existingWarranty.WS_Warranty_Record_Type__c = 'ApplicableWarranty';
        existingWarranty.Warranty_Description__c = 'AW Description';
        existingWarranty.Warranty_Information_Business_ID__c = 'aw_' + existingWarranty.Vehicle_Identification_Number__c + '_' + existingWarranty.Warranty_Description__c;
        insert existingWarranty;
        
        //testing already exist comment text.
        Generic_Text__c[] existingVSCComments = new Generic_Text__c[] {
            new Generic_Text__c(VIN__c = 'VIN01000010000101',
                                Line_Number__c = 1,
                                Comment_Text__c = 'CommentText1 In Sf'),
            new Generic_Text__c(VIN__c = 'VIN01000010000101',
                                Line_Number__c = 2,
                                Comment_Text__c = 'CommentText2 In Sf')
        };
        insert existingVSCComments;
    }
}