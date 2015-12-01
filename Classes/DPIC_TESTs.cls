@isTest
public class DPIC_TESTs {
	static testMethod void ClassTest()
    {
        Account dealer = new Account();
		dealer.RecordTypeId = '012A0000000OfI0';
		dealer.Name = 'Sebastian';
		dealer.Dealer_Code__c = '1234';
		insert dealer;
		
		DPIC_WebToCase w2c = new DPIC_WebToCase();
        
        //Submit with empty fields
        w2c.submit();
        
        //Submit with an invalid email
        w2c.dealerCode = '1234';
        w2c.firstName = 'Sebastian';
        w2c.lastName = 'Rohdenburg';
        w2c.webCase.SuppliedPhone = '4200-1234';
        w2c.webCase.SuppliedEmail = 'XXX';
        w2c.webCase.Description = 'Testing an invalid email';        
        w2c.submit();
        
        //Submit with an invalid Dealer
        w2c.dealerCode = 'XXXX';
        w2c.firstName = 'Sebastian';
        w2c.lastName = 'Rohdenburg';
        w2c.webCase.SuppliedPhone = '4200-1234';
        w2c.webCase.SuppliedEmail = 'srohdenburg@teletech.com';
        w2c.webCase.Description = 'Testing an invalid email';        
        w2c.submit();
        
        //Submit with valid Information
        w2c.dealerCode = '1234';
        w2c.firstName = 'Sebastian';
        w2c.lastName = 'Rohdenburg';
        w2c.webCase.SuppliedPhone = '4200-1234';
        w2c.webCase.SuppliedEmail = 'srohdenburg@teletech.com';
        w2c.webCase.Description = 'Testing an invalid email';
        w2c.webCase.Part_Number_1__c = 'ABCD';        
        w2c.submit();
        
        //Checking the style recovery
        w2c.getStylesheetURL('Nissan');
    }
}