public class VehicleServiceContractAlertInVehicleExt {
	public Id recId { get; set; }
	public Boolean dispVehServContrs { get; set; }
	public VehicleServiceContractAlertInVehicleExt(ApexPages.StandardController stdController) {
		dispVehServContrs = false;
		recId = stdController.getRecord().id;
		List <Vehicle_Service_Contract__c > vehServContrList = [SELECT id FROM Vehicle_Service_Contract__c WHERE Vehicle_Id__c = :recId LIMIT 1];
		if (!vehServContrList.isEmpty()) {
			dispVehServContrs = true;
		}

	}
}