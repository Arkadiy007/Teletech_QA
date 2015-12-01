@isTest
public class ContactHelperTests{
	
	public static Id supplierRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Supplier');
	public static Id plantRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Plant');

	@isTest
	static void ifMoreThanOnePrimaryContactAvailableForPlant_AddError(){
		Account plant = createPlantAccount();
		insert plant;

		Contact primaryContact = createContact(plant.Id);
		primaryContact.EQA_Records_Owner__c = true;
		insert primaryContact;

		Test.startTest();		
			Contact anotherPrimaryContact = createContact(plant.Id);
			anotherPrimaryContact.EQA_Records_Owner__c = true;
			
			try{
				insert anotherPrimaryContact;
			}
			catch(Exception e){
				System.assert(e.getMessage().contains('EQA Owner already exsists'));
			}
		Test.stopTest();
	}




	@isTest
	static void ifMoreThanOnePrimaryContactAvailableForSupplier_AddError(){
		Account supplier = createSupplierAccount();
		insert supplier;

		Contact primaryContact = createContact(supplier.Id);
		primaryContact.EQA_Records_Owner__c = true;
		insert primaryContact;

		Test.startTest();		
			Contact anotherPrimaryContact = createContact(supplier.Id);
			anotherPrimaryContact.EQA_Records_Owner__c = true;
			
			try{
				insert anotherPrimaryContact;
			}
			catch(Exception e){
				System.assert(e.getMessage().contains('EQA Owner already exsists'));
			}
		Test.stopTest();
	}


	@isTest
	static void ifMoreThanOnePrimaryContactAvailableInBulkForPlant_AddError(){
		Account plant = createPlantAccount();
		insert plant;

		Contact primaryContact = createContact(plant.Id);
		primaryContact.EQA_Records_Owner__c = true;
		insert primaryContact;

		Test.startTest();		
			List<Contact> contacts = new List<Contact>();

			for(Integer i = 0; i < 200; i++){
				contacts.add(createContact(plant.Id)); 
			}
			
			try{
				insert contacts;
			}
			catch(Exception e){
				System.assert(e.getMessage().contains('EQA Owner already exsists'));
			}
		Test.stopTest();
	}

	@isTest
	static void ifMoreThanOnePrimaryContactAvailableInBulkForSupplier_AddError(){
		Account supplier = createSupplierAccount();
		insert supplier;

		Contact primaryContact = createContact(supplier.Id);
		primaryContact.EQA_Records_Owner__c = true;
		insert primaryContact;

		Test.startTest();		
			List<Contact> contacts = new List<Contact>();

			for(Integer i = 0; i < 200; i++){
				contacts.add(createContact(supplier.Id)); 
			}
			
			try{
				insert contacts;
			}
			catch(Exception e){
				System.assert(e.getMessage().contains('EQA Owner already exsists'));
			}
		Test.stopTest();
	}

	private static Account createPlantAccount(){
		Account plant = new Account();
		plant.Name = 'Test Plant';
		plant.Plant__c = 'St. Petersburg';
		plant.RecordTypeId = plantRT;
		return plant;
	} 

	private static Account createSupplierAccount(){
		Account supplier = new Account();
		supplier.Name = 'Test Supplier';
		supplier.Supplier_Code__c = 'XXX-23';
		supplier.Global_Supplier_Number__c = 'GSN-1';
		supplier.RecordTypeId = supplierRT;
		return supplier;
	} 


	private static Contact createContact(Id accountId){
		Contact plantContact = new Contact();
		plantContact.Lastname = 'Bezuhoff';
		plantContact.AccountId = accountId;
		plantContact.Email = 'secret@secret.com';
		return plantContact;
	}
}