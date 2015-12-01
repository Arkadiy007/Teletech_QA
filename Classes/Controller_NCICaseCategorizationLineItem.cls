/**********************************************************************
Name: Controller_CaseCategorizationLineItem
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
Controller of CaseCategorizationLineItem component

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 09/06/2011 Created
1.01 - Anna Koseykina 12/18/14 Added flag for Closed Case for displaying Major Component Code and Category Date
1.02 - Anna Koseykina 12/18/14 Changed defenition of Major Code Component
1.1 - Vladimir Martynenko 08/06/2015 Moved Case Categorization logic over NCI Sandbox
***********************************************************************/
public with sharing class Controller_NCICaseCategorizationLineItem {
    private static final String SELECT_ONE_PROMPT = Controller_NCICaseCategorization.SELECT_ONE_PROMPT;
    private static final String NONE_PROMPT = '--None--';
    
    //this flag is used to indicate whether add initial ids to the dropdowns. initial ids are the ones in the record.
    //the four categories stored in the record may not follow any dependency in the CaseCategorization_Dependency table. 
    //for displaying them properly, the options must be added in the dropdowns.
    private Boolean onChange = false;
    
    public Integer Index {get; set;}
    public String TestAtr {get; set;}
    public Controller_NCICaseCategorization CaseCategorizationController {get; set;}
    public NCI_Case_Categorization__c theCC {
        get {
            if (theCC == null) {
                theCC = CaseCategorizationController.CaseCategorizations[Index];
                
                //initialize dropdown selections with the id in record
                selectedConcern = theCC.Concern__c;
                selectedCategory = theCC.Category__c;
                selectedSubcategory = theCC.Subcategory__c;
                selectedSymptom = theCC.Symptom__c;
               
            }
            return theCC;
        }
        set;
    }
   
    public String selectedConcern {get; set;}
    //Concerns is shared by all components in the page. Concerns is passed from CaseCategorization page.
    //<c:CaseCategorizationLineItem allConcerns="{!AllConcerns}" ...
    public List<SelectOption> Concerns {
        get {
            if (onChange || theCC.Concern__c == null)
                return Concerns;
            
            //if looping through the dependency, the id in the record is not found, it needs to be add in the dropdown.
            for (SelectOption c : Concerns) {
                if(c.getValue() != SELECT_ONE_PROMPT && theCC.Concern__c == c.getValue())
                    return Concerns;
            }

            Concerns.add(new SelectOption(theCC.Concern__c, theCC.Concern__r.Description__c));
            return Concerns;
        }
        set;
    }
    
    public String selectedCategory {get; set;}
    public List<SelectOption> Categories {
        get {
            if (Categories == null)
                Categories = new List<SelectOption>();
            else
                Categories.clear();
            Categories.add(new SelectOption(NONE_PROMPT, NONE_PROMPT));
            List<ID> sortedID = new List<ID>();
            Map<ID, String> IDtoNameMap = new Map<ID, String>();
            
            //bFound: if looping through the dependency, the id in the record is not found, it needs to be add in the dropdown.
            Boolean bFound = (onChange || theCC.Category__c == null);
            if (selectedConcern != null && selectedConcern != SELECT_ONE_PROMPT) {
                for (AggregateResult groupedResult : [SELECT Category__c, Category__r.Description__c Description, Count(ID) categoryChildren 
                                                    FROM NCI_CaseCategory_Dependency__c 
                                                    Where Concern__c =: selectedConcern and 
                                                        Category__r.Active__c = TRUE
                                                    Group By Category__c, Category__r.Description__c]) {
                    String categoryID = String.valueOf(groupedResult.get('Category__c'));
                    String category = String.valueOf(groupedResult.get('Description'));
                    IDtoNameMap.put(categoryID, category);
                    
                    if(!bFound && theCC.Category__c == categoryID)
                        bFound = true;
                }
                
                if(!bFound)
                    IDtoNameMap.put(theCC.Category__c, theCC.Category__r.Description__c);
                
                sortedID = Text_Util.sortIDByName(IDtoNameMap);
                for (ID key : sortedID)
                    Categories.add(new SelectOption(key, IDtoNameMap.get(key)));
                
            }
            return Categories;
        }
        set;
    }
    
    public String selectedSubcategory {get; set;}
    public List<SelectOption> Subcategories {
        get {
            if (Subcategories == null)
                Subcategories = new List<SelectOption>();
            else
                Subcategories.clear();
            Subcategories.add(new SelectOption(NONE_PROMPT, NONE_PROMPT));
            List<ID> sortedID = new List<ID>();
            Map<ID, String> IDtoNameMap = new Map<ID, String>();
            
            //bFound: if looping through the dependency, the id in the record is not found, it needs to be add in the dropdown.
            Boolean bFound = (onChange || theCC.Subcategory__c == null);
            if (selectedConcern != null && selectedConcern != SELECT_ONE_PROMPT && 
                    selectedCategory != null && selectedCategory != NONE_PROMPT) {
                for (AggregateResult groupedResult : [SELECT Subcategory__c, Subcategory__r.Description__c Description, Count(ID) subcategoryChildren 
                                                    FROM NCI_CaseCategory_Dependency__c 
                                                    Where Concern__c =: selectedConcern and 
                                                        Category__c =: selectedCategory and 
                                                        Subcategory__r.Active__c = TRUE
                                                    Group By Subcategory__c, Subcategory__r.Description__c]) {
                    String subcategoryID = String.valueOf(groupedResult.get('Subcategory__c'));
                    String subcategory = String.valueOf(groupedResult.get('Description'));
                    IDtoNameMap.put(subcategoryID, subcategory);
                    
                    if(!bFound && theCC.Subcategory__c == subcategoryID)
                        bFound = true;
                }
                
                if(!bFound)
                    IDtoNameMap.put(theCC.Subcategory__c, theCC.Subcategory__r.Description__c);
                
                sortedID = Text_Util.sortIDByName(IDtoNameMap);
                for (ID key : sortedID)
                    Subcategories.add(new SelectOption(key, IDtoNameMap.get(key)));
            }
            return Subcategories;
        }
        set;
    }

    public String selectedSymptom {get; set;}
    public List<SelectOption> Symptoms {
        get {
            if (Symptoms == null)
                Symptoms = new List<SelectOption>();
            else
                Symptoms.clear();
            Symptoms.add(new SelectOption(NONE_PROMPT, NONE_PROMPT));
            List<ID> sortedID = new List<ID>();
            Map<ID, String> IDtoNameMap = new Map<ID, String>();
            
            //bFound: if looping through the dependency, the id in the record is not found, it needs to be add in the dropdown.
            Boolean bFound = (onChange || theCC.Symptom__c == null);
            if (selectedConcern != null && selectedConcern != SELECT_ONE_PROMPT && 
                    selectedCategory != null && selectedCategory != NONE_PROMPT && 
                    selectedSubcategory != null && selectedSubcategory != NONE_PROMPT) {
                for (AggregateResult groupedResult : [SELECT Symptom__c, Symptom__r.Description__c Description, Count(ID) symptomChildren 
                                                    FROM NCI_CaseCategory_Dependency__c 
                                                    Where Concern__c =: selectedConcern and 
                                                        Category__c =: selectedCategory and 
                                                        Subcategory__c =: selectedSubcategory and 
                                                        Symptom__r.Active__c = TRUE
                                                    Group By Symptom__c, Symptom__r.Description__c]) {
                    String symptomID = String.valueOf(groupedResult.get('Symptom__c'));
                    String symptom = String.valueOf(groupedResult.get('Description'));
                    IDtoNameMap.put(symptomID, symptom);
                    
                    if(!bFound && theCC.Symptom__c == symptomID)
                        bFound = true;
                }
                
                if(!bFound)
                    IDtoNameMap.put(theCC.Symptom__c, theCC.Symptom__r.Description__c);
                
                sortedID = Text_Util.sortIDByName(IDtoNameMap);
                for (ID key : sortedID)
                    Symptoms.add(new SelectOption(key, IDtoNameMap.get(key)));
            }
            return Symptoms;
        }
        set;
    }
    

    //Concern dropdown onchange action
    public PageReference onSelectedConcernChanged() {
        onChange = true;
        
        selectedCategory = NONE_PROMPT;
        selectedSubcategory = NONE_PROMPT;
        selectedSymptom = NONE_PROMPT;
        
        theCC.Concern__c = selectedConcern == SELECT_ONE_PROMPT ? null : selectedConcern;
        theCC.Category__c = null;
        theCC.Subcategory__c = null;
        theCC.Symptom__c = null;
        if(theCC.Concern__c != null){
            CaseCategorizationController.lineItemsPopulated = false;
        }else {
            CaseCategorizationController.lineItemsPopulated = true;
        }
        
        return null;
    }
    
    //Category dropdown onchange action
    public PageReference onSelectedCategoryChanged() {
        onChange = true;
        
        selectedSubcategory = NONE_PROMPT;
        selectedSymptom = NONE_PROMPT;

        
        theCC.Concern__c = selectedConcern == SELECT_ONE_PROMPT ? null : selectedConcern;
        theCC.Category__c = selectedCategory == NONE_PROMPT ? null : selectedCategory;
        theCC.Subcategory__c = null;
        theCC.Symptom__c = null;
        if(theCC.Concern__c != null){
            CaseCategorizationController.lineItemsPopulated = false;
        }else {
            CaseCategorizationController.lineItemsPopulated = true;
        }
        
        return null;
    }
    
    //Subcategory dropdown onchange action
    public PageReference onSelectedSubcategoryChanged() {
        onChange = true;
        
        selectedSymptom = NONE_PROMPT;
        
        theCC.Concern__c = selectedConcern == SELECT_ONE_PROMPT ? null : selectedConcern;
        theCC.Category__c = selectedCategory == NONE_PROMPT ? null : selectedCategory;
        theCC.Subcategory__c = selectedSubcategory == NONE_PROMPT ? null : selectedSubcategory;
        theCC.Symptom__c = null;
        if(theCC.Concern__c != null){
            CaseCategorizationController.lineItemsPopulated = false;
        }else {
            CaseCategorizationController.lineItemsPopulated = true;
        }
        
        return null;
    }
    
    //Symptom dropdown onchange action
    public PageReference populateEntries() {
        onChange = true;
        
        theCC.Concern__c = selectedConcern == SELECT_ONE_PROMPT ? null : selectedConcern;
        theCC.Category__c = selectedCategory == NONE_PROMPT ? null : selectedCategory;
        theCC.Subcategory__c = selectedSubcategory == NONE_PROMPT ? null : selectedSubcategory;
        theCC.Symptom__c = selectedSymptom == NONE_PROMPT ? null : selectedSymptom;

        if(theCC.Concern__c != null && theCC.Category__c != null && theCC.Subcategory__c != null && theCC.Symptom__c != null){
            CaseCategorizationController.lineItemsPopulated = true;
        }else{
            CaseCategorizationController.lineItemsPopulated = false;
        }

        return null;
    }
}