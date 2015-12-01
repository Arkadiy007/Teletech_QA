@isTest
public class SortingReportItemHandlerTests {

	@isTest
	static void testCreationOfDuplicatesNotWorkingForSRIPointingAtTheSamePIR(){
		Test.startTest();
			Part__c part = sObjectFactory.createPart();
			insert part;

			Part_Incident_Report__c pir = sObjectFactory.createPIR('test', part);
			pir.Sorting_Required__c = true;
			pir.Average_Sort_Time_Per_Part__c = 10;
			insert pir;

			Sorting_Report__c sortingReport = sObjectFactory.createSR(part);
			insert sortingReport;

			Sorting_Report_Item__c sortingReportOne = sObjectFactory.createSRI(sortingReport, pir);
			insert sortingReportOne;

			System.assertEquals(1, [SELECT Count() FROM Sorting_Report_Item__c], 'No Duplicates here - insert should pass well');

			
			Sorting_Report_Item__c sortingReportTwo = sObjectFactory.createSRI(sortingReport, pir);
			
			try {	        
				insert sortingReportTwo;
			}
			catch (DMLException e){
				System.assert(e.getMessage().contains(SortingReportItemHandler.DUPLICATE_PIR_MSG), 'Should Be Duplicate PIR Error MSG Here');
			}
		

			System.assertEquals(1, [SELECT Count() FROM Sorting_Report_Item__c], 'Duplicate should not be inserted - two sorting report items points at the same SR and PIR');

		Test.stopTest();
	}

	@isTest
	static void testCreationOfDuplicatesNotWorkingForSRIPointingAtTwoPIROnUpdate(){
		Test.startTest();
			Part__c part = sObjectFactory.createPart();
			insert part;

			Part_Incident_Report__c pir = sObjectFactory.createPIR('test', part);
			pir.Sorting_Required__c = true;
			pir.Average_Sort_Time_Per_Part__c = 10;
			insert pir;

			Part_Incident_Report__c pir2 = sObjectFactory.createPIR('test 2', part);
			pir2.Sorting_Required__c = true;
			pir2.Average_Sort_Time_Per_Part__c = 10;
			insert pir2;

			Sorting_Report__c sortingReport = sObjectFactory.createSR(part);
			insert sortingReport;

			Sorting_Report_Item__c sortingReportOne = sObjectFactory.createSRI(sortingReport, pir);
			insert sortingReportOne;

			System.assertEquals(1, [SELECT Count() FROM Sorting_Report_Item__c], 'No Duplicates here - insert should pass well');

			
			Sorting_Report_Item__c sortingReportTwo = sObjectFactory.createSRI(sortingReport, pir2);
			insert sortingReportTwo;

			System.assertEquals(2, [SELECT Count() FROM Sorting_Report_Item__c], 'Still No Duplicates On That Point');

			sortingReportTwo.Part_Incident_Report__c = pir.Id;
			try {	        
				update sortingReportTwo;
			}
			catch (DMLException e){
				System.assert(e.getMessage().contains(SortingReportItemHandler.DUPLICATE_PIR_MSG), 'Should Be Duplicate PIR Error MSG Here');
			}
		
			System.assertEquals(pir2.id, [SELECT Part_Incident_Report__c FROM Sorting_Report_Item__c WHERE Id =:sortingReportTwo.id][0].Part_Incident_Report__c, 'That Update should fail - to prevent duplicates');


		Test.stopTest();
	}
	
}