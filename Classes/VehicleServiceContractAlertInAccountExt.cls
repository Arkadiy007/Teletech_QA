public class VehicleServiceContractAlertInAccountExt {
	public Id recId { get; set; }
	public Boolean dispVehServContrs { get; set; }
	public VehicleServiceContractAlertInAccountExt(ApexPages.StandardController stdController) {
		dispVehServContrs = false;
		recId = stdController.getRecord().id;
		List <Vehicle_Ownership_History__c > vehOwnerShipList = [SELECT id, Vehicle__c FROM Vehicle_Ownership_History__c WHERE Owner__c = :recId];
		Set<String> vehicleIds = getFieldValues(vehOwnerShipList, Vehicle_Ownership_History__c.Vehicle__c);
		List <Vehicle_Service_Contract__c > vehServContrList = [SELECT id FROM Vehicle_Service_Contract__c WHERE Vehicle_Id__c IN :vehicleIds LIMIT 1];

		if (!vehServContrList.isEmpty()) {
			dispVehServContrs = true;
		}

	}

	public Set<String> getFieldValues(SObject[] objects, SObjectField field) {
		return getFieldValues(objects, field.getDescribe().getName());
	}

	public Set<String> getFieldValues(SObject[] objects, String field) {
		Set<String> result = new Set<String> ();
		if (objects != null && !objects.isEmpty()) {
			for (SObject o : objects) {
				result.add(String.valueOf(o.get(field)));
			}
			result.remove(null);
		}
		return result;
	}
}