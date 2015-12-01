public class SortingReportItemHandler{
	@Testvisible
    private static final String DUPLICATE_PIR_MSG = 'Duplicate PIR Number for Sorting Report Record';

    public static void checkForDuplicatePIRNumber(List<Sorting_Report_Item__c> triggerNew){
        Map<Id, Set<String>> exsistingPIRNumbersForSR = getExsistingPIRNumbersForSR(triggerNew);

		for (Sorting_Report_Item__c item : triggerNew){
			if (exsistingPIRNumbersForSR.containsKey(item.Sorting_Report__c)){
				if (exsistingPIRNumbersForSR.get(item.Sorting_Report__c).contains(item.PIR_Number__c)){
					item.addError(DUPLICATE_PIR_MSG);
				}
			}
		}
     
    }

    private static Map<Id, Set<String>>  getExsistingPIRNumbersForSR(List<Sorting_Report_Item__c> triggerNew){
        Set<Id> sortingReportIds = getSortingReportIds(triggerNew);

		Map<Id, Set<String>> exsistingPIRNumbersForSR = new Map<Id, Set<String>>();

		for (Sorting_Report_Item__c item : [SELECT Id, Sorting_Report__c, PIR_Number__c FROM Sorting_Report_Item__c WHERE Sorting_Report__c IN :sortingReportIds AND Id NOT IN :triggerNew]){
			if (!exsistingPIRNumbersForSR.containsKey(item.Sorting_Report__c)){
				Set<String> pirNumbers = new Set<String>();
				pirNumbers.add(item.PIR_Number__c);
				exsistingPIRNumbersForSR.put(item.Sorting_Report__c, pirNumbers);
			}
			else{
				exsistingPIRNumbersForSR.get(item.Sorting_Report__c).add(item.PIR_Number__c);
			}
		}

		return exsistingPIRNumbersForSR;
    }

	private static Set<Id> getSortingReportIds(List<Sorting_Report_Item__c> triggerNew){
		Set<Id> sortingReportIds = new Set<Id>();

		for (Sorting_Report_Item__c item : triggerNew){
			sortingReportIds.add(item.Sorting_Report__c);
		}

		return sortingReportIds;
	}
 }