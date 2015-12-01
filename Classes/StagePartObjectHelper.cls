public class StagePartObjectHelper {
	private static Map<String, Id> supplierIdBySupplierCodeAndName;
	private static Id supplierRecordType = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Supplier');

	public static void buildParts(List<Stage_Part_Object__c> triggerNew){
		selectOrCreateAccountsForSuppliers(triggerNew);

		List<Part__c> buildedParts = new List<Part__c>();

		for(Stage_Part_Object__c part : triggerNew){
			Part__c realPart = buildPart(part);
			if(realPart != null){
				buildedParts.add(realPart);
			}
		}

		if(buildedParts.size() > 0){
			upsert buildedParts Part_Number__c;
		}
	}

	private static void selectOrCreateAccountsForSuppliers(List<Stage_Part_Object__c> triggerNew){
		supplierIdBySupplierCodeAndName = new Map<String, Id>();
		
		Set<String> supplierCodes = getSupplierCodesSet(triggerNew);
		Set<String> supplierNames = getSupplierNamesSet(triggerNew);

		for(Account exsistingSupplier : [SELECT Id, Name, Supplier_Code__c FROM Account WHERE Name IN:supplierNames AND Supplier_Code__c IN:supplierCodes AND RecordTypeId = :supplierRecordType]){
			supplierIdBySupplierCodeAndName.put(exsistingSupplier.Supplier_Code__c+exsistingSupplier.Name, exsistingSupplier.Id);
		}

		List<Account> newSuppliers = getNewSuppliersWithId(triggerNew);

		for(Account newSupplier : newSuppliers){
			supplierIdBySupplierCodeAndName.put(newSupplier.Supplier_Code__c+newSupplier.Name, newSupplier.Id);
		}
	}

	private static Part__c buildPart(Stage_Part_Object__c stagePart){
		Part__c part = new Part__c();
		part.Abolish_Date__c = stagePart.Abolish_Date__c;
		part.Base_Part_Number__c = stagePart.Base_Part_Number__c;
		part.Customer_Number__c = stagePart.Customer_Number__c;
		part.Destination_Country__c = stagePart.Destination_Country__c;
		part.HARM_Code__c = stagePart.HARM_Code__c;
		part.Name = stagePart.Name;
		part.Origin_Country__c = stagePart.Origin_Country__c;
		part.Part_Name__c = stagePart.Part_Name__c;
		part.Part_Number__c = stagePart.Part_Number__c;
		part.Name = stagePart.Part_Number__c;

		if(supplierIdBySupplierCodeAndName.containsKey(stagePart.Supplier_Code__c+stagePart.Supplier_Name__c)){
			part.Supplier__c = supplierIdBySupplierCodeAndName.get(stagePart.Supplier_Code__c+stagePart.Supplier_Name__c);
			stagePart.Status__c = 'Records Created';
		}
		else{
			stagePart.Status__c = 'Error';
		}
		return part;
	}

	private static List<Account> getNewSuppliersWithId(List<Stage_Part_Object__c> triggerNew){
		Map <String, Account> newSuppliers = new Map <String, Account>();

		for(Stage_Part_Object__c stagePartObject : triggerNew){
			if(!supplierIdBySupplierCodeAndName.containsKey(stagePartObject.Supplier_Code__c+stagePartObject.Supplier_Name__c) && String.isNotBlank(stagePartObject.Supplier_Name__c) ){
				newSuppliers.put(stagePartObject.Supplier_Code__c+stagePartObject.Supplier_Name__c, new Account(Name = stagePartObject.Supplier_Name__c, RecordTypeId = supplierRecordType, Supplier_Code__c = stagePartObject.Supplier_Code__c, Global_Supplier_Number__c = stagePartObject.Global_Supplier_Number__c));
			}
		}

		insert newSuppliers.values();
		return newSuppliers.values();
	}

	private static Set<String> getSupplierNamesSet(List<Stage_Part_Object__c> triggerNew){
		Set<String> supplierNames = new Set<String>();

		for(Stage_Part_Object__c stagePartObject : triggerNew){
			supplierNames.add(stagePartObject.Supplier_Name__c);
		}

		return supplierNames;
	}

	private static Set<String> getSupplierCodesSet(List<Stage_Part_Object__c> triggerNew){
		Set<String> supplierCodesSet = new Set<String>();

		for(Stage_Part_Object__c stagePartObject : triggerNew){
			supplierCodesSet.add(stagePartObject.Supplier_Code__c);
		}

		return supplierCodesSet;
	}
}