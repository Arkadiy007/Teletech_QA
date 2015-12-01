/**********************************************************************
Name: Controller_CaseCategorization
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
Controller of CaseCategorization page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 09/06/2011 Created
1.01 - Anna Koseykina 18/12/2014 Added logic for checking if Case is Closed before saving
1.02 - Vladimir Martynenko 08/06/2015 Moved Case categorization logic to NCI Sandbox
***********************************************************************/
public with sharing class Controller_NCICaseCategorization {
    //"3, 3, 4": initial number of category lines is 3, than increment by 3, than by 4 
    private static final Integer[] LEVELS = new Integer[] {3, 3, 4};
    
    private ApexPages.StandardController stdController;
    private NCI_Case_Categorization__c caseCategoryRecord;
    public Case theCase {get; set;}
//    public List<CaseCategorizationLineItem> lineItems = new List<CaseCategorizationLineItem>()[10];
    //each item Case_Categorization__c in this list is assigned to a CaseCategorizationLineItem component on the page
    public List<NCI_Case_Categorization__c> CaseCategorizations {get; set;}
    
    //constructor: if empty categorization for the case, initially there are should be 3 emplty line items displayed.
    //if not, existing categorizations + empty lines to fill up to the right level
    public Controller_NCICaseCategorization(ApexPages.StandardController controller) {
        stdController = controller;
        retrieveCaseCategorizations();
        lineItemsPopulated = true;
    }

    public Boolean lineItemsPopulated{
    get;
    set;}
    
//------------------------------------------------------>
//properties and functions facilitate the add more button.
//------------------------------------------------------>
    private Integer currentLevelIndex = 0;
    public Integer CurrentLineCounts {get; private set;}
    
    //caption of Add More button. add 3 more than add 4 more.
    public Integer NumberOfMoreCategories {
        get {
            return currentLevelIndex >= LEVELS.size() - 1 ? 0 : LEVELS[currentLevelIndex + 1];
        }
    }
    
    //increase the currentLevelIndex
    public PageReference doAddMoreCategories() {
        currentLevelIndex++;
        
        //line counts of current level
        Integer lineCounts = 0;
        for (Integer i = 0; i <= currentLevelIndex; i++)
            lineCounts = lineCounts + LEVELS[i];
        CurrentLineCounts = lineCounts;
        
        //fill CaseCategories with empty CaseCategory up to the current level.
        addCategoryToLevel();
        return null;
    }
    
    private void addCategoryToLevel() {
        Integer counts = CaseCategorizations.size();
        for (Integer i = counts; i < CurrentLineCounts; i++)
            CaseCategorizations.add(new NCI_Case_Categorization__c(Case__c = caseCategoryRecord.Case__c));
    }
//<------------------------------------------------------
    
    //if case is not specified, Case__c inputfield is displayed - the page is not invoked from case related list
    //resetCaseCategorizations resets categorization list as selecting a case in the inputfield.
    public PageReference resetCaseCategorizations() {
        retrieveCaseCategorizations();
        return null;
    }
    
    //this page controller is passed to the components, so they can fill the Case_Categorization__c in the list CaseCategorizations that each one is responsable for.
    //<c:CaseCategorizationLineItem caseCategorizationController="{!this}" ...
    public Controller_NCICaseCategorization getThis() {
        return this;
    }
    
    public PageReference doSaveCategorization() {       
            List<NCI_Case_Categorization__c> ccToUpsert = new List<NCI_Case_Categorization__c>();
            List<NCI_Case_Categorization__c> ccToDelete = new List<NCI_Case_Categorization__c>();
            //CaseAfterHelper helper = new CaseAfterHelper();
            Map<ID, Case> caseToUpdate = new Map<ID, Case>();
            List<ID> casesIds = new List<ID>();
            for (NCI_Case_Categorization__c cc : CaseCategorizations) {
                casesIds.add(cc.Case__c);
            }
            Map<ID, Case> newMap = new Map<ID, Case>([SELECT ID, Categorizations__c,IsClosed,recordTypeId, Status  FROM Case WHERE ID IN :casesIds]);
            List<Id> concerns = new List<Id>();
            List<Id> categories = new List<Id>();
            List<Id> subcategories = new List<Id>();
            List<Id> symptoms = new List<Id>();
            for (NCI_Case_Categorization__c cc : CaseCategorizations){
                if(cc.Concern__c != null){
                    concerns.add(cc.Concern__c);
                }
                if(cc.Category__c != null){
                    categories.add(cc.Category__c);
                }
                if(cc.Subcategory__c != null){
                    subcategories.add(cc.Subcategory__c);
                }
                if(cc.Symptom__c != null){
                    symptoms.add(cc.Symptom__c);
                }
            }
            List<NCI_CaseCategory_Dependency__c> dependencies = [SELECT Id, Concern__c, Category__c, Subcategory__c, Symptom__c 
                                                            FROM NCI_CaseCategory_Dependency__c 
                                                            WHERE Concern__c IN :concerns 
                                                            AND (Category__c IN :categories OR Category__c = NULL)
                                                            AND (Subcategory__c IN :subcategories OR Subcategory__c = NULL)
                                                            AND (Symptom__c In :symptoms OR Symptom__c = NULL)];
            for (NCI_Case_Categorization__c cc : CaseCategorizations) {
            //Check if Case is Closed before saving
                if(!cc.Case__r.IsClosed){
                    if (cc.Case__c != null && cc.Concern__c != null && cc.Category__c != null && cc.Subcategory__c != null && cc.Symptom__c != null){
                        ccToUpsert.add(cc);                     
                        caseToUpdate.put(cc.Case__c, newMap.get(cc.Case__c));
                        //helper.caseRecordTypes.put(cc.Case__c, newMap.get(cc.Case__c).recordTypeId); 
                    }else if (cc.ID != null && cc.Concern__c == null && cc.Category__c == null && cc.Subcategory__c == null && cc.Symptom__c == null){
                        ccToDelete.add(cc);
                    }else if (cc.Concern__c != null && (cc.Category__c == null || cc.Subcategory__c == null || cc.Symptom__c == null)){                     
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case Categories cannot be saved. Not all fields populated'));
                        return null;                       
                    }
                }else{ 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case Categories cannot be changed for Closed Case'));
                    return null;
                }
            }
        
            try {
                if(ccToDelete.size() > 0)
                    delete ccToDelete;
                if(ccToUpsert.size() > 0)
                    upsert ccToUpsert;              
                    
                    //helper.TreadLogic(newMap);
               
            } catch (Exception e) {
                return null;
            }
        
            return new ApexPages.StandardController(new Case(ID = caseCategoryRecord.Case__c)).view();
        
    }
    
    private void retrieveCaseCategorizations() {
        caseCategoryRecord = (NCI_Case_Categorization__c)stdController.getRecord();
        
        if (caseCategoryRecord.Case__c != null)
            theCase = [Select CaseNumber from Case where ID =: caseCategoryRecord.Case__c];
        
        CaseCategorizations = [Select c.Symptom__c, 
                                c.Symptom__r.Description__c, 
                                c.Symptom_Code__c, 
                                c.Subcategory__c, 
                                c.Subcategory__r.Description__c, 
                                c.Subcategory_Code__c, 
                                c.Name, 
                                c.Major_Component_Code__c, 
                                c.Concern__c, 
                                c.Concern__r.Description__c,
                                c.Concern_Code__c, 
                                c.Category__c, 
                                c.Category__r.Description__c, 
                                c.Category_Code__c, 
                                c.Case__c,
                                c.Case__r.Status,
                                c.Case__r.IsClosed,
                                c.Case__r.CA_CaseReopenCount__c,
                                c.Case__r.Id
                            From NCI_Case_Categorization__c c 
                            Where Case__c =: caseCategoryRecord.Case__c 
                            order by c.ID];
        
        //calculate the current "add more" level index of the array LEVELS 
        //eg. if CaseCategories size is 2, currentLevelIndex = 0, CurrentLineCounts = 3; 
        //  if CaseCategories size is 5, currentLevelIndex = 1, CurrentLineCounts = 6; 
        Integer counts = CaseCategorizations.size();
        Integer lineCounts = 0;
        if(counts <= 10){
            for (Integer i = 0; i <= LEVELS.size(); i++) {
                lineCounts = lineCounts + LEVELS[i];
                if (counts <= lineCounts) {
                    currentLevelIndex = i;
                    CurrentLineCounts = lineCounts;
                    break;
                }
            }
            addCategoryToLevel();
        }else{
            currentLevelIndex = CaseCategorizations.size();
            CurrentLineCounts = CaseCategorizations.size();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Case has more than 10 Case Categorizations, only first 10 can be shown.'));
        }

        //fill CaseCategories with empty CaseCategory up to the current level.
        //eg. if CaseCategories size is 2, add a CaseCategory to CaseCategories = 3; 
               
    }

    //move Concerns dropdown code here to speed up the page - each CaseCategorizationLineItem component does not need to retrieve concerns individually.
    public static final String SELECT_ONE_PROMPT = '--Select One--';
    public List<SelectOption> AllConcerns {
        get {
            if (AllConcerns == null) {
                AllConcerns = new List<SelectOption>();
                AllConcerns.add(new SelectOption(SELECT_ONE_PROMPT, SELECT_ONE_PROMPT));
                List<ID> sortedID = new List<ID>();
                Map<ID, String> IDtoNameMap = new Map<ID, String>();
                
                for (AggregateResult groupedResult : [SELECT Concern__c, Concern__r.Description__c Description, Count(ID) concernChildren 
                                                    FROM NCI_CaseCategory_Dependency__c
                                                    WHERE Concern__r.Active__c = TRUE 
                                                    Group By Concern__c, Concern__r.Description__c]) {
                    String concernID = String.valueOf(groupedResult.get('Concern__c'));
                    String concern = String.valueOf(groupedResult.get('Description'));
                    
                    IDtoNameMap.put(concernID, concern);
                }
                
                sortedID = Text_Util.sortIDByName(IDtoNameMap);
                for (ID key : sortedID)
                    AllConcerns.add(new SelectOption(key, IDtoNameMap.get(key)));
            }
            
            return AllConcerns;
        }
        set;
    }
}