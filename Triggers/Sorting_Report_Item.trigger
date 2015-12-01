trigger Sorting_Report_Item on Sorting_Report_Item__c (after insert, after update)  {
	if((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isAfter)){
		SortingReportItemHandler.checkForDuplicatePIRNumber(Trigger.New);
	}

 }