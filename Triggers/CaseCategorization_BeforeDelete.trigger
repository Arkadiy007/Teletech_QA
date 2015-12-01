/**********************************************************************
Name: CaseCategorization_BeforeDelete
Copyright � notice: Nissan Motor Company
======================================================
Purpose: 
Check if Case is Closed or Case Categorization is the last for Case, then it cannot be deleted
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Anna Koseikina        12/19/2014 Created
***********************************************************************/
trigger CaseCategorization_BeforeDelete on Case_Categorization__c (before delete) {
    List<Id> caseIds = new List<Id>();
    Map<Id,Case> cases = new Map<Id,Case>();
    Set<Case_Categorization__c> undeletableCategories = new Set<Case_Categorization__c>();
    Set<Case_Categorization__c> closedCaseCategories = new Set<Case_Categorization__c>();
    for (Case_Categorization__c cc: Trigger.old) {
        caseIds.add(cc.Case__c);
    }

    cases = new Map<Id,Case>([select Id, Categorizations__c, Status, IsClosed from Case where Id in :caseIds]);
    List<Case_Categorization__c> tempCategories = new List<Case_Categorization__c>();
    for(ID caseItem : cases.keySet()){
        Integer countOfCategories = 0;
        
        for (Case_Categorization__c cc: Trigger.old) {
            if(cases.get(caseItem).IsClosed){
                closedCaseCategories.add(cc);
                
            }else if(cc.Case__c == caseItem){
                countOfCategories++;
                tempCategories.add(cc);
            }           
        }

        if(countOfCategories > 0 && countOfCategories == cases.get(caseItem).Categorizations__c){
            undeletableCategories.add(tempCategories[tempCategories.size()-1]);         
        }
    }

    for(Case_Categorization__c cc : undeletableCategories){
        cc.addError('The Case Categorization cannot be deleted because it is the last one.');
    }

    for(Case_Categorization__c cc : closedCaseCategories){
        cc.addError('Case is Closed, Case Categorizations are locked.');
    }
}