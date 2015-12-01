@isTest
public class Part_Incident_ReportTriggerTests {
	
	@isTest
	static void insertShouldGiveCorrectNameToPIR(){

		Test.startTest();
			Part__c part = sObjectFactory.createPart();
			insert part;

			Part_Incident_Report__c pir = sObjectFactory.createPIR('PST-8888', part);

			insert pir;

			System.assertEquals('PST-8888', [SELECT Name FROM Part_Incident_Report__c LIMIT 1][0].Name);
		Test.stopTest();
	}

	@isTest
	static void insertShouldGiveCorrectNameToPIR_BULK(){
		Test.startTest();
			Part__c part = sObjectFactory.createPart();
			insert part;

			List<Part_Incident_Report__c> pirs = new List<Part_Incident_Report__c>();
			for (Integer i = 0; i < 200; i++)
			{
					pirs.add(sObjectFactory.createPIR('PST-8888'+String.valueOf(i), part));
			}
	

			insert pirs;

			System.assertEquals(200, [SELECT Count() FROM Part_Incident_Report__c ]);

			String allNames = '';

			for (Part_Incident_Report__c pir : [SELECT Name FROM Part_Incident_Report__c LIMIT 200]){
				allNames += pir.Name;
			}

			System.assert(allNames.contains('PST-888812PST-888813PST-888814'));
		Test.stopTest();
	}

	
}