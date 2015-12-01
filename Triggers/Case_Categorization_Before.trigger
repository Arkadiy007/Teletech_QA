/**********************************************************************
Name: Case_Categorization_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Set Stage_Status__c value on the Case Categorization appropriately
when it is inserted or updated so it will be picked
up by batch processing.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Bryan Fry        11/22/2011 Created
1.1 -  Yuli Fintescu    02/09/2012 No new Case Categorizations after case is closed
1.2 -  Anna Koseykina   01/09/2015 Cannot edit Case Categorization if Case is reopened
***********************************************************************/
trigger Case_Categorization_Before on Case_Categorization__c (before insert, before update) {
	if(Trigger_Switch__c.getInstance(Label.Trigger_CaseCategorizationsBefore) != null && Trigger_Switch__c.getInstance(Label.Trigger_CaseCategorizationsBefore).Disabled__c){
    	return;
    }
    List<Id> caseIds = new List<Id>();
    Map<String, Case> caseMap = new Map<String, Case>();
    Map<Id,Case> cases;
    List<Case> updateCases = new List<Case>();
    
    for (Case_Categorization__c cc: Trigger.new) {
        caseIds.add(cc.Case__c);
    }
    
    cases = new Map<Id,Case>([select Id, Stage_Status__c, IsClosed, CA_CaseReopenCount__c,Categorizations__c, Status from Case where Id in :caseIds]);
    //All categories, which correspond to cases, needed to check similar case categorizations
    List<Case_Categorization__c> caseCategories = [SELECT ID, Case__c, Concern__c, Category__c, Subcategory__c, Symptom__c FROM Case_Categorization__c WHERE Case__c IN :caseIds];
    if(System.label.TurnOffStageStatus != 'Yes' && !CaseCategorizationBeforeHelper.hasAlreadyUpdatedCases()) {
        for(Case_Categorization__c cc: Trigger.new) {
            System.debug('putting in ' + cc.Id + '_' + cc.Case__c);
            caseMap.put(cc.Id + '_' + cc.Case__c, cases.get(cc.Case__c));
        }
        
        for (Case_Categorization__c cc: Trigger.new) {
            System.debug('getting out in ' + cc.Id + '_' + cc.Case__c);
            Case c = caseMap.get(cc.Id + '_' + cc.Case__c);         
            // Batch processing sets state to done, this trigger sets state
            // back to initial in that case.
            if (cc.Stage_Status__c == System.Label.Stage_Status_Done){
                cc.Stage_Status__c = System.Label.Stage_Status_None;
            }
            // Otherwise this is not a change as a result of batch processing
            // so set state to indicate a change has been made and needs to be
            // processed. If this is an insert, indicate this will be an Add.
            else if (Trigger.isInsert) {
                cc.Stage_Status__c = System.Label.Stage_Status_Add;
            }
            // If this is an update, we need to indicate it is an Update unless
            // the record is already flagged as an Add, meaning it was created
            // since the last time the batch process ran and should be reported
            // as an Add even with the updated changes being made.
            else if (Trigger.isUpdate && cc.Stage_Status__c != System.Label.Stage_Status_Add) {
                cc.Stage_Status__c = System.Label.Stage_Status_Update;
                 
            }
            
            if(cc.Stage_Status__c != System.Label.Stage_Status_Done && cc.Stage_Status__c != System.Label.Stage_Status_None) {
                if (c.Stage_Status__c != System.Label.Stage_Status_Add && c.Stage_Status__c != System.Label.Stage_Status_Update) {
                    c.Stage_Status__c = System.Label.Stage_Status_Update;
                    updateCases.add(c);
                }
            }
        }
        CaseCategorizationBeforeHelper.setAlreadyUpdatedCases();
        update updateCases;
    }
        
    for (Case_Categorization__c cc: Trigger.new) {
        System.debug('getting out in ' + cc.Id + '_' + cc.Case__c);
        Case c = cases.get(cc.Case__c);
        boolean duplicateFound = false;
        if(!c.IsClosed){
            for(Case_Categorization__c caseCategory : caseCategories){
                if(cc.Concern__c == caseCategory.Concern__c && cc.Category__c == caseCategory.Category__c && 
                    cc.Subcategory__c == caseCategory.Subcategory__c && cc.Symptom__c == caseCategory.Symptom__c && cc.Id != caseCategory.Id
                    && cc.Case__c == caseCategory.Case__c){
                    duplicateFound = true;
                }           
            }
        
            if(duplicateFound){
                cc.addError('This Category cannot be saved due to duplicated Category');
            }
        }
    }
    // ********** Case Categorization cannot be added to a closed case.
    if (Trigger.isInsert && system.label.TurnOffValidation != 'Yes') {
        Map<ID, Case> mapCases = new Map<ID, Case>(cases);
        for (Case_Categorization__c t: Trigger.new) {
            if (mapCases.containsKey(t.Case__c) && mapCases.get(t.Case__c).IsClosed)
                t.addError('Case Categorization cannot be added to a closed case.');
        }
    }

    // ********** Case Categorization cannot be edited on closed case.
    if (Trigger.isUpdate && system.label.TurnOffValidation != 'Yes') {
        Map<ID, Case> mapCases = new Map<ID, Case>(cases);
        String[] fieldNames = new String[] {'Concern__c', 'Category__c', 'Subcategory__c', 'Symptom__c'};
        for (Case_Categorization__c caseCat : Trigger.new) {
            Case_Categorization__c old = Trigger.oldMap.get(caseCat.Id);
            for (String field : fieldNames) {
                if (caseCat.get(field) != old.get(field) && caseCat.CaseWasClosed__c == true) {
                    if (mapCases.containsKey(caseCat.Case__c) && mapCases.get(caseCat.Case__c).CA_CaseReopenCount__c > 0){
                        caseCat.addError('Case Categorization cannot be edited on reopened Case if it was added before Case was closed.');
                    }
                }else if (caseCat.get(field) != old.get(field)) {
                    if (mapCases.containsKey(caseCat.Case__c)  && mapCases.get(caseCat.Case__c).IsClosed == true){
                        caseCat.addError('Case Categories cannot be changed for Closed Case');
                    }
                }
            }
        }
    }

    //get settings what case record types are available for TREAD logic
    TREAD_Codes_Logic__c treadCodeSettings = TREAD_Codes_Logic__c.getOrgDefaults();
    
    if(treadCodeSettings == null || treadCodeSettings.CasesTypes__c == null || treadCodeSettings.Calculate_TREAD__c==null || treadCodeSettings.User_ID_not_Fire__c == null){
        treadCodeSettings = getTreadCodesLogic();
    }
    Set<String> usersNotExecute = new Set<String> ();
    try {
        usersNotExecute.addAll(treadCodeSettings.User_ID_not_Fire__c.split(','));
    } catch(Exception e) {
    }

    if(treadCodeSettings.Calculate_TREAD__c == true && !usersNotExecute.contains(UserInfo.getUserId().substring(0, 15))){
        
        Set<ID> neededCases = new Set<ID>();
        for(Case_Categorization__c category : trigger.new){
            neededCases.add(category.Case__c);
        }

        if(neededCases.size() > 0){
            //get existing TREAD and Major Component codes
            Set<String> codes = new Set<String>();
            for(Code__c code : [SELECT Id, Code__c FROM Code__c WHERE (Type__c='Major Component Code' OR Type__c='TREAD Code')]){
                codes.add(code.Code__c);
            }
            
            //get subcategories, will be used later
            List<String> subcat = new List<String>();
            for(Case_Categorization__c category : trigger.new){
                subcat.add(category.Subcategory__c);
            }
            //get case category dependencies which have major component code and are in range by subcategories
            List<CaseCategory_Dependency__c> dependencies = [SELECT Id, Major_Component_Code__c ,Subcategory__c,Symptom__c FROM CaseCategory_Dependency__c WHERE Major_Component_Code__c != null AND Major_Component_Code__c != '' AND Subcategory__c IN :subcat];
            
            for(Case_Categorization__c category : trigger.new){
                boolean dependencyExists = false;
                for(CaseCategory_Dependency__c dependency : dependencies){                  
                    if(dependency.Subcategory__c == category.Subcategory__c && dependency.Symptom__c == category.Symptom__c){
                        dependencyExists = true;
                        if(codes.contains(dependency.Major_Component_Code__c) && (category.Major_Component_Code__c == null || !category.Major_Component_Code__c.equals(dependency.Major_Component_Code__c))){                                                               
                            category.Major_Component_Code__c = dependency.Major_Component_Code__c;
                            category.Category_Date__c = Date.today();  
                            
                        //if code is incorrect
                        }else if(!codes.contains(dependency.Major_Component_Code__c)){                      
                            category.Major_Component_Code__c = '';
                            category.Category_Date__c = null;                     
                        }

                        break;
                    }
                }

                if(!dependencyExists){
                    category.Major_Component_Code__c = '';
                    category.Category_Date__c = null;
                }
            }

            for(ID caseItem : neededCases){
                boolean report = false;
                for(Case_Categorization__c category : trigger.new){
                    if(category.Major_Component_Code__c != null && !category.Major_Component_Code__c.equals('') && category.Case__c == caseItem){
                        report = true;
                    }                   
                }               

                //check if case is tread reportable 
                if(report == false){                            
                    System.debug('Error, Case is not TREAD reportable! ID: ' + caseItem);
                }
            }
        }
    }

    private static TREAD_Codes_Logic__c getTreadCodesLogic(){
        TREAD_Codes_Logic__c treadCodeSetting = TREAD_Codes_Logic__c.getOrgDefaults();
        if (treadCodeSettings == null){
            treadCodeSetting  = new TREAD_Codes_Logic__c();
        }
        treadCodeSetting.CasesTypes__c = 'CA,CA Closed Case,T5,CA Email Infiniti,CA Email Nissan,CA Sales & Service';
        treadCodeSetting.Calculate_TREAD__c = true;
        treadCodeSetting.User_ID_not_Fire__c = '005A0000001Y7Ek'; //Manage Service ID
        upsert treadCodeSetting;
        treadCodeSetting = TREAD_Codes_Logic__c.getOrgDefaults();
        return treadCodeSetting;
    }
}