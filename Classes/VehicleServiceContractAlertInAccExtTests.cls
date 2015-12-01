@isTest
private class VehicleServiceContractAlertInAccExtTests {
	@istest
	static void notExistsVehicleServiceContract() {
		Account acc = new Account(Name = 'test Name');
		insert acc;

		Vehicle__c veh = new Vehicle__c(Name = '1N4AA51E39C829297');
		insert veh;

		Vehicle_Ownership_History__c voh = new Vehicle_Ownership_History__c(Vehicle__c = veh.id, Owner__c = acc.id);
		insert voh;

		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		VehicleServiceContractAlertInAccountExt ve = new VehicleServiceContractAlertInAccountExt(sc);
		test.startTest();
		System.assertEquals(false, ve.dispVehServContrs);
		test.stoptest();
	}
}