@isTest
public class StagePartObjectHelperTests{
	private static Id supplierRecordType = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Supplier');
	@isTest
	static void ifSupplierDetailsExsists_NewPartAndNewAccountShouldBeCreated(){
		Test.startTest();
			Stage_Part_Object__c stagePart = stagePartObjectCreator();
			stagePart.Supplier_Code__c = '01010';
			stagePart.Supplier_Name__c = 'NISSAN ENGINES';

			insert stagePart;

			System.assertEquals(1, [SELECT Count() FROM Account WHERE Supplier_Code__c != null]);
			System.assertEquals(1, [SELECT Count() FROM Part__c WHERE Supplier__c != null]);

		Test.stopTest();
	}

	@isTest
	static void ifAccountExists_DoNotCreateNew(){
		Test.startTest();
		Account acc = new Account(Name = 'NISSAN ENGINES', RecordTypeId = supplierRecordType, Supplier_Code__c = '01010' );
		insert acc;
			Stage_Part_Object__c stagePart = stagePartObjectCreator();
			stagePart.Supplier_Code__c = '01010';
			stagePart.Supplier_Name__c = 'NISSAN ENGINES';

			insert stagePart;

			System.assertEquals(1, [SELECT Count() FROM Account WHERE Supplier_Code__c != null]);
			System.assertEquals(1, [SELECT Count() FROM Part__c WHERE Supplier__c != null]);

		Test.stopTest();
	}
	@isTest
	static void ifSupplierDetailsExsistMultiple_NewPartAndNewAccountShouldBeCreated(){
		Test.startTest();
			Stage_Part_Object__c stagePart = stagePartObjectCreator();
			stagePart.Supplier_Code__c = '01010';
			stagePart.Supplier_Name__c = 'NISSAN ENGINES';
			stagePart.Part_Name__c = 'DRIVER COOLER';
		stagePart.Part_Number__c = 'PST-8889';
			
			Stage_Part_Object__c stagePart2 = stagePartObjectCreator();
			stagePart2.Supplier_Code__c = '01011';
			stagePart2.Supplier_Name__c = 'INFINITI ENGINES';

			List<Stage_Part_Object__c> stageParts = new list<Stage_Part_Object__c>();
			stageParts.add(stagePart);
			stageParts.add(stagePart2);
			insert stageParts;

			System.assertEquals(2, [SELECT Count() FROM Account WHERE Supplier_Code__c != null]);
			System.assertEquals(2, [SELECT Count() FROM Part__c WHERE Supplier__c != null]);

		Test.stopTest();
	}

	@isTest
	static void ifAccountExistMultiple_DoNotCreateNew(){
		Test.startTest();
		Account acc = new Account(Name = 'NISSAN ENGINES', RecordTypeId = supplierRecordType, Supplier_Code__c = '01010' );
		insert acc;
			Stage_Part_Object__c stagePart = stagePartObjectCreator();
			stagePart.Supplier_Code__c = '01010';
			stagePart.Supplier_Name__c = 'NISSAN ENGINES';
			stagePart.Part_Name__c = 'DRIVER COOLER';
		stagePart.Part_Number__c = 'PST-8889';

			Stage_Part_Object__c stagePart2 = stagePartObjectCreator();
			stagePart2.Supplier_Code__c = '01011';
			stagePart2.Supplier_Name__c = 'Infiniti ENGINES';

			List<Stage_Part_Object__c> stageParts = new list<Stage_Part_Object__c>();
			stageParts.add(stagePart);
			stageParts.add(stagePart2);
			insert stageParts;

			System.assertEquals(2, [SELECT Count() FROM Account WHERE Supplier_Code__c != null]);
			System.assertEquals(2, [SELECT Count() FROM Part__c WHERE Supplier__c != null]);

		Test.stopTest();
	}

	static Stage_Part_Object__c stagePartObjectCreator(){
		Stage_Part_Object__c stagePart = new Stage_Part_Object__c();
		stagePart.Base_Part_Number__c = 'BPN';
		stagePart.Destination_Country__c = 'UK';
		stagePart.Origin_Country__c = 'JAPAN';
		stagePart.Part_Name__c = 'ENGINE COOLER';
		stagePart.Part_Number__c = 'PST-8888';
		
		return stagePart;

	}

}