global class Batch_Techline_KB_Categories implements Database.Batchable<sObject> {
	global String query;
	List<Techline__kav> listArticles;
	
	private final String RECORD_TYPE_TECH_LINE = 'TECH LINE Cases';
	
	private ValidationUtility datacheck = new ValidationUtility();
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		String techlineId = Schema.Sobjecttype.Case.getRecordTypeInfosByName(
            ).get(RECORD_TYPE_TECH_LINE).getRecordTypeId();
		
		query = '';
		query += 'SELECT Id, Component_Code_Category__c, '; 
        query += 'Component_Code_Issue__c, Description, DTC_1__c, DTC_2__c, DTC_3__c, ';
        query += 'Make__c, Model_Line__c, Model_Year__c, CaseNumber, Other_DTCs__c, ';
        query += 'Problem_Analysis__c, Project_Number__c, Solution_Description__c, ';
        query += 'Symptom_Code_Category__c, Symptom_Code_Issue__c, Subject ';
        query += ',(SELECT CommentBody FROM CaseComments) ';
        query += 'FROM Case ';
        query += 'WHERE RecordTypeId = \'' + techlineId + '\' ';
        query += 'AND Issue_Type__c = \'Full\' ';
        
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Case> techlineCases){
		if (techlineCases.size() > 0) {
			listArticles = new List<Techline__kav>();
			
			for (Case c : techlineCases) {
	            listArticles.add(getArticle(c));
	        }
	        
	        //insert listArticles;
	        Database.SaveResult[] lstCSIns = Database.insert(listArticles, false);
	        
	        if (lstCSIns.size() > 0) {
                for (integer x = 0; x < techlineCases.size(); x++) {
                	if (lstCSIns[x].isSuccess()) {
                    	System.debug('SR - Successful DML operation');
                    } 
                    else {
                        Database.Error err = lstCSIns[x].getErrors()[0];      
                        System.debug('SR - FAILED DML operation' + err.getMessage());                        
                    }
                }
            }
		}
    }

	global void finish(Database.BatchableContext BC){
	}
	
	// It creates an KB Article with a TechLine Case
    private Techline__kav getArticle(Case techlineCase) {
        Techline__kav article = new Techline__kav();
        try {
        	article.Case_Article_was_Created_from__c = techlineCase.Id;
            article.Component_Code_Category__c = 
                techlineCase.Component_Code_Category__c;
            article.Component_Code_Issue__c = 
                techlineCase.Component_Code_Issue__c;
            article.Description__c = techlineCase.Description;
            article.DTC_1__c = techlineCase.DTC_1__c;
            article.DTC_2__c = techlineCase.DTC_2__c;
            article.DTC_3__c = techlineCase.DTC_3__c;
            article.Make__c = techlineCase.Make__c;
            article.Model_Line__c = techlineCase.Model_Line__c;
            
            if (techlineCase.Model_Year__c != null && techlineCase.Model_Year__c.length() > 4) {
                article.Model_Year__c = techlineCase.Model_Year__c.substring(0,4);
            }
            else {
                article.Model_Year__c = techlineCase.Model_Year__c; 
            }
            
            article.Original_Case_Number__c = techlineCase.CaseNumber;
            article.Other_DTCs__c = techlineCase.Other_DTCs__c;
            article.Problem_Analysis__c = techlineCase.Problem_Analysis__c;
            article.Project_Number__c = techlineCase.Project_Number__c;
            article.Summary = techlineCase.Solution_Description__c;
            article.Symptom_Code_Category__c = 
                techlineCase.Symptom_Code_Category__c;
            article.Symptom_Code_Issue__c = techlineCase.Symptom_Code_Issue__c;
            
            if (techlineCase.CaseComments != null && techlineCase.CaseComments.size() > 0) {
                String concatenatedComments = '';
                for (CaseComment cc : techlineCase.CaseComments) {
                    concatenatedComments += cc.CommentBody;
                    concatenatedComments += '\n\b';
                }
                
                article.Case_Comments__c = concatenatedComments;
            }
            
            article.UrlName = techlineCase.CaseNumber; 
            
            String articleSubject;
            if (techlineCase.Subject == null || techlineCase.Subject.trim() == '') {
                articleSubject = techlineCase.CaseNumber;
            }
            else {
                articleSubject = techlineCase.Subject;
            }
            
            if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_1__c)) {
                articleSubject += ' - ' + techlineCase.DTC_1__c;
            }
            
            if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_2__c)) {
                articleSubject += ' - ' + techlineCase.DTC_2__c;
            }
            
            if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_3__c)) {
                articleSubject += ' - ' + techlineCase.DTC_3__c;
            }
            
            article.Title = articleSubject;
             
        }
        catch (Exception ex) {
            
        }
        
        return article;
    }
}