@isTest(SeeAllData=True)
private class TestClaimFormAccessibility{
	public static TestMethod void testRunAs(){

	User u = [SELECT Id FROM User WHERE Username='claimform@qa-nna.cs16.force.com'];

	System.RunAs(u){

		List<Vehicle_Recall__c> vehRecList = [Select Master_Recall_Campaign__r.Name, Id From Vehicle_Recall__c where Vehicle__c = 'a0GF000000Au1KPMAZ'];
		
        System.debug(vehRecList);
	}

	}
}