@isTest
private class VehicleServiceContractAlertInVehExtTests {
	@istest
	static void notExistsVehicleServiceContract() {
		Account acc = new Account(Name = 'test Name');
		insert acc;

		Vehicle__c veh = new Vehicle__c(Name = '1N4AA51E39C829297');
		insert veh;

		ApexPages.StandardController sc = new ApexPages.StandardController(veh);
		VehicleServiceContractAlertInVehicleExt ve = new VehicleServiceContractAlertInVehicleExt(sc);
		test.startTest();
		System.assertEquals(false, ve.dispVehServContrs);
		test.stoptest();
	}
}